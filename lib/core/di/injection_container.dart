import 'package:get_it/get_it.dart';
import 'package:guidr/core/locale/locale_cubit.dart';
import 'package:guidr/core/messaging/fcm_service.dart';
import 'package:guidr/features/chat/data/firestore_chat_repository.dart';
import 'package:guidr/features/chat/domain/repositories/chat_repository.dart';
import 'package:guidr/features/coach_builders/data/repositories/builder_repository.dart';
import 'package:guidr/features/coach_builders/presentation/bloc/workout_builder_bloc.dart';
import 'package:guidr/features/coach_builders/presentation/bloc/nutrition_builder_bloc.dart';
import 'package:guidr/features/coach_settings/domain/usecases/coach_data_use_case.dart';
import 'package:guidr/features/home/data/datasources/home_remote_data_source.dart';
import 'package:guidr/features/home/domain/usecases/get_coach_home_use_case.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../storage/local_storage.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/coach_settings/data/datasources/coach_remote_data_source.dart';
import '../../features/coach_settings/domain/repositories/coach_repository.dart';
import '../../features/coach_settings/data/repositories/coach_repository_impl.dart';
import '../../features/coach_settings/presentation/bloc/coach_profile_bloc.dart';

import '../../features/needs_attention/data/datasources/needs_attention_remote_data_source.dart';
import '../../features/needs_attention/domain/repositories/needs_attention_repository.dart';
import '../../features/needs_attention/data/repositories/needs_attention_repository_impl.dart';
import '../../features/needs_attention/domain/usecases/get_needs_attention_use_case.dart';

import '../../features/trainees/data/datasources/trainees_remote_data_source.dart';
import '../../features/trainees/domain/repositories/trainees_repository.dart';
import '../../features/trainees/data/repositories/trainees_repository_impl.dart';
import '../../features/trainees/presentation/bloc/trainees_bloc.dart';

import '../../features/trainee_app/data/datasources/trainee_app_remote_data_source.dart';
import '../../features/trainee_app/domain/repositories/trainee_app_repository.dart';
import '../../features/trainee_app/data/repositories/trainee_app_repository_impl.dart';

import '../../features/trainee_today/data/trainee_completed_plan_sessions_storage.dart';
import '../../features/trainee_today/presentation/bloc/trainee_today_cubit.dart';

import '../../features/coach_builders/data/datasources/builders_remote_data_source.dart';
import '../../features/coach_builders/data/repositories/builders_repository_impl.dart';

import '../../features/trainee_progress/data/datasources/trainee_progress_remote_data_source.dart';
import '../../features/trainee_progress/domain/repositories/trainee_progress_repository.dart';
import '../../features/trainee_progress/data/repositories/trainee_progress_repository_impl.dart';
import '../../features/trainee_progress/presentation/bloc/trainee_progress_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());

  //! Core
  sl.registerLazySingleton(() => LocalStorage(sl()));
  sl.registerLazySingleton(() => TraineeCompletedPlanSessionsStorage(sl()));
  sl.registerLazySingleton(() => ApiClient(localStorage: sl(), client: sl()));
  sl.registerLazySingleton<ChatRepository>(() => FirestoreChatRepository());
  sl.registerLazySingleton(() => FcmService());
  sl.registerLazySingleton(() => LocaleCubit(sl()));

  //! Features - Auth
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localStorage: sl(),
      apiClient: sl(),
    ),
  );

  // Bloc
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  //! Features - Coach Settings
  sl.registerLazySingleton<CoachRemoteDataSource>(
    () => CoachRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<CoachRepository>(
    () => CoachRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(() => CoachProfileBloc(repository: sl()));

  //! Features - Needs Attention
  sl.registerLazySingleton<NeedsAttentionRemoteDataSource>(
    () => NeedsAttentionRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<NeedsAttentionRepository>(
    () => NeedsAttentionRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(
    () => GetNeedsAttentionUseCase(sl()),
  );

  //! Features - Trainees
  sl.registerLazySingleton<TraineesRemoteDataSource>(
    () => TraineesRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<TraineesRepository>(
    () => TraineesRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(() => TraineesBloc(repository: sl()));

  //! Features - Trainee App
  sl.registerLazySingleton<TraineeAppRemoteDataSource>(
    () => TraineeAppRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<TraineeAppRepository>(
    () => TraineeAppRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(() => TraineeTodayCubit(repository: sl()));

  //! Features - Coach Builders (Nutrition & Exercises)
  sl.registerLazySingleton<BuildersRemoteDataSource>(
    () => BuildersRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton(() => GetCoachDataUseCase(sl()));
  sl.registerLazySingleton<BuildersRepository>(
    () => BuildersRepositoryImpl(remoteDataSource: sl()),
  );
sl.registerFactory(
    () => WorkoutBuilderBloc(
      buildersRepository: sl(),
      traineesRepository: sl(),
      getCoachDataUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => NutritionBuilderBloc(
      buildersRepository: sl(),
      traineesRepository: sl(),
    ),
  );
  //! Features - Coach Home
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<GetCoachHomeUseCase>(
    () => GetCoachHomeUseCase(sl()),
  );

  //! Features - Trainee Progress
  sl.registerLazySingleton<TraineeProgressRemoteDataSource>(
    () => TraineeProgressRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<TraineeProgressRepository>(
    () => TraineeProgressRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(() => TraineeProgressBloc(repository: sl()));
}

