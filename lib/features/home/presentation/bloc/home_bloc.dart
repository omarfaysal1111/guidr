import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/features/home/domain/entities/coach_data.dart';
import 'package:guidr/features/home/domain/entities/coach_home_models.dart';
import 'package:guidr/features/home/domain/usecases/get_coach_home_use_case.dart';
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
  final List<CoachHomeTrainee> todaysSessions;
  final List<CoachHomeTrainee> topPerformers;
  final List<CoachHomeInvitation> pendingInvitations;

  const HomeLoaded({
    required this.coachData,
    required this.todaysSessions,
    required this.topPerformers,
    required this.pendingInvitations,
  });

  @override
  List<Object?> get props =>
      [coachData, todaysSessions, topPerformers, pendingInvitations];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetCoachHomeUseCase getCoachHomeUseCase;
  final GetNeedsAttentionUseCase getNeedsAttentionUseCase;

  HomeBloc(this.getCoachHomeUseCase, this.getNeedsAttentionUseCase)
      : super(HomeInitial()) {
    on<LoadHomeDataEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        final home = await getCoachHomeUseCase();
        final trainees = home.trainees;
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

        final activeClients = home.coach.traineeCount ?? 0;
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
        // Add trainees with low adherence (< 50%) to needs attention
        final List<AttentionItem> combinedAttentionItems = [
          ...needsAttentionItems,
        ];
        for (final trainee in trainees) {
          final adherence = trainee.adherence;
          if (adherence != null && adherence < 50) {
            final traineeIdStr = trainee.id.toString();
            final alreadyExists = combinedAttentionItems
                .any((item) => item.traineeId == traineeIdStr);
            if (!alreadyExists) {
              combinedAttentionItems.add(
                AttentionItem(
                  id: 'adherence_${trainee.id}',
                  traineeId: traineeIdStr,
                  clientName: trainee.fullName,
                  message:
                      '${trainee.fullName} adherence is ${adherence.toStringAsFixed(0)}% this week.',
                  alertType: 'nutrition',
                ),
              );
            }
          }
        }
        final needsAttentionCount = combinedAttentionItems.length;

        final todaysSessions = trainees.take(2).toList();
        final topPerformers = trainees.take(3).toList();
        final pendingInvitations = home.invitations
            .where((inv) => inv.status.toUpperCase() == 'PENDING')
            .toList();

        final coachHomeData = CoachData(
          name: home.coach.fullName,
          dateString: dateString,
          sessionsToday: todaysSessions.length,
          needsAttention: needsAttentionCount,
          isPremium: false, // TODO: from subscription when available
          activeClients: activeClients,
          maxClients: maxClients,
          avgAdherence: 0, // TODO: from analytics when available
          needsAttentionItems: combinedAttentionItems,
        );

        emit(
          HomeLoaded(
            coachData: coachHomeData,
            todaysSessions: todaysSessions,
            topPerformers: topPerformers,
            pendingInvitations: pendingInvitations,
          ),
        );
      } catch (e) {
        emit(HomeError(e.toString()));
      }
    });
  }
}
