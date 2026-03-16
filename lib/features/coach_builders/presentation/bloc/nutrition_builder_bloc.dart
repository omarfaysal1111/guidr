import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/features/coach_builders/data/repositories/builder_repository.dart';
import 'package:guidr/features/trainees/domain/repositories/trainees_repository.dart';
import 'nutrition_builder_event.dart';
import 'nutrition_builder_state.dart';

class NutritionBuilderBloc
    extends Bloc<NutritionBuilderEvent, NutritionBuilderState> {
  final BuildersRepository buildersRepository;
  final TraineesRepository traineesRepository;

  NutritionBuilderBloc({
    required this.buildersRepository,
    required this.traineesRepository,
  }) : super(NutritionBuilderState.initial()) {
    on<NutritionBuilderInit>(_onInit);
    on<NutritionSetStep>(
        (e, emit) => emit(state.copyWith(currentStep: e.step)));
    on<NutritionFilterTrainees>(_onFilter);
    on<NutritionToggleTrainee>(_onToggle);
    on<NutritionSelectAllTrainees>(_onSelectAll);
    on<NutritionUpdateMetadata>(_onUpdateMeta);
    on<NutritionToggleMealSection>(_onToggleSection);
    on<NutritionAddMealItem>(_onAddItem);
    on<NutritionRemoveMealItem>(_onRemoveItem);
    on<NutritionLoadIngredientLibrary>(_onLoadLibrary);
    on<NutritionApplyTemplate>(_onApplyTemplate);
    on<NutritionUpdateSchedule>(_onUpdateSchedule);
    on<NutritionAssignPlan>(_onAssign);
    on<NutritionSaveTemplate>(_onSaveTemplate);
    on<NutritionSaveDraft>(_onSaveDraft);
  }

  List<String> _listFor(MealSection s) => state.mealsFor(s);

  void _emitMeals(
      MealSection s, List<String> list, Emitter<NutritionBuilderState> emit) {
    emit(switch (s) {
      MealSection.breakfast => state.copyWith(breakfast: list),
      MealSection.lunch => state.copyWith(lunch: list),
      MealSection.dinner => state.copyWith(dinner: list),
      MealSection.snacks => state.copyWith(snacks: list),
    });
  }

  Future<void> _onInit(
      NutritionBuilderInit event, Emitter<NutritionBuilderState> emit) async {
    emit(state.copyWith(traineesLoading: true, clearError: true));
    try {
      final trainees = await traineesRepository.getMyTrainees();
      final active = trainees.where((t) => t.status == 'active').toList();
      emit(state.copyWith(
          traineesLoading: false,
          allTrainees: active,
          filteredTrainees: active));
    } catch (e) {
      emit(state.copyWith(traineesLoading: false, error: e.toString()));
    }
  }

  void _onFilter(
      NutritionFilterTrainees event, Emitter<NutritionBuilderState> emit) {
    final q = event.query.trim().toLowerCase();
    final list = q.isEmpty
        ? state.allTrainees
        : state.allTrainees
            .where((t) => [t.name, t.email, t.goal]
                .any((f) => f.toLowerCase().contains(q)))
            .toList();
    emit(state.copyWith(filteredTrainees: list));
  }

  void _onToggle(
      NutritionToggleTrainee event, Emitter<NutritionBuilderState> emit) {
    final ids = Set<int>.from(state.selectedTraineeIds);
    ids.contains(event.traineeId)
        ? ids.remove(event.traineeId)
        : ids.add(event.traineeId);
    emit(state.copyWith(selectedTraineeIds: ids));
  }

  void _onSelectAll(
      NutritionSelectAllTrainees event, Emitter<NutritionBuilderState> emit) {
    final allIds = state.filteredTrainees.map((t) => t.id).toSet();
    emit(state.copyWith(
        selectedTraineeIds:
            state.selectedTraineeIds.length == allIds.length ? {} : allIds));
  }

  void _onUpdateMeta(
      NutritionUpdateMetadata event, Emitter<NutritionBuilderState> emit) {
    emit(state.copyWith(planName: event.planName));
  }

  void _onToggleSection(NutritionToggleMealSection event,
      Emitter<NutritionBuilderState> emit) {
    emit(switch (event.section) {
      MealSection.breakfast =>
        state.copyWith(breakfastExpanded: !state.breakfastExpanded),
      MealSection.lunch =>
        state.copyWith(lunchExpanded: !state.lunchExpanded),
      MealSection.dinner =>
        state.copyWith(dinnerExpanded: !state.dinnerExpanded),
      MealSection.snacks =>
        state.copyWith(snacksExpanded: !state.snacksExpanded),
    });
  }

  void _onAddItem(
      NutritionAddMealItem event, Emitter<NutritionBuilderState> emit) {
    final list = List<String>.from(_listFor(event.section));
    final name = event.libraryIngredient?.name ?? event.customName ?? '';
    if (name.isNotEmpty) {
      _emitMeals(event.section, [...list, name], emit);
    }
  }

  void _onRemoveItem(
      NutritionRemoveMealItem event, Emitter<NutritionBuilderState> emit) {
    final list = List<String>.from(_listFor(event.section));
    if (event.index >= 0 && event.index < list.length) {
      list.removeAt(event.index);
      _emitMeals(event.section, list, emit);
    }
  }

  Future<void> _onLoadLibrary(NutritionLoadIngredientLibrary event,
      Emitter<NutritionBuilderState> emit) async {
    if (state.ingredientLibrary.isNotEmpty) return;
    emit(state.copyWith(libraryLoading: true));
    try {
      final ingredients = await buildersRepository.getIngredients();
      emit(state.copyWith(
          libraryLoading: false, ingredientLibrary: ingredients));
    } catch (e) {
      emit(state.copyWith(libraryLoading: false, error: e.toString()));
    }
  }

  void _onApplyTemplate(
      NutritionApplyTemplate event, Emitter<NutritionBuilderState> emit) {
    final templates = <String, Map<String, List<String>>>{
      '1': {
        'breakfast': ['Eggs & spinach', 'Greek yogurt'],
        'lunch': ['Grilled chicken salad', 'Brown rice'],
        'dinner': ['Salmon with vegetables', 'Cottage cheese'],
        'snacks': ['Protein shake', 'Almonds'],
      },
      '2': {
        'breakfast': ['Avocado eggs', 'Bulletproof coffee'],
        'lunch': ['Grilled salmon', 'Leafy green salad'],
        'dinner': ['Chicken stir-fry', 'Broccoli'],
        'snacks': ['Cheese', 'Macadamia nuts'],
      },
      '3': {
        'breakfast': ['Oatmeal with berries', 'Whole grain toast'],
        'lunch': ['Turkey wrap', 'Mixed vegetables'],
        'dinner': ['Grilled fish', 'Quinoa', 'Steamed veggies'],
        'snacks': ['Apple', 'Hummus with carrots'],
      },
    };
    final t = templates[event.templateId];
    if (t != null) {
      emit(state.copyWith(
        breakfast: t['breakfast'] ?? [],
        lunch: t['lunch'] ?? [],
        dinner: t['dinner'] ?? [],
        snacks: t['snacks'] ?? [],
        currentStep: 3,
      ));
    }
  }

  void _onUpdateSchedule(
      NutritionUpdateSchedule event, Emitter<NutritionBuilderState> emit) {
    emit(state.copyWith(
      selectedDate: event.selectedDate,
      selectedTime: event.selectedTime,
      recurrence: event.recurrence,
      remindTrainee: event.remindTrainee,
      alertIfMissed: event.alertIfMissed,
    ));
  }

  Future<void> _onAssign(
      NutritionAssignPlan event, Emitter<NutritionBuilderState> emit) async {
    if (state.selectedTraineeIds.isEmpty) return;
    emit(state.copyWith(saving: true, clearError: true));
    try {
      final meals = <Map<String, dynamic>>[];
      void addSection(String name, List<String> items) {
        if (items.isNotEmpty) {
          meals.add({
            'name': name,
            'ingredientIds': <int>[],
            'customCalories': items.length * 400.0,
          });
        }
      }

      addSection('Breakfast', state.breakfast);
      addSection('Lunch', state.lunch);
      addSection('Dinner', state.dinner);
      addSection('Snacks', state.snacks);

      await buildersRepository.createNutritionPlan({
        'title':
            state.planName.isEmpty ? 'Untitled plan' : state.planName,
        'description': 'Created from Nutrition Plan Builder',
        'traineeIds': state.selectedTraineeIds.toList(),
        'meals': meals,
      });
      emit(state.copyWith(saving: false, assignSuccess: true));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  Map<String, dynamic> _buildPayload() {
    final meals = <Map<String, dynamic>>[];
    void addSection(String name, List<String> items) {
      if (items.isNotEmpty) {
        meals.add({
          'name': name,
          'ingredientIds': <int>[],
          'customCalories': items.length * 400.0,
        });
      }
    }

    addSection('Breakfast', state.breakfast);
    addSection('Lunch', state.lunch);
    addSection('Dinner', state.dinner);
    addSection('Snacks', state.snacks);

    final payload = <String, dynamic>{
      'title': state.planName.isEmpty ? 'Untitled plan' : state.planName,
      'description': 'Created from Nutrition Plan Builder',
      'meals': meals,
    };
    return payload;
  }

  Future<void> _onSaveTemplate(NutritionSaveTemplate event,
      Emitter<NutritionBuilderState> emit) async {
    emit(state.copyWith(saving: true, clearError: true));
    try {
      await buildersRepository.saveNutritionPlanTemplate(_buildPayload());
      emit(state.copyWith(saving: false, templateSaved: true));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  Future<void> _onSaveDraft(
      NutritionSaveDraft event, Emitter<NutritionBuilderState> emit) async {
    emit(state.copyWith(saving: true, clearError: true));
    try {
      await buildersRepository.saveNutritionPlanDraft(_buildPayload());
      emit(state.copyWith(saving: false, draftSaved: true));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }
}
