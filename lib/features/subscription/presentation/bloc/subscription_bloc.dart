import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/subscription_repository.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
  @override
  List<Object?> get props => [];
}

class LoadSubscription extends SubscriptionEvent {}

class SubmitPayment extends SubscriptionEvent {
  final String desiredPlan;
  final String paymentMethod;
  final double transferredAmount;
  final List<int> imageBytes;
  final String fileName;

  const SubmitPayment({
    required this.desiredPlan,
    required this.paymentMethod,
    required this.transferredAmount,
    required this.imageBytes,
    required this.fileName,
  });

  @override
  List<Object?> get props =>
      [desiredPlan, paymentMethod, transferredAmount, fileName];
}

class LoadPaymentHistory extends SubscriptionEvent {}

// ── States ───────────────────────────────────────────────────────────────────

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionStatus status;
  const SubscriptionLoaded(this.status);
  @override
  List<Object?> get props => [status];
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError(this.message);
  @override
  List<Object?> get props => [message];
}

class PaymentSubmitting extends SubscriptionState {}

class PaymentSuccess extends SubscriptionState {
  final PaymentRecord record;
  const PaymentSuccess(this.record);
  @override
  List<Object?> get props => [record];
}

class PaymentFailed extends SubscriptionState {
  final String message;
  const PaymentFailed(this.message);
  @override
  List<Object?> get props => [message];
}

class PaymentHistoryLoaded extends SubscriptionState {
  final List<PaymentRecord> records;
  const PaymentHistoryLoaded(this.records);
  @override
  List<Object?> get props => [records];
}

// ── BLoC ────────────────────────────────────────────────────────────────────

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository repository;

  SubscriptionBloc({required this.repository}) : super(SubscriptionInitial()) {
    on<LoadSubscription>((event, emit) async {
      emit(SubscriptionLoading());
      try {
        final status = await repository.getSubscriptionStatus();
        emit(SubscriptionLoaded(status));
      } catch (e) {
        emit(SubscriptionError(_clean(e)));
      }
    });

    on<SubmitPayment>((event, emit) async {
      emit(PaymentSubmitting());
      try {
        final record = await repository.submitPayment(
          desiredPlan: event.desiredPlan,
          paymentMethod: event.paymentMethod,
          transferredAmount: event.transferredAmount,
          imageBytes: event.imageBytes,
          fileName: event.fileName,
        );
        emit(PaymentSuccess(record));
      } catch (e) {
        emit(PaymentFailed(_clean(e)));
      }
    });

    on<LoadPaymentHistory>((event, emit) async {
      emit(SubscriptionLoading());
      try {
        final records = await repository.getPaymentHistory();
        emit(PaymentHistoryLoaded(records));
      } catch (e) {
        emit(SubscriptionError(_clean(e)));
      }
    });
  }

  String _clean(Object e) {
    final msg = e.toString();
    if (msg.startsWith('Exception: ')) return msg.substring(11);
    return msg;
  }
}
