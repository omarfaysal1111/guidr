import 'package:flutter/material.dart';
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/trainee_today/presentation/pages/trainee_today_screen.dart';
import 'package:guidr/features/trainee_workout/presentation/pages/trainee_workout_screen.dart';
import 'package:guidr/features/trainee_nutrition/presentation/pages/trainee_nutrition_screen.dart';
import 'package:guidr/features/trainee_progress/presentation/pages/trainee_progress_screen.dart';
import 'package:guidr/features/trainee_chat/presentation/pages/trainee_chat_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/features/trainee_progress/presentation/bloc/trainee_progress_bloc.dart';
import 'package:guidr/features/trainee_progress/presentation/bloc/trainee_progress_event.dart';
class TraineeLayoutPage extends StatefulWidget {
  const TraineeLayoutPage({super.key});

  @override
  State<TraineeLayoutPage> createState() => _TraineeLayoutPageState();
}

class _TraineeLayoutPageState extends State<TraineeLayoutPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const TraineeTodayScreen(),
      const TraineeWorkoutScreen(),
      const TraineeNutritionScreen(),
      BlocProvider(
        create: (_) => di.sl<TraineeProgressBloc>()..add(LoadTraineeProgress()),
        child: const TraineeProgressScreen(),
      ),
      const TraineeChatScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: const Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.card,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Today',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Workout',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined),
              activeIcon: Icon(Icons.restaurant),
              label: 'Nutrition',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_outlined),
              activeIcon: Icon(Icons.show_chart),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}
