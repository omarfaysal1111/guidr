import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/features/coach_settings/domain/usecases/CoachDataUseCase.dart';
import 'package:guidr/features/home/domain/entities/coach_data.dart';
import 'package:guidr/features/needs_attention/domain/entities/attention_item.dart';
import 'package:guidr/features/needs_attention/domain/usecases/get_needs_attention_use_case.dart';

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
  final GetCoachDataUseCase getCoachDataUseCase;
  final GetNeedsAttentionUseCase getNeedsAttentionUseCase;

  HomeBloc(this.getCoachDataUseCase, this.getNeedsAttentionUseCase)
      : super(HomeInitial()) {
    on<LoadHomeDataEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final profile = await getCoachDataUseCase();
        final now = DateTime.now();
        final weekdays = [
          'Monday', 'Tuesday', 'Wednesday', 'Thursday',
          'Friday', 'Saturday', 'Sunday'
        ];
        final months = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        final dateString =
            '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

        final activeClients = profile.traineeCount ?? 0;
        const maxClients = 3; // Free plan limit

        List<AttentionItem> needsAttentionItems;
        try {
          needsAttentionItems = await getNeedsAttentionUseCase(
            limit: 10,
            offset: 0,
          );
        } catch (_) {
          needsAttentionItems = [];
        }
        final needsAttentionCount = needsAttentionItems.length;

        final coachHomeData = CoachData(
          name: profile.fullName,
          dateString: dateString,
          sessionsToday: 0, // TODO: from sessions API when available
          needsAttention: needsAttentionCount,
          isPremium: false, // TODO: from subscription when available
          activeClients: activeClients,
          maxClients: maxClients,
          avgAdherence: 0, // TODO: from analytics when available
          needsAttentionItems: needsAttentionItems,
        );

        emit(HomeLoaded(coachHomeData));
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });
  }
}
