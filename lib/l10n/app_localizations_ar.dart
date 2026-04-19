// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'غايدر';

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
}
