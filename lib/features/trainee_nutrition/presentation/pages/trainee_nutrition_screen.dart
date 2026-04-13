import 'package:flutter/material.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/features/trainee_app/domain/entities/ingredient_library_item.dart';
import 'package:guidr/features/trainee_app/domain/entities/nutrition_plan_detail.dart';
import 'package:guidr/features/trainee_app/domain/entities/trainee_dashboard_today.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';
import '../../../../core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class TraineeNutritionScreen extends StatefulWidget {
  const TraineeNutritionScreen({super.key});

  @override
  State<TraineeNutritionScreen> createState() => _TraineeNutritionScreenState();
}

class _TraineeNutritionScreenState extends State<TraineeNutritionScreen> {
  TraineeDashboardToday? _dashboard;
  List<NutritionPlanDetail> _plans = [];
  bool _loading = true;
  String? _error;

  // ── Local optimistic state ─────────────────────────────────────────────────
  // Keyed by mealId
  final Set<int> _completedMeals = {};
  final Set<int> _skippedMeals = {};
  // ingredientId → swapped-to ingredient (per mealId)
  final Map<int, Map<int, IngredientLibraryItem>> _swappedIngredients = {};
  // ingredientId set per mealId
  final Map<int, Set<int>> _skippedIngredients = {};

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
      final results = await Future.wait([
        repo.getDashboardToday(),
        repo.getMyNutritionPlanDetails(),
      ]);
      final dashboard = results[0] as TraineeDashboardToday;
      final plans = results[1] as List<NutritionPlanDetail>;
      setState(() {
        _dashboard = dashboard;
        _plans = plans;
        _loading = false;
        // Seed completed meals from dashboard summary
        if (dashboard.todayNutritionSummary.caloriesConsumed > 0) {
          for (final m in dashboard.todayNutritionSummary.meals) {
            if (m.completed) _completedMeals.add(m.id);
          }
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  // ── Meal actions ───────────────────────────────────────────────────────────

  Future<void> _completeMeal(int mealId) async {
    final wasCompleted = _completedMeals.contains(mealId);
    setState(() {
      if (wasCompleted) {
        _completedMeals.remove(mealId);
      } else {
        _completedMeals.add(mealId);
        _skippedMeals.remove(mealId);
      }
    });
    try {
      await di.sl<TraineeAppRepository>().completeMeal(mealId);
      if (mounted) _showToast(wasCompleted ? 'Meal unmarked' : 'Meal completed!', success: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (wasCompleted) _completedMeals.add(mealId);
        else _completedMeals.remove(mealId);
      });
      _showToast(e.toString().replaceFirst('Exception: ', ''), success: false);
    }
  }

  Future<void> _skipMeal(int mealId) async {
    final wasSkipped = _skippedMeals.contains(mealId);
    setState(() {
      if (wasSkipped) {
        _skippedMeals.remove(mealId);
      } else {
        _skippedMeals.add(mealId);
        _completedMeals.remove(mealId);
      }
    });
    try {
      await di.sl<TraineeAppRepository>().skipMeal(mealId);
      if (mounted) _showToast(wasSkipped ? 'Meal unskipped' : 'Meal skipped', success: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (wasSkipped) _skippedMeals.add(mealId);
        else _skippedMeals.remove(mealId);
      });
      _showToast(e.toString().replaceFirst('Exception: ', ''), success: false);
    }
  }

  // ── Ingredient actions ─────────────────────────────────────────────────────

  Future<void> _skipIngredient(int mealId, int ingredientId) async {
    final set = _skippedIngredients[mealId] ??= {};
    final wasSkipped = set.contains(ingredientId);
    setState(() {
      if (wasSkipped) set.remove(ingredientId);
      else set.add(ingredientId);
    });
    try {
      await di.sl<TraineeAppRepository>().skipIngredient(mealId, ingredientId);
      if (mounted) _showToast(wasSkipped ? 'Ingredient restored' : 'Ingredient skipped', success: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (wasSkipped) set.add(ingredientId);
        else set.remove(ingredientId);
      });
      _showToast(e.toString().replaceFirst('Exception: ', ''), success: false);
    }
  }

  void _openSwapSheet(int mealId, NutritionIngredient ingredient) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _IngredientSwapSheet(
        mealId: mealId,
        ingredient: ingredient,
        onSwap: (newIngredient) async {
          Navigator.pop(ctx);
          await _doSwap(mealId, ingredient.id, newIngredient);
        },
      ),
    );
  }

  Future<void> _doSwap(
      int mealId, int ingredientId, IngredientLibraryItem newIngredient) async {
    setState(() {
      (_swappedIngredients[mealId] ??= {})[ingredientId] = newIngredient;
    });
    try {
      await di
          .sl<TraineeAppRepository>()
          .swapIngredient(mealId, ingredientId, newIngredient.id);
      if (mounted) {
        _showToast('Swapped to ${newIngredient.name}', success: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _swappedIngredients[mealId]?.remove(ingredientId));
      _showToast(e.toString().replaceFirst('Exception: ', ''), success: false);
    }
  }

  void _showToast(String message, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dashboard = _dashboard;
    final summary = dashboard?.todayNutritionSummary;
    final coachName = dashboard?.coach.fullName;
    final caloriesConsumed = summary?.caloriesConsumed ?? 0;
    final caloriesTarget = summary?.caloriesTarget ?? 0;
    final caloriesRemaining =
        caloriesTarget > 0 ? (caloriesTarget - caloriesConsumed).clamp(0, caloriesTarget) : 0;

    // Flatten all meals from all plans for display
    final allMeals = _plans.expand((p) => p.meals).toList();
    final mealsLogged = _completedMeals.length;

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
                child: CircularProgressIndicator(color: AppColors.primary))
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(_error!,
                          style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      const SizedBox(height: 8),

                      // ── Header ─────────────────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color:
                                      AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Text(
                              '$mealsLogged/${allMeals.isEmpty ? 4 : allMeals.length} logged',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Plan title chip (if loaded) ─────────────────────────
                      if (_plans.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.restaurant_menu,
                                  size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                _plans.first.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── Main Calorie Card ─────────────────────────────────
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
                                            ? (caloriesConsumed /
                                                    caloriesTarget)
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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

                            // ── Water Intake ──────────────────────────────
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
                                      (i) => Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: i < 5
                                              ? AppColors.primaryLight
                                              : AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.water_drop,
                                          size: 16,
                                          color: i < 5
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
                                        borderRadius:
                                            BorderRadius.circular(20)),
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

                      // ── Meals section ─────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            allMeals.isEmpty ? 'Meals' : 'Meals (${allMeals.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (allMeals.isEmpty)
                            const Text(
                              'No plan assigned',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Meal cards ────────────────────────────────────────
                      if (allMeals.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'No meals assigned for today.',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ...List.generate(allMeals.length, (index) {
                          final meal = allMeals[index];
                          final isExpanded = _expandedMealIndex == index;
                          final isCompleted = _completedMeals.contains(meal.id);
                          final isSkipped = _skippedMeals.contains(meal.id);
                          final swapped = _swappedIngredients[meal.id] ?? {};
                          final skippedIng =
                              _skippedIngredients[meal.id] ?? {};
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: index < allMeals.length - 1 ? 10 : 0),
                            child: _MealCard(
                              meal: meal,
                              isExpanded: isExpanded,
                              isCompleted: isCompleted,
                              isSkipped: isSkipped,
                              swappedIngredients: swapped,
                              skippedIngredients: skippedIng,
                              onTap: () => setState(() =>
                                  _expandedMealIndex =
                                      isExpanded ? null : index),
                              onComplete: () => _completeMeal(meal.id),
                              onSkip: () => _skipMeal(meal.id),
                              onSkipIngredient: (ingId) =>
                                  _skipIngredient(meal.id, ingId),
                              onSwapIngredient: (ing) =>
                                  _openSwapSheet(meal.id, ing),
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
                            _TipBox(
                              icon: Icons.lightbulb_outline,
                              label: 'Daily Tip',
                              text: 'Try to spread protein intake across all meals for better absorption. Aim for 30–40g per meal.',
                              color: AppColors.primary,
                              bgColor: AppColors.primaryLight,
                            ),
                            const SizedBox(height: 10),
                            _TipBox(
                              icon: Icons.notifications_none_outlined,
                              label: 'Reminder',
                              text: 'Avoid dairy within 1 hour of iron-rich meals for better nutrient absorption.',
                              color: AppColors.warning,
                              bgColor: AppColors.warningLight,
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
                                    color: AppColors.textMuted),
                                filled: true,
                                fillColor: AppColors.surface,
                                contentPadding: const EdgeInsets.all(12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.border),
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

                      // ── Streak & badges ───────────────────────────────────
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
                                    color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Log all meals to keep your streak alive!',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
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
                                  Text('8 days ago',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
                                  Text('Today',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
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
                                    color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: const [
                                  _BadgeChip('Clean Eater', earned: true),
                                  _BadgeChip('Protein Pro', earned: true),
                                  _BadgeChip('On Target', earned: false),
                                  _BadgeChip('Hydrated', earned: false),
                                ],
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
// Meal card widget
// ---------------------------------------------------------------------------

class _MealCard extends StatelessWidget {
  final NutritionMealDetail meal;
  final bool isExpanded;
  final bool isCompleted;
  final bool isSkipped;
  final Map<int, IngredientLibraryItem> swappedIngredients;
  final Set<int> skippedIngredients;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final void Function(int ingredientId) onSkipIngredient;
  final void Function(NutritionIngredient ingredient) onSwapIngredient;

  const _MealCard({
    required this.meal,
    required this.isExpanded,
    required this.isCompleted,
    required this.isSkipped,
    required this.swappedIngredients,
    required this.skippedIngredients,
    required this.onTap,
    required this.onComplete,
    required this.onSkip,
    required this.onSkipIngredient,
    required this.onSwapIngredient,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isCompleted
        ? AppColors.primary.withOpacity(0.4)
        : isSkipped
            ? AppColors.warning.withOpacity(0.4)
            : AppColors.border;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Collapsed header ────────────────────────────────────────────
          InkWell(
            borderRadius: isExpanded
                ? const BorderRadius.vertical(top: Radius.circular(18))
                : BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Meal icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.successLight
                          : isSkipped
                              ? AppColors.warningLight
                              : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _mealIcon(meal.name),
                      size: 20,
                      color: isCompleted
                          ? AppColors.success
                          : isSkipped
                              ? AppColors.warning
                              : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title + calories
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              meal.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSkipped
                                    ? AppColors.textMuted
                                    : AppColors.textPrimary,
                                decoration: isSkipped
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (isSkipped) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Skipped',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${meal.ingredients.length} ingredients · ${meal.calories.toInt()} cal',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Expand chevron
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  // Completion checkbox
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onComplete,
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

          // ── Expanded body ───────────────────────────────────────────────
          if (isExpanded) ...[
            const Divider(color: AppColors.border, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ingredients list
                  if (meal.ingredients.isEmpty)
                    const Text(
                      'No ingredients listed.',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    )
                  else
                    ...meal.ingredients.map((ing) {
                      final isIngSkipped =
                          skippedIngredients.contains(ing.id);
                      final swapped = swappedIngredients[ing.id];
                      return _IngredientRow(
                        ingredient: ing,
                        isSkipped: isIngSkipped,
                        swappedTo: swapped,
                        onSkip: () => onSkipIngredient(ing.id),
                        onSwap: () => onSwapIngredient(ing),
                        onUndoSwap: swapped != null
                            ? () => onSkipIngredient(ing.id)
                            : null,
                      );
                    }),

                  const SizedBox(height: 10),

                  // ── Meal action row ─────────────────────────────────────
                  Row(
                    children: [
                      // Skip meal button
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(
                            isSkipped
                                ? Icons.undo
                                : Icons.block_outlined,
                            size: 14,
                          ),
                          label: Text(isSkipped ? 'Undo Skip' : 'Skip Meal',
                              style: const TextStyle(fontSize: 12)),
                          onPressed: onSkip,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            side: BorderSide(
                                color: AppColors.warning.withOpacity(0.5)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Complete meal button
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            size: 14,
                          ),
                          label: Text(
                              isCompleted ? 'Completed' : 'Mark Done',
                              style: const TextStyle(fontSize: 12)),
                          onPressed: onComplete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCompleted
                                ? AppColors.success
                                : AppColors.primary,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _mealIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('breakfast')) return Icons.wb_sunny_outlined;
    if (lower.contains('lunch')) return Icons.lunch_dining_outlined;
    if (lower.contains('snack')) return Icons.apple_outlined;
    if (lower.contains('dinner') || lower.contains('supper')) {
      return Icons.nightlight_round;
    }
    return Icons.restaurant_outlined;
  }
}

// ---------------------------------------------------------------------------
// Ingredient row widget
// ---------------------------------------------------------------------------

class _IngredientRow extends StatelessWidget {
  final NutritionIngredient ingredient;
  final bool isSkipped;
  final IngredientLibraryItem? swappedTo;
  final VoidCallback onSkip;
  final VoidCallback onSwap;
  final VoidCallback? onUndoSwap;

  const _IngredientRow({
    required this.ingredient,
    required this.isSkipped,
    required this.swappedTo,
    required this.onSkip,
    required this.onSwap,
    this.onUndoSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Bullet dot
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: isSkipped
                  ? AppColors.warning
                  : swappedTo != null
                      ? AppColors.primary
                      : AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSkipped
                      ? ingredient.name
                      : swappedTo != null
                          ? swappedTo!.name
                          : ingredient.name,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSkipped
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    decoration:
                        isSkipped ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (swappedTo != null)
                  Row(
                    children: [
                      const Icon(Icons.swap_horiz,
                          size: 11, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Text(
                        'was: ${ingredient.name}',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Action buttons
          if (!isSkipped && swappedTo == null) ...[
            _ActionBtn(
              label: 'Skip',
              color: AppColors.warning,
              onTap: onSkip,
            ),
            const SizedBox(width: 6),
            _ActionBtn(
              label: 'Swap',
              color: AppColors.primary,
              onTap: onSwap,
            ),
          ] else if (isSkipped)
            _ActionBtn(
              label: 'Undo',
              color: AppColors.textSecondary,
              onTap: onSkip,
            )
          else if (swappedTo != null)
            _ActionBtn(
              label: 'Revert',
              color: AppColors.textSecondary,
              onTap: onUndoSwap ?? () {},
            ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Swap ingredient bottom sheet
// ---------------------------------------------------------------------------

class _IngredientSwapSheet extends StatefulWidget {
  final int mealId;
  final NutritionIngredient ingredient;
  final void Function(IngredientLibraryItem) onSwap;

  const _IngredientSwapSheet({
    required this.mealId,
    required this.ingredient,
    required this.onSwap,
  });

  @override
  State<_IngredientSwapSheet> createState() => _IngredientSwapSheetState();
}

class _IngredientSwapSheetState extends State<_IngredientSwapSheet> {
  final _controller = TextEditingController();
  List<IngredientLibraryItem> _results = [];
  bool _searching = false;
  String? _searchError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results =
          await di.sl<TraineeAppRepository>().searchIngredients(query.trim());
      if (mounted) setState(() {
        _results = results;
        _searching = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _searchError = e.toString().replaceFirst('Exception: ', '');
        _searching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Swap Ingredient',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
              children: [
                const TextSpan(text: 'Replacing: '),
                TextSpan(
                  text: widget.ingredient.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search field
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search ingredient library…',
              hintStyle:
                  const TextStyle(fontSize: 13, color: AppColors.textMuted),
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textMuted, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (v) => _search(v),
          ),
          const SizedBox(height: 12),

          // Results
          if (_searching)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_searchError != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _searchError!,
                style: const TextStyle(
                    color: AppColors.error, fontSize: 12),
              ),
            )
          else if (_results.isEmpty && _controller.text.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No ingredients found.',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.35,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _results.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (ctx, i) {
                  final item = _results[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 4),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.restaurant,
                          size: 18, color: AppColors.primary),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: item.calories != null
                        ? Text(
                            '${item.calories!.toInt()} cal',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                          )
                        : null,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Select',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () => widget.onSwap(item),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
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
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const Spacer(),
            Text('${consumed}g/${target}g',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
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

class _TipBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String text;
  final Color color;
  final Color bgColor;

  const _TipBox({
    required this.icon,
    required this.label,
    required this.text,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color)),
                const SizedBox(height: 4),
                Text(text,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
            color: earned ? AppColors.primary : AppColors.border),
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
