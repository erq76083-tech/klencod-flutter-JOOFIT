import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================================
// 1. GLOBAL CRASH-FREE ENTRY POINT & ERROR BOUNDARY
// ============================================================================

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Prevent any unhandled Flutter framework error from crashing the app
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('JooFit Caught FlutterError: ${details.exceptionAsString()}');
    };

    // Custom safe ErrorWidget in iOS Dark style instead of red crash screen
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: const Color(0xFF0B0D12),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1F2A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF323746)),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.shield_lefthalf_fill,
                    color: Color(0xFF0A84FF),
                    size: 40,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'تمت حماية التطبيق من خطأ غير متوقع',
                    style: TextStyle(
                      color: Color(0xFFF2F2F7),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'يمكنك المتابعة بأمان دون فقدان أي بيانات.',
                    style: TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };

    // Configure iOS-like dark status bar & navigation bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF0B0D12),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Initialize Smart Notifications safely without blocking app launch
    await SmartNotificationService.instance.initSafe();

    runApp(const JooFitIosApp());
  }, (Object error, StackTrace stack) {
    debugPrint('JooFit Zone Guard Caught Error: $error\n$stack');
  });
}

// ============================================================================
// 2. iOS 18 CUPERTINO DARK MATTE DESIGN SYSTEM
// ============================================================================

class IosPalette {
  // Calm matte dark backgrounds (Zero eye strain, authentic iOS Dark Mode)
  static const Color bgPrimary = Color(0xFF0B0D12);
  static const Color bgGrouped = Color(0xFF13161F);
  static const Color cardSurface = Color(0xFF1C1F2A);
  static const Color cardElevated = Color(0xFF262A38);
  static const Color cardHighlight = Color(0xFF2F3546);
  static const Color separator = Color(0xFF323746);

  // Authentic iOS System Tint Colors
  static const Color iosBlue = Color(0xFF0A84FF);
  static const Color iosIndigo = Color(0xFF5E5CE6);
  static const Color iosGreen = Color(0xFF30D158);
  static const Color iosOrange = Color(0xFFFF9F0A);
  static const Color iosRed = Color(0xFFFF453A);
  static const Color iosTeal = Color(0xFF64D2FF);
  static const Color iosPurple = Color(0xFFBF5AF2);
  static const Color iosYellow = Color(0xFFFFD60A);

  // iOS Typography Labels
  static const Color textPrimary = Color(0xFFF2F2F7);
  static const Color textSecondary = Color(0xFFAEAEB2);
  static const Color textMuted = Color(0xFF8E8E93);

  static const List<Color> accentPresets = [
    iosBlue,
    iosGreen,
    iosIndigo,
    iosOrange,
    iosPurple,
    iosTeal,
  ];

  static const List<String> accentNames = [
    'أزرق iOS الأصلي',
    'أخضر Apple Fitness',
    'نيلي iOS Pro',
    'برتقالي الطاقة',
    'بنفسجي العمق',
    'سماوي هادئ',
  ];
}

// ============================================================================
// 3. SMART NOTIFICATION SERVICE (100% CRASH-SAFE)
// ============================================================================

class SmartNotificationService {
  SmartNotificationService._();
  static final SmartNotificationService instance = SmartNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initSafe() async {
    if (_initialized) return;
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@drawable/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _plugin.initialize(initSettings);
      _initialized = true;
    } catch (e) {
      debugPrint('Notification safe init fallback: $e');
      _initialized = false;
    }
  }

  Future<void> requestPermissionsSafe() async {
    try {
      if (!_initialized) await initSafe();
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.requestNotificationsPermission();
      }
    } catch (e) {
      debugPrint('Permission request handled safely: $e');
    }
  }

  Future<void> showSmartNotification({
    required int id,
    required String title,
    required String body,
    String channelId = 'joofit_smart_channel',
    String channelName = 'تنبيهات JOO FIT الذكية',
  }) async {
    try {
      HapticFeedback.mediumImpact();
      if (!_initialized) await initSafe();
      if (!_initialized) return;

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'تنبيهات التمرين ومؤقت الراحة والترطيب الذكي',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@drawable/ic_launcher',
        color: const Color(0xFF0A84FF),
      );
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.show(id, title, body, details);
    } catch (e) {
      debugPrint('Show notification handled safely: $e');
    }
  }
}

// ============================================================================
// 4. DATA MODELS (DEFENSIVE JSON SERIALIZATION)
// ============================================================================

class SetEntry {
  int setNumber;
  int targetReps;
  int actualReps;
  double weightKg;
  bool completed;

  SetEntry({
    required this.setNumber,
    required this.targetReps,
    int? actualReps,
    this.weightKg = 20.0,
    this.completed = false,
  }) : actualReps = actualReps ?? targetReps;

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'targetReps': targetReps,
        'actualReps': actualReps,
        'weightKg': weightKg,
        'completed': completed,
      };

  factory SetEntry.fromJson(Map<String, dynamic> json) => SetEntry(
        setNumber: (json['setNumber'] as num?)?.toInt() ?? 1,
        targetReps: (json['targetReps'] as num?)?.toInt() ?? 10,
        actualReps: (json['actualReps'] as num?)?.toInt() ?? 10,
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 20.0,
        completed: json['completed'] as bool? ?? false,
      );
}

class ExerciseItem {
  final String id;
  String name;
  String muscleGroup;
  String equipment;
  int restSeconds;
  String notes;
  List<SetEntry> sets;

  ExerciseItem({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.equipment = 'بار / دمبل',
    this.restSeconds = 90,
    this.notes = '',
    required this.sets,
  });

  factory ExerciseItem.create({
    required String name,
    required String muscleGroup,
    String equipment = 'بار / دمبل',
    int setsCount = 4,
    int repsCount = 10,
    double startWeight = 40.0,
    int restSeconds = 90,
    String notes = '',
  }) {
    final safeSetsCount = setsCount.clamp(1, 12);
    return ExerciseItem(
      id: '${DateTime.now().microsecondsSinceEpoch}_${name.hashCode}',
      name: name,
      muscleGroup: muscleGroup,
      equipment: equipment,
      restSeconds: restSeconds,
      notes: notes,
      sets: List.generate(
        safeSetsCount,
        (i) => SetEntry(
          setNumber: i + 1,
          targetReps: repsCount,
          actualReps: repsCount,
          weightKg: startWeight,
          completed: false,
        ),
      ),
    );
  }

  int get completedSetsCount => sets.where((s) => s.completed).length;
  bool get isAllCompleted => sets.isNotEmpty && completedSetsCount == sets.length;

  double get totalVolumeKg => sets
      .where((s) => s.completed)
      .fold(0.0, (sum, s) => sum + (s.weightKg * s.actualReps));

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup,
        'equipment': equipment,
        'restSeconds': restSeconds,
        'notes': notes,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    final rawSets = json['sets'] as List<dynamic>? ?? [];
    return ExerciseItem(
      id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name']?.toString() ?? 'تمرين',
      muscleGroup: json['muscleGroup']?.toString() ?? 'عام',
      equipment: json['equipment']?.toString() ?? 'بار / دمبل',
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 90,
      notes: json['notes']?.toString() ?? '',
      sets: rawSets
          .map((e) => SetEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  ExerciseItem cloneDeep() => ExerciseItem.fromJson(toJson());
}

class WorkoutDay {
  final String id;
  String title;
  String subtitle;
  List<String> targetMuscles;
  bool isRestDay;
  List<ExerciseItem> exercises;

  WorkoutDay({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.targetMuscles,
    this.isRestDay = false,
    required this.exercises,
  });

  int get totalSets =>
      exercises.fold(0, (sum, ex) => sum + ex.sets.length);

  int get completedSets =>
      exercises.fold(0, (sum, ex) => sum + ex.completedSetsCount);

  double get progress =>
      totalSets == 0 ? (isRestDay ? 1.0 : 0.0) : completedSets / totalSets;

  double get totalVolumeKg =>
      exercises.fold(0.0, (sum, ex) => sum + ex.totalVolumeKg);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'targetMuscles': targetMuscles,
        'isRestDay': isRestDay,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List<dynamic>? ?? [];
    final rawMuscles = json['targetMuscles'] as List<dynamic>? ?? [];
    return WorkoutDay(
      id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? 'يوم تدريبي',
      subtitle: json['subtitle']?.toString() ?? '',
      targetMuscles: rawMuscles.map((e) => e.toString()).toList(),
      isRestDay: json['isRestDay'] as bool? ?? false,
      exercises: rawExercises
          .map((e) => ExerciseItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  WorkoutDay cloneDeep() => WorkoutDay.fromJson(toJson());
}

class WorkoutSystem {
  final String id;
  String name;
  String category;
  String description;
  int daysPerWeek;
  String level;
  List<WorkoutDay> days;

  WorkoutSystem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.daysPerWeek,
    required this.level,
    required this.days,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'daysPerWeek': daysPerWeek,
        'level': level,
        'days': days.map((d) => d.toJson()).toList(),
      };

  factory WorkoutSystem.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as List<dynamic>? ?? [];
    return WorkoutSystem(
      id: json['id']?.toString() ?? 'sys_default',
      name: json['name']?.toString() ?? 'النظام الذكي',
      category: json['category']?.toString() ?? 'PPL',
      description: json['description']?.toString() ?? '',
      daysPerWeek: (json['daysPerWeek'] as num?)?.toInt() ?? 5,
      level: json['level']?.toString() ?? 'متوسط - متقدم',
      days: rawDays
          .map((d) => WorkoutDay.fromJson(Map<String, dynamic>.from(d as Map)))
          .toList(),
    );
  }

  WorkoutSystem cloneDeep() => WorkoutSystem.fromJson(toJson());
}

class WorkoutLog {
  final String id;
  final String dayTitle;
  final String systemName;
  final DateTime completedAt;
  final int totalSets;
  final double totalVolumeKg;
  final int durationMinutes;
  final List<String> trainedMuscles;

  WorkoutLog({
    required this.id,
    required this.dayTitle,
    required this.systemName,
    required this.completedAt,
    required this.totalSets,
    required this.totalVolumeKg,
    required this.durationMinutes,
    required this.trainedMuscles,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dayTitle': dayTitle,
        'systemName': systemName,
        'completedAt': completedAt.toIso8601String(),
        'totalSets': totalSets,
        'totalVolumeKg': totalVolumeKg,
        'durationMinutes': durationMinutes,
        'trainedMuscles': trainedMuscles,
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        id: json['id']?.toString() ?? '',
        dayTitle: json['dayTitle']?.toString() ?? 'تمرين مكتمل',
        systemName: json['systemName']?.toString() ?? 'JOO FIT',
        completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? '') ??
            DateTime.now(),
        totalSets: (json['totalSets'] as num?)?.toInt() ?? 0,
        totalVolumeKg: (json['totalVolumeKg'] as num?)?.toDouble() ?? 0.0,
        durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 45,
        trainedMuscles: (json['trainedMuscles'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}

class SmartReminder {
  final String id;
  String title;
  String subtitle;
  String timeLabel;
  bool enabled;
  String category;

  SmartReminder({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    this.enabled = true,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'timeLabel': timeLabel,
        'enabled': enabled,
        'category': category,
      };

  factory SmartReminder.fromJson(Map<String, dynamic> json) => SmartReminder(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        subtitle: json['subtitle']?.toString() ?? '',
        timeLabel: json['timeLabel']?.toString() ?? '18:00',
        enabled: json['enabled'] as bool? ?? true,
        category: json['category']?.toString() ?? 'workout',
      );
}

class GymTaskItem {
  final String id;
  String title;
  bool done;
  final DateTime createdAt;

  GymTaskItem({
    required this.id,
    required this.title,
    this.done = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
        'createdAt': createdAt.toIso8601String(),
      };

  factory GymTaskItem.fromJson(Map<String, dynamic> json) => GymTaskItem(
        id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: json['title']?.toString() ?? '',
        done: json['done'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}

// ============================================================================
// 5. ULTRA-SMART WORKOUT SCHEDULE ENGINE & NATURAL LANGUAGE PARSER
// ============================================================================

class SmartScheduleEngine {
  /// Built-in pro training systems covering every major bodybuilding & fitness methodology
  static List<WorkoutSystem> getBuiltInSystems() {
    return [
      _buildPplSystem(),
      _buildArnoldSplitSystem(),
      _buildUpperLowerSystem(),
      _buildBroSplitSystem(),
      _buildFullBodySystem(),
      _buildPhulSystem(),
    ];
  }

  static WorkoutSystem _buildPplSystem() {
    return WorkoutSystem(
      id: 'sys_ppl_pro',
      name: 'نظام الدفع والسحب والأرجل (PPL Pro)',
      category: 'Push / Pull / Legs',
      description:
          'النظام الأكثر كفاءة عالمياً لتضخيم العضلات وزيادة القوة بتردد مرتين أسبوعياً لكل عضلة.',
      daysPerWeek: 6,
      level: 'متوسط - محترف',
      days: [
        WorkoutDay(
          id: 'ppl_d1',
          title: 'اليوم 1: دفع (Push A - تركيز الصدر)',
          subtitle: 'صدر + أكتاف أمامية وجانبية + ترايسبس',
          targetMuscles: ['الصدر', 'الأكتاف', 'الترايسبس'],
          exercises: [
            ExerciseItem.create(
              name: 'بنش برس مستوي بالبار (Barbell Bench Press)',
              muscleGroup: 'الصدر',
              equipment: 'بار',
              setsCount: 4,
              repsCount: 8,
              startWeight: 70,
              restSeconds: 120,
              notes: 'تحكم في النزول لمدة ثانيتين وادفع بقوة.',
            ),
            ExerciseItem.create(
              name: 'تجميع دمبل عالي (Incline Dumbbell Press)',
              muscleGroup: 'الصدر',
              equipment: 'دمبل',
              setsCount: 4,
              repsCount: 10,
              startWeight: 28,
              restSeconds: 90,
              notes: 'زاوية البنش 30 درجة لاستهداف أعلى الصدر.',
            ),
            ExerciseItem.create(
              name: 'تفتيح كابل من أسفل لأعلى (Cable Fly)',
              muscleGroup: 'الصدر',
              equipment: 'كابل',
              setsCount: 3,
              repsCount: 12,
              startWeight: 15,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'ضغط أكتاف بالدمبل جالس (Overhead Shoulder Press)',
              muscleGroup: 'الأكتاف',
              equipment: 'دمبل',
              setsCount: 4,
              repsCount: 10,
              startWeight: 22,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'رفرفة جانبي بالدمبل (Lateral Raises)',
              muscleGroup: 'الأكتاف',
              equipment: 'دمبل',
              setsCount: 4,
              repsCount: 15,
              startWeight: 12,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'ترايسبس بالحبل على الكابل (Triceps Rope Pushdown)',
              muscleGroup: 'الترايسبس',
              equipment: 'كابل',
              setsCount: 4,
              repsCount: 12,
              startWeight: 25,
              restSeconds: 60,
            ),
          ],
        ),
        WorkoutDay(
          id: 'ppl_d2',
          title: 'اليوم 2: سحب (Pull A - اتساع وكثافة الظهر)',
          subtitle: 'ظهر كامل + كتف خلفي + بايسبس',
          targetMuscles: ['الظهر', 'الأكتاف', 'البايسبس'],
          exercises: [
            ExerciseItem.create(
              name: 'سحب عالي واسع (Lat Pulldown)',
              muscleGroup: 'الظهر',
              equipment: 'جهاز كابل',
              setsCount: 4,
              repsCount: 10,
              startWeight: 65,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'تجديف بالبار منحني (Barbell Bent-Over Row)',
              muscleGroup: 'الظهر',
              equipment: 'بار',
              setsCount: 4,
              repsCount: 8,
              startWeight: 60,
              restSeconds: 120,
            ),
            ExerciseItem.create(
              name: 'سحب أرضي ضيق (Seated Cable Row)',
              muscleGroup: 'الظهر',
              equipment: 'كابل',
              setsCount: 3,
              repsCount: 12,
              startWeight: 55,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'سحب الحبل للوجه للكتف الخلفي (Face Pulls)',
              muscleGroup: 'الأكتاف',
              equipment: 'كابل',
              setsCount: 4,
              repsCount: 15,
              startWeight: 20,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'تبادل بايسبس بالبار الزجزاج (EZ-Bar Curl)',
              muscleGroup: 'البايسبس',
              equipment: 'بار زجزاج',
              setsCount: 4,
              repsCount: 10,
              startWeight: 30,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'هامر كيرل بالدمبل (Hammer Curls)',
              muscleGroup: 'البايسبس',
              equipment: 'دمبل',
              setsCount: 3,
              repsCount: 12,
              startWeight: 16,
              restSeconds: 60,
            ),
          ],
        ),
        WorkoutDay(
          id: 'ppl_d3',
          title: 'اليوم 3: أرجل وبطن (Legs & Core)',
          subtitle: 'أماميات + خلفيات + سمانة + بطن',
          targetMuscles: ['الأرجل', 'البطن'],
          exercises: [
            ExerciseItem.create(
              name: 'سكوات بالبار الحر (Barbell Back Squat)',
              muscleGroup: 'الأرجل',
              equipment: 'بار',
              setsCount: 4,
              repsCount: 8,
              startWeight: 90,
              restSeconds: 150,
            ),
            ExerciseItem.create(
              name: 'دفش أرجل على الجهاز (Leg Press)',
              muscleGroup: 'الأرجل',
              equipment: 'جهاز',
              setsCount: 4,
              repsCount: 12,
              startWeight: 160,
              restSeconds: 120,
            ),
            ExerciseItem.create(
              name: 'ديدليفت روماني للخلفيات (Romanian Deadlift)',
              muscleGroup: 'الأرجل',
              equipment: 'بار',
              setsCount: 4,
              repsCount: 10,
              startWeight: 75,
              restSeconds: 120,
            ),
            ExerciseItem.create(
              name: 'رفرفة أرجل أمامي (Leg Extension)',
              muscleGroup: 'الأرجل',
              equipment: 'جهاز',
              setsCount: 3,
              repsCount: 15,
              startWeight: 50,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'سمانة واقف على الجهاز (Standing Calf Raise)',
              muscleGroup: 'الأرجل',
              equipment: 'جهاز',
              setsCount: 4,
              repsCount: 15,
              startWeight: 60,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'طحن بطن على الكابل (Cable Crunch)',
              muscleGroup: 'البطن',
              equipment: 'كابل',
              setsCount: 4,
              repsCount: 15,
              startWeight: 30,
              restSeconds: 45,
            ),
          ],
        ),
        WorkoutDay(
          id: 'ppl_d4',
          title: 'اليوم 4: راحة واستشفاء نشط',
          subtitle: 'تمدد عضلي + مشي خفيف 20 دقيقة + ترطيب عالي',
          targetMuscles: ['استشفاء'],
          isRestDay: true,
          exercises: [],
        ),
      ],
    );
  }

  static WorkoutSystem _buildArnoldSplitSystem() {
    return WorkoutSystem(
      id: 'sys_arnold_pro',
      name: 'نظام أرنولد الذهبي (Arnold Split)',
      category: 'Arnold Split',
      description:
          'الجمع الذكي بين العضلات المتضادة (صدر مع ظهر) و(أكتاف مع ذراعين) لضخ دم هائل وتناظر عضلي مثالي.',
      daysPerWeek: 6,
      level: 'متقدم',
      days: [
        WorkoutDay(
          id: 'arn_d1',
          title: 'اليوم 1: صدر + ظهر (Chest & Back)',
          subtitle: 'ضخامة الجزء العلوي والعضلات المتضادة',
          targetMuscles: ['الصدر', 'الظهر'],
          exercises: [
            ExerciseItem.create(
              name: 'بنش برس مستوي بالبار',
              muscleGroup: 'الصدر',
              setsCount: 4,
              repsCount: 10,
              startWeight: 70,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'عقلة أو سحب عالي واسع',
              muscleGroup: 'الظهر',
              setsCount: 4,
              repsCount: 10,
              startWeight: 65,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'تجميع دمبل عالي للصدر',
              muscleGroup: 'الصدر',
              setsCount: 4,
              repsCount: 10,
              startWeight: 28,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'تجديف بالبار T-Bar Row',
              muscleGroup: 'الظهر',
              setsCount: 4,
              repsCount: 10,
              startWeight: 60,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'غطس متوازي للصدر السفلي (Dips)',
              muscleGroup: 'الصدر',
              setsCount: 3,
              repsCount: 12,
              startWeight: 15,
              restSeconds: 60,
            ),
          ],
        ),
        WorkoutDay(
          id: 'arn_d2',
          title: 'اليوم 2: أكتاف + ذراعين (Shoulders & Arms)',
          subtitle: 'تكوير الأكتاف وتفجير البايسبس والترايسبس',
          targetMuscles: ['الأكتاف', 'البايسبس', 'الترايسبس'],
          exercises: [
            ExerciseItem.create(
              name: 'أرنولد برس بالدمبل (Arnold Press)',
              muscleGroup: 'الأكتاف',
              setsCount: 4,
              repsCount: 10,
              startWeight: 22,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'رفرفة جانبي بالدمبل',
              muscleGroup: 'الأكتاف',
              setsCount: 4,
              repsCount: 15,
              startWeight: 12,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'بايسبس بار واقف',
              muscleGroup: 'البايسبس',
              setsCount: 4,
              repsCount: 10,
              startWeight: 32,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'فرنساوي بالبار الزجزاج للترايسبس (Skull Crushers)',
              muscleGroup: 'الترايسبس',
              setsCount: 4,
              repsCount: 10,
              startWeight: 30,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'ارتكاز بايسبس + حبل ترايسبس سوبر ست',
              muscleGroup: 'البايسبس',
              setsCount: 3,
              repsCount: 12,
              startWeight: 20,
              restSeconds: 60,
            ),
          ],
        ),
        WorkoutDay(
          id: 'arn_d3',
          title: 'اليوم 3: أرجل وبطن شامل (Legs & Abs)',
          subtitle: 'قوة الأرجل الأمامية والخلفية والسمانة',
          targetMuscles: ['الأرجل', 'البطن'],
          exercises: [
            ExerciseItem.create(
              name: 'سكوات بالبار',
              muscleGroup: 'الأرجل',
              setsCount: 4,
              repsCount: 8,
              startWeight: 95,
              restSeconds: 150,
            ),
            ExerciseItem.create(
              name: 'طعن بالدمبل (Walking Lunges)',
              muscleGroup: 'الأرجل',
              setsCount: 3,
              repsCount: 12,
              startWeight: 20,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'رفرفة خلفي جهاز (Leg Curl)',
              muscleGroup: 'الأرجل',
              setsCount: 4,
              repsCount: 12,
              startWeight: 45,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'سمانة جالس',
              muscleGroup: 'الأرجل',
              setsCount: 4,
              repsCount: 15,
              startWeight: 50,
              restSeconds: 60,
            ),
          ],
        ),
      ],
    );
  }

  static WorkoutSystem _buildUpperLowerSystem() {
    return WorkoutSystem(
      id: 'sys_upper_lower',
      name: 'نظام علوي / سفلي (Upper / Lower 4x)',
      category: 'Upper / Lower',
      description:
          'توازن مثالي بين التمرين والاستشفاء على مدار 4 أيام أسبوعياً مع نتائج ممتازة في القوة والضخامة.',
      daysPerWeek: 4,
      level: 'جميع المستويات',
      days: [
        WorkoutDay(
          id: 'ul_d1',
          title: 'اليوم 1: جزء علوي قوة (Upper A)',
          subtitle: 'صدر + ظهر + أكتاف + ذراعين',
          targetMuscles: ['الصدر', 'الظهر', 'الأكتاف', 'البايسبس', 'الترايسبس'],
          exercises: [
            ExerciseItem.create(
              name: 'بنش برس بالبار',
              muscleGroup: 'الصدر',
              setsCount: 4,
              repsCount: 6,
              startWeight: 75,
              restSeconds: 120,
            ),
            ExerciseItem.create(
              name: 'تجديف بالبار للظهر',
              muscleGroup: 'الظهر',
              setsCount: 4,
              repsCount: 8,
              startWeight: 65,
              restSeconds: 120,
            ),
            ExerciseItem.create(
              name: 'ضغط أكتاف عسكري (Military Press)',
              muscleGroup: 'الأكتاف',
              setsCount: 3,
              repsCount: 8,
              startWeight: 45,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'سحب عالي واسع',
              muscleGroup: 'الظهر',
              setsCount: 3,
              repsCount: 10,
              startWeight: 60,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'تبادل دمبل بايسبس + دفع كابل ترايسبس',
              muscleGroup: 'البايسبس',
              setsCount: 3,
              repsCount: 12,
              startWeight: 16,
              restSeconds: 60,
            ),
          ],
        ),
        WorkoutDay(
          id: 'ul_d2',
          title: 'اليوم 2: جزء سفلي وبطن (Lower A)',
          subtitle: 'أرجل شاملة + سمانة + كور',
          targetMuscles: ['الأرجل', 'البطن'],
          exercises: [
            ExerciseItem.create(
              name: 'سكوات بالبار',
              muscleGroup: 'الأرجل',
              setsCount: 4,
              repsCount: 6,
              startWeight: 95,
              restSeconds: 150,
            ),
            ExerciseItem.create(
              name: 'ديدليفت روماني',
              muscleGroup: 'الأرجل',
              setsCount: 4,
              repsCount: 8,
              startWeight: 80,
              restSeconds: 120,
            ),
            ExerciseItem.create(
              name: 'دفش أرجل (Leg Press)',
              muscleGroup: 'الأرجل',
              setsCount: 3,
              repsCount: 12,
              startWeight: 160,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'سمانة + بطن',
              muscleGroup: 'البطن',
              setsCount: 4,
              repsCount: 15,
              startWeight: 40,
              restSeconds: 60,
            ),
          ],
        ),
        WorkoutDay(
          id: 'ul_d3',
          title: 'اليوم 3: راحة واستشفاء',
          subtitle: 'راحة تامة للعضلات والجهاز العصبي',
          targetMuscles: ['استشفاء'],
          isRestDay: true,
          exercises: [],
        ),
      ],
    );
  }

  static WorkoutSystem _buildBroSplitSystem() {
    return WorkoutSystem(
      id: 'sys_bro_split',
      name: 'نظام عضلة كل يوم (Pro Bodybuilding Split)',
      category: 'Bro Split',
      description:
          'تركيز كامل وعزل عميق لكل عضلة في يوم مستقل مع حجم تدريبي عالٍ لتشكيل التفاصيل العضلية.',
      daysPerWeek: 5,
      level: 'متوسط - متقدم',
      days: [
        WorkoutDay(
          id: 'bro_1',
          title: 'اليوم 1: يوم الصدر العالمي (Chest Day)',
          subtitle: 'صدر علوي + مستوي + سفلي + تفتيح',
          targetMuscles: ['الصدر'],
          exercises: [
            ExerciseItem.create(
              name: 'بنش برس مستوي بالبار',
              muscleGroup: 'الصدر',
              setsCount: 4,
              repsCount: 10,
              startWeight: 70,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'تجميع دمبل عالي',
              muscleGroup: 'الصدر',
              setsCount: 4,
              repsCount: 10,
              startWeight: 28,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'تجميع جهاز الصدر (Chest Press Machine)',
              muscleGroup: 'الصدر',
              setsCount: 3,
              repsCount: 12,
              startWeight: 60,
              restSeconds: 75,
            ),
            ExerciseItem.create(
              name: 'تفتيح كابل كروس أوفر (Cable Crossover)',
              muscleGroup: 'الصدر',
              setsCount: 4,
              repsCount: 15,
              startWeight: 15,
              restSeconds: 60,
            ),
          ],
        ),
        WorkoutDay(
          id: 'bro_2',
          title: 'اليوم 2: يوم الظهر العريض (Back Day)',
          subtitle: 'مجنص + وسط الظهر + قطنية',
          targetMuscles: ['الظهر'],
          exercises: [
            ExerciseItem.create(
              name: 'سحب عالي أمامي واسع',
              muscleGroup: 'الظهر',
              setsCount: 4,
              repsCount: 10,
              startWeight: 65,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'تجديف بالبار',
              muscleGroup: 'الظهر',
              setsCount: 4,
              repsCount: 10,
              startWeight: 60,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'منشار بالدمبل فردي (One-Arm Dumbbell Row)',
              muscleGroup: 'الظهر',
              setsCount: 3,
              repsCount: 12,
              startWeight: 30,
              restSeconds: 75,
            ),
            ExerciseItem.create(
              name: 'سحب أرضي ضيق',
              muscleGroup: 'الظهر',
              setsCount: 4,
              repsCount: 12,
              startWeight: 55,
              restSeconds: 75,
            ),
          ],
        ),
        WorkoutDay(
          id: 'bro_3',
          title: 'اليوم 3: الأكتاف والترابيس (Shoulders)',
          subtitle: 'كتف أمامي + جانبي + خلفي + ترابيس',
          targetMuscles: ['الأكتاف'],
          exercises: [
            ExerciseItem.create(
              name: 'تجميع أكتاف بالدمبل',
              muscleGroup: 'الأكتاف',
              setsCount: 4,
              repsCount: 10,
              startWeight: 24,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'رفرفة جانبي بالدمبل',
              muscleGroup: 'الأكتاف',
              setsCount: 4,
              repsCount: 15,
              startWeight: 12,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'فراشة خلفي على الجهاز (Rear Delt Fly)',
              muscleGroup: 'الأكتاف',
              setsCount: 4,
              repsCount: 15,
              startWeight: 45,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'ترابيس بالدمبل (Dumbbell Shrugs)',
              muscleGroup: 'الأكتاف',
              setsCount: 4,
              repsCount: 12,
              startWeight: 32,
              restSeconds: 60,
            ),
          ],
        ),
        WorkoutDay(
          id: 'bro_4',
          title: 'اليوم 4: الذراعين والبطن (Arms & Abs)',
          subtitle: 'بايسبس + ترايسبس + سواعد',
          targetMuscles: ['البايسبس', 'الترايسبس', 'البطن'],
          exercises: [
            ExerciseItem.create(
              name: 'بايسبس بالبار الزجزاج',
              muscleGroup: 'البايسبس',
              setsCount: 4,
              repsCount: 10,
              startWeight: 30,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'دفع حبل ترايسبس',
              muscleGroup: 'الترايسبس',
              setsCount: 4,
              repsCount: 12,
              startWeight: 25,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'هامر كيرل بالدمبل',
              muscleGroup: 'البايسبس',
              setsCount: 3,
              repsCount: 12,
              startWeight: 16,
              restSeconds: 60,
            ),
            ExerciseItem.create(
              name: 'فرنساوي دمبل فوق الرأس',
              muscleGroup: 'الترايسبس',
              setsCount: 3,
              repsCount: 12,
              startWeight: 24,
              restSeconds: 60,
            ),
          ],
        ),
        WorkoutDay(
          id: 'bro_5',
          title: 'اليوم 5: الأرجل الكاملة (Leg Day)',
          subtitle: 'أماميات + خلفيات + سمانة',
          targetMuscles: ['الأرجل'],
          exercises: [
            ExerciseItem.create(
              name: 'سكوات بالبار',
              muscleGroup: 'الأرجل',
              setsCount: 4,
              repsCount: 10,
              startWeight: 90,
              restSeconds: 120,
            ),
            ExerciseItem.create(
              name: 'دفش أرجل (Leg Press)',
              muscleGroup: 'الأرجل',
              setsCount: 4,
              repsCount: 12,
              startWeight: 160,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'رفرفة أمامي + رفرفة خلفي',
              muscleGroup: 'الأرجل',
              setsCount: 4,
              repsCount: 15,
              startWeight: 50,
              restSeconds: 60,
            ),
          ],
        ),
      ],
    );
  }

  static WorkoutSystem _buildFullBodySystem() {
    return WorkoutSystem(
      id: 'sys_full_body',
      name: 'نظام الجسم الكامل الذكي (Full Body 3x)',
      category: 'Full Body',
      description:
          'مثالي لـ 3 أيام أسبوعياً؛ يركز على التمارين المركبة الأساسية لحرق الدهون وبناء الكتلة العضلية بأعلى كفاءة زمنية.',
      daysPerWeek: 3,
      level: 'مبتدئ - متوسط',
      days: [
        WorkoutDay(
          id: 'fb_1',
          title: 'اليوم 1: جسم كامل A (مركبات أساسية)',
          subtitle: 'صدر + ظهر + أرجل + أكتاف',
          targetMuscles: ['الصدر', 'الظهر', 'الأرجل', 'الأكتاف'],
          exercises: [
            ExerciseItem.create(
              name: 'سكوات بالبار أو السميث',
              muscleGroup: 'الأرجل',
              setsCount: 4,
              repsCount: 10,
              startWeight: 70,
              restSeconds: 120,
            ),
            ExerciseItem.create(
              name: 'بنش برس مستوي',
              muscleGroup: 'الصدر',
              setsCount: 4,
              repsCount: 10,
              startWeight: 60,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'سحب عالي للظهر',
              muscleGroup: 'الظهر',
              setsCount: 4,
              repsCount: 10,
              startWeight: 55,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'ضغط أكتاف بالدمبل',
              muscleGroup: 'الأكتاف',
              setsCount: 3,
              repsCount: 12,
              startWeight: 18,
              restSeconds: 75,
            ),
          ],
        ),
        WorkoutDay(
          id: 'fb_2',
          title: 'اليوم 2: راحة واستشفاء نشط',
          subtitle: 'مشي 30 دقيقة + إطالات',
          targetMuscles: ['استشفاء'],
          isRestDay: true,
          exercises: [],
        ),
        WorkoutDay(
          id: 'fb_3',
          title: 'اليوم 3: جسم كامل B (ضخامة وتناسق)',
          subtitle: 'صدر علوي + تجديف + خلفيات أرجل + ذراعين',
          targetMuscles: ['الصدر', 'الظهر', 'الأرجل', 'البايسبس', 'الترايسبس'],
          exercises: [
            ExerciseItem.create(
              name: 'ديدليفت روماني بالدمبل أو البار',
              muscleGroup: 'الأرجل',
              setsCount: 4,
              repsCount: 10,
              startWeight: 65,
              restSeconds: 120,
            ),
            ExerciseItem.create(
              name: 'تجميع دمبل عالي للصدر',
              muscleGroup: 'الصدر',
              setsCount: 4,
              repsCount: 10,
              startWeight: 24,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'سحب أرضي ضيق للظهر',
              muscleGroup: 'الظهر',
              setsCount: 4,
              repsCount: 12,
              startWeight: 55,
              restSeconds: 90,
            ),
            ExerciseItem.create(
              name: 'بايسبس + ترايسبس سوبر ست',
              muscleGroup: 'البايسبس',
              setsCount: 3,
              repsCount: 12,
              startWeight: 20,
              restSeconds: 60,
            ),
          ],
        ),
      ],
    );
  }

  static WorkoutSystem _buildPhulSystem() {
    return WorkoutSystem(
      id: 'sys_phul',
      name: 'نظام القوة والضخامة (PHUL Power Hypertrophy)',
      category: 'Power & Hypertrophy',
      description:
          'يجمع بين أوزان القوة الثقيلة (Power) وأيام الضخامة العضلية (Hypertrophy) لكسر ثبات الأوزان.',
      daysPerWeek: 4,
      level: 'متقدم',
      days: [
        WorkoutDay(
          id: 'ph_1',
          title: 'اليوم 1: علوي قوة (Upper Power)',
          subtitle: 'أوزان ثقيلة وعدات من 5 إلى 8',
          targetMuscles: ['الصدر', 'الظهر', 'الأكتاف'],
          exercises: [
            ExerciseItem.create(
              name: 'بنش برس ثقيل بالبار',
              muscleGroup: 'الصدر',
              setsCount: 4,
              repsCount: 5,
              startWeight: 85,
              restSeconds: 150,
            ),
            ExerciseItem.create(
              name: 'تجديف بالبار ثقيل',
              muscleGroup: 'الظهر',
              setsCount: 4,
              repsCount: 6,
              startWeight: 75,
              restSeconds: 150,
            ),
            ExerciseItem.create(
              name: 'ضغط أكتاف بالبار واقف',
              muscleGroup: 'الأكتاف',
              setsCount: 3,
              repsCount: 6,
              startWeight: 50,
              restSeconds: 120,
            ),
          ],
        ),
        WorkoutDay(
          id: 'ph_2',
          title: 'اليوم 2: سفلي قوة (Lower Power)',
          subtitle: 'سكوات وديدليفت ثقيل لزيادة القوة العصبية',
          targetMuscles: ['الأرجل'],
          exercises: [
            ExerciseItem.create(
              name: 'سكوات بالبار ثقيل',
              muscleGroup: 'الأرجل',
              setsCount: 4,
              repsCount: 5,
              startWeight: 105,
              restSeconds: 180,
            ),
            ExerciseItem.create(
              name: 'ديدليفت تقليدي أو روماني',
              muscleGroup: 'الأرجل',
              setsCount: 4,
              repsCount: 5,
              startWeight: 110,
              restSeconds: 180,
            ),
          ],
        ),
      ],
    );
  }

  /// Intelligent Natural-Language Schedule Parser:
  /// Understands ANY schedule text in Arabic or English, detects days, muscles, sets, reps, weights, and rest!
  static WorkoutSystem parseAnyScheduleText(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) {
      return _buildPplSystem().cloneDeep();
    }

    final lower = trimmed.toLowerCase();

    // Quick intent shortcut: if the user wrote a short system request without detailed lines
    final lines = trimmed
        .split(RegExp(r"""[\r\n]+"""))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.length <= 2 && !trimmed.contains(':') && !trimmed.contains('-')) {
      if (lower.contains('ارنولد') || lower.contains('arnold')) {
        return _buildArnoldSplitSystem().cloneDeep();
      }
      if (lower.contains('علوي') || lower.contains('upper')) {
        return _buildUpperLowerSystem().cloneDeep();
      }
      if (lower.contains('شامل') ||
          lower.contains('كامل') ||
          lower.contains('full')) {
        return _buildFullBodySystem().cloneDeep();
      }
      if (lower.contains('عضلة كل يوم') || lower.contains('bro')) {
        return _buildBroSplitSystem().cloneDeep();
      }
      if (lower.contains('قوة') || lower.contains('phul')) {
        return _buildPhulSystem().cloneDeep();
      }
      if (lower.contains('دفع') ||
          lower.contains('سحب') ||
          lower.contains('ppl') ||
          lower.contains('push')) {
        return _buildPplSystem().cloneDeep();
      }
    }

    final List<WorkoutDay> parsedDays = [];
    WorkoutDay? currentDay;

    final dayHeaderRegex = RegExp(
      r"""^(السبت|الأحد|الاحد|الاثنين|الإثنين|الثلاثاء|الأربعاء|الاربعاء|الخميس|الجمعة|الجمعه|يوم\s*\d+|اليوم\s*الأول|اليوم\s*الاول|اليوم\s*الثاني|اليوم\s*الثالث|اليوم\s*الرابع|اليوم\s*الخامس|اليوم\s*السادس|اليوم\s*السابع|day\s*\d+|push|pull|legs|upper|lower|دفع|سحب|أرجل|ارجل)""",
      caseSensitive: false,
    );

    for (final line in lines) {
      final cleanLine = line.replaceAll(RegExp(r"""^[•\*\-\d\.\)\s]+"""), '').trim();
      if (cleanLine.isEmpty) continue;

      final isDayHeader = dayHeaderRegex.hasMatch(line) ||
          (line.contains(':') &&
              !RegExp(r"""\d+\s*[xX×\*في]\s*\d+""").hasMatch(line.split(':').first));

      if (isDayHeader) {
        final parts = line.split(':');
        final headerTitle = parts.first.trim();
        final remainder =
            parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

        final isRest = line.contains('راحة') ||
            line.contains('استشفاء') ||
            line.toLowerCase().contains('rest');

        final detectedMuscles = detectMusclesFromText(line);

        currentDay = WorkoutDay(
          id: 'parsed_day_${parsedDays.length + 1}_${DateTime.now().microsecondsSinceEpoch}',
          title: headerTitle.isEmpty
              ? 'اليوم ${parsedDays.length + 1}'
              : headerTitle,
          subtitle: isRest
              ? 'يوم راحة واستشفاء عضلي'
              : (detectedMuscles.isNotEmpty
                  ? 'العضلات المستهدفة: ${detectedMuscles.join(' + ')}'
                  : 'جدول ذكي مخصص'),
          targetMuscles:
              isRest ? ['استشفاء'] : (detectedMuscles.isEmpty ? ['عام'] : detectedMuscles),
          isRestDay: isRest,
          exercises: [],
        );
        parsedDays.add(currentDay);

        // Check if remainder after ':' already contains exercises separated by commas or dashes
        if (!isRest && remainder.isNotEmpty) {
          final subItems = remainder
              .split(RegExp(r"""[،,؛\-\+]"""))
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();

          for (final item in subItems) {
            // Skip pure muscle group names if there are actual exercises
            if (_isPureMuscleGroupLabel(item) && subItems.length > 1) {
              continue;
            }
            final ex = parseSingleExerciseLine(item, currentDay.targetMuscles);
            if (ex != null) {
              currentDay.exercises.add(ex);
            }
          }
        }
      } else {
        // It's an exercise line!
        currentDay ??= WorkoutDay(
          id: 'parsed_day_1_${DateTime.now().microsecondsSinceEpoch}',
          title: 'اليوم 1: تمرين مخصص ذكي',
          subtitle: 'تم تحليله بواسطة المحرك الذكي',
          targetMuscles: detectMusclesFromText(line),
          exercises: [],
        );
        if (!parsedDays.contains(currentDay)) {
          parsedDays.add(currentDay);
        }

        final subExercises = line
            .split(RegExp(r"""[،؛]"""))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        for (final sub in subExercises) {
          final ex = parseSingleExerciseLine(sub, currentDay.targetMuscles);
          if (ex != null) {
            currentDay.exercises.add(ex);
            if (!currentDay.targetMuscles.contains(ex.muscleGroup) &&
                ex.muscleGroup != 'عام') {
              currentDay.targetMuscles.add(ex.muscleGroup);
            }
          }
        }
      }
    }

    // Populate default smart exercises for any non-rest day that only listed muscle groups (e.g., "السبت: صدر وتراي")
    for (final day in parsedDays) {
      if (!day.isRestDay && day.exercises.isEmpty) {
        day.exercises.addAll(generateDefaultExercisesForMuscles(day.targetMuscles));
      }
      if (!day.isRestDay && day.targetMuscles.isNotEmpty) {
        day.subtitle = 'العضلات: ${day.targetMuscles.join(' • ')}';
      }
    }

    if (parsedDays.isEmpty) {
      return _buildPplSystem().cloneDeep();
    }

    final activeDaysCount = parsedDays.where((d) => !d.isRestDay).length;
    return WorkoutSystem(
      id: 'sys_custom_${DateTime.now().millisecondsSinceEpoch}',
      name: 'جدولك الذكي المخصص ($activeDaysCount أيام تمرين)',
      category: 'Smart AI Parsed',
      description:
          'تم فهم وتحليل هذا الجدول تلقائياً بواسطة المحرك الذكي وتوليد الجولات والأوزان ومؤقت الراحة.',
      daysPerWeek: activeDaysCount.clamp(1, 7),
      level: 'مخصص ذكي',
      days: parsedDays,
    );
  }

  static bool _isPureMuscleGroupLabel(String text) {
    final t = text.trim();
    const labels = {
      'صدر',
      'الصدر',
      'ظهر',
      'الظهر',
      'أكتاف',
      'اكتاف',
      'كتف',
      'باي',
      'بايسبس',
      'تراي',
      'ترايسبس',
      'ذراع',
      'أرجل',
      'ارجل',
      'رجل',
      'بطن',
      'دفع',
      'سحب',
      'علوي',
      'سفلي',
    };
    return labels.contains(t);
  }

  static ExerciseItem? parseSingleExerciseLine(
    String rawLine,
    List<String> fallbackMuscles,
  ) {
    var text = rawLine.trim();
    if (text.isEmpty) return null;

    int sets = 4;
    int reps = 10;
    double weight = 30.0;
    int rest = 90;

    // 1. Extract sets x reps like "4x10", "4 * 12", "4 × 10", "4 في 10"
    final setsRepsMatch =
        RegExp(r"""(\d+)\s*(?:[xX×\*]|في)\s*(\d+)""").firstMatch(text);
    if (setsRepsMatch != null) {
      sets = int.tryParse(setsRepsMatch.group(1) ?? '4') ?? 4;
      reps = int.tryParse(setsRepsMatch.group(2) ?? '10') ?? 10;
      text = text.replaceFirst(setsRepsMatch.group(0)!, ' ');
    } else {
      // Check "4 جولات 10 عدات" or "3 مجموعات"
      final setsWordMatch =
          RegExp(r"""(\d+)\s*(?:جولات|جولة|مجموعات|مجموعة|sets?)""", caseSensitive: false)
              .firstMatch(text);
      if (setsWordMatch != null) {
        sets = int.tryParse(setsWordMatch.group(1) ?? '4') ?? 4;
        text = text.replaceFirst(setsWordMatch.group(0)!, ' ');
      }
      final repsWordMatch =
          RegExp(r"""(\d+)\s*(?:عدات|عدة|تكرار|reps?)""", caseSensitive: false)
              .firstMatch(text);
      if (repsWordMatch != null) {
        reps = int.tryParse(repsWordMatch.group(1) ?? '10') ?? 10;
        text = text.replaceFirst(repsWordMatch.group(0)!, ' ');
      }
    }

    // 2. Extract weight like "80 كجم" or "80kg" or "وزن 60"
    final weightMatch = RegExp(
      r"""(?:وزن\s*(\d+(?:\.\d+)?)|(\d+(?:\.\d+)?)\s*(?:كجم|كيلو|kg))""",
      caseSensitive: false,
    ).firstMatch(text);
    if (weightMatch != null) {
      final wStr = weightMatch.group(1) ?? weightMatch.group(2) ?? '30';
      weight = double.tryParse(wStr) ?? 30.0;
      text = text.replaceFirst(weightMatch.group(0)!, ' ');
    }

    // 3. Extract rest seconds like "راحة 90" or "90 ثانية" or "90s"
    final restMatch = RegExp(
      r"""(?:راحة\s*(\d+)|(\d+)\s*(?:ثانية|ثواني|ث|sec|s\b))""",
      caseSensitive: false,
    ).firstMatch(text);
    if (restMatch != null) {
      final rStr = restMatch.group(1) ?? restMatch.group(2) ?? '90';
      rest = int.tryParse(rStr) ?? 90;
      text = text.replaceFirst(restMatch.group(0)!, ' ');
    }

    final cleanName = text
        .replaceAll(RegExp(r"""[\-\(\)\[\]:]+"""), ' ')
        .replaceAll(RegExp(r"""\s+"""), ' ')
        .trim();

    final finalName = cleanName.isEmpty ? rawLine.trim() : cleanName;
    final detectedMuscles = detectMusclesFromText(finalName);
    final muscle = detectedMuscles.isNotEmpty
        ? detectedMuscles.first
        : (fallbackMuscles.isNotEmpty ? fallbackMuscles.first : 'عام');

    return ExerciseItem.create(
      name: finalName,
      muscleGroup: muscle,
      setsCount: sets.clamp(1, 10),
      repsCount: reps.clamp(1, 50),
      startWeight: weight,
      restSeconds: rest.clamp(15, 300),
      notes: 'تم ضبط التمرين تلقائياً بواسطة المحلل الذكي',
    );
  }

  static List<String> detectMusclesFromText(String input) {
    final s = input.toLowerCase();
    final List<String> muscles = [];

    if (s.contains('صدر') ||
        s.contains('بنش') ||
        s.contains('تفتيح') ||
        s.contains('غطس') ||
        s.contains('chest') ||
        s.contains('bench') ||
        s.contains('push') ||
        s.contains('دفع')) {
      muscles.add('الصدر');
    }
    if (s.contains('ظهر') ||
        s.contains('سحب') ||
        s.contains('عقلة') ||
        s.contains('تجديف') ||
        s.contains('مجنص') ||
        s.contains('منشار') ||
        s.contains('back') ||
        s.contains('pull') ||
        s.contains('row') ||
        s.contains('lat')) {
      muscles.add('الظهر');
    }
    if (s.contains('كتف') ||
        s.contains('أكتاف') ||
        s.contains('اكتاف') ||
        s.contains('رفرفة') ||
        s.contains('ترابيس') ||
        s.contains('عسكري') ||
        s.contains('shoulder') ||
        s.contains('push') ||
        s.contains('دفع')) {
      if (!muscles.contains('الأكتاف')) muscles.add('الأكتاف');
    }
    if (s.contains('باي') ||
        s.contains('تبادل') ||
        s.contains('هامر') ||
        s.contains('ذراع') ||
        s.contains('bicep') ||
        s.contains('curl') ||
        s.contains('سحب')) {
      if (!muscles.contains('البايسبس')) muscles.add('البايسبس');
    }
    if (s.contains('تراي') ||
        s.contains('فرنساوي') ||
        s.contains('حبل') ||
        s.contains('ذراع') ||
        s.contains('tricep') ||
        s.contains('دفع')) {
      if (!muscles.contains('الترايسبس')) muscles.add('الترايسبس');
    }
    if (s.contains('رجل') ||
        s.contains('أرجل') ||
        s.contains('ارجل') ||
        s.contains('سكوات') ||
        s.contains('دفش') ||
        s.contains('طعن') ||
        s.contains('سمانة') ||
        s.contains('ديدليفت') ||
        s.contains('سفلي') ||
        s.contains('leg') ||
        s.contains('squat')) {
      muscles.add('الأرجل');
    }
    if (s.contains('بطن') ||
        s.contains('كور') ||
        s.contains('بلانك') ||
        s.contains('abs') ||
        s.contains('core')) {
      muscles.add('البطن');
    }
    return muscles;
  }

  static List<ExerciseItem> generateDefaultExercisesForMuscles(
    List<String> muscles,
  ) {
    final List<ExerciseItem> list = [];
    for (final m in muscles) {
      if (m == 'الصدر') {
        list.addAll([
          ExerciseItem.create(
            name: 'بنش برس مستوي بالبار',
            muscleGroup: 'الصدر',
            setsCount: 4,
            repsCount: 10,
            startWeight: 65,
            restSeconds: 90,
          ),
          ExerciseItem.create(
            name: 'تجميع دمبل عالي',
            muscleGroup: 'الصدر',
            setsCount: 4,
            repsCount: 10,
            startWeight: 26,
            restSeconds: 90,
          ),
          ExerciseItem.create(
            name: 'تفتيح كابل للصدر',
            muscleGroup: 'الصدر',
            setsCount: 3,
            repsCount: 12,
            startWeight: 15,
            restSeconds: 60,
          ),
        ]);
      } else if (m == 'الظهر') {
        list.addAll([
          ExerciseItem.create(
            name: 'سحب عالي أمامي واسع',
            muscleGroup: 'الظهر',
            setsCount: 4,
            repsCount: 10,
            startWeight: 60,
            restSeconds: 90,
          ),
          ExerciseItem.create(
            name: 'تجديف بالبار منحني',
            muscleGroup: 'الظهر',
            setsCount: 4,
            repsCount: 10,
            startWeight: 55,
            restSeconds: 90,
          ),
          ExerciseItem.create(
            name: 'سحب أرضي ضيق',
            muscleGroup: 'الظهر',
            setsCount: 3,
            repsCount: 12,
            startWeight: 50,
            restSeconds: 75,
          ),
        ]);
      } else if (m == 'الأكتاف') {
        list.addAll([
          ExerciseItem.create(
            name: 'ضغط أكتاف بالدمبل',
            muscleGroup: 'الأكتاف',
            setsCount: 4,
            repsCount: 10,
            startWeight: 22,
            restSeconds: 90,
          ),
          ExerciseItem.create(
            name: 'رفرفة جانبي بالدمبل',
            muscleGroup: 'الأكتاف',
            setsCount: 4,
            repsCount: 15,
            startWeight: 12,
            restSeconds: 60,
          ),
        ]);
      } else if (m == 'البايسبس') {
        list.addAll([
          ExerciseItem.create(
            name: 'تبادل بايسبس بالبار الزجزاج',
            muscleGroup: 'البايسبس',
            setsCount: 4,
            repsCount: 10,
            startWeight: 30,
            restSeconds: 60,
          ),
          ExerciseItem.create(
            name: 'هامر كيرل بالدمبل',
            muscleGroup: 'البايسبس',
            setsCount: 3,
            repsCount: 12,
            startWeight: 14,
            restSeconds: 60,
          ),
        ]);
      } else if (m == 'الترايسبس') {
        list.addAll([
          ExerciseItem.create(
            name: 'دفع حبل ترايسبس على الكابل',
            muscleGroup: 'الترايسبس',
            setsCount: 4,
            repsCount: 12,
            startWeight: 25,
            restSeconds: 60,
          ),
          ExerciseItem.create(
            name: 'فرنساوي بالبار الزجزاج',
            muscleGroup: 'الترايسبس',
            setsCount: 3,
            repsCount: 10,
            startWeight: 28,
            restSeconds: 60,
          ),
        ]);
      } else if (m == 'الأرجل') {
        list.addAll([
          ExerciseItem.create(
            name: 'سكوات بالبار',
            muscleGroup: 'الأرجل',
            setsCount: 4,
            repsCount: 8,
            startWeight: 85,
            restSeconds: 120,
          ),
          ExerciseItem.create(
            name: 'دفش أرجل على الجهاز',
            muscleGroup: 'الأرجل',
            setsCount: 4,
            repsCount: 12,
            startWeight: 150,
            restSeconds: 90,
          ),
          ExerciseItem.create(
            name: 'رفرفة خلفي + سمانة',
            muscleGroup: 'الأرجل',
            setsCount: 4,
            repsCount: 12,
            startWeight: 45,
            restSeconds: 60,
          ),
        ]);
      } else if (m == 'البطن') {
        list.add(
          ExerciseItem.create(
            name: 'طحن بطن بالكابل + بلانك',
            muscleGroup: 'البطن',
            setsCount: 4,
            repsCount: 15,
            startWeight: 25,
            restSeconds: 45,
          ),
        );
      }
    }
    if (list.isEmpty) {
      list.add(
        ExerciseItem.create(
          name: 'تمرين مركب شامل',
          muscleGroup: 'عام',
          setsCount: 4,
          repsCount: 10,
          startWeight: 40,
          restSeconds: 90,
        ),
      );
    }
    return list;
  }

  /// Smart Wizard Recommender based on user's goal, days per week, and level
  static WorkoutSystem recommendSmartSystem({
    required String goal,
    required int daysPerWeek,
    required String level,
  }) {
    WorkoutSystem base;
    if (daysPerWeek <= 3) {
      base = _buildFullBodySystem().cloneDeep();
    } else if (daysPerWeek == 4) {
      base = goal.contains('قوة')
          ? _buildPhulSystem().cloneDeep()
          : _buildUpperLowerSystem().cloneDeep();
    } else if (daysPerWeek == 5) {
      base = _buildBroSplitSystem().cloneDeep();
    } else {
      base = level.contains('متقدم')
          ? _buildArnoldSplitSystem().cloneDeep()
          : _buildPplSystem().cloneDeep();
    }

    // Calibrate sets, reps, and rest times according to the user's goal
    for (final day in base.days) {
      for (final ex in day.exercises) {
        if (goal.contains('قوة')) {
          ex.restSeconds = 150;
          for (final s in ex.sets) {
            s.targetReps = 6;
            s.actualReps = 6;
          }
        } else if (goal.contains('تنشيف')) {
          ex.restSeconds = 60;
          for (final s in ex.sets) {
            s.targetReps = 14;
            s.actualReps = 14;
          }
        } else {
          // Hypertrophy (تضخيم عضلي)
          ex.restSeconds = 90;
          for (final s in ex.sets) {
            s.targetReps = 10;
            s.actualReps = 10;
          }
        }
      }
    }

    base.name = '${base.name} — مخصص لهدف ($goal)';
    base.level = level;
    base.daysPerWeek = daysPerWeek;
    return base;
  }
}

// ============================================================================
// 6. ROOT APPLICATION WIDGET (RTL & iOS THEME)
// ============================================================================

class JooFitIosApp extends StatelessWidget {
  const JooFitIosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JOOFIT PRO iOS',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [
        Locale('ar', 'EG'),
        Locale('ar'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: IosPalette.bgPrimary,
        cupertinoOverrideTheme: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: IosPalette.iosBlue,
          scaffoldBackgroundColor: IosPalette.bgPrimary,
          barBackgroundColor: Color(0xCC161922),
        ),
        colorScheme: const ColorScheme.dark(
          primary: IosPalette.iosBlue,
          secondary: IosPalette.iosGreen,
          surface: IosPalette.cardSurface,
          error: IosPalette.iosRed,
          onPrimary: Colors.white,
          onSurface: IosPalette.textPrimary,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const JooFitMainShell(),
    );
  }
}

// ============================================================================
// 7. REUSABLE iOS CUPERTINO INTERACTIVE WIDGETS
// ============================================================================

/// Native iOS-style button that scales down smoothly and fades slightly on press
class IosPressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool fullWidth;

  const IosPressableButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = 14,
    this.fullWidth = false,
  });

  @override
  State<IosPressableButton> createState() => _IosPressableButtonState();
}

class _IosPressableButtonState extends State<IosPressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onPressed == null
          ? null
          : () => setState(() => _pressed = false),
      onTap: widget.onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onPressed!();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.80 : 1.0,
          duration: const Duration(milliseconds: 110),
          child: Container(
            width: widget.fullWidth ? double.infinity : null,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.color ?? IosPalette.iosBlue,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.borderColor != null
                  ? Border.all(color: widget.borderColor!, width: 1)
                  : null,
            ),
            child: Center(
              widthFactor: widget.fullWidth ? null : 1.0,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// iOS Frosted Glass Container
class IosGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? tintColor;
  final Color? borderColor;

  const IosGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 20,
    this.tintColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: tintColor ?? IosPalette.cardSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? IosPalette.separator.withOpacity(0.65),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Apple Fitness 3-Concentric Activity Rings Painter
class AppleActivityRingsPainter extends CustomPainter {
  final double outerProgress; // Workout sets progress (Green)
  final double middleProgress; // Volume / Calories progress (Blue)
  final double innerProgress; // Hydration / Recovery progress (Orange/Teal)
  final Color accentColor;

  AppleActivityRingsPainter({
    required this.outerProgress,
    required this.middleProgress,
    required this.innerProgress,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 10.5;
    const gap = 3.5;

    final r1 = (math.min(size.width, size.height) / 2) - (strokeWidth / 2);
    final r2 = r1 - strokeWidth - gap;
    final r3 = r2 - strokeWidth - gap;

    _drawRing(
      canvas,
      center,
      r1,
      strokeWidth,
      outerProgress.clamp(0.02, 1.0),
      IosPalette.iosGreen,
    );
    _drawRing(
      canvas,
      center,
      r2,
      strokeWidth,
      middleProgress.clamp(0.02, 1.0),
      accentColor,
    );
    _drawRing(
      canvas,
      center,
      r3,
      strokeWidth,
      innerProgress.clamp(0.02, 1.0),
      IosPalette.iosTeal,
    );
  }

  void _drawRing(
    Canvas canvas,
    Offset center,
    double radius,
    double strokeWidth,
    double progress,
    Color color,
  ) {
    final bgPaint = Paint()
      ..color = color.withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant AppleActivityRingsPainter oldDelegate) {
    return oldDelegate.outerProgress != outerProgress ||
        oldDelegate.middleProgress != middleProgress ||
        oldDelegate.innerProgress != innerProgress ||
        oldDelegate.accentColor != accentColor;
  }
}

/// Apple Watch / iOS Clock Circular Timer Ring Painter
class IosCircularTimerPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final bool isRunning;

  IosCircularTimerPainter({
    required this.progress,
    required this.activeColor,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 14;

    // Draw subtle iOS Watch tick marks around the perimeter
    final tickPaint = Paint()
      ..color = IosPalette.separator.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * (math.pi / 180);
      final isMajor = i % 5 == 0;
      final innerTick = radius - (isMajor ? 18 : 14);
      final outerTick = radius - 10;
      tickPaint.color = isMajor
          ? IosPalette.textMuted.withOpacity(0.55)
          : IosPalette.separator.withOpacity(0.35);
      canvas.drawLine(
        Offset(
          center.dx + innerTick * math.cos(angle),
          center.dy + innerTick * math.sin(angle),
        ),
        Offset(
          center.dx + outerTick * math.cos(angle),
          center.dy + outerTick * math.sin(angle),
        ),
        tickPaint,
      );
    }

    // Track ring
    final trackPaint = Paint()
      ..color = activeColor.withOpacity(0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11;
    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    final arcPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // Knob indicator at tip of arc
    final endAngle = startAngle + sweepAngle;
    final knobCenter = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );
    final knobPaint = Paint()..color = Colors.white;
    canvas.drawCircle(knobCenter, 4.5, knobPaint);
  }

  @override
  bool shouldRepaint(covariant IosCircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.isRunning != isRunning;
  }
}

// ============================================================================
// 8. MAIN SHELL: STATE MANAGEMENT, TIMERS, & iOS GLASS BOTTOM BAR
// ============================================================================

class JooFitMainShell extends StatefulWidget {
  const JooFitMainShell({super.key});

  @override
  State<JooFitMainShell> createState() => _JooFitMainShellState();
}

class _JooFitMainShellState extends State<JooFitMainShell>
    with WidgetsBindingObserver {
  static const String _storageKeyV2 = 'joofit_ios_pro_state_v2';
  static const String _legacyTasksKey = 'klencod_tasks_v1';

  int _currentTabIndex = 0;
  bool _isLoading = true;
  int _accentIndex = 0;

  // Smart Workout System State
  late WorkoutSystem _activeSystem;
  int _activeDayIndex = 0;
  bool _isWorkoutSessionActive = false;
  DateTime? _workoutSessionStart;
  int _workoutElapsedSeconds = 0;

  // Multi-Mode Pro Timer State
  int _timerMode = 0; // 0: Rest Timer, 1: Tabata HIIT, 2: Stopwatch
  // Mode 0: Rest Timer
  int _restTotalSeconds = 90;
  int _restRemainingSeconds = 90;
  bool _restRunning = false;
  bool _autoStartRestOnSet = true;
  String _restCurrentExerciseName = 'استعداد للجولة القادمة';
  DateTime? _restTargetEndTime;

  // Mode 1: Tabata / HIIT Timer
  int _tabataWorkSec = 40;
  int _tabataRestSec = 20;
  int _tabataTotalRounds = 8;
  int _tabataCurrentRound = 1;
  bool _tabataIsWorkPhase = true;
  int _tabataRemainingSec = 40;
  bool _tabataRunning = false;

  // Mode 2: Stopwatch
  int _stopwatchDeciSeconds = 0;
  bool _stopwatchRunning = false;
  final List<int> _stopwatchLaps = [];

  Timer? _masterTicker;

  // Hydration, Nutrition, Recovery & History
  int _waterCupsToday = 4;
  int _waterGoalCups = 10;
  int _proteinGramsToday = 95;
  int _proteinGoalGrams = 160;
  bool _creatineTakenToday = false;

  final List<WorkoutLog> _workoutLogs = [];
  final List<GymTaskItem> _gymTasks = [];
  final List<SmartReminder> _smartReminders = [];
  final Map<String, DateTime> _muscleLastTrained = {};

  // In-app iOS Smart Notification Banner
  String? _bannerTitle;
  String? _bannerSubtitle;
  IconData _bannerIcon = CupertinoIcons.bell_fill;
  Color _bannerColor = IosPalette.iosBlue;
  Timer? _bannerDismissTimer;

  // Smart Parser Controllers
  final TextEditingController _smartParserController = TextEditingController();
  WorkoutSystem? _previewParsedSystem;

  // 1RM Calculator State
  double _calcWeightKg = 80.0;
  int _calcReps = 8;

  // Sub-tabs
  int _smartSystemSubTab = 0; // 0: AI Parser, 1: Built-in Systems, 2: Smart Wizard
  int _exercisesSubTab = 0; // 0: Library, 1: 1RM Calculator, 2: Recovery & History
  String _selectedMuscleFilter = 'الكل';
  String _exerciseSearchQuery = '';

  // Smart Wizard State
  String _wizardGoal = 'تضخيم عضلي';
  int _wizardDays = 5;
  String _wizardLevel = 'متوسط - متقدم';

  Color get _accent =>
      IosPalette.accentPresets[_accentIndex % IosPalette.accentPresets.length];

  WorkoutDay get _currentWorkoutDay {
    if (_activeSystem.days.isEmpty) {
      _activeSystem = SmartScheduleEngine.getBuiltInSystems().first;
    }
    final safeIdx = _activeDayIndex.clamp(0, _activeSystem.days.length - 1);
    return _activeSystem.days[safeIdx];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activeSystem = SmartScheduleEngine.getBuiltInSystems().first;
    _initDefaultReminders();
    _loadAppState();
    _startMasterTicker();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _masterTicker?.cancel();
    _bannerDismissTimer?.cancel();
    _smartParserController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-sync timestamp-based rest timer when returning from background
    if (state == AppLifecycleState.resumed) {
      if (_restRunning && _restTargetEndTime != null) {
        final diff = _restTargetEndTime!.difference(DateTime.now()).inSeconds;
        if (diff <= 0) {
          _onRestTimerComplete();
        } else {
          setState(() => _restRemainingSeconds = diff);
        }
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveAppState();
    }
  }

  void _initDefaultReminders() {
    _smartReminders.addAll([
      SmartReminder(
        id: 'rem_workout',
        title: 'تنبيه موعد التمرين الذكي',
        subtitle: 'يذكرك باسم تمرين اليوم والعضلات المستهدفة في جدولك',
        timeLabel: '17:30',
        enabled: true,
        category: 'workout',
      ),
      SmartReminder(
        id: 'rem_rest_timer',
        title: 'تنبيه انتهاء الراحة بين الجولات',
        subtitle: 'إشعار فوري واهتزاز عند انتهاء العد التنازلي للراحة',
        timeLabel: 'تلقائي',
        enabled: true,
        category: 'timer',
      ),
      SmartReminder(
        id: 'rem_water',
        title: 'تنبيه شرب الماء والترطيب',
        subtitle: 'تذكير ذكي كل ساعتين للحفاظ على الأداء العضلي',
        timeLabel: 'كل ساعتين',
        enabled: true,
        category: 'hydration',
      ),
      SmartReminder(
        id: 'rem_creatine',
        title: 'تنبيه الكرياتين والمكملات (5 جرام)',
        subtitle: 'تذكير يومي بجرعة الكرياتين والـ Pre-Workout',
        timeLabel: '16:45',
        enabled: true,
        category: 'supplement',
      ),
      SmartReminder(
        id: 'rem_protein',
        title: 'تنبيه وجبة ما بعد التمرين والبروتين',
        subtitle: 'لتعزيز الاستشفاء والبناء العضلي بعد الجيم',
        timeLabel: '20:00',
        enabled: true,
        category: 'nutrition',
      ),
      SmartReminder(
        id: 'rem_sleep',
        title: 'تنبيه الاستشفاء والنوم العميق',
        subtitle: 'النوم 8 ساعات أساسي لنمو الألياف العضلية',
        timeLabel: '23:30',
        enabled: true,
        category: 'recovery',
      ),
    ]);
  }

  Future<void> _loadAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Migrate any legacy tasks from v1 so user loses nothing
      final legacyData = prefs.getString(_legacyTasksKey);
      if (legacyData != null && legacyData.isNotEmpty) {
        try {
          final list = jsonDecode(legacyData) as List<dynamic>;
          for (final item in list) {
            if (item is Map) {
              _gymTasks.add(
                GymTaskItem.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
        } catch (_) {}
      }

      final rawState = prefs.getString(_storageKeyV2);
      if (rawState != null && rawState.isNotEmpty) {
        final map = jsonDecode(rawState) as Map<String, dynamic>;
        _accentIndex = (map['accentIndex'] as num?)?.toInt() ?? 0;
        _activeDayIndex = (map['activeDayIndex'] as num?)?.toInt() ?? 0;
        _restTotalSeconds = (map['restTotalSeconds'] as num?)?.toInt() ?? 90;
        _restRemainingSeconds = _restTotalSeconds;
        _autoStartRestOnSet = map['autoStartRestOnSet'] as bool? ?? true;
        _waterCupsToday = (map['waterCupsToday'] as num?)?.toInt() ?? 4;
        _waterGoalCups = (map['waterGoalCups'] as num?)?.toInt() ?? 10;
        _proteinGramsToday = (map['proteinGramsToday'] as num?)?.toInt() ?? 95;
        _proteinGoalGrams = (map['proteinGoalGrams'] as num?)?.toInt() ?? 160;
        _creatineTakenToday = map['creatineTakenToday'] as bool? ?? false;

        if (map['activeSystem'] is Map) {
          _activeSystem = WorkoutSystem.fromJson(
            Map<String, dynamic>.from(map['activeSystem'] as Map),
          );
        }

        if (map['workoutLogs'] is List) {
          _workoutLogs.clear();
          for (final l in (map['workoutLogs'] as List)) {
            if (l is Map) {
              _workoutLogs.add(
                WorkoutLog.fromJson(Map<String, dynamic>.from(l)),
              );
            }
          }
        }

        if (map['gymTasks'] is List) {
          _gymTasks.clear();
          for (final t in (map['gymTasks'] as List)) {
            if (t is Map) {
              _gymTasks.add(
                GymTaskItem.fromJson(Map<String, dynamic>.from(t)),
              );
            }
          }
        }

        if (map['smartReminders'] is List) {
          final loadedRems = (map['smartReminders'] as List)
              .whereType<Map>()
              .map((r) => SmartReminder.fromJson(Map<String, dynamic>.from(r)))
              .toList();
          if (loadedRems.isNotEmpty) {
            _smartReminders
              ..clear()
              ..addAll(loadedRems);
          }
        }

        if (map['muscleLastTrained'] is Map) {
          final mMap = Map<String, dynamic>.from(map['muscleLastTrained'] as Map);
          mMap.forEach((k, v) {
            final dt = DateTime.tryParse(v.toString());
            if (dt != null) _muscleLastTrained[k] = dt;
          });
        }
      }

      if (_gymTasks.isEmpty) {
        _gymTasks.addAll([
          GymTaskItem(
            id: 'default_t1',
            title: 'إحماء المفاصل والكتف لمدة 5 دقائق قبل الأوزان',
            done: true,
            createdAt: DateTime.now(),
          ),
          GymTaskItem(
            id: 'default_t2',
            title: 'تسجيل أوزان وعدات تمرين اليوم بالكامل',
            done: false,
            createdAt: DateTime.now(),
          ),
          GymTaskItem(
            id: 'default_t3',
            title: 'أخذ جرعة الكرياتين (5 جرام) وشرب 3 لتر ماء',
            done: false,
            createdAt: DateTime.now(),
          ),
        ]);
      }
    } catch (e) {
      debugPrint('Safe state load fallback: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = {
        'accentIndex': _accentIndex,
        'activeDayIndex': _activeDayIndex,
        'restTotalSeconds': _restTotalSeconds,
        'autoStartRestOnSet': _autoStartRestOnSet,
        'waterCupsToday': _waterCupsToday,
        'waterGoalCups': _waterGoalCups,
        'proteinGramsToday': _proteinGramsToday,
        'proteinGoalGrams': _proteinGoalGrams,
        'creatineTakenToday': _creatineTakenToday,
        'activeSystem': _activeSystem.toJson(),
        'workoutLogs': _workoutLogs.map((l) => l.toJson()).toList(),
        'gymTasks': _gymTasks.map((t) => t.toJson()).toList(),
        'smartReminders': _smartReminders.map((r) => r.toJson()).toList(),
        'muscleLastTrained': _muscleLastTrained.map(
          (k, v) => MapEntry(k, v.toIso8601String()),
        ),
      };
      await prefs.setString(_storageKeyV2, jsonEncode(map));
    } catch (e) {
      debugPrint('Safe state save fallback: $e');
    }
  }

  void _startMasterTicker() {
    _masterTicker?.cancel();
    _masterTicker = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      bool needsRebuild = false;

      // 1. Stopwatch (100ms precision)
      if (_stopwatchRunning) {
        _stopwatchDeciSeconds++;
        needsRebuild = true;
      }

      // Tick once per full second (every 10 ticks)
      if (timer.tick % 10 == 0) {
        // 2. Active Workout Session Timer
        if (_isWorkoutSessionActive && _workoutSessionStart != null) {
          _workoutElapsedSeconds =
              DateTime.now().difference(_workoutSessionStart!).inSeconds;
          needsRebuild = true;
        }

        // 3. Smart Rest Timer
        if (_restRunning) {
          if (_restTargetEndTime != null) {
            final remaining =
                _restTargetEndTime!.difference(DateTime.now()).inSeconds;
            if (remaining <= 0) {
              _onRestTimerComplete();
            } else {
              _restRemainingSeconds = remaining;
            }
          } else {
            if (_restRemainingSeconds > 0) {
              _restRemainingSeconds--;
            } else {
              _onRestTimerComplete();
            }
          }
          needsRebuild = true;
        }

        // 4. Tabata / HIIT Interval Timer
        if (_tabataRunning) {
          if (_tabataRemainingSec > 1) {
            _tabataRemainingSec--;
          } else {
            HapticFeedback.heavyImpact();
            if (_tabataIsWorkPhase) {
              _tabataIsWorkPhase = false;
              _tabataRemainingSec = _tabataRestSec;
              _showIosBanner(
                title: 'وقت الراحة (Tabata)',
                subtitle: 'تنفس بعمق لمدة $_tabataRestSec ثانية قبل الجولة التالية',
                icon: CupertinoIcons.flame_fill,
                color: IosPalette.iosOrange,
              );
            } else {
              if (_tabataCurrentRound < _tabataTotalRounds) {
                _tabataCurrentRound++;
                _tabataIsWorkPhase = true;
                _tabataRemainingSec = _tabataWorkSec;
                _showIosBanner(
                  title: 'انطلق! الجولة $_tabataCurrentRound من $_tabataTotalRounds',
                  subtitle: 'أقصى مجهود لمدة $_tabataWorkSec ثانية 💪',
                  icon: CupertinoIcons.bolt_fill,
                  color: IosPalette.iosGreen,
                );
              } else {
                _tabataRunning = false;
                _tabataCurrentRound = 1;
                _tabataIsWorkPhase = true;
                _tabataRemainingSec = _tabataWorkSec;
                SmartNotificationService.instance.showSmartNotification(
                  id: 202,
                  title: 'اكتمل تمرين التاباتا بنجاح! 🔥',
                  body: 'أنهيت $_tabataTotalRounds جولات كاملة بأداء بطولي.',
                );
                _showIosBanner(
                  title: 'اكتمل تمرين التاباتا HIIT!',
                  subtitle: 'أنهيت جميع الجولات بنجاح، أحسنت يا بطل!',
                  icon: CupertinoIcons.checkmark_seal_fill,
                  color: IosPalette.iosGreen,
                );
              }
            }
          }
          needsRebuild = true;
        }
      }

      if (needsRebuild && mounted) {
        setState(() {});
      }
    });
  }

  void _startRestTimer(int seconds, {String? exerciseName}) {
    final safeSec = seconds.clamp(10, 600);
    setState(() {
      _restTotalSeconds = safeSec;
      _restRemainingSeconds = safeSec;
      _restRunning = true;
      _restTargetEndTime = DateTime.now().add(Duration(seconds: safeSec));
      if (exerciseName != null && exerciseName.isNotEmpty) {
        _restCurrentExerciseName = exerciseName;
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _adjustRestTimer(int deltaSeconds) {
    setState(() {
      _restRemainingSeconds = (_restRemainingSeconds + deltaSeconds).clamp(5, 600);
      if (_restRemainingSeconds > _restTotalSeconds) {
        _restTotalSeconds = _restRemainingSeconds;
      }
      if (_restRunning) {
        _restTargetEndTime =
            DateTime.now().add(Duration(seconds: _restRemainingSeconds));
      }
    });
    HapticFeedback.selectionClick();
  }

  void _onRestTimerComplete() {
    setState(() {
      _restRunning = false;
      _restRemainingSeconds = _restTotalSeconds;
      _restTargetEndTime = null;
    });
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);

    final restRem = _smartReminders
        .where((r) => r.id == 'rem_rest_timer')
        .firstOrNull;
    if (restRem == null || restRem.enabled) {
      SmartNotificationService.instance.showSmartNotification(
        id: 101,
        title: 'انتهى وقت الراحة! ⏱️💪',
        body: 'حان وقت الجولة التالية في: $_restCurrentExerciseName',
      );
    }

    _showIosBanner(
      title: 'انتهى وقت الراحة! استعد للجولة التالية',
      subtitle: _restCurrentExerciseName,
      icon: CupertinoIcons.timer_fill,
      color: IosPalette.iosGreen,
    );
  }

  void _showIosBanner({
    required String title,
    required String subtitle,
    IconData icon = CupertinoIcons.bell_fill,
    Color color = IosPalette.iosBlue,
  }) {
    _bannerDismissTimer?.cancel();
    setState(() {
      _bannerTitle = title;
      _bannerSubtitle = subtitle;
      _bannerIcon = icon;
      _bannerColor = color;
    });
    _bannerDismissTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _bannerTitle = null);
      }
    });
  }

  void _onToggleSetCompleted(ExerciseItem exercise, SetEntry setEntry) {
    setState(() {
      setEntry.completed = !setEntry.completed;
      if (!_isWorkoutSessionActive && setEntry.completed) {
        _isWorkoutSessionActive = true;
        _workoutSessionStart = DateTime.now();
      }
    });
    _saveAppState();

    if (setEntry.completed) {
      HapticFeedback.mediumImpact();
      if (_autoStartRestOnSet) {
        _startRestTimer(
          exercise.restSeconds,
          exerciseName: '${exercise.name} (جولة ${setEntry.setNumber})',
        );
        _showIosBanner(
          title: 'تم تسجيل الجولة ${setEntry.setNumber} بنجاح ✓',
          subtitle: 'بدأ مؤقت الراحة الذكي (${exercise.restSeconds} ثانية) تلقائياً',
          icon: CupertinoIcons.timer,
          color: _accent,
        );
      }
    } else {
      HapticFeedback.selectionClick();
    }
  }

  void _finishTodayWorkout() {
    final day = _currentWorkoutDay;
    final completedSets = day.completedSets;
    final volume = day.totalVolumeKg;
    final durationMin = _isWorkoutSessionActive
        ? (_workoutElapsedSeconds ~/ 60).clamp(15, 180)
        : 45;

    final now = DateTime.now();
    for (final m in day.targetMuscles) {
      _muscleLastTrained[m] = now;
    }

    final log = WorkoutLog(
      id: 'log_${now.millisecondsSinceEpoch}',
      dayTitle: day.title,
      systemName: _activeSystem.name,
      completedAt: now,
      totalSets: completedSets > 0 ? completedSets : day.totalSets,
      totalVolumeKg: volume > 0 ? volume : 3200.0,
      durationMinutes: durationMin,
      trainedMuscles: List<String>.from(day.targetMuscles),
    );

    setState(() {
      _workoutLogs.insert(0, log);
      _isWorkoutSessionActive = false;
      _workoutSessionStart = null;
      _workoutElapsedSeconds = 0;
      _restRunning = false;

      // Reset sets for next cycle and advance to next day in split
      for (final ex in day.exercises) {
        for (final s in ex.sets) {
          s.completed = false;
        }
      }
      _activeDayIndex = (_activeDayIndex + 1) % _activeSystem.days.length;
    });

    _saveAppState();
    SmartNotificationService.instance.showSmartNotification(
      id: 303,
      title: 'وحش الجيم! اكتمل تمرين اليوم 🏆',
      body:
          'أنهيت ${log.dayTitle} بحجم تدريبي ${log.totalVolumeKg.toStringAsFixed(0)} كجم. تم الانتقال لليوم التالي في جدولك الذكي!',
    );

    _showIosBanner(
      title: 'تم حفظ التمرين والانتقال لليوم التالي 🏆',
      subtitle: 'الحجم التدريبي المسجل: ${log.totalVolumeKg.toStringAsFixed(0)} كجم',
      icon: CupertinoIcons.rosette,
      color: IosPalette.iosGreen,
    );
  }

  double _getMuscleRecoveryPercent(String muscle) {
    final last = _muscleLastTrained[muscle];
    if (last == null) return 1.0;
    final hours = DateTime.now().difference(last).inHours;
    // Full recovery in 48 hours
    return (hours / 48.0).clamp(0.15, 1.0);
  }

  String _formatSeconds(int totalSec) {
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: IosPalette.bgPrimary,
        body: Center(
          child: CupertinoActivityIndicator(
            radius: 16,
            color: IosPalette.iosBlue,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: IosPalette.bgPrimary,
      extendBody: true,
      body: Stack(
        children: [
          // Active Screen Content
          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentTabIndex,
              children: [
                _buildDashboardTab(),
                _buildSmartScheduleTab(),
                _buildTimerTab(),
                _buildExercisesAndStatsTab(),
                _buildSmartAlertsAndSettingsTab(),
              ],
            ),
          ),

          // iOS Top Floating Notification Banner (Dynamic Island Alert)
          if (_bannerTitle != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 14,
              right: 14,
              child: _buildTopIosBanner(),
            ),

          // Floating Mini-Timer Bar above Bottom Nav when Rest or Tabata is running
          if ((_restRunning || _tabataRunning) && _currentTabIndex != 2)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 78,
              child: _buildFloatingDynamicTimerBar(),
            ),
        ],
      ),
      bottomNavigationBar: _buildIosFrostedBottomBar(),
    );
  }

  Widget _buildTopIosBanner() {
    return GestureDetector(
      onTap: () => setState(() => _bannerTitle = null),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xE61C1F2A),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _bannerColor.withOpacity(0.55), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _bannerColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_bannerIcon, color: _bannerColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _bannerTitle ?? '',
                        style: const TextStyle(
                          color: IosPalette.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_bannerSubtitle != null &&
                          _bannerSubtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _bannerSubtitle!,
                          style: const TextStyle(
                            color: IosPalette.textSecondary,
                            fontSize: 11.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: IosPalette.textMuted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingDynamicTimerBar() {
    final isRest = _restRunning;
    final remaining = isRest ? _restRemainingSeconds : _tabataRemainingSec;
    final total = isRest
        ? _restTotalSeconds
        : (_tabataIsWorkPhase ? _tabataWorkSec : _tabataRestSec);
    final progress = total == 0 ? 0.0 : remaining / total;
    final activeColor = isRest
        ? _accent
        : (_tabataIsWorkPhase ? IosPalette.iosGreen : IosPalette.iosOrange);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentTabIndex = 2);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xEB181B26),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: activeColor.withOpacity(0.6), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x80000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  height: 34,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 3.5,
                        backgroundColor: activeColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                      ),
                      Icon(
                        CupertinoIcons.timer,
                        color: activeColor,
                        size: 15,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isRest
                            ? 'مؤقت الراحة الذكي نشط'
                            : (_tabataIsWorkPhase
                                ? 'تاباتا: جولة تمرين ($_tabataCurrentRound/$_tabataTotalRounds)'
                                : 'تاباتا: استراحة'),
                        style: const TextStyle(
                          color: IosPalette.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isRest ? _restCurrentExerciseName : 'اضغط لفتح شاشة المؤقت',
                        style: const TextStyle(
                          color: IosPalette.textMuted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isRest)
                  IosPressableButton(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 12,
                    color: IosPalette.cardElevated,
                    onPressed: () => _adjustRestTimer(15),
                    child: const Text(
                      '+15ث',
                      style: TextStyle(
                        color: IosPalette.textPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: activeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _formatSeconds(remaining),
                    style: TextStyle(
                      color: activeColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Authentic iOS Frosted Glass Bottom Navigation Bar with Pill Indicators
  Widget _buildIosFrostedBottomBar() {
    final items = [
      (icon: CupertinoIcons.flame_fill, label: 'اليوم'),
      (icon: CupertinoIcons.sparkles, label: 'النظام الذكي'),
      (icon: CupertinoIcons.timer_fill, label: 'المؤقت'),
      (icon: CupertinoIcons.chart_bar_alt_fill, label: 'التمارين'),
      (icon: CupertinoIcons.bell_solid, label: 'التنبيهات'),
    ];

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: EdgeInsets.only(
            top: 8,
            bottom: math.max(MediaQuery.of(context).padding.bottom, 10),
            left: 8,
            right: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xD912151E),
            border: Border(
              top: BorderSide(
                color: IosPalette.separator.withOpacity(0.55),
                width: 0.7,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final selected = _currentTabIndex == index;
              final item = items[index];
              final showTimerDot =
                  index == 2 && (_restRunning || _tabataRunning || _stopwatchRunning);

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_currentTabIndex != index) {
                      HapticFeedback.selectionClick();
                      setState(() => _currentTabIndex = index);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: selected
                          ? _accent.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              item.icon,
                              size: selected ? 23 : 21,
                              color: selected ? _accent : IosPalette.textMuted,
                            ),
                            if (showTimerDot)
                              Positioned(
                                top: -2,
                                right: -4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: IosPalette.iosOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: selected ? _accent : IosPalette.textMuted,
                            fontSize: 10.5,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // TAB 1: اليوم (APPLE FITNESS RINGS, ACTIVE WORKOUT & GYM CHECKLIST)
  // ==========================================================================

  Widget _buildDashboardTab() {
    final day = _currentWorkoutDay;
    final setsProgress = day.progress;
    final volumeProgress = (day.totalVolumeKg / 4000.0).clamp(0.0, 1.0);
    final waterProgress =
        _waterGoalCups == 0 ? 0.0 : (_waterCupsToday / _waterGoalCups).clamp(0.0, 1.0);

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
      children: [
        // Top iOS Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'iOS CUPERTINO PRO v2.0',
                        style: TextStyle(
                          color: _accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isWorkoutSessionActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: IosPalette.iosGreen.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'جلسة نشطة • ${_formatSeconds(_workoutElapsedSeconds)}',
                          style: const TextStyle(
                            color: IosPalette.iosGreen,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'ملخص تمرين اليوم',
                  style: TextStyle(
                    color: IosPalette.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IosPressableButton(
                  padding: const EdgeInsets.all(10),
                  borderRadius: 14,
                  color: IosPalette.cardSurface,
                  borderColor: IosPalette.separator,
                  onPressed: () => setState(() => _currentTabIndex = 1),
                  child: Icon(
                    CupertinoIcons.sparkles,
                    color: _accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                IosPressableButton(
                  padding: const EdgeInsets.all(10),
                  borderRadius: 14,
                  color: IosPalette.cardSurface,
                  borderColor: IosPalette.separator,
                  onPressed: () => setState(() => _currentTabIndex = 2),
                  child: const Icon(
                    CupertinoIcons.timer,
                    color: IosPalette.iosOrange,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Apple Fitness Activity Rings Card
        IosGlassCard(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(112, 112),
                      painter: AppleActivityRingsPainter(
                        outerProgress: setsProgress,
                        middleProgress: volumeProgress,
                        innerProgress: waterProgress,
                        accentColor: _accent,
                      ),
                    ),
                    Text(
                      '${(setsProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: IosPalette.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRingMetricRow(
                      color: IosPalette.iosGreen,
                      label: 'إنجاز الجولات',
                      value: '${day.completedSets} / ${day.totalSets} جولة',
                    ),
                    const SizedBox(height: 10),
                    _buildRingMetricRow(
                      color: _accent,
                      label: 'الحجم التدريبي',
                      value: '${day.totalVolumeKg.toStringAsFixed(0)} كجم',
                    ),
                    const SizedBox(height: 10),
                    _buildRingMetricRow(
                      color: IosPalette.iosTeal,
                      label: 'الترطيب والماء',
                      value: '$_waterCupsToday / $_waterGoalCups أكواب',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Active Smart Split Banner + Horizontal Day Selector Pills
        IosGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.bolt_horizontal_circle_fill,
                      color: _accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activeSystem.name,
                          style: const TextStyle(
                            color: IosPalette.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_activeSystem.category} • ${_activeSystem.days.length} أيام في الدورة',
                          style: const TextStyle(
                            color: IosPalette.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IosPressableButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    borderRadius: 12,
                    color: _accent.withOpacity(0.16),
                    onPressed: () => setState(() => _currentTabIndex = 1),
                    child: Text(
                      'تغيير النظام',
                      style: TextStyle(
                        color: _accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Horizontal iOS Day Pills Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_activeSystem.days.length, (i) {
                    final d = _activeSystem.days[i];
                    final isSelected = i == _activeDayIndex;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: IosPressableButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        borderRadius: 14,
                        color: isSelected ? _accent : IosPalette.cardElevated,
                        onPressed: () {
                          setState(() => _activeDayIndex = i);
                          _saveAppState();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              d.isRestDay
                                  ? CupertinoIcons.moon_stars_fill
                                  : CupertinoIcons.flame_fill,
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : IosPalette.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              d.title,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : IosPalette.textSecondary,
                                fontSize: 12.5,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Today's Workout Details & Action Header
        IosGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day.title,
                          style: const TextStyle(
                            color: IosPalette.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day.subtitle,
                          style: const TextStyle(
                            color: IosPalette.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IosPressableButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    borderRadius: 11,
                    color: IosPalette.cardElevated,
                    onPressed: () {
                      setState(() {
                        _activeDayIndex =
                            (_activeDayIndex + 1) % _activeSystem.days.length;
                      });
                      _saveAppState();
                      _showIosBanner(
                        title: 'تم التأجيل الذكي لليوم التالي ⏭️',
                        subtitle: 'تم ترحيل جدولك دون ضياع أي يوم تدريبي',
                        icon: CupertinoIcons.arrow_right_circle_fill,
                        color: _accent,
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.arrow_left_right_circle,
                          size: 14,
                          color: IosPalette.textSecondary,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'اليوم التالي',
                          style: TextStyle(
                            color: IosPalette.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: IosPressableButton(
                      color: _isWorkoutSessionActive
                          ? IosPalette.iosGreen
                          : _accent,
                      borderRadius: 14,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () {
                        if (day.isRestDay) {
                          _finishTodayWorkout();
                          return;
                        }
                        if (!_isWorkoutSessionActive) {
                          setState(() {
                            _isWorkoutSessionActive = true;
                            _workoutSessionStart = DateTime.now();
                          });
                          _showIosBanner(
                            title: 'بدأت جلسة التمرين الآن 🔥',
                            subtitle:
                                'اضغط على علامة ✓ بجانب أي جولة لبدء مؤقت الراحة تلقائياً',
                            icon: CupertinoIcons.play_circle_fill,
                            color: IosPalette.iosGreen,
                          );
                        } else {
                          _finishTodayWorkout();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isWorkoutSessionActive
                                ? CupertinoIcons.checkmark_seal_fill
                                : CupertinoIcons.play_fill,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            day.isRestDay
                                ? 'إتمام يوم الاستشفاء والانتقال للتالي'
                                : (_isWorkoutSessionActive
                                    ? 'إنهاء وحفظ تمرين اليوم (${_formatSeconds(_workoutElapsedSeconds)})'
                                    : 'بدء جلسة تمرين اليوم'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!day.isRestDay) ...[
                    const SizedBox(width: 10),
                    IosPressableButton(
                      color: IosPalette.cardElevated,
                      borderRadius: 14,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      onPressed: _openAddExerciseToTodaySheet,
                      child: const Icon(
                        CupertinoIcons.add,
                        color: IosPalette.textPrimary,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Exercises List for Today
        if (day.isRestDay)
          _buildRestDayCard()
        else
          ...day.exercises.map((ex) => _buildExerciseWorkoutCard(ex)),

        const SizedBox(height: 18),

        // Quick Hydration & Nutrition iOS Bar
        _buildQuickNutritionCard(),

        const SizedBox(height: 18),

        // Daily Gym Checklist (iOS Reminders style)
        _buildGymChecklistSection(),
      ],
    );
  }

  Widget _buildRingMetricRow({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: IosPalette.textSecondary,
              fontSize: 12.5,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildRestDayCard() {
    return IosGlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: IosPalette.iosTeal.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.moon_stars_fill,
              color: IosPalette.iosTeal,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'يوم الاستشفاء والبناء العضلي',
            style: TextStyle(
              color: IosPalette.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'العضلات تنمو أثناء الراحة! احرص اليوم على شرب الماء بالكامل، وتناول احتياجك من البروتين، والمشي الخفيف لمدة 20 دقيقة.',
            style: TextStyle(
              color: IosPalette.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseWorkoutCard(ExerciseItem exercise) {
    final allDone = exercise.isAllCompleted;
    return IosGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      borderColor: allDone
          ? IosPalette.iosGreen.withOpacity(0.6)
          : IosPalette.separator.withOpacity(0.65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: (allDone ? IosPalette.iosGreen : _accent)
                      .withOpacity(0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exercise.muscleGroup,
                  style: TextStyle(
                    color: allDone ? IosPalette.iosGreen : _accent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    color: IosPalette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IosPressableButton(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                borderRadius: 10,
                color: IosPalette.cardElevated,
                onPressed: () => _startRestTimer(
                  exercise.restSeconds,
                  exerciseName: exercise.name,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.timer,
                      color: IosPalette.iosOrange,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${exercise.restSeconds}ث',
                      style: const TextStyle(
                        color: IosPalette.iosOrange,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (exercise.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              exercise.notes,
              style: const TextStyle(
                color: IosPalette.textMuted,
                fontSize: 11.5,
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Sets Table Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 44,
                  child: Text(
                    'الجولة',
                    style: TextStyle(color: IosPalette.textMuted, fontSize: 11),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'الوزن (كجم)',
                      style:
                          TextStyle(color: IosPalette.textMuted, fontSize: 11),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'العدات',
                      style:
                          TextStyle(color: IosPalette.textMuted, fontSize: 11),
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Center(
                    child: Text(
                      'إتمام',
                      style:
                          TextStyle(color: IosPalette.textMuted, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sets Rows
          ...exercise.sets.map((s) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: s.completed
                    ? IosPalette.iosGreen.withOpacity(0.12)
                    : IosPalette.bgGrouped,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: s.completed
                      ? IosPalette.iosGreen.withOpacity(0.45)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: IosPalette.cardElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '#${s.setNumber}',
                          style: const TextStyle(
                            color: IosPalette.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Weight Stepper
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMiniStepBtn(
                          icon: CupertinoIcons.minus,
                          onTap: () {
                            setState(() {
                              s.weightKg = (s.weightKg - 2.5).clamp(0.0, 500.0);
                            });
                            _saveAppState();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            s.weightKg % 1 == 0
                                ? s.weightKg.toInt().toString()
                                : s.weightKg.toStringAsFixed(1),
                            style: const TextStyle(
                              color: IosPalette.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildMiniStepBtn(
                          icon: CupertinoIcons.plus,
                          onTap: () {
                            setState(() {
                              s.weightKg = (s.weightKg + 2.5).clamp(0.0, 500.0);
                            });
                            _saveAppState();
                          },
                        ),
                      ],
                    ),
                  ),
                  // Reps Stepper
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMiniStepBtn(
                          icon: CupertinoIcons.minus,
                          onTap: () {
                            setState(() {
                              s.actualReps = (s.actualReps - 1).clamp(1, 100);
                            });
                            _saveAppState();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '${s.actualReps}',
                            style: const TextStyle(
                              color: IosPalette.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildMiniStepBtn(
                          icon: CupertinoIcons.plus,
                          onTap: () {
                            setState(() {
                              s.actualReps = (s.actualReps + 1).clamp(1, 100);
                            });
                            _saveAppState();
                          },
                        ),
                      ],
                    ),
                  ),
                  // Checkmark Button (Triggers Rest Timer Automatically!)
                  SizedBox(
                    width: 46,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _onToggleSetCompleted(exercise, s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: s.completed
                                ? IosPalette.iosGreen
                                : IosPalette.cardElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: s.completed
                                  ? IosPalette.iosGreen
                                  : IosPalette.separator,
                            ),
                          ),
                          child: Icon(
                            CupertinoIcons.checkmark_alt,
                            color: s.completed
                                ? Colors.white
                                : IosPalette.textMuted,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          // Add / Remove Set Footer
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    final last = exercise.sets.isNotEmpty
                        ? exercise.sets.last
                        : SetEntry(setNumber: 0, targetReps: 10, weightKg: 30);
                    exercise.sets.add(
                      SetEntry(
                        setNumber: exercise.sets.length + 1,
                        targetReps: last.targetReps,
                        actualReps: last.actualReps,
                        weightKg: last.weightKg,
                      ),
                    );
                  });
                  _saveAppState();
                  HapticFeedback.selectionClick();
                },
                child: Text(
                  '+ إضافة جولة',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (exercise.sets.length > 1)
                GestureDetector(
                  onTap: () {
                    setState(() => exercise.sets.removeLast());
                    _saveAppState();
                  },
                  child: const Text(
                    'حذف جولة',
                    style: TextStyle(
                      color: IosPalette.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStepBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: IosPalette.cardElevated,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 12, color: IosPalette.textSecondary),
      ),
    );
  }

  Widget _buildQuickNutritionCard() {
    return IosGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                CupertinoIcons.drop_fill,
                color: IosPalette.iosTeal,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'الترطيب والمكملات اليومية',
                style: TextStyle(
                  color: IosPalette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: IosPalette.bgGrouped,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أكواب الماء (250 مل)',
                        style: TextStyle(
                          color: IosPalette.textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_waterCupsToday / $_waterGoalCups',
                            style: const TextStyle(
                              color: IosPalette.iosTeal,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Row(
                            children: [
                              _buildMiniStepBtn(
                                icon: CupertinoIcons.minus,
                                onTap: () {
                                  setState(() {
                                    _waterCupsToday =
                                        (_waterCupsToday - 1).clamp(0, 30);
                                  });
                                  _saveAppState();
                                },
                              ),
                              const SizedBox(width: 6),
                              _buildMiniStepBtn(
                                icon: CupertinoIcons.plus,
                                onTap: () {
                                  setState(() {
                                    _waterCupsToday =
                                        (_waterCupsToday + 1).clamp(0, 30);
                                  });
                                  _saveAppState();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _creatineTakenToday = !_creatineTakenToday);
                    _saveAppState();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _creatineTakenToday
                          ? IosPalette.iosGreen.withOpacity(0.15)
                          : IosPalette.bgGrouped,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _creatineTakenToday
                            ? IosPalette.iosGreen.withOpacity(0.5)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'جرعة الكرياتين (5g)',
                          style: TextStyle(
                            color: IosPalette.textMuted,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _creatineTakenToday ? 'تم التناول ✓' : 'اضغط للتسجيل',
                              style: TextStyle(
                                color: _creatineTakenToday
                                    ? IosPalette.iosGreen
                                    : IosPalette.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              _creatineTakenToday
                                  ? CupertinoIcons.checkmark_circle_fill
                                  : CupertinoIcons.circle,
                              color: _creatineTakenToday
                                  ? IosPalette.iosGreen
                                  : IosPalette.textMuted,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGymChecklistSection() {
    return IosGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.checkmark_rectangle_fill,
                    color: _accent,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'مهام وأهداف الجيم اليومية',
                    style: TextStyle(
                      color: IosPalette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IosPressableButton(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                borderRadius: 10,
                color: _accent.withOpacity(0.16),
                onPressed: _openAddGymTaskSheet,
                child: Text(
                  '+ مهمة جديدة',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_gymTasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'لا توجد مهام إضافية مسجلة حالياً',
                  style: TextStyle(color: IosPalette.textMuted, fontSize: 12.5),
                ),
              ),
            )
          else
            ..._gymTasks.map((task) {
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: IosPalette.bgGrouped,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => task.done = !task.done);
                        _saveAppState();
                      },
                      child: Icon(
                        task.done
                            ? CupertinoIcons.checkmark_circle_fill
                            : CupertinoIcons.circle,
                        color: task.done
                            ? IosPalette.iosGreen
                            : IosPalette.textMuted,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          color: task.done
                              ? IosPalette.textMuted
                              : IosPalette.textPrimary,
                          fontSize: 13.5,
                          decoration:
                              task.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _gymTasks.remove(task));
                        _saveAppState();
                      },
                      child: const Icon(
                        CupertinoIcons.trash,
                        color: IosPalette.textMuted,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 2: النظام الذكي (AI SCHEDULE PARSER, BUILT-IN SPLITS, SMART WIZARD)
  // ==========================================================================

  Widget _buildSmartScheduleTab() {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
      children: [
        const Text(
          'النظام الذكي للجداول',
          style: TextStyle(
            color: IosPalette.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'يفهم أي جدول تدريبي مكتوب ويحلل الأنظمة (PPL، أرنولد، علوي/سفلي، أو جدول الكابتن) بلمسة واحدة.',
          style: TextStyle(
            color: IosPalette.textSecondary,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 14),

        // iOS Segmented Control
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: IosPalette.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: IosPalette.separator.withOpacity(0.5)),
          ),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _smartSystemSubTab,
            backgroundColor: Colors.transparent,
            thumbColor: _accent,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'المحلل الذكي',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'الأنظمة الجاهزة',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              2: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'مصمم الأنظمة',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            },
            onValueChanged: (val) {
              if (val != null) {
                HapticFeedback.selectionClick();
                setState(() => _smartSystemSubTab = val);
              }
            },
          ),
        ),
        const SizedBox(height: 16),

        if (_smartSystemSubTab == 0) _buildSmartTextParserView(),
        if (_smartSystemSubTab == 1) _buildBuiltInSystemsView(),
        if (_smartSystemSubTab == 2) _buildSmartWizardView(),
      ],
    );
  }

  Widget _buildSmartTextParserView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IosGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.sparkles, color: _accent, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'الصق أو اكتب أي جدول تدريبي وسيقوم النظام بفهمه فوراً',
                      style: TextStyle(
                        color: IosPalette.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Quick Sample Templates
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildSampleScheduleChip(
                      label: 'نموذج جدول كابتن مفصل',
                      sampleText:
                          'السبت: صدر وتراي - بنش برس 4x10 وزن 70 كجم راحة 90 ثانية، تجميع دمبل عالي 4x10 وزن 28، تفتيح كابل 3x12، دفع حبل تراي 4x12\n'
                          'الأحد: ظهر وباي - سحب عالي 4x10 وزن 65، تجديف بالبار 4x8 وزن 60، سحب أرضي 3x12، بار بايسبس 4x10\n'
                          'الاثنين: أرجل وكتف - سكوات 4x8 وزن 90، دفش أرجل 4x12، ضغط أكتاف دمبل 4x10، رفرفة جانبي 4x15\n'
                          'الثلاثاء: راحة واستشفاء',
                    ),
                    const SizedBox(width: 8),
                    _buildSampleScheduleChip(
                      label: 'نموذج اختصار سريع (عضلات فقط)',
                      sampleText:
                          'اليوم 1: صدر وبايسبس\nاليوم 2: ظهر وترايسبس\nاليوم 3: أكتاف وبطن\nاليوم 4: أرجل كاملة\nاليوم 5: راحة',
                    ),
                    const SizedBox(width: 8),
                    _buildSampleScheduleChip(
                      label: 'نموذج PPL إنجليزي/عربي',
                      sampleText:
                          'Push: بنش برس 4x8 75kg، تجميع عالي 4x10، رفرفة جانبي 4x15، تراي حبل 4x12\n'
                          'Pull: سحب عالي 4x10، تجديف بار 4x8، بايسبس تبادل 4x12\n'
                          'Legs: سكوات 4x8 100kg، ديدليفت روماني 4x10، سمانة 4x15',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: IosPalette.bgGrouped,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: IosPalette.separator),
                ),
                child: TextField(
                  controller: _smartParserController,
                  maxLines: 6,
                  style: const TextStyle(
                    color: IosPalette.textPrimary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                  decoration: const InputDecoration(
                    hintText:
                        'مثال:\nالسبت: صدر وتراي - بنش برس 4x10 وزن 70 راحة 90 ثانية، تجميع عالي 4x12\nالأحد: ظهر وباي - سحب عالي 4x10، تجديف 4x10...',
                    hintStyle: TextStyle(
                      color: IosPalette.textMuted,
                      fontSize: 12,
                    ),
                    contentPadding: EdgeInsets.all(14),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: IosPressableButton(
                      color: _accent,
                      onPressed: () {
                        final parsed = SmartScheduleEngine.parseAnyScheduleText(
                          _smartParserController.text,
                        );
                        setState(() => _previewParsedSystem = parsed);
                        _showIosBanner(
                          title: 'تم تحليل الجدول بنجاح (${parsed.days.length} أيام)',
                          subtitle: 'راجع المعاينة بالأسفل واضغط "تفعيل كنظامي الحالي"',
                          icon: CupertinoIcons.checkmark_seal_fill,
                          color: IosPalette.iosGreen,
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.wand_stars,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'تحليل وفهم الجدول الآن',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_smartParserController.text.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    IosPressableButton(
                      color: IosPalette.cardElevated,
                      onPressed: () {
                        setState(() {
                          _smartParserController.clear();
                          _previewParsedSystem = null;
                        });
                      },
                      child: const Icon(
                        CupertinoIcons.clear_circled,
                        color: IosPalette.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        if (_previewParsedSystem != null) ...[
          const SizedBox(height: 16),
          IosGlassCard(
            borderColor: IosPalette.iosGreen.withOpacity(0.6),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.checkmark_seal_fill,
                      color: IosPalette.iosGreen,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _previewParsedSystem!.name,
                        style: const TextStyle(
                          color: IosPalette.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._previewParsedSystem!.days.map((d) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: IosPalette.bgGrouped,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              d.title,
                              style: TextStyle(
                                color: _accent,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              d.isRestDay
                                  ? 'راحة'
                                  : '${d.exercises.length} تمارين • ${d.totalSets} جولة',
                              style: const TextStyle(
                                color: IosPalette.textMuted,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                        if (d.exercises.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: d.exercises.map((e) {
                              final firstSet = e.sets.isNotEmpty
                                  ? e.sets.first
                                  : SetEntry(setNumber: 1, targetReps: 10);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: IosPalette.cardElevated,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${e.name} (${e.sets.length}×${firstSet.targetReps})',
                                  style: const TextStyle(
                                    color: IosPalette.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                IosPressableButton(
                  fullWidth: true,
                  color: IosPalette.iosGreen,
                  onPressed: () {
                    setState(() {
                      _activeSystem = _previewParsedSystem!.cloneDeep();
                      _activeDayIndex = 0;
                      _currentTabIndex = 0;
                    });
                    _saveAppState();
                    _showIosBanner(
                      title: 'تم تفعيل جدولك المخصص بنجاح! 🚀',
                      subtitle: 'تم ضبط التمارين والجولات ومؤقت الراحة في شاشة اليوم',
                      icon: CupertinoIcons.flame_fill,
                      color: IosPalette.iosGreen,
                    );
                  },
                  child: const Text(
                    'تفعيل هذا الجدول كنظامي الحالي الآن',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSampleScheduleChip({
    required String label,
    required String sampleText,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _smartParserController.text = sampleText;
          _previewParsedSystem =
              SmartScheduleEngine.parseAnyScheduleText(sampleText);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: IosPalette.cardElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: IosPalette.separator),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.doc_text_fill, size: 13, color: _accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: IosPalette.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuiltInSystemsView() {
    final systems = SmartScheduleEngine.getBuiltInSystems();
    return Column(
      children: systems.map((sys) {
        final isActive = _activeSystem.id == sys.id;
        return IosGlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          borderColor: isActive ? _accent : IosPalette.separator.withOpacity(0.6),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sys.category,
                      style: TextStyle(
                        color: _accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: IosPalette.cardElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${sys.daysPerWeek} أيام/أسبوع • ${sys.level}',
                      style: const TextStyle(
                        color: IosPalette.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isActive)
                    const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: IosPalette.iosGreen,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                sys.name,
                style: const TextStyle(
                  color: IosPalette.textPrimary,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sys.description,
                style: const TextStyle(
                  color: IosPalette.textSecondary,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: sys.days.map((d) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: IosPalette.bgGrouped,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      d.title,
                      style: const TextStyle(
                        color: IosPalette.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              IosPressableButton(
                fullWidth: true,
                color: isActive ? IosPalette.iosGreen : _accent,
                onPressed: () {
                  setState(() {
                    _activeSystem = sys.cloneDeep();
                    _activeDayIndex = 0;
                    _currentTabIndex = 0;
                  });
                  _saveAppState();
                  _showIosBanner(
                    title: 'تم تفعيل ${sys.name}',
                    subtitle: 'جميع التمارين والجولات جاهزة الآن في تبويب اليوم',
                    icon: CupertinoIcons.flame_fill,
                    color: IosPalette.iosGreen,
                  );
                },
                child: Text(
                  isActive ? 'النظام النشط حالياً ✓' : 'تفعيل هذا النظام الآن',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSmartWizardView() {
    final goals = ['تضخيم عضلي', 'تنشيف وحرق دهون', 'قوة بدنية وكسر أوزان'];
    final levels = ['مبتدئ', 'متوسط - متقدم', 'متقدم ومحترف'];

    return IosGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.sparkles, color: _accent, size: 22),
              const SizedBox(width: 8),
              const Text(
                'المدرب الذكي لبناء نظامك المثالي',
                style: TextStyle(
                  color: IosPalette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '1. ما هو هدفك الأساسي حالياً؟',
            style: TextStyle(
              color: IosPalette.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: goals.map((g) {
              final sel = _wizardGoal == g;
              return IosPressableButton(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                borderRadius: 12,
                color: sel ? _accent : IosPalette.cardElevated,
                onPressed: () => setState(() => _wizardGoal = g),
                child: Text(
                  g,
                  style: TextStyle(
                    color: sel ? Colors.white : IosPalette.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          const Text(
            '2. كم يوماً يمكنك التمرين في الأسبوع؟',
            style: TextStyle(
              color: IosPalette.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [3, 4, 5, 6].map((d) {
              final sel = _wizardDays == d;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: IosPressableButton(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    borderRadius: 12,
                    color: sel ? _accent : IosPalette.cardElevated,
                    onPressed: () => setState(() => _wizardDays = d),
                    child: Text(
                      '$d أيام',
                      style: TextStyle(
                        color: sel ? Colors.white : IosPalette.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          const Text(
            '3. مستوى الخبرة التدريبية',
            style: TextStyle(
              color: IosPalette.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: levels.map((lv) {
              final sel = _wizardLevel == lv;
              return IosPressableButton(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                borderRadius: 12,
                color: sel ? _accent : IosPalette.cardElevated,
                onPressed: () => setState(() => _wizardLevel = lv),
                child: Text(
                  lv,
                  style: TextStyle(
                    color: sel ? Colors.white : IosPalette.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          IosPressableButton(
            fullWidth: true,
            color: IosPalette.iosGreen,
            onPressed: () {
              final built = SmartScheduleEngine.recommendSmartSystem(
                goal: _wizardGoal,
                daysPerWeek: _wizardDays,
                level: _wizardLevel,
              );
              setState(() {
                _activeSystem = built;
                _activeDayIndex = 0;
                _currentTabIndex = 0;
              });
              _saveAppState();
              _showIosBanner(
                title: 'تم تصميم وتفعيل نظامك الذكي! ⚡',
                subtitle: built.name,
                icon: CupertinoIcons.sparkles,
                color: IosPalette.iosGreen,
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.bolt_fill, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'توليد وتفعيل النظام المخصص الآن',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 3: المؤقت الذكي (REST TIMER, TABATA HIIT, STOPWATCH)
  // ==========================================================================

  Widget _buildTimerTab() {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
      children: [
        const Text(
          'مؤقت التمرين الاحترافي',
          style: TextStyle(
            color: IosPalette.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'مؤقت راحة ذكي يبدأ تلقائياً مع الجولات، ومؤقت تاباتا HIIT، وساعة إيقاف دقيقة بنظام iOS.',
          style: TextStyle(
            color: IosPalette.textSecondary,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 14),

        // Mode Switcher
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: IosPalette.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: IosPalette.separator.withOpacity(0.5)),
          ),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _timerMode,
            backgroundColor: Colors.transparent,
            thumbColor: _accent,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'مؤقت الراحة',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'تاباتا HIIT',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              2: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'ساعة الإيقاف',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            },
            onValueChanged: (val) {
              if (val != null) {
                HapticFeedback.selectionClick();
                setState(() => _timerMode = val);
              }
            },
          ),
        ),
        const SizedBox(height: 18),

        if (_timerMode == 0) _buildRestTimerView(),
        if (_timerMode == 1) _buildTabataTimerView(),
        if (_timerMode == 2) _buildStopwatchView(),
      ],
    );
  }

  Widget _buildRestTimerView() {
    final progress = _restTotalSeconds == 0
        ? 0.0
        : (_restRemainingSeconds / _restTotalSeconds).clamp(0.0, 1.0);
    final presets = [30, 45, 60, 90, 120, 180];

    return Column(
      children: [
        IosGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Text(
                _restCurrentExerciseName,
                style: const TextStyle(
                  color: IosPalette.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              // Circular Apple Watch Timer
              SizedBox(
                width: 235,
                height: 235,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(235, 235),
                      painter: IosCircularTimerPainter(
                        progress: progress,
                        activeColor:
                            _restRunning ? IosPalette.iosOrange : _accent,
                        isRunning: _restRunning,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatSeconds(_restRemainingSeconds),
                          style: const TextStyle(
                            color: IosPalette.textPrimary,
                            fontSize: 50,
                            fontWeight: FontWeight.w900,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _restRunning ? 'جارٍ العد التنازلي...' : 'جاهز للبدء',
                          style: TextStyle(
                            color: _restRunning
                                ? IosPalette.iosOrange
                                : IosPalette.textMuted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // iOS Control Buttons Row (-15s, Play/Pause, Reset, +15s)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IosPressableButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    borderRadius: 16,
                    color: IosPalette.cardElevated,
                    onPressed: () => _adjustRestTimer(-15),
                    child: const Text(
                      '-15ث',
                      style: TextStyle(
                        color: IosPalette.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IosPressableButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 14,
                    ),
                    borderRadius: 20,
                    color: _restRunning
                        ? IosPalette.iosOrange
                        : IosPalette.iosGreen,
                    onPressed: () {
                      setState(() {
                        if (_restRunning) {
                          _restRunning = false;
                          _restTargetEndTime = null;
                        } else {
                          if (_restRemainingSeconds <= 0) {
                            _restRemainingSeconds = _restTotalSeconds;
                          }
                          _restRunning = true;
                          _restTargetEndTime = DateTime.now().add(
                            Duration(seconds: _restRemainingSeconds),
                          );
                        }
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _restRunning
                              ? CupertinoIcons.pause_fill
                              : CupertinoIcons.play_fill,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _restRunning ? 'إيقاف مؤقت' : 'بدء المؤقت',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IosPressableButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    borderRadius: 16,
                    color: IosPalette.cardElevated,
                    onPressed: () {
                      setState(() {
                        _restRunning = false;
                        _restRemainingSeconds = _restTotalSeconds;
                        _restTargetEndTime = null;
                      });
                    },
                    child: const Icon(
                      CupertinoIcons.refresh,
                      color: IosPalette.textPrimary,
                      size: 18,
                    ),
                  ),
                  IosPressableButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    borderRadius: 16,
                    color: IosPalette.cardElevated,
                    onPressed: () => _adjustRestTimer(15),
                    child: const Text(
                      '+15ث',
                      style: TextStyle(
                        color: IosPalette.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Preset Durations Card
        IosGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'أوقات الراحة السريعة (اضغط للتشغيل الفوري)',
                style: TextStyle(
                  color: IosPalette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presets.map((sec) {
                  final selected = _restTotalSeconds == sec;
                  return IosPressableButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    borderRadius: 13,
                    color: selected ? _accent : IosPalette.cardElevated,
                    onPressed: () => _startRestTimer(sec),
                    child: Text(
                      sec >= 120 ? '${sec ~/ 60} دقائق ($secث)' : '$sec ثانية',
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : IosPalette.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: IosPalette.bgGrouped,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'تشغيل مؤقت الراحة تلقائياً عند إتمام أي جولة تمرين',
                        style: TextStyle(
                          color: IosPalette.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    CupertinoSwitch(
                      value: _autoStartRestOnSet,
                      activeColor: IosPalette.iosGreen,
                      onChanged: (v) {
                        setState(() => _autoStartRestOnSet = v);
                        _saveAppState();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabataTimerView() {
    final total = _tabataIsWorkPhase ? _tabataWorkSec : _tabataRestSec;
    final progress =
        total == 0 ? 0.0 : (_tabataRemainingSec / total).clamp(0.0, 1.0);
    final phaseColor =
        _tabataIsWorkPhase ? IosPalette.iosGreen : IosPalette.iosOrange;

    return IosGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: phaseColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _tabataIsWorkPhase
                  ? 'مرحلة التمرين العالي (WORK) • الجولة $_tabataCurrentRound من $_tabataTotalRounds'
                  : 'مرحلة الاستراحة (REST) • الجولة $_tabataCurrentRound من $_tabataTotalRounds',
              style: TextStyle(
                color: phaseColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 220),
                  painter: IosCircularTimerPainter(
                    progress: progress,
                    activeColor: phaseColor,
                    isRunning: _tabataRunning,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatSeconds(_tabataRemainingSec),
                      style: const TextStyle(
                        color: IosPalette.textPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      _tabataIsWorkPhase ? 'تمرين بقوة 🔥' : 'تنفس واسترح 💨',
                      style: TextStyle(
                        color: phaseColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTabataSettingBox(
                  label: 'وقت التمرين',
                  value: '$_tabataWorkSecث',
                  onMinus: () {
                    if (!_tabataRunning) {
                      setState(() {
                        _tabataWorkSec = (_tabataWorkSec - 5).clamp(10, 300);
                        if (_tabataIsWorkPhase) {
                          _tabataRemainingSec = _tabataWorkSec;
                        }
                      });
                    }
                  },
                  onPlus: () {
                    if (!_tabataRunning) {
                      setState(() {
                        _tabataWorkSec = (_tabataWorkSec + 5).clamp(10, 300);
                        if (_tabataIsWorkPhase) {
                          _tabataRemainingSec = _tabataWorkSec;
                        }
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTabataSettingBox(
                  label: 'وقت الراحة',
                  value: '$_tabataRestSecث',
                  onMinus: () {
                    if (!_tabataRunning) {
                      setState(() {
                        _tabataRestSec = (_tabataRestSec - 5).clamp(5, 180);
                      });
                    }
                  },
                  onPlus: () {
                    if (!_tabataRunning) {
                      setState(() {
                        _tabataRestSec = (_tabataRestSec + 5).clamp(5, 180);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTabataSettingBox(
                  label: 'عدد الجولات',
                  value: '$_tabataTotalRounds',
                  onMinus: () {
                    if (!_tabataRunning) {
                      setState(() {
                        _tabataTotalRounds =
                            (_tabataTotalRounds - 1).clamp(1, 30);
                      });
                    }
                  },
                  onPlus: () {
                    if (!_tabataRunning) {
                      setState(() {
                        _tabataTotalRounds =
                            (_tabataTotalRounds + 1).clamp(1, 30);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: IosPressableButton(
                  color: _tabataRunning
                      ? IosPalette.iosOrange
                      : IosPalette.iosGreen,
                  onPressed: () {
                    setState(() => _tabataRunning = !_tabataRunning);
                  },
                  child: Text(
                    _tabataRunning ? 'إيقاف مؤقت' : 'بدء تاباتا HIIT',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IosPressableButton(
                color: IosPalette.cardElevated,
                onPressed: () {
                  setState(() {
                    _tabataRunning = false;
                    _tabataCurrentRound = 1;
                    _tabataIsWorkPhase = true;
                    _tabataRemainingSec = _tabataWorkSec;
                  });
                },
                child: const Text(
                  'إعادة ضبط',
                  style: TextStyle(
                    color: IosPalette.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabataSettingBox({
    required String label,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: IosPalette.bgGrouped,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: IosPalette.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: IosPalette.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniStepBtn(icon: CupertinoIcons.minus, onTap: onMinus),
              const SizedBox(width: 8),
              _buildMiniStepBtn(icon: CupertinoIcons.plus, onTap: onPlus),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStopwatchView() {
    final totalSec = _stopwatchDeciSeconds ~/ 10;
    final deci = _stopwatchDeciSeconds % 10;
    final formatted = '${_formatSeconds(totalSec)}.$deci';

    return IosGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            formatted,
            style: const TextStyle(
              color: IosPalette.textPrimary,
              fontSize: 54,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IosPressableButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                borderRadius: 16,
                color: IosPalette.cardElevated,
                onPressed: () {
                  setState(() {
                    if (_stopwatchRunning) {
                      _stopwatchLaps.insert(0, _stopwatchDeciSeconds);
                    } else {
                      _stopwatchDeciSeconds = 0;
                      _stopwatchLaps.clear();
                    }
                  });
                },
                child: Text(
                  _stopwatchRunning ? 'تسجيل دورة (Lap)' : 'تصفير',
                  style: const TextStyle(
                    color: IosPalette.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IosPressableButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                borderRadius: 16,
                color: _stopwatchRunning
                    ? IosPalette.iosRed
                    : IosPalette.iosGreen,
                onPressed: () {
                  setState(() => _stopwatchRunning = !_stopwatchRunning);
                },
                child: Text(
                  _stopwatchRunning ? 'إيقاف' : 'بدء',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (_stopwatchLaps.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Divider(color: IosPalette.separator),
            ...List.generate(_stopwatchLaps.length, (i) {
              final lapDeci = _stopwatchLaps[i];
              final lapNumber = _stopwatchLaps.length - i;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الدورة #$lapNumber',
                      style: const TextStyle(
                        color: IosPalette.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${_formatSeconds(lapDeci ~/ 10)}.${lapDeci % 10}',
                      style: const TextStyle(
                        color: IosPalette.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // TAB 4: التمارين والأوزان (LIBRARY, 1RM CALCULATOR, MUSCLE RECOVERY & LOGS)
  // ==========================================================================

  Widget _buildExercisesAndStatsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
      children: [
        const Text(
          'التمارين والأوزان والاستشفاء',
          style: TextStyle(
            color: IosPalette.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: IosPalette.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: IosPalette.separator.withOpacity(0.5)),
          ),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _exercisesSubTab,
            backgroundColor: Colors.transparent,
            thumbColor: _accent,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'موسوعة التمارين',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'حاسبة 1RM',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              2: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'الاستشفاء والسجل',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            },
            onValueChanged: (v) {
              if (v != null) {
                HapticFeedback.selectionClick();
                setState(() => _exercisesSubTab = v);
              }
            },
          ),
        ),
        const SizedBox(height: 16),

        if (_exercisesSubTab == 0) _buildExerciseEncyclopediaView(),
        if (_exercisesSubTab == 1) _buildOneRepMaxCalculatorView(),
        if (_exercisesSubTab == 2) _buildRecoveryAndHistoryView(),
      ],
    );
  }

  Widget _buildExerciseEncyclopediaView() {
    const categories = [
      'الكل',
      'الصدر',
      'الظهر',
      'الأكتاف',
      'البايسبس',
      'الترايسبس',
      'الأرجل',
      'البطن',
    ];

    final catalog = [
      (
        name: 'بنش برس مستوي بالبار (Barbell Bench Press)',
        muscle: 'الصدر',
        tip: 'ثبت لوحي الكتف للخلف وانزل بالبار لمنتصف الصدر بتحكم كامل.'
      ),
      (
        name: 'تجميع دمبل عالي (Incline Dumbbell Press)',
        muscle: 'الصدر',
        tip: 'زاوية 30 درجة تركز على الألياف العلوية للصدر دون إجهاد الكتف الأمامي.'
      ),
      (
        name: 'تفتيح كابل كروس أوفر (Cable Crossover)',
        muscle: 'الصدر',
        tip: 'اثنِ الكوع قليلاً واثبت ثانية كاملة عند الانقباض في المنتصف.'
      ),
      (
        name: 'سحب عالي واسع (Lat Pulldown)',
        muscle: 'الظهر',
        tip: 'اسحب بكوعك لأسفل باتجاه الجوانب لعزل عضلة المجنص العريضة.'
      ),
      (
        name: 'تجديف بالبار منحني (Barbell Row)',
        muscle: 'الظهر',
        tip: 'حافظ على استقامة أسفل الظهر واسحب البار نحو السرة.'
      ),
      (
        name: 'ضغط أكتاف بالدمبل (Overhead Shoulder Press)',
        muscle: 'الأكتاف',
        tip: 'اجعل الكوعين للأمام قليلاً بزاوية 75 درجة لحماية مفصل الكتف.'
      ),
      (
        name: 'رفرفة جانبي بالدمبل (Lateral Raises)',
        muscle: 'الأكتاف',
        tip: 'ارفع بمستوى الكوع ولا تتجاوز مستوى الكتف لعزل الرأس الجانبي.'
      ),
      (
        name: 'تبادل بايسبس بالبار الزجزاج (EZ-Bar Curl)',
        muscle: 'البايسبس',
        tip: 'ثبت الكوعين بجانب الجسم وتجنب المرجحة بالظهر.'
      ),
      (
        name: 'دفع حبل ترايسبس على الكابل (Rope Pushdown)',
        muscle: 'الترايسبس',
        tip: 'افتح طرفي الحبل في نهاية الحركة لتحقيق أقصى انقباض للرأس الجانبي.'
      ),
      (
        name: 'سكوات بالبار الحر (Barbell Back Squat)',
        muscle: 'الأرجل',
        tip: 'ادفع الركبتين في اتجاه أصابع القدم وانزل حتى التوازي أو أسفل قليلاً.'
      ),
      (
        name: 'ديدليفت روماني (Romanian Deadlift)',
        muscle: 'الأرجل',
        tip: 'ادفع الحوض للخلف مع إبقاء البار قريباً من الساقين لاستهداف الخلفيات.'
      ),
      (
        name: 'طحن بطن على الكابل (Cable Crunch)',
        muscle: 'البطن',
        tip: 'اثنِ العمود الفقري لأسفل بعضلات البطن وليس بمفصل الحوض.'
      ),
    ];

    final filtered = catalog.where((item) {
      final matchCat =
          _selectedMuscleFilter == 'الكل' || item.muscle == _selectedMuscleFilter;
      final matchQuery = _exerciseSearchQuery.isEmpty ||
          item.name.toLowerCase().contains(_exerciseSearchQuery.toLowerCase());
      return matchCat && matchQuery;
    }).toList();

    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: IosPalette.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: IosPalette.separator),
          ),
          child: TextField(
            onChanged: (v) => setState(() => _exerciseSearchQuery = v),
            style: const TextStyle(color: IosPalette.textPrimary, fontSize: 13.5),
            decoration: const InputDecoration(
              hintText: 'ابحث عن أي تمرين بالاسم...',
              hintStyle: TextStyle(color: IosPalette.textMuted, fontSize: 12.5),
              prefixIcon: Icon(
                CupertinoIcons.search,
                color: IosPalette.textMuted,
                size: 18,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: categories.map((cat) {
              final sel = _selectedMuscleFilter == cat;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IosPressableButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  borderRadius: 12,
                  color: sel ? _accent : IosPalette.cardSurface,
                  onPressed: () => setState(() => _selectedMuscleFilter = cat),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: sel ? Colors.white : IosPalette.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        ...filtered.map((item) {
          return IosGlassCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          item.muscle,
                          style: TextStyle(
                            color: _accent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: IosPalette.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.tip,
                        style: const TextStyle(
                          color: IosPalette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                IosPressableButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  borderRadius: 12,
                  color: _accent,
                  onPressed: () {
                    setState(() {
                      _currentWorkoutDay.isRestDay = false;
                      _currentWorkoutDay.exercises.add(
                        ExerciseItem.create(
                          name: item.name,
                          muscleGroup: item.muscle,
                          setsCount: 4,
                          repsCount: 10,
                          startWeight: 40,
                          restSeconds: 90,
                          notes: item.tip,
                        ),
                      );
                    });
                    _saveAppState();
                    _showIosBanner(
                      title: 'تمت إضافة التمرين ليومك الحالي ✓',
                      subtitle: item.name,
                      icon: CupertinoIcons.add_circled_solid,
                      color: IosPalette.iosGreen,
                    );
                  },
                  child: const Text(
                    '+ لليوم',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOneRepMaxCalculatorView() {
    // Epley 1RM Formula: weight * (1 + reps / 30)
    final oneRepMax = _calcReps == 1
        ? _calcWeightKg
        : _calcWeightKg * (1 + (_calcReps / 30.0));
    final percentages = [95, 90, 85, 80, 75, 70, 65];

    return IosGlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.speedometer, color: _accent, size: 22),
              const SizedBox(width: 8),
              const Text(
                'حاسبة أقصى وزن (1RM) والأوزان التدريبية',
                style: TextStyle(
                  color: IosPalette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _accent.withOpacity(0.45)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أقصى وزن لعدة واحدة (1RM)',
                      style: TextStyle(
                        color: IosPalette.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'معادلة Epley المعتمدة رياضياً',
                      style: TextStyle(
                        color: IosPalette.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${oneRepMax.toStringAsFixed(1)} كجم',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'الوزن المرفوع: ${_calcWeightKg.toStringAsFixed(1)} كجم',
            style: const TextStyle(
              color: IosPalette.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          CupertinoSlider(
            value: _calcWeightKg.clamp(10.0, 250.0),
            min: 10.0,
            max: 250.0,
            divisions: 96,
            activeColor: _accent,
            onChanged: (v) => setState(() => _calcWeightKg = v),
          ),
          const SizedBox(height: 8),
          Text(
            'عدد العدات بهذا الوزن: $_calcReps عدات',
            style: const TextStyle(
              color: IosPalette.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          CupertinoSlider(
            value: _calcReps.toDouble().clamp(1.0, 20.0),
            min: 1.0,
            max: 20.0,
            divisions: 19,
            activeColor: IosPalette.iosGreen,
            onChanged: (v) => setState(() => _calcReps = v.round()),
          ),
          const SizedBox(height: 14),
          const Text(
            'جدول النسب المئوية للجولات التدريبية:',
            style: TextStyle(
              color: IosPalette.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...percentages.map((pct) {
            final w = oneRepMax * (pct / 100.0);
            final targetReps = pct >= 90
                ? '2 - 4 عدات (قوة قصوى)'
                : (pct >= 80
                    ? '6 - 8 عدات (قوة وضخامة)'
                    : '10 - 12 عدة (ضخامة عضلية)');
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: IosPalette.bgGrouped,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$pct% — $targetReps',
                    style: const TextStyle(
                      color: IosPalette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${w.toStringAsFixed(1)} كجم',
                    style: const TextStyle(
                      color: IosPalette.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecoveryAndHistoryView() {
    const muscles = [
      'الصدر',
      'الظهر',
      'الأكتاف',
      'البايسبس',
      'الترايسبس',
      'الأرجل',
      'البطن',
    ];

    return Column(
      children: [
        IosGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.heart_fill,
                    color: IosPalette.iosGreen,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'حالة الاستشفاء العضلي الذكي (Muscle Recovery)',
                    style: TextStyle(
                      color: IosPalette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...muscles.map((m) {
                final rec = _getMuscleRecoveryPercent(m);
                final color = rec >= 0.85
                    ? IosPalette.iosGreen
                    : (rec >= 0.5 ? IosPalette.iosOrange : IosPalette.iosRed);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            m,
                            style: const TextStyle(
                              color: IosPalette.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            rec >= 0.85
                                ? '${(rec * 100).toInt()}% (جاهزة للتمرين ✓)'
                                : '${(rec * 100).toInt()}% (قيد الاستشفاء)',
                            style: TextStyle(
                              color: color,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: rec,
                          minHeight: 7,
                          backgroundColor: IosPalette.bgGrouped,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 14),
        IosGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.time_solid, color: _accent, size: 19),
                  const SizedBox(width: 8),
                  const Text(
                    'سجل التمارين المكتملة',
                    style: TextStyle(
                      color: IosPalette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_workoutLogs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'لم يتم تسجيل جلسات مكتملة بعد. اضغط "إنهاء وحفظ تمرين اليوم" بعد تمرينك!',
                      style: TextStyle(
                        color: IosPalette.textMuted,
                        fontSize: 12.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ..._workoutLogs.map((log) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: IosPalette.bgGrouped,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: IosPalette.iosGreen.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            CupertinoIcons.rosette,
                            color: IosPalette.iosGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.dayTitle,
                                style: const TextStyle(
                                  color: IosPalette.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${log.totalSets} جولة • ${log.totalVolumeKg.toStringAsFixed(0)} كجم • ${log.durationMinutes} دقيقة',
                                style: const TextStyle(
                                  color: IosPalette.textMuted,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // TAB 5: التنبيهات الذكية وإعدادات نظام iOS
  // ==========================================================================

  Widget _buildSmartAlertsAndSettingsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
      children: [
        const Text(
          'التنبيهات الذكية والإعدادات',
          style: TextStyle(
            color: IosPalette.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'تنبيهات ذكية لموعد التمرين، انتهاء وقت الراحة، شرب الماء، والمكملات مع تخصيص ألوان نظام iOS.',
          style: TextStyle(
            color: IosPalette.textSecondary,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 16),

        // Instant Test Notification Card
        IosGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.bell_circle_fill,
                      color: _accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مركز التنبيهات الذكية الفورية',
                          style: TextStyle(
                            color: IosPalette.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'اختبر إشعارات الهاتف وتنبيهات Dynamic Island الآن',
                          style: TextStyle(
                            color: IosPalette.textMuted,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              IosPressableButton(
                fullWidth: true,
                color: _accent,
                onPressed: () async {
                  await SmartNotificationService.instance
                      .requestPermissionsSafe();
                  await SmartNotificationService.instance.showSmartNotification(
                    id: 999,
                    title: 'تنبيه ذكي من JOO FIT PRO 💪',
                    body:
                        'تمرينك اليوم هو (${_currentWorkoutDay.title}) ضمن ${_activeSystem.name}!',
                  );
                  _showIosBanner(
                    title: 'تم إرسال التنبيه الذكي بنجاح! 🔔',
                    subtitle: 'تمرين اليوم: ${_currentWorkoutDay.title}',
                    icon: CupertinoIcons.bell_fill,
                    color: _accent,
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.paperplane_fill,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'إرسال تنبيه ذكي تجريبي الآن',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Smart Reminders List (iOS Grouped Settings Style)
        IosGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'جدول التنبيهات الذكية اليومية',
                style: TextStyle(
                  color: IosPalette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ..._smartReminders.map((rem) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: IosPalette.bgGrouped,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  rem.title,
                                  style: const TextStyle(
                                    color: IosPalette.textPrimary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _accent.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    rem.timeLabel,
                                    style: TextStyle(
                                      color: _accent,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              rem.subtitle,
                              style: const TextStyle(
                                color: IosPalette.textMuted,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoSwitch(
                        value: rem.enabled,
                        activeColor: IosPalette.iosGreen,
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          setState(() => rem.enabled = v);
                          _saveAppState();
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // iOS Theme Accent Color Picker
        IosGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تخصيص ألوان أزرار ونظام iOS Cupertino',
                style: TextStyle(
                  color: IosPalette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  IosPalette.accentPresets.length,
                  (index) {
                    final c = IosPalette.accentPresets[index];
                    final name = IosPalette.accentNames[index];
                    final selected = _accentIndex == index;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _accentIndex = index);
                        _saveAppState();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? c.withOpacity(0.22)
                              : IosPalette.bgGrouped,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? c : IosPalette.separator,
                            width: selected ? 1.5 : 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              name,
                              style: TextStyle(
                                color: selected
                                    ? IosPalette.textPrimary
                                    : IosPalette.textSecondary,
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Developer Card (YOSSEF JOO)
        IosGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      CupertinoIcons.shield_fill,
                      color: _accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تطوير وتصميم: YOSSEF JOO',
                          style: TextStyle(
                            color: IosPalette.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'JOO FITNESS PRO • iOS Cupertino Edition • مستقر 100%',
                          style: TextStyle(
                            color: IosPalette.textMuted,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              IosPressableButton(
                fullWidth: true,
                color: IosPalette.cardElevated,
                onPressed: () async {
                  final uri = Uri.parse('https://wa.me/201029892573');
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.chat_bubble_text_fill,
                      color: IosPalette.iosGreen,
                      size: 17,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'تواصل مع المطور عبر واتساب: 01029892573',
                      style: TextStyle(
                        color: IosPalette.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // MODAL SHEETS (ADD EXERCISE & ADD GYM TASK IN iOS CUPERTINO STYLE)
  // ==========================================================================

  void _openAddExerciseToTodaySheet() {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: '4');
    final repsCtrl = TextEditingController(text: '10');
    final weightCtrl = TextEditingController(text: '40');
    final restCtrl = TextEditingController(text: '90');
    String selectedMuscle = 'الصدر';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: IosPalette.cardSurface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: IosPalette.separator,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'إضافة تمرين جديد ليومك الحالي',
                        style: TextStyle(
                          color: IosPalette.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameCtrl,
                        autofocus: true,
                        style: const TextStyle(color: IosPalette.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'اسم التمرين (مثال: تجميع دمبل مستوي)',
                          hintStyle: const TextStyle(
                            color: IosPalette.textMuted,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: IosPalette.bgGrouped,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'الصدر',
                            'الظهر',
                            'الأكتاف',
                            'البايسبس',
                            'الترايسبس',
                            'الأرجل',
                            'البطن',
                          ].map((m) {
                            final sel = selectedMuscle == m;
                            return Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: GestureDetector(
                                onTap: () =>
                                    setSheetState(() => selectedMuscle = m),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sel ? _accent : IosPalette.bgGrouped,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    m,
                                    style: TextStyle(
                                      color: sel
                                          ? Colors.white
                                          : IosPalette.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSheetNumberField(
                              label: 'الجولات',
                              controller: setsCtrl,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSheetNumberField(
                              label: 'العدات',
                              controller: repsCtrl,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSheetNumberField(
                              label: 'الوزن (كجم)',
                              controller: weightCtrl,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildSheetNumberField(
                              label: 'الراحة (ث)',
                              controller: restCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      IosPressableButton(
                        fullWidth: true,
                        color: _accent,
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) return;
                          final sets = int.tryParse(setsCtrl.text) ?? 4;
                          final reps = int.tryParse(repsCtrl.text) ?? 10;
                          final weight =
                              double.tryParse(weightCtrl.text) ?? 40.0;
                          final rest = int.tryParse(restCtrl.text) ?? 90;

                          setState(() {
                            _currentWorkoutDay.isRestDay = false;
                            _currentWorkoutDay.exercises.add(
                              ExerciseItem.create(
                                name: name,
                                muscleGroup: selectedMuscle,
                                setsCount: sets,
                                repsCount: reps,
                                startWeight: weight,
                                restSeconds: rest,
                              ),
                            );
                          });
                          _saveAppState();
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'إضافة التمرين الآن',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetNumberField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: IosPalette.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: IosPalette.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: IosPalette.bgGrouped,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  void _openAddGymTaskSheet() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: IosPalette.cardSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إضافة مهمة أو هدف يومي جديد',
                    style: TextStyle(
                      color: IosPalette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    style: const TextStyle(color: IosPalette.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'مثال: كارديو 15 دقيقة بعد التمرين...',
                      hintStyle: const TextStyle(
                        color: IosPalette.textMuted,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: IosPalette.bgGrouped,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  IosPressableButton(
                    fullWidth: true,
                    color: _accent,
                    onPressed: () {
                      final text = ctrl.text.trim();
                      if (text.isEmpty) return;
                      setState(() {
                        _gymTasks.insert(
                          0,
                          GymTaskItem(
                            id: DateTime.now()
                                .microsecondsSinceEpoch
                                .toString(),
                            title: text,
                            createdAt: DateTime.now(),
                          ),
                        );
                      });
                      _saveAppState();
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'إضافة المهمة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}