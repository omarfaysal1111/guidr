import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/trainee_progress_bloc.dart';
import '../bloc/trainee_progress_event.dart';
import '../bloc/trainee_progress_state.dart';

class TraineeProgressScreen extends StatefulWidget {
  const TraineeProgressScreen({super.key});

  @override
  State<TraineeProgressScreen> createState() => _TraineeProgressScreenState();
}

class _TraineeProgressScreenState extends State<TraineeProgressScreen> {
  String _timeRange = 'month'; // 'week' | 'month'
  String _activeChart = 'weight'; // 'weight' | 'calories' | 'macros' | 'body'
  bool _photosExpanded = false;
  bool _inbodyExpanded = false;

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
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is TraineeProgressLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final measurements =
              state is TraineeProgressLoaded ? state.measurements : [];
          final pictures =
              state is TraineeProgressLoaded ? state.pictures : [];

          // Sort measurements by date descending to get the latest
          final sortedMeasurements = measurements.toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          final latestWeight = sortedMeasurements.isNotEmpty
              ? sortedMeasurements.first.weight?.toStringAsFixed(1) ?? '--'
              : '--';

          // Start weight: oldest measurement
          final startWeight = sortedMeasurements.isNotEmpty
              ? sortedMeasurements.last.weight?.toStringAsFixed(1) ?? '--'
              : '--';

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const SizedBox(height: 8),

              // ── Header + Week/Month tabs ──────────────────────────────
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
                        GestureDetector(
                          onTap: () => setState(() => _timeRange = 'week'),
                          child: _SmallTab(
                              label: 'Week', active: _timeRange == 'week'),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _timeRange = 'month'),
                          child: _SmallTab(
                              label: 'Month', active: _timeRange == 'month'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Connect device card ───────────────────────────────────
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

              // ── 2x2 stats grid ────────────────────────────────────────
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

              // ── Weight Goal Progress card ─────────────────────────────
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
                      children: [
                        Text(
                          'Start: $startWeight kg',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Now: $latestWeight kg',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Text(
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              side:
                                  const BorderSide(color: AppColors.primary),
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
                            onPressed: () =>
                                _showLogMeasurementsDialog(context),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              side:
                                  const BorderSide(color: AppColors.primary),
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

              // ── Charts & Trends ───────────────────────────────────────
              const Text(
                'Charts & Trends',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Chart type tab row
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _activeChart = 'weight'),
                      child: _SmallTab(
                          label: 'Weight',
                          active: _activeChart == 'weight'),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _activeChart = 'calories'),
                      child: _SmallTab(
                          label: 'Calories',
                          active: _activeChart == 'calories'),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _activeChart = 'macros'),
                      child: _SmallTab(
                          label: 'Macros',
                          active: _activeChart == 'macros'),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _activeChart = 'body'),
                      child: _SmallTab(
                          label: 'Body', active: _activeChart == 'body'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Weight trend chart
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Weight (kg)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _timeRange == 'week' ? '74.5 kg now' : '74.5 kg now',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: CustomPaint(
                        painter: _WeightChartPainter(
                          data: _timeRange == 'week'
                              ? [74.8, 74.6, 74.7, 74.5, 74.5, 74.3, 74.5]
                              : [76.2, 75.8, 75.5, 75.2, 75.0, 74.8, 74.5],
                          labels: _timeRange == 'week'
                              ? [
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                  'Sun'
                                ]
                              : ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'Now'],
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Body Measurements table ───────────────────────────────
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
                      'Body Measurements',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Table header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: const [
                          Expanded(
                              flex: 3,
                              child: Text('Part',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary))),
                          Expanded(
                              flex: 2,
                              child: Text('This',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary))),
                          Expanded(
                              flex: 2,
                              child: Text('Prev',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary))),
                          Expanded(
                              flex: 2,
                              child: Text('Start',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary))),
                          Expanded(
                              flex: 2,
                              child: Text('Delta',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary))),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 4),
                    _measurementRow(
                        'Waist', '79 cm', '82 cm', '85 cm', '-3cm', false),
                    _measurementRow(
                        'Chest', '94 cm', '95 cm', '96 cm', '-1cm', false),
                    _measurementRow(
                        'Arms', '33 cm', '32 cm', '31 cm', '+1cm', true),
                    _measurementRow(
                        'Hips', '96 cm', '98 cm', '100 cm', '-2cm', false),
                    _measurementRow(
                        'Thighs', '56 cm', '57 cm', '58 cm', '-1cm', false),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Progress Photos ───────────────────────────────────────
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
                      children: [
                        const Text(
                          'Progress Photos',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              _showAddProgressPictureDialog(context),
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
                        ? GestureDetector(
                            onTap: () =>
                                _showAddProgressPictureDialog(context),
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 28),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add_a_photo_outlined,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Upload your first progress photo',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Track your visual transformation over time',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(
                              pictures.length > 4 ? 4 : pictures.length,
                              (index) => Container(
                                width: (MediaQuery.of(context).size.width -
                                        20 * 2 -
                                        10) /
                                    2.4,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                  image: pictures[index].frontPictureUrl !=
                                          null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              pictures[index].frontPictureUrl!),
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
              const SizedBox(height: 20),

              // ── InBody Reports (collapsible) ──────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    // Header row
                    GestureDetector(
                      onTap: () =>
                          setState(() => _inbodyExpanded = !_inbodyExpanded),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'InBody Reports',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            AnimatedRotation(
                              turns: _inbodyExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Expanded content
                    AnimatedCrossFade(
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        child: Column(
                          children: [
                            _inbodyReportRow(
                              date: 'Feb 15, 2025',
                              label: 'InBody Full Report',
                              type: 'PDF',
                              iconColor: const Color(0xFF7C3AED),
                              bgColor: const Color(0xFFF5F3FF),
                              icon: Icons.picture_as_pdf_outlined,
                            ),
                            const SizedBox(height: 10),
                            _inbodyReportRow(
                              date: 'Feb 1, 2025',
                              label: 'InBody Scan Result',
                              type: 'Image',
                              iconColor: const Color(0xFF2563EB),
                              bgColor: const Color(0xFFEFF6FF),
                              icon: Icons.image_outlined,
                            ),
                            const SizedBox(height: 10),
                            _inbodyReportRow(
                              date: 'Jan 15, 2025',
                              label: 'InBody Baseline',
                              type: 'PDF',
                              iconColor: const Color(0xFF059669),
                              bgColor: const Color(0xFFECFDF5),
                              icon: Icons.picture_as_pdf_outlined,
                            ),
                            const SizedBox(height: 10),
                            _inbodyReportRow(
                              date: 'Jan 1, 2025',
                              label: 'Initial InBody Scan',
                              type: 'Image',
                              iconColor: const Color(0xFFD97706),
                              bgColor: const Color(0xFFFFFBEB),
                              icon: Icons.image_outlined,
                            ),
                          ],
                        ),
                      ),
                      crossFadeState: _inbodyExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Weekly Comparison table ───────────────────────────────
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

              // ── Coach feedback + reflection ───────────────────────────
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
          );
        },
      ),
    );
  }

  // ── Helper: measurement table row ──────────────────────────────────────────
  Widget _measurementRow(String part, String current, String prev, String start,
      String delta, bool isIncrease) {
    // For muscle (arms), increase is green. For fat areas, decrease is green.
    // The spec says all delta entries shown are green, so always use green.
    final arrow = delta.startsWith('+') ? '↑' : '↓';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              part,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              current,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              prev,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              start,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$arrow $delta',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper: InBody report row ───────────────────────────────────────────────
  Widget _inbodyReportRow({
    required String date,
    required String label,
    required String type,
    required Color iconColor,
    required Color bgColor,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            type,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
        ),
      ],
    );
  }

  // ── Helper: weekly comparison row ──────────────────────────────────────────
  Widget _weeklyRow(
      String metric, String thisWeek, String lastWeek, String change) {
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

  // ── Helper: feedback card ───────────────────────────────────────────────────
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
          const Icon(Icons.star_border, size: 18, color: AppColors.primary),
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

  // ── Dialogs ─────────────────────────────────────────────────────────────────

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
              if (parse(bodyFatCtrl) != null) {
                data['bodyFatPercentage'] = parse(bodyFatCtrl);
              }
              if (parse(muscleMassCtrl) != null) {
                data['muscleMass'] = parse(muscleMassCtrl);
              }
              if (parse(chestCtrl) != null) data['chest'] = parse(chestCtrl);
              if (parse(waistCtrl) != null) data['waist'] = parse(waistCtrl);
              if (parse(armsCtrl) != null) data['arms'] = parse(armsCtrl);
              if (parse(hipsCtrl) != null) data['hips'] = parse(hipsCtrl);
              if (parse(thighsCtrl) != null) {
                data['thighs'] = parse(thighsCtrl);
              }

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

    Widget field(TextEditingController ctrl, String label,
            {int maxLines = 1}) =>
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
              if (frontUrlCtrl.text.trim().isNotEmpty) {
                data['frontPictureUrl'] = frontUrlCtrl.text.trim();
              }
              if (sideUrlCtrl.text.trim().isNotEmpty) {
                data['sidePictureUrl'] = sideUrlCtrl.text.trim();
              }
              if (backUrlCtrl.text.trim().isNotEmpty) {
                data['backPictureUrl'] = backUrlCtrl.text.trim();
              }
              if (notesCtrl.text.trim().isNotEmpty) {
                data['notes'] = notesCtrl.text.trim();
              }
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

// ── CustomPainter for weight trend chart ──────────────────────────────────────

class _WeightChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  _WeightChartPainter({required this.data, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final double minVal = data.reduce((a, b) => a < b ? a : b) - 0.5;
    final double maxVal = data.reduce((a, b) => a > b ? a : b) + 0.5;
    final double range = maxVal - minVal;
    const double padLeft = 10.0,
        padRight = 10.0,
        padTop = 16.0,
        padBottom = 28.0;
    final double w = size.width - padLeft - padRight;
    final double h = size.height - padTop - padBottom;

    // Normalise x/y
    final List<Offset> pts = [];
    for (int i = 0; i < data.length; i++) {
      final double x = padLeft + (i / (data.length - 1)) * w;
      final double y = padTop + h - ((data[i] - minVal) / range) * h;
      pts.add(Offset(x, y));
    }

    // Draw filled area
    final fillPath = Path();
    fillPath.moveTo(pts.first.dx, size.height - padBottom);
    for (final p in pts) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(pts.last.dx, size.height - padBottom);
    fillPath.close();
    canvas.drawPath(
        fillPath,
        Paint()
          ..color = const Color(0xFF34D399).withOpacity(0.12)
          ..style = PaintingStyle.fill);

    // Draw line
    final linePaint = Paint()
      ..color = const Color(0xFF34D399)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final linePath = Path();
    linePath.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      linePath.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Draw points
    for (final p in pts) {
      canvas.drawCircle(
          p,
          4,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          p,
          4,
          Paint()
            ..color = const Color(0xFF34D399)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    }

    // Draw x-axis labels
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    for (int i = 0; i < labels.length && i < pts.length; i++) {
      textPainter.text = TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)));
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(pts[i].dx - textPainter.width / 2,
              size.height - padBottom + 6));
    }
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) => old.data != data;
}

// ── Reusable stat card ────────────────────────────────────────────────────────

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

// ── Reusable small tab ────────────────────────────────────────────────────────

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
