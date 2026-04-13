import 'package:flutter/material.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/features/trainee_app/domain/entities/trainee_dashboard_today.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';
import '../../../../core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Data models for static meal content
// ---------------------------------------------------------------------------

class _FoodItem {
  final String name;
  final String portion;
  final int calories;
  const _FoodItem(this.name, this.portion, this.calories);
}

class _MealData {
  final String title;
  final String time;
  final int totalCalories;
  final int mealId;
  final List<_FoodItem> items;
  final String? instruction;
  final String? caution;
  const _MealData({
    required this.title,
    required this.time,
    required this.totalCalories,
    required this.mealId,
    required this.items,
    this.instruction,
    this.caution,
  });
}

const List<_MealData> _kMeals = [
  _MealData(
    title: 'Breakfast',
    time: '07:30',
    totalCalories: 480,
    mealId: 1,
    items: [
      _FoodItem('Oatmeal', '80g', 240),
      _FoodItem('Banana', '1 medium', 105),
      _FoodItem('Whey Protein Shake', '1 scoop', 135),
    ],
    instruction: 'Eat within 20 minutes of waking up. Drink a full glass of water first.',
  ),
  _MealData(
    title: 'Lunch',
    time: '12:30',
    totalCalories: 500,
    mealId: 2,
    items: [
      _FoodItem('Grilled Chicken Breast', '180g', 280),
      _FoodItem('Brown Rice', '150g', 180),
      _FoodItem('Steamed Broccoli', '120g', 40),
    ],
    instruction: 'Eat slowly and chew thoroughly. Have this meal within 30 min after training.',
    caution: 'Avoid adding extra sauces or dressing — they add hidden calories.',
  ),
  _MealData(
    title: 'Snack',
    time: '16:00',
    totalCalories: 170,
    mealId: 3,
    items: [
      _FoodItem('Greek Yogurt', '200g', 130),
      _FoodItem('Mixed Berries', '80g', 40),
    ],
    caution: 'Do not replace with flavored yogurt — too much sugar.',
  ),
  _MealData(
    title: 'Dinner',
    time: '19:30',
    totalCalories: 700,
    mealId: 4,
    items: [
      _FoodItem('Salmon Fillet', '200g', 400),
      _FoodItem('Sweet Potato', '200g', 180),
      _FoodItem('Mixed Salad + Olive Oil', '1 bowl', 120),
    ],
    instruction: 'Eat this at least 2 hours before sleeping.',
  ),
];

// ---------------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------------

class TraineeNutritionScreen extends StatefulWidget {
  const TraineeNutritionScreen({super.key});

  @override
  State<TraineeNutritionScreen> createState() => _TraineeNutritionScreenState();
}

class _TraineeNutritionScreenState extends State<TraineeNutritionScreen> {
  TraineeDashboardToday? _dashboard;
  bool _loading = true;
  String? _error;
  final Map<String, bool> _mealCompleted = {
    'Breakfast': false,
    'Lunch': false,
    'Snack': false,
    'Dinner': false,
  };
  int? _expandedMealIndex;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = di.sl<TraineeAppRepository>();
      final dashboard = await repo.getDashboardToday();
      setState(() {
        _dashboard = dashboard;
        _loading = false;
        final c = dashboard.todayNutritionSummary.caloriesConsumed;
        _mealCompleted['Breakfast'] = c > 0;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _toggleMeal(String key, int mealId) async {
    final current = _mealCompleted[key] ?? false;
    setState(() {
      _mealCompleted[key] = !current;
    });

    try {
      final repo = di.sl<TraineeAppRepository>();
      await repo.completeMeal(mealId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !current ? 'Meal marked as completed.' : 'Meal marked as not completed.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _mealCompleted[key] = current;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = _dashboard;
    final summary = dashboard?.todayNutritionSummary;
    final coachName = dashboard?.coach.fullName;
    final caloriesConsumed = summary?.caloriesConsumed ?? 0;
    final caloriesTarget = summary?.caloriesTarget ?? 0;
    final caloriesRemaining =
        caloriesTarget > 0 ? (caloriesTarget - caloriesConsumed).clamp(0, caloriesTarget) : 0;
    final mealsLogged = _mealCompleted.values.where((v) => v).length;

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
        onRefresh: _load,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
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

                      // ── Header ──────────────────────────────────────────
                      const Text(
                        "Today's Nutrition",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coachName != null && coachName.isNotEmpty
                            ? 'Assigned by $coachName'
                            : 'Assigned by your coach',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$mealsLogged/4 meals logged',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Main Calorie Card ────────────────────────────────
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Circular calorie progress
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CircularProgressIndicator(
                                        value: 1,
                                        strokeWidth: 8,
                                        backgroundColor: AppColors.surface,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                AppColors.surface),
                                      ),
                                      CircularProgressIndicator(
                                        value: caloriesTarget > 0
                                            ? (caloriesConsumed / caloriesTarget)
                                                .clamp(0.0, 1.0)
                                            : 0,
                                        strokeWidth: 8,
                                        backgroundColor: Colors.transparent,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                AppColors.primary),
                                      ),
                                      Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '$caloriesConsumed',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              '/${caloriesTarget > 0 ? caloriesTarget : 0} cal',
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
                                // Macro bars
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _MacroBarRow(
                                        label: 'Protein',
                                        consumed: summary?.proteinGrams ?? 0,
                                        target: summary?.proteinTarget ?? 0,
                                        color: const Color(0xFF8B5CF6),
                                      ),
                                      const SizedBox(height: 8),
                                      _MacroBarRow(
                                        label: 'Carbs',
                                        consumed: summary?.carbsGrams ?? 0,
                                        target: summary?.carbsTarget ?? 0,
                                        color: const Color(0xFFF97316),
                                      ),
                                      const SizedBox(height: 8),
                                      _MacroBarRow(
                                        label: 'Fat',
                                        consumed: summary?.fatGrams ?? 0,
                                        target: summary?.fatTarget ?? 0,
                                        color: const Color(0xFFEF4444),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '$caloriesRemaining cal remaining',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const Divider(color: AppColors.border, height: 1),
                            const SizedBox(height: 14),

                            // ── Water Intake ─────────────────────────────
                            Row(
                              children: [
                                const Text(
                                  'Water Intake',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '5/8 glasses',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: List.generate(
                                      8,
                                      (index) => Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: index < 5
                                              ? AppColors.primaryLight
                                              : AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.water_drop,
                                          size: 16,
                                          color: index < 5
                                              ? AppColors.primary
                                              : AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: AppColors.primaryLight,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    '+250ml',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Meals header ──────────────────────────────────────
                      const Text(
                        'Meals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Meal cards ────────────────────────────────────────
                      ...List.generate(_kMeals.length, (index) {
                        final meal = _kMeals[index];
                        final isExpanded = _expandedMealIndex == index;
                        final isCompleted =
                            _mealCompleted[meal.title] ?? false;
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: index < _kMeals.length - 1 ? 10 : 0),
                          child: _ExpandableMealCard(
                            meal: meal,
                            isExpanded: isExpanded,
                            isCompleted: isCompleted,
                            onTap: () {
                              setState(() {
                                _expandedMealIndex =
                                    isExpanded ? null : index;
                              });
                            },
                            onToggle: () =>
                                _toggleMeal(meal.title, meal.mealId),
                          ),
                        );
                      }),

                      const SizedBox(height: 24),

                      // ── Coach Notes & Tips ────────────────────────────────
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
                              'Coach Notes & Tips',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Daily Tip box
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.lightbulb_outline,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Daily Tip',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Try to spread protein intake across all meals for better absorption. Aim for 30–40g per meal.',
                                          style: TextStyle(
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

                            const SizedBox(height: 10),

                            // Reminder box
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.warningLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.warning.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.warning.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.notifications_none_outlined,
                                      size: 16,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          'Reminder',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Avoid dairy within 1 hour of iron-rich meals for better nutrient absorption.',
                                          style: TextStyle(
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

                            const SizedBox(height: 14),
                            const Text(
                              'Your Notes',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              maxLines: 3,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Add a note about today\u2019s meals\u2026',
                                hintStyle: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                contentPadding: const EdgeInsets.all(12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide:
                                      const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Logging streak + badges ──────────────────────────
                      if (dashboard != null) ...[
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
                                '8-Day Logging Streak',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Log all meals to keep your streak alive!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: const LinearProgressIndicator(
                                  value: 0.8,
                                  minHeight: 6,
                                  backgroundColor: AppColors.surface,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    '8 days ago',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'Today',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
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
                                'Nutrition Badges',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _BadgeChip('Clean Eater', earned: true),
                                  _BadgeChip('Protein Pro', earned: true),
                                  _BadgeChip('On Target', earned: false),
                                  _BadgeChip('Hydrated', earned: false),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                '3 meals left to log — you\'ve got this!',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Macro bar row widget
// ---------------------------------------------------------------------------

class _MacroBarRow extends StatelessWidget {
  final String label;
  final int consumed;
  final int target;
  final Color color;

  const _MacroBarRow({
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '${consumed}g/${target}g',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Expandable meal card widget
// ---------------------------------------------------------------------------

class _ExpandableMealCard extends StatelessWidget {
  final _MealData meal;
  final bool isExpanded;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _ExpandableMealCard({
    required this.meal,
    required this.isExpanded,
    required this.isCompleted,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collapsed header — tapping the body expands, tapping checkbox toggles
          InkWell(
            borderRadius: isExpanded
                ? const BorderRadius.vertical(top: Radius.circular(18))
                : BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Meal icon placeholder
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.successLight
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _mealIcon(meal.title),
                      size: 20,
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title + time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meal.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Calorie count
                  Text(
                    '${meal.totalCalories} cal',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Expand chevron
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  // Completion checkbox — stops propagation via GestureDetector
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      onToggle();
                    },
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded body
          if (isExpanded) ...[
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food items
                  ...meal.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            item.portion,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${item.calories} cal',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Coach instruction box
                  if (meal.instruction != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              meal.instruction!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Coach caution box
                  if (meal.caution != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_outlined,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              meal.caution!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _mealIcon(String title) {
    switch (title) {
      case 'Breakfast':
        return Icons.wb_sunny_outlined;
      case 'Lunch':
        return Icons.lunch_dining_outlined;
      case 'Snack':
        return Icons.apple_outlined;
      case 'Dinner':
        return Icons.nightlight_round;
      default:
        return Icons.restaurant_outlined;
    }
  }
}

// ---------------------------------------------------------------------------
// Badge chip widget
// ---------------------------------------------------------------------------

class _BadgeChip extends StatelessWidget {
  final String label;
  final bool earned;

  const _BadgeChip(this.label, {required this.earned});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: earned ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: earned ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: earned ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
