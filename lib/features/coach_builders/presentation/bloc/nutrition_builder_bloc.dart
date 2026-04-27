import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/features/coach_builders/data/local/plan_builder_local_storage.dart';
import 'package:guidr/features/coach_builders/data/repositories/builder_repository.dart';
import 'package:guidr/features/coach_builders/domain/entities/ingredient.dart';
import 'package:guidr/features/trainees/domain/repositories/trainees_repository.dart';
import 'nutrition_builder_event.dart';
import 'nutrition_builder_state.dart';

class NutritionBuilderBloc
    extends Bloc<NutritionBuilderEvent, NutritionBuilderState> {
  final BuildersRepository buildersRepository;
  final TraineesRepository traineesRepository;
  final PlanBuilderLocalStorage planBuilderLocalStorage;

  NutritionBuilderBloc({
    required this.buildersRepository,
    required this.traineesRepository,
    required this.planBuilderLocalStorage,
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
    on<NutritionUpdateMealItemQty>(_onUpdateItemQty);
    on<NutritionLoadIngredientLibrary>(_onLoadLibrary);
    on<NutritionApplyTemplate>(_onApplyTemplate);
    on<NutritionUpdateSchedule>(_onUpdateSchedule);
    on<NutritionAssignPlan>(_onAssign);
    on<NutritionSaveTemplate>(_onSaveTemplate);
    on<NutritionSaveDraft>(_onSaveDraft);
    on<RestoreNutritionDraftFromLocal>(_onRestoreDraft);
    on<RestoreNutritionTemplateFromLocal>(_onRestoreTemplate);
  }

  List<MealIngredientEntry> _listFor(MealSection s) => state.mealsFor(s);

  void _emitMeals(MealSection s, List<MealIngredientEntry> list,
      Emitter<NutritionBuilderState> emit) {
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
    final list = List<MealIngredientEntry>.from(_listFor(event.section));
    MealIngredientEntry? entry;

    if (event.libraryIngredient != null) {
      final qty = event.quantityG > 0
          ? event.quantityG
          : event.libraryIngredient!.servingQuantityG;
      entry = MealIngredientEntry.fromLibrary(event.libraryIngredient!, qty);
    } else if (event.customName?.isNotEmpty == true) {
      entry = MealIngredientEntry.custom(event.customName!);
    }

    if (entry != null) {
      _emitMeals(event.section, [...list, entry], emit);
    }
  }

  void _onRemoveItem(
      NutritionRemoveMealItem event, Emitter<NutritionBuilderState> emit) {
    final list = List<MealIngredientEntry>.from(_listFor(event.section));
    if (event.index >= 0 && event.index < list.length) {
      list.removeAt(event.index);
      _emitMeals(event.section, list, emit);
    }
  }

  void _onUpdateItemQty(
      NutritionUpdateMealItemQty event, Emitter<NutritionBuilderState> emit) {
    if (event.quantityG <= 0) return;
    final list = List<MealIngredientEntry>.from(_listFor(event.section));
    if (event.index >= 0 && event.index < list.length) {
      list[event.index] = list[event.index].copyWithQty(event.quantityG);
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
    // Templates now produce custom (no-macro) entries as placeholders
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
        breakfast:
            t['breakfast']!.map(MealIngredientEntry.custom).toList(),
        lunch: t['lunch']!.map(MealIngredientEntry.custom).toList(),
        dinner: t['dinner']!.map(MealIngredientEntry.custom).toList(),
        snacks: t['snacks']!.map(MealIngredientEntry.custom).toList(),
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
      await buildersRepository.createNutritionPlan({
        'title': state.planName.isEmpty ? 'Untitled plan' : state.planName,
        'description': 'Created from Nutrition Plan Builder',
        'traineeIds': state.selectedTraineeIds.toList(),
        'meals': _buildMealsPayload(),
      });
      emit(state.copyWith(saving: false, assignSuccess: true));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  List<Map<String, dynamic>> _buildMealsPayload() {
    final meals = <Map<String, dynamic>>[];

    void addSection(String name, List<MealIngredientEntry> items) {
      if (items.isEmpty) return;
      final libItems = items.where((e) => e.isFromLibrary).toList();
      meals.add({
        'name': name,
        'ingredientIds':
            libItems.map((e) => e.ingredient!.id).toList(),
        'customCalories': items.fold<double>(0, (s, e) => s + e.calories),
      });
    }

    addSection('Breakfast', state.breakfast);
    addSection('Lunch', state.lunch);
    addSection('Dinner', state.dinner);
    addSection('Snacks', state.snacks);
    return meals;
  }

  List<Map<String, dynamic>> _serializeMealEntries(
      List<MealIngredientEntry> items) {
    return items.map((e) {
      if (e.ingredient != null) {
        final i = e.ingredient!;
        return {
          'fromLibrary': true,
          'ingredient': {
            'id': i.id,
            'name': i.name,
            'servingQuantityG': i.servingQuantityG,
            'calories': i.calories,
            'fat': i.fat,
            'carbohydrates': i.carbohydrates,
            'protein': i.protein,
            'water': i.water,
            'totalMinerals': i.totalMinerals,
          },
          'name': e.name,
          'quantityG': e.quantityG,
        };
      }
      return {
        'fromLibrary': false,
        'name': e.name,
        'quantityG': e.quantityG,
      };
    }).toList();
  }

  MealIngredientEntry _mealEntryFromMap(Map<String, dynamic> m) {
    if (m['fromLibrary'] == true && m['ingredient'] is Map) {
      final ing = Ingredient.fromJson(
        Map<String, dynamic>.from(m['ingredient'] as Map),
      );
      return MealIngredientEntry.fromLibrary(
        ing,
        (m['quantityG'] as num).toDouble(),
      );
    }
    final name = m['name'] as String? ?? '';
    return MealIngredientEntry(
      name: name,
      quantityG: (m['quantityG'] as num?)?.toDouble() ?? 0,
    );
  }

  List<MealIngredientEntry> _mealEntriesFromList(Object? list) {
    if (list is! List) return [];
    return list
        .map((e) {
          if (e is! Map) return null;
          return _mealEntryFromMap(Map<String, dynamic>.from(e));
        })
        .whereType<MealIngredientEntry>()
        .toList();
  }

  Map<String, dynamic> _nutritionLocalSnapshot({required bool isDraft}) {
    return {
      'schemaVersion': 1,
      'planName': state.planName,
      'breakfast': _serializeMealEntries(state.breakfast),
      'lunch': _serializeMealEntries(state.lunch),
      'dinner': _serializeMealEntries(state.dinner),
      'snacks': _serializeMealEntries(state.snacks),
      'breakfastExpanded': state.breakfastExpanded,
      'lunchExpanded': state.lunchExpanded,
      'dinnerExpanded': state.dinnerExpanded,
      'snacksExpanded': state.snacksExpanded,
      'selectedDate': state.selectedDate?.toIso8601String(),
      'selectedTime': state.selectedTime,
      'recurrence': state.recurrence,
      'remindTrainee': state.remindTrainee,
      'alertIfMissed': state.alertIfMissed,
      if (isDraft) 'selectedTraineeIds': state.selectedTraineeIds.toList(),
    };
  }

  NutritionBuilderState? _stateFromLocalSnapshot(
    Map<String, dynamic> raw,
  ) {
    if ((raw['schemaVersion'] as num?)?.toInt() != 1) {
      return null;
    }
    final ids = raw['selectedTraineeIds'] as List?;
    final selected = ids == null
        ? <int>{}
        : ids
            .map((e) => (e as num).toInt())
            .where((id) => state.allTrainees.any((t) => t.id == id))
            .toSet();
    final sd = raw['selectedDate'] != null
        ? DateTime.tryParse(raw['selectedDate'] as String)
        : null;
    return state.copyWith(
      planName: raw['planName'] as String? ?? '',
      breakfast: _mealEntriesFromList(raw['breakfast']),
      lunch: _mealEntriesFromList(raw['lunch']),
      dinner: _mealEntriesFromList(raw['dinner']),
      snacks: _mealEntriesFromList(raw['snacks']),
      breakfastExpanded: raw['breakfastExpanded'] as bool? ?? true,
      lunchExpanded: raw['lunchExpanded'] as bool? ?? false,
      dinnerExpanded: raw['dinnerExpanded'] as bool? ?? false,
      snacksExpanded: raw['snacksExpanded'] as bool? ?? true,
      selectedDate: sd,
      selectedTime: raw['selectedTime'] as String? ?? state.selectedTime,
      recurrence: raw['recurrence'] as String? ?? state.recurrence,
      remindTrainee: raw['remindTrainee'] as bool? ?? state.remindTrainee,
      alertIfMissed: raw['alertIfMissed'] as bool? ?? state.alertIfMissed,
      selectedTraineeIds: selected,
      currentStep: 5,
      clearError: true,
    );
  }

  Future<void> _onSaveTemplate(NutritionSaveTemplate event,
      Emitter<NutritionBuilderState> emit) async {
    emit(state.copyWith(
        saving: true, clearError: true, templateSaved: false));
    try {
      final snap = _nutritionLocalSnapshot(isDraft: false);
      await planBuilderLocalStorage.saveNutritionTemplate(
        snap,
        displayName: state.planName.trim().isEmpty ? null : state.planName.trim(),
      );
      emit(state.copyWith(saving: false, templateSaved: true));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  Future<void> _onSaveDraft(
      NutritionSaveDraft event, Emitter<NutritionBuilderState> emit) async {
    emit(state.copyWith(saving: true, clearError: true, draftSaved: false));
    try {
      await planBuilderLocalStorage
          .saveNutritionDraft(_nutritionLocalSnapshot(isDraft: true));
      emit(state.copyWith(saving: false, draftSaved: true));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  Future<void> _onRestoreDraft(
    RestoreNutritionDraftFromLocal event,
    Emitter<NutritionBuilderState> emit,
  ) async {
    emit(state.copyWith(saving: true, clearError: true));
    try {
      final json = planBuilderLocalStorage.nutritionDraftJson;
      if (json == null || json.isEmpty) {
        emit(state.copyWith(
          saving: false,
          error: 'No saved draft on this device.',
        ));
        return;
      }
      final decoded = jsonDecode(json);
      if (decoded is! Map) {
        emit(state.copyWith(
          saving: false,
          error: 'Could not read draft data.',
        ));
        return;
      }
      final data = Map<String, dynamic>.from(decoded);
      final next = _stateFromLocalSnapshot(data);
      if (next == null) {
        emit(state.copyWith(
          saving: false,
          error: 'Draft data is not valid for this version.',
        ));
        return;
      }
      emit(next.copyWith(saving: false));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  Future<void> _onRestoreTemplate(
    RestoreNutritionTemplateFromLocal event,
    Emitter<NutritionBuilderState> emit,
  ) async {
    emit(state.copyWith(saving: true, clearError: true));
    try {
      final data = planBuilderLocalStorage
          .nutritionTemplateDataById(event.templateId);
      if (data == null) {
        emit(state.copyWith(
          saving: false,
          error: 'Template not found.',
        ));
        return;
      }
      final next = _stateFromLocalSnapshot(data);
      if (next == null) {
        emit(state.copyWith(
          saving: false,
          error: 'Template data is not valid for this version.',
        ));
        return;
      }
      emit(next.copyWith(
        saving: false,
        selectedTraineeIds: const {},
      ));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }
}
