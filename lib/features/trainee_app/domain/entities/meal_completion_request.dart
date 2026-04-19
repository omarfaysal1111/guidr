class IngredientSwapRequest {
  final int originalIngredientId;
  final int newIngredientId;
  final double? newQuantity;

  const IngredientSwapRequest({
    required this.originalIngredientId,
    required this.newIngredientId,
    this.newQuantity,
  });

  Map<String, dynamic> toJson() => {
        'originalIngredientId': originalIngredientId,
        'newIngredientId': newIngredientId,
        if (newQuantity != null) 'newQuantity': newQuantity,
      };
}

class MealCompletionRequest {
  final bool skipMeal;
  final List<int> skippedIngredientIds;
  final List<IngredientSwapRequest> replacedIngredients;

  const MealCompletionRequest({
    this.skipMeal = false,
    this.skippedIngredientIds = const [],
    this.replacedIngredients = const [],
  });

  Map<String, dynamic> toJson() => {
        'skipMeal': skipMeal,
        'skippedIngredientIds': skippedIngredientIds,
        'replacedIngredients':
            replacedIngredients.map((e) => e.toJson()).toList(),
      };
}
