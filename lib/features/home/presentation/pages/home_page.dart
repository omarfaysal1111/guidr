import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/core/widgets/progress_bar.dart';
import 'package:guidr/core/widgets/stat_card.dart';
import 'package:guidr/features/coach_settings/domain/repositories/coach_repository.dart';
import 'package:guidr/features/coach_settings/domain/usecases/CoachDataUseCase.dart';
import 'package:guidr/features/home/presentation/widgets/needs_attention_section.dart';
import 'package:guidr/features/needs_attention/domain/usecases/get_needs_attention_use_case.dart';
import '../bloc/home_bloc.dart';

class HomePage extends StatelessWidget {
  final CoachRepository? repo;
  const HomePage({super.key, this.repo});

  @override
  Widget build(BuildContext context) {
    final repository = repo ?? di.sl<CoachRepository>();
    return BlocProvider(
      create: (context) => HomeBloc(
        GetCoachDataUseCase(repository),
        di.sl<GetNeedsAttentionUseCase>(),
      )..add(LoadHomeDataEvent()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guider'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is HomeError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.error),
              ),
            );
          } else if (state is HomeLoaded) {
            final data = state.coachData;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(LoadHomeDataEvent());
              },
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                children: [
                  Text(
                    'Good evening, ${data.name}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(text: '${data.dateString} · '),
                        TextSpan(
                          text: '${data.sessionsToday} sessions today',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (data.needsAttention > 0) ...[
                          const TextSpan(text: ' · '),
                          TextSpan(
                            text: '${data.needsAttention} need attention',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Freemium Banner (Free Plan)
                  if (!data.isPremium)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warning.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.flash_on,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Free Plan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.star, size: 14),
                                label: const Text('Upgrade'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.people_alt_outlined,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Clients',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${data.activeClients}/${data.maxClients}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CustomProgressBar(
                            value: data.activeClients.toDouble(),
                            max: data.maxClients.toDouble(),
                            color: AppColors.warning,
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 12,
                                color: AppColors.warning,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Client limit reached — upgrade to add more',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Stats Grid
                  Row(
                    children: [
                      StatCard(
                        value: data.activeClients.toString(),
                        label: 'Active',
                        color: AppColors.primary,
                        fontsize: 11,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        value: '${data.avgAdherence}%',
                        label: 'Avg Adherence',
                        fontsize: 8,
                         
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        value: data.sessionsToday.toString(),
                        label: 'Sessions Today',
                        color: AppColors.textPrimary,
                        fontsize: 8,
                      ),
                      const SizedBox(width: 10),
                      StatCard(
                        value: data.needsAttention.toString(),
                        label: 'Alerts',
                        color: AppColors.error,
                        fontsize: 11,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  NeedsAttentionSection(
                    items: data.needsAttentionItems,
                    onViewAll: () {
                      // TODO: Navigate to full needs attention list
                    },
                    onItemTap: (item) {
                      // TODO: Navigate to trainee detail
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
