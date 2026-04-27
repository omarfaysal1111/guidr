import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/features/trainee_app/domain/entities/extra_meal_log.dart';
import 'package:guidr/features/trainee_app/domain/entities/ingredient_library_item.dart';
import 'package:guidr/features/trainee_app/domain/entities/meal_completion_request.dart';
import 'package:guidr/features/trainee_app/domain/entities/nutrition_plan_detail.dart';
import 'package:guidr/features/trainee_app/domain/entities/trainee_dashboard_today.dart';
import 'package:guidr/features/trainee_app/domain/entities/water_intake_day.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';

class TraineeNutritionState extends Equatable {
  final bool loading;
  final String? error;
  final TraineeDashboardToday? dashboard;
  final List<NutritionPlanDetail> plans;
  final Set<int> completedMeals;
  final Set<int> skippedMeals;
  final Map<int, Map<int, IngredientLibraryItem>> swappedIngredients;
  final Map<int, Set<int>> skippedIngredients;

  /// mealId → ingredientId → custom quantity override in grams
  final Map<int, Map<int, double>> ingredientQuantities;

  final int? expandedMealIndex;
  final String? toastMessage;
  final bool? toastSuccess;

  /// Extra meals added by the trainee during this session (optimistic).
  final List<ExtraMealLog> extraMeals;

  /// IDs of extra meals the trainee has marked as completed.
  final Set<int> completedExtraMeals;

  final WaterIntakeDay? waterIntake;
  final bool savingWater;

  const TraineeNutritionState({
    required this.loading,
    required this.plans,
    required this.completedMeals,
    required this.skippedMeals,
    required this.swappedIngredients,
    required this.skippedIngredients,
    required this.ingredientQuantities,
    required this.extraMeals,
    required this.completedExtraMeals,
    this.error,
    this.dashboard,
    this.expandedMealIndex,
    this.toastMessage,
    this.toastSuccess,
    this.waterIntake,
    this.savingWater = false,
  });

  factory TraineeNutritionState.initial() => const TraineeNutritionState(
        loading: true,
        plans: [],
        completedMeals: {},
        skippedMeals: {},
        swappedIngredients: {},
        skippedIngredients: {},
        ingredientQuantities: {},
        extraMeals: [],
        completedExtraMeals: {},
        waterIntake: null,
        savingWater: false,
      );

  TraineeNutritionState copyWith({
    bool? loading,
    String? error,
    TraineeDashboardToday? dashboard,
    List<NutritionPlanDetail>? plans,
    Set<int>? completedMeals,
    Set<int>? skippedMeals,
    Map<int, Map<int, IngredientLibraryItem>>? swappedIngredients,
    Map<int, Set<int>>? skippedIngredients,
    Map<int, Map<int, double>>? ingredientQuantities,
    int? expandedMealIndex,
    String? toastMessage,
    bool? toastSuccess,
    List<ExtraMealLog>? extraMeals,
    Set<int>? completedExtraMeals,
    bool clearError = false,
    bool clearToast = false,
    bool clearExpandedMealIndex = false,
    WaterIntakeDay? waterIntake,
    bool? savingWater,
  }) {
    return TraineeNutritionState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      dashboard: dashboard ?? this.dashboard,
      plans: plans ?? this.plans,
      completedMeals: completedMeals ?? this.completedMeals,
      skippedMeals: skippedMeals ?? this.skippedMeals,
      swappedIngredients: swappedIngredients ?? this.swappedIngredients,
      skippedIngredients: skippedIngredients ?? this.skippedIngredients,
      ingredientQuantities: ingredientQuantities ?? this.ingredientQuantities,
      expandedMealIndex:
          clearExpandedMealIndex ? null : (expandedMealIndex ?? this.expandedMealIndex),
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
      toastSuccess: clearToast ? null : (toastSuccess ?? this.toastSuccess),
      extraMeals: extraMeals ?? this.extraMeals,
      completedExtraMeals: completedExtraMeals ?? this.completedExtraMeals,
      waterIntake: waterIntake ?? this.waterIntake,
      savingWater: savingWater ?? this.savingWater,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        error,
        dashboard,
        plans,
        completedMeals,
        skippedMeals,
        swappedIngredients,
        skippedIngredients,
        ingredientQuantities,
        expandedMealIndex,
        toastMessage,
        toastSuccess,
        extraMeals,
        completedExtraMeals,
        waterIntake,
        savingWater,
      ];
}

class TraineeNutritionCubit extends Cubit<TraineeNutritionState> {
  final TraineeAppRepository repository;

  TraineeNutritionCubit({required this.repository})
      : super(TraineeNutritionState.initial());

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final results = await Future.wait([
        repository.getDashboardToday(),
        repository.getMyNutritionPlanDetails(),
      ]);
      final dashboard = results[0] as TraineeDashboardToday;
      final plans = results[1] as List<NutritionPlanDetail>;

      WaterIntakeDay water;
      try {
        water = await repository.getMyWaterIntake();
      } catch (_) {
        water = WaterIntakeDay.emptyForDate(DateTime.now());
      }

      final completedMeals = Set<int>.from(state.completedMeals);
      if (dashboard.todayNutritionSummary.caloriesConsumed > 0) {
        for (final m in dashboard.todayNutritionSummary.meals) {
          if (m.completed) completedMeals.add(m.id);
        }
      }

      emit(state.copyWith(
        loading: false,
        dashboard: dashboard,
        plans: plans,
        completedMeals: completedMeals,
        waterIntake: water,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  /// Sets the **total** liters for [day] (replaces any previous value for that date).
  Future<void> setTotalWaterLitersForDay(double liters, DateTime day) async {
    if (liters < 0 || liters > 50) {
      emit(state.copyWith(
        toastMessage: 'Enter a realistic amount (0–50 L).',
        toastSuccess: false,
      ));
      return;
    }
    final dateIso = WaterIntakeDay.formatDate(
      DateTime(day.year, day.month, day.day),
    );
    emit(state.copyWith(savingWater: true, clearToast: true));
    try {
      final updated = await repository.setMyWaterIntake(
        liters: liters,
        dateIso: dateIso,
      );
      emit(state.copyWith(
        waterIntake: updated,
        savingWater: false,
        toastMessage: 'Water log updated',
        toastSuccess: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        savingWater: false,
        toastMessage: e.toString().replaceFirst('Exception: ', ''),
        toastSuccess: false,
      ));
    }
  }

  Future<void> completeMeal(int mealId) async {
    final wasCompleted = state.completedMeals.contains(mealId);

    final skippedIngForMeal =
        Set<int>.from(state.skippedIngredients[mealId] ?? {});
    final swappedIngForMeal = Map<int, IngredientLibraryItem>.from(
        state.swappedIngredients[mealId] ?? {});

    final newCompleted = Set<int>.from(state.completedMeals);
    final newSkipped = Set<int>.from(state.skippedMeals);
    if (wasCompleted) {
      newCompleted.remove(mealId);
    } else {
      newCompleted.add(mealId);
      newSkipped.remove(mealId);
    }
    emit(state.copyWith(completedMeals: newCompleted, skippedMeals: newSkipped));

    try {
      final request = MealCompletionRequest(
        skipMeal: false,
        skippedIngredientIds: skippedIngForMeal.toList(),
        replacedIngredients: swappedIngForMeal.entries
            .map((e) => IngredientSwapRequest(
                  originalIngredientId: e.key,
                  newIngredientId: e.value.id,
                ))
            .toList(),
      );
      await repository.completeMeal(mealId, request);
      emit(state.copyWith(
        toastMessage: wasCompleted ? 'Meal unmarked' : 'Meal completed!',
        toastSuccess: true,
      ));
    } catch (e) {
      final revertCompleted = Set<int>.from(state.completedMeals);
      final revertSkipped = Set<int>.from(state.skippedMeals);
      if (wasCompleted) {
        revertCompleted.add(mealId);
      } else {
        revertCompleted.remove(mealId);
      }
      emit(state.copyWith(
        completedMeals: revertCompleted,
        skippedMeals: revertSkipped,
        toastMessage: e.toString().replaceFirst('Exception: ', ''),
        toastSuccess: false,
      ));
    }
  }

  Future<void> skipMeal(int mealId) async {
    final wasSkipped = state.skippedMeals.contains(mealId);

    final newSkipped = Set<int>.from(state.skippedMeals);
    final newCompleted = Set<int>.from(state.completedMeals);
    if (wasSkipped) {
      newSkipped.remove(mealId);
    } else {
      newSkipped.add(mealId);
      newCompleted.remove(mealId);
    }
    emit(state.copyWith(skippedMeals: newSkipped, completedMeals: newCompleted));

    try {
      final request = MealCompletionRequest(skipMeal: !wasSkipped);
      await repository.completeMeal(mealId, request);
      emit(state.copyWith(
        toastMessage: wasSkipped ? 'Meal unskipped' : 'Meal skipped',
        toastSuccess: true,
      ));
    } catch (e) {
      final revertSkipped = Set<int>.from(state.skippedMeals);
      final revertCompleted = Set<int>.from(state.completedMeals);
      if (wasSkipped) {
        revertSkipped.add(mealId);
      } else {
        revertSkipped.remove(mealId);
      }
      emit(state.copyWith(
        skippedMeals: revertSkipped,
        completedMeals: revertCompleted,
        toastMessage: e.toString().replaceFirst('Exception: ', ''),
        toastSuccess: false,
      ));
    }
  }

  void skipIngredient(int mealId, int ingredientId) {
    final currentSkippedIng =
        Map<int, Set<int>>.from(state.skippedIngredients);
    final currentSet = Set<int>.from(currentSkippedIng[mealId] ?? {});

    if (currentSet.contains(ingredientId)) {
      currentSet.remove(ingredientId);
      currentSkippedIng[mealId] = currentSet;
      emit(state.copyWith(skippedIngredients: currentSkippedIng));
    } else {
      currentSet.add(ingredientId);
      currentSkippedIng[mealId] = currentSet;

      final currentSwapped = Map<int, Map<int, IngredientLibraryItem>>.from(
          state.swappedIngredients);
      if (currentSwapped.containsKey(mealId)) {
        final mealSwaps =
            Map<int, IngredientLibraryItem>.from(currentSwapped[mealId]!);
        mealSwaps.remove(ingredientId);
        currentSwapped[mealId] = mealSwaps;
      }

      emit(state.copyWith(
        skippedIngredients: currentSkippedIng,
        swappedIngredients: currentSwapped,
      ));
    }
  }

  void doSwap(
      int mealId, int ingredientId, IngredientLibraryItem newIngredient) {
    final currentSwapped = Map<int, Map<int, IngredientLibraryItem>>.from(
        state.swappedIngredients);
    final mealSwaps =
        Map<int, IngredientLibraryItem>.from(currentSwapped[mealId] ?? {});
    mealSwaps[ingredientId] = newIngredient;
    currentSwapped[mealId] = mealSwaps;

    final currentSkippedIng =
        Map<int, Set<int>>.from(state.skippedIngredients);
    if (currentSkippedIng.containsKey(mealId)) {
      final mealSkipped = Set<int>.from(currentSkippedIng[mealId]!);
      mealSkipped.remove(ingredientId);
      currentSkippedIng[mealId] = mealSkipped;
    }

    emit(state.copyWith(
      swappedIngredients: currentSwapped,
      skippedIngredients: currentSkippedIng,
    ));
  }

  /// Updates the quantity override for a specific ingredient in a meal.
  /// Pass [qty] ≤ 0 to reset to the ingredient's default serving quantity.
  void updateIngredientQuantity(int mealId, int ingredientId, double qty) {
    final current =
        Map<int, Map<int, double>>.from(state.ingredientQuantities);
    final mealQtys = Map<int, double>.from(current[mealId] ?? {});
    if (qty <= 0) {
      mealQtys.remove(ingredientId);
    } else {
      mealQtys[ingredientId] = qty;
    }
    current[mealId] = mealQtys;
    emit(state.copyWith(ingredientQuantities: current));
  }

  void toggleExpandedMeal(int index) {
    if (state.expandedMealIndex == index) {
      emit(state.copyWith(clearExpandedMealIndex: true));
    } else {
      emit(state.copyWith(expandedMealIndex: index));
    }
  }

  /// Immediately adds an extra meal to the local list after the trainee logs it.
  void addExtraMealLocally(ExtraMealLog meal) {
    final updated = List<ExtraMealLog>.from(state.extraMeals)..add(meal);
    emit(state.copyWith(extraMeals: updated));
  }

  /// Toggles the completion state of a locally-tracked extra meal.
  void toggleExtraMealComplete(int extraMealId) {
    final current = Set<int>.from(state.completedExtraMeals);
    if (current.contains(extraMealId)) {
      current.remove(extraMealId);
    } else {
      current.add(extraMealId);
    }
    emit(state.copyWith(completedExtraMeals: current));
  }
}
