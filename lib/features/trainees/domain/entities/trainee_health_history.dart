import 'package:equatable/equatable.dart';
import 'trainee.dart';

/// Health & training questionnaire fields (coach trainee `profile` / nested `healthHistory`).
class TraineeHealthHistory extends Equatable {
  final String goal;
  final String trainingExperience;
  final String previousTraining;
  final String reasonForStopping;
  final String diseasesOrConditions;
  final String allergies;
  final String injuries;
  final String medications;

  const TraineeHealthHistory({
    required this.goal,
    required this.trainingExperience,
    required this.previousTraining,
    required this.reasonForStopping,
    required this.diseasesOrConditions,
    required this.allergies,
    required this.injuries,
    required this.medications,
  });

  static String _pick(Map<String, dynamic> m, List<String> keys, [String empty = '—']) {
    for (final k in keys) {
      final v = m[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return empty;
  }

  /// Reads nested `healthHistory` on [profileMap] when present, else top-level keys on profile.
  factory TraineeHealthHistory.fromProfileMap(
    Map<String, dynamic> profileMap,
    Trainee profile,
  ) {
    final nested = profileMap['healthHistory'];
    final m = nested is Map<String, dynamic> ? nested : profileMap;

    final goalVal = _pick(m, const ['goal', 'fitnessGoal'], '');
    final goal = goalVal.isNotEmpty ? goalVal : profile.goal;

    return TraineeHealthHistory(
      goal: goal,
      trainingExperience: _pick(m, const [
        'trainingExperience',
        'training_experience',
        'experience',
        'trainingExperienceDescription',
      ]),
      previousTraining: _pick(m, const [
        'previousTraining',
        'previous_training',
        'pastTraining',
        'trainingHistory',
      ]),
      reasonForStopping: _pick(m, const [
        'reasonForStopping',
        'reason_for_stopping',
        'stoppedReason',
      ]),
      diseasesOrConditions: _pick(m, const [
        'diseasesOrConditions',
        'diseases_or_conditions',
        'conditions',
        'medicalConditions',
      ]),
      allergies: _pick(m, const ['allergies', 'allergy']),
      injuries: _pick(m, const ['injuries', 'injury']),
      medications: _pick(m, const ['medications', 'medication', 'meds']),
    );
  }

  /// When detail is not loaded — show goal from [profile], rest placeholders.
  factory TraineeHealthHistory.fallback(Trainee profile) {
    return TraineeHealthHistory(
      goal: profile.goal,
      trainingExperience: '—',
      previousTraining: '—',
      reasonForStopping: '—',
      diseasesOrConditions: '—',
      allergies: '—',
      injuries: '—',
      medications: '—',
    );
  }

  @override
  List<Object?> get props => [
        goal,
        trainingExperience,
        previousTraining,
        reasonForStopping,
        diseasesOrConditions,
        allergies,
        injuries,
        medications,
      ];
}
