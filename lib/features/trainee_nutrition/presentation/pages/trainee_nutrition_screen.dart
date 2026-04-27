// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/features/trainee_app/domain/entities/extra_meal_log.dart';
import 'package:guidr/features/trainee_app/domain/entities/ingredient_library_item.dart';
import 'package:guidr/features/trainee_app/domain/entities/nutrition_plan_detail.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';
import 'package:guidr/core/widgets/notification_inbox_button.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/trainee_nutrition_cubit.dart';
import '../widgets/food_search_sheet.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class TraineeNutritionScreen extends StatelessWidget {
  const TraineeNutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TraineeNutritionCubit(
        repository: di.sl<TraineeAppRepository>(),
      )..load(),
      child: const _NutritionView(),
    );
  }
}

// ---------------------------------------------------------------------------
// Main view (BlocConsumer)
// ---------------------------------------------------------------------------

class _NutritionView extends StatelessWidget {
  const _NutritionView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TraineeNutritionCubit, TraineeNutritionState>(
      listenWhen: (prev, curr) =>
          curr.toastMessage != null &&
          curr.toastMessage != prev.toastMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.toastMessage!),
            backgroundColor:
                state.toastSuccess == true ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      builder: (context, state) {
        final cubit = context.read<TraineeNutritionCubit>();
        final dashboard = state.dashboard;
        final summary = dashboard?.todayNutritionSummary;
        final coachName = dashboard?.coach.fullName;
        final caloriesConsumed = summary?.caloriesConsumed ?? 0;
        final caloriesTarget = summary?.caloriesTarget ?? 0;
        final caloriesRemaining = caloriesTarget > 0
            ? (caloriesTarget - caloriesConsumed).clamp(0, caloriesTarget)
            : 0;

        final allMeals = state.plans.expand((p) => p.meals).toList();
        final mealsLogged = state.completedMeals.length +
            state.completedExtraMeals.length;
        final totalMealsCount = allMeals.length + state.extraMeals.length;
        final waterTargetLiters = (dashboard?.weeklyGoals.waterTargetLiters ?? 2)
            .toDouble()
            .clamp(0.5, 20.0);
        final notifItems = demoTraineeInboxNotifications();

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
                tooltip: 'Log extra food',
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.textPrimary),
                onPressed: state.loading || state.error != null
                    ? null
                    : () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          builder: (ctx) => FoodSearchSheet(
                            onLogged: cubit.addExtraMealLocally,
                          ),
                        );
                      },
              ),
              NotificationInboxButton(
                items: notifItems,
                badgeCount:
                    notifItems.isNotEmpty ? notifItems.length : null,
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
            onRefresh: cubit.load,
            child: state.loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : state.error != null
                    ? ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          Text(state.error!,
                              style: const TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: cubit.load,
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
                        padding:
                            const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        children: [
                          const SizedBox(height: 8),

                          // ── Header ──────────────────────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                                      coachName != null &&
                                              coachName.isNotEmpty
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
                                      color: AppColors.primary
                                          .withOpacity(0.3)),
                                ),
                                child: Text(
                                  '$mealsLogged/${totalMealsCount == 0 ? 4 : totalMealsCount} logged',
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

                          // ── Plan title chip ─────────────────────────────
                          if (state.plans.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.restaurant_menu,
                                      size: 14,
                                      color: AppColors.textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    state.plans.first.title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // ── Main Calorie Card ───────────────────────────
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
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
                                            backgroundColor:
                                                AppColors.surface,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                        Color>(
                                                    AppColors.surface),
                                          ),
                                          CircularProgressIndicator(
                                            value: caloriesTarget > 0
                                                ? (caloriesConsumed /
                                                        caloriesTarget)
                                                    .clamp(0.0, 1.0)
                                                : 0,
                                            strokeWidth: 8,
                                            backgroundColor:
                                                Colors.transparent,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                        Color>(
                                                    AppColors.primary),
                                          ),
                                          Center(
                                            child: Column(
                                              mainAxisSize:
                                                  MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '$caloriesConsumed',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    color: AppColors
                                                        .textPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  '/${caloriesTarget > 0 ? caloriesTarget : 0} cal',
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
                                          _MacroBarRow(
                                            label: 'Protein',
                                            consumed:
                                                summary?.proteinGrams ??
                                                    0,
                                            target:
                                                summary?.proteinTarget ??
                                                    0,
                                            color: const Color(0xFF8B5CF6),
                                          ),
                                          const SizedBox(height: 8),
                                          _MacroBarRow(
                                            label: 'Carbs',
                                            consumed:
                                                summary?.carbsGrams ?? 0,
                                            target:
                                                summary?.carbsTarget ?? 0,
                                            color: const Color(0xFFF97316),
                                          ),
                                          const SizedBox(height: 8),
                                          _MacroBarRow(
                                            label: 'Fat',
                                            consumed:
                                                summary?.fatGrams ?? 0,
                                            target:
                                                summary?.fatTarget ?? 0,
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
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ── Water intake: own card so the field is always visible/tappable
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: _TodayWaterIntakeBlock(
                              litersLogged: state.waterIntake?.liters ?? 0,
                              targetLiters: waterTargetLiters,
                              busy: state.savingWater,
                              serverUpdatedAt: state.waterIntake?.updatedAt,
                              onSave: (liters) => cubit.setTotalWaterLitersForDay(
                                liters,
                                DateTime.now(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Meals section ───────────────────────────────
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                totalMealsCount == 0
                                    ? 'Meals'
                                    : 'Meals ($totalMealsCount)',
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

                          // ── Meal cards ─────────────────────────────────
                          if (allMeals.isEmpty &&
                              state.extraMeals.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.border),
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
                          else ...[
                            ...List.generate(allMeals.length, (index) {
                              final meal = allMeals[index];
                              final isExpanded =
                                  state.expandedMealIndex == index;
                              final isCompleted =
                                  state.completedMeals.contains(meal.id);
                              final isSkipped =
                                  state.skippedMeals.contains(meal.id);
                              final swapped =
                                  state.swappedIngredients[meal.id] ?? {};
                              final skippedIng =
                                  state.skippedIngredients[meal.id] ?? {};
                              final mealQtys =
                                  state.ingredientQuantities[meal.id] ?? {};
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _MealCard(
                                  meal: meal,
                                  isExpanded: isExpanded,
                                  isCompleted: isCompleted,
                                  isSkipped: isSkipped,
                                  swappedIngredients: swapped,
                                  skippedIngredients: skippedIng,
                                  ingredientQuantities: mealQtys,
                                  onTap: () =>
                                      cubit.toggleExpandedMeal(index),
                                  onComplete: () =>
                                      cubit.completeMeal(meal.id),
                                  onSkip: () => cubit.skipMeal(meal.id),
                                  onSkipIngredient: (ingId) =>
                                      cubit.skipIngredient(meal.id, ingId),
                                  onSwapIngredient: (ing) =>
                                      _openSwapSheet(
                                          context, cubit, meal.id, ing),
                                  onUpdateQty: (ingId, qty) =>
                                      cubit.updateIngredientQuantity(
                                          meal.id, ingId, qty),
                                ),
                              );
                            }),

                            // ── Extra (ad-hoc) meals ──────────────────────
                            ...state.extraMeals.map((extra) {
                              final id = extra.id;
                              final isCompleted = id != null &&
                                  state.completedExtraMeals.contains(id);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ExtraMealCard(
                                  meal: extra,
                                  isCompleted: isCompleted,
                                  onComplete: id != null
                                      ? () => cubit
                                          .toggleExtraMealComplete(id)
                                      : null,
                                ),
                              );
                            }),
                          ],

                          const SizedBox(height: 24),

                          // ── Coach Notes & Tips ──────────────────────────
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                  text:
                                      'Try to spread protein intake across all meals for better absorption. Aim for 30–40g per meal.',
                                  color: AppColors.primary,
                                  bgColor: AppColors.primaryLight,
                                ),
                                const SizedBox(height: 10),
                                _TipBox(
                                  icon:
                                      Icons.notifications_none_outlined,
                                  label: 'Reminder',
                                  text:
                                      'Avoid dairy within 1 hour of iron-rich meals for better nutrient absorption.',
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
                                    hintText:
                                        'Add a note about today\u2019s meals\u2026',
                                    hintStyle: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted),
                                    filled: true,
                                    fillColor: AppColors.surface,
                                    contentPadding:
                                        const EdgeInsets.all(12),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AppColors.border),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AppColors.border),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: AppColors.primary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Streak & badges ─────────────────────────────
                          if (dashboard != null) ...[
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
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
                                    borderRadius:
                                        BorderRadius.circular(999),
                                    child: const LinearProgressIndicator(
                                      value: 0.8,
                                      minHeight: 6,
                                      backgroundColor: AppColors.surface,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
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
                                              color:
                                                  AppColors.textSecondary)),
                                      Text('Today',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color:
                                                  AppColors.textSecondary)),
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
                                border:
                                    Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Nutrition Badges',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 10),
                                  const Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _BadgeChip('Clean Eater',
                                          earned: true),
                                      _BadgeChip('Protein Pro',
                                          earned: true),
                                      _BadgeChip('On Target',
                                          earned: false),
                                      _BadgeChip('Hydrated',
                                          earned: false),
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
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Swap sheet helper
// ---------------------------------------------------------------------------

void _openSwapSheet(
  BuildContext context,
  TraineeNutritionCubit cubit,
  int mealId,
  NutritionIngredient ingredient,
) {
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
      onSwap: (newIngredient) {
        Navigator.pop(ctx);
        cubit.doSwap(mealId, ingredient.id, newIngredient);
      },
    ),
  );
}

// ---------------------------------------------------------------------------
// Helpers: compute effective macros for a meal
// ---------------------------------------------------------------------------

double _effectiveMealCalories(
  NutritionMealDetail meal,
  Map<int, IngredientLibraryItem> swapped,
  Set<int> skipped,
  Map<int, double> quantities,
) {
  if (meal.ingredients.isEmpty) return meal.calories;
  final anyHasMacros = meal.ingredients.any((i) => i.hasMacros);
  if (!anyHasMacros) return meal.calories;

  double total = 0;
  for (final ing in meal.ingredients) {
    if (skipped.contains(ing.id)) continue;
    final qty =
        quantities[ing.id] ?? ing.servingQuantityG;
    final swp = swapped[ing.id];
    if (swp != null) {
      total += swp.caloriesForQty(qty) ?? 0;
    } else {
      total += ing.caloriesForQty(qty);
    }
  }
  return total;
}

double _effectiveMealMacro(
  NutritionMealDetail meal,
  Map<int, IngredientLibraryItem> swapped,
  Set<int> skipped,
  Map<int, double> quantities,
  String macro, // 'protein' | 'carbs' | 'fat'
) {
  if (meal.ingredients.isEmpty) return 0;
  double total = 0;
  for (final ing in meal.ingredients) {
    if (skipped.contains(ing.id)) continue;
    final qty = quantities[ing.id] ?? ing.servingQuantityG;
    final swp = swapped[ing.id];
    if (swp != null) {
      total += switch (macro) {
        'protein' => swp.proteinForQty(qty) ?? 0,
        'carbs' => swp.carbsForQty(qty) ?? 0,
        'fat' => swp.fatForQty(qty) ?? 0,
        _ => 0.0,
      };
    } else {
      total += switch (macro) {
        'protein' => ing.proteinForQty(qty),
        'carbs' => ing.carbsForQty(qty),
        'fat' => ing.fatForQty(qty),
        _ => 0.0,
      };
    }
  }
  return total;
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
  final Map<int, double> ingredientQuantities;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final void Function(int ingredientId) onSkipIngredient;
  final void Function(NutritionIngredient ingredient) onSwapIngredient;
  final void Function(int ingredientId, double qty) onUpdateQty;

  const _MealCard({
    required this.meal,
    required this.isExpanded,
    required this.isCompleted,
    required this.isSkipped,
    required this.swappedIngredients,
    required this.skippedIngredients,
    required this.ingredientQuantities,
    required this.onTap,
    required this.onComplete,
    required this.onSkip,
    required this.onSkipIngredient,
    required this.onSwapIngredient,
    required this.onUpdateQty,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isCompleted
        ? AppColors.primary.withOpacity(0.4)
        : isSkipped
            ? AppColors.warning.withOpacity(0.4)
            : AppColors.border;

    final displayCalories = _effectiveMealCalories(
        meal, swappedIngredients, skippedIngredients, ingredientQuantities);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Collapsed header ───────────────────────────────────────────
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
                          '${meal.ingredients.length} ingredients · '
                          '${displayCalories.toStringAsFixed(0)} cal',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
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

          // ── Expanded body ──────────────────────────────────────────────
          if (isExpanded) ...[
            const Divider(color: AppColors.border, height: 1),

            // Meal-level macro summary
            if (meal.ingredients.any((i) => i.hasMacros))
              _MealMacroSummary(
                meal: meal,
                swapped: swappedIngredients,
                skipped: skippedIngredients,
                quantities: ingredientQuantities,
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      final swappedTo = swappedIngredients[ing.id];
                      final currentQty = ingredientQuantities[ing.id] ??
                          ing.servingQuantityG;
                      return _IngredientRow(
                        ingredient: ing,
                        isSkipped: isIngSkipped,
                        swappedTo: swappedTo,
                        currentQty: currentQty,
                        onSkip: () => onSkipIngredient(ing.id),
                        onSwap: () => onSwapIngredient(ing),
                        onUndoSwap: swappedTo != null
                            ? () => onSkipIngredient(ing.id)
                            : null,
                        onUpdateQty: (qty) => onUpdateQty(ing.id, qty),
                      );
                    }),

                  const SizedBox(height: 10),

                  // ── Meal action row ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(
                            isSkipped
                                ? Icons.undo
                                : Icons.block_outlined,
                            size: 14,
                          ),
                          label: Text(
                              isSkipped ? 'Undo Skip' : 'Skip Meal',
                              style: const TextStyle(fontSize: 12)),
                          onPressed: onSkip,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.warning,
                            side: BorderSide(
                                color: AppColors.warning.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
// Meal-level macro summary strip
// ---------------------------------------------------------------------------

class _MealMacroSummary extends StatelessWidget {
  final NutritionMealDetail meal;
  final Map<int, IngredientLibraryItem> swapped;
  final Set<int> skipped;
  final Map<int, double> quantities;

  const _MealMacroSummary({
    required this.meal,
    required this.swapped,
    required this.skipped,
    required this.quantities,
  });

  @override
  Widget build(BuildContext context) {
    final cal = _effectiveMealCalories(meal, swapped, skipped, quantities);
    final p = _effectiveMealMacro(meal, swapped, skipped, quantities, 'protein');
    final c = _effectiveMealMacro(meal, swapped, skipped, quantities, 'carbs');
    final f = _effectiveMealMacro(meal, swapped, skipped, quantities, 'fat');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MacroColumn(cal.toStringAsFixed(0), 'kcal',
              const Color(0xFFF97316)),
          _MacroColumn('${p.toStringAsFixed(1)}g', 'Protein',
              const Color(0xFF8B5CF6)),
          _MacroColumn('${c.toStringAsFixed(1)}g', 'Carbs',
              const Color(0xFF0EA5E9)),
          _MacroColumn('${f.toStringAsFixed(1)}g', 'Fat',
              const Color(0xFFEF4444)),
        ],
      ),
    );
  }
}

class _MacroColumn extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _MacroColumn(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ingredient row widget
// ---------------------------------------------------------------------------

class _IngredientRow extends StatelessWidget {
  final NutritionIngredient ingredient;
  final bool isSkipped;
  final IngredientLibraryItem? swappedTo;
  final double currentQty;
  final VoidCallback onSkip;
  final VoidCallback onSwap;
  final VoidCallback? onUndoSwap;
  final void Function(double qty) onUpdateQty;

  const _IngredientRow({
    required this.ingredient,
    required this.isSkipped,
    required this.swappedTo,
    required this.currentQty,
    required this.onSkip,
    required this.onSwap,
    this.onUndoSwap,
    required this.onUpdateQty,
  });

  // Effective macros considering swap + current quantity
  double get _kcal {
    if (swappedTo != null) {
      return swappedTo!.caloriesForQty(currentQty) ?? 0;
    }
    return ingredient.caloriesForQty(currentQty);
  }

  double get _protein {
    if (swappedTo != null) return swappedTo!.proteinForQty(currentQty) ?? 0;
    return ingredient.proteinForQty(currentQty);
  }

  double get _carbs {
    if (swappedTo != null) return swappedTo!.carbsForQty(currentQty) ?? 0;
    return ingredient.carbsForQty(currentQty);
  }

  double get _fat {
    if (swappedTo != null) return swappedTo!.fatForQty(currentQty) ?? 0;
    return ingredient.fatForQty(currentQty);
  }

  bool get _hasMacros =>
      swappedTo?.hasMacros == true || ingredient.hasMacros;

  @override
  Widget build(BuildContext context) {
    final displayName =
        swappedTo?.name ?? ingredient.name;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bullet dot
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: isSkipped
                      ? AppColors.warning
                      : AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              // Name + swap indicator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSkipped
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        decoration: isSkipped
                            ? TextDecoration.lineThrough
                            : null,
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
                    onTap: onSkip),
                const SizedBox(width: 6),
                _ActionBtn(
                    label: 'Swap',
                    color: AppColors.primary,
                    onTap: onSwap),
              ] else if (isSkipped)
                _ActionBtn(
                    label: 'Undo',
                    color: AppColors.textSecondary,
                    onTap: onSkip)
              else if (swappedTo != null)
                _ActionBtn(
                    label: 'Revert',
                    color: AppColors.textSecondary,
                    onTap: onUndoSwap ?? () {}),
            ],
          ),

          // ── Macro facts + quantity stepper ──────────────────────────────
          if (!isSkipped) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  // Macro chips
                  if (_hasMacros)
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          _MacroChip(
                              '${_kcal.toStringAsFixed(0)} kcal',
                              const Color(0xFFF97316)),
                          _MacroChip(
                              'P ${_protein.toStringAsFixed(1)}g',
                              const Color(0xFF8B5CF6)),
                          _MacroChip(
                              'C ${_carbs.toStringAsFixed(1)}g',
                              const Color(0xFF0EA5E9)),
                          _MacroChip('F ${_fat.toStringAsFixed(1)}g',
                              const Color(0xFFEF4444)),
                        ],
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 8),
                  // Quantity stepper
                  _QtyPill(
                    qty: currentQty,
                    onDecrement: () =>
                        onUpdateQty((currentQty - 10).clamp(10, 9999)),
                    onIncrement: () => onUpdateQty(currentQty + 10),
                    onEdit: () =>
                        _showQtyDialog(context, currentQty, onUpdateQty),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showQtyDialog(
    BuildContext context,
    double current,
    void Function(double) onSave,
  ) {
    final ctrl = TextEditingController(text: current.toStringAsFixed(0));
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Quantity',
            style: TextStyle(fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: false),
          decoration: const InputDecoration(
              suffixText: 'g', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text) ?? current;
              if (v > 0) onSave(v);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Ingredient action button ──────────────────────────────────────────────────

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

// ── Quantity pill widget ────────────────────────────────────────────────────

class _QtyPill extends StatelessWidget {
  final double qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onEdit;

  const _QtyPill({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillBtn(icon: Icons.remove, onTap: onDecrement),
          GestureDetector(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '${qty.toStringAsFixed(0)}g',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
            ),
          ),
          _PillBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PillBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 14, color: AppColors.textSecondary),
      ),
    );
  }
}

// ── Macro chip ────────────────────────────────────────────────────────────────

class _MacroChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MacroChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color)),
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
      final results = await di
          .sl<TraineeAppRepository>()
          .searchIngredients(query.trim());
      if (mounted) {
        setState(() {
          _results = results;
          _searching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchError = e.toString().replaceFirst('Exception: ', '');
          _searching = false;
        });
      }
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
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.textMuted, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                style:
                    const TextStyle(color: AppColors.error, fontSize: 12),
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
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _results.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (ctx, i) {
                  final item = _results[i];
                  return _SwapResultTile(
                    item: item,
                    onSelect: () => widget.onSwap(item),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SwapResultTile extends StatelessWidget {
  final IngredientLibraryItem item;
  final VoidCallback onSelect;
  const _SwapResultTile({required this.item, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final serving = item.servingQuantityG ?? 100;
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
      subtitle: item.hasMacros
          ? Wrap(
              spacing: 4,
              children: [
                if (item.calories != null)
                  _MiniChip(
                      '${item.calories!.toStringAsFixed(0)} kcal',
                      const Color(0xFFF97316)),
                if (item.protein != null)
                  _MiniChip('P ${item.protein!.toStringAsFixed(1)}g',
                      const Color(0xFF8B5CF6)),
                if (item.carbs != null)
                  _MiniChip('C ${item.carbs!.toStringAsFixed(1)}g',
                      const Color(0xFF0EA5E9)),
                if (item.fat != null)
                  _MiniChip(
                      'F ${item.fat!.toStringAsFixed(1)}g',
                      const Color(0xFFEF4444)),
              ],
            )
          : null,
      isThreeLine: item.hasMacros,
      trailing: GestureDetector(
        onTap: onSelect,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Select · per ${serving.toStringAsFixed(0)}g',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ---------------------------------------------------------------------------
// Extra meal card widget
// ---------------------------------------------------------------------------

class _ExtraMealCard extends StatelessWidget {
  final ExtraMealLog meal;
  final bool isCompleted;
  final VoidCallback? onComplete;

  const _ExtraMealCard({
    required this.meal,
    required this.isCompleted,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isCompleted
        ? AppColors.primary.withOpacity(0.4)
        : AppColors.border;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.successLight
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add_circle_outline,
                size: 20,
                color: isCompleted
                    ? AppColors.success
                    : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          meal.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Extra',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${meal.calories.toStringAsFixed(0)} cal',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
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
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _TodayWaterIntakeBlock extends StatefulWidget {
  final double litersLogged;
  final double targetLiters;
  final bool busy;
  final DateTime? serverUpdatedAt;
  final void Function(double liters) onSave;

  const _TodayWaterIntakeBlock({
    required this.litersLogged,
    required this.targetLiters,
    required this.busy,
    this.serverUpdatedAt,
    required this.onSave,
  });

  @override
  State<_TodayWaterIntakeBlock> createState() => _TodayWaterIntakeBlockState();
}

class _TodayWaterIntakeBlockState extends State<_TodayWaterIntakeBlock> {
  late TextEditingController _controller;
  String _lastServerSig = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatLiters(widget.litersLogged));
    _lastServerSig = _serverSig;
  }

  @override
  void didUpdateWidget(covariant _TodayWaterIntakeBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_serverSig != _lastServerSig && !widget.busy) {
      _controller.text = _formatLiters(widget.litersLogged);
      _lastServerSig = _serverSig;
    }
  }

  String get _serverSig =>
      '${widget.litersLogged}_${widget.serverUpdatedAt?.millisecondsSinceEpoch}';

  String _formatLiters(double v) {
    if (v == 0) return '0';
    var s = v.toStringAsFixed(2);
    if (s.endsWith('00')) s = s.substring(0, s.length - 3);
    return s;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) {
      widget.onSave(0);
      return;
    }
    final v = double.tryParse(raw);
    if (v == null) return;
    widget.onSave(v);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.targetLiters > 0
        ? (widget.litersLogged / widget.targetLiters).clamp(0.0, 1.0)
        : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.water_drop,
              size: 22,
              color: Color(0xFF0EA5E9),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Water today (liters)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              'Goal ${widget.targetLiters.toStringAsFixed(1)} L',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter the total you drank today (replaces any earlier value for this day).',
          style: TextStyle(
            fontSize: 12,
            height: 1.35,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: p,
            minHeight: 6,
            backgroundColor: AppColors.surface,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          enabled: !widget.busy,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Total liters for today',
            hintText: '0',
            filled: true,
            fillColor: AppColors.background,
            suffixText: 'L',
            suffixStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.busy ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: widget.busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save water',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        if (widget.serverUpdatedAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Last saved: ${DateFormat('MMM d, y · HH:mm').format(widget.serverUpdatedAt!.toLocal())}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}

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
