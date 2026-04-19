// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/trainees/presentation/pages/trainee_profile_screen.dart';
import 'package:guidr/features/trainees/presentation/widgets/invite_trainee_dialog.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import '../bloc/trainees_bloc.dart';

class TraineesPage extends StatelessWidget {
  const TraineesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<TraineesBloc>()..add(LoadTraineesEvent()),
      child: const TraineesView(),
    );
  }
}

class TraineesView extends StatelessWidget {
  const TraineesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trainees',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              context.read<TraineesBloc>().add(const ToggleBulkModeEvent(true));
            },
          ),
        ],
      ),
      body: BlocBuilder<TraineesBloc, TraineesState>(
        builder: (context, state) {
          if (state is TraineesLoading || state is TraineesInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is TraineesLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip(context, 'All', 'all', state),
                      const SizedBox(width: 12),
                      _buildFilterChip(context, 'Active', 'active', state),
                      const SizedBox(width: 12),
                      _buildFilterChip(context, 'Attention', 'attention', state),
                      const SizedBox(width: 12),
                      _buildFilterChip(context, 'Pending', 'pending', state),
                    ],
                  ),
                ),

                // Header details
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.filteredTrainees.length} trainees',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showSortSheet(context),
                        icon: const Icon(Icons.swap_vert, size: 16),
                        label: const Text('Sort'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.filteredTrainees.length,
                    itemBuilder: (context, index) {
                      final trainee = state.filteredTrainees[index];
                      final isSelected = state.selectedIds.contains(trainee.id);
                      final hasAlerts = trainee.alerts.isNotEmpty || 
                                        trainee.missedMealCount > 0 || 
                                        trainee.missedWorkoutCount > 0;
                      final isPending = trainee.status == 'pending';

                      return GestureDetector(
                        onTap: () {
                          if (state.isBulkMode) {
                            context.read<TraineesBloc>().add(
                              ToggleSelectTraineeEvent(trainee.id),
                            );
                          } else if (!isPending) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<TraineesBloc>(),
                                  child: TraineeProfileScreen(
                                    trainee: trainee,
                                    onBackPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryLight
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : hasAlerts
                                      ? AppColors.error.withOpacity(0.3)
                                      : AppColors.border,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (state.isBulkMode) ...[
                                Icon(
                                  isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                                const SizedBox(width: 12),
                              ],
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: isPending
                                    ? AppColors.surface
                                    : hasAlerts
                                        ? AppColors.errorLight
                                        : AppColors.primaryLight,
                                child: Text(
                                  trainee.avatar,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isPending
                                        ? AppColors.textMuted
                                        : hasAlerts
                                            ? AppColors.error
                                            : AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Name and Status Row
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            trainee.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                           ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isPending
                                                ? AppColors.warningLight
                                                : AppColors.successLight,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isPending ? 'Pending' : 'Active',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isPending
                                                  ? AppColors.warning
                                                  : AppColors.success,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    
                                    // Goal and Joined Date
                                    Text(
                                      '${trainee.goal} · ${isPending ? 'Invited ${trainee.joined}' : trainee.joined}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    
                                    // Unified Alerts and Missed Items Wrap
                                    if (hasAlerts)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: [
                                            if (trainee.missedMealCount > 0)
                                              _buildAlertBadge('${trainee.missedMealCount} Missed Meals'),
                                            if (trainee.missedWorkoutCount > 0)
                                              _buildAlertBadge('${trainee.missedWorkoutCount} Missed Workouts'),
                                            ...trainee.alerts.map((a) => _buildAlertBadge(a)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                             
                              // Adherence + Streak
                              if (!state.isBulkMode && !isPending)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${trainee.adherence}%',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: trainee.adherence >= 80
                                              ? AppColors.success
                                              : AppColors.warning,
                                        ),
                                      ),
                                      const Text(
                                        'adherence',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      if (trainee.currentStreak > 0) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('🔥', style: TextStyle(fontSize: 12)),
                                            const SizedBox(width: 2),
                                            Text(
                                              '${trainee.currentStreak}d',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Floating Invite CTA
                if (!state.isBulkMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocProvider.value(
                            value: context.read<TraineesBloc>(),
                            child: const InviteTraineeDialog(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text(
                        'Invite Trainee',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                // Bulk actions bottom bar
                if (state.isBulkMode)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${state.selectedIds.length} selected',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<TraineesBloc>().add(
                                    const ToggleBulkModeEvent(false),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _bulkActionButton(
                                  'Assign Workout',
                                  Icons.fitness_center,
                                  AppColors.primary,
                                ),
                                const SizedBox(width: 12),
                                _bulkActionButton(
                                  'Assign Nutrition',
                                  Icons.restaurant,
                                  AppColors.success,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'Sort Trainees',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
            _sortTile(ctx, 'Name A–Z', TraineeSortField.name, ascending: true),
            _sortTile(ctx, 'Name Z–A', TraineeSortField.name, ascending: false),
            _sortTile(ctx, 'Highest Adherence', TraineeSortField.adherence, ascending: false),
            _sortTile(ctx, 'Lowest Adherence', TraineeSortField.adherence, ascending: true),
            _sortTile(ctx, 'Longest Streak', TraineeSortField.streak, ascending: false),
            _sortTile(ctx, 'Shortest Streak', TraineeSortField.streak, ascending: true),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _sortTile(BuildContext ctx, String label, TraineeSortField field, {required bool ascending}) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 15)),
      onTap: () {
        ctx.read<TraineesBloc>().add(SortTraineesEvent(field: field, ascending: ascending));
        Navigator.pop(ctx);
      },
    );
  }

  // Extracted Badge widget for cleaner code
  Widget _buildAlertBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String filterValue,
    TraineesLoaded state,
  ) {
    final isActive = state.activeFilter == filterValue;
    return GestureDetector(
      onTap: () {
        context.read<TraineesBloc>().add(
          FilterTraineesEvent(filter: filterValue),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _bulkActionButton(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}