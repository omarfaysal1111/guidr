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

  @override
  String get trainSmarter => 'Train smarter. Together.';

  @override
  String get iAmACoach => 'I\'m a Coach';

  @override
  String get coachRoleDescription =>
      'Manage clients, create plans & track progress';

  @override
  String get iAmATrainee => 'I\'m a Trainee';

  @override
  String get traineeRoleDescription =>
      'Follow plans, log workouts & hit your goals';

  @override
  String get continueBtn => 'Continue →';

  @override
  String get welcomeBackCoach => 'Welcome back, Coach';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get logIn => 'Log In';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get invitationCode => 'Invitation Code';

  @override
  String get fitnessGoal => 'Fitness Goal';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterAPassword => 'Please enter a password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get pleaseEnterInvitationCode => 'Please enter your invitation code';

  @override
  String get createNewPlan => 'Create new plan';

  @override
  String get exercisesPlan => 'Exercises Plan';

  @override
  String get nutritionPlan => 'Nutrition Plan';

  @override
  String get more => 'More';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String sessionsToday(int count) {
    return '$count sessions today';
  }

  @override
  String needAttention(int count) {
    return '$count need attention';
  }

  @override
  String get freePlan => 'Free Plan';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get clients => 'Clients';

  @override
  String get clientLimitReached => 'Client limit reached — upgrade to add more';

  @override
  String get todaysSessions => 'Today\'s Sessions';

  @override
  String get noSessionsToday => 'No sessions scheduled for today.';

  @override
  String get topPerformers => 'Top Performers';

  @override
  String get topPerformersEmpty =>
      'Your most engaged clients will appear here.';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get recentActivityEmpty =>
      'Activity from your clients will appear here.';

  @override
  String get pendingInvitations => 'Pending Invitations';

  @override
  String get noPendingInvites =>
      'No pending invites. Invite a trainee to get started.';

  @override
  String expires(String date) {
    return 'Expires $date';
  }

  @override
  String get pendingInvitation => 'Pending invitation';

  @override
  String invited(String email) {
    return 'Invited: $email';
  }

  @override
  String get noItemsNeedAttention => 'No items need attention right now.';

  @override
  String get viewAllBtn => 'View all';

  @override
  String traineeCount(int count) {
    return '$count trainees';
  }

  @override
  String get sort => 'Sort';

  @override
  String get sortTrainees => 'Sort Trainees';

  @override
  String get nameAZ => 'Name A–Z';

  @override
  String get nameZA => 'Name Z–A';

  @override
  String get highestAdherence => 'Highest Adherence';

  @override
  String get lowestAdherence => 'Lowest Adherence';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get shortestStreak => 'Shortest Streak';

  @override
  String get adherenceWord => 'adherence';

  @override
  String missedMeals(int count) {
    return '$count Missed Meals';
  }

  @override
  String missedWorkouts(int count) {
    return '$count Missed Workouts';
  }

  @override
  String get overview => 'Overview';

  @override
  String get traineeLevel => 'Trainee Level';

  @override
  String get directionGoal => 'DIRECTION / GOAL';

  @override
  String get adherenceLabel => 'ADHERENCE';

  @override
  String get dayStreak => 'DAY STREAK';

  @override
  String get weightLabel => 'WEIGHT';

  @override
  String get viewHealthHistory => 'View Health & Training History';

  @override
  String get weeklySummary => 'Weekly Summary';

  @override
  String get workouts => 'Workouts';

  @override
  String get details => 'Details';

  @override
  String get lastActive => 'Last Active';

  @override
  String get nextSession => 'Next Session';

  @override
  String get missedWorkoutsAlert => 'Missed workouts';

  @override
  String get lowNutritionAdherence => 'Low nutrition adherence';

  @override
  String get weightPlateau => 'Weight plateau (3+ weeks)';

  @override
  String get healthTrainingHistory => 'Health & Training History';

  @override
  String get trainingExperience => 'TRAINING EXPERIENCE';

  @override
  String get previousTraining => 'PREVIOUS TRAINING';

  @override
  String get reasonForStopping => 'REASON FOR STOPPING';

  @override
  String get diseasesConditions => 'DISEASES / CONDITIONS';

  @override
  String get allergiesLabel => 'ALLERGIES';

  @override
  String get injuriesLabel => 'INJURIES';

  @override
  String get medicationsLabel => 'MEDICATIONS';

  @override
  String get weightTrend => 'Weight Trend';

  @override
  String get noWeightLogs => 'No weight logs yet.';

  @override
  String get thisWeek => 'This Week';

  @override
  String get bodyMeasurements => 'Body Measurements';

  @override
  String get fromTrainee => 'From Trainee';

  @override
  String get poseCheckIns => 'Pose check-ins';

  @override
  String get allDates => 'All dates';

  @override
  String get clear => 'Clear';

  @override
  String get noPhotosInRange => 'No photos in this range.';

  @override
  String get front => 'Front';

  @override
  String get sideLabel => 'Side';

  @override
  String get backLabel => 'Back';

  @override
  String get traineeFeedback => 'Trainee Feedback';

  @override
  String get noFeedbackYet => 'No feedback entries yet.';

  @override
  String get latest => 'Latest';

  @override
  String feedbackForTrainee(String name) {
    return 'Feedback for $name';
  }

  @override
  String get feedbackHint =>
      'Write your feedback here... This will be visible to the trainee.';

  @override
  String get cautionMedicalNotes => 'Caution / Medical Notes';

  @override
  String get cautionHint =>
      'Injuries, restrictions, things to watch out for...';

  @override
  String get saveNotes => 'Save Notes';

  @override
  String get saving => 'Saving…';

  @override
  String get uploading => 'Uploading…';

  @override
  String get uploadImageOrPdf => 'Upload image or PDF';

  @override
  String get noInBodyReports => 'No InBody reports yet.';

  @override
  String get inBodyReportsSubtitle =>
      'Upload scans or PDFs from the device. Expand a row to preview.';

  @override
  String get noGoalsYet => 'No goals listed yet.';

  @override
  String get tapToMarkDone =>
      'Tap to mark done · Tap ✏ to edit · Swipe left to delete';

  @override
  String get addNewGoal => 'Add a new goal...';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get goalDescription => 'Goal description…';

  @override
  String get levelAndGoal => 'Level & Goal';

  @override
  String get traineeLevelLabel => 'TRAINEE LEVEL';

  @override
  String get goalHint => 'e.g. Lose 5 kg, Build muscle...';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get traineeInfo => 'Trainee Info';

  @override
  String get archiveTraineeQuestion => 'Archive trainee?';

  @override
  String archiveTraineeBody(String name) {
    return '$name will be archived. You can restore them later if your app supports it.';
  }

  @override
  String get archive => 'Archive';

  @override
  String get deleteTraineePermanently => 'Delete trainee permanently?';

  @override
  String deleteTraineeBody(String name) {
    return 'This will remove $name and their data. This action cannot be undone.';
  }

  @override
  String get deleteTraineePermanentlyBtn => 'Delete Trainee Permanently';

  @override
  String get planAssignedSuccess => 'Plan assigned successfully!';

  @override
  String get templateSavedMsg => 'Template saved on this device';

  @override
  String get draftSavedMsg => 'Draft saved on this device';

  @override
  String get savedTemplates => 'SAVED TEMPLATES';

  @override
  String get startFromScratch => 'Start from Scratch';

  @override
  String get searchTrainees => 'Search trainees...';

  @override
  String get noActiveTraineesFound => 'No active trainees found';

  @override
  String get inviteTraineesFirst => 'Invite trainees first to create a plan';

  @override
  String get selectAll => 'Select All';

  @override
  String get assignmentDate => 'ASSIGNMENT DATE';

  @override
  String get recurrence => 'RECURRENCE';

  @override
  String get selectDateOrAssignImmediately =>
      'Select date (or assign immediately)';

  @override
  String get planLabel => 'PLAN';

  @override
  String get sessionsLabel => 'SESSIONS';

  @override
  String get addSession => 'Add session';

  @override
  String get nameDayHint =>
      'Name each day (e.g. Leg Day) and add exercises from the library.';

  @override
  String traineesSelected(int count) {
    return '$count trainees selected';
  }

  @override
  String get planAndSessions => 'Plan & sessions';

  @override
  String get untitledPlan => 'Untitled plan';

  @override
  String get assignedTo => 'Assigned to';

  @override
  String get schedule => 'Schedule';

  @override
  String get meals => 'Meals';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snacks => 'Snacks';

  @override
  String get mySavedTemplates => 'MY SAVED TEMPLATES';

  @override
  String get starterTemplates => 'STARTER TEMPLATES';

  @override
  String get workoutComplete => 'Workout Complete!';

  @override
  String get amazingEffort => 'Amazing effort!';

  @override
  String get coachNotified => 'Your coach has been notified of your results.';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get shareResults => 'Share Results';

  @override
  String get duration => 'Duration';

  @override
  String minutes(int count) {
    return '$count min';
  }

  @override
  String get setsCompleted => 'Sets Completed';

  @override
  String get exercisesCompleted => 'Exercises Completed';

  @override
  String get workoutSummary => 'Workout Summary';

  @override
  String get noWorkoutPlan => 'No Workout Plan';

  @override
  String get noWorkoutPlanDesc =>
      'Your coach hasn\'t assigned a workout plan yet.';

  @override
  String caloriesRemaining(int cal) {
    return '$cal cal remaining';
  }

  @override
  String mealsLogged(int logged, int total) {
    return '$logged/$total meals logged';
  }

  @override
  String get logFood => 'Log Food';

  @override
  String get addCustomMeal => 'Add Custom Meal';

  @override
  String get customMealName => 'Custom meal name';

  @override
  String get logMealBtn => 'Log Meal';

  @override
  String get searchFoodHint => 'Search food...';

  @override
  String get weeklyGoals => 'Weekly Goals';

  @override
  String get water => 'Water';

  @override
  String liters(String amount) {
    return '${amount}L';
  }

  @override
  String get couldNotLoadProgress => 'Could not load progress data.';

  @override
  String setXofY(int current, int total) {
    return 'Set $current of $total';
  }

  @override
  String get completeSet => 'Complete Set';

  @override
  String get skipSet => 'Skip Set';

  @override
  String get nextExercise => 'Next Exercise';

  @override
  String get finishWorkout => 'Finish Workout';

  @override
  String exerciseXofY(int current, int total) {
    return 'Exercise $current of $total';
  }

  @override
  String get couldNotReadFile =>
      'Could not read the selected file. Try a smaller file or re-save the export.';

  @override
  String get allFilter => 'All';

  @override
  String get attentionFilter => 'Attention';

  @override
  String notesForTrainee(String name) {
    return 'Notes saved for $name';
  }

  @override
  String get comingSoonSettings =>
      'Coming soon — settings update not yet available';

  @override
  String get notificationsLabel => 'NOTIFICATIONS';

  @override
  String get remindTrainee => 'Remind trainee';

  @override
  String get alertIfMissed => 'Alert if missed';

  @override
  String get timeLabel => 'TIME';

  @override
  String get dateLabel => 'DATE';

  @override
  String get goalsLabel => 'Goals';

  @override
  String get doneSuffix => 'done';

  @override
  String get myDrafts => 'My Drafts';

  @override
  String get continueEditingPlans => 'Continue editing saved plans';

  @override
  String get buildCustomWorkout => 'Build a completely custom workout';

  @override
  String get buildCustomNutrition => 'Build a completely custom nutrition plan';

  @override
  String get noSavedTemplatesYet => 'No saved templates yet';

  @override
  String get templatesSavedWillAppearHere => 'Templates you save will appear here';

  @override
  String get confirmAndAssignWorkout => 'CONFIRM & ASSIGN WORKOUT';

  @override
  String get assignNutritionPlanBtn => 'Assign Nutrition Plan →';

  @override
  String get saveDraft => 'Save Draft';

  @override
  String get saveTemplate => 'Save Template';

  @override
  String get saveAsTemplate => 'Save as Template';

  @override
  String get loadDraft => 'Load draft';

  @override
  String get loadTemplateBtn => 'Load template…';

  @override
  String get savedOnDevice => 'Saved on this device (no cloud sync)';

  @override
  String get finalCheckBeforeSending => 'Final check before sending to trainees';

  @override
  String get remindTraineeBeforeWorkout => 'Remind trainee before workout';

  @override
  String get sendNotification30Min => 'Send notification 30 min before';

  @override
  String get alertIfMissedSubtitle => 'Notify you when trainee misses a session';

  @override
  String selectAllActiveTrainees(int count) => 'Select all active trainees ($count)';

  @override
  String get exerciseLibrary => 'Exercise library';

  @override
  String get searchExercisesHint => 'Search exercises...';

  @override
  String get addFromLibrary => 'Add from library';

  @override
  String get addCustom => 'Add Custom';

  @override
  String get libraryBtn => 'Library';

  @override
  String get hasVideo => 'Has video';

  @override
  String get removeSession => 'Remove session';

  @override
  String get planTitleLabel => 'Plan title *';

  @override
  String get planTitleHint => 'e.g. 4-week strength block';

  @override
  String get descriptionInstructions => 'DESCRIPTION / INSTRUCTIONS';

  @override
  String get optionalPlanDescription => 'Optional plan description for trainees...';

  @override
  String get cautionNotesLabel => 'CAUTION / NOTES';

  @override
  String get optionalSafetyNotes => 'Optional safety notes...';

  @override
  String get sessionTitleLabel => 'Session title';

  @override
  String get sessionTitleHint => 'e.g. Push day, Leg day';

  @override
  String get loadFieldLabel => 'Load (e.g. 60kg)';

  @override
  String get restFieldLabel => 'Rest (e.g. 90s)';

  @override
  String get videoUrl => 'Video URL';

  @override
  String get setQuantityGrams => 'Set quantity (grams):';

  @override
  String addToMeal(String meal) => 'Add to $meal';

  @override
  String get nutritionPlanReady => 'Nutrition plan ready';

  @override
  String get addNutritionPlanName => 'Add a nutrition plan name';

  @override
  String get nutritionPlanNameHint => 'Nutrition plan name *';

  @override
  String get useTemplate => 'Use template →';

  @override
  String get remindTraineeBeforeSession => 'Remind trainee before session';

  @override
  String get alertMePlanMissed => 'Alert me if plan missed';

  @override
  String get workoutTemplatesDeviceStorage => 'Workout templates (device storage)';

  @override
  String get nutritionTemplatesDeviceStorage => 'Nutrition templates (device storage)';

  @override
  String get noSavedTemplatesSnackbar => 'No saved templates on this device yet.';

  @override
  String get immediatelyLabel => 'Immediately';

  @override
  String get traineeWillBeReminded => 'Trainee will be reminded';

  @override
  String get alertIfMissedSuffix => '· Alert if missed';

  @override
  String get noTraineeSelected => 'No trainee selected';

  @override
  String get noIngredientsAvailable => 'No ingredients available.';

  @override
  String get searchIngredientsHint => 'Search ingredients...';

  @override
  String get addToMealBtn => 'Add to Meal';

  @override
  String nutritionFactsPer(String amount) => 'Nutrition Facts · per ${amount}g';

  @override
  String get coachGoals => 'Coach Goals';

  @override
  String setByCoach(String name) => 'Set by $name';

  @override
  String get todaysWorkout => "Today's Workout";

  @override
  String get todaysNutrition => "Today's Nutrition";

  @override
  String get noWorkoutAssigned => 'No workout assigned';

  @override
  String get noNutritionPlanAssigned => 'No nutrition plan assigned';

  @override
  String exercisesDone(int done, int total) => '$done of $total exercises done';

  @override
  String get monthlyGoal => 'Monthly Goal';

  @override
  String reachKg(String kg) => 'Reach $kg kg';

  @override
  String get mealsLoggedLabel => 'Meals Logged';

  @override
  String get waterLitersLabel => 'Water (L)';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountBody =>
      'This will permanently delete your account and all your data. This action cannot be undone.';

  @override
  String get typeDeleteToConfirm => 'Type DELETE to confirm:';

  @override
  String get manageYourMembership => 'Manage your membership';

  @override
  String get noPaymentMethod => 'No payment method';

  @override
  String get addCardToUpgrade => 'Add a card to upgrade your plan';

  @override
  String get addPaymentMethod => 'Add Payment Method';

  @override
  String get frequentlyAskedQuestions => 'Frequently asked questions';

  @override
  String get hereToHelp => "We're here to help. Reach out anytime.";

  @override
  String sessionNumber(int number) => 'Session $number';

  @override
  String get difficulty => 'Difficulty';

  @override
  String dayStreakCount(int count) => '$count-day streak!';

  @override
  String moreDaysToBadge(int days, String badge) =>
      '$days more day to earn the $badge badge';
}
