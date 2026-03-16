import 'package:guidr/features/coach_builders/domain/entities/ingredient.dart';
import 'package:guidr/features/trainees/domain/entities/trainee.dart';

enum MealSection { breakfast, lunch, dinner, snacks }

class NutritionBuilderState {
  final int currentStep;
  final bool traineesLoading;
  final bool saving;
  final bool assignSuccess;
  final bool templateSaved;
  final bool draftSaved;
  final String? error;

  // Trainee data
  final List<Trainee> allTrainees;
  final List<Trainee> filteredTrainees;
  final Set<int> selectedTraineeIds;

  // Plan metadata
  final String planName;

  // Meal content
  final List<String> breakfast;
  final List<String> lunch;
  final List<String> dinner;
  final List<String> snacks;

  // UI expansion state
  final bool breakfastExpanded;
  final bool lunchExpanded;
  final bool dinnerExpanded;
  final bool snacksExpanded;

  // Ingredient library
  final List<Ingredient> ingredientLibrary;
  final bool libraryLoading;

  // Schedule
  final DateTime? selectedDate;
  final String selectedTime;
  final String recurrence;
  final bool remindTrainee;
  final bool alertIfMissed;

  const NutritionBuilderState({
    required this.currentStep,
    required this.allTrainees,
    required this.filteredTrainees,
    required this.selectedTraineeIds,
    required this.traineesLoading,
    required this.saving,
    required this.assignSuccess,
    required this.templateSaved,
    required this.draftSaved,
    required this.planName,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
    required this.breakfastExpanded,
    required this.lunchExpanded,
    required this.dinnerExpanded,
    required this.snacksExpanded,
    required this.ingredientLibrary,
    required this.libraryLoading,
    required this.selectedDate,
    required this.selectedTime,
    required this.recurrence,
    required this.remindTrainee,
    required this.alertIfMissed,
    this.error,
  });

  factory NutritionBuilderState.initial() => NutritionBuilderState(
        currentStep: 1,
        allTrainees: const [],
        filteredTrainees: const [],
        selectedTraineeIds: const {},
        traineesLoading: true,
        saving: false,
        assignSuccess: false,
        templateSaved: false,
        draftSaved: false,
        planName: '',
        breakfast: const [],
        lunch: const [],
        dinner: const [],
        snacks: const [],
        breakfastExpanded: true,
        lunchExpanded: false,
        dinnerExpanded: false,
        snacksExpanded: true,
        ingredientLibrary: const [],
        libraryLoading: false,
        selectedDate: DateTime.now().add(const Duration(days: 7)),
        selectedTime: '09:00',
        recurrence: 'One-time',
        remindTrainee: true,
        alertIfMissed: true,
        error: null,
      );

  int get totalMeals =>
      breakfast.length + lunch.length + dinner.length + snacks.length;

  int get estimatedKcal => totalMeals * 400;

  List<String> mealsFor(MealSection s) => switch (s) {
        MealSection.breakfast => breakfast,
        MealSection.lunch => lunch,
        MealSection.dinner => dinner,
        MealSection.snacks => snacks,
      };

  NutritionBuilderState copyWith({
    int? currentStep,
    List<Trainee>? allTrainees,
    List<Trainee>? filteredTrainees,
    Set<int>? selectedTraineeIds,
    bool? traineesLoading,
    bool? saving,
    bool? assignSuccess,
    bool? templateSaved,
    bool? draftSaved,
    String? planName,
    List<String>? breakfast,
    List<String>? lunch,
    List<String>? dinner,
    List<String>? snacks,
    bool? breakfastExpanded,
    bool? lunchExpanded,
    bool? dinnerExpanded,
    bool? snacksExpanded,
    List<Ingredient>? ingredientLibrary,
    bool? libraryLoading,
    DateTime? selectedDate,
    String? selectedTime,
    String? recurrence,
    bool? remindTrainee,
    bool? alertIfMissed,
    String? error,
    bool clearError = false,
  }) {
    return NutritionBuilderState(
      currentStep: currentStep ?? this.currentStep,
      allTrainees: allTrainees ?? this.allTrainees,
      filteredTrainees: filteredTrainees ?? this.filteredTrainees,
      selectedTraineeIds: selectedTraineeIds ?? this.selectedTraineeIds,
      traineesLoading: traineesLoading ?? this.traineesLoading,
      saving: saving ?? this.saving,
      assignSuccess: assignSuccess ?? this.assignSuccess,
      templateSaved: templateSaved ?? this.templateSaved,
      draftSaved: draftSaved ?? this.draftSaved,
      planName: planName ?? this.planName,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      dinner: dinner ?? this.dinner,
      snacks: snacks ?? this.snacks,
      breakfastExpanded: breakfastExpanded ?? this.breakfastExpanded,
      lunchExpanded: lunchExpanded ?? this.lunchExpanded,
      dinnerExpanded: dinnerExpanded ?? this.dinnerExpanded,
      snacksExpanded: snacksExpanded ?? this.snacksExpanded,
      ingredientLibrary: ingredientLibrary ?? this.ingredientLibrary,
      libraryLoading: libraryLoading ?? this.libraryLoading,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      recurrence: recurrence ?? this.recurrence,
      remindTrainee: remindTrainee ?? this.remindTrainee,
      alertIfMissed: alertIfMissed ?? this.alertIfMissed,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
