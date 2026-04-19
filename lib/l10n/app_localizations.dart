import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Guider'**
  String get appName;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Arabic language option
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// Units setting label
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// Metric units option
  ///
  /// In en, this message translates to:
  /// **'Metric (kg / cm)'**
  String get unitsMetric;

  /// Imperial units option
  ///
  /// In en, this message translates to:
  /// **'Imperial (lb / in)'**
  String get unitsImperial;

  /// Language picker title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Units picker title
  ///
  /// In en, this message translates to:
  /// **'Select Units'**
  String get selectUnits;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Account section header
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Preferences section header
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Support section header
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Edit profile tile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Subscription plan tile
  ///
  /// In en, this message translates to:
  /// **'Subscription Plan'**
  String get subscriptionPlan;

  /// Billing info tile
  ///
  /// In en, this message translates to:
  /// **'Billing Info'**
  String get billingInfo;

  /// Notifications tile
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Help center tile
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// Contact us tile
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Log out button
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Log in button
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// Register button
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Generic loading text
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Trainees tab label
  ///
  /// In en, this message translates to:
  /// **'Trainees'**
  String get trainees;

  /// Trainee label
  ///
  /// In en, this message translates to:
  /// **'Trainee'**
  String get trainee;

  /// Coach label
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get coach;

  /// Workout label
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// Nutrition label
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// Progress label
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Plans tab label
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get plans;

  /// Chat tab label
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Invite trainee button
  ///
  /// In en, this message translates to:
  /// **'Invite Trainee'**
  String get inviteTrainee;

  /// Sort by label
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// Filter label
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Name sort option
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Streak label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// Days count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String days(int count);

  /// Current streak label
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Weight label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// Height label
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// Age label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// Goal label
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// Goals label
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// Add goal button
  ///
  /// In en, this message translates to:
  /// **'Add Goal'**
  String get addGoal;

  /// Notes label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Coach notes section
  ///
  /// In en, this message translates to:
  /// **'Coach Notes'**
  String get coachNotes;

  /// Caution notes section
  ///
  /// In en, this message translates to:
  /// **'Caution Notes'**
  String get cautionNotes;

  /// Feedback label
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Measurements section
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurements;

  /// Photos label
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// InBody reports section
  ///
  /// In en, this message translates to:
  /// **'InBody Reports'**
  String get inBodyReports;

  /// Upload report button
  ///
  /// In en, this message translates to:
  /// **'Upload Report'**
  String get uploadReport;

  /// Workout history section
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutHistory;

  /// Meal plan section
  ///
  /// In en, this message translates to:
  /// **'Meal Plan'**
  String get mealPlan;

  /// Workout plan section
  ///
  /// In en, this message translates to:
  /// **'Workout Plan'**
  String get workoutPlan;

  /// Calories label
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// Protein label
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// Carbs label
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// Fat label
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// Sets label
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// Reps label
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// Exercise label
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// Exercises label
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// Complete button
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Skipped status
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Active status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Archived status
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// Archive trainee option
  ///
  /// In en, this message translates to:
  /// **'Archive Trainee'**
  String get archiveTrainee;

  /// Delete trainee option
  ///
  /// In en, this message translates to:
  /// **'Delete Trainee'**
  String get deleteTrainee;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get confirmDelete;

  /// Archive confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to archive this trainee?'**
  String get confirmArchive;

  /// Needs attention section
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get needsAttention;

  /// Activity feed section
  ///
  /// In en, this message translates to:
  /// **'Activity Feed'**
  String get activityFeed;

  /// Badges section
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// Achievements label
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Log weight button
  ///
  /// In en, this message translates to:
  /// **'Log Weight'**
  String get logWeight;

  /// Log meal button
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get logMeal;

  /// Search food placeholder
  ///
  /// In en, this message translates to:
  /// **'Search Food'**
  String get searchFood;

  /// Add meal button
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Dark mode toggle
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Theme section
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Free plan badge
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// Kilograms unit
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// Pounds unit
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get lb;

  /// Centimetres unit
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// Inches unit
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get inchUnit;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// Today's plan section
  ///
  /// In en, this message translates to:
  /// **'Today\'s Plan'**
  String get todaysPlan;

  /// No workout plan message
  ///
  /// In en, this message translates to:
  /// **'No active workout plan'**
  String get noActiveWorkout;

  /// No meal plan message
  ///
  /// In en, this message translates to:
  /// **'No active meal plan'**
  String get noActiveMealPlan;

  /// Start workout button
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get startWorkout;

  /// View all button
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Session label
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// Sessions label
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// Assign button
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// Assign workout button
  ///
  /// In en, this message translates to:
  /// **'Assign Workout'**
  String get assignWorkout;

  /// Assign nutrition button
  ///
  /// In en, this message translates to:
  /// **'Assign Nutrition'**
  String get assignNutrition;

  /// Bulk actions label
  ///
  /// In en, this message translates to:
  /// **'Bulk Actions'**
  String get bulkActions;

  /// Selected count
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selected(int count);

  /// Notification preferences label
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// Enable notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// Workout reminders toggle
  ///
  /// In en, this message translates to:
  /// **'Workout Reminders'**
  String get workoutReminders;

  /// Meal reminders toggle
  ///
  /// In en, this message translates to:
  /// **'Meal Reminders'**
  String get mealReminders;

  /// Progress updates toggle
  ///
  /// In en, this message translates to:
  /// **'Progress Updates'**
  String get progressUpdates;

  /// Chat messages toggle
  ///
  /// In en, this message translates to:
  /// **'Chat Messages'**
  String get chatMessages;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
