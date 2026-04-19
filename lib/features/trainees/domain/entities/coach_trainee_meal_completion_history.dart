import 'package:equatable/equatable.dart';

/// One ingredient deviation inside a [MealCompletionRecord].
class MealIngredientDeviation extends Equatable {
  final int originalIngredientId;
  final String originalIngredientName;
  final int? replacementIngredientId;
  final String? replacementIngredientName;
  final double? newQuantity;

  /// `"SKIPPED"` or `"SWAPPED"`.
  final String type;

  const MealIngredientDeviation({
    required this.originalIngredientId,
    required this.originalIngredientName,
    this.replacementIngredientId,
    this.replacementIngredientName,
    this.newQuantity,
    required this.type,
  });

  bool get isSkipped => type.toUpperCase() == 'SKIPPED';
  bool get isSwapped => type.toUpperCase() == 'SWAPPED';

  factory MealIngredientDeviation.fromJson(Map<String, dynamic> json) {
    return MealIngredientDeviation(
      originalIngredientId: _toInt(json['originalIngredientId']),
      originalIngredientName:
          json['originalIngredientName']?.toString() ?? 'Ingredient',
      replacementIngredientId:
          json['replacementIngredientId'] != null
              ? _toInt(json['replacementIngredientId'])
              : null,
      replacementIngredientName:
          json['replacementIngredientName']?.toString(),
      newQuantity: json['newQuantity'] != null
          ? (json['newQuantity'] as num).toDouble()
          : null,
      type: json['type']?.toString() ?? 'SKIPPED',
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [
        originalIngredientId,
        originalIngredientName,
        replacementIngredientId,
        replacementIngredientName,
        newQuantity,
        type,
      ];
}

/// One meal completion entry from `mealCompletionHistory` on the coach trainee detail API.
class MealCompletionRecord extends Equatable {
  final int completionId;
  final int mealId;
  final String mealName;
  final int nutritionPlanId;
  final String nutritionPlanTitle;
  final String completionDate;
  final DateTime? completedAt;
  final bool skipped;
  final bool hasDeviations;
  final List<MealIngredientDeviation> ingredientDeviations;

  const MealCompletionRecord({
    required this.completionId,
    required this.mealId,
    required this.mealName,
    required this.nutritionPlanId,
    required this.nutritionPlanTitle,
    required this.completionDate,
    this.completedAt,
    required this.skipped,
    required this.hasDeviations,
    required this.ingredientDeviations,
  });

  factory MealCompletionRecord.fromJson(Map<String, dynamic> json) {
    final devsRaw = json['ingredientDeviations'];
    final devs = <MealIngredientDeviation>[];
    if (devsRaw is List) {
      for (final d in devsRaw) {
        if (d is Map<String, dynamic>) {
          devs.add(MealIngredientDeviation.fromJson(d));
        } else if (d is Map) {
          devs.add(
              MealIngredientDeviation.fromJson(Map<String, dynamic>.from(d)));
        }
      }
    }

    return MealCompletionRecord(
      completionId: MealIngredientDeviation._toInt(json['completionId']),
      mealId: MealIngredientDeviation._toInt(json['mealId']),
      mealName: json['mealName']?.toString() ?? 'Meal',
      nutritionPlanId:
          MealIngredientDeviation._toInt(json['nutritionPlanId']),
      nutritionPlanTitle:
          json['nutritionPlanTitle']?.toString() ?? '',
      completionDate:
          json['completionDate']?.toString().trim() ?? '',
      completedAt: _parseDateTime(json['completedAt']),
      skipped: json['skipped'] == true,
      hasDeviations: json['hasDeviations'] == true,
      ingredientDeviations: devs,
    );
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  @override
  List<Object?> get props => [
        completionId,
        mealId,
        mealName,
        nutritionPlanId,
        nutritionPlanTitle,
        completionDate,
        completedAt,
        skipped,
        hasDeviations,
        ingredientDeviations,
      ];
}

List<MealCompletionRecord> parseMealCompletionHistory(dynamic raw) {
  if (raw is! List) return [];
  final out = <MealCompletionRecord>[];
  for (final e in raw) {
    if (e is Map<String, dynamic>) {
      out.add(MealCompletionRecord.fromJson(e));
    } else if (e is Map) {
      out.add(MealCompletionRecord.fromJson(Map<String, dynamic>.from(e)));
    }
  }
  return out;
}
