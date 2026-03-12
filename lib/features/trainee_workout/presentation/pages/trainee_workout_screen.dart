import 'package:flutter/material.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/coach_builders/domain/entities/plans.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';
import 'package:guidr/features/trainee_today/presentation/pages/trainee_exercise_plan_screen.dart';

class TraineeWorkoutScreen extends StatefulWidget {
  const TraineeWorkoutScreen({super.key});

  @override
  State<TraineeWorkoutScreen> createState() => _TraineeWorkoutScreenState();
}

class _TraineeWorkoutScreenState extends State<TraineeWorkoutScreen> {
  ExercisePlan? _plan;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrentWorkout();
  }

  Future<void> _loadCurrentWorkout() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = di.sl<TraineeAppRepository>();
    try {
      final dashboard = await repo.getDashboardToday();
      final summary = dashboard.todayWorkoutSummary;
      if (summary.planId == 0) {
        setState(() {
          _plan = null;
          _loading = false;
        });
        return;
      }
      // Minimal plan model; detail screen will fetch full data by id.
      final plan = ExercisePlan(
        id: summary.planId,
        title: summary.title,
        description: '',
      );
      setState(() {
        _plan = plan;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Workout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadCurrentWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_plan == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Workout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'No workout assigned for today.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    // Delegate to the detailed exercise plan screen (preview).
    return TraineeExercisePlanScreen(plan: _plan!);
  }
}
