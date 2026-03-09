import 'package:get_it/get_it.dart';
import 'package:guidr/features/coach_settings/domain/usecases/CoachDataUseCase.dart';
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

import '../../features/coach_builders/data/datasources/builders_remote_data_source.dart';
import '../../features/coach_builders/data/repositories/builders_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());

  //! Core
  sl.registerLazySingleton(() => LocalStorage(sl()));
  sl.registerLazySingleton(() => ApiClient(localStorage: sl(), client: sl()));

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

  //! Features - Coach Builders (Nutrition & Exercises)
  sl.registerLazySingleton<BuildersRemoteDataSource>(
    () => BuildersRemoteDataSourceImpl(apiClient: sl()),
  );
sl.registerLazySingleton(() => GetCoachDataUseCase(sl()));
  sl.registerLazySingleton<BuildersRepository>(
    () => BuildersRepositoryImpl(remoteDataSource: sl()),
  );
}

