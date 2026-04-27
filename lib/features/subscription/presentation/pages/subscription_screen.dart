// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import '../bloc/subscription_bloc.dart';
import '../../domain/entities/subscription_status.dart';
import 'payment_submit_screen.dart';

// ─── Plan metadata ───────────────────────────────────────────────────────────

class PlanMeta {
  final String key;
  final String name;
  final String price;
  final String duration;
  final String clientLabel;
  final List<String> features;
  final Color accentColor;
  final LinearGradient gradient;

  const PlanMeta({
    required this.key,
    required this.name,
    required this.price,
    required this.duration,
    required this.clientLabel,
    required this.features,
    required this.accentColor,
    required this.gradient,
  });
}

const _plans = [
  PlanMeta(
    key: 'TRIAL',
    name: 'Trial',
    price: 'Free',
    duration: '7 days',
    clientLabel: 'Up to 3 clients',
    features: [
      'Up to 3 active trainees',
      'Workout & nutrition plans',
      'Progress tracking',
      'Client messaging',
    ],
    accentColor: Color(0xFF94A3B8),
    gradient: LinearGradient(
      colors: [Color(0xFF475569), Color(0xFF64748B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  PlanMeta(
    key: 'BASIC',
    name: 'Basic',
    price: '399 EGP',
    duration: '1 month',
    clientLabel: 'Up to 10 clients',
    features: [
      'Up to 10 active trainees',
      'Workout & nutrition plans',
      'Progress tracking',
      'Client messaging',
      'InBody report uploads',
    ],
    accentColor: Color(0xFF3B82F6),
    gradient: LinearGradient(
      colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  PlanMeta(
    key: 'PREMIUM',
    name: 'Premium',
    price: '699 EGP',
    duration: '1 month',
    clientLabel: 'Up to 25 clients',
    features: [
      'Up to 25 active trainees',
      'Everything in Basic',
      'Priority support',
      'Advanced analytics',
    ],
    accentColor: AppColors.primary,
    gradient: AppColors.workoutGradient,
  ),
  PlanMeta(
    key: 'ELITE',
    name: 'Elite',
    price: '999 EGP',
    duration: '1 month',
    clientLabel: 'Unlimited clients',
    features: [
      'Unlimited active trainees',
      'Everything in Premium',
      'Dedicated support',
      'Early access to new features',
    ],
    accentColor: Color(0xFFF59E0B),
    gradient: LinearGradient(
      colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
];

// ─── Entry point ─────────────────────────────────────────────────────────────

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<SubscriptionBloc>()..add(LoadSubscription()),
      child: const _SubscriptionView(),
    );
  }
}

// ─── Main view ───────────────────────────────────────────────────────────────

class _SubscriptionView extends StatelessWidget {
  const _SubscriptionView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Subscription & Billing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _openHistory(context),
            icon: const Icon(Icons.receipt_long_outlined,
                size: 18, color: AppColors.textSecondary),
            label: const Text(
              'History',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading || state is SubscriptionInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is SubscriptionError) {
            return _ErrorBody(
              message: state.message,
              onRetry: () =>
                  context.read<SubscriptionBloc>().add(LoadSubscription()),
            );
          }
          final status =
              state is SubscriptionLoaded ? state.status : null;
          return _Body(status: status);
        },
      ),
    );
  }

  void _openHistory(BuildContext context) {
    final bloc = context.read<SubscriptionBloc>();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: bloc..add(LoadPaymentHistory()),
        child: const _PaymentHistoryScreen(),
      ),
    ));
  }
}

// ─── Body ────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final SubscriptionStatus? status;
  const _Body({this.status});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
      children: [
        if (status != null) ...[
          _CurrentPlanCard(status: status!),
          const SizedBox(height: 28),
        ],
        const Text(
          'AVAILABLE PLANS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        ..._plans.map((plan) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _PlanCard(
                plan: plan,
                isCurrent: status?.plan == plan.key,
                isExpired: status?.isExpired ?? false,
                onUpgrade: plan.key == 'TRIAL'
                    ? null
                    : () => _navigateToPayment(context, plan),
              ),
            )),
        const SizedBox(height: 8),
        _PaymentMethodsNote(),
      ],
    );
  }

  void _navigateToPayment(BuildContext context, PlanMeta plan) {
    final bloc = context.read<SubscriptionBloc>();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: PaymentSubmitScreen(plan: plan),
      ),
    ));
  }
}

// ─── Current plan hero card ───────────────────────────────────────────────────

class _CurrentPlanCard extends StatelessWidget {
  final SubscriptionStatus status;
  const _CurrentPlanCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final meta = _plans.firstWhere(
      (p) => p.key == status.plan,
      orElse: () => _plans.first,
    );

    final pct = status.unlimited || status.maxClients <= 0
        ? 0.0
        : (status.currentClientCount / status.maxClients).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: meta.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: meta.accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'CURRENT PLAN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status.active
                      ? Colors.white.withOpacity(0.2)
                      : Colors.red.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: status.active ? Colors.white : Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status.active ? 'Active' : 'Expired',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            meta.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status.isExpired
                ? 'Expired — renew to continue'
                : '${status.daysRemaining} day${status.daysRemaining == 1 ? '' : 's'} remaining',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          // Client slots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Client Slots',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500),
              ),
              Text(
                status.unlimited
                    ? '${status.currentClientCount} / ∞'
                    : '${status.currentClientCount} / ${status.maxClients}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!status.unlimited) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pct >= 1
                  ? 'Limit reached — upgrade to invite more'
                  : '${status.remainingSlots} slot${status.remainingSlots == 1 ? '' : 's'} remaining',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w500),
            ),
          ] else ...[
            Text(
              'Unlimited clients',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.75),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Plan card ───────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final PlanMeta plan;
  final bool isCurrent;
  final bool isExpired;
  final VoidCallback? onUpgrade;

  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.isExpired,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isSelectable = onUpgrade != null;
    final showRenew = isCurrent && isExpired && isSelectable;
    final showUpgrade = !isCurrent && isSelectable;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent
              ? plan.accentColor.withOpacity(0.6)
              : AppColors.border,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: plan.accentColor.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: InkWell(
        onTap: onUpgrade,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Plan icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: plan.gradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _iconFor(plan.key),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      plan.accentColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isExpired ? 'EXPIRED' : 'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: isExpired
                                        ? AppColors.error
                                        : plan.accentColor,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plan.clientLabel,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.price,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: plan.accentColor,
                        ),
                      ),
                      Text(
                        plan.duration,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...plan.features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 14, color: plan.accentColor),
                        const SizedBox(width: 8),
                        Text(
                          f,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )),
              if (showUpgrade || showRenew) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onUpgrade,
                    style: FilledButton.styleFrom(
                      backgroundColor: plan.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    child: Text(
                      showRenew ? 'Renew ${plan.name}' : 'Upgrade to ${plan.name}',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'BASIC':
        return Icons.bolt_rounded;
      case 'PREMIUM':
        return Icons.star_rounded;
      case 'ELITE':
        return Icons.diamond_rounded;
      default:
        return Icons.explore_outlined;
    }
  }
}

// ─── Payment methods note ────────────────────────────────────────────────────

class _PaymentMethodsNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'We accept Vodafone Cash and InstaPay. After payment, upload a screenshot of your transfer receipt for instant verification.',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryDark,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error body ──────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 52, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Payment history screen ──────────────────────────────────────────────────

class _PaymentHistoryScreen extends StatelessWidget {
  const _PaymentHistoryScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment History',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary),
        ),
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is PaymentHistoryLoaded) {
            if (state.records.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 52, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text('No payment history yet',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: state.records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _HistoryTile(record: state.records[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final dynamic record;
  const _HistoryTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final isApproved = record.status == 'APPROVED';
    final isRejected = record.status == 'REJECTED';
    final statusColor = isApproved
        ? AppColors.success
        : isRejected
            ? AppColors.error
            : AppColors.warning;
    final statusLabel = isApproved
        ? 'Approved'
        : isRejected
            ? 'Rejected'
            : 'Pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _fmtDate(record.createdAt),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.desiredPlan,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    record.paymentMethod.toString().replaceAll('_', ' '),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Text(
                '${record.claimedAmount.toStringAsFixed(0)} EGP',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          if (record.reviewNote != null && record.reviewNote!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isRejected
                    ? AppColors.errorLight
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isRejected
                        ? Icons.error_outline
                        : Icons.info_outline_rounded,
                    size: 14,
                    color: isRejected
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      record.reviewNote!,
                      style: TextStyle(
                          fontSize: 12,
                          color: isRejected
                              ? AppColors.error
                              : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}
