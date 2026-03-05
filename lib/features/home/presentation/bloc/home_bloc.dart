import 'package:equatable/equatable.dart';
import '../../domain/entities/coach_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {}

// States
abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final CoachData coachData;

  const HomeLoaded(this.coachData);

  @override
  List<Object?> get props => [coachData];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeDataEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Mock Data based on prototype
        final mockData = CoachData(
          name: 'Mahmoud',
          dateString: 'Sunday, Feb 15',
          sessionsToday: 3,
          needsAttention: 4,
          isPremium: false,
          activeClients: 10,
          maxClients: 3,
          avgAdherence: 68,
        );
        
        emit(HomeLoaded(mockData));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });
  }
}
