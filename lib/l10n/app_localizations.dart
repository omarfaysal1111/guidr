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

  /// Login screen tagline
  ///
  /// In en, this message translates to:
  /// **'Train smarter. Together.'**
  String get trainSmarter;

  /// Role selection - coach
  ///
  /// In en, this message translates to:
  /// **'I\'m a Coach'**
  String get iAmACoach;

  /// Coach role description
  ///
  /// In en, this message translates to:
  /// **'Manage clients, create plans & track progress'**
  String get coachRoleDescription;

  /// Role selection - trainee
  ///
  /// In en, this message translates to:
  /// **'I\'m a Trainee'**
  String get iAmATrainee;

  /// Trainee role description
  ///
  /// In en, this message translates to:
  /// **'Follow plans, log workouts & hit your goals'**
  String get traineeRoleDescription;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue →'**
  String get continueBtn;

  /// Welcome back for coach
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Coach'**
  String get welcomeBackCoach;

  /// Email address field label
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Password validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Log in button label
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// Register link text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get dontHaveAccount;

  /// Register screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// Invitation code field label
  ///
  /// In en, this message translates to:
  /// **'Invitation Code'**
  String get invitationCode;

  /// Fitness goal field label
  ///
  /// In en, this message translates to:
  /// **'Fitness Goal'**
  String get fitnessGoal;

  /// Name validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// Email format validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Password required validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterAPassword;

  /// Password length validation
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Invitation code validation
  ///
  /// In en, this message translates to:
  /// **'Please enter your invitation code'**
  String get pleaseEnterInvitationCode;

  /// Create new plan sheet title
  ///
  /// In en, this message translates to:
  /// **'Create new plan'**
  String get createNewPlan;

  /// Exercises plan option
  ///
  /// In en, this message translates to:
  /// **'Exercises Plan'**
  String get exercisesPlan;

  /// Nutrition plan option
  ///
  /// In en, this message translates to:
  /// **'Nutrition Plan'**
  String get nutritionPlan;

  /// More tab label
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// Sessions today count
  ///
  /// In en, this message translates to:
  /// **'{count} sessions today'**
  String sessionsToday(int count);

  /// Needs attention count
  ///
  /// In en, this message translates to:
  /// **'{count} need attention'**
  String needAttention(int count);

  /// Free plan label
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// Upgrade button
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// Clients label
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// Client limit warning
  ///
  /// In en, this message translates to:
  /// **'Client limit reached — upgrade to add more'**
  String get clientLimitReached;

  /// Today's sessions section
  ///
  /// In en, this message translates to:
  /// **'Today\'s Sessions'**
  String get todaysSessions;

  /// No sessions today message
  ///
  /// In en, this message translates to:
  /// **'No sessions scheduled for today.'**
  String get noSessionsToday;

  /// Top performers section
  ///
  /// In en, this message translates to:
  /// **'Top Performers'**
  String get topPerformers;

  /// Top performers empty state
  ///
  /// In en, this message translates to:
  /// **'Your most engaged clients will appear here.'**
  String get topPerformersEmpty;

  /// Recent activity section
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// Recent activity empty state
  ///
  /// In en, this message translates to:
  /// **'Activity from your clients will appear here.'**
  String get recentActivityEmpty;

  /// Pending invitations section
  ///
  /// In en, this message translates to:
  /// **'Pending Invitations'**
  String get pendingInvitations;

  /// No pending invites message
  ///
  /// In en, this message translates to:
  /// **'No pending invites. Invite a trainee to get started.'**
  String get noPendingInvites;

  /// Expiry date label
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String expires(String date);

  /// Pending invitation label
  ///
  /// In en, this message translates to:
  /// **'Pending invitation'**
  String get pendingInvitation;

  /// Invited email label
  ///
  /// In en, this message translates to:
  /// **'Invited: {email}'**
  String invited(String email);

  /// No attention items message
  ///
  /// In en, this message translates to:
  /// **'No items need attention right now.'**
  String get noItemsNeedAttention;

  /// View all button variant
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAllBtn;

  /// Trainee count label
  ///
  /// In en, this message translates to:
  /// **'{count} trainees'**
  String traineeCount(int count);

  /// Sort button
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Sort trainees sheet title
  ///
  /// In en, this message translates to:
  /// **'Sort Trainees'**
  String get sortTrainees;

  /// Sort name ascending
  ///
  /// In en, this message translates to:
  /// **'Name A–Z'**
  String get nameAZ;

  /// Sort name descending
  ///
  /// In en, this message translates to:
  /// **'Name Z–A'**
  String get nameZA;

  /// Sort highest adherence
  ///
  /// In en, this message translates to:
  /// **'Highest Adherence'**
  String get highestAdherence;

  /// Sort lowest adherence
  ///
  /// In en, this message translates to:
  /// **'Lowest Adherence'**
  String get lowestAdherence;

  /// Sort longest streak
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// Sort shortest streak
  ///
  /// In en, this message translates to:
  /// **'Shortest Streak'**
  String get shortestStreak;

  /// Adherence label lowercase
  ///
  /// In en, this message translates to:
  /// **'adherence'**
  String get adherenceWord;

  /// Missed meals badge
  ///
  /// In en, this message translates to:
  /// **'{count} Missed Meals'**
  String missedMeals(int count);

  /// Missed workouts badge
  ///
  /// In en, this message translates to:
  /// **'{count} Missed Workouts'**
  String missedWorkouts(int count);

  /// Overview tab
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Trainee level label
  ///
  /// In en, this message translates to:
  /// **'Trainee Level'**
  String get traineeLevel;

  /// Direction / goal section label
  ///
  /// In en, this message translates to:
  /// **'DIRECTION / GOAL'**
  String get directionGoal;

  /// Adherence metric label uppercase
  ///
  /// In en, this message translates to:
  /// **'ADHERENCE'**
  String get adherenceLabel;

  /// Day streak metric label uppercase
  ///
  /// In en, this message translates to:
  /// **'DAY STREAK'**
  String get dayStreak;

  /// Weight metric label uppercase
  ///
  /// In en, this message translates to:
  /// **'WEIGHT'**
  String get weightLabel;

  /// View health history link
  ///
  /// In en, this message translates to:
  /// **'View Health & Training History'**
  String get viewHealthHistory;

  /// Weekly summary section
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// Workouts label
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// Details section
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// Last active label
  ///
  /// In en, this message translates to:
  /// **'Last Active'**
  String get lastActive;

  /// Next session label
  ///
  /// In en, this message translates to:
  /// **'Next Session'**
  String get nextSession;

  /// Missed workouts alert message
  ///
  /// In en, this message translates to:
  /// **'Missed workouts'**
  String get missedWorkoutsAlert;

  /// Low nutrition adherence alert
  ///
  /// In en, this message translates to:
  /// **'Low nutrition adherence'**
  String get lowNutritionAdherence;

  /// Weight plateau alert
  ///
  /// In en, this message translates to:
  /// **'Weight plateau (3+ weeks)'**
  String get weightPlateau;

  /// Health & training history sheet title
  ///
  /// In en, this message translates to:
  /// **'Health & Training History'**
  String get healthTrainingHistory;

  /// Training experience label
  ///
  /// In en, this message translates to:
  /// **'TRAINING EXPERIENCE'**
  String get trainingExperience;

  /// Previous training label
  ///
  /// In en, this message translates to:
  /// **'PREVIOUS TRAINING'**
  String get previousTraining;

  /// Reason for stopping label
  ///
  /// In en, this message translates to:
  /// **'REASON FOR STOPPING'**
  String get reasonForStopping;

  /// Diseases/conditions label
  ///
  /// In en, this message translates to:
  /// **'DISEASES / CONDITIONS'**
  String get diseasesConditions;

  /// Allergies label
  ///
  /// In en, this message translates to:
  /// **'ALLERGIES'**
  String get allergiesLabel;

  /// Injuries label
  ///
  /// In en, this message translates to:
  /// **'INJURIES'**
  String get injuriesLabel;

  /// Medications label
  ///
  /// In en, this message translates to:
  /// **'MEDICATIONS'**
  String get medicationsLabel;

  /// Weight trend section
  ///
  /// In en, this message translates to:
  /// **'Weight Trend'**
  String get weightTrend;

  /// No weight logs message
  ///
  /// In en, this message translates to:
  /// **'No weight logs yet.'**
  String get noWeightLogs;

  /// This week label
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Body measurements section
  ///
  /// In en, this message translates to:
  /// **'Body Measurements'**
  String get bodyMeasurements;

  /// From trainee badge
  ///
  /// In en, this message translates to:
  /// **'From Trainee'**
  String get fromTrainee;

  /// Pose check-ins section
  ///
  /// In en, this message translates to:
  /// **'Pose check-ins'**
  String get poseCheckIns;

  /// All dates filter option
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get allDates;

  /// Clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No photos message
  ///
  /// In en, this message translates to:
  /// **'No photos in this range.'**
  String get noPhotosInRange;

  /// Front photo label
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get front;

  /// Side photo label
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get sideLabel;

  /// Back photo label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backLabel;

  /// Trainee feedback section
  ///
  /// In en, this message translates to:
  /// **'Trainee Feedback'**
  String get traineeFeedback;

  /// No feedback message
  ///
  /// In en, this message translates to:
  /// **'No feedback entries yet.'**
  String get noFeedbackYet;

  /// Latest badge
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// Feedback for trainee label
  ///
  /// In en, this message translates to:
  /// **'Feedback for {name}'**
  String feedbackForTrainee(String name);

  /// Feedback hint text
  ///
  /// In en, this message translates to:
  /// **'Write your feedback here... This will be visible to the trainee.'**
  String get feedbackHint;

  /// Caution/medical notes label
  ///
  /// In en, this message translates to:
  /// **'Caution / Medical Notes'**
  String get cautionMedicalNotes;

  /// Caution hint text
  ///
  /// In en, this message translates to:
  /// **'Injuries, restrictions, things to watch out for...'**
  String get cautionHint;

  /// Save notes button
  ///
  /// In en, this message translates to:
  /// **'Save Notes'**
  String get saveNotes;

  /// Saving label
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// Uploading label
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get uploading;

  /// Upload image/PDF button
  ///
  /// In en, this message translates to:
  /// **'Upload image or PDF'**
  String get uploadImageOrPdf;

  /// No InBody reports message
  ///
  /// In en, this message translates to:
  /// **'No InBody reports yet.'**
  String get noInBodyReports;

  /// InBody reports subtitle
  ///
  /// In en, this message translates to:
  /// **'Upload scans or PDFs from the device. Expand a row to preview.'**
  String get inBodyReportsSubtitle;

  /// No goals message
  ///
  /// In en, this message translates to:
  /// **'No goals listed yet.'**
  String get noGoalsYet;

  /// Goals hint text
  ///
  /// In en, this message translates to:
  /// **'Tap to mark done · Tap ✏ to edit · Swipe left to delete'**
  String get tapToMarkDone;

  /// Add new goal hint
  ///
  /// In en, this message translates to:
  /// **'Add a new goal...'**
  String get addNewGoal;

  /// Edit goal sheet title
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// Goal description hint
  ///
  /// In en, this message translates to:
  /// **'Goal description…'**
  String get goalDescription;

  /// Level & goal card title
  ///
  /// In en, this message translates to:
  /// **'Level & Goal'**
  String get levelAndGoal;

  /// Trainee level label uppercase
  ///
  /// In en, this message translates to:
  /// **'TRAINEE LEVEL'**
  String get traineeLevelLabel;

  /// Goal input hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Lose 5 kg, Build muscle...'**
  String get goalHint;

  /// Save changes button
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Trainee info card title
  ///
  /// In en, this message translates to:
  /// **'Trainee Info'**
  String get traineeInfo;

  /// Archive trainee dialog title
  ///
  /// In en, this message translates to:
  /// **'Archive trainee?'**
  String get archiveTraineeQuestion;

  /// Archive trainee dialog body
  ///
  /// In en, this message translates to:
  /// **'{name} will be archived. You can restore them later if your app supports it.'**
  String archiveTraineeBody(String name);

  /// Archive button
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// Delete trainee dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete trainee permanently?'**
  String get deleteTraineePermanently;

  /// Delete trainee dialog body
  ///
  /// In en, this message translates to:
  /// **'This will remove {name} and their data. This action cannot be undone.'**
  String deleteTraineeBody(String name);

  /// Delete trainee permanently button
  ///
  /// In en, this message translates to:
  /// **'Delete Trainee Permanently'**
  String get deleteTraineePermanentlyBtn;

  /// Plan assigned success message
  ///
  /// In en, this message translates to:
  /// **'Plan assigned successfully!'**
  String get planAssignedSuccess;

  /// Template saved message
  ///
  /// In en, this message translates to:
  /// **'Template saved on this device'**
  String get templateSavedMsg;

  /// Draft saved message
  ///
  /// In en, this message translates to:
  /// **'Draft saved on this device'**
  String get draftSavedMsg;

  /// Saved templates section label
  ///
  /// In en, this message translates to:
  /// **'SAVED TEMPLATES'**
  String get savedTemplates;

  /// Start from scratch option
  ///
  /// In en, this message translates to:
  /// **'Start from Scratch'**
  String get startFromScratch;

  /// Search trainees hint
  ///
  /// In en, this message translates to:
  /// **'Search trainees...'**
  String get searchTrainees;

  /// No trainees message
  ///
  /// In en, this message translates to:
  /// **'No active trainees found'**
  String get noActiveTraineesFound;

  /// No trainees suggestion
  ///
  /// In en, this message translates to:
  /// **'Invite trainees first to create a plan'**
  String get inviteTraineesFirst;

  /// Select all option
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// Assignment date label
  ///
  /// In en, this message translates to:
  /// **'ASSIGNMENT DATE'**
  String get assignmentDate;

  /// Recurrence label
  ///
  /// In en, this message translates to:
  /// **'RECURRENCE'**
  String get recurrence;

  /// Date picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Select date (or assign immediately)'**
  String get selectDateOrAssignImmediately;

  /// Plan section label uppercase
  ///
  /// In en, this message translates to:
  /// **'PLAN'**
  String get planLabel;

  /// Sessions label uppercase
  ///
  /// In en, this message translates to:
  /// **'SESSIONS'**
  String get sessionsLabel;

  /// Add session button
  ///
  /// In en, this message translates to:
  /// **'Add session'**
  String get addSession;

  /// Session naming hint
  ///
  /// In en, this message translates to:
  /// **'Name each day (e.g. Leg Day) and add exercises from the library.'**
  String get nameDayHint;

  /// Trainees selected count
  ///
  /// In en, this message translates to:
  /// **'{count} trainees selected'**
  String traineesSelected(int count);

  /// Plan & sessions review card title
  ///
  /// In en, this message translates to:
  /// **'Plan & sessions'**
  String get planAndSessions;

  /// Untitled plan label
  ///
  /// In en, this message translates to:
  /// **'Untitled plan'**
  String get untitledPlan;

  /// Assigned to label
  ///
  /// In en, this message translates to:
  /// **'Assigned to'**
  String get assignedTo;

  /// Schedule label
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// Meals label
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// Breakfast meal label
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// Lunch meal label
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// Dinner meal label
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// Snacks meal label
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snacks;

  /// My saved templates section label
  ///
  /// In en, this message translates to:
  /// **'MY SAVED TEMPLATES'**
  String get mySavedTemplates;

  /// Starter templates section label
  ///
  /// In en, this message translates to:
  /// **'STARTER TEMPLATES'**
  String get starterTemplates;

  /// Workout complete title
  ///
  /// In en, this message translates to:
  /// **'Workout Complete!'**
  String get workoutComplete;

  /// Workout complete subtitle
  ///
  /// In en, this message translates to:
  /// **'Amazing effort!'**
  String get amazingEffort;

  /// Coach notified message
  ///
  /// In en, this message translates to:
  /// **'Your coach has been notified of your results.'**
  String get coachNotified;

  /// Back to home button
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// Share results button
  ///
  /// In en, this message translates to:
  /// **'Share Results'**
  String get shareResults;

  /// Duration label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Minutes label
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minutes(int count);

  /// Sets completed label
  ///
  /// In en, this message translates to:
  /// **'Sets Completed'**
  String get setsCompleted;

  /// Exercises completed label
  ///
  /// In en, this message translates to:
  /// **'Exercises Completed'**
  String get exercisesCompleted;

  /// Workout summary section
  ///
  /// In en, this message translates to:
  /// **'Workout Summary'**
  String get workoutSummary;

  /// No workout plan title
  ///
  /// In en, this message translates to:
  /// **'No Workout Plan'**
  String get noWorkoutPlan;

  /// No workout plan description
  ///
  /// In en, this message translates to:
  /// **'Your coach hasn\'t assigned a workout plan yet.'**
  String get noWorkoutPlanDesc;

  /// Calories remaining label
  ///
  /// In en, this message translates to:
  /// **'{cal} cal remaining'**
  String caloriesRemaining(int cal);

  /// Meals logged label
  ///
  /// In en, this message translates to:
  /// **'{logged}/{total} meals logged'**
  String mealsLogged(int logged, int total);

  /// Log food button
  ///
  /// In en, this message translates to:
  /// **'Log Food'**
  String get logFood;

  /// Add custom meal option
  ///
  /// In en, this message translates to:
  /// **'Add Custom Meal'**
  String get addCustomMeal;

  /// Custom meal name hint
  ///
  /// In en, this message translates to:
  /// **'Custom meal name'**
  String get customMealName;

  /// Log meal button label
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get logMealBtn;

  /// Search food input hint
  ///
  /// In en, this message translates to:
  /// **'Search food...'**
  String get searchFoodHint;

  /// Weekly goals section
  ///
  /// In en, this message translates to:
  /// **'Weekly Goals'**
  String get weeklyGoals;

  /// Water label
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// Liters label
  ///
  /// In en, this message translates to:
  /// **'{amount}L'**
  String liters(String amount);

  /// Progress load error message
  ///
  /// In en, this message translates to:
  /// **'Could not load progress data.'**
  String get couldNotLoadProgress;

  /// Set X of Y label
  ///
  /// In en, this message translates to:
  /// **'Set {current} of {total}'**
  String setXofY(int current, int total);

  /// Complete set button
  ///
  /// In en, this message translates to:
  /// **'Complete Set'**
  String get completeSet;

  /// Skip set button
  ///
  /// In en, this message translates to:
  /// **'Skip Set'**
  String get skipSet;

  /// Next exercise button
  ///
  /// In en, this message translates to:
  /// **'Next Exercise'**
  String get nextExercise;

  /// Finish workout button
  ///
  /// In en, this message translates to:
  /// **'Finish Workout'**
  String get finishWorkout;

  /// Exercise X of Y label
  ///
  /// In en, this message translates to:
  /// **'Exercise {current} of {total}'**
  String exerciseXofY(int current, int total);

  /// File read error message
  ///
  /// In en, this message translates to:
  /// **'Could not read the selected file. Try a smaller file or re-save the export.'**
  String get couldNotReadFile;

  /// All filter chip
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allFilter;

  /// Attention filter chip
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get attentionFilter;

  /// Notes saved success message
  ///
  /// In en, this message translates to:
  /// **'Notes saved for {name}'**
  String notesForTrainee(String name);

  /// Coming soon settings message
  ///
  /// In en, this message translates to:
  /// **'Coming soon — settings update not yet available'**
  String get comingSoonSettings;

  /// Notifications section label uppercase
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notificationsLabel;

  /// Remind trainee toggle
  ///
  /// In en, this message translates to:
  /// **'Remind trainee'**
  String get remindTrainee;

  /// Alert if missed toggle
  ///
  /// In en, this message translates to:
  /// **'Alert if missed'**
  String get alertIfMissed;

  /// Time section label
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get timeLabel;

  /// Date section label
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get dateLabel;

  /// Goals card title
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsLabel;

  /// Done count suffix
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get doneSuffix;

  /// My drafts card title
  ///
  /// In en, this message translates to:
  /// **'My Drafts'**
  String get myDrafts;

  /// Continue editing saved plans subtitle
  ///
  /// In en, this message translates to:
  /// **'Continue editing saved plans'**
  String get continueEditingPlans;

  /// Build custom workout subtitle
  ///
  /// In en, this message translates to:
  /// **'Build a completely custom workout'**
  String get buildCustomWorkout;

  /// Build custom nutrition subtitle
  ///
  /// In en, this message translates to:
  /// **'Build a completely custom nutrition plan'**
  String get buildCustomNutrition;

  /// No saved templates yet message
  ///
  /// In en, this message translates to:
  /// **'No saved templates yet'**
  String get noSavedTemplatesYet;

  /// Templates saved hint
  ///
  /// In en, this message translates to:
  /// **'Templates you save will appear here'**
  String get templatesSavedWillAppearHere;

  /// Confirm and assign workout button
  ///
  /// In en, this message translates to:
  /// **'CONFIRM & ASSIGN WORKOUT'**
  String get confirmAndAssignWorkout;

  /// Assign nutrition plan button
  ///
  /// In en, this message translates to:
  /// **'Assign Nutrition Plan →'**
  String get assignNutritionPlanBtn;

  /// Save draft button
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// Save template button
  ///
  /// In en, this message translates to:
  /// **'Save Template'**
  String get saveTemplate;

  /// Save as template button
  ///
  /// In en, this message translates to:
  /// **'Save as Template'**
  String get saveAsTemplate;

  /// Load draft button
  ///
  /// In en, this message translates to:
  /// **'Load draft'**
  String get loadDraft;

  /// Load template button
  ///
  /// In en, this message translates to:
  /// **'Load template…'**
  String get loadTemplateBtn;

  /// Saved on device note
  ///
  /// In en, this message translates to:
  /// **'Saved on this device (no cloud sync)'**
  String get savedOnDevice;

  /// Final check message
  ///
  /// In en, this message translates to:
  /// **'Final check before sending to trainees'**
  String get finalCheckBeforeSending;

  /// Remind trainee before workout toggle
  ///
  /// In en, this message translates to:
  /// **'Remind trainee before workout'**
  String get remindTraineeBeforeWorkout;

  /// Send notification 30 min before
  ///
  /// In en, this message translates to:
  /// **'Send notification 30 min before'**
  String get sendNotification30Min;

  /// Alert if missed subtitle
  ///
  /// In en, this message translates to:
  /// **'Notify you when trainee misses a session'**
  String get alertIfMissedSubtitle;

  /// Select all active trainees text with count
  ///
  /// In en, this message translates to:
  /// **'Select all active trainees ({count})'**
  String selectAllActiveTrainees(int count);

  /// Exercise library sheet title
  ///
  /// In en, this message translates to:
  /// **'Exercise library'**
  String get exerciseLibrary;

  /// Search exercises hint
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get searchExercisesHint;

  /// Add from library button
  ///
  /// In en, this message translates to:
  /// **'Add from library'**
  String get addFromLibrary;

  /// Add custom button
  ///
  /// In en, this message translates to:
  /// **'Add Custom'**
  String get addCustom;

  /// Library button
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryBtn;

  /// Has video label
  ///
  /// In en, this message translates to:
  /// **'Has video'**
  String get hasVideo;

  /// Remove session button
  ///
  /// In en, this message translates to:
  /// **'Remove session'**
  String get removeSession;

  /// Plan title field label
  ///
  /// In en, this message translates to:
  /// **'Plan title *'**
  String get planTitleLabel;

  /// Plan title hint
  ///
  /// In en, this message translates to:
  /// **'e.g. 4-week strength block'**
  String get planTitleHint;

  /// Description / instructions label
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION / INSTRUCTIONS'**
  String get descriptionInstructions;

  /// Optional plan description hint
  ///
  /// In en, this message translates to:
  /// **'Optional plan description for trainees...'**
  String get optionalPlanDescription;

  /// Caution / notes label
  ///
  /// In en, this message translates to:
  /// **'CAUTION / NOTES'**
  String get cautionNotesLabel;

  /// Optional safety notes hint
  ///
  /// In en, this message translates to:
  /// **'Optional safety notes...'**
  String get optionalSafetyNotes;

  /// Session title field label
  ///
  /// In en, this message translates to:
  /// **'Session title'**
  String get sessionTitleLabel;

  /// Session title hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Push day, Leg day'**
  String get sessionTitleHint;

  /// Load (weight) field label
  ///
  /// In en, this message translates to:
  /// **'Load (e.g. 60kg)'**
  String get loadFieldLabel;

  /// Rest time field label
  ///
  /// In en, this message translates to:
  /// **'Rest (e.g. 90s)'**
  String get restFieldLabel;

  /// Video URL field label
  ///
  /// In en, this message translates to:
  /// **'Video URL'**
  String get videoUrl;

  /// Set quantity grams dialog text
  ///
  /// In en, this message translates to:
  /// **'Set quantity (grams):'**
  String get setQuantityGrams;

  /// Add to meal dialog title
  ///
  /// In en, this message translates to:
  /// **'Add to {meal}'**
  String addToMeal(String meal);

  /// Nutrition plan ready banner
  ///
  /// In en, this message translates to:
  /// **'Nutrition plan ready'**
  String get nutritionPlanReady;

  /// Add nutrition plan name banner
  ///
  /// In en, this message translates to:
  /// **'Add a nutrition plan name'**
  String get addNutritionPlanName;

  /// Nutrition plan name hint
  ///
  /// In en, this message translates to:
  /// **'Nutrition plan name *'**
  String get nutritionPlanNameHint;

  /// Use template button
  ///
  /// In en, this message translates to:
  /// **'Use template →'**
  String get useTemplate;

  /// Remind trainee before session toggle
  ///
  /// In en, this message translates to:
  /// **'Remind trainee before session'**
  String get remindTraineeBeforeSession;

  /// Alert me if plan missed toggle
  ///
  /// In en, this message translates to:
  /// **'Alert me if plan missed'**
  String get alertMePlanMissed;

  /// Workout templates device storage title
  ///
  /// In en, this message translates to:
  /// **'Workout templates (device storage)'**
  String get workoutTemplatesDeviceStorage;

  /// Nutrition templates device storage title
  ///
  /// In en, this message translates to:
  /// **'Nutrition templates (device storage)'**
  String get nutritionTemplatesDeviceStorage;

  /// No saved templates snackbar
  ///
  /// In en, this message translates to:
  /// **'No saved templates on this device yet.'**
  String get noSavedTemplatesSnackbar;

  /// Immediately label for date picker
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get immediatelyLabel;

  /// Trainee will be reminded notification text
  ///
  /// In en, this message translates to:
  /// **'Trainee will be reminded'**
  String get traineeWillBeReminded;

  /// Alert if missed suffix
  ///
  /// In en, this message translates to:
  /// **'· Alert if missed'**
  String get alertIfMissedSuffix;

  /// No trainee selected message
  ///
  /// In en, this message translates to:
  /// **'No trainee selected'**
  String get noTraineeSelected;

  /// No ingredients available message
  ///
  /// In en, this message translates to:
  /// **'No ingredients available.'**
  String get noIngredientsAvailable;

  /// Search ingredients hint
  ///
  /// In en, this message translates to:
  /// **'Search ingredients...'**
  String get searchIngredientsHint;

  /// Add to meal button text
  ///
  /// In en, this message translates to:
  /// **'Add to Meal'**
  String get addToMealBtn;

  /// Nutrition facts label
  ///
  /// In en, this message translates to:
  /// **'Nutrition Facts · per {amount}g'**
  String nutritionFactsPer(String amount);

  /// Coach goals section title
  ///
  /// In en, this message translates to:
  /// **'Coach Goals'**
  String get coachGoals;

  /// Set by coach subtitle
  ///
  /// In en, this message translates to:
  /// **'Set by {name}'**
  String setByCoach(String name);

  /// Today's workout card title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workout'**
  String get todaysWorkout;

  /// Today's nutrition card title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Nutrition'**
  String get todaysNutrition;

  /// No workout assigned message
  ///
  /// In en, this message translates to:
  /// **'No workout assigned'**
  String get noWorkoutAssigned;

  /// No nutrition plan assigned message
  ///
  /// In en, this message translates to:
  /// **'No nutrition plan assigned'**
  String get noNutritionPlanAssigned;

  /// Exercises done label
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} exercises done'**
  String exercisesDone(int done, int total);

  /// Monthly goal label
  ///
  /// In en, this message translates to:
  /// **'Monthly Goal'**
  String get monthlyGoal;

  /// Reach weight goal label
  ///
  /// In en, this message translates to:
  /// **'Reach {kg} kg'**
  String reachKg(String kg);

  /// Meals logged weekly goal label
  ///
  /// In en, this message translates to:
  /// **'Meals Logged'**
  String get mealsLoggedLabel;

  /// Water liters weekly goal label
  ///
  /// In en, this message translates to:
  /// **'Water (L)'**
  String get waterLitersLabel;

  /// Profile updated success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// Name cannot be empty validation
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// Delete account button/title
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account dialog body
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all your data. This action cannot be undone.'**
  String get deleteAccountBody;

  /// Type DELETE to confirm label
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm:'**
  String get typeDeleteToConfirm;

  /// Manage membership subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage your membership'**
  String get manageYourMembership;

  /// No payment method label
  ///
  /// In en, this message translates to:
  /// **'No payment method'**
  String get noPaymentMethod;

  /// Add a card to upgrade label
  ///
  /// In en, this message translates to:
  /// **'Add a card to upgrade your plan'**
  String get addCardToUpgrade;

  /// Add payment method button
  ///
  /// In en, this message translates to:
  /// **'Add Payment Method'**
  String get addPaymentMethod;

  /// Frequently asked questions label
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get frequentlyAskedQuestions;

  /// We're here to help subtitle
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help. Reach out anytime.'**
  String get hereToHelp;

  /// Session number label
  ///
  /// In en, this message translates to:
  /// **'Session {number}'**
  String sessionNumber(int number);

  /// Difficulty label
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Day streak label with count
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak!'**
  String dayStreakCount(int count);

  /// More days to badge label
  ///
  /// In en, this message translates to:
  /// **'{days} more day to earn the {badge} badge'**
  String moreDaysToBadge(int days, String badge);
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
