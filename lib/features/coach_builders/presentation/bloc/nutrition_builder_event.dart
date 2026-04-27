import 'package:guidr/features/coach_builders/domain/entities/ingredient.dart';
import 'nutrition_builder_state.dart';

abstract class NutritionBuilderEvent {
  const NutritionBuilderEvent();
}

class NutritionBuilderInit extends NutritionBuilderEvent {}

class NutritionSetStep extends NutritionBuilderEvent {
  final int step;
  const NutritionSetStep(this.step);
}

class NutritionFilterTrainees extends NutritionBuilderEvent {
  final String query;
  const NutritionFilterTrainees(this.query);
}

class NutritionToggleTrainee extends NutritionBuilderEvent {
  final int traineeId;
  const NutritionToggleTrainee(this.traineeId);
}

class NutritionSelectAllTrainees extends NutritionBuilderEvent {}

class NutritionUpdateMetadata extends NutritionBuilderEvent {
  final String? planName;
  const NutritionUpdateMetadata({this.planName});
}

class NutritionToggleMealSection extends NutritionBuilderEvent {
  final MealSection section;
  const NutritionToggleMealSection(this.section);
}

class NutritionAddMealItem extends NutritionBuilderEvent {
  final MealSection section;
  final String? customName;
  final Ingredient? libraryIngredient;

  /// Quantity in grams (only used when [libraryIngredient] is provided).
  final double quantityG;

  const NutritionAddMealItem.custom(this.section, this.customName)
      : libraryIngredient = null,
        quantityG = 0;

  const NutritionAddMealItem.fromLibrary(
      this.section, this.libraryIngredient, this.quantityG)
      : customName = null;
}

class NutritionRemoveMealItem extends NutritionBuilderEvent {
  final MealSection section;
  final int index;
  const NutritionRemoveMealItem(this.section, this.index);
}

class NutritionUpdateMealItemQty extends NutritionBuilderEvent {
  final MealSection section;
  final int index;
  final double quantityG;
  const NutritionUpdateMealItemQty(this.section, this.index, this.quantityG);
}

class NutritionLoadIngredientLibrary extends NutritionBuilderEvent {}

class NutritionApplyTemplate extends NutritionBuilderEvent {
  final String templateId;
  const NutritionApplyTemplate(this.templateId);
}

class NutritionUpdateSchedule extends NutritionBuilderEvent {
  final DateTime? selectedDate;
  final String? selectedTime;
  final String? recurrence;
  final bool? remindTrainee;
  final bool? alertIfMissed;
  const NutritionUpdateSchedule({
    this.selectedDate,
    this.selectedTime,
    this.recurrence,
    this.remindTrainee,
    this.alertIfMissed,
  });
}

class NutritionAssignPlan extends NutritionBuilderEvent {}

class NutritionSaveTemplate extends NutritionBuilderEvent {}

class NutritionSaveDraft extends NutritionBuilderEvent {}

class RestoreNutritionDraftFromLocal extends NutritionBuilderEvent {
  const RestoreNutritionDraftFromLocal();
}

class RestoreNutritionTemplateFromLocal extends NutritionBuilderEvent {
  final String templateId;
  const RestoreNutritionTemplateFromLocal(this.templateId);
}
