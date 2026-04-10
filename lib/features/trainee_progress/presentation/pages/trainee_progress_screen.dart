import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/trainee_progress_bloc.dart';
import '../bloc/trainee_progress_event.dart';
import '../bloc/trainee_progress_state.dart';

class TraineeProgressScreen extends StatelessWidget {
  const TraineeProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 20,
        title: const Text(
          'guider.',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: AppColors.textPrimary),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: BlocConsumer<TraineeProgressBloc, TraineeProgressState>(
        listener: (context, state) {
          if (state is TraineeProgressActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is TraineeProgressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is TraineeProgressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final measurements = state is TraineeProgressLoaded ? state.measurements : [];
          final pictures = state is TraineeProgressLoaded ? state.pictures : [];

          // Sort measurements by date descending to get the latest
          final sortedMeasurements = measurements.toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          final latestWeight = sortedMeasurements.isNotEmpty
              ? sortedMeasurements.first.weight?.toStringAsFixed(1) ?? '--'
              : '--';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const SizedBox(height: 8),
          // Header + tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'My Progress',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Track your fitness journey',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _SmallTab(label: 'Week', active: false),
                    _SmallTab(label: 'Month', active: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Connect device card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.watch_outlined,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect Apple Watch',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sync workouts & health data',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Connect',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2x2 stats grid
          Row(
            children: [
              Expanded(
                child: _BigStatCard(
                  title: 'Current Weight',
                  value: '$latestWeight kg',
                  subtitle: 'Latest logged',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BigStatCard(
                  title: 'Workout Rate',
                  value: '80%',
                  subtitle: '4/5 this week',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _BigStatCard(
                  title: 'Nutrition',
                  value: '80%',
                  subtitle: '8-day streak',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BigStatCard(
                  title: 'Workout Streak',
                  value: '7 days',
                  subtitle: 'Best: 12',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weight goal progress
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weight Goal Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '46% there',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    value: 0.46,
                    minHeight: 8,
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:  [
                    Text(
                      'Start: -- kg',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Now: $latestWeight kg',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Goal: 72 kg',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showLogWeightDialog(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '+ Log Weight',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showLogMeasurementsDialog(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '+ Log Measurements',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Charts & Trends header (weight tab selected)
          const Text(
            'Charts & Trends',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _SmallTab(label: 'Weight', active: true),
                _SmallTab(label: 'Calories', active: false),
                _SmallTab(label: 'Macros', active: false),
                _SmallTab(label: 'Body', active: false),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Weight trend chart placeholder
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'Weight Trend Chart',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Progress photos
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:  [
                    Text(
                      'Progress Photos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAddProgressPictureDialog(context),
                      child: const Text(
                        '+ Upload',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                pictures.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No photos yet',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                          pictures.length > 4 ? 4 : pictures.length,
                          (index) => Container(
                            width: (MediaQuery.of(context).size.width - 20 * 2 - 10) /
                                2.4,
                            height: 90,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                              image: pictures[index].frontPictureUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(pictures[index].frontPictureUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: pictures[index].frontPictureUrl == null
                                ? const Center(
                                    child: Icon(Icons.camera_alt_outlined,
                                        color: AppColors.textMuted),
                                  )
                                : null,
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Weekly Comparison table (simplified)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Comparison',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _weeklyRow('Workouts', '4/5', '5/5', '+20%'),
                _weeklyRow('Avg Calories', '2,057', '2,085', '-1%'),
                _weeklyRow('Protein Avg', '138g', '132g', '+5%'),
                _weeklyRow('Weight', '74.5 kg', '75.0 kg', '-0.7%'),
                _weeklyRow('Water Avg', '3.2 L', '2.8 L', '+7%'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Coach feedback + reflection (condensed)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coach Feedback',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _feedbackCard(
                  'Amazing consistency this week! Your protein intake is much better. Keep pushing on lower body days.',
                ),
                const SizedBox(height: 8),
                _feedbackCard(
                  'Try adding 5 min mobility work after leg days. Your recovery will improve significantly.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Weekly Reflection',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'How do you feel about your progress this week?\nWhat will you focus on next?',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                "You're doing great, Sarah!",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
          );})
    );
  }

  Widget _weeklyRow(String metric, String thisWeek, String lastWeek, String change) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            metric,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Row(
            children: [
              Text(
                thisWeek,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                lastWeek,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: change.startsWith('-')
                      ? AppColors.error
                      : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feedbackCard(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star_border,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogWeightDialog(BuildContext context) {
    final weightController = TextEditingController();
    final bloc = context.read<TraineeProgressBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Weight'),
        content: TextField(
          controller: weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'e.g. 75.0',
            suffixText: 'kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text.trim());
              if (weight != null) {
                final today = DateTime.now();
                final date =
                    '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
                bloc.add(AddMeasurement({'weight': weight, 'date': date}));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogMeasurementsDialog(BuildContext context) {
    final weightCtrl = TextEditingController();
    final bodyFatCtrl = TextEditingController();
    final muscleMassCtrl = TextEditingController();
    final chestCtrl = TextEditingController();
    final waistCtrl = TextEditingController();
    final armsCtrl = TextEditingController();
    final hipsCtrl = TextEditingController();
    final thighsCtrl = TextEditingController();
    final bloc = context.read<TraineeProgressBloc>();

    Widget field(TextEditingController ctrl, String label, String suffix) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextField(
            controller: ctrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: label,
              suffixText: suffix,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
        );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Measurements'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              field(weightCtrl, 'Weight', 'kg'),
              field(bodyFatCtrl, 'Body Fat %', '%'),
              field(muscleMassCtrl, 'Muscle Mass', 'kg'),
              field(chestCtrl, 'Chest', 'cm'),
              field(waistCtrl, 'Waist', 'cm'),
              field(armsCtrl, 'Arms', 'cm'),
              field(hipsCtrl, 'Hips', 'cm'),
              field(thighsCtrl, 'Thighs', 'cm'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              double? parse(TextEditingController c) =>
                  double.tryParse(c.text.trim());
              final today = DateTime.now();
              final date =
                  '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
              final data = <String, dynamic>{'date': date};
              if (parse(weightCtrl) != null) data['weight'] = parse(weightCtrl);
              if (parse(bodyFatCtrl) != null) data['bodyFatPercentage'] = parse(bodyFatCtrl);
              if (parse(muscleMassCtrl) != null) data['muscleMass'] = parse(muscleMassCtrl);
              if (parse(chestCtrl) != null) data['chest'] = parse(chestCtrl);
              if (parse(waistCtrl) != null) data['waist'] = parse(waistCtrl);
              if (parse(armsCtrl) != null) data['arms'] = parse(armsCtrl);
              if (parse(hipsCtrl) != null) data['hips'] = parse(hipsCtrl);
              if (parse(thighsCtrl) != null) data['thighs'] = parse(thighsCtrl);

              if (data.length > 1) {
                bloc.add(AddMeasurement(data));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddProgressPictureDialog(BuildContext context) {
    final frontUrlCtrl = TextEditingController();
    final sideUrlCtrl = TextEditingController();
    final backUrlCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final bloc = context.read<TraineeProgressBloc>();

    Widget field(TextEditingController ctrl, String label, {int maxLines = 1}) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            decoration: InputDecoration(
              labelText: label,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
        );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Progress Photo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              field(frontUrlCtrl, 'Front Photo URL'),
              field(sideUrlCtrl, 'Side Photo URL'),
              field(backUrlCtrl, 'Back Photo URL'),
              field(notesCtrl, 'Notes (optional)', maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final today = DateTime.now();
              final date =
                  '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
              final data = <String, dynamic>{'date': date};
              if (frontUrlCtrl.text.trim().isNotEmpty) data['frontPictureUrl'] = frontUrlCtrl.text.trim();
              if (sideUrlCtrl.text.trim().isNotEmpty) data['sidePictureUrl'] = sideUrlCtrl.text.trim();
              if (backUrlCtrl.text.trim().isNotEmpty) data['backPictureUrl'] = backUrlCtrl.text.trim();
              if (notesCtrl.text.trim().isNotEmpty) data['notes'] = notesCtrl.text.trim();
              bloc.add(AddProgressPicture(data));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _BigStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallTab extends StatelessWidget {
  final String label;
  final bool active;

  const _SmallTab({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
