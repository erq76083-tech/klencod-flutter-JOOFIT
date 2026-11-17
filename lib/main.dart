import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================================
// 1. نقطة البداية الآمنة وحماية التطبيق من أي أخطاء (JOO SMART GYM PRO)
// ============================================================================

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('JooFit Caught FlutterError: ${details.exceptionAsString()}');
    };

    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: const Color(0xFF0D1017),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF181C26),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2B3142)),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.shield_lefthalf_fill,
                    color: Color(0xFF3B82F6),
                    size: 40,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'التطبيق في أمان يا بطل ومفيش أي بيانات ضاعت',
                    style: TextStyle(
                      color: Color(0xFFF3F4F6),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'تقدر تكمل تمرينك ومتابعتك بكل سلاسة.',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
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

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF0D1017),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    await SmartNotificationService.instance.initSafe();

    runApp(const JooFitEgyptianApp());
  }, (Object error, StackTrace stack) {
    debugPrint('JooFit Zone Guard Caught Error: $error\n$stack');
  });
}

// ============================================================================
// 2. نظام الألوان الذكي والمريح للعين (Dark Matte Eye-Comfort Design)
// ============================================================================

class JooPalette {
  // خلفيات مطفية هادئة ومريحة للعين في إضاءة الجيم أو بالليل
  static const Color bgPrimary = Color(0xFF0D1017);
  static const Color bgGrouped = Color(0xFF131722);
  static const Color cardSurface = Color(0xFF191E2B);
  static const Color cardElevated = Color(0xFF23293A);
  static const Color cardHighlight = Color(0xFF2D354A);
  static const Color separator = Color(0xFF2E364B);

  // ألوان تفاعلية متزنة ومريحة للعين
  static const Color royalBlue = Color(0xFF3B82F6);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color indigoCalm = Color(0xFF6366F1);
  static const Color warmAmber = Color(0xFFF59E0B);
  static const Color coralRed = Color(0xFFEF4444);
  static const Color calmTeal = Color(0xFF14B8A6);
  static const Color softPurple = Color(0xFF8B5CF6);
  static const Color goldStar = Color(0xFFEAB308);

  // ألوان النصوص عالية الوضوح
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFFD1D5DB);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const List<Color> accentPresets = [
    royalBlue,
    emeraldGreen,
    calmTeal,
    indigoCalm,
    warmAmber,
    softPurple,
  ];

  static const List<String> accentNames = [
    'أزرق ملكي مريح',
    'أخضر الطاقة والحيوية',
    'تركواز هادي للعين',
    'نيلي احترافي رايق',
    'ذهبي الحماس',
    'بنفسجي هادي',
  ];
}

// ============================================================================
// 3. محرك أصوات اللمس التفاعلية والاهتزاز الذكي (JooSoundService)
// ============================================================================

class JooSoundService {
  JooSoundService._();
  static final JooSoundService instance = JooSoundService._();

  static const MethodChannel _channel =
      MethodChannel('com.yossefjoo.joofit/sound');

  bool soundEnabled = true;
  bool vibrationEnabled = true;

  Future<void> playTap() async {
    try {
      if (vibrationEnabled) {
        HapticFeedback.lightImpact();
      }
      if (soundEnabled) {
        SystemSound.play(SystemSoundType.click);
        await _channel.invokeMethod('playTap');
      }
    } catch (_) {}
  }

  Future<void> playTick() async {
    try {
      if (vibrationEnabled) {
        HapticFeedback.selectionClick();
      }
      if (soundEnabled) {
        SystemSound.play(SystemSoundType.click);
        await _channel.invokeMethod('playTick');
      }
    } catch (_) {}
  }

  Future<void> playSuccess() async {
    try {
      if (vibrationEnabled) {
        HapticFeedback.mediumImpact();
      }
      if (soundEnabled) {
        SystemSound.play(SystemSoundType.click);
        await _channel.invokeMethod('playSuccess');
      }
    } catch (_) {}
  }

  Future<void> playAlarm() async {
    try {
      if (vibrationEnabled) {
        HapticFeedback.heavyImpact();
      }
      if (soundEnabled) {
        SystemSound.play(SystemSoundType.alert);
        await _channel.invokeMethod('playAlarm');
      }
    } catch (_) {}
  }
}

// ============================================================================
// 4. خدمة الإشعارات والتنبيهات الذكية باللهجة المصرية
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
    String channelId = 'joofit_eg_smart_channel',
    String channelName = 'تنبيهات JOO FIT الذكية',
  }) async {
    try {
      await JooSoundService.instance.playSuccess();
      if (!_initialized) await initSafe();
      if (!_initialized) return;

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'تنبيهات ميعاد التمرين ومؤقت الراحة وتجديد الجيم',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@drawable/ic_launcher',
        color: const Color(0xFF3B82F6),
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
// 5. نماذج البيانات الشاملة (ملف البطل، اشتراك الجيم، الجدول، المتابعة اليومية)
// ============================================================================

const List<String> kEgyptianWeekDays = [
  'السبت',
  'الأحد',
  'الاثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
];

const List<String> kAllMuscleGroups = [
  'الصدر',
  'الظهر',
  'الأكتاف',
  'البايسبس',
  'الترايسبس',
  'الأرجل',
  'البطن',
  'كارديو',
];

int getTodayEgyptianWeekIndex() {
  // DateTime.weekday: Mon=1 .. Fri=5, Sat=6, Sun=7
  // kEgyptianWeekDays: 0=السبت, 1=الأحد, 2=الاثنين, 3=الثلاثاء, 4=الأربعاء, 5=الخميس, 6=الجمعة
  final wd = DateTime.now().weekday;
  if (wd == DateTime.saturday) return 0;
  if (wd == DateTime.sunday) return 1;
  return wd + 1;
}

class UserProfileData {
  String name;
  int age;
  double weightKg;
  double targetWeightKg;
  double heightCm;
  String fitnessGoal; // تضخيم عضلي، تنشيف وحرق دهون، قوة بدنية، لياقة عامة
  int workoutDaysPerWeek;
  List<String> selectedDays;
  String preferredWorkoutTime;
  String gymName;
  String subscriptionType; // شهري، 3 شهور، 6 شهور، سنوي، بالحصة
  double subscriptionPriceEgp;
  DateTime subscriptionStartDate;
  DateTime subscriptionRenewalDate;
  bool onboardingCompleted;

  UserProfileData({
    this.name = '',
    this.age = 22,
    this.weightKg = 75.0,
    this.targetWeightKg = 80.0,
    this.heightCm = 175.0,
    this.fitnessGoal = 'تضخيم عضلي',
    this.workoutDaysPerWeek = 4,
    List<String>? selectedDays,
    this.preferredWorkoutTime = '06:00 مساءً',
    this.gymName = '',
    this.subscriptionType = 'شهري',
    this.subscriptionPriceEgp = 500.0,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionRenewalDate,
    this.onboardingCompleted = false,
  })  : selectedDays = selectedDays ??
            ['السبت', 'الأحد', 'الثلاثاء', 'الخميس'],
        subscriptionStartDate = subscriptionStartDate ?? DateTime.now(),
        subscriptionRenewalDate = subscriptionRenewalDate ??
            DateTime.now().add(const Duration(days: 30));

  double get bmi {
    if (heightCm <= 0) return 22.0;
    final hMeters = heightCm / 100.0;
    return weightKg / (hMeters * hMeters);
  }

  String get bmiStatusEgyptian {
    final b = bmi;
    if (b < 18.5) return 'محتاج تزيد وزن وعضل';
    if (b < 25.0) return 'وزنك مثالي ومظبوط على الشعرة';
    if (b < 30.0) return 'زيادة بسيطة (فرصة ممتازة للتنشيف أو التضخيم الصافي)';
    return 'محتاج تركز على حرق الدهون والكارديو مع الحديد';
  }

  /// حساب السعرات اليومية (Mifflin-St Jeor + معامل النشاط حسب أيام التمرين)
  int get dailyCaloriesTarget {
    final bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    double activityFactor = 1.375;
    if (workoutDaysPerWeek <= 2) {
      activityFactor = 1.3;
    } else if (workoutDaysPerWeek <= 4) {
      activityFactor = 1.5;
    } else if (workoutDaysPerWeek == 5) {
      activityFactor = 1.62;
    } else {
      activityFactor = 1.725;
    }
    final tdee = bmr * activityFactor;
    if (fitnessGoal.contains('تضخيم')) {
      return (tdee + 350).round();
    } else if (fitnessGoal.contains('تنشيف')) {
      return math.max(1400, (tdee - 450).round());
    }
    return tdee.round();
  }

  /// احتياج البروتين اليومي بالجرام (2 جرام لكل كجم)
  int get dailyProteinTargetGrams {
    if (fitnessGoal.contains('تضخيم') || fitnessGoal.contains('تنشيف')) {
      return (weightKg * 2.0).round().clamp(80, 280);
    }
    return (weightKg * 1.8).round().clamp(70, 250);
  }

  /// احتياج الكارب اليومي بالجرام
  int get dailyCarbsTargetGrams {
    final proteinCals = dailyProteinTargetGrams * 4;
    final fatCals = dailyFatsTargetGrams * 9;
    final remCals = math.max(400, dailyCaloriesTarget - proteinCals - fatCals);
    return (remCals / 4).round();
  }

  /// احتياج الدهون الصحية اليومي بالجرام
  int get dailyFatsTargetGrams {
    return (weightKg * 0.9).round().clamp(40, 120);
  }

  /// احتياج الميه اليومي بالأكواب (250 مل)
  int get dailyWaterTargetCups {
    final ml = (weightKg * 40) + (workoutDaysPerWeek * 120);
    return (ml / 250.0).round().clamp(8, 22);
  }

  /// الأيام المتبقية على تجديد اشتراك الجيم
  int get daysUntilGymRenewal {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final renewal = DateTime(
      subscriptionRenewalDate.year,
      subscriptionRenewalDate.month,
      subscriptionRenewalDate.day,
    );
    return renewal.difference(today).inDays;
  }

  double get subscriptionProgress {
    final totalDays = subscriptionRenewalDate
        .difference(subscriptionStartDate)
        .inDays
        .clamp(1, 3650);
    final elapsed = DateTime.now()
        .difference(subscriptionStartDate)
        .inDays
        .clamp(0, totalDays);
    return (elapsed / totalDays).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'weightKg': weightKg,
        'targetWeightKg': targetWeightKg,
        'heightCm': heightCm,
        'fitnessGoal': fitnessGoal,
        'workoutDaysPerWeek': workoutDaysPerWeek,
        'selectedDays': selectedDays,
        'preferredWorkoutTime': preferredWorkoutTime,
        'gymName': gymName,
        'subscriptionType': subscriptionType,
        'subscriptionPriceEgp': subscriptionPriceEgp,
        'subscriptionStartDate': subscriptionStartDate.toIso8601String(),
        'subscriptionRenewalDate': subscriptionRenewalDate.toIso8601String(),
        'onboardingCompleted': onboardingCompleted,
      };

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      name: json['name']?.toString() ?? '',
      age: (json['age'] as num?)?.toInt() ?? 22,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 75.0,
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble() ?? 80.0,
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 175.0,
      fitnessGoal: json['fitnessGoal']?.toString() ?? 'تضخيم عضلي',
      workoutDaysPerWeek: (json['workoutDaysPerWeek'] as num?)?.toInt() ?? 4,
      selectedDays: (json['selectedDays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['السبت', 'الأحد', 'الثلاثاء', 'الخميس'],
      preferredWorkoutTime:
          json['preferredWorkoutTime']?.toString() ?? '06:00 مساءً',
      gymName: json['gymName']?.toString() ?? '',
      subscriptionType: json['subscriptionType']?.toString() ?? 'شهري',
      subscriptionPriceEgp:
          (json['subscriptionPriceEgp'] as num?)?.toDouble() ?? 500.0,
      subscriptionStartDate: DateTime.tryParse(
              json['subscriptionStartDate']?.toString() ?? '') ??
          DateTime.now(),
      subscriptionRenewalDate: DateTime.tryParse(
              json['subscriptionRenewalDate']?.toString() ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
    );
  }
}

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
    this.weightKg = 0.0,
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
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
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
    double startWeight = 0.0,
    int restSeconds = 90,
    String notes = '',
  }) {
    final safeSetsCount = setsCount.clamp(1, 15);
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
  bool get isAllCompleted =>
      sets.isNotEmpty && completedSetsCount == sets.length;

  double get totalVolumeKg => sets
      .where((s) => s.completed)
      .fold(0.0, (sum, s) => sum + (s.weightKg * s.actualReps));

  double get maxWeightKg => sets.isEmpty
      ? 0.0
      : sets.fold(0.0, (maxW, s) => s.weightKg > maxW ? s.weightKg : maxW);

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
      id: json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
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
  String weekDayName; // السبت، الأحد...
  String title;
  String subtitle;
  String scheduledTime; // مثلاً 06:00 مساءً
  List<String> targetMuscles;
  bool isRestDay;
  List<ExerciseItem> exercises;

  WorkoutDay({
    required this.id,
    this.weekDayName = 'السبت',
    required this.title,
    required this.subtitle,
    this.scheduledTime = '06:00 مساءً',
    required this.targetMuscles,
    this.isRestDay = false,
    required this.exercises,
  });

  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.sets.length);

  int get completedSets =>
      exercises.fold(0, (sum, ex) => sum + ex.completedSetsCount);

  double get progress =>
      totalSets == 0 ? (isRestDay ? 1.0 : 0.0) : completedSets / totalSets;

  double get totalVolumeKg =>
      exercises.fold(0.0, (sum, ex) => sum + ex.totalVolumeKg);

  Map<String, dynamic> toJson() => {
        'id': id,
        'weekDayName': weekDayName,
        'title': title,
        'subtitle': subtitle,
        'scheduledTime': scheduledTime,
        'targetMuscles': targetMuscles,
        'isRestDay': isRestDay,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List<dynamic>? ?? [];
    final rawMuscles = json['targetMuscles'] as List<dynamic>? ?? [];
    return WorkoutDay(
      id: json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      weekDayName: json['weekDayName']?.toString() ?? 'السبت',
      title: json['title']?.toString() ?? 'يوم تمرين',
      subtitle: json['subtitle']?.toString() ?? '',
      scheduledTime: json['scheduledTime']?.toString() ?? '06:00 مساءً',
      targetMuscles: rawMuscles.map((e) => e.toString()).toList(),
      isRestDay: json['isRestDay'] as bool? ?? false,
      exercises: rawExercises
          .map(
              (e) => ExerciseItem.fromJson(Map<String, dynamic>.from(e as Map)))
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
      id: json['id']?.toString() ?? 'sys_custom',
      name: json['name']?.toString() ?? 'جدولي الشخصي المفصل',
      category: json['category']?.toString() ?? 'مخصص',
      description: json['description']?.toString() ?? '',
      daysPerWeek: (json['daysPerWeek'] as num?)?.toInt() ?? 4,
      level: json['level']?.toString() ?? 'مخصص للبطل',
      days: rawDays
          .map((d) => WorkoutDay.fromJson(Map<String, dynamic>.from(d as Map)))
          .toList(),
    );
  }

  WorkoutSystem cloneDeep() => WorkoutSystem.fromJson(toJson());
}

class DailyFollowUpLog {
  final String id;
  final DateTime date;
  final String weekDayName;
  final String workoutTitle;
  final int completedExercisesCount;
  final int completedSetsCount;
  final double totalVolumeKg;
  final int durationMinutes;
  final double recordedBodyWeightKg;
  final int waterCups;
  final int proteinGrams;
  final bool creatineTaken;
  final String notes;
  final List<String> trainedMuscles;

  DailyFollowUpLog({
    required this.id,
    required this.date,
    required this.weekDayName,
    required this.workoutTitle,
    required this.completedExercisesCount,
    required this.completedSetsCount,
    required this.totalVolumeKg,
    required this.durationMinutes,
    required this.recordedBodyWeightKg,
    required this.waterCups,
    required this.proteinGrams,
    required this.creatineTaken,
    this.notes = '',
    required this.trainedMuscles,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'weekDayName': weekDayName,
        'workoutTitle': workoutTitle,
        'completedExercisesCount': completedExercisesCount,
        'completedSetsCount': completedSetsCount,
        'totalVolumeKg': totalVolumeKg,
        'durationMinutes': durationMinutes,
        'recordedBodyWeightKg': recordedBodyWeightKg,
        'waterCups': waterCups,
        'proteinGrams': proteinGrams,
        'creatineTaken': creatineTaken,
        'notes': notes,
        'trainedMuscles': trainedMuscles,
      };

  factory DailyFollowUpLog.fromJson(Map<String, dynamic> json) =>
      DailyFollowUpLog(
        id: json['id']?.toString() ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        date:
            DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        weekDayName: json['weekDayName']?.toString() ?? 'اليوم',
        workoutTitle: json['workoutTitle']?.toString() ?? 'تمرين اليوم',
        completedExercisesCount:
            (json['completedExercisesCount'] as num?)?.toInt() ?? 0,
        completedSetsCount: (json['completedSetsCount'] as num?)?.toInt() ?? 0,
        totalVolumeKg: (json['totalVolumeKg'] as num?)?.toDouble() ?? 0.0,
        durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
        recordedBodyWeightKg:
            (json['recordedBodyWeightKg'] as num?)?.toDouble() ?? 75.0,
        waterCups: (json['waterCups'] as num?)?.toInt() ?? 0,
        proteinGrams: (json['proteinGrams'] as num?)?.toInt() ?? 0,
        creatineTaken: json['creatineTaken'] as bool? ?? false,
        notes: json['notes']?.toString() ?? '',
        trainedMuscles: (json['trainedMuscles'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
      );
}

class BodyWeightPoint {
  final DateTime date;
  final double weightKg;

  BodyWeightPoint({required this.date, required this.weightKg});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'weightKg': weightKg,
      };

  factory BodyWeightPoint.fromJson(Map<String, dynamic> json) =>
      BodyWeightPoint(
        date:
            DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 75.0,
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
        timeLabel: json['timeLabel']?.toString() ?? '06:00 مساءً',
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
        id: json['id']?.toString() ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        title: json['title']?.toString() ?? '',
        done: json['done'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}

// ============================================================================
// 6. محرك تنظيم الجداول والتمارين الذكي باللهجة المصرية (SmartScheduleEngine)
// ============================================================================

class ExerciseCatalogEntry {
  final String name;
  final String muscle;
  final String equipment;
  final int defaultSets;
  final int defaultReps;
  final String tipEgyptian;

  const ExerciseCatalogEntry({
    required this.name,
    required this.muscle,
    required this.equipment,
    this.defaultSets = 4,
    this.defaultReps = 10,
    required this.tipEgyptian,
  });
}

class SmartScheduleEngine {
  static const List<ExerciseCatalogEntry> egyptianExerciseCatalog = [
    // الصدر
    ExerciseCatalogEntry(
      name: 'بنش برس مسطح بالبار (Flat Barbell Bench Press)',
      muscle: 'الصدر',
      equipment: 'بار',
      defaultSets: 4,
      defaultReps: 10,
      tipEgyptian: 'ضم لوحين الكتف لورا وانزل بالبار لنص صدرك بتحكم واطلع بقوة.',
    ),
    ExerciseCatalogEntry(
      name: 'تجميع دمبل عالي (Incline Dumbbell Press)',
      muscle: 'الصدر',
      equipment: 'دمبل',
      defaultSets: 4,
      defaultReps: 10,
      tipEgyptian: 'اضبط البنش على زاوية 30 عشان تركز على الصدر العالي من غير ما تحمل على الكتف.',
    ),
    ExerciseCatalogEntry(
      name: 'تفتيح كابل كروس أوفر (Cable Crossover)',
      muscle: 'الصدر',
      equipment: 'كابل',
      defaultSets: 3,
      defaultReps: 12,
      tipEgyptian: 'اتني كوعك سنة بسيطة واثبت ثانية في النص عشان تعصر عضلة الصدر.',
    ),
    ExerciseCatalogEntry(
      name: 'تجميع صدر على الجهاز (Chest Press Machine)',
      muscle: 'الصدر',
      equipment: 'جهاز',
      defaultSets: 3,
      defaultReps: 12,
      tipEgyptian: 'خلي ضهرك لازق في الكرسي وادفع بتركيز في العدات الأخيرة.',
    ),
    ExerciseCatalogEntry(
      name: 'غطس متوازي للصدر السفلي (Chest Dips)',
      muscle: 'الصدر',
      equipment: 'وزن الجسم',
      defaultSets: 3,
      defaultReps: 10,
      tipEgyptian: 'ميل بجسمك لقدام سنة بسيطة عشان تستهدف الصدر السفلي بقوة.',
    ),
    // الظهر
    ExerciseCatalogEntry(
      name: 'سحب عالي أمامي واسع (Lat Pulldown)',
      muscle: 'الظهر',
      equipment: 'كابل',
      defaultSets: 4,
      defaultReps: 10,
      tipEgyptian: 'اسحب بكوعك لتحت ناحية جنابك وافرد صدرك لفوق.',
    ),
    ExerciseCatalogEntry(
      name: 'تجديف بالبار منحني (Barbell Bent-Over Row)',
      muscle: 'الظهر',
      equipment: 'بار',
      defaultSets: 4,
      defaultReps: 10,
      tipEgyptian: 'خلي ضهرك مفرود تماماً واسحب البار ناحية بطنك واعصر المجنص.',
    ),
    ExerciseCatalogEntry(
      name: 'سحب أرضي ضيق (Seated Cable Row)',
      muscle: 'الظهر',
      equipment: 'كابل',
      defaultSets: 4,
      defaultReps: 12,
      tipEgyptian: 'ارجع بكتفك لورا في آخر السحبة واثبت ثانية عشان تتخن عضلات الضهر.',
    ),
    ExerciseCatalogEntry(
      name: 'منشار بالدمبل فردي (One-Arm Dumbbell Row)',
      muscle: 'الظهر',
      equipment: 'دمبل',
      defaultSets: 3,
      defaultReps: 10,
      tipEgyptian: 'اسحب الدمبل ناحية وسطك مش كتفك عشان تعزل المجنص صح.',
    ),
    ExerciseCatalogEntry(
      name: 'عقلة واسع أو بمساعدة (Pull-Ups)',
      muscle: 'الظهر',
      equipment: 'وزن الجسم',
      defaultSets: 3,
      defaultReps: 8,
      tipEgyptian: 'اطلع لحد ما دقنك تعدي البار وانزل بهدوء كامل.',
    ),
    // الأكتاف
    ExerciseCatalogEntry(
      name: 'ضغط أكتاف بالدمبل جالس (Seated Dumbbell Shoulder Press)',
      muscle: 'الأكتاف',
      equipment: 'دمبل',
      defaultSets: 4,
      defaultReps: 10,
      tipEgyptian: 'خلي كوعك داخل لجوه سنة بسيطة (زاوية 75) عشان تحمي مفصل الكتف.',
    ),
    ExerciseCatalogEntry(
      name: 'رفرفة جانبي بالدمبل (Dumbbell Lateral Raises)',
      muscle: 'الأكتاف',
      equipment: 'دمبل',
      defaultSets: 4,
      defaultReps: 15,
      tipEgyptian: 'ارفع بكوعك لحد مستوى الكتف وانزل ببطء من غير مرجحة.',
    ),
    ExerciseCatalogEntry(
      name: 'فيس بول بالحبل للكتف الخلفي (Face Pulls)',
      muscle: 'الأكتاف',
      equipment: 'كابل',
      defaultSets: 4,
      defaultReps: 15,
      tipEgyptian: 'اسحب الحبل ناحية جبهتك وافتح إيدك لبره عشان تشغل الكتف الخلفي.',
    ),
    ExerciseCatalogEntry(
      name: 'ترابيس بالدمبل أو البار (Shrugs)',
      muscle: 'الأكتاف',
      equipment: 'دمبل / بار',
      defaultSets: 3,
      defaultReps: 15,
      tipEgyptian: 'ارفع كتفك لفوق ناحية ودنك واثبت ثانية فوق من غير ما تلف كتفك.',
    ),
    // البايسبس
    ExerciseCatalogEntry(
      name: 'تبادل بايسبس بالبار الزجزاج (EZ-Bar Curl)',
      muscle: 'البايسبس',
      equipment: 'بار زجزاج',
      defaultSets: 4,
      defaultReps: 10,
      tipEgyptian: 'ثبت كوعك في جنبك ومتمرجحش ضهرك خالص.',
    ),
    ExerciseCatalogEntry(
      name: 'هامر كيرل بالدمبل (Hammer Curls)',
      muscle: 'البايسبس',
      equipment: 'دمبل',
      defaultSets: 3,
      defaultReps: 12,
      tipEgyptian: 'ممتاز لتعريض الدراع وتقوية الساعد مع البايسبس.',
    ),
    ExerciseCatalogEntry(
      name: 'بايسبس ارتكاز على الحصان (Preacher Curl)',
      muscle: 'البايسبس',
      equipment: 'جهاز / بار',
      defaultSets: 3,
      defaultReps: 12,
      tipEgyptian: 'بيعزل البايسبس 100% وبيمنع أي غش في الحركة.',
    ),
    // الترايسبس
    ExerciseCatalogEntry(
      name: 'دفع حبل ترايسبس على الكابل (Tricep Rope Pushdown)',
      muscle: 'الترايسبس',
      equipment: 'كابل',
      defaultSets: 4,
      defaultReps: 12,
      tipEgyptian: 'افتح طرفين الحبل لبره في آخر النزلة واعصر الترايسبس.',
    ),
    ExerciseCatalogEntry(
      name: 'فرنساوي بالبار الزجزاج نائم (Skull Crushers)',
      muscle: 'الترايسبس',
      equipment: 'بار زجزاج',
      defaultSets: 3,
      defaultReps: 10,
      tipEgyptian: 'انزل بالبار ورا الجبهة بهدوء وثبت الكوعين.',
    ),
    ExerciseCatalogEntry(
      name: 'ترايسبس دمبل خلف الرأس (Overhead Dumbbell Extension)',
      muscle: 'الترايسبس',
      equipment: 'دمبل',
      defaultSets: 3,
      defaultReps: 12,
      tipEgyptian: 'بيستهدف الرأس الطويلة للترايسبس اللي بتدي ضخامة للدراع.',
    ),
    // الأرجل
    ExerciseCatalogEntry(
      name: 'سكوات بالبار الحر أو سميث (Squats)',
      muscle: 'الأرجل',
      equipment: 'بار',
      defaultSets: 4,
      defaultReps: 10,
      tipEgyptian: 'افرد ضهرك وادفع بكعب رجلك وخلي ركبتك في اتجاه مشط الرجل.',
    ),
    ExerciseCatalogEntry(
      name: 'دفع أرجل على الجهاز (Leg Press)',
      muscle: 'الأرجل',
      equipment: 'جهاز',
      defaultSets: 4,
      defaultReps: 12,
      tipEgyptian: 'متقفلش ركبتك للأخر وإنت بتزق عشان تحافظ على المفصل.',
    ),
    ExerciseCatalogEntry(
      name: 'رفرفة رجل أمامي (Leg Extension)',
      muscle: 'الأرجل',
      equipment: 'جهاز',
      defaultSets: 3,
      defaultReps: 15,
      tipEgyptian: 'اثبت ثانية فوق في كل عدة عشان تفصّل عضلة الفخذ الأمامية.',
    ),
    ExerciseCatalogEntry(
      name: 'رفرفة رجل خلفي (Seated / Lying Leg Curl)',
      muscle: 'الأرجل',
      equipment: 'جهاز',
      defaultSets: 3,
      defaultReps: 12,
      tipEgyptian: 'انزل بالوزن ببطء عشان تستهدف الخلفيات بأقصى كفاءة.',
    ),
    ExerciseCatalogEntry(
      name: 'سمانة واقف أو جالس (Calf Raises)',
      muscle: 'الأرجل',
      equipment: 'جهاز / دمبل',
      defaultSets: 4,
      defaultReps: 20,
      tipEgyptian: 'اطلع لأقصى مدى فوق واثبت ثانيتين في كل عدة.',
    ),
    // البطن والكارديو
    ExerciseCatalogEntry(
      name: 'طحن بطن على الكابل (Cable Crunch)',
      muscle: 'البطن',
      equipment: 'كابل',
      defaultSets: 4,
      defaultReps: 15,
      tipEgyptian: 'اعصر عضلات بطنك لتحت وطلع الزفير في آخر النزلة.',
    ),
    ExerciseCatalogEntry(
      name: 'رفع أرجل متوازي للبطن السفلي (Hanging Leg Raises)',
      muscle: 'البطن',
      equipment: 'وزن الجسم',
      defaultSets: 3,
      defaultReps: 15,
      tipEgyptian: 'ارفع ركبتك ناحية صدرك بتحكم من غير مرجحة.',
    ),
    ExerciseCatalogEntry(
      name: 'مشاية أو عجلة كارديو (Treadmill / Cardio)',
      muscle: 'كارديو',
      equipment: 'جهاز كارديو',
      defaultSets: 1,
      defaultReps: 20,
      tipEgyptian: 'مشي سريع بميل خفيف بعد التمرين بيحرق دهون صافي ويحافظ على العضل.',
    ),
  ];

  /// بناء جدول الـ 7 أيام الافتراضي النظيف بناءً على الأيام اللي اختارها البطل
  static List<WorkoutDay> createInitialSevenDays({
    required List<String> selectedTrainingDays,
    required String defaultTime,
    required String goal,
  }) {
    // توزيع ذكي للعضلات على الأيام المختارة
    final splitsByCount = <int, List<(String, List<String>)>>{
      1: [
        ('جسم كامل شامل (Full Body)', ['الصدر', 'الظهر', 'الأكتاف', 'الأرجل']),
      ],
      2: [
        ('جزء علوي كامل (Upper Body)', ['الصدر', 'الظهر', 'الأكتاف', 'البايسبس', 'الترايسبس']),
        ('جزء سفلي وبطن (Lower Body & Core)', ['الأرجل', 'البطن']),
      ],
      3: [
        ('دفع: صدر + أكتاف + ترايسبس (Push)', ['الصدر', 'الأكتاف', 'الترايسبس']),
        ('سحب: ظهر + بايسبس (Pull)', ['الظهر', 'البايسبس']),
        ('أرجل كامل + بطن (Legs & Abs)', ['الأرجل', 'البطن']),
      ],
      4: [
        ('صدر + ترايسبس', ['الصدر', 'الترايسبس']),
        ('ظهر + بايسبس', ['الظهر', 'البايسبس']),
        ('أكتاف + بطن', ['الأكتاف', 'البطن']),
        ('أرجل كامل (أماميات وخلفيات وسمانة)', ['الأرجل']),
      ],
      5: [
        ('يوم الصدر + بطن', ['الصدر', 'البطن']),
        ('يوم الظهر + ترابيس', ['الظهر']),
        ('يوم الأكتاف + بطن', ['الأكتاف', 'البطن']),
        ('يوم الدراع كامل (بايسبس + ترايسبس)', ['البايسبس', 'الترايسبس']),
        ('يوم الأرجل الشامل', ['الأرجل']),
      ],
      6: [
        ('دفع 1: صدر + أكتاف + ترايسبس', ['الصدر', 'الأكتاف', 'الترايسبس']),
        ('سحب 1: ظهر + بايسبس', ['الظهر', 'البايسبس']),
        ('أرجل 1 + بطن', ['الأرجل', 'البطن']),
        ('دفع 2: تركيز الكتف والصدر العالي + تراي', ['الصدر', 'الأكتاف', 'الترايسبس']),
        ('سحب 2: كثافة الظهر + بايسبس', ['الظهر', 'البايسبس']),
        ('أرجل 2 + كارديو وبطن', ['الأرجل', 'البطن', 'كارديو']),
      ],
      7: [
        ('صدر', ['الصدر']),
        ('ظهر', ['الظهر']),
        ('أكتاف', ['الأكتاف']),
        ('بايسبس + ترايسبس', ['البايسبس', 'الترايسبس']),
        ('أرجل أمامي وسمانة', ['الأرجل']),
        ('أرجل خلفي وبطن', ['الأرجل', 'البطن']),
        ('كارديو ومرونة واستشفاء نشط', ['كارديو', 'البطن']),
      ],
    };

    final count = selectedTrainingDays.length.clamp(1, 7);
    final templateList = splitsByCount[count] ?? splitsByCount[4]!;
    int activeIdx = 0;

    return List.generate(kEgyptianWeekDays.length, (i) {
      final wDay = kEgyptianWeekDays[i];
      final isTraining = selectedTrainingDays.contains(wDay);
      if (!isTraining) {
        return WorkoutDay(
          id: 'day_$i',
          weekDayName: wDay,
          title: '$wDay: يوم راحة واستشفاء عضلي',
          subtitle: 'راحة من الحديد لبناء الألياف العضلية',
          scheduledTime: defaultTime,
          targetMuscles: [],
          isRestDay: true,
          exercises: [],
        );
      }

      final tpl = templateList[activeIdx % templateList.length];
      activeIdx++;
      final muscles = List<String>.from(tpl.$2);
      final exercises = generateDefaultExercisesForMuscles(
        muscles,
        goal: goal,
      );

      return WorkoutDay(
        id: 'day_$i',
        weekDayName: wDay,
        title: '$wDay: ${tpl.$1}',
        subtitle: 'العضلات: ${muscles.join(" + ")}',
        scheduledTime: defaultTime,
        targetMuscles: muscles,
        isRestDay: false,
        exercises: exercises,
      );
    });
  }

  static List<ExerciseItem> generateDefaultExercisesForMuscles(
    List<String> muscles, {
    String goal = 'تضخيم عضلي',
  }) {
    final int reps = goal.contains('قوة')
        ? 6
        : (goal.contains('تنشيف') ? 12 : 10);
    final int rest = goal.contains('قوة')
        ? 120
        : (goal.contains('تنشيف') ? 60 : 90);

    final List<ExerciseItem> list = [];
    for (final m in muscles) {
      final matches = egyptianExerciseCatalog
          .where((c) => c.muscle == m)
          .take(m == 'الصدر' || m == 'الظهر' || m == 'الأرجل' ? 3 : 2);
      for (final item in matches) {
        list.add(
          ExerciseItem.create(
            name: item.name,
            muscleGroup: item.muscle,
            equipment: item.equipment,
            setsCount: item.defaultSets,
            repsCount: item.muscle == 'كارديو' ? 20 : reps,
            startWeight: 0.0,
            restSeconds: rest,
            notes: item.tipEgyptian,
          ),
        );
      }
    }
    return list;
  }

  /// محلل النصوص الذكي باللهجة المصرية (لو المستخدم كتب جدوله نصياً)
  static WorkoutSystem parseCustomScheduleText(
    String rawText, {
    String defaultTime = '06:00 مساءً',
  }) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final Map<String, WorkoutDay> byWeekDay = {
      for (var i = 0; i < kEgyptianWeekDays.length; i++)
        kEgyptianWeekDays[i]: WorkoutDay(
          id: 'parsed_$i',
          weekDayName: kEgyptianWeekDays[i],
          title: '${kEgyptianWeekDays[i]}: يوم راحة واستشفاء',
          subtitle: 'يوم راحة',
          scheduledTime: defaultTime,
          targetMuscles: [],
          isRestDay: true,
          exercises: [],
        ),
    };

    String currentDayKey = 'السبت';

    for (final line in lines) {
      String? matchedDay;
      for (final d in kEgyptianWeekDays) {
        if (line.contains(d) ||
            (d == 'الأحد' && line.contains('الاحد')) ||
            (d == 'الاثنين' && line.contains('الإثنين')) ||
            (d == 'الأربعاء' && line.contains('الاربعاء'))) {
          matchedDay = d;
          break;
        }
      }

      if (matchedDay != null) {
        currentDayKey = matchedDay;
        final isRest = line.contains('راحة') || line.contains('اجازة') || line.contains('إجازة');
        final muscles = detectMusclesFromText(line);
        final dObj = byWeekDay[currentDayKey]!;
        dObj.isRestDay = isRest;
        if (!isRest) {
          dObj.targetMuscles = muscles.isEmpty ? ['عام'] : muscles;
          dObj.title = '$currentDayKey: ${dObj.targetMuscles.join(" + ")}';
          dObj.subtitle = line;
          if (dObj.exercises.isEmpty && muscles.isNotEmpty) {
            dObj.exercises = generateDefaultExercisesForMuscles(muscles);
          }
        }
      } else {
        // سطر تمرين مثل: بنش مسطح 4 في 10
        final dObj = byWeekDay[currentDayKey]!;
        dObj.isRestDay = false;
        final ex = parseSingleExerciseLine(line);
        dObj.exercises.add(ex);
        if (!dObj.targetMuscles.contains(ex.muscleGroup)) {
          dObj.targetMuscles.add(ex.muscleGroup);
        }
        dObj.title = '$currentDayKey: ${dObj.targetMuscles.join(" + ")}';
        dObj.subtitle = '${dObj.exercises.length} تمارين مسجلة';
      }
    }

    final daysList = kEgyptianWeekDays.map((k) => byWeekDay[k]!).toList();
    final trainingCount = daysList.where((d) => !d.isRestDay).length;

    return WorkoutSystem(
      id: 'sys_parsed_${DateTime.now().millisecondsSinceEpoch}',
      name: 'جدولي المتنظم بالمحلل الذكي',
      category: 'مخصص 7 أيام',
      description: 'تم تنظيمه تلقائياً حسب تقسيمتك وأيامك',
      daysPerWeek: trainingCount == 0 ? 4 : trainingCount,
      level: 'مخصص للبطل',
      days: daysList,
    );
  }

  static ExerciseItem parseSingleExerciseLine(String line) {
    final clean = line.replaceAll(RegExp(r'^[-*•\d.)]+\s*'), '').trim();
    int sets = 4;
    int reps = 10;

    final match = RegExp(r"""(\d+)\s*[xX×*في]\s*(\d+)""").firstMatch(clean);
    if (match != null) {
      sets = int.tryParse(match.group(1) ?? '4') ?? 4;
      reps = int.tryParse(match.group(2) ?? '10') ?? 10;
    } else {
      final setsMatch =
          RegExp(r"""(\d+)\s*(?:مجموعات|مجاميع|جولات|مجموعة)""").firstMatch(clean);
      final repsMatch =
          RegExp(r"""(\d+)\s*(?:عدات|عدة|تكرار)""").firstMatch(clean);
      if (setsMatch != null) {
        sets = int.tryParse(setsMatch.group(1) ?? '4') ?? 4;
      }
      if (repsMatch != null) {
        reps = int.tryParse(repsMatch.group(1) ?? '10') ?? 10;
      }
    }

    final muscles = detectMusclesFromText(clean);
    final muscle = muscles.isNotEmpty ? muscles.first : 'عام';

    return ExerciseItem.create(
      name: clean,
      muscleGroup: muscle,
      setsCount: sets.clamp(1, 12),
      repsCount: reps.clamp(1, 50),
      startWeight: 0.0,
      restSeconds: 90,
      notes: 'متضاف من جدولك الخاص',
    );
  }

  static List<String> detectMusclesFromText(String input) {
    final s = input.toLowerCase();
    final List<String> muscles = [];
    if (s.contains('صدر') || s.contains('بنش') || s.contains('تفتيح') || s.contains('غطس')) {
      muscles.add('الصدر');
    }
    if (s.contains('ظهر') || s.contains('ضهر') || s.contains('سحب') || s.contains('مجنص') || s.contains('عقلة') || s.contains('منشار')) {
      muscles.add('الظهر');
    }
    if (s.contains('كتف') || s.contains('أكتاف') || s.contains('اكتاف') || s.contains('رفرفة') || s.contains('ترابيس')) {
      muscles.add('الأكتاف');
    }
    if (s.contains('باي') || s.contains('تبادل') || s.contains('هامر') || s.contains('دراع') || s.contains('ذراع')) {
      muscles.add('البايسبس');
    }
    if (s.contains('تراي') || s.contains('فرنساوي') || s.contains('حبل') || s.contains('دراع') || s.contains('ذراع')) {
      muscles.add('الترايسبس');
    }
    if (s.contains('رجل') || s.contains('أرجل') || s.contains('ارجل') || s.contains('سكوات') || s.contains('دفش') || s.contains('سمانة')) {
      muscles.add('الأرجل');
    }
    if (s.contains('بطن') || s.contains('بلانك')) {
      muscles.add('البطن');
    }
    if (s.contains('كارديو') || s.contains('مشاية') || s.contains('جري')) {
      muscles.add('كارديو');
    }
    return muscles;
  }

  static List<WorkoutSystem> getEgyptianProTemplates(String defaultTime) {
    return [
      WorkoutSystem(
        id: 'tpl_ppl',
        name: 'نظام دفع / سحب / رجل (Push Pull Legs)',
        category: 'PPL - 6 أيام',
        description: 'أقوى نظام لتضخيم العضلات وتمرين كل عضلة مرتين في الأسبوع.',
        daysPerWeek: 6,
        level: 'متوسط - وحش',
        days: createInitialSevenDays(
          selectedTrainingDays: ['السبت', 'الأحد', 'الاثنين', 'الأربعاء', 'الخميس', 'الجمعة'],
          defaultTime: defaultTime,
          goal: 'تضخيم عضلي',
        ),
      ),
      WorkoutSystem(
        id: 'tpl_bro5',
        name: 'نظام عضلة كل يوم (Bro Split المصري)',
        category: '5 أيام تركيز عالي',
        description: 'صدر، ظهر، أكتاف، دراع كامل، ورجل مع يومين راحة واستشفاء.',
        daysPerWeek: 5,
        level: 'كل المستويات',
        days: createInitialSevenDays(
          selectedTrainingDays: ['السبت', 'الأحد', 'الاثنين', 'الأربعاء', 'الخميس'],
          defaultTime: defaultTime,
          goal: 'تضخيم عضلي',
        ),
      ),
      WorkoutSystem(
        id: 'tpl_ul4',
        name: 'نظام علوي / سفلي 4 أيام (Upper / Lower)',
        category: '4 أيام متوازن',
        description: 'ممتاز لو بتروح الجيم 4 أيام في الأسبوع وعايز توازن بين القوة والضخامة.',
        daysPerWeek: 4,
        level: 'مبتدئ - متوسط',
        days: createInitialSevenDays(
          selectedTrainingDays: ['السبت', 'الأحد', 'الثلاثاء', 'الخميس'],
          defaultTime: defaultTime,
          goal: 'تضخيم عضلي',
        ),
      ),
      WorkoutSystem(
        id: 'tpl_fb3',
        name: 'نظام 3 أيام شامل (دفع / سحب / رجل)',
        category: '3 أيام في الأسبوع',
        description: 'مثالي لو وقتك مشغول وبتتمرن 3 أيام بس في الأسبوع بتركيز عالي.',
        daysPerWeek: 3,
        level: 'كل المستويات',
        days: createInitialSevenDays(
          selectedTrainingDays: ['السبت', 'الاثنين', 'الأربعاء'],
          defaultTime: defaultTime,
          goal: 'تضخيم عضلي',
        ),
      ),
    ];
  }
}

// ============================================================================
// 7. التطبيق الرئيسي والعناصر التفاعلية المريحة للعين
// ============================================================================

class JooFitEgyptianApp extends StatelessWidget {
  const JooFitEgyptianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JOOFIT PRO',
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
        scaffoldBackgroundColor: JooPalette.bgPrimary,
        cupertinoOverrideTheme: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: JooPalette.royalBlue,
          scaffoldBackgroundColor: JooPalette.bgPrimary,
          barBackgroundColor: Color(0xCC131722),
        ),
        colorScheme: const ColorScheme.dark(
          primary: JooPalette.royalBlue,
          secondary: JooPalette.emeraldGreen,
          surface: JooPalette.cardSurface,
          error: JooPalette.coralRed,
          onPrimary: Colors.white,
          onSurface: JooPalette.textPrimary,
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

class JooPressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool fullWidth;

  const JooPressableButton({
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
  State<JooPressableButton> createState() => _JooPressableButtonState();
}

class _JooPressableButtonState extends State<JooPressableButton> {
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
              JooSoundService.instance.playTap();
              widget.onPressed!();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.84 : 1.0,
          duration: const Duration(milliseconds: 110),
          child: Container(
            width: widget.fullWidth ? double.infinity : null,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.color ?? JooPalette.royalBlue,
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

class JooGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? tintColor;
  final Color? borderColor;

  const JooGlassCard({
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
      padding: padding,
      decoration: BoxDecoration(
        color: tintColor ?? JooPalette.cardSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? JooPalette.separator.withOpacity(0.65),
          width: 0.9,
        ),
      ),
      child: child,
    );
  }
}

class ActivityRingsPainter extends CustomPainter {
  final double outerProgress;
  final double middleProgress;
  final double innerProgress;
  final Color accentColor;

  ActivityRingsPainter({
    required this.outerProgress,
    required this.middleProgress,
    required this.innerProgress,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 10.5;
    const gap = 4.0;

    final outerRadius = (size.width / 2) - (strokeWidth / 2);
    final middleRadius = outerRadius - strokeWidth - gap;
    final innerRadius = middleRadius - strokeWidth - gap;

    _drawRing(
      canvas,
      center,
      outerRadius,
      strokeWidth,
      outerProgress,
      JooPalette.emeraldGreen,
    );
    _drawRing(
      canvas,
      center,
      middleRadius,
      strokeWidth,
      middleProgress,
      accentColor,
    );
    _drawRing(
      canvas,
      center,
      innerRadius,
      strokeWidth,
      innerProgress,
      JooPalette.calmTeal,
    );
  }

  void _drawRing(
    Canvas canvas,
    Offset center,
    double radius,
    double stroke,
    double progress,
    Color color,
  ) {
    final trackPaint = Paint()
      ..color = color.withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final clamped = progress.clamp(0.02, 1.0);
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * clamped,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ActivityRingsPainter oldDelegate) {
    return oldDelegate.outerProgress != outerProgress ||
        oldDelegate.middleProgress != middleProgress ||
        oldDelegate.innerProgress != innerProgress ||
        oldDelegate.accentColor != accentColor;
  }
}

class CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color activeColor;

  CircularTimerPainter({
    required this.progress,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 14;

    final tickPaint = Paint()
      ..color = JooPalette.separator.withOpacity(0.6)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = (i * 6) * (math.pi / 180);
      final isMajor = i % 5 == 0;
      final outer = radius + 8;
      final inner = radius + (isMajor ? 2 : 5);
      tickPaint.color = isMajor
          ? JooPalette.textMuted.withOpacity(0.55)
          : JooPalette.separator.withOpacity(0.35);
      canvas.drawLine(
        Offset(
          center.dx + outer * math.cos(angle),
          center.dy + outer * math.sin(angle),
        ),
        Offset(
          center.dx + inner * math.cos(angle),
          center.dy + inner * math.sin(angle),
        ),
        tickPaint,
      );
    }

    final bgRing = Paint()
      ..color = JooPalette.cardElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius - 8, bgRing);

    final fgRing = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      fgRing,
    );
  }

  @override
  bool shouldRepaint(covariant CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor;
  }
}

// ============================================================================
// 8. الغلاف الرئيسي للتطبيق (إدارة الحالة، شاشة البداية، التبويبات الـ 5)
// ============================================================================

class JooFitMainShell extends StatefulWidget {
  const JooFitMainShell({super.key});

  @override
  State<JooFitMainShell> createState() => _JooFitMainShellState();
}

class _JooFitMainShellState extends State<JooFitMainShell>
    with WidgetsBindingObserver {
  // مفتاح تخزين نظيف بالكامل بدون أي بيانات تجريبية سابقة
  static const String _storageKeyV3 = 'joofit_egyptian_pro_state_v3';

  int _currentTabIndex = 0;
  bool _isLoading = true;
  int _accentIndex = 0;

  // ملف المستخدم واشتراك الجيم
  UserProfileData _profile = UserProfileData();

  // الجدول النشط ويوم الأسبوع المحدد
  late WorkoutSystem _activeSystem;
  int _activeDayIndex = getTodayEgyptianWeekIndex();
  bool _isWorkoutSessionActive = false;
  DateTime? _workoutSessionStart;
  int _workoutElapsedSeconds = 0;

  // المؤقتات (0: مؤقت الراحة، 1: تاباتا، 2: ستوب ووتش)
  int _timerMode = 0;
  int _restTotalSeconds = 90;
  int _restRemainingSeconds = 90;
  bool _restRunning = false;
  bool _autoStartRestOnSet = true;
  String _restCurrentExerciseName = 'استعداد للمجموعة الجاية';

  int _tabataWorkSec = 40;
  int _tabataRestSec = 20;
  int _tabataTotalRounds = 8;
  int _tabataCurrentRound = 1;
  bool _tabataIsWorkPhase = true;
  int _tabataRemainingSec = 40;
  bool _tabataRunning = false;

  int _stopwatchDeciSeconds = 0;
  bool _stopwatchRunning = false;
  final List<int> _stopwatchLaps = [];

  Timer? _masterTicker;

  // المتابعة اليومية الحقيقية (تبدأ من صفر بدون أي أرقام تجريبية)
  int _waterCupsToday = 0;
  int _proteinGramsToday = 0;
  bool _creatineTakenToday = false;
  String _lastDailyResetDateKey = '';

  // السجلات والمهام والتنبيهات
  final List<DailyFollowUpLog> _dailyFollowUpLogs = [];
  final List<BodyWeightPoint> _weightHistory = [];
  final List<GymTaskItem> _gymTasks = [];
  final List<SmartReminder> _smartReminders = [];
  final Map<String, DateTime> _muscleLastTrained = {};

  // بانر التنبيه الذكي العلوي
  String? _bannerTitle;
  String? _bannerSubtitle;
  IconData _bannerIcon = CupertinoIcons.bell_fill;
  Color _bannerColor = JooPalette.royalBlue;
  Timer? _bannerHideTimer;

  // أدوات الجيم الذكية
  int _toolsSubTab = 0; // 0: المتابعة والسجل، 1: حاسبة الطارات والسعرات و1RM، 2: موسوعة التمارين
  double _calcWeightKg = 60.0;
  int _calcReps = 8;
  double _plateTargetWeightKg = 80.0;
  double _plateBarWeightKg = 20.0;
  String _selectedMuscleFilter = 'الكل';
  String _exerciseSearchQuery = '';

  // تبويب الجدول الذكي
  int _scheduleSubTab = 0; // 0: تعديل جدولي يوم بيوم، 1: المحلل النصي الذكي، 2: قوالب جاهزة

  final TextEditingController _smartScheduleInputCtrl = TextEditingController();

  Color get _accent =>
      JooPalette.accentPresets[_accentIndex % JooPalette.accentPresets.length];

  WorkoutDay get _currentWorkoutDay {
    if (_activeSystem.days.isEmpty) {
      _activeSystem.days = SmartScheduleEngine.createInitialSevenDays(
        selectedTrainingDays: _profile.selectedDays,
        defaultTime: _profile.preferredWorkoutTime,
        goal: _profile.fitnessGoal,
      );
    }
    final safeIdx = _activeDayIndex.clamp(0, _activeSystem.days.length - 1);
    return _activeSystem.days[safeIdx];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activeSystem = WorkoutSystem(
      id: 'sys_custom_eg',
      name: 'جدولي الأسبوعي المفصل',
      category: 'مخصص 7 أيام',
      description: 'جدول متفصل على مقاسك ومواعيدك',
      daysPerWeek: 4,
      level: 'بطل الجيم',
      days: SmartScheduleEngine.createInitialSevenDays(
        selectedTrainingDays: _profile.selectedDays,
        defaultTime: _profile.preferredWorkoutTime,
        goal: _profile.fitnessGoal,
      ),
    );
    _initDefaultReminders();
    _loadAppState();
    _startMasterTicker();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _masterTicker?.cancel();
    _bannerHideTimer?.cancel();
    _smartScheduleInputCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveAppState();
    }
  }

  String _todayDateKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}';
  }

  void _initDefaultReminders() {
    _smartReminders.clear();
    _smartReminders.addAll([
      SmartReminder(
        id: 'rem_workout',
        title: 'تذكير ميعاد التمرين اليومي',
        subtitle: 'يفكرك باسم تمرين النهاردة والعضلات والمجموعات اللي عليك',
        timeLabel: _profile.preferredWorkoutTime,
        enabled: true,
        category: 'workout',
      ),
      SmartReminder(
        id: 'rem_gym_renewal',
        title: 'تنبيه ميعاد تجديد اشتراك الجيم',
        subtitle: 'ينبهك قبل ما اشتراك الجيم يخلص عشان تجدد في ميعادك',
        timeLabel: 'تلقائي',
        enabled: true,
        category: 'subscription',
      ),
      SmartReminder(
        id: 'rem_rest_timer',
        title: 'تنبيه انتهاء الراحة بين المجموعات',
        subtitle: 'صوت واهتزاز أول ما وقت الراحة يخلص عشان تدخل المجموعة الجاية',
        timeLabel: 'تلقائي',
        enabled: true,
        category: 'timer',
      ),
      SmartReminder(
        id: 'rem_water',
        title: 'تذكير شرب الميه والترطيب',
        subtitle: 'يفكرك تشرب ميه بانتظام عشان تحافظ على البامب والأداء',
        timeLabel: 'كل ساعتين',
        enabled: true,
        category: 'hydration',
      ),
      SmartReminder(
        id: 'rem_protein',
        title: 'تذكير وجبة بعد التمرين والبروتين',
        subtitle: 'عشان تغذي العضلات وتعمل استشفاء صح بعد الجيم',
        timeLabel: 'بعد التمرين',
        enabled: true,
        category: 'nutrition',
      ),
      SmartReminder(
        id: 'rem_creatine',
        title: 'تذكير جرعة الكرياتين (5 جرام)',
        subtitle: 'متنساش جرعة الكرياتين اليومية مع ميه كفاية',
        timeLabel: 'يومياً',
        enabled: true,
        category: 'supplement',
      ),
    ]);
  }

  Future<void> _loadAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawState = prefs.getString(_storageKeyV3);

      if (rawState != null && rawState.isNotEmpty) {
        final map = jsonDecode(rawState) as Map<String, dynamic>;
        _accentIndex = (map['accentIndex'] as num?)?.toInt() ?? 0;
        JooSoundService.instance.soundEnabled =
            map['soundEnabled'] as bool? ?? true;
        JooSoundService.instance.vibrationEnabled =
            map['vibrationEnabled'] as bool? ?? true;
        _restTotalSeconds = (map['restTotalSeconds'] as num?)?.toInt() ?? 90;
        _restRemainingSeconds = _restTotalSeconds;
        _autoStartRestOnSet = map['autoStartRestOnSet'] as bool? ?? true;

        if (map['profile'] is Map) {
          _profile = UserProfileData.fromJson(
            Map<String, dynamic>.from(map['profile'] as Map),
          );
        }

        if (map['activeSystem'] is Map) {
          _activeSystem = WorkoutSystem.fromJson(
            Map<String, dynamic>.from(map['activeSystem'] as Map),
          );
        }

        // ضبط اليوم تلقائياً على يوم الأسبوع الحالي لو المستخدم فتح في يوم جديد
        final savedDateKey = map['lastDailyResetDateKey']?.toString() ?? '';
        final currentKey = _todayDateKey();
        _lastDailyResetDateKey = currentKey;

        if (savedDateKey == currentKey) {
          _activeDayIndex = (map['activeDayIndex'] as num?)?.toInt() ??
              getTodayEgyptianWeekIndex();
          _waterCupsToday = (map['waterCupsToday'] as num?)?.toInt() ?? 0;
          _proteinGramsToday = (map['proteinGramsToday'] as num?)?.toInt() ?? 0;
          _creatineTakenToday = map['creatineTakenToday'] as bool? ?? false;
        } else {
          // يوم جديد: نصفر عدادات اليوم ونوجهه لتمرين النهاردة!
          _activeDayIndex = getTodayEgyptianWeekIndex();
          _waterCupsToday = 0;
          _proteinGramsToday = 0;
          _creatineTakenToday = false;
          for (final d in _activeSystem.days) {
            for (final ex in d.exercises) {
              for (final s in ex.sets) {
                s.completed = false;
              }
            }
          }
        }

        if (map['dailyFollowUpLogs'] is List) {
          _dailyFollowUpLogs.clear();
          for (final l in (map['dailyFollowUpLogs'] as List)) {
            if (l is Map) {
              _dailyFollowUpLogs.add(
                DailyFollowUpLog.fromJson(Map<String, dynamic>.from(l)),
              );
            }
          }
        }

        if (map['weightHistory'] is List) {
          _weightHistory.clear();
          for (final w in (map['weightHistory'] as List)) {
            if (w is Map) {
              _weightHistory.add(
                BodyWeightPoint.fromJson(Map<String, dynamic>.from(w)),
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
          final mMap =
              Map<String, dynamic>.from(map['muscleLastTrained'] as Map);
          mMap.forEach((k, v) {
            final dt = DateTime.tryParse(v.toString());
            if (dt != null) _muscleLastTrained[k] = dt;
          });
        }
      } else {
        _lastDailyResetDateKey = _todayDateKey();
      }
    } catch (e) {
      debugPrint('Safe state load fallback: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
      // لو المستخدم خلص الإعداد، نرحب بيه ونفكره بتمرين النهاردة وميعاد التجديد لو قرب
      if (_profile.onboardingCompleted) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          _checkDailySmartGreetingAndAlerts();
        });
      }
    }
  }

  void _checkDailySmartGreetingAndAlerts() {
    final daysLeft = _profile.daysUntilGymRenewal;
    final todayDay = _currentWorkoutDay;
    if (daysLeft <= 3) {
      final msg = daysLeft < 0
          ? 'اشتراك الجيم بتاعك انتهى! متنساش تجدد عشان متوقفش تمرينك 💪'
          : (daysLeft == 0
              ? 'النهاردة ميعاد تجديد اشتراك الجيم بتاعك!'
              : 'فاضل $daysLeft أيام بس على تجديد اشتراك الجيم (${_profile.gymName.isEmpty ? "الجيم" : _profile.gymName})');
      _showSmartBanner(
        title: 'تذكير تجديد اشتراك الجيم 🔔',
        subtitle: msg,
        icon: CupertinoIcons.calendar_badge_exclamationmark,
        color: JooPalette.warmAmber,
      );
      SmartNotificationService.instance.showSmartNotification(
        id: 202,
        title: 'تذكير اشتراك الجيم يا ${_profile.name} 🔔',
        body: msg,
      );
    } else if (!todayDay.isRestDay) {
      _showSmartBanner(
        title: 'منور يا ${_profile.name}! جاهز لتمرين النهاردة؟ 🔥',
        subtitle: '${todayDay.title} • الميعاد: ${todayDay.scheduledTime}',
        icon: CupertinoIcons.flame_fill,
        color: _accent,
      );
    }
  }

  Future<void> _saveAppState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = {
        'accentIndex': _accentIndex,
        'soundEnabled': JooSoundService.instance.soundEnabled,
        'vibrationEnabled': JooSoundService.instance.vibrationEnabled,
        'activeDayIndex': _activeDayIndex,
        'restTotalSeconds': _restTotalSeconds,
        'autoStartRestOnSet': _autoStartRestOnSet,
        'waterCupsToday': _waterCupsToday,
        'proteinGramsToday': _proteinGramsToday,
        'creatineTakenToday': _creatineTakenToday,
        'lastDailyResetDateKey': _todayDateKey(),
        'profile': _profile.toJson(),
        'activeSystem': _activeSystem.toJson(),
        'dailyFollowUpLogs':
            _dailyFollowUpLogs.map((l) => l.toJson()).toList(),
        'weightHistory': _weightHistory.map((w) => w.toJson()).toList(),
        'gymTasks': _gymTasks.map((t) => t.toJson()).toList(),
        'smartReminders': _smartReminders.map((r) => r.toJson()).toList(),
        'muscleLastTrained': _muscleLastTrained.map(
          (k, v) => MapEntry(k, v.toIso8601String()),
        ),
      };
      await prefs.setString(_storageKeyV3, jsonEncode(map));
    } catch (e) {
      debugPrint('Safe state save fallback: $e');
    }
  }

  void _startMasterTicker() {
    _masterTicker?.cancel();
    _masterTicker = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      bool needsRebuild = false;

      if (_stopwatchRunning) {
        _stopwatchDeciSeconds++;
        needsRebuild = true;
      }

      if (timer.tick % 10 == 0) {
        if (_isWorkoutSessionActive && _workoutSessionStart != null) {
          _workoutElapsedSeconds =
              DateTime.now().difference(_workoutSessionStart!).inSeconds;
          needsRebuild = true;
        }

        if (_restRunning) {
          if (_restRemainingSeconds > 0) {
            _restRemainingSeconds--;
            if (_restRemainingSeconds <= 3 && _restRemainingSeconds > 0) {
              JooSoundService.instance.playTick();
            }
            needsRebuild = true;
          } else {
            _restRunning = false;
            _onRestTimerComplete();
            needsRebuild = true;
          }
        }

        if (_tabataRunning) {
          if (_tabataRemainingSec > 0) {
            _tabataRemainingSec--;
            if (_tabataRemainingSec <= 3 && _tabataRemainingSec > 0) {
              JooSoundService.instance.playTick();
            }
            needsRebuild = true;
          } else {
            JooSoundService.instance.playAlarm();
            if (_tabataIsWorkPhase) {
              _tabataIsWorkPhase = false;
              _tabataRemainingSec = _tabataRestSec;
              _showSmartBanner(
                title: 'وقت الراحة! خد نفسك (${_tabataRestSec}ث)',
                subtitle: 'استعد للجولة الجاية يا وحش',
                icon: CupertinoIcons.flame_fill,
                color: JooPalette.warmAmber,
              );
            } else {
              if (_tabataCurrentRound < _tabataTotalRounds) {
                _tabataCurrentRound++;
                _tabataIsWorkPhase = true;
                _tabataRemainingSec = _tabataWorkSec;
                _showSmartBanner(
                  title: 'انطلق! جولة $_tabataCurrentRound من $_tabataTotalRounds',
                  subtitle: 'أقصى مجهود لمدة $_tabataWorkSec ثانية',
                  icon: CupertinoIcons.bolt_fill,
                  color: JooPalette.emeraldGreen,
                );
              } else {
                _tabataRunning = false;
                _tabataCurrentRound = 1;
                _tabataIsWorkPhase = true;
                _tabataRemainingSec = _tabataWorkSec;
                SmartNotificationService.instance.showSmartNotification(
                  id: 102,
                  title: 'عاش يا وحش! خلصت تمرين التاباتا 🔥',
                  body: 'أنجزت $_tabataTotalRounds جولات كاملة بنجاح!',
                );
                _showSmartBanner(
                  title: 'عاش يا بطل! خلصت كل جولات التاباتا 🏆',
                  subtitle: 'أداء عالمي، اشرب ميه وريح جسمك',
                  icon: CupertinoIcons.checkmark_seal_fill,
                  color: JooPalette.emeraldGreen,
                );
              }
            }
            needsRebuild = true;
          }
        }
      }

      if (needsRebuild) {
        setState(() {});
      }
    });
  }

  void _startRestTimer(int seconds, {String? exerciseName}) {
    JooSoundService.instance.playTap();
    setState(() {
      _restTotalSeconds = seconds.clamp(10, 600);
      _restRemainingSeconds = _restTotalSeconds;
      _restRunning = true;
      if (exerciseName != null && exerciseName.isNotEmpty) {
        _restCurrentExerciseName = exerciseName;
      }
    });
  }

  void _adjustRestTimer(int deltaSeconds) {
    JooSoundService.instance.playTick();
    setState(() {
      _restRemainingSeconds =
          (_restRemainingSeconds + deltaSeconds).clamp(0, 600);
      if (_restRemainingSeconds > _restTotalSeconds) {
        _restTotalSeconds = _restRemainingSeconds;
      }
    });
  }

  void _onRestTimerComplete() {
    JooSoundService.instance.playAlarm();
    final remEnabled = _smartReminders
        .where((r) => r.id == 'rem_rest_timer')
        .fold<bool>(true, (prev, elem) => elem.enabled);

    if (remEnabled) {
      SmartNotificationService.instance.showSmartNotification(
        id: 101,
        title: 'وقت الراحة خلص يا ${_profile.name.isEmpty ? "بطل" : _profile.name}! ⚡',
        body: 'يلا بينا على المجموعة الجاية في: $_restCurrentExerciseName',
      );
    }

    _showSmartBanner(
      title: 'وقت الراحة خلص! ادخل على المجموعة الجاية 💪',
      subtitle: 'التمرين الحالي: $_restCurrentExerciseName',
      icon: CupertinoIcons.bell_solid,
      color: JooPalette.emeraldGreen,
    );
  }

  void _showSmartBanner({
    required String title,
    required String subtitle,
    IconData icon = CupertinoIcons.bell_fill,
    Color color = JooPalette.royalBlue,
  }) {
    _bannerHideTimer?.cancel();
    setState(() {
      _bannerTitle = title;
      _bannerSubtitle = subtitle;
      _bannerIcon = icon;
      _bannerColor = color;
    });
    _bannerHideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _bannerTitle = null;
          _bannerSubtitle = null;
        });
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

    if (setEntry.completed) {
      JooSoundService.instance.playSuccess();
      for (final m in _currentWorkoutDay.targetMuscles) {
        _muscleLastTrained[m] = DateTime.now();
      }
      _muscleLastTrained[exercise.muscleGroup] = DateTime.now();

      if (_autoStartRestOnSet) {
        _startRestTimer(
          exercise.restSeconds,
          exerciseName:
              '${exercise.name} (مجموعة ${setEntry.setNumber}/${exercise.sets.length})',
        );
        _showSmartBanner(
          title: 'عاش! خلصت المجموعة #${setEntry.setNumber} ✓',
          subtitle: 'مؤقت الراحة بدأ تلقائياً (${exercise.restSeconds} ثانية)',
          icon: CupertinoIcons.timer,
          color: _accent,
        );
      }
    } else {
      JooSoundService.instance.playTap();
    }

    _saveAppState();
  }

  void _logAndFinishTodayWorkout() {
    final day = _currentWorkoutDay;
    final completedSets = day.completedSets;
    final completedExercises =
        day.exercises.where((e) => e.completedSetsCount > 0).length;
    final volume = day.totalVolumeKg;
    final durationMin = _workoutElapsedSeconds > 60
        ? (_workoutElapsedSeconds / 60).round()
        : (day.isRestDay ? 0 : 45);

    for (final m in day.targetMuscles) {
      _muscleLastTrained[m] = DateTime.now();
    }

    final log = DailyFollowUpLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      weekDayName: day.weekDayName,
      workoutTitle: day.title,
      completedExercisesCount: completedExercises,
      completedSetsCount: completedSets,
      totalVolumeKg: volume,
      durationMinutes: durationMin,
      recordedBodyWeightKg: _profile.weightKg,
      waterCups: _waterCupsToday,
      proteinGrams: _proteinGramsToday,
      creatineTaken: _creatineTakenToday,
      notes: day.isRestDay
          ? 'يوم راحة واستشفاء عضلي'
          : 'تم إنجاز $completedSets مجموعة بإجمالي أوزان ${volume.toStringAsFixed(0)} كجم',
      trainedMuscles: List<String>.from(day.targetMuscles),
    );

    JooSoundService.instance.playAlarm();

    setState(() {
      _dailyFollowUpLogs.insert(0, log);
      _isWorkoutSessionActive = false;
      _workoutSessionStart = null;
      _workoutElapsedSeconds = 0;
      _restRunning = false;
    });

    _saveAppState();

    SmartNotificationService.instance.showSmartNotification(
      id: 105,
      title: 'الله ينور يا ${_profile.name}! اتسجل يومك في السجل 🏆',
      body: day.isRestDay
          ? 'تم تسجيل متابعة يوم الاستشفاء بنجاح!'
          : 'أنجزت $completedSets مجموعة بإجمالي أوزان ${volume.toStringAsFixed(0)} كجم!',
    );

    _showSmartBanner(
      title: 'عاش يا وحش! تم حفظ وتسجيل تمرين النهاردة 🏆',
      subtitle: 'تقدر تراجع كل تفاصيل تطورك في قسم المتابعة والأدوات',
      icon: CupertinoIcons.rosette,
      color: JooPalette.emeraldGreen,
    );
  }

  double _getMuscleRecoveryPercent(String muscle) {
    final last = _muscleLastTrained[muscle];
    if (last == null) return 1.0;
    final hours = DateTime.now().difference(last).inHours;
    return (hours / 48.0).clamp(0.15, 1.0);
  }

  String _formatSeconds(int totalSec) {
    final mins = (totalSec ~/ 60).toString().padLeft(2, "0");
    final secs = (totalSec % 60).toString().padLeft(2, "0");
    return '$mins:$secs';
  }

  String _formatDateEgyptian(DateTime dt) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final m = months[(dt.month - 1).clamp(0, 11)];
    return '${dt.day} $m ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: JooPalette.bgPrimary,
        body: Center(
          child: CupertinoActivityIndicator(
            radius: 16,
            color: JooPalette.royalBlue,
          ),
        ),
      );
    }

    // أول ما يفتح التطبيق لو مدخلش بياناته وجدوله لسه، تفتح شاشة الإعداد الشاملة فوراً
    if (!_profile.onboardingCompleted) {
      return _SmartOnboardingWizardScreen(
        initialProfile: _profile,
        initialSystem: _activeSystem,
        accentColor: _accent,
        onFinishSetup: (updatedProfile, updatedSystem) {
          JooSoundService.instance.playAlarm();
          setState(() {
            _profile = updatedProfile;
            _activeSystem = updatedSystem;
            _activeDayIndex = getTodayEgyptianWeekIndex();
            _weightHistory.add(
              BodyWeightPoint(
                date: DateTime.now(),
                weightKg: updatedProfile.weightKg,
              ),
            );
            // تحديث ميعاد تذكير التمرين
            for (final r in _smartReminders) {
              if (r.id == 'rem_workout') {
                r.timeLabel = updatedProfile.preferredWorkoutTime;
              }
            }
          });
          _saveAppState();
          SmartNotificationService.instance.requestPermissionsSafe();
          SmartNotificationService.instance.showSmartNotification(
            id: 100,
            title: 'أهلاً بيك يا ${updatedProfile.name} في نظامك الذكي 💪',
            body:
                'تم تنظيم جدولك (${updatedProfile.workoutDaysPerWeek} أيام في الأسبوع) وضبط مواعيد التمرين وتجديد الجيم بنجاح!',
          );
          _showSmartBanner(
            title: 'مبروك يا ${updatedProfile.name}! جدولك جاهز على الشعرة 🔥',
            subtitle: 'تقدر تبدأ تسجل تمرينك كل يوم وتتابع تطورك بالتفصيل',
            icon: CupertinoIcons.checkmark_seal_fill,
            color: JooPalette.emeraldGreen,
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: JooPalette.bgPrimary,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentTabIndex,
              children: [
                _buildTodayDashboardTab(),
                _buildSmartScheduleTab(),
                _buildTimerTab(),
                _buildSmartToolsAndTrackingTab(),
                _buildAlertsAndSettingsTab(),
              ],
            ),
          ),

          if (_bannerTitle != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 14,
              right: 14,
              child: _buildTopSmartBanner(),
            ),

          if ((_restRunning || _tabataRunning) && _currentTabIndex != 2)
            Positioned(
              bottom: 88 + MediaQuery.of(context).padding.bottom,
              left: 16,
              right: 16,
              child: _buildFloatingDynamicTimerBar(),
            ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFrostedBottomBar(),
          ),
        ],
      ),
    );
  }

  void _openFullSetupWizardModal() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) => _SmartOnboardingWizardScreen(
          initialProfile: _profile,
          initialSystem: _activeSystem,
          accentColor: _accent,
          isEditingExisting: true,
          onFinishSetup: (updatedProfile, updatedSystem) {
            JooSoundService.instance.playSuccess();
            setState(() {
              _profile = updatedProfile;
              _activeSystem = updatedSystem;
              if (_weightHistory.isEmpty ||
                  _weightHistory.last.weightKg != updatedProfile.weightKg) {
                _weightHistory.add(
                  BodyWeightPoint(
                    date: DateTime.now(),
                    weightKg: updatedProfile.weightKg,
                  ),
                );
              }
              for (final r in _smartReminders) {
                if (r.id == 'rem_workout') {
                  r.timeLabel = updatedProfile.preferredWorkoutTime;
                }
              }
            });
            _saveAppState();
            Navigator.of(ctx).pop();
            _showSmartBanner(
              title: 'تم تحديث بياناتك وجدولك بنجاح ✓',
              subtitle: 'كل التعديلات اتحفظت في نظامك الذكي',
              icon: CupertinoIcons.checkmark_seal_fill,
              color: JooPalette.emeraldGreen,
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopSmartBanner() {
    return GestureDetector(
      onTap: () {
        JooSoundService.instance.playTap();
        setState(() => _bannerTitle = null);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xE61F2433),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _bannerColor.withOpacity(0.55),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
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
                    shape: BoxShape.circle,
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
                          color: JooPalette.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (_bannerSubtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _bannerSubtitle!,
                          style: const TextStyle(
                            color: JooPalette.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  CupertinoIcons.xmark_circle_fill,
                  color: JooPalette.textMuted,
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
        : (_tabataIsWorkPhase ? JooPalette.emeraldGreen : JooPalette.warmAmber);

    return GestureDetector(
      onTap: () {
        JooSoundService.instance.playTap();
        setState(() => _currentTabIndex = 2);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xEB181C28),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: activeColor.withOpacity(0.55),
                width: 1.2,
              ),
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
                        backgroundColor: JooPalette.cardElevated,
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
                            ? 'مؤقت الراحة شغال دلوقتي'
                            : (_tabataIsWorkPhase
                                ? 'تاباتا: جولة تمرين ($_tabataCurrentRound/$_tabataTotalRounds)'
                                : 'تاباتا: وقت راحة'),
                        style: const TextStyle(
                          color: JooPalette.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isRest
                            ? _restCurrentExerciseName
                            : 'اضغط هنا عشان تفتح شاشة المؤقت',
                        style: const TextStyle(
                          color: JooPalette.textMuted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isRest)
                  JooPressableButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 12,
                    color: JooPalette.cardElevated,
                    onPressed: () => _adjustRestTimer(15),
                    child: const Text(
                      '+15ث',
                      style: TextStyle(
                        color: JooPalette.textPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _buildFrostedBottomBar() {
    final items = [
      (icon: CupertinoIcons.flame_fill, label: 'تمرين النهاردة'),
      (icon: CupertinoIcons.calendar_today, label: 'جدولي'),
      (icon: CupertinoIcons.timer_fill, label: 'المؤقت'),
      (icon: CupertinoIcons.chart_bar_alt_fill, label: 'المتابعة والأدوات'),
      (icon: CupertinoIcons.slider_horizontal_3, label: 'الإعدادات'),
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
            color: const Color(0xE011151E),
            border: Border(
              top: BorderSide(
                color: JooPalette.separator.withOpacity(0.55),
                width: 0.7,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final selected = _currentTabIndex == index;
              final item = items[index];
              final showTimerDot = index == 2 &&
                  (_restRunning || _tabataRunning || _stopwatchRunning);

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_currentTabIndex != index) {
                      JooSoundService.instance.playTap();
                      setState(() => _currentTabIndex = index);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: selected
                          ? _accent.withOpacity(0.16)
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
                              size: selected ? 22 : 20,
                              color: selected ? _accent : JooPalette.textMuted,
                            ),
                            if (showTimerDot)
                              Positioned(
                                top: -2,
                                right: -4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: JooPalette.warmAmber,
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
                            color: selected ? _accent : JooPalette.textMuted,
                            fontSize: 10.2,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
  // التبويب 1: تمرين النهاردة والمتابعة اليومية واشتراك الجيم
  // ==========================================================================

  Widget _buildTodayDashboardTab() {
    final day = _currentWorkoutDay;
    final setsProgress = day.progress;
    final waterGoal = _profile.dailyWaterTargetCups;
    final proteinGoal = _profile.dailyProteinTargetGrams;
    final waterProgress =
        waterGoal == 0 ? 0.0 : (_waterCupsToday / waterGoal).clamp(0.0, 1.0);
    final proteinProgress = proteinGoal == 0
        ? 0.0
        : (_proteinGramsToday / proteinGoal).clamp(0.0, 1.0);
    final daysLeftRenewal = _profile.daysUntilGymRenewal;

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
      children: [
        // الهيدر العلوي النظيف باللهجة المصرية
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _profile.name.isEmpty
                              ? 'يا أهلاً بيك يا وحش 💪'
                              : 'عاش يا ${_profile.name} 💪',
                          style: TextStyle(
                            color: _accent,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_isWorkoutSessionActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: JooPalette.emeraldGreen.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'شغال دلوقتي • ${_formatSeconds(_workoutElapsedSeconds)}',
                            style: const TextStyle(
                              color: JooPalette.emeraldGreen,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'تمرين ومتابعة ${day.weekDayName}',
                    style: const TextStyle(
                      color: JooPalette.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                JooPressableButton(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                  borderRadius: 13,
                  color: JooPalette.cardSurface,
                  borderColor: JooPalette.separator,
                  onPressed: _openFullSetupWizardModal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.person_crop_circle_badge_checkmark,
                        color: _accent,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'بياناتي',
                        style: TextStyle(
                          color: JooPalette.textPrimary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                JooPressableButton(
                  padding: const EdgeInsets.all(10),
                  borderRadius: 13,
                  color: JooPalette.cardSurface,
                  borderColor: JooPalette.separator,
                  onPressed: () => setState(() => _currentTabIndex = 2),
                  child: const Icon(
                    CupertinoIcons.timer,
                    color: JooPalette.warmAmber,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // كارت اشتراك الجيم وموعد التجديد الذكي
        JooGlassCard(
          padding: const EdgeInsets.all(15),
          borderColor: daysLeftRenewal <= 5
              ? JooPalette.warmAmber.withOpacity(0.65)
              : JooPalette.separator.withOpacity(0.65),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: (daysLeftRenewal <= 5
                              ? JooPalette.warmAmber
                              : JooPalette.emeraldGreen)
                          .withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.creditcard_fill,
                      color: daysLeftRenewal <= 5
                          ? JooPalette.warmAmber
                          : JooPalette.emeraldGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _profile.gymName.isEmpty
                              ? 'اشتراك الجيم (${_profile.subscriptionType})'
                              : '${_profile.gymName} • اشتراك ${_profile.subscriptionType}',
                          style: const TextStyle(
                            color: JooPalette.textPrimary,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ميعاد التجديد الجاي: ${_formatDateEgyptian(_profile.subscriptionRenewalDate)}',
                          style: const TextStyle(
                            color: JooPalette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (daysLeftRenewal <= 5
                              ? JooPalette.warmAmber
                              : _accent)
                          .withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      daysLeftRenewal < 0
                          ? 'محتاج تجديد!'
                          : (daysLeftRenewal == 0
                              ? 'التجديد النهاردة'
                              : 'فاضل $daysLeftRenewal يوم'),
                      style: TextStyle(
                        color: daysLeftRenewal <= 5
                            ? JooPalette.warmAmber
                            : _accent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'أيام التمرين: ${_profile.workoutDaysPerWeek} أيام في الأسبوع • الميعاد: ${day.scheduledTime}',
                      style: const TextStyle(
                        color: JooPalette.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _renewGymSubscriptionNow,
                    child: Text(
                      'جددت الاشتراك؟',
                      style: TextStyle(
                        color: _accent,
                        fontSize: 11.5,
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

        // كارت حلقات الإنجاز اليومي + ملخص الجسم
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 108,
                height: 108,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(108, 108),
                      painter: ActivityRingsPainter(
                        outerProgress: setsProgress,
                        middleProgress: proteinProgress,
                        innerProgress: waterProgress,
                        accentColor: _accent,
                      ),
                    ),
                    Text(
                      '${(setsProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: JooPalette.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRingMetricRow(
                      color: JooPalette.emeraldGreen,
                      label: 'مجاميع النهاردة',
                      value: '${day.completedSets} / ${day.totalSets} مجموعة',
                    ),
                    const SizedBox(height: 9),
                    _buildRingMetricRow(
                      color: _accent,
                      label: 'البروتين اليومي',
                      value: '$_proteinGramsToday / $proteinGoal جرام',
                    ),
                    const SizedBox(height: 9),
                    _buildRingMetricRow(
                      color: JooPalette.calmTeal,
                      label: 'شرب الميه',
                      value: '$_waterCupsToday / $waterGoal كوباية',
                    ),
                    const SizedBox(height: 9),
                    _buildRingMetricRow(
                      color: JooPalette.warmAmber,
                      label: 'الوزن والسعرات',
                      value:
                          '${_profile.weightKg.toStringAsFixed(0)} كجم • ${_profile.dailyCaloriesTarget} سعرة',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // شريط أيام الأسبوع الـ 7 للتنقل السريع
        JooGlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'جدول أيام الأسبوع (اضغط على أي يوم لعرضه أو تعديله)',
                    style: TextStyle(
                      color: JooPalette.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      JooSoundService.instance.playTap();
                      setState(() => _currentTabIndex = 1);
                    },
                    child: Text(
                      'تعديل الجدول',
                      style: TextStyle(
                        color: _accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_activeSystem.days.length, (i) {
                    final d = _activeSystem.days[i];
                    final isSelected = i == _activeDayIndex;
                    final isToday = i == getTodayEgyptianWeekIndex();
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: JooPressableButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        borderRadius: 14,
                        color: isSelected ? _accent : JooPalette.cardElevated,
                        borderColor: isToday && !isSelected ? _accent : null,
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
                                  : (d.isRestDay
                                      ? JooPalette.calmTeal
                                      : JooPalette.warmAmber),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isToday ? '${d.weekDayName} (النهاردة)' : d.weekDayName,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : JooPalette.textPrimary,
                                fontSize: 12.5,
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w600,
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

        // تفاصيل تمرين اليوم وأزرار البدء والتسجيل
        JooGlassCard(
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
                            color: JooPalette.textPrimary,
                            fontSize: 17.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.subtitle} • الميعاد: ${day.scheduledTime}',
                          style: const TextStyle(
                            color: JooPalette.textSecondary,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  JooPressableButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    borderRadius: 11,
                    color: JooPalette.cardElevated,
                    onPressed: () {
                      SmartNotificationService.instance.showSmartNotification(
                        id: 301,
                        title: 'تذكير تمرين ${day.weekDayName} يا ${_profile.name} 💪',
                        body: day.isRestDay
                            ? 'النهاردة يوم راحة واستشفاء، اهتم بالميه والبروتين!'
                            : 'ميعادك ${day.scheduledTime} — عندك ${day.exercises.length} تمارين (${day.totalSets} مجموعة)!',
                      );
                      _showSmartBanner(
                        title: 'اتبعثلك إشعار بتفاصيل تمرين اليوم 🔔',
                        subtitle: '${day.title} (${day.scheduledTime})',
                        icon: CupertinoIcons.bell_solid,
                        color: _accent,
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.bell_fill,
                          size: 13,
                          color: JooPalette.warmAmber,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'ذكرني',
                          style: TextStyle(
                            color: JooPalette.textPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
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
                    child: JooPressableButton(
                      color: _isWorkoutSessionActive
                          ? JooPalette.emeraldGreen
                          : _accent,
                      borderRadius: 14,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () {
                        if (day.isRestDay) {
                          _logAndFinishTodayWorkout();
                          return;
                        }
                        if (!_isWorkoutSessionActive) {
                          JooSoundService.instance.playSuccess();
                          setState(() {
                            _isWorkoutSessionActive = true;
                            _workoutSessionStart = DateTime.now();
                          });
                          _showSmartBanner(
                            title: 'بدأت تمرينة النهاردة.. الله يقويك يا وحش 🔥',
                            subtitle:
                                'كل ما تخلص مجموعة اضغط علامة ✓ عشان مؤقت الراحة يشتغل',
                            icon: CupertinoIcons.play_circle_fill,
                            color: JooPalette.emeraldGreen,
                          );
                        } else {
                          _logAndFinishTodayWorkout();
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
                                ? 'تسجيل متابعة يوم الراحة في السجل'
                                : (_isWorkoutSessionActive
                                    ? 'إنهاء وتسجيل تمرين النهاردة (${_formatSeconds(_workoutElapsedSeconds)})'
                                    : 'ابدأ تمرينة النهاردة أو سجل يومك'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!day.isRestDay) ...[
                    const SizedBox(width: 8),
                    JooPressableButton(
                      color: JooPalette.cardElevated,
                      borderRadius: 14,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      onPressed: () => _openAddExerciseSheetForDay(day),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.add,
                            color: JooPalette.textPrimary,
                            size: 17,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'تمرين',
                            style: TextStyle(
                              color: JooPalette.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (!day.isRestDay && !_isWorkoutSessionActive && day.completedSets > 0) ...[
                const SizedBox(height: 10),
                JooPressableButton(
                  fullWidth: true,
                  color: JooPalette.emeraldGreen.withOpacity(0.2),
                  borderColor: JooPalette.emeraldGreen,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onPressed: _logAndFinishTodayWorkout,
                  child: const Text(
                    'حفظ وتسجيل التمرين ومتابعة اليوم في السجل ✓',
                    style: TextStyle(
                      color: JooPalette.emeraldGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // قائمة التمارين لليوم المحدد
        if (day.isRestDay)
          _buildRestDayCard(day)
        else if (day.exercises.isEmpty)
          _buildEmptyExercisesCard(day)
        else
          ...day.exercises.map((ex) => _buildExerciseWorkoutCard(day, ex)),

        const SizedBox(height: 16),

        // كارت متابعة الميه والبروتين والكرياتين والوزن اليومي
        _buildQuickNutritionAndWeightCard(),

        const SizedBox(height: 16),

        // مهام وملاحظات الجيم اليومية
        _buildGymChecklistSection(),
      ],
    );
  }

  void _renewGymSubscriptionNow() {
    int addDays = 30;
    if (_profile.subscriptionType.contains('3')) {
      addDays = 90;
    } else if (_profile.subscriptionType.contains('6')) {
      addDays = 180;
    } else if (_profile.subscriptionType.contains('سنوي')) {
      addDays = 365;
    }
    JooSoundService.instance.playSuccess();
    setState(() {
      _profile.subscriptionStartDate = DateTime.now();
      _profile.subscriptionRenewalDate =
          DateTime.now().add(Duration(days: addDays));
    });
    _saveAppState();
    _showSmartBanner(
      title: 'مبروك تجديد اشتراك الجيم يا وحش! 🎉',
      subtitle:
          'ميعاد التجديد الجديد: ${_formatDateEgyptian(_profile.subscriptionRenewalDate)}',
      icon: CupertinoIcons.checkmark_seal_fill,
      color: JooPalette.emeraldGreen,
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
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: JooPalette.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildRestDayCard(WorkoutDay day) {
    return JooGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: JooPalette.calmTeal.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.moon_stars_fill,
              color: JooPalette.calmTeal,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${day.weekDayName} يوم راحة واستشفاء عضلي 🛌',
            style: const TextStyle(
              color: JooPalette.textPrimary,
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'العضلة بتكبر وإنت مريح وبتاكل كويس! ركز النهاردة على قفل احتياجك من البروتين والميه والنوم 8 ساعات.',
            style: TextStyle(
              color: JooPalette.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          JooPressableButton(
            color: JooPalette.cardElevated,
            onPressed: () {
              setState(() {
                day.isRestDay = false;
                day.title = '${day.weekDayName}: تمرين إضافي';
                day.subtitle = 'يوم تمرين مخصص';
              });
              _saveAppState();
              _openAddExerciseSheetForDay(day);
            },
            child: const Text(
              'تحويل اليوم ده ليوم تمرين وإضافة تمارين +',
              style: TextStyle(
                color: JooPalette.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyExercisesCard(WorkoutDay day) {
    return JooGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.plus_square_on_square,
            color: _accent,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            'مفيش تمارين مضافة ليوم ${day.weekDayName} لسه',
            style: const TextStyle(
              color: JooPalette.textPrimary,
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'تقدر تضيف التمارين اللي عايز تلعبها النهاردة وتحدد عدد المجموعات والعدات لكل تمرين.',
            style: TextStyle(
              color: JooPalette.textMuted,
              fontSize: 12.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          JooPressableButton(
            color: _accent,
            onPressed: () => _openAddExerciseSheetForDay(day),
            child: const Text(
              '+ إضافة تمرين ليوم النهاردة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseWorkoutCard(WorkoutDay day, ExerciseItem exercise) {
    final allDone = exercise.isAllCompleted;
    return JooGlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      borderColor: allDone
          ? JooPalette.emeraldGreen.withOpacity(0.6)
          : JooPalette.separator.withOpacity(0.65),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: (allDone ? JooPalette.emeraldGreen : _accent)
                      .withOpacity(0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exercise.muscleGroup,
                  style: TextStyle(
                    color: allDone ? JooPalette.emeraldGreen : _accent,
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
                    color: JooPalette.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              JooPressableButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                borderRadius: 10,
                color: JooPalette.cardElevated,
                onPressed: () => _startRestTimer(
                  exercise.restSeconds,
                  exerciseName: exercise.name,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.timer,
                      color: JooPalette.warmAmber,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${exercise.restSeconds}ث',
                      style: const TextStyle(
                        color: JooPalette.warmAmber,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  JooSoundService.instance.playTap();
                  setState(() => day.exercises.remove(exercise));
                  _saveAppState();
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    CupertinoIcons.trash,
                    color: JooPalette.textMuted,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          if (exercise.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              exercise.notes,
              style: const TextStyle(
                color: JooPalette.textMuted,
                fontSize: 11.5,
              ),
            ),
          ],
          const SizedBox(height: 12),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    'المجموعة',
                    style:
                        TextStyle(color: JooPalette.textMuted, fontSize: 11),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'الوزن (كجم)',
                      style:
                          TextStyle(color: JooPalette.textMuted, fontSize: 11),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'العدات',
                      style:
                          TextStyle(color: JooPalette.textMuted, fontSize: 11),
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Center(
                    child: Text(
                      'خلصت',
                      style:
                          TextStyle(color: JooPalette.textMuted, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),

          ...exercise.sets.map((s) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: s.completed
                    ? JooPalette.emeraldGreen.withOpacity(0.12)
                    : JooPalette.bgGrouped,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: s.completed
                      ? JooPalette.emeraldGreen.withOpacity(0.45)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: JooPalette.cardElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '#${s.setNumber}',
                          style: const TextStyle(
                            color: JooPalette.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
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
                              color: JooPalette.textPrimary,
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
                              color: JooPalette.textPrimary,
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
                                ? JooPalette.emeraldGreen
                                : JooPalette.cardElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: s.completed
                                  ? JooPalette.emeraldGreen
                                  : JooPalette.separator,
                            ),
                          ),
                          child: Icon(
                            CupertinoIcons.checkmark_alt,
                            color: s.completed
                                ? Colors.white
                                : JooPalette.textMuted,
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

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  JooSoundService.instance.playTick();
                  setState(() {
                    final last = exercise.sets.isNotEmpty
                        ? exercise.sets.last
                        : SetEntry(setNumber: 0, targetReps: 10, weightKg: 0);
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
                },
                child: Text(
                  '+ زود مجموعة كمان',
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
                    JooSoundService.instance.playTap();
                    setState(() => exercise.sets.removeLast());
                    _saveAppState();
                  },
                  child: const Text(
                    'شيل مجموعة',
                    style: TextStyle(
                      color: JooPalette.textMuted,
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
        JooSoundService.instance.playTick();
        onTap();
      },
      child: Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: JooPalette.cardElevated,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 12, color: JooPalette.textSecondary),
      ),
    );
  }

  Widget _buildQuickNutritionAndWeightCard() {
    final waterGoal = _profile.dailyWaterTargetCups;
    final proteinGoal = _profile.dailyProteinTargetGrams;

    return JooGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                CupertinoIcons.drop_fill,
                color: JooPalette.calmTeal,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'متابعة الميه والبروتين والوزن النهاردة',
                style: TextStyle(
                  color: JooPalette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // الميه
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: JooPalette.bgGrouped,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'كوبايات الميه (250 مل)',
                        style: TextStyle(
                          color: JooPalette.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_waterCupsToday / $waterGoal',
                            style: const TextStyle(
                              color: JooPalette.calmTeal,
                              fontSize: 16,
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
                                        (_waterCupsToday - 1).clamp(0, 40);
                                  });
                                  _saveAppState();
                                },
                              ),
                              const SizedBox(width: 5),
                              _buildMiniStepBtn(
                                icon: CupertinoIcons.plus,
                                onTap: () {
                                  setState(() {
                                    _waterCupsToday =
                                        (_waterCupsToday + 1).clamp(0, 40);
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
              // البروتين
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: JooPalette.bgGrouped,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'البروتين (جرام)',
                        style: TextStyle(
                          color: JooPalette.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_proteinGramsToday / $proteinGoal',
                            style: TextStyle(
                              color: _accent,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Row(
                            children: [
                              _buildMiniStepBtn(
                                icon: CupertinoIcons.minus,
                                onTap: () {
                                  setState(() {
                                    _proteinGramsToday =
                                        (_proteinGramsToday - 10).clamp(0, 400);
                                  });
                                  _saveAppState();
                                },
                              ),
                              const SizedBox(width: 5),
                              _buildMiniStepBtn(
                                icon: CupertinoIcons.plus,
                                onTap: () {
                                  setState(() {
                                    _proteinGramsToday =
                                        (_proteinGramsToday + 10).clamp(0, 400);
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
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // الكرياتين
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    JooSoundService.instance.playSuccess();
                    setState(() => _creatineTakenToday = !_creatineTakenToday);
                    _saveAppState();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _creatineTakenToday
                          ? JooPalette.emeraldGreen.withOpacity(0.15)
                          : JooPalette.bgGrouped,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _creatineTakenToday
                            ? JooPalette.emeraldGreen.withOpacity(0.5)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'جرعة الكرياتين (5g)',
                              style: TextStyle(
                                color: JooPalette.textMuted,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _creatineTakenToday ? 'اتاخدت النهاردة ✓' : 'اضغط للتسجيل',
                              style: TextStyle(
                                color: _creatineTakenToday
                                    ? JooPalette.emeraldGreen
                                    : JooPalette.textPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          _creatineTakenToday
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.circle,
                          color: _creatineTakenToday
                              ? JooPalette.emeraldGreen
                              : JooPalette.textMuted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // وزن الجسم اليومي
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: JooPalette.bgGrouped,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'وزنك النهاردة (كجم)',
                        style: TextStyle(
                          color: JooPalette.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_profile.weightKg.toStringAsFixed(1)} كجم',
                            style: const TextStyle(
                              color: JooPalette.warmAmber,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Row(
                            children: [
                              _buildMiniStepBtn(
                                icon: CupertinoIcons.minus,
                                onTap: () {
                                  setState(() {
                                    _profile.weightKg =
                                        (_profile.weightKg - 0.5).clamp(30.0, 250.0);
                                    _weightHistory.add(
                                      BodyWeightPoint(
                                        date: DateTime.now(),
                                        weightKg: _profile.weightKg,
                                      ),
                                    );
                                  });
                                  _saveAppState();
                                },
                              ),
                              const SizedBox(width: 5),
                              _buildMiniStepBtn(
                                icon: CupertinoIcons.plus,
                                onTap: () {
                                  setState(() {
                                    _profile.weightKg =
                                        (_profile.weightKg + 0.5).clamp(30.0, 250.0);
                                    _weightHistory.add(
                                      BodyWeightPoint(
                                        date: DateTime.now(),
                                        weightKg: _profile.weightKg,
                                      ),
                                    );
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGymChecklistSection() {
    return JooGlassCard(
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
                    'مهام وملاحظات الجيم بتاعتك',
                    style: TextStyle(
                      color: JooPalette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              JooPressableButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                borderRadius: 10,
                color: _accent.withOpacity(0.16),
                onPressed: _openAddGymTaskSheet,
                child: Text(
                  '+ ضيف مهمة',
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
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  'مفيش مهام مضافة حالياً.. اضغط "+ ضيف مهمة" لو عايز تفكر نفسك بحاجة النهاردة!',
                  style: TextStyle(color: JooPalette.textMuted, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ..._gymTasks.map((task) {
              return Container(
                margin: const EdgeInsets.only(top: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: JooPalette.bgGrouped,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        JooSoundService.instance.playSuccess();
                        setState(() => task.done = !task.done);
                        _saveAppState();
                      },
                      child: Icon(
                        task.done
                            ? CupertinoIcons.checkmark_circle_fill
                            : CupertinoIcons.circle,
                        color: task.done
                            ? JooPalette.emeraldGreen
                            : JooPalette.textMuted,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          color: task.done
                              ? JooPalette.textMuted
                              : JooPalette.textPrimary,
                          fontSize: 13.5,
                          decoration:
                              task.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        JooSoundService.instance.playTap();
                        setState(() => _gymTasks.remove(task));
                        _saveAppState();
                      },
                      child: const Icon(
                        CupertinoIcons.trash,
                        color: JooPalette.textMuted,
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
  // التبويب 2: تنظيم الجدول الأسبوعي بالتفصيل (يوم بيوم، محلل ذكي، أنظمة)
  // ==========================================================================

  Widget _buildSmartScheduleTab() {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تنظيم جدولي الأسبوعي بالتفصيل',
                    style: TextStyle(
                      color: JooPalette.textPrimary,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'ظبط أيام تمرينك، المواعيد، والتمارين والمجاميع لكل يوم براحتك.',
                    style: TextStyle(
                      color: JooPalette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            JooPressableButton(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              borderRadius: 12,
              color: _accent,
              onPressed: _openFullSetupWizardModal,
              child: const Text(
                'معالج الإعداد الشامل',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: JooPalette.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: JooPalette.separator.withOpacity(0.5)),
          ),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _scheduleSubTab,
            backgroundColor: Colors.transparent,
            thumbColor: _accent,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'جدولي يوم بيوم',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'اكتب جدولك نصياً',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              2: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'أنظمة جاهزة',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            },
            onValueChanged: (val) {
              if (val != null) {
                JooSoundService.instance.playTap();
                setState(() => _scheduleSubTab = val);
              }
            },
          ),
        ),
        const SizedBox(height: 16),

        if (_scheduleSubTab == 0) _buildDayByDayScheduleEditorView(),
        if (_scheduleSubTab == 1) _buildSmartTextParserView(),
        if (_scheduleSubTab == 2) _buildBuiltInSystemsView(),
      ],
    );
  }

  Widget _buildDayByDayScheduleEditorView() {
    return Column(
      children: List.generate(_activeSystem.days.length, (index) {
        final d = _activeSystem.days[index];
        return JooGlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          borderColor: d.isRestDay
              ? JooPalette.separator.withOpacity(0.5)
              : _accent.withOpacity(0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: (d.isRestDay
                                  ? JooPalette.calmTeal
                                  : _accent)
                              .withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          d.weekDayName,
                          style: TextStyle(
                            color: d.isRestDay ? JooPalette.calmTeal : _accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        d.isRestDay ? 'يوم راحة 🛌' : 'يوم تمرين 💪 (${d.scheduledTime})',
                        style: const TextStyle(
                          color: JooPalette.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        'تمرين',
                        style: TextStyle(
                          color: JooPalette.textMuted,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      CupertinoSwitch(
                        value: !d.isRestDay,
                        activeColor: JooPalette.emeraldGreen,
                        onChanged: (isTrain) {
                          JooSoundService.instance.playTap();
                          setState(() {
                            d.isRestDay = !isTrain;
                            if (d.isRestDay) {
                              d.title = '${d.weekDayName}: يوم راحة واستشفاء';
                              d.subtitle = 'راحة واستشفاء عضلي';
                              _profile.selectedDays.remove(d.weekDayName);
                            } else {
                              if (!_profile.selectedDays.contains(d.weekDayName)) {
                                _profile.selectedDays.add(d.weekDayName);
                              }
                              if (d.targetMuscles.isEmpty) {
                                d.targetMuscles = ['الصدر', 'الترايسبس'];
                              }
                              d.title =
                                  '${d.weekDayName}: ${d.targetMuscles.join(" + ")}';
                              d.subtitle =
                                  'العضلات: ${d.targetMuscles.join(" + ")}';
                            }
                            _profile.workoutDaysPerWeek = _activeSystem.days
                                .where((dayItem) => !dayItem.isRestDay)
                                .length;
                          });
                          _saveAppState();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (!d.isRestDay) ...[
                const SizedBox(height: 10),
                const Text(
                  'اختار العضلات اللي بتلعبها في اليوم ده:',
                  style: TextStyle(
                    color: JooPalette.textMuted,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: kAllMuscleGroups.map((m) {
                    final selected = d.targetMuscles.contains(m);
                    return GestureDetector(
                      onTap: () {
                        JooSoundService.instance.playTick();
                        setState(() {
                          if (selected) {
                            d.targetMuscles.remove(m);
                          } else {
                            d.targetMuscles.add(m);
                          }
                          d.title = d.targetMuscles.isEmpty
                              ? '${d.weekDayName}: تمرين شامل'
                              : '${d.weekDayName}: ${d.targetMuscles.join(" + ")}';
                          d.subtitle = d.targetMuscles.isEmpty
                              ? 'تمرين مخصص'
                              : 'العضلات: ${d.targetMuscles.join(" + ")}';
                        });
                        _saveAppState();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? _accent.withOpacity(0.22)
                              : JooPalette.bgGrouped,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected ? _accent : JooPalette.separator,
                          ),
                        ),
                        child: Text(
                          m,
                          style: TextStyle(
                            color: selected
                                ? JooPalette.textPrimary
                                : JooPalette.textMuted,
                            fontSize: 11.5,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                if (d.exercises.isNotEmpty)
                  ...d.exercises.map((ex) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: JooPalette.bgGrouped,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '• ${ex.name} (${ex.sets.length} مجاميع × ${ex.sets.isNotEmpty ? ex.sets.first.targetReps : 10} عدات)',
                              style: const TextStyle(
                                color: JooPalette.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              JooSoundService.instance.playTap();
                              setState(() => d.exercises.remove(ex));
                              _saveAppState();
                            },
                            child: const Icon(
                              CupertinoIcons.xmark_circle_fill,
                              color: JooPalette.textMuted,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: JooPressableButton(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        borderRadius: 11,
                        color: _accent.withOpacity(0.18),
                        onPressed: () => _openAddExerciseSheetForDay(d),
                        child: Text(
                          '+ ضيف تمرين بمجاميعه ليوم ${d.weekDayName}',
                          style: TextStyle(
                            color: _accent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    JooPressableButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 9,
                      ),
                      borderRadius: 11,
                      color: JooPalette.cardElevated,
                      onPressed: () {
                        if (d.targetMuscles.isEmpty) {
                          d.targetMuscles = ['الصدر', 'الترايسبس'];
                        }
                        setState(() {
                          d.exercises = SmartScheduleEngine
                              .generateDefaultExercisesForMuscles(
                            d.targetMuscles,
                            goal: _profile.fitnessGoal,
                          );
                        });
                        _saveAppState();
                        _showSmartBanner(
                          title: 'تم توزيع تمارين ${d.weekDayName} تلقائياً ⚡',
                          subtitle:
                              'اتضافت أهم تمارين ${d.targetMuscles.join(" + ")} وتقدر تعدلها براحتك',
                          icon: CupertinoIcons.sparkles,
                          color: JooPalette.emeraldGreen,
                        );
                      },
                      child: const Text(
                        'تعبئة ذكية',
                        style: TextStyle(
                          color: JooPalette.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSmartTextParserView() {
    return JooGlassCard(
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
                  'اكتب جدولك بالطريقة اللي تريحك والتطبيق هينظمهولك فوراً',
                  style: TextStyle(
                    color: JooPalette.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'مثال: اكتب كل يوم والعضلات أو التمارين اللي هتلعبها فيه بعدد المجاميع والعدات، والتطبيق هيجمعها ويعملك جدول أسبوعي كامل.',
            style: TextStyle(
              color: JooPalette.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: JooPalette.bgGrouped,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: JooPalette.separator),
            ),
            child: TextField(
              controller: _smartScheduleInputCtrl,
              maxLines: 7,
              style:
                  const TextStyle(color: JooPalette.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                hintText:
                    'مثال:\nالسبت: صدر وترايسبس\nبنش مسطح بالبار 4 في 10\nتجميع دمبل عالي 4 في 10\nدفع حبل ترايسبس 4 في 12\nالأحد: ظهر وبايسبس\nسحب عالي واسع 4 في 10...',
                hintStyle: TextStyle(
                  color: JooPalette.textMuted,
                  fontSize: 12,
                  height: 1.45,
                ),
                contentPadding: EdgeInsets.all(14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          JooPressableButton(
            fullWidth: true,
            color: _accent,
            onPressed: () {
              final txt = _smartScheduleInputCtrl.text.trim();
              if (txt.isEmpty) {
                _showSmartBanner(
                  title: 'اكتب جدولك الأول يا بطل ✍️',
                  subtitle: 'اكتب الأيام والتمارين عشان أنظمهالك فوراً',
                  icon: CupertinoIcons.exclamationmark_circle_fill,
                  color: JooPalette.warmAmber,
                );
                return;
              }
              final parsed = SmartScheduleEngine.parseCustomScheduleText(
                txt,
                defaultTime: _profile.preferredWorkoutTime,
              );
              JooSoundService.instance.playSuccess();
              setState(() {
                _activeSystem = parsed;
                _profile.workoutDaysPerWeek = parsed.daysPerWeek;
                _profile.selectedDays = parsed.days
                    .where((d) => !d.isRestDay)
                    .map((d) => d.weekDayName)
                    .toList();
                _scheduleSubTab = 0;
              });
              _saveAppState();
              _showSmartBanner(
                title: 'تم تنظيم جدولك بنجاح يا وحش! 🎯',
                subtitle: 'تقدر تشوفه وتعدله يوم بيوم دلوقتي',
                icon: CupertinoIcons.checkmark_seal_fill,
                color: JooPalette.emeraldGreen,
              );
            },
            child: const Text(
              'تنظيم واعتماد الجدول المكتوب فوراً ⚡',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuiltInSystemsView() {
    final systems = SmartScheduleEngine.getEgyptianProTemplates(
      _profile.preferredWorkoutTime,
    );

    return Column(
      children: systems.map((sys) {
        return JooGlassCard(
          margin: const EdgeInsets.only(bottom: 12),
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
                  const Spacer(),
                  Text(
                    '${sys.daysPerWeek} أيام تمرين في الأسبوع',
                    style: const TextStyle(
                      color: JooPalette.textMuted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                sys.name,
                style: const TextStyle(
                  color: JooPalette.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sys.description,
                style: const TextStyle(
                  color: JooPalette.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 12),
              JooPressableButton(
                fullWidth: true,
                color: _accent,
                onPressed: () {
                  JooSoundService.instance.playSuccess();
                  setState(() {
                    _activeSystem = sys.cloneDeep();
                    _profile.workoutDaysPerWeek = sys.daysPerWeek;
                    _profile.selectedDays = sys.days
                        .where((d) => !d.isRestDay)
                        .map((d) => d.weekDayName)
                        .toList();
                    _scheduleSubTab = 0;
                  });
                  _saveAppState();
                  _showSmartBanner(
                    title: 'تم تفعيل ${sys.name} 💪',
                    subtitle: 'تقدر تعدل أي يوم أو تمرين فيه براحتك',
                    icon: CupertinoIcons.checkmark_seal_fill,
                    color: JooPalette.emeraldGreen,
                  );
                },
                child: const Text(
                  'تفعيل النظام ده وتخصيصه على أيامي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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

  // ==========================================================================
  // التبويب 3: المؤقت الاحترافي (مؤقت الراحة، تاباتا HIIT، ستوب ووتش)
  // ==========================================================================

  Widget _buildTimerTab() {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
      children: [
        const Text(
          'مؤقت الجيم الاحترافي',
          style: TextStyle(
            color: JooPalette.textPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'مؤقت راحة ذكي بيشتغل تلقائياً مع كل مجموعة، ومؤقت تاباتا للكارديو، وستوب ووتش دقيق.',
          style: TextStyle(
            color: JooPalette.textSecondary,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: JooPalette.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: JooPalette.separator.withOpacity(0.5)),
          ),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _timerMode,
            backgroundColor: Colors.transparent,
            thumbColor: _accent,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'راحة المجموعات',
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
                  'ستوب ووتش',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            },
            onValueChanged: (v) {
              if (v != null) {
                JooSoundService.instance.playTap();
                setState(() => _timerMode = v);
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
        : _restRemainingSeconds / _restTotalSeconds;
    final presets = [30, 45, 60, 90, 120, 180];

    return Column(
      children: [
        JooGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Text(
                _restCurrentExerciseName,
                style: const TextStyle(
                  color: JooPalette.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
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
                      painter: CircularTimerPainter(
                        progress: progress,
                        activeColor: _accent,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatSeconds(_restRemainingSeconds),
                          style: const TextStyle(
                            color: JooPalette.textPrimary,
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _restRunning ? 'وقت الراحة شغال...' : 'جاهز للبدء',
                          style: TextStyle(
                            color: _restRunning
                                ? JooPalette.emeraldGreen
                                : JooPalette.textMuted,
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

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  JooPressableButton(
                    color: JooPalette.cardElevated,
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    onPressed: () => _adjustRestTimer(-15),
                    child: const Text(
                      '-15 ث',
                      style: TextStyle(
                        color: JooPalette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  JooPressableButton(
                    color:
                        _restRunning ? JooPalette.warmAmber : JooPalette.emeraldGreen,
                    borderRadius: 18,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_restRemainingSeconds == 0) {
                          _restRemainingSeconds = _restTotalSeconds;
                        }
                        _restRunning = !_restRunning;
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
                        const SizedBox(width: 6),
                        Text(
                          _restRunning ? 'إيقاف مؤقت' : 'تشغيل',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  JooPressableButton(
                    color: JooPalette.cardElevated,
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    onPressed: () => _adjustRestTimer(15),
                    child: const Text(
                      '+15 ث',
                      style: TextStyle(
                        color: JooPalette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: presets.map((sec) {
                  final isSel = _restTotalSeconds == sec;
                  return JooPressableButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    borderRadius: 12,
                    color: isSel ? _accent : JooPalette.bgGrouped,
                    onPressed: () => _startRestTimer(sec),
                    child: Text(
                      '$sec ثانية',
                      style: TextStyle(
                        color: isSel ? Colors.white : JooPalette.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        JooGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تشغيل مؤقت الراحة تلقائياً مع كل مجموعة',
                      style: TextStyle(
                        color: JooPalette.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'أول ما تضغط ✓ على أي مجموعة يبدأ يعد لوحده',
                      style: TextStyle(
                        color: JooPalette.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoSwitch(
                value: _autoStartRestOnSet,
                activeColor: JooPalette.emeraldGreen,
                onChanged: (v) {
                  JooSoundService.instance.playTap();
                  setState(() => _autoStartRestOnSet = v);
                  _saveAppState();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabataTimerView() {
    final total = _tabataIsWorkPhase ? _tabataWorkSec : _tabataRestSec;
    final progress = total == 0 ? 0.0 : _tabataRemainingSec / total;
    final phaseColor =
        _tabataIsWorkPhase ? JooPalette.emeraldGreen : JooPalette.warmAmber;

    return JooGlassCard(
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
                  ? 'جولة تمرين ناري ($_tabataCurrentRound / $_tabataTotalRounds)'
                  : 'استراحة سريعة ($_tabataCurrentRound / $_tabataTotalRounds)',
              style: TextStyle(
                color: phaseColor,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 210,
            height: 210,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(210, 210),
                  painter: CircularTimerPainter(
                    progress: progress,
                    activeColor: phaseColor,
                  ),
                ),
                Text(
                  _formatSeconds(_tabataRemainingSec),
                  style: const TextStyle(
                    color: JooPalette.textPrimary,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTabataSettingBox(
                  label: 'تمرين (ث)',
                  value: _tabataWorkSec,
                  onMinus: () => setState(() {
                    _tabataWorkSec = (_tabataWorkSec - 5).clamp(10, 300);
                    if (!_tabataRunning && _tabataIsWorkPhase) {
                      _tabataRemainingSec = _tabataWorkSec;
                    }
                  }),
                  onPlus: () => setState(() {
                    _tabataWorkSec = (_tabataWorkSec + 5).clamp(10, 300);
                    if (!_tabataRunning && _tabataIsWorkPhase) {
                      _tabataRemainingSec = _tabataWorkSec;
                    }
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTabataSettingBox(
                  label: 'راحة (ث)',
                  value: _tabataRestSec,
                  onMinus: () => setState(() {
                    _tabataRestSec = (_tabataRestSec - 5).clamp(5, 180);
                    if (!_tabataRunning && !_tabataIsWorkPhase) {
                      _tabataRemainingSec = _tabataRestSec;
                    }
                  }),
                  onPlus: () => setState(() {
                    _tabataRestSec = (_tabataRestSec + 5).clamp(5, 180);
                    if (!_tabataRunning && !_tabataIsWorkPhase) {
                      _tabataRemainingSec = _tabataRestSec;
                    }
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTabataSettingBox(
                  label: 'الجولات',
                  value: _tabataTotalRounds,
                  onMinus: () => setState(() {
                    _tabataTotalRounds = (_tabataTotalRounds - 1).clamp(1, 30);
                  }),
                  onPlus: () => setState(() {
                    _tabataTotalRounds = (_tabataTotalRounds + 1).clamp(1, 30);
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: JooPressableButton(
                  color: _tabataRunning
                      ? JooPalette.warmAmber
                      : JooPalette.emeraldGreen,
                  onPressed: () =>
                      setState(() => _tabataRunning = !_tabataRunning),
                  child: Text(
                    _tabataRunning ? 'إيقاف مؤقت' : 'ابدأ التاباتا 🔥',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              JooPressableButton(
                color: JooPalette.cardElevated,
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
                    color: JooPalette.textSecondary,
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
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: JooPalette.bgGrouped,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: JooPalette.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: const TextStyle(
              color: JooPalette.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
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
    final totalSeconds = _stopwatchDeciSeconds ~/ 10;
    final deci = _stopwatchDeciSeconds % 10;

    return JooGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            '${_formatSeconds(totalSeconds)}.$deci',
            style: const TextStyle(
              color: JooPalette.textPrimary,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: JooPressableButton(
                  color: _stopwatchRunning
                      ? JooPalette.coralRed
                      : JooPalette.emeraldGreen,
                  onPressed: () =>
                      setState(() => _stopwatchRunning = !_stopwatchRunning),
                  child: Text(
                    _stopwatchRunning ? 'إيقاف' : 'تشغيل',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: JooPressableButton(
                  color: JooPalette.cardElevated,
                  onPressed: () {
                    if (_stopwatchRunning) {
                      setState(
                          () => _stopwatchLaps.insert(0, _stopwatchDeciSeconds));
                    } else {
                      setState(() {
                        _stopwatchDeciSeconds = 0;
                        _stopwatchLaps.clear();
                      });
                    }
                  },
                  child: Text(
                    _stopwatchRunning ? 'تسجيل لفة (Lap)' : 'تصفير',
                    style: const TextStyle(
                      color: JooPalette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_stopwatchLaps.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...List.generate(_stopwatchLaps.length, (i) {
              final lapDeci = _stopwatchLaps[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: JooPalette.bgGrouped,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'جولة #${_stopwatchLaps.length - i}',
                      style: const TextStyle(
                        color: JooPalette.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    Text(
                      '${_formatSeconds(lapDeci ~/ 10)}.${lapDeci % 10}',
                      style: const TextStyle(
                        color: JooPalette.textPrimary,
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
  // التبويب 4: المتابعة التفصيلية الذكية + أدوات الجيم المهمة جداً + الموسوعة
  // ==========================================================================

  Widget _buildSmartToolsAndTrackingTab() {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
      children: [
        const Text(
          'المتابعة التفصيلية وأدوات الجيم الذكية',
          style: TextStyle(
            color: JooPalette.textPrimary,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'متابعة ذكية لتطور جسمك وسجل أيامك، مع حاسبة الطارات والسعرات والماكروز وموسوعة التمارين.',
          style: TextStyle(
            color: JooPalette.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: JooPalette.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: JooPalette.separator.withOpacity(0.5)),
          ),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _toolsSubTab,
            backgroundColor: Colors.transparent,
            thumbColor: _accent,
            children: const {
              0: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'متابعتي وسجلي',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              1: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'أدوات الجيم الذكية',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              2: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'موسوعة التمارين',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            },
            onValueChanged: (v) {
              if (v != null) {
                JooSoundService.instance.playTap();
                setState(() => _toolsSubTab = v);
              }
            },
          ),
        ),
        const SizedBox(height: 16),

        if (_toolsSubTab == 0) _buildDetailedPersonalTrackingView(),
        if (_toolsSubTab == 1) _buildSmartGymToolsSuiteView(),
        if (_toolsSubTab == 2) _buildExerciseEncyclopediaView(),
      ],
    );
  }

  Widget _buildDetailedPersonalTrackingView() {
    const muscles = [
      'الصدر',
      'الظهر',
      'الأكتاف',
      'البايسبس',
      'الترايسبس',
      'الأرجل',
      'البطن',
    ];

    final totalWorkouts = _dailyFollowUpLogs.length;
    final totalLoggedVolume = _dailyFollowUpLogs.fold<double>(
        0.0, (sum, item) => sum + item.totalVolumeKg);

    return Column(
      children: [
        // بطاقة الملف الشخصي والتحليل الذكي للجسم
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.person_badge_plus_fill,
                          color: _accent, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'ملف البطل: ${_profile.name.isEmpty ? "بطل الجيم" : _profile.name}',
                        style: const TextStyle(
                          color: JooPalette.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  JooPressableButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 10,
                    color: _accent.withOpacity(0.18),
                    onPressed: _openFullSetupWizardModal,
                    child: Text(
                      'تعديل بياناتي',
                      style: TextStyle(
                        color: _accent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatMiniBox('السن', '${_profile.age} سنة', JooPalette.royalBlue),
                  const SizedBox(width: 8),
                  _buildStatMiniBox('الوزن', '${_profile.weightKg.toStringAsFixed(1)} كجم', JooPalette.emeraldGreen),
                  const SizedBox(width: 8),
                  _buildStatMiniBox('الطول', '${_profile.heightCm.toStringAsFixed(0)} سم', JooPalette.calmTeal),
                  const SizedBox(width: 8),
                  _buildStatMiniBox('BMI', _profile.bmi.toStringAsFixed(1), JooPalette.warmAmber),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: JooPalette.bgGrouped,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تحليل جسمك الذكي: ${_profile.bmiStatusEgyptian}',
                      style: const TextStyle(
                        color: JooPalette.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'هدفك: ${_profile.fitnessGoal} • سعراتك: ${_profile.dailyCaloriesTarget} سعرة • بروتين: ${_profile.dailyProteinTargetGrams}ج • كارب: ${_profile.dailyCarbsTargetGrams}ج • دهون: ${_profile.dailyFatsTargetGrams}ج',
                      style: const TextStyle(
                        color: JooPalette.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // الرسم البياني لتطور الوزن لو فيه قراءات
        if (_weightHistory.length >= 2)
          JooGlassCard(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'مؤشر تطور وزنك بالكيلو 📈',
                  style: TextStyle(
                    color: JooPalette.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            _weightHistory.length,
                            (i) => FlSpot(
                              i.toDouble(),
                              _weightHistory[i].weightKg,
                            ),
                          ),
                          isCurved: true,
                          color: _accent,
                          barWidth: 3.5,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: _accent.withOpacity(0.16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        // سجل المتابعة اليومية الشامل
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(CupertinoIcons.doc_chart_fill,
                          color: _accent, size: 19),
                      const SizedBox(width: 8),
                      const Text(
                        'سجل المتابعة اليومية والتمارين المسجلة',
                        style: TextStyle(
                          color: JooPalette.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$totalWorkouts يوم مسجل (${totalLoggedVolume.toStringAsFixed(0)} كجم)',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_dailyFollowUpLogs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'لسه مسجلتش أيام في السجل.. بعد ما تخلص تمرينك اضغط "إنهاء وتسجيل تمرين النهاردة" وهتلاقي كل يوم مسجل هنا بالتفصيل!',
                      style: TextStyle(
                        color: JooPalette.textMuted,
                        fontSize: 12.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ..._dailyFollowUpLogs.map((log) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: JooPalette.bgGrouped,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                log.workoutTitle,
                                style: const TextStyle(
                                  color: JooPalette.textPrimary,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              _formatDateEgyptian(log.date),
                              style: const TextStyle(
                                color: JooPalette.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${log.completedSetsCount} مجموعة • أوزان: ${log.totalVolumeKg.toStringAsFixed(0)} كجم • وزنك: ${log.recordedBodyWeightKg.toStringAsFixed(1)} كجم • ميه: ${log.waterCups} كوب • بروتين: ${log.proteinGrams}ج',
                          style: const TextStyle(
                            color: JooPalette.textSecondary,
                            fontSize: 11.5,
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

        // حالة استشفاء العضلات
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.heart_fill,
                    color: JooPalette.emeraldGreen,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'حالة استشفاء عضلاتك دلوقتي',
                    style: TextStyle(
                      color: JooPalette.textPrimary,
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
                    ? JooPalette.emeraldGreen
                    : (rec >= 0.5 ? JooPalette.warmAmber : JooPalette.coralRed);
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
                              color: JooPalette.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            rec >= 0.85
                                ? '${(rec * 100).toInt()}% (جاهزة تفرمها ✓)'
                                : '${(rec * 100).toInt()}% (بتعمل استشفاء)',
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
                          backgroundColor: JooPalette.bgGrouped,
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
      ],
    );
  }

  Widget _buildStatMiniBox(String title, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: JooPalette.bgGrouped,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: JooPalette.textMuted, fontSize: 10.5),
            ),
            const SizedBox(height: 4),
            Text(
              val,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartGymToolsSuiteView() {
    // 1. حساب الطارات على البار (Plate Calculator)
    final double weightPerSide =
        math.max(0.0, (_plateTargetWeightKg - _plateBarWeightKg) / 2.0);
    double rem = weightPerSide;
    final List<double> standardPlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25];
    final List<double> platesPerSide = [];
    for (final p in standardPlates) {
      while (rem >= p - 0.01) {
        platesPerSide.add(p);
        rem -= p;
      }
    }

    // 2. حساب أقصى وزن 1RM
    final oneRepMax = _calcReps == 1
        ? _calcWeightKg
        : _calcWeightKg * (1 + (_calcReps / 30.0));
    final percentages = [95, 90, 85, 80, 75, 70];

    return Column(
      children: [
        // الأداة 1: حاسبة أوزان البار والطارات الذكية
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.circle_grid_hex_fill,
                      color: _accent, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'حاسبة طارات البار الذكية (Plate Calculator)',
                    style: TextStyle(
                      color: JooPalette.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'اختار الوزن الإجمالي اللي عايز تشيله، والتطبيق هيقولك تركب طارات كام في كل ناحية بالظبط!',
                style: TextStyle(color: JooPalette.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الوزن الإجمالي بالبار: ${_plateTargetWeightKg.toStringAsFixed(1)} كجم',
                    style: const TextStyle(
                      color: JooPalette.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      _buildMiniStepBtn(
                        icon: CupertinoIcons.minus,
                        onTap: () => setState(() {
                          _plateTargetWeightKg =
                              (_plateTargetWeightKg - 2.5).clamp(20.0, 300.0);
                        }),
                      ),
                      const SizedBox(width: 8),
                      _buildMiniStepBtn(
                        icon: CupertinoIcons.plus,
                        onTap: () => setState(() {
                          _plateTargetWeightKg =
                              (_plateTargetWeightKg + 2.5).clamp(20.0, 300.0);
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              CupertinoSlider(
                value: _plateTargetWeightKg.clamp(20.0, 260.0),
                min: 20.0,
                max: 260.0,
                divisions: 96,
                activeColor: _accent,
                onChanged: (v) => setState(() => _plateTargetWeightKg = v),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: JooPalette.bgGrouped,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'وزن البار: ${_plateBarWeightKg.toInt()} كجم • الوزن في كل ناحية: ${weightPerSide.toStringAsFixed(2)} كجم',
                      style: const TextStyle(
                        color: JooPalette.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (platesPerSide.isEmpty)
                      const Text(
                        'البار فاضي (من غير طارات)',
                        style: TextStyle(
                          color: JooPalette.warmAmber,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: platesPerSide.map((p) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _accent.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _accent),
                            ),
                            child: Text(
                              'طارة ${p % 1 == 0 ? p.toInt() : p} كجم',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // الأداة 2: حاسبة السعرات والماكروز التفصيلية
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.flame_fill,
                    color: JooPalette.warmAmber,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'حاسبة السعرات والماكروز اليومية لجسمك',
                    style: TextStyle(
                      color: JooPalette.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatMiniBox(
                    'سعراتك',
                    '${_profile.dailyCaloriesTarget}',
                    JooPalette.warmAmber,
                  ),
                  const SizedBox(width: 8),
                  _buildStatMiniBox(
                    'بروتين',
                    '${_profile.dailyProteinTargetGrams} جرام',
                    JooPalette.emeraldGreen,
                  ),
                  const SizedBox(width: 8),
                  _buildStatMiniBox(
                    'كارب',
                    '${_profile.dailyCarbsTargetGrams} جرام',
                    JooPalette.royalBlue,
                  ),
                  const SizedBox(width: 8),
                  _buildStatMiniBox(
                    'دهون صحية',
                    '${_profile.dailyFatsTargetGrams} جرام',
                    JooPalette.calmTeal,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // الأداة 3: حاسبة أقصى وزن (1RM)
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(CupertinoIcons.speedometer, color: _accent, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'حاسبة أقصى وزن تشيله لعدة واحدة (1RM)',
                    style: TextStyle(
                      color: JooPalette.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _accent.withOpacity(0.45)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'أقصى وزن متوقع لعدة واحدة (1RM):',
                      style: TextStyle(
                        color: JooPalette.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${oneRepMax.toStringAsFixed(1)} كجم',
                      style: TextStyle(
                        color: _accent,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'الوزن اللي بتلعب بيه: ${_calcWeightKg.toStringAsFixed(1)} كجم',
                style: const TextStyle(
                  color: JooPalette.textPrimary,
                  fontSize: 13,
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
              Text(
                'عدد العدات بالوزن ده: $_calcReps عدات',
                style: const TextStyle(
                  color: JooPalette.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CupertinoSlider(
                value: _calcReps.toDouble().clamp(1.0, 20.0),
                min: 1.0,
                max: 20.0,
                divisions: 19,
                activeColor: JooPalette.emeraldGreen,
                onChanged: (v) => setState(() => _calcReps = v.round()),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: JooPalette.bgGrouped,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$pct% — $targetReps',
                        style: const TextStyle(
                          color: JooPalette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${w.toStringAsFixed(1)} كجم',
                        style: const TextStyle(
                          color: JooPalette.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
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
      'كارديو',
    ];

    final filtered = SmartScheduleEngine.egyptianExerciseCatalog.where((item) {
      final matchCat = _selectedMuscleFilter == 'الكل' ||
          item.muscle == _selectedMuscleFilter;
      final matchQuery = _exerciseSearchQuery.isEmpty ||
          item.name.toLowerCase().contains(_exerciseSearchQuery.toLowerCase());
      return matchCat && matchQuery;
    }).toList();

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: JooPalette.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: JooPalette.separator),
          ),
          child: TextField(
            onChanged: (v) => setState(() => _exerciseSearchQuery = v),
            style:
                const TextStyle(color: JooPalette.textPrimary, fontSize: 13.5),
            decoration: const InputDecoration(
              hintText: 'دور على أي تمرين بالاسم...',
              hintStyle:
                  TextStyle(color: JooPalette.textMuted, fontSize: 12.5),
              prefixIcon: Icon(
                CupertinoIcons.search,
                color: JooPalette.textMuted,
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
                child: JooPressableButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  borderRadius: 12,
                  color: sel ? _accent : JooPalette.cardSurface,
                  onPressed: () => setState(() => _selectedMuscleFilter = cat),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: sel ? Colors.white : JooPalette.textSecondary,
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
          return JooGlassCard(
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
                          '${item.muscle} • ${item.equipment}',
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
                          color: JooPalette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.tipEgyptian,
                        style: const TextStyle(
                          color: JooPalette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                JooPressableButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  borderRadius: 12,
                  color: _accent,
                  onPressed: () {
                    JooSoundService.instance.playSuccess();
                    setState(() {
                      _currentWorkoutDay.isRestDay = false;
                      _currentWorkoutDay.exercises.add(
                        ExerciseItem.create(
                          name: item.name,
                          muscleGroup: item.muscle,
                          equipment: item.equipment,
                          setsCount: item.defaultSets,
                          repsCount: item.defaultReps,
                          startWeight: 0.0,
                          restSeconds: 90,
                          notes: item.tipEgyptian,
                        ),
                      );
                    });
                    _saveAppState();
                    _showSmartBanner(
                      title: 'اتضاف التمرين ليوم ${_currentWorkoutDay.weekDayName} ✓',
                      subtitle: item.name,
                      icon: CupertinoIcons.add_circled_solid,
                      color: JooPalette.emeraldGreen,
                    );
                  },
                  child: Text(
                    '+ ليوم ${_currentWorkoutDay.weekDayName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
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

  // ==========================================================================
  // التبويب 5: التنبيهات الذكية والإعدادات وبيانات المطور JOO
  // ==========================================================================

  Widget _buildAlertsAndSettingsTab() {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 130),
      children: [
        const Text(
          'التنبيهات الذكية والإعدادات',
          style: TextStyle(
            color: JooPalette.textPrimary,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'تحكم في إشعارات التمرين، أصوات اللمس، بياناتك الشخصية، وتواصل مع المطور JOO.',
          style: TextStyle(
            color: JooPalette.textSecondary,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 16),

        // كارت المطور JOO للتواصل واتس 01029892573 (في صدارة الإعدادات بوضوح وأناقة)
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          borderColor: JooPalette.emeraldGreen.withOpacity(0.6),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      CupertinoIcons.shield_fill,
                      color: _accent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المطور: JOO',
                          style: TextStyle(
                            color: JooPalette.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'للتواصل واتس: 01029892573',
                          style: TextStyle(
                            color: JooPalette.emeraldGreen,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'JOOFIT PRO • تصميم ذكي ومريح للعين',
                          style: TextStyle(
                            color: JooPalette.textMuted,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: JooPressableButton(
                      color: JooPalette.emeraldGreen,
                      onPressed: () async {
                        final uri = Uri.parse('https://wa.me/201029892573');
                        try {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (_) {}
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.chat_bubble_text_fill,
                            color: Colors.white,
                            size: 17,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'تواصل واتساب: 01029892573',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  JooPressableButton(
                    color: JooPalette.cardElevated,
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(text: '01029892573'),
                      );
                      _showSmartBanner(
                        title: 'تم نسخ رقم المطور JOO ✓',
                        subtitle: '01029892573 جاهز للصق في واتساب',
                        icon: CupertinoIcons.doc_on_clipboard_fill,
                        color: JooPalette.emeraldGreen,
                      );
                    },
                    child: const Icon(
                      CupertinoIcons.doc_on_clipboard,
                      color: JooPalette.textPrimary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // التحكم في أصوات اللمس والاهتزاز وتعديل البيانات
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إعدادات الصوت والبيانات الشخصية',
                style: TextStyle(
                  color: JooPalette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أصوات اللمس التفاعلية',
                          style: TextStyle(
                            color: JooPalette.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'صوت نقر ناعم عند الضغط على الأزرار وإتمام المجموعات',
                          style: TextStyle(
                            color: JooPalette.textMuted,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: JooSoundService.instance.soundEnabled,
                    activeColor: JooPalette.emeraldGreen,
                    onChanged: (v) {
                      setState(() {
                        JooSoundService.instance.soundEnabled = v;
                      });
                      if (v) JooSoundService.instance.playSuccess();
                      _saveAppState();
                    },
                  ),
                ],
              ),
              const Divider(color: JooPalette.separator, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الاهتزاز الذكي مع اللمس والتنبيهات',
                          style: TextStyle(
                            color: JooPalette.textPrimary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'اهتزاز خفيف عند التفاعل واهتزاز قوي عند انتهاء المؤقت',
                          style: TextStyle(
                            color: JooPalette.textMuted,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoSwitch(
                    value: JooSoundService.instance.vibrationEnabled,
                    activeColor: JooPalette.emeraldGreen,
                    onChanged: (v) {
                      setState(() {
                        JooSoundService.instance.vibrationEnabled = v;
                      });
                      _saveAppState();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              JooPressableButton(
                fullWidth: true,
                color: _accent,
                onPressed: _openFullSetupWizardModal,
                child: const Text(
                  'تعديل بياناتي الشخصية وجدول التمرين واشتراك الجيم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // مركز الإشعارات والتذكير باليوم
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'جدول الإشعارات والتنبيهات الذكية',
                    style: TextStyle(
                      color: JooPalette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  JooPressableButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: 10,
                    color: _accent.withOpacity(0.18),
                    onPressed: () async {
                      await SmartNotificationService.instance
                          .requestPermissionsSafe();
                      await SmartNotificationService.instance
                          .showSmartNotification(
                        id: 999,
                        title:
                            'تذكير ذكي من JOOFIT يا ${_profile.name.isEmpty ? "بطل" : _profile.name} 💪',
                        body:
                            'تمرينك النهاردة: (${_currentWorkoutDay.title}) الساعة ${_currentWorkoutDay.scheduledTime} — فاضل ${_profile.daysUntilGymRenewal} يوم على تجديد الجيم!',
                      );
                      _showSmartBanner(
                        title: 'وصلك إشعار تذكير بتمرين النهاردة 🔔',
                        subtitle: _currentWorkoutDay.title,
                        icon: CupertinoIcons.bell_fill,
                        color: _accent,
                      );
                    },
                    child: Text(
                      'إرسال تذكير باليوم الآن',
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
              ..._smartReminders.map((rem) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: JooPalette.bgGrouped,
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
                                Flexible(
                                  child: Text(
                                    rem.title,
                                    style: const TextStyle(
                                      color: JooPalette.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                color: JooPalette.textMuted,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CupertinoSwitch(
                        value: rem.enabled,
                        activeColor: JooPalette.emeraldGreen,
                        onChanged: (v) {
                          JooSoundService.instance.playTap();
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

        // تخصيص ألوان التطبيق المريحة للعين
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختار لون التطبيق المريح لعينك',
                style: TextStyle(
                  color: JooPalette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  JooPalette.accentPresets.length,
                  (index) {
                    final c = JooPalette.accentPresets[index];
                    final name = JooPalette.accentNames[index];
                    final selected = _accentIndex == index;
                    return GestureDetector(
                      onTap: () {
                        JooSoundService.instance.playTap();
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
                              : JooPalette.bgGrouped,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? c : JooPalette.separator,
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
                                    ? JooPalette.textPrimary
                                    : JooPalette.textSecondary,
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
      ],
    );
  }

  // ==========================================================================
  // نوافذ إضافة تمرين جديد لأي يوم وإضافة مهام الجيم
  // ==========================================================================

  void _openAddExerciseSheetForDay(WorkoutDay targetDay) {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: '4');
    final repsCtrl = TextEditingController(text: '10');
    final weightCtrl = TextEditingController(text: '0');
    final restCtrl = TextEditingController(text: '90');
    String selectedMuscle = targetDay.targetMuscles.isNotEmpty
        ? targetDay.targetMuscles.first
        : 'الصدر';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final quickMatches = SmartScheduleEngine.egyptianExerciseCatalog
                .where((e) => e.muscle == selectedMuscle)
                .toList();

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: JooPalette.cardSurface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(26)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 5,
                            decoration: BoxDecoration(
                              color: JooPalette.separator,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'إضافة تمرين ليوم ${targetDay.weekDayName}',
                          style: const TextStyle(
                            color: JooPalette.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'اختار العضلة المستهدفة:',
                          style: TextStyle(
                            color: JooPalette.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: kAllMuscleGroups.map((m) {
                            final sel = selectedMuscle == m;
                            return GestureDetector(
                              onTap: () {
                                JooSoundService.instance.playTick();
                                setSheetState(() => selectedMuscle = m);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: sel ? _accent : JooPalette.bgGrouped,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  m,
                                  style: TextStyle(
                                    color: sel
                                        ? Colors.white
                                        : JooPalette.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        if (quickMatches.isNotEmpty) ...[
                          const Text(
                            'أو اختار تمرين سريع من القائمة:',
                            style: TextStyle(
                              color: JooPalette.textMuted,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: quickMatches.map((qm) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: GestureDetector(
                                    onTap: () {
                                      JooSoundService.instance.playTick();
                                      setSheetState(() {
                                        nameCtrl.text = qm.name;
                                        setsCtrl.text = '${qm.defaultSets}';
                                        repsCtrl.text = '${qm.defaultReps}';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: JooPalette.bgGrouped,
                                        borderRadius: BorderRadius.circular(9),
                                        border: Border.all(
                                            color: JooPalette.separator),
                                      ),
                                      child: Text(
                                        qm.name,
                                        style: const TextStyle(
                                          color: JooPalette.textSecondary,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        TextField(
                          controller: nameCtrl,
                          style: const TextStyle(color: JooPalette.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'اسم التمرين (مثلاً: بنش مسطح بالبار)',
                            hintStyle:
                                const TextStyle(color: JooPalette.textMuted),
                            filled: true,
                            fillColor: JooPalette.bgGrouped,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildSheetNumberField(
                                label: 'كام مجموعة؟',
                                ctrl: setsCtrl,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildSheetNumberField(
                                label: 'كام عدة؟',
                                ctrl: repsCtrl,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildSheetNumberField(
                                label: 'الوزن (كجم)',
                                ctrl: weightCtrl,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildSheetNumberField(
                                label: 'الراحة (ث)',
                                ctrl: restCtrl,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        JooPressableButton(
                          fullWidth: true,
                          color: _accent,
                          onPressed: () {
                            final name = nameCtrl.text.trim().isEmpty
                                ? 'تمرين $selectedMuscle'
                                : nameCtrl.text.trim();
                            final sets = int.tryParse(setsCtrl.text) ?? 4;
                            final reps = int.tryParse(repsCtrl.text) ?? 10;
                            final weight =
                                double.tryParse(weightCtrl.text) ?? 0.0;
                            final rest = int.tryParse(restCtrl.text) ?? 90;

                            JooSoundService.instance.playSuccess();
                            setState(() {
                              targetDay.isRestDay = false;
                              if (!targetDay.targetMuscles
                                  .contains(selectedMuscle)) {
                                targetDay.targetMuscles.add(selectedMuscle);
                              }
                              targetDay.title =
                                  '${targetDay.weekDayName}: ${targetDay.targetMuscles.join(" + ")}';
                              targetDay.exercises.add(
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
                            'إضافة التمرين للجدول ✓',
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetNumberField({
    required String label,
    required TextEditingController ctrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: JooPalette.textMuted, fontSize: 11),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: JooPalette.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: JooPalette.bgGrouped,
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
    final taskCtrl = TextEditingController();
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
                color: JooPalette.cardSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'إضافة مهمة أو تذكير للجيم النهاردة',
                    style: TextStyle(
                      color: JooPalette.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: taskCtrl,
                    autofocus: true,
                    style: const TextStyle(color: JooPalette.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'مثلاً: تسخين الكتف كويس، تجهيز شنطة الجيم...',
                      hintStyle: const TextStyle(color: JooPalette.textMuted),
                      filled: true,
                      fillColor: JooPalette.bgGrouped,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  JooPressableButton(
                    fullWidth: true,
                    color: _accent,
                    onPressed: () {
                      final t = taskCtrl.text.trim();
                      if (t.isNotEmpty) {
                        JooSoundService.instance.playSuccess();
                        setState(() {
                          _gymTasks.add(
                            GymTaskItem(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              title: t,
                              done: false,
                              createdAt: DateTime.now(),
                            ),
                          );
                        });
                        _saveAppState();
                      }
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'إضافة المهمة ✓',
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

// ============================================================================
// 9. شاشة البداية الذكية الشاملة (Smart Onboarding & Full Schedule Setup)
// ============================================================================

class _SmartOnboardingWizardScreen extends StatefulWidget {
  final UserProfileData initialProfile;
  final WorkoutSystem initialSystem;
  final Color accentColor;
  final bool isEditingExisting;
  final void Function(UserProfileData profile, WorkoutSystem system)
      onFinishSetup;

  const _SmartOnboardingWizardScreen({
    required this.initialProfile,
    required this.initialSystem,
    required this.accentColor,
    this.isEditingExisting = false,
    required this.onFinishSetup,
  });

  @override
  State<_SmartOnboardingWizardScreen> createState() =>
      _SmartOnboardingWizardScreenState();
}

class _SmartOnboardingWizardScreenState
    extends State<_SmartOnboardingWizardScreen> {
  int _step = 0; // 0: البيانات والجسم، 1: الأيام والاشتراك، 2: تفصيل كل يوم والتمارين، 3: المراجعة والاعتماد

  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _targetWeightCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _gymNameCtrl;
  late TextEditingController _subPriceCtrl;

  late String _fitnessGoal;
  late int _workoutDaysPerWeek;
  late List<String> _selectedDays;
  late String _preferredTime;
  late String _subscriptionType;
  late DateTime _renewalDate;

  late List<WorkoutDay> _draftDays;
  int _editingDayTabIdx = 0;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _nameCtrl = TextEditingController(text: p.name);
    _ageCtrl = TextEditingController(text: '${p.age}');
    _weightCtrl = TextEditingController(
      text: p.weightKg % 1 == 0
          ? '${p.weightKg.toInt()}'
          : p.weightKg.toStringAsFixed(1),
    );
    _targetWeightCtrl = TextEditingController(
      text: p.targetWeightKg % 1 == 0
          ? '${p.targetWeightKg.toInt()}'
          : p.targetWeightKg.toStringAsFixed(1),
    );
    _heightCtrl = TextEditingController(
      text: '${p.heightCm.toInt()}',
    );
    _gymNameCtrl = TextEditingController(text: p.gymName);
    _subPriceCtrl = TextEditingController(
      text: '${p.subscriptionPriceEgp.toInt()}',
    );

    _fitnessGoal = p.fitnessGoal;
    _workoutDaysPerWeek = p.workoutDaysPerWeek;
    _selectedDays = List<String>.from(p.selectedDays);
    _preferredTime = p.preferredWorkoutTime;
    _subscriptionType = p.subscriptionType;
    _renewalDate = p.subscriptionRenewalDate;

    if (widget.isEditingExisting && widget.initialSystem.days.length == 7) {
      _draftDays = widget.initialSystem.days.map((d) => d.cloneDeep()).toList();
    } else {
      _draftDays = SmartScheduleEngine.createInitialSevenDays(
        selectedTrainingDays: _selectedDays,
        defaultTime: _preferredTime,
        goal: _fitnessGoal,
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _targetWeightCtrl.dispose();
    _heightCtrl.dispose();
    _gymNameCtrl.dispose();
    _subPriceCtrl.dispose();
    super.dispose();
  }

  UserProfileData _buildCurrentDraftProfile() {
    return UserProfileData(
      name: _nameCtrl.text.trim().isEmpty ? 'بطل الجيم' : _nameCtrl.text.trim(),
      age: (int.tryParse(_ageCtrl.text.trim()) ?? 22).clamp(12, 90),
      weightKg:
          (double.tryParse(_weightCtrl.text.trim()) ?? 75.0).clamp(30.0, 250.0),
      targetWeightKg:
          (double.tryParse(_targetWeightCtrl.text.trim()) ?? 80.0)
              .clamp(30.0, 250.0),
      heightCm:
          (double.tryParse(_heightCtrl.text.trim()) ?? 175.0).clamp(120.0, 230.0),
      fitnessGoal: _fitnessGoal,
      workoutDaysPerWeek: _selectedDays.length.clamp(1, 7),
      selectedDays: _selectedDays,
      preferredWorkoutTime: _preferredTime,
      gymName: _gymNameCtrl.text.trim(),
      subscriptionType: _subscriptionType,
      subscriptionPriceEgp:
          double.tryParse(_subPriceCtrl.text.trim()) ?? 500.0,
      subscriptionStartDate: DateTime.now(),
      subscriptionRenewalDate: _renewalDate,
      onboardingCompleted: true,
    );
  }

  void _syncDraftDaysWithSelectedWeekdays({bool forceRebuildExercises = false}) {
    final autoDays = SmartScheduleEngine.createInitialSevenDays(
      selectedTrainingDays: _selectedDays,
      defaultTime: _preferredTime,
      goal: _fitnessGoal,
    );

    if (forceRebuildExercises || _draftDays.length != 7) {
      _draftDays = autoDays;
      return;
    }

    for (int i = 0; i < 7; i++) {
      final wName = kEgyptianWeekDays[i];
      final shouldTrain = _selectedDays.contains(wName);
      _draftDays[i].weekDayName = wName;
      if (_draftDays[i].scheduledTime.isEmpty) {
        _draftDays[i].scheduledTime = _preferredTime;
      }
      if (!shouldTrain) {
        _draftDays[i].isRestDay = true;
        _draftDays[i].title = '$wName: يوم راحة واستشفاء عضلي';
        _draftDays[i].subtitle = 'راحة من الحديد لبناء العضلات';
      } else {
        if (_draftDays[i].isRestDay || _draftDays[i].exercises.isEmpty) {
          _draftDays[i] = autoDays[i];
        }
      }
    }
  }

  String _formatDateEgyptian(DateTime dt) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${dt.day} ${months[(dt.month - 1).clamp(0, 11)]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final stepTitles = [
      '1. بياناتك الشخصية وقياسات جسمك',
      '2. أيام ومواعيد التمرين واشتراك الجيم',
      '3. تفصيل جدولك والتمارين والمجموعات لكل يوم',
      '4. مراجعة جدولك واعتماده',
    ];

    return Scaffold(
      backgroundColor: JooPalette.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // شريط التقدم العلوي
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.isEditingExisting
                              ? 'تعديل بياناتي وجدولي المفصل'
                              : 'أهلاً بيك في JOOFIT PRO يا وحش 💪',
                          style: const TextStyle(
                            color: JooPalette.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (widget.isEditingExisting)
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: JooPalette.textMuted,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stepTitles[_step],
                    style: TextStyle(
                      color: widget.accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(4, (i) {
                      final active = i <= _step;
                      return Expanded(
                        child: Container(
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: active
                                ? widget.accentColor
                                : JooPalette.cardElevated,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // محتوى الخطوة الحالية
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  if (_step == 0) _buildStep1PersonalAndBody(),
                  if (_step == 1) _buildStep2DaysTimeAndGymSub(),
                  if (_step == 2) _buildStep3DetailedDailyExercises(),
                  if (_step == 3) _buildStep4FinalReview(),
                ],
              ),
            ),

            // أزرار التنقل السفلية
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: JooPalette.bgGrouped,
                border: Border(
                  top: BorderSide(
                    color: JooPalette.separator.withOpacity(0.6),
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (_step > 0) ...[
                    JooPressableButton(
                      color: JooPalette.cardElevated,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                      onPressed: () => setState(() => _step--),
                      child: const Text(
                        'السابق',
                        style: TextStyle(
                          color: JooPalette.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: JooPressableButton(
                      color: _step == 3
                          ? JooPalette.emeraldGreen
                          : widget.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: () {
                        if (_step < 3) {
                          if (_step == 1) {
                            _syncDraftDaysWithSelectedWeekdays();
                            final firstTrainIdx =
                                _draftDays.indexWhere((d) => !d.isRestDay);
                            if (firstTrainIdx >= 0) {
                              _editingDayTabIdx = firstTrainIdx;
                            }
                          }
                          setState(() => _step++);
                        } else {
                          final finalProfile = _buildCurrentDraftProfile();
                          final finalSystem = WorkoutSystem(
                            id: 'sys_custom_user',
                            name: 'جدول ${finalProfile.name} المفصل',
                            category:
                                '${finalProfile.workoutDaysPerWeek} أيام في الأسبوع',
                            description:
                                'هدف: ${finalProfile.fitnessGoal} • الميعاد: ${finalProfile.preferredWorkoutTime}',
                            daysPerWeek: finalProfile.workoutDaysPerWeek,
                            level: finalProfile.fitnessGoal,
                            days: _draftDays,
                          );
                          widget.onFinishSetup(finalProfile, finalSystem);
                        }
                      },
                      child: Text(
                        _step == 3
                            ? 'اعتمد جدولي وابدأ يا بطل 🔥'
                            : 'الخطوة الجاية ⬅️',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // الخطوة 1: الاسم، العمر، الوزن، الطول، والهدف
  Widget _buildStep1PersonalAndBody() {
    final previewProfile = _buildCurrentDraftProfile();
    final goals = [
      'تضخيم عضلي وزيادة وزن',
      'تنشيف وحرق دهون',
      'زيادة القوة والأوزان',
      'لياقة عامة وشد الجسم',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'عرفنا بيك يا بطل عشان نظبطلك النظام على مقاسك:',
                style: TextStyle(
                  color: JooPalette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildLabeledField(
                label: 'اسمك إيه يا وحش؟',
                hint: 'اكتب اسمك هنا (مثلاً: يوسف)',
                ctrl: _nameCtrl,
                isNumber: false,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildLabeledField(
                      label: 'عندك كام سنة؟',
                      hint: '22',
                      ctrl: _ageCtrl,
                      isNumber: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildLabeledField(
                      label: 'طولك كام (سم)؟',
                      hint: '175',
                      ctrl: _heightCtrl,
                      isNumber: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildLabeledField(
                      label: 'وزنك الحالي (كجم)؟',
                      hint: '75',
                      ctrl: _weightCtrl,
                      isNumber: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildLabeledField(
                      label: 'الوزن اللي عايز توصله؟',
                      hint: '80',
                      ctrl: _targetWeightCtrl,
                      isNumber: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'هدفك الأساسي في الجيم إيه؟',
                style: TextStyle(
                  color: JooPalette.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: goals.map((g) {
                  final sel = _fitnessGoal == g;
                  return GestureDetector(
                    onTap: () {
                      JooSoundService.instance.playTap();
                      setState(() => _fitnessGoal = g);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: sel
                            ? widget.accentColor.withOpacity(0.22)
                            : JooPalette.bgGrouped,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? widget.accentColor : JooPalette.separator,
                          width: sel ? 1.5 : 0.9,
                        ),
                      ),
                      child: Text(
                        g,
                        style: TextStyle(
                          color: sel
                              ? JooPalette.textPrimary
                              : JooPalette.textSecondary,
                          fontSize: 12.5,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // بطاقة التحليل الذكي الفوري لبيانات الجسم
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          borderColor: JooPalette.emeraldGreen.withOpacity(0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.sparkles,
                    color: JooPalette.emeraldGreen,
                    size: 19,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'حسابات جسمك الذكية (تتحدث تلقائياً):',
                    style: TextStyle(
                      color: JooPalette.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '• مؤشر كتلة الجسم (BMI): ${previewProfile.bmi.toStringAsFixed(1)} (${previewProfile.bmiStatusEgyptian})',
                style: const TextStyle(
                  color: JooPalette.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• السعرات اليومية المطلوبة لهدفك: ${previewProfile.dailyCaloriesTarget} سعرة حرارية',
                style: const TextStyle(
                  color: JooPalette.warmAmber,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• احتياجك اليومي: ${previewProfile.dailyProteinTargetGrams} جرام بروتين • ${previewProfile.dailyWaterTargetCups} كوبايات ميه',
                style: const TextStyle(
                  color: JooPalette.emeraldGreen,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // الخطوة 2: كام مرة في الأسبوع، إيه هي الأيام، التوقيت، واشتراك الجيم وموعد التجديد
  Widget _buildStep2DaysTimeAndGymSub() {
    final timesList = [
      '08:00 صباحاً',
      '12:00 ظهراً',
      '03:00 عصراً',
      '05:00 مساءً',
      '06:00 مساءً',
      '07:30 مساءً',
      '09:00 مساءً',
      '10:30 مساءً',
    ];

    final subTypes = [
      ('شهري (30 يوم)', 'شهري', 30),
      ('3 شهور (90 يوم)', '3 شهور', 90),
      ('6 شهور (180 يوم)', '6 شهور', 180),
      ('سنوي (365 يوم)', 'سنوي', 365),
      ('بالحصة / مخصص', 'بالحصة', 14),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // أيام التمرين والتوقيت
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'بتتمرن كام يوم في الأسبوع؟ (${_selectedDays.length} أيام مختارة)',
                style: const TextStyle(
                  color: JooPalette.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'علم على الأيام اللي بتروح فيها الجيم في الأسبوع:',
                style: TextStyle(color: JooPalette.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kEgyptianWeekDays.map((dayName) {
                  final sel = _selectedDays.contains(dayName);
                  return GestureDetector(
                    onTap: () {
                      JooSoundService.instance.playTap();
                      setState(() {
                        if (sel) {
                          if (_selectedDays.length > 1) {
                            _selectedDays.remove(dayName);
                          }
                        } else {
                          _selectedDays.add(dayName);
                        }
                        _workoutDaysPerWeek = _selectedDays.length;
                        _syncDraftDaysWithSelectedWeekdays();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? widget.accentColor : JooPalette.bgGrouped,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? widget.accentColor : JooPalette.separator,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            sel
                                ? CupertinoIcons.checkmark_circle_fill
                                : CupertinoIcons.circle,
                            color: sel ? Colors.white : JooPalette.textMuted,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dayName,
                            style: TextStyle(
                              color:
                                  sel ? Colors.white : JooPalette.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'توقيت تمرينك المفضل الساعة كام؟',
                style: TextStyle(
                  color: JooPalette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: timesList.map((t) {
                  final sel = _preferredTime == t;
                  return GestureDetector(
                    onTap: () {
                      JooSoundService.instance.playTick();
                      setState(() {
                        _preferredTime = t;
                        for (final d in _draftDays) {
                          d.scheduledTime = t;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: sel
                            ? JooPalette.emeraldGreen.withOpacity(0.22)
                            : JooPalette.bgGrouped,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel
                              ? JooPalette.emeraldGreen
                              : JooPalette.separator,
                        ),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          color: sel
                              ? JooPalette.emeraldGreen
                              : JooPalette.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // تفاصيل اشتراك الجيم وموعد التجديد
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    CupertinoIcons.creditcard_fill,
                    color: JooPalette.warmAmber,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'بيانات اشتراكك في الجيم وميعاد التجديد:',
                    style: TextStyle(
                      color: JooPalette.textPrimary,
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
                    flex: 2,
                    child: _buildLabeledField(
                      label: 'اسم الجيم بتاعك (اختياري)',
                      hint: 'مثلاً: Power Gym',
                      ctrl: _gymNameCtrl,
                      isNumber: false,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildLabeledField(
                      label: 'قيمة الاشتراك (ج.م)',
                      hint: '500',
                      ctrl: _subPriceCtrl,
                      isNumber: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'نوع اشتراكك في الجيم:',
                style: TextStyle(
                  color: JooPalette.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subTypes.map((st) {
                  final sel = _subscriptionType == st.$2;
                  return GestureDetector(
                    onTap: () {
                      JooSoundService.instance.playTap();
                      setState(() {
                        _subscriptionType = st.$2;
                        _renewalDate =
                            DateTime.now().add(Duration(days: st.$3));
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sel
                            ? widget.accentColor.withOpacity(0.22)
                            : JooPalette.bgGrouped,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: sel ? widget.accentColor : JooPalette.separator,
                        ),
                      ),
                      child: Text(
                        st.$1,
                        style: TextStyle(
                          color: sel
                              ? JooPalette.textPrimary
                              : JooPalette.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // تحديد موعد التجديد باليوم والشهر
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: JooPalette.bgGrouped,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: JooPalette.warmAmber.withOpacity(0.45),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ميعاد تجديد الاشتراك القادم:',
                          style: TextStyle(
                            color: JooPalette.textSecondary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDateEgyptian(_renewalDate),
                          style: const TextStyle(
                            color: JooPalette.warmAmber,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ظبط ميعاد التجديد باليوم:',
                          style: TextStyle(
                            color: JooPalette.textMuted,
                            fontSize: 11.5,
                          ),
                        ),
                        Row(
                          children: [
                            JooPressableButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              borderRadius: 9,
                              color: JooPalette.cardElevated,
                              onPressed: () {
                                setState(() {
                                  _renewalDate = _renewalDate
                                      .subtract(const Duration(days: 1));
                                });
                              },
                              child: const Text(
                                '- يوم',
                                style: TextStyle(
                                  color: JooPalette.textPrimary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            JooPressableButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              borderRadius: 9,
                              color: JooPalette.cardElevated,
                              onPressed: () {
                                setState(() {
                                  _renewalDate =
                                      _renewalDate.add(const Duration(days: 1));
                                });
                              },
                              child: const Text(
                                '+ يوم',
                                style: TextStyle(
                                  color: JooPalette.textPrimary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            JooPressableButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              borderRadius: 9,
                              color: widget.accentColor,
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _renewalDate,
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 1000)),
                                );
                                if (picked != null) {
                                  setState(() => _renewalDate = picked);
                                }
                              },
                              child: const Text(
                                'اختار تاريخ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // الخطوة 3: تفصيل كل يوم والتمارين والمجموعات
  Widget _buildStep3DetailedDailyExercises() {
    final currentDay = _draftDays[_editingDayTabIdx.clamp(0, 6)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختار اليوم وحدد العضلات والتمارين وعدد المجاميع اللي عايز تتمرنها فيه:',
          style: TextStyle(
            color: JooPalette.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // شريط اختيار اليوم من الـ 7 أيام
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_draftDays.length, (i) {
              final d = _draftDays[i];
              final sel = i == _editingDayTabIdx;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: JooPressableButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  borderRadius: 13,
                  color: sel ? widget.accentColor : JooPalette.cardSurface,
                  onPressed: () => setState(() => _editingDayTabIdx = i),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        d.isRestDay
                            ? CupertinoIcons.moon_stars_fill
                            : CupertinoIcons.flame_fill,
                        size: 14,
                        color: sel
                            ? Colors.white
                            : (d.isRestDay
                                ? JooPalette.calmTeal
                                : JooPalette.warmAmber),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        d.weekDayName,
                        style: TextStyle(
                          color: sel ? Colors.white : JooPalette.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),

        // كارت تفصيل اليوم المحدد
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'إعداد يوم ${currentDay.weekDayName}',
                    style: const TextStyle(
                      color: JooPalette.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        currentDay.isRestDay ? 'يوم راحة' : 'يوم تمرين 💪',
                        style: TextStyle(
                          color: currentDay.isRestDay
                              ? JooPalette.textMuted
                              : JooPalette.emeraldGreen,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      CupertinoSwitch(
                        value: !currentDay.isRestDay,
                        activeColor: JooPalette.emeraldGreen,
                        onChanged: (val) {
                          JooSoundService.instance.playTap();
                          setState(() {
                            currentDay.isRestDay = !val;
                            if (currentDay.isRestDay) {
                              _selectedDays.remove(currentDay.weekDayName);
                              currentDay.title =
                                  '${currentDay.weekDayName}: يوم راحة واستشفاء';
                            } else {
                              if (!_selectedDays
                                  .contains(currentDay.weekDayName)) {
                                _selectedDays.add(currentDay.weekDayName);
                              }
                              if (currentDay.targetMuscles.isEmpty) {
                                currentDay.targetMuscles = ['الصدر', 'الترايسبس'];
                              }
                              currentDay.title =
                                  '${currentDay.weekDayName}: ${currentDay.targetMuscles.join(" + ")}';
                              if (currentDay.exercises.isEmpty) {
                                currentDay.exercises = SmartScheduleEngine
                                    .generateDefaultExercisesForMuscles(
                                  currentDay.targetMuscles,
                                  goal: _fitnessGoal,
                                );
                              }
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              if (currentDay.isRestDay) ...[
                const SizedBox(height: 12),
                const Text(
                  'اليوم ده متحدد كيوم راحة واستشفاء عضلي. لو عايز تتمرن فيه، شغل زرار "يوم تمرين" اللي فوق!',
                  style: TextStyle(
                    color: JooPalette.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                const Text(
                  '1. هتتمرن عضلات إيه في اليوم ده؟ (مثلاً: صدر مع ترايسبس)',
                  style: TextStyle(
                    color: JooPalette.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: kAllMuscleGroups.map((m) {
                    final sel = currentDay.targetMuscles.contains(m);
                    return GestureDetector(
                      onTap: () {
                        JooSoundService.instance.playTick();
                        setState(() {
                          if (sel) {
                            currentDay.targetMuscles.remove(m);
                          } else {
                            currentDay.targetMuscles.add(m);
                          }
                          currentDay.title = currentDay.targetMuscles.isEmpty
                              ? '${currentDay.weekDayName}: تمرين شامل'
                              : '${currentDay.weekDayName}: ${currentDay.targetMuscles.join(" + ")}';
                          currentDay.subtitle =
                              'العضلات: ${currentDay.targetMuscles.join(" + ")}';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? widget.accentColor.withOpacity(0.22)
                              : JooPalette.bgGrouped,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                sel ? widget.accentColor : JooPalette.separator,
                          ),
                        ),
                        child: Text(
                          m,
                          style: TextStyle(
                            color: sel
                                ? JooPalette.textPrimary
                                : JooPalette.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '2. التمارين والمجاميع (${currentDay.exercises.length} تمارين):',
                      style: const TextStyle(
                        color: JooPalette.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        JooSoundService.instance.playSuccess();
                        setState(() {
                          if (currentDay.targetMuscles.isEmpty) {
                            currentDay.targetMuscles = ['الصدر', 'الترايسبس'];
                          }
                          currentDay.exercises = SmartScheduleEngine
                              .generateDefaultExercisesForMuscles(
                            currentDay.targetMuscles,
                            goal: _fitnessGoal,
                          );
                        });
                      },
                      child: Text(
                        'اقتراح تمارين تلقائي لعضلات اليوم ⚡',
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // قائمة التمارين في اليوم ده مع التحكم في عدد المجاميع والعدات
                ...currentDay.exercises.map((ex) {
                  final currentReps =
                      ex.sets.isNotEmpty ? ex.sets.first.targetReps : 10;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: JooPalette.bgGrouped,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: JooPalette.separator.withOpacity(0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${ex.name} (${ex.muscleGroup})',
                                style: const TextStyle(
                                  color: JooPalette.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                JooSoundService.instance.playTap();
                                setState(() => currentDay.exercises.remove(ex));
                              },
                              child: const Icon(
                                CupertinoIcons.trash,
                                color: JooPalette.coralRed,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // عدد المجموعات
                            Row(
                              children: [
                                const Text(
                                  'المجموعات: ',
                                  style: TextStyle(
                                    color: JooPalette.textMuted,
                                    fontSize: 11.5,
                                  ),
                                ),
                                _buildWizardSmallBtn(
                                  icon: CupertinoIcons.minus,
                                  onTap: () {
                                    if (ex.sets.length > 1) {
                                      setState(() => ex.sets.removeLast());
                                    }
                                  },
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '${ex.sets.length}',
                                    style: TextStyle(
                                      color: widget.accentColor,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                _buildWizardSmallBtn(
                                  icon: CupertinoIcons.plus,
                                  onTap: () {
                                    if (ex.sets.length < 12) {
                                      setState(() {
                                        ex.sets.add(
                                          SetEntry(
                                            setNumber: ex.sets.length + 1,
                                            targetReps: currentReps,
                                            actualReps: currentReps,
                                          ),
                                        );
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            // عدد العدات
                            Row(
                              children: [
                                const Text(
                                  'العدات: ',
                                  style: TextStyle(
                                    color: JooPalette.textMuted,
                                    fontSize: 11.5,
                                  ),
                                ),
                                _buildWizardSmallBtn(
                                  icon: CupertinoIcons.minus,
                                  onTap: () {
                                    setState(() {
                                      final nextR =
                                          (currentReps - 1).clamp(1, 50);
                                      for (final s in ex.sets) {
                                        s.targetReps = nextR;
                                        s.actualReps = nextR;
                                      }
                                    });
                                  },
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '$currentReps',
                                    style: const TextStyle(
                                      color: JooPalette.emeraldGreen,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                _buildWizardSmallBtn(
                                  icon: CupertinoIcons.plus,
                                  onTap: () {
                                    setState(() {
                                      final nextR =
                                          (currentReps + 1).clamp(1, 50);
                                      for (final s in ex.sets) {
                                        s.targetReps = nextR;
                                        s.actualReps = nextR;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 8),
                JooPressableButton(
                  fullWidth: true,
                  color: widget.accentColor.withOpacity(0.2),
                  borderColor: widget.accentColor,
                  onPressed: () => _openWizardAddExerciseDialog(currentDay),
                  child: Text(
                    '+ إضافة تمرين جديد ليوم ${currentDay.weekDayName}',
                    style: TextStyle(
                      color: widget.accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _openWizardAddExerciseDialog(WorkoutDay day) {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: '4');
    final repsCtrl = TextEditingController(text: '10');
    String muscle =
        day.targetMuscles.isNotEmpty ? day.targetMuscles.first : 'الصدر';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final suggestions = SmartScheduleEngine.egyptianExerciseCatalog
                .where((e) => e.muscle == muscle)
                .toList();
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: JooPalette.cardSurface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(26)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إضافة تمرين ليوم ${day.weekDayName}',
                          style: const TextStyle(
                            color: JooPalette.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: kAllMuscleGroups.map((m) {
                            final sel = muscle == m;
                            return GestureDetector(
                              onTap: () {
                                JooSoundService.instance.playTick();
                                setModalState(() => muscle = m);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? widget.accentColor
                                      : JooPalette.bgGrouped,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  m,
                                  style: TextStyle(
                                    color: sel
                                        ? Colors.white
                                        : JooPalette.textSecondary,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        if (suggestions.isNotEmpty) ...[
                          const Text(
                            'اضغط على أي تمرين لاختياره فوراً:',
                            style: TextStyle(
                              color: JooPalette.textMuted,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: suggestions.map((s) {
                              return GestureDetector(
                                onTap: () {
                                  JooSoundService.instance.playTick();
                                  setModalState(() {
                                    nameCtrl.text = s.name;
                                    setsCtrl.text = '${s.defaultSets}';
                                    repsCtrl.text = '${s.defaultReps}';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: JooPalette.bgGrouped,
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: JooPalette.separator),
                                  ),
                                  child: Text(
                                    s.name,
                                    style: const TextStyle(
                                      color: JooPalette.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 10),
                        ],
                        TextField(
                          controller: nameCtrl,
                          style: const TextStyle(color: JooPalette.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'أو اكتب اسم التمرين بنفسك هنا...',
                            hintStyle:
                                const TextStyle(color: JooPalette.textMuted),
                            filled: true,
                            fillColor: JooPalette.bgGrouped,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLabeledField(
                                label: 'عدد المجموعات',
                                hint: '4',
                                ctrl: setsCtrl,
                                isNumber: true,
                                onChanged: (_) {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildLabeledField(
                                label: 'عدد العدات',
                                hint: '10',
                                ctrl: repsCtrl,
                                isNumber: true,
                                onChanged: (_) {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        JooPressableButton(
                          fullWidth: true,
                          color: widget.accentColor,
                          onPressed: () {
                            final exName = nameCtrl.text.trim().isEmpty
                                ? 'تمرين $muscle'
                                : nameCtrl.text.trim();
                            final sc = int.tryParse(setsCtrl.text) ?? 4;
                            final rc = int.tryParse(repsCtrl.text) ?? 10;
                            setState(() {
                              if (!day.targetMuscles.contains(muscle)) {
                                day.targetMuscles.add(muscle);
                              }
                              day.exercises.add(
                                ExerciseItem.create(
                                  name: exName,
                                  muscleGroup: muscle,
                                  setsCount: sc,
                                  repsCount: rc,
                                ),
                              );
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text(
                            'إضافة التمرين لليوم ✓',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // الخطوة 4: المراجعة النهائية للجدول والبيانات
  Widget _buildStep4FinalReview() {
    final p = _buildCurrentDraftProfile();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JooGlassCard(
          padding: const EdgeInsets.all(16),
          borderColor: JooPalette.emeraldGreen.withOpacity(0.6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.checkmark_seal_fill,
                    color: JooPalette.emeraldGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ملخص نظام البطل (${p.name}) الجاهز للتنفيذ:',
                    style: const TextStyle(
                      color: JooPalette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '• السن: ${p.age} سنة • الوزن: ${p.weightKg} كجم • الطول: ${p.heightCm.toInt()} سم (BMI: ${p.bmi.toStringAsFixed(1)})',
                style: const TextStyle(
                  color: JooPalette.textSecondary,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• الهدف: ${p.fitnessGoal} • السعرات: ${p.dailyCaloriesTarget} سعرة • البروتين: ${p.dailyProteinTargetGrams}ج • الميه: ${p.dailyWaterTargetCups} أكواب',
                style: const TextStyle(
                  color: JooPalette.emeraldGreen,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• الجيم: ${p.gymName.isEmpty ? "الجيم" : p.gymName} (${p.subscriptionType}) • ميعاد التجديد: ${_formatDateEgyptian(p.subscriptionRenewalDate)}',
                style: const TextStyle(
                  color: JooPalette.warmAmber,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'جدولك الأسبوعي المتنظم يوم بيوم:',
          style: TextStyle(
            color: JooPalette.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._draftDays.map((d) {
          return JooGlassCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  d.isRestDay
                      ? CupertinoIcons.moon_stars_fill
                      : CupertinoIcons.flame_fill,
                  color: d.isRestDay
                      ? JooPalette.calmTeal
                      : JooPalette.warmAmber,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.title,
                        style: const TextStyle(
                          color: JooPalette.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!d.isRestDay)
                        Text(
                          'الميعاد: ${d.scheduledTime} • ${d.exercises.length} تمارين (${d.totalSets} مجموعة)',
                          style: const TextStyle(
                            color: JooPalette.textMuted,
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
    );
  }

  Widget _buildWizardSmallBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        JooSoundService.instance.playTick();
        onTap();
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: JooPalette.cardElevated,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 12, color: JooPalette.textPrimary),
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required String hint,
    required TextEditingController ctrl,
    required bool isNumber,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: JooPalette.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          onChanged: onChanged,
          style: const TextStyle(
            color: JooPalette.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: JooPalette.textMuted, fontSize: 12),
            filled: true,
            fillColor: JooPalette.bgGrouped,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: JooPalette.separator),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: JooPalette.separator),
            ),
          ),
        ),
      ],
    );
  }
}