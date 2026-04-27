// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'جايدر';

  @override
  String get language => 'اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get units => 'الوحدات';

  @override
  String get unitsMetric => 'متري (كجم / سم)';

  @override
  String get unitsImperial => 'إمبراطوري (رطل / بوصة)';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get selectUnits => 'اختر الوحدات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get account => 'الحساب';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get support => 'الدعم';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get subscriptionPlan => 'خطة الاشتراك';

  @override
  String get billingInfo => 'معلومات الفواتير';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get helpCenter => 'مركز المساعدة';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get error => 'حدث خطأ ما';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get confirm => 'تأكيد';

  @override
  String get done => 'تم';

  @override
  String get add => 'إضافة';

  @override
  String get edit => 'تعديل';

  @override
  String get search => 'بحث';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get home => 'الرئيسية';

  @override
  String get trainees => 'المتدربون';

  @override
  String get trainee => 'المتدرب';

  @override
  String get coach => 'المدرب';

  @override
  String get workout => 'التمرين';

  @override
  String get nutrition => 'التغذية';

  @override
  String get progress => 'التقدم';

  @override
  String get plans => 'الخطط';

  @override
  String get chat => 'المحادثة';

  @override
  String get inviteTrainee => 'دعوة متدرب';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get filter => 'تصفية';

  @override
  String get name => 'الاسم';

  @override
  String get streak => 'الاستمرارية';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يومًا',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
      zero: 'لا أيام',
    );
    return '$_temp0';
  }

  @override
  String get currentStreak => 'الاستمرارية الحالية';

  @override
  String get weight => 'الوزن';

  @override
  String get height => 'الطول';

  @override
  String get age => 'العمر';

  @override
  String get goal => 'الهدف';

  @override
  String get goals => 'الأهداف';

  @override
  String get addGoal => 'إضافة هدف';

  @override
  String get notes => 'الملاحظات';

  @override
  String get coachNotes => 'ملاحظات المدرب';

  @override
  String get cautionNotes => 'تحذيرات';

  @override
  String get feedback => 'التغذية الراجعة';

  @override
  String get measurements => 'القياسات';

  @override
  String get photos => 'الصور';

  @override
  String get inBodyReports => 'تقارير InBody';

  @override
  String get uploadReport => 'رفع تقرير';

  @override
  String get workoutHistory => 'سجل التمارين';

  @override
  String get mealPlan => 'خطة التغذية';

  @override
  String get workoutPlan => 'خطة التمرين';

  @override
  String get calories => 'السعرات الحرارية';

  @override
  String get protein => 'البروتين';

  @override
  String get carbs => 'الكربوهيدرات';

  @override
  String get fat => 'الدهون';

  @override
  String get sets => 'المجموعات';

  @override
  String get reps => 'التكرارات';

  @override
  String get exercise => 'تمرين';

  @override
  String get exercises => 'التمارين';

  @override
  String get complete => 'إكمال';

  @override
  String get completed => 'مكتمل';

  @override
  String get skipped => 'تم التخطي';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get active => 'نشط';

  @override
  String get archived => 'مؤرشف';

  @override
  String get archiveTrainee => 'أرشفة المتدرب';

  @override
  String get deleteTrainee => 'حذف المتدرب';

  @override
  String get confirmDelete => 'هل أنت متأكد من الحذف؟';

  @override
  String get confirmArchive => 'هل أنت متأكد من أرشفة هذا المتدرب؟';

  @override
  String get needsAttention => 'يحتاج إلى اهتمام';

  @override
  String get activityFeed => 'سجل النشاط';

  @override
  String get badges => 'الشارات';

  @override
  String get achievements => 'الإنجازات';

  @override
  String get logWeight => 'تسجيل الوزن';

  @override
  String get logMeal => 'تسجيل وجبة';

  @override
  String get searchFood => 'البحث عن طعام';

  @override
  String get addMeal => 'إضافة وجبة';

  @override
  String get date => 'التاريخ';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get theme => 'المظهر';

  @override
  String get free => 'مجاني';

  @override
  String get kg => 'كجم';

  @override
  String get lb => 'رطل';

  @override
  String get cm => 'سم';

  @override
  String get inchUnit => 'بوصة';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get todaysPlan => 'خطة اليوم';

  @override
  String get noActiveWorkout => 'لا توجد خطة تمرين نشطة';

  @override
  String get noActiveMealPlan => 'لا توجد خطة تغذية نشطة';

  @override
  String get startWorkout => 'بدء التمرين';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get session => 'جلسة';

  @override
  String get sessions => 'الجلسات';

  @override
  String get assign => 'تعيين';

  @override
  String get assignWorkout => 'تعيين تمرين';

  @override
  String get assignNutrition => 'تعيين خطة تغذية';

  @override
  String get bulkActions => 'إجراءات جماعية';

  @override
  String selected(int count) {
    return '$count محدد';
  }

  @override
  String get notificationPreferences => 'تفضيلات الإشعارات';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get workoutReminders => 'تذكيرات التمرين';

  @override
  String get mealReminders => 'تذكيرات الوجبات';

  @override
  String get progressUpdates => 'تحديثات التقدم';

  @override
  String get chatMessages => 'رسائل المحادثة';

  @override
  String get trainSmarter => 'تدرّب بذكاء. معاً.';

  @override
  String get iAmACoach => 'أنا مدرب';

  @override
  String get coachRoleDescription => 'إدارة العملاء وإنشاء الخطط وتتبع التقدم';

  @override
  String get iAmATrainee => 'أنا متدرب';

  @override
  String get traineeRoleDescription => 'اتبع الخطط وسجّل التمارين وحقق أهدافك';

  @override
  String get continueBtn => 'متابعة ←';

  @override
  String get welcomeBackCoach => 'مرحباً بعودتك، مدرب';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟ سجّل الآن';

  @override
  String get createYourAccount => 'إنشاء حسابك';

  @override
  String get invitationCode => 'رمز الدعوة';

  @override
  String get fitnessGoal => 'هدف اللياقة';

  @override
  String get pleaseEnterName => 'يرجى إدخال اسمك';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get pleaseEnterAPassword => 'يرجى إدخال كلمة مرور';

  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get pleaseEnterInvitationCode => 'يرجى إدخال رمز الدعوة';

  @override
  String get createNewPlan => 'إنشاء خطة جديدة';

  @override
  String get exercisesPlan => 'خطة التمارين';

  @override
  String get nutritionPlan => 'خطة التغذية';

  @override
  String get more => 'المزيد';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء النور';

  @override
  String sessionsToday(int count) {
    return '$count جلسات اليوم';
  }

  @override
  String needAttention(int count) {
    return '$count تحتاج اهتمامًا';
  }

  @override
  String get freePlan => 'الخطة المجانية';

  @override
  String get upgrade => 'ترقية';

  @override
  String get clients => 'العملاء';

  @override
  String get clientLimitReached =>
      'تم الوصول لحد العملاء — قم بالترقية لإضافة المزيد';

  @override
  String get todaysSessions => 'جلسات اليوم';

  @override
  String get noSessionsToday => 'لا توجد جلسات مجدولة اليوم.';

  @override
  String get topPerformers => 'أفضل المتدربين';

  @override
  String get topPerformersEmpty => 'سيظهر هنا العملاء الأكثر تفاعلاً.';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get recentActivityEmpty => 'سيظهر هنا نشاط عملائك.';

  @override
  String get pendingInvitations => 'الدعوات المعلقة';

  @override
  String get noPendingInvites => 'لا توجد دعوات معلقة. ادعُ متدرباً للبدء.';

  @override
  String expires(String date) {
    return 'ينتهي في $date';
  }

  @override
  String get pendingInvitation => 'دعوة معلقة';

  @override
  String invited(String email) {
    return 'مدعو: $email';
  }

  @override
  String get noItemsNeedAttention => 'لا توجد عناصر تحتاج إلى اهتمام الآن.';

  @override
  String get viewAllBtn => 'عرض الكل';

  @override
  String traineeCount(int count) {
    return '$count متدرب';
  }

  @override
  String get sort => 'ترتيب';

  @override
  String get sortTrainees => 'ترتيب المتدربين';

  @override
  String get nameAZ => 'الاسم أ-ي';

  @override
  String get nameZA => 'الاسم ي-أ';

  @override
  String get highestAdherence => 'أعلى التزام';

  @override
  String get lowestAdherence => 'أدنى التزام';

  @override
  String get longestStreak => 'أطول سلسلة';

  @override
  String get shortestStreak => 'أقصر سلسلة';

  @override
  String get adherenceWord => 'الالتزام';

  @override
  String missedMeals(int count) {
    return '$count وجبات فائتة';
  }

  @override
  String missedWorkouts(int count) {
    return '$count تمارين فائتة';
  }

  @override
  String get overview => 'نظرة عامة';

  @override
  String get traineeLevel => 'مستوى المتدرب';

  @override
  String get directionGoal => 'الاتجاه / الهدف';

  @override
  String get adherenceLabel => 'الالتزام';

  @override
  String get dayStreak => 'سلسلة الأيام';

  @override
  String get weightLabel => 'الوزن';

  @override
  String get viewHealthHistory => 'عرض التاريخ الصحي والتدريبي';

  @override
  String get weeklySummary => 'الملخص الأسبوعي';

  @override
  String get workouts => 'التمارين';

  @override
  String get details => 'التفاصيل';

  @override
  String get lastActive => 'آخر نشاط';

  @override
  String get nextSession => 'الجلسة القادمة';

  @override
  String get missedWorkoutsAlert => 'تمارين فائتة';

  @override
  String get lowNutritionAdherence => 'التزام تغذية منخفض';

  @override
  String get weightPlateau => 'ثبات الوزن (3+ أسابيع)';

  @override
  String get healthTrainingHistory => 'التاريخ الصحي والتدريبي';

  @override
  String get trainingExperience => 'الخبرة التدريبية';

  @override
  String get previousTraining => 'التدريب السابق';

  @override
  String get reasonForStopping => 'سبب التوقف';

  @override
  String get diseasesConditions => 'الأمراض / الحالات';

  @override
  String get allergiesLabel => 'الحساسية';

  @override
  String get injuriesLabel => 'الإصابات';

  @override
  String get medicationsLabel => 'الأدوية';

  @override
  String get weightTrend => 'منحنى الوزن';

  @override
  String get noWeightLogs => 'لا توجد تسجيلات وزن بعد.';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get bodyMeasurements => 'قياسات الجسم';

  @override
  String get fromTrainee => 'من المتدرب';

  @override
  String get poseCheckIns => 'صور التقدم';

  @override
  String get allDates => 'جميع التواريخ';

  @override
  String get clear => 'مسح';

  @override
  String get noPhotosInRange => 'لا توجد صور في هذا النطاق.';

  @override
  String get front => 'أمامي';

  @override
  String get sideLabel => 'جانبي';

  @override
  String get backLabel => 'خلفي';

  @override
  String get traineeFeedback => 'تقييم المتدرب';

  @override
  String get noFeedbackYet => 'لا توجد تقييمات بعد.';

  @override
  String get latest => 'الأحدث';

  @override
  String feedbackForTrainee(String name) {
    return 'تغذية راجعة لـ $name';
  }

  @override
  String get feedbackHint => 'اكتب تغذيتك الراجعة هنا... ستكون مرئية للمتدرب.';

  @override
  String get cautionMedicalNotes => 'ملاحظات تحذيرية / طبية';

  @override
  String get cautionHint =>
      'الإصابات والقيود والأمور التي يجب الانتباه إليها...';

  @override
  String get saveNotes => 'حفظ الملاحظات';

  @override
  String get saving => 'جارٍ الحفظ…';

  @override
  String get uploading => 'جارٍ الرفع…';

  @override
  String get uploadImageOrPdf => 'رفع صورة أو PDF';

  @override
  String get noInBodyReports => 'لا توجد تقارير InBody بعد.';

  @override
  String get inBodyReportsSubtitle =>
      'ارفع الفحوصات أو ملفات PDF من الجهاز. وسّع صفاً للمعاينة.';

  @override
  String get noGoalsYet => 'لا توجد أهداف بعد.';

  @override
  String get tapToMarkDone =>
      'اضغط للتحديد كمنجز · اضغط ✏ للتعديل · اسحب لليسار للحذف';

  @override
  String get addNewGoal => 'أضف هدفاً جديداً...';

  @override
  String get editGoal => 'تعديل الهدف';

  @override
  String get goalDescription => 'وصف الهدف…';

  @override
  String get levelAndGoal => 'المستوى والهدف';

  @override
  String get traineeLevelLabel => 'مستوى المتدرب';

  @override
  String get goalHint => 'مثال: إنقاص 5 كجم، بناء العضلات...';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get traineeInfo => 'معلومات المتدرب';

  @override
  String get archiveTraineeQuestion => 'أرشفة المتدرب؟';

  @override
  String archiveTraineeBody(String name) {
    return 'سيتم أرشفة $name. يمكنك استعادته لاحقاً إذا كان تطبيقك يدعم ذلك.';
  }

  @override
  String get archive => 'أرشفة';

  @override
  String get deleteTraineePermanently => 'حذف المتدرب نهائياً؟';

  @override
  String deleteTraineeBody(String name) {
    return 'سيؤدي ذلك إلى إزالة $name وبياناته. لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get deleteTraineePermanentlyBtn => 'حذف المتدرب نهائياً';

  @override
  String get planAssignedSuccess => 'تم تعيين الخطة بنجاح!';

  @override
  String get templateSavedMsg => 'تم حفظ القالب على هذا الجهاز';

  @override
  String get draftSavedMsg => 'تم حفظ المسودة على هذا الجهاز';

  @override
  String get savedTemplates => 'القوالب المحفوظة';

  @override
  String get startFromScratch => 'البدء من الصفر';

  @override
  String get searchTrainees => 'البحث عن متدربين...';

  @override
  String get noActiveTraineesFound => 'لا يوجد متدربون نشطون';

  @override
  String get inviteTraineesFirst => 'ادعُ متدربين أولاً لإنشاء خطة';

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get assignmentDate => 'تاريخ التعيين';

  @override
  String get recurrence => 'التكرار';

  @override
  String get selectDateOrAssignImmediately => 'اختر تاريخاً (أو عيّن فوراً)';

  @override
  String get planLabel => 'الخطة';

  @override
  String get sessionsLabel => 'الجلسات';

  @override
  String get addSession => 'إضافة جلسة';

  @override
  String get nameDayHint =>
      'سمِّ كل يوم (مثال: يوم الأرجل) وأضف التمارين من المكتبة.';

  @override
  String traineesSelected(int count) {
    return '$count متدرب محدد';
  }

  @override
  String get planAndSessions => 'الخطة والجلسات';

  @override
  String get untitledPlan => 'خطة بلا عنوان';

  @override
  String get assignedTo => 'مُعيَّن إلى';

  @override
  String get schedule => 'الجدول الزمني';

  @override
  String get meals => 'الوجبات';

  @override
  String get breakfast => 'الإفطار';

  @override
  String get lunch => 'الغداء';

  @override
  String get dinner => 'العشاء';

  @override
  String get snacks => 'الوجبات الخفيفة';

  @override
  String get mySavedTemplates => 'قوالبي المحفوظة';

  @override
  String get starterTemplates => 'قوالب البدء';

  @override
  String get workoutComplete => 'اكتمل التمرين!';

  @override
  String get amazingEffort => 'جهد رائع!';

  @override
  String get coachNotified => 'تم إخطار مدربك بنتائجك.';

  @override
  String get backToHome => 'العودة للرئيسية';

  @override
  String get shareResults => 'مشاركة النتائج';

  @override
  String get duration => 'المدة';

  @override
  String minutes(int count) {
    return '$count دقيقة';
  }

  @override
  String get setsCompleted => 'المجموعات المكتملة';

  @override
  String get exercisesCompleted => 'التمارين المكتملة';

  @override
  String get workoutSummary => 'ملخص التمرين';

  @override
  String get noWorkoutPlan => 'لا توجد خطة تمرين';

  @override
  String get noWorkoutPlanDesc => 'لم يقم مدربك بتعيين خطة تمرين بعد.';

  @override
  String caloriesRemaining(int cal) {
    return '$cal سعرة متبقية';
  }

  @override
  String mealsLogged(int logged, int total) {
    return '$logged/$total وجبات مسجلة';
  }

  @override
  String get logFood => 'تسجيل طعام';

  @override
  String get addCustomMeal => 'إضافة وجبة مخصصة';

  @override
  String get customMealName => 'اسم الوجبة المخصصة';

  @override
  String get logMealBtn => 'تسجيل وجبة';

  @override
  String get searchFoodHint => 'البحث عن طعام...';

  @override
  String get weeklyGoals => 'الأهداف الأسبوعية';

  @override
  String get water => 'الماء';

  @override
  String liters(String amount) {
    return '$amountل';
  }

  @override
  String get couldNotLoadProgress => 'تعذّر تحميل بيانات التقدم.';

  @override
  String setXofY(int current, int total) {
    return 'مجموعة $current من $total';
  }

  @override
  String get completeSet => 'إكمال المجموعة';

  @override
  String get skipSet => 'تخطي المجموعة';

  @override
  String get nextExercise => 'التمرين التالي';

  @override
  String get finishWorkout => 'إنهاء التمرين';

  @override
  String exerciseXofY(int current, int total) {
    return 'تمرين $current من $total';
  }

  @override
  String get couldNotReadFile =>
      'تعذّرت قراءة الملف المحدد. جرّب ملفاً أصغر أو أعد حفظ التصدير.';

  @override
  String get allFilter => 'الكل';

  @override
  String get attentionFilter => 'تحتاج اهتمام';

  @override
  String notesForTrainee(String name) {
    return 'تم حفظ الملاحظات لـ $name';
  }

  @override
  String get comingSoonSettings => 'قريباً — تحديث الإعدادات غير متاح بعد';

  @override
  String get notificationsLabel => 'الإشعارات';

  @override
  String get remindTrainee => 'تذكير المتدرب';

  @override
  String get alertIfMissed => 'تنبيه إذا فات';

  @override
  String get timeLabel => 'الوقت';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get goalsLabel => 'الأهداف';

  @override
  String get doneSuffix => 'منجز';

  @override
  String get myDrafts => 'مسوداتي';

  @override
  String get continueEditingPlans => 'متابعة تعديل الخطط المحفوظة';

  @override
  String get buildCustomWorkout => 'بناء تمرين مخصص بالكامل';

  @override
  String get buildCustomNutrition => 'بناء خطة تغذية مخصصة بالكامل';

  @override
  String get noSavedTemplatesYet => 'لا توجد قوالب محفوظة بعد';

  @override
  String get templatesSavedWillAppearHere => 'القوالب التي تحفظها ستظهر هنا';

  @override
  String get confirmAndAssignWorkout => 'تأكيد وتعيين التمرين';

  @override
  String get assignNutritionPlanBtn => 'تعيين خطة التغذية ←';

  @override
  String get saveDraft => 'حفظ المسودة';

  @override
  String get saveTemplate => 'حفظ القالب';

  @override
  String get saveAsTemplate => 'حفظ كقالب';

  @override
  String get loadDraft => 'تحميل المسودة';

  @override
  String get loadTemplateBtn => 'تحميل قالب…';

  @override
  String get savedOnDevice => 'محفوظ على هذا الجهاز (بدون مزامنة سحابية)';

  @override
  String get finalCheckBeforeSending => 'مراجعة أخيرة قبل الإرسال للمتدربين';

  @override
  String get remindTraineeBeforeWorkout => 'تذكير المتدرب قبل التمرين';

  @override
  String get sendNotification30Min => 'إرسال إشعار قبل 30 دقيقة';

  @override
  String get alertIfMissedSubtitle => 'إشعارك عند تفويت المتدرب للجلسة';

  @override
  String selectAllActiveTrainees(int count) => 'تحديد جميع المتدربين النشطين ($count)';

  @override
  String get exerciseLibrary => 'مكتبة التمارين';

  @override
  String get searchExercisesHint => 'البحث عن تمارين...';

  @override
  String get addFromLibrary => 'إضافة من المكتبة';

  @override
  String get addCustom => 'إضافة مخصص';

  @override
  String get libraryBtn => 'المكتبة';

  @override
  String get hasVideo => 'يحتوي على فيديو';

  @override
  String get removeSession => 'إزالة الجلسة';

  @override
  String get planTitleLabel => 'عنوان الخطة *';

  @override
  String get planTitleHint => 'مثال: برنامج قوة 4 أسابيع';

  @override
  String get descriptionInstructions => 'الوصف / التعليمات';

  @override
  String get optionalPlanDescription => 'وصف اختياري للخطة للمتدربين...';

  @override
  String get cautionNotesLabel => 'ملاحظات التحذير';

  @override
  String get optionalSafetyNotes => 'ملاحظات سلامة اختيارية...';

  @override
  String get sessionTitleLabel => 'عنوان الجلسة';

  @override
  String get sessionTitleHint => 'مثال: يوم الدفع، يوم الأرجل';

  @override
  String get loadFieldLabel => 'الحمل (مثال: 60كجم)';

  @override
  String get restFieldLabel => 'الراحة (مثال: 90 ث)';

  @override
  String get videoUrl => 'رابط الفيديو';

  @override
  String get setQuantityGrams => 'حدد الكمية (جرام):';

  @override
  String addToMeal(String meal) => 'إضافة إلى $meal';

  @override
  String get nutritionPlanReady => 'خطة التغذية جاهزة';

  @override
  String get addNutritionPlanName => 'أضف اسماً لخطة التغذية';

  @override
  String get nutritionPlanNameHint => 'اسم خطة التغذية *';

  @override
  String get useTemplate => 'استخدام القالب ←';

  @override
  String get remindTraineeBeforeSession => 'تذكير المتدرب قبل الجلسة';

  @override
  String get alertMePlanMissed => 'تنبيهي إذا فاتت الخطة';

  @override
  String get workoutTemplatesDeviceStorage => 'قوالب التمارين (تخزين الجهاز)';

  @override
  String get nutritionTemplatesDeviceStorage => 'قوالب التغذية (تخزين الجهاز)';

  @override
  String get noSavedTemplatesSnackbar => 'لا توجد قوالب محفوظة على هذا الجهاز بعد.';

  @override
  String get immediatelyLabel => 'فوراً';

  @override
  String get traineeWillBeReminded => 'سيتم تذكير المتدرب';

  @override
  String get alertIfMissedSuffix => '· تنبيه إذا فات';

  @override
  String get noTraineeSelected => 'لم يتم اختيار متدرب';

  @override
  String get noIngredientsAvailable => 'لا توجد مكونات متاحة.';

  @override
  String get searchIngredientsHint => 'البحث عن مكونات...';

  @override
  String get addToMealBtn => 'إضافة للوجبة';

  @override
  String nutritionFactsPer(String amount) => 'القيم الغذائية · لكل ${amount}جم';

  @override
  String get coachGoals => 'أهداف المدرب';

  @override
  String setByCoach(String name) => 'محددة من قِبَل $name';

  @override
  String get todaysWorkout => 'تمرين اليوم';

  @override
  String get todaysNutrition => 'تغذية اليوم';

  @override
  String get noWorkoutAssigned => 'لا يوجد تمرين معين';

  @override
  String get noNutritionPlanAssigned => 'لا توجد خطة تغذية معينة';

  @override
  String exercisesDone(int done, int total) => '$done من $total تمارين مكتملة';

  @override
  String get monthlyGoal => 'الهدف الشهري';

  @override
  String reachKg(String kg) => 'الوصول إلى $kg كجم';

  @override
  String get mealsLoggedLabel => 'الوجبات المسجلة';

  @override
  String get waterLitersLabel => 'الماء (ل)';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get nameCannotBeEmpty => 'الاسم لا يمكن أن يكون فارغاً';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountBody =>
      'سيؤدي ذلك إلى حذف حسابك وجميع بياناتك نهائياً. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get typeDeleteToConfirm => 'اكتب DELETE للتأكيد:';

  @override
  String get manageYourMembership => 'إدارة عضويتك';

  @override
  String get noPaymentMethod => 'لا توجد طريقة دفع';

  @override
  String get addCardToUpgrade => 'أضف بطاقة للترقية';

  @override
  String get addPaymentMethod => 'إضافة طريقة دفع';

  @override
  String get frequentlyAskedQuestions => 'الأسئلة الشائعة';

  @override
  String get hereToHelp => 'نحن هنا للمساعدة. تواصل معنا في أي وقت.';

  @override
  String sessionNumber(int number) => 'جلسة $number';

  @override
  String get difficulty => 'الصعوبة';

  @override
  String dayStreakCount(int count) => 'سلسلة $count يوماً!';

  @override
  String moreDaysToBadge(int days, String badge) =>
      '$days يوم إضافي لتحصل على شارة $badge';
}
