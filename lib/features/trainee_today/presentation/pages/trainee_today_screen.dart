import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/features/trainee_app/domain/entities/trainee_dashboard_today.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/progress_bar.dart';
import '../bloc/trainee_today_cubit.dart';
import 'trainee_exercise_plan_screen.dart';

class TraineeTodayScreen extends StatelessWidget {
  const TraineeTodayScreen({super.key});

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
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined,
                      color: AppColors.textPrimary),
                  onPressed: () {},
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
                  onPressed: () => context.read<TraineeTodayCubit>().load(),
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
                Text(
                  'Good evening, $firstName!',
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
                const SizedBox(height: 24),

                // Streak card
                if (dashboard != null)
                  Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDD5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFA94D),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_fire_department, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${dashboard.streak.currentDays}-day streak!',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${dashboard.streak.nextBadgeInDays} more day to earn the ${dashboard.streak.nextBadgeName} badge',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${dashboard.streak.currentDays}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF6B3D),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Coach Goals',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (coachName != null && coachName.isNotEmpty)
                                Text(
                                  'Set by $coachName',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                          if (primaryGoal != null && primaryGoal.isNotEmpty)
                            Text(
                              primaryGoal,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
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
                      else if (primaryGoal != null && primaryGoal.isNotEmpty)
                        _buildGoalRow(false, primaryGoal)
                      else
                        _buildGoalRow(false, 'Work towards your main goal'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Today's workout card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today's Workout",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          if (dashboard?.todayWorkoutSummary.difficulty
                                  .isNotEmpty ==
                              true)
                            Text(
                              _capitalize(
                                  dashboard!.todayWorkoutSummary.difficulty),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        dashboard?.todayWorkoutSummary.title.isNotEmpty == true
                            ? dashboard!.todayWorkoutSummary.title
                            : (workoutPlan?.title.isNotEmpty == true
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
                        workoutPlan?.description.isNotEmpty == true
                            ? workoutPlan!.description
                            : '—',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 14),
                      CustomProgressBar(
                        value: (dashboard?.todayWorkoutSummary.exercisesDone ??
                                0)
                            .toDouble(),
                        max: (dashboard?.todayWorkoutSummary.exercisesTotal ??
                                0)
                            .toDouble(),
                        color: Colors.white,
                        height: 6,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dashboard != null
                                ? '${dashboard.todayWorkoutSummary.exercisesDone} of ${dashboard.todayWorkoutSummary.exercisesTotal} exercises done'
                                : '—',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              if (workoutPlan == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No workout plan assigned yet.'),
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TraineeExercisePlanScreen(
                                    plan: workoutPlan,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'View',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                  backgroundColor: AppColors.surface,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.surface,
                                  ),
                                ),
                                CircularProgressIndicator(
                                  value: dashboard != null &&
                                          dashboard
                                                  .todayNutritionSummary
                                                  .caloriesTarget >
                                              0
                                      ? dashboard.todayNutritionSummary
                                              .caloriesConsumed /
                                          dashboard.todayNutritionSummary
                                              .caloriesTarget
                                      : 0,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.transparent,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
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
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        dashboard != null
                                            ? '/${dashboard.todayNutritionSummary.caloriesTarget}'
                                            : '/0',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dashboard?.todayNutritionSummary.title
                                              .isNotEmpty ==
                                          true
                                      ? dashboard!.todayNutritionSummary.title
                                      : (nutritionPlan?.title.isNotEmpty == true
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
                      Row(
                        children: [
                          Expanded(
                            child: _buildMealChip(
                              label: 'Bkfast',
                              kcal: _mealKcalText(
                                dashboard,
                                slotIndex: 0,
                              ),
                              isActive: true,
                              onTap: () =>
                                  _handleMealTap(context, dashboard),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMealChip(
                              label: 'Lunch',
                              kcal: _mealKcalText(
                                dashboard,
                                slotIndex: 1,
                              ),
                              isActive: false,
                              onTap: () =>
                                  _handleMealTap(context, dashboard),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMealChip(
                              label: 'Dinner',
                              kcal: _mealKcalText(
                                dashboard,
                                slotIndex: 2,
                              ),
                              isActive: false,
                              onTap: () =>
                                  _handleMealTap(context, dashboard),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMealChip(
                              label: 'Snack',
                              kcal: _mealKcalText(
                                dashboard,
                                slotIndex: 3,
                              ),
                              isActive: false,
                              onTap: () =>
                                  _handleMealTap(context, dashboard),
                            ),
                          ),
                        ],
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
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: a.unlocked
                                          ? AppColors.primaryLight
                                          : AppColors.surface,
                                      borderRadius: BorderRadius.circular(14),
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
                                          a.label,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: a.unlocked
                                                ? AppColors.primary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          a.level,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
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
                          value: dashboard.weeklyGoals.workoutsCompleted,
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
                          max: dashboard.weeklyGoals.waterTargetLiters,
                        ),
                        const SizedBox(height: 14),
                        Text(
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

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  String _mealKcalText(
    TraineeDashboardToday? dashboard, {
    required int slotIndex,
  }) {
    if (dashboard == null ||
        dashboard.todayNutritionSummary.caloriesTarget <= 0) {
      return '0 kcal';
    }
    // Simple even split of target across 4 meals, so still derived from backend
    final perMeal =
        (dashboard.todayNutritionSummary.caloriesTarget / 4).round();
    return '$perMeal kcal';
  }

  Future<void> _handleMealTap(
    BuildContext context,
    TraineeDashboardToday? dashboard,
  ) async {
    if (dashboard == null ||
        dashboard.todayNutritionSummary.planId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No nutrition plan assigned yet.'),
        ),
      );
      return;
    }

    final repo = di.sl<TraineeAppRepository>();
    try {
      await repo.completeMeal(dashboard.todayNutritionSummary.planId);
      // Refresh dashboard to update calories/mealsLogged later if backend supports it
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal marked as completed.'),
        ),
      );
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
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: completed ? AppColors.success : AppColors.border,
              ),
            ),
            child: Icon(
              completed ? Icons.check : Icons.circle_outlined,
              size: 14,
              color: completed ? Colors.white : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: completed ? AppColors.textSecondary : AppColors.textPrimary,
                decoration: completed ? TextDecoration.lineThrough : null,
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