import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'core/messaging/fcm_service.dart';
import 'core/messaging/firebase_messaging_background.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/main/presentation/pages/main_layout_page.dart';
import 'features/main/presentation/pages/trainee_layout_page.dart';
import 'features/auth/domain/entities/user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await di.init();
  di.sl<FcmService>().listenForegroundMessages((msg) {
    if (kDebugMode) {
      debugPrint(
        'FCM foreground: ${msg.notification?.title} ${msg.notification?.body}',
      );
    }
  });

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
      home: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => current is Authenticated,
        listener: (context, state) {
          if (state is Authenticated) {
            di.sl<FcmService>().syncTokenForUser(state.user.id);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
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
      ),
    );
  }
}
