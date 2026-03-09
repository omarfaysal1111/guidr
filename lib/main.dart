import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/main/presentation/pages/main_layout_page.dart';
import 'features/main/presentation/pages/trainee_layout_page.dart';
import 'features/auth/domain/entities/user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatus()),
        ),
      ],
      child: const FitCoachApp(),
    ),
  );
}

class FitCoachApp extends StatelessWidget {
  const FitCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guider',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial || state is AuthChecking) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is Authenticated) {
            if (state.user.role == UserRole.trainee) {
              return const TraineeLayoutPage();
            }
            return const MainLayoutPage();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
