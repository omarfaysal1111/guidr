import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/features/trainee_app/domain/entities/trainee_dashboard_today.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../bloc/trainee_today_cubit.dart';
import 'trainee_exercise_plan_screen.dart';

class TraineeTodayScreen extends StatefulWidget {
  const TraineeTodayScreen({super.key});

  @override
  State<TraineeTodayScreen> createState() => _TraineeTodayScreenState();
}

class _TraineeTodayScreenState extends State<TraineeTodayScreen> {
  bool _notifExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<TraineeTodayCubit>()..load(),
      child: BlocBuilder<TraineeTodayCubit, TraineeTodayState>(
        builder: (context, state) {
          final now = DateTime.now();
          const weekdays = [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday'
          ];
          const months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
          ];
          final dateLabel =
              '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

          final hour = now.hour;
          final greeting = hour < 12
              ? 'Good morning'
              : hour < 17
                  ? 'Good afternoon'
                  : 'Good evening';

          final dashboard = state.dashboard;
          final fullName =
              dashboard?.profile.fullName.trim() ?? state.profile?.fullName.trim();
          final firstName = (fullName != null && fullName.isNotEmpty)
              ? fullName.split(' ').first
              : 'there';

          final coachName =
              dashboard?.coach.fullName.trim() ?? state.coach?.fullName.trim();
          final primaryGoal =
              dashboard?.profile.fitnessGoal?.trim() ?? state.profile?.fitnessGoal?.trim();

          final workoutPlan = state.exercisePlans.isNotEmpty
              ? state.exercisePlans.first
              : null;
          final nutritionPlan = state.nutritionPlans.isNotEmpty
              ? state.nutritionPlans.first
              : null;

          // Determine whether to show notifications badge
          const hasNotifications = true;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              titleSpacing: 20,
              title: const Text(
                'guider.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              actions: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined,
                          color: AppColors.textPrimary),
                      onPressed: () {
                        setState(() {
                          _notifExpanded = !_notifExpanded;
                        });
                      },
                    ),
                    if (hasNotifications)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            body: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<TraineeTodayCubit>().load(),
              child: state.loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : (state.error != null
                      ? ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            Text(
                              state.error!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<TraineeTodayCubit>().load(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          children: [
                            const SizedBox(height: 8),

                            // Greeting
                            Text(
                              '$greeting, $firstName!',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateLabel,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Notification section
                            _buildNotificationSection(),
                            const SizedBox(height: 16),

                            // Streak card
                            if (dashboard != null)
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF97316),
                                      Color(0xFFEF4444)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.25),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                          Icons.local_fire_department,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${dashboard.streak.currentDays}-day streak!',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${dashboard.streak.nextBadgeInDays} more day to earn the ${dashboard.streak.nextBadgeName} badge',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  Colors.white.withOpacity(0.85),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${dashboard.streak.currentDays}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: Color(0xFFF97316),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 20),

                            // Coach goals
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Coach Goals',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          if (coachName != null &&
                                              coachName.isNotEmpty)
                                            Text(
                                              'Set by $coachName',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (primaryGoal != null &&
                                          primaryGoal.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            primaryGoal,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  if (dashboard != null &&
                                      dashboard.coachGoals.isNotEmpty)
                                    ...dashboard.coachGoals.map(
                                      (g) => _buildGoalRow(g.completed, g.label),
                                    )
                                  else if (primaryGoal != null &&
                                      primaryGoal.isNotEmpty)
                                    _buildGoalRow(false, primaryGoal)
                                  else
                                    _buildGoalRow(
                                        false, 'Work towards your main goal'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Today's workout card
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF34D399),
                                    Color(0xFF2BC48A),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Stack(
                                children: [
                                  // Decorative circle top-right
                                  Positioned(
                                    top: -20,
                                    right: -20,
                                    child: Container(
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.08),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 20,
                                    right: 20,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.06),
                                      ),
                                    ),
                                  ),
                                  // Card content
                                  Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              "Today's Workout",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            if (dashboard?.todayWorkoutSummary
                                                        .difficulty
                                                        .isNotEmpty ==
                                                    true)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  _capitalize(dashboard!
                                                      .todayWorkoutSummary
                                                      .difficulty),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          dashboard?.todayWorkoutSummary.title
                                                      .isNotEmpty ==
                                                  true
                                              ? dashboard!
                                                  .todayWorkoutSummary.title
                                              : (workoutPlan?.title.isNotEmpty ==
                                                      true
                                                  ? workoutPlan!.title
                                                  : 'No workout assigned'),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          workoutPlan?.description.isNotEmpty ==
                                                  true
                                              ? workoutPlan!.description
                                              : '—',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                Colors.white.withOpacity(0.85),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        CustomProgressBar(
                                          value: (dashboard?.todayWorkoutSummary
                                                      .exercisesDone ??
                                                  0)
                                              .toDouble(),
                                          max: (dashboard?.todayWorkoutSummary
                                                      .exercisesTotal ??
                                                  0)
                                              .toDouble(),
                                          color: Colors.white,
                                          height: 6,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              dashboard != null
                                                  ? '${dashboard.todayWorkoutSummary.exercisesDone} of ${dashboard.todayWorkoutSummary.exercisesTotal} exercises done'
                                                  : '—',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white
                                                    .withOpacity(0.85),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (workoutPlan == null) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'No workout plan assigned yet.'),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        TraineeExercisePlanScreen(
                                                      plan: workoutPlan,
                                                    ),
                                                  ),
                                                ).then((_) {
                                                  if (context.mounted) {
                                                    context
                                                        .read<
                                                            TraineeTodayCubit>()
                                                        .load();
                                                  }
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 7),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.12),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: const Text(
                                                  'View',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF2BC48A),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Today's nutrition
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "Today's Nutrition",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'View all',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            CircularProgressIndicator(
                                              value: 1,
                                              strokeWidth: 8,
                                              backgroundColor:
                                                  AppColors.surface,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                      Color>(
                                                AppColors.surface,
                                              ),
                                            ),
                                            CircularProgressIndicator(
                                              value: dashboard != null &&
                                                      dashboard
                                                              .todayNutritionSummary
                                                              .caloriesTarget >
                                                          0
                                                  ? dashboard
                                                          .todayNutritionSummary
                                                          .caloriesConsumed /
                                                      dashboard
                                                          .todayNutritionSummary
                                                          .caloriesTarget
                                                  : 0,
                                              strokeWidth: 8,
                                              backgroundColor:
                                                  Colors.transparent,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                      Color>(
                                                AppColors.primary,
                                              ),
                                            ),
                                            Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    dashboard != null
                                                        ? '${dashboard.todayNutritionSummary.caloriesConsumed}'
                                                        : '0',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  Text(
                                                    dashboard != null
                                                        ? '/${dashboard.todayNutritionSummary.caloriesTarget}'
                                                        : '/0',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dashboard?.todayNutritionSummary
                                                          .title
                                                          .isNotEmpty ==
                                                      true
                                                  ? dashboard!
                                                      .todayNutritionSummary
                                                      .title
                                                  : (nutritionPlan?.title
                                                              .isNotEmpty ==
                                                          true
                                                      ? nutritionPlan!.title
                                                      : 'No nutrition plan assigned'),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            _MacroRow(
                                              label: 'Protein',
                                              value: dashboard != null
                                                  ? '${dashboard.todayNutritionSummary.proteinGrams}/${dashboard.todayNutritionSummary.proteinTarget}g'
                                                  : '—',
                                              color: Colors.purple,
                                            ),
                                            _MacroRow(
                                              label: 'Carbs',
                                              value: dashboard != null
                                                  ? '${dashboard.todayNutritionSummary.carbsGrams}/${dashboard.todayNutritionSummary.carbsTarget}g'
                                                  : '—',
                                              color: Colors.orange,
                                            ),
                                            _MacroRow(
                                              label: 'Fat',
                                              value: dashboard != null
                                                  ? '${dashboard.todayNutritionSummary.fatGrams}/${dashboard.todayNutritionSummary.fatTarget}g'
                                                  : '—',
                                              color: Colors.redAccent,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  // Meals chips row
                                  if (dashboard != null &&
                                      dashboard.todayNutritionSummary.meals
                                          .isNotEmpty)
                                    SizedBox(
                                      height: 70,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: dashboard
                                            .todayNutritionSummary.meals.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                          final meal = dashboard
                                              .todayNutritionSummary
                                              .meals[index];
                                          return SizedBox(
                                            width: 80,
                                            child: _buildMealChip(
                                              label: meal.name.isNotEmpty
                                                  ? meal.name
                                                  : 'Meal ${index + 1}',
                                              kcal: '${meal.calories} kcal',
                                              isActive: meal.completed,
                                              onTap: () {
                                                if (!meal.completed) {
                                                  _handleMealTap(
                                                      context, meal.id);
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Achievements
                            if (dashboard != null)
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Achievements',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: dashboard.achievements
                                            .map(
                                              (a) => Container(
                                                margin: const EdgeInsets.only(
                                                    right: 8),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: a.unlocked
                                                      ? AppColors.primaryLight
                                                      : AppColors.surface,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: a.unlocked
                                                        ? AppColors.primary
                                                        : AppColors.border,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      a.unlocked
                                                          ? '🏆 ${a.label}'
                                                          : a.label,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: a.unlocked
                                                            ? AppColors.primary
                                                            : AppColors
                                                                .textSecondary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      a.level,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Weekly goals
                            if (dashboard != null)
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Weekly Goals',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    _buildWeeklyBar(
                                      label: 'Workouts',
                                      value: dashboard
                                          .weeklyGoals.workoutsCompleted,
                                      max: dashboard.weeklyGoals.workoutsTarget,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildWeeklyBar(
                                      label: 'Meals Logged',
                                      value: dashboard.weeklyGoals.mealsLogged,
                                      max: dashboard.weeklyGoals.mealsTarget,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildWeeklyBar(
                                      label: 'Water (L)',
                                      value: dashboard.weeklyGoals.waterLiters,
                                      max: dashboard
                                          .weeklyGoals.waterTargetLiters,
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'Monthly Goal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Reach ${dashboard.weeklyGoals.weightTarget.toStringAsFixed(1)} kg',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        )),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Notification section
  // ---------------------------------------------------------------------------

  Widget _buildNotificationSection() {
    return Column(
      children: [
        // Collapsed row / toggle
        GestureDetector(
          onTap: () {
            setState(() {
              _notifExpanded = !_notifExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: _notifExpanded
                  ? const BorderRadius.vertical(top: Radius.circular(14))
                  : BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_none_outlined,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '3 notifications',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _notifExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down,
                      size: 20, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),

        // Expanded notification cards
        if (_notifExpanded)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(14)),
              border: Border(
                left: BorderSide(color: AppColors.border),
                right: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              children: [
                _buildNotifCard(
                  color: const Color(0xFF8B5CF6),
                  icon: Icons.chat_bubble_outline,
                  title: 'Coach Mike sent a message',
                  description:
                      'Great progress this week! Let\'s adjust your...',
                ),
                _buildNotifCard(
                  color: const Color(0xFF10B981),
                  icon: Icons.fitness_center,
                  title: 'Workout completed!',
                  description:
                      'You finished Monday workout. +7 day streak.',
                ),
                _buildNotifCard(
                  color: const Color(0xFFF59E0B),
                  icon: Icons.restaurant_outlined,
                  title: 'Nutrition reminder',
                  description:
                      'Don\'t forget to log lunch before 2pm!',
                  isLast: true,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNotifCard({
    required Color color,
    required IconData icon,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: color, width: 4),
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: AppColors.border),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Future<void> _handleMealTap(
    BuildContext context,
    int mealId,
  ) async {
    final repo = di.sl<TraineeAppRepository>();
    try {
      await repo.completeMeal(mealId);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal marked as completed.'),
        ),
      );
      if (context.mounted) {
        context.read<TraineeTodayCubit>().load();
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  Widget _buildGoalRow(bool completed, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: completed ? AppColors.success : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: completed ? AppColors.success : AppColors.border,
              ),
            ),
            child: completed
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.textSecondary, width: 1.5),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: completed
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                decoration:
                    completed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBar({
    required String label,
    required int value,
    required int max,
  }) {
    final clampedMax = max == 0 ? 1 : max;
    final ratio = (value / clampedMax).clamp(0, 1);
    final percent = (ratio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$value/$max ($percent%)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        CustomProgressBar(
          value: value.toDouble(),
          max: clampedMax.toDouble(),
          color: AppColors.primary,
          height: 6,
        ),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildMealChip({
  required String label,
  required String kcal,
  required bool isActive,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            kcal,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ),
  );
}
