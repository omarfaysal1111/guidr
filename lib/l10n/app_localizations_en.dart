// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Guider';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get units => 'Units';

  @override
  String get unitsMetric => 'Metric (kg / cm)';

  @override
  String get unitsImperial => 'Imperial (lb / in)';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectUnits => 'Select Units';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get account => 'Account';

  @override
  String get preferences => 'Preferences';

  @override
  String get support => 'Support';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get subscriptionPlan => 'Subscription Plan';

  @override
  String get billingInfo => 'Billing Info';

  @override
  String get notifications => 'Notifications';

  @override
  String get helpCenter => 'Help Center';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get logOut => 'Log Out';

  @override
  String get login => 'Log In';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading…';

  @override
  String get error => 'Something went wrong';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get done => 'Done';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get noData => 'No data available';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get home => 'Home';

  @override
  String get trainees => 'Trainees';

  @override
  String get trainee => 'Trainee';

  @override
  String get coach => 'Coach';

  @override
  String get workout => 'Workout';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get progress => 'Progress';

  @override
  String get plans => 'Plans';

  @override
  String get chat => 'Chat';

  @override
  String get inviteTrainee => 'Invite Trainee';

  @override
  String get sortBy => 'Sort by';

  @override
  String get filter => 'Filter';

  @override
  String get name => 'Name';

  @override
  String get streak => 'Streak';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get weight => 'Weight';

  @override
  String get height => 'Height';

  @override
  String get age => 'Age';

  @override
  String get goal => 'Goal';

  @override
  String get goals => 'Goals';

  @override
  String get addGoal => 'Add Goal';

  @override
  String get notes => 'Notes';

  @override
  String get coachNotes => 'Coach Notes';

  @override
  String get cautionNotes => 'Caution Notes';

  @override
  String get feedback => 'Feedback';

  @override
  String get measurements => 'Measurements';

  @override
  String get photos => 'Photos';

  @override
  String get inBodyReports => 'InBody Reports';

  @override
  String get uploadReport => 'Upload Report';

  @override
  String get workoutHistory => 'Workout History';

  @override
  String get mealPlan => 'Meal Plan';

  @override
  String get workoutPlan => 'Workout Plan';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get sets => 'Sets';

  @override
  String get reps => 'Reps';

  @override
  String get exercise => 'Exercise';

  @override
  String get exercises => 'Exercises';

  @override
  String get complete => 'Complete';

  @override
  String get completed => 'Completed';

  @override
  String get skipped => 'Skipped';

  @override
  String get pending => 'Pending';

  @override
  String get active => 'Active';

  @override
  String get archived => 'Archived';

  @override
  String get archiveTrainee => 'Archive Trainee';

  @override
  String get deleteTrainee => 'Delete Trainee';

  @override
  String get confirmDelete => 'Are you sure you want to delete?';

  @override
  String get confirmArchive => 'Are you sure you want to archive this trainee?';

  @override
  String get needsAttention => 'Needs Attention';

  @override
  String get activityFeed => 'Activity Feed';

  @override
  String get badges => 'Badges';

  @override
  String get achievements => 'Achievements';

  @override
  String get logWeight => 'Log Weight';

  @override
  String get logMeal => 'Log Meal';

  @override
  String get searchFood => 'Search Food';

  @override
  String get addMeal => 'Add Meal';

  @override
  String get date => 'Date';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get theme => 'Theme';

  @override
  String get free => 'Free';

  @override
  String get kg => 'kg';

  @override
  String get lb => 'lb';

  @override
  String get cm => 'cm';

  @override
  String get inchUnit => 'in';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get todaysPlan => 'Today\'s Plan';

  @override
  String get noActiveWorkout => 'No active workout plan';

  @override
  String get noActiveMealPlan => 'No active meal plan';

  @override
  String get startWorkout => 'Start Workout';

  @override
  String get viewAll => 'View All';

  @override
  String get session => 'Session';

  @override
  String get sessions => 'Sessions';

  @override
  String get assign => 'Assign';

  @override
  String get assignWorkout => 'Assign Workout';

  @override
  String get assignNutrition => 'Assign Nutrition';

  @override
  String get bulkActions => 'Bulk Actions';

  @override
  String selected(int count) {
    return '$count selected';
  }

  @override
  String get notificationPreferences => 'Notification Preferences';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get workoutReminders => 'Workout Reminders';

  @override
  String get mealReminders => 'Meal Reminders';

  @override
  String get progressUpdates => 'Progress Updates';

  @override
  String get chatMessages => 'Chat Messages';
}
