import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/trainee.dart';

class TraineeProfileScreen extends StatefulWidget {
  final Trainee trainee;
  final VoidCallback onBackPressed;

  const TraineeProfileScreen({
    super.key,
    required this.trainee,
    required this.onBackPressed,
  });

  @override
  State<TraineeProfileScreen> createState() => _TraineeProfileScreenState();
}

class _TraineeProfileScreenState extends State<TraineeProfileScreen> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = widget.trainee;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackPressed,
        ),
        title: Text(t.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show settings/archive actions
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Profile
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    t.avatar,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${t.goal} · ${t.level}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Joined ${t.joined}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTab(0, 'Overview'),
                _buildTab(1, 'Plans'),
                _buildTab(2, 'Progress'),
                _buildTab(3, 'Notes'),
              ],
            ),
          ),

          const Divider(),

          // Content
          Expanded(child: _buildContent(t)),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isActive = _activeTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Trainee t) {
    switch (_activeTabIndex) {
      case 0:
        return _buildOverview(t);
      case 1:
        return const Center(child: Text('Plans Content'));
      case 2:
        return const Center(child: Text('Progress Content'));
      case 3:
        return const Center(child: Text('Notes Content'));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverview(Trainee t) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Adherence Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Adherence',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${t.adherence}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color:
                      t.adherence >= 80 ? AppColors.success : AppColors.warning,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Recent Activity Placeholder
        const Text(
          'Recent Activity',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success, size: 20),
              SizedBox(width: 12),
              Text('Completed today\'s workout'),
            ],
          ),
        ),
      ],
    );
  }
}
