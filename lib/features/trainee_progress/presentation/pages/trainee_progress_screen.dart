// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:guidr/core/widgets/notification_inbox_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../trainees/domain/entities/inbody_report.dart';
import '../../../trainees/presentation/utils/trainee_media_url.dart';
import '../../../trainees/presentation/widgets/inbody_report_file_preview.dart';
import '../bloc/trainee_progress_bloc.dart';
import '../bloc/trainee_progress_event.dart';
import '../bloc/trainee_progress_state.dart';

// ── Badge model (local, demo data) ────────────────────────────────────────────

class _Badge {
  final String icon;
  final String name;
  final String desc;
  final String criteria;
  final bool earned;
  final String? date;
  final String? tier; // 'gold' | 'silver'
  final double? progress;
  final double? total;

  const _Badge({
    required this.icon,
    required this.name,
    required this.desc,
    required this.criteria,
    required this.earned,
    this.date,
    this.tier,
    this.progress,
    this.total,
  });
}

const _badges = [
  _Badge(icon: 'fire',    name: 'Streak Master',    desc: '7-day workout streak',     criteria: 'Complete 7 workouts in a row',              earned: true,  date: 'Feb 14', tier: 'gold'),
  _Badge(icon: 'dumbbell',name: 'Iron Will',         desc: 'Complete 40+ workouts',    criteria: 'Log 40 total workouts',                     earned: true,  date: 'Feb 10', tier: 'gold'),
  _Badge(icon: 'apple',   name: 'Clean Eater',       desc: '14-day nutrition streak',  criteria: 'Log all meals for 14 days',                 earned: true,  date: 'Feb 8',  tier: 'silver'),
  _Badge(icon: 'trend',   name: 'Downward Trend',    desc: 'Lose 1.5+ kg',             criteria: 'Reach 1.5 kg weight loss',                  earned: true,  date: 'Feb 5',  tier: 'silver'),
  _Badge(icon: 'camera',  name: 'Progress Tracker',  desc: 'Upload 5 progress photos', criteria: 'Take 5 progress photos',                    earned: false, progress: 3,  total: 5),
  _Badge(icon: 'target',  name: 'Goal Crusher',      desc: 'Reach target weight',      criteria: 'Hit your goal weight of 72 kg',             earned: false, progress: 42, total: 100),
  _Badge(icon: 'star',    name: 'Perfect Week',      desc: '100% adherence',           criteria: 'Complete all workouts + log all meals',     earned: false, progress: 80, total: 100),
  _Badge(icon: 'drop',    name: 'Hydro Hero',        desc: '8 glasses × 14 days',      criteria: 'Drink 8 glasses of water for 14 days',      earned: false, progress: 8,  total: 14),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class TraineeProgressScreen extends StatefulWidget {
  const TraineeProgressScreen({super.key});

  @override
  State<TraineeProgressScreen> createState() => _TraineeProgressScreenState();
}

class _TraineeProgressScreenState extends State<TraineeProgressScreen> {
  String _timeRange    = 'month'; // 'week' | 'month'
  String _activeChart  = 'weight'; // 'weight' | 'calories' | 'macros' | 'body'
  bool   _photosExpanded  = false;
  bool   _watchConnected  = false;
  bool   _showWatchAuth   = false;
  int?   _badgeDetailId;

  // ── Static demo data ─────────────────────────────────────────────────────────

  static const double _startWeight   = 76.2;
  static const double _currentWeight = 74.5;
  static const double _goalWeight    = 72.0;

  final _weightWeek  = const [74.8, 74.6, 74.7, 74.5, 74.5, 74.3, 74.5];
  final _weightMonth = const [76.2, 75.8, 75.5, 75.2, 75.0, 74.8, 74.5];
  final _weightWeekLabels  = const ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
  final _weightMonthLabels = const ['W1','W2','W3','W4','W5','W6','Now'];

  final _calorieData   = const [2050, 2120, 1980, 2200, 2100, 2050, 1900];
  static const int _calTarget = 2100;
  final _calLabels     = const ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

  final _macros = const [
    {'name': 'Protein', 'pct': 82, 'target': '150g/day', 'color': Color(0xFF8B5CF6)},
    {'name': 'Carbs',   'pct': 78, 'target': '230g/day', 'color': Color(0xFFF59E0B)},
    {'name': 'Fat',     'pct': 85, 'target': '70g/day',  'color': Color(0xFFEF4444)},
  ];

  // Body measurements (for "Body" chart tab)
  final _bodyMeasurements = const [
    {'part': 'Waist',  'current': 79, 'prev': 82, 'start': 85, 'unit': 'cm', 'good': true},
    {'part': 'Chest',  'current': 94, 'prev': 95, 'start': 96, 'unit': 'cm', 'good': false},
    {'part': 'Arms',   'current': 33, 'prev': 32, 'start': 31, 'unit': 'cm', 'good': true},
    {'part': 'Hips',   'current': 96, 'prev': 98, 'start': 100,'unit': 'cm', 'good': true},
    {'part': 'Thighs', 'current': 56, 'prev': 57, 'start': 58, 'unit': 'cm', 'good': true},
  ];

  // Photo sets
  static const _photoSets = [
    {'date': 'Feb 15', 'week': 'Week 3'},
    {'date': 'Feb 8',  'week': 'Week 2'},
    {'date': 'Feb 1',  'week': 'Week 1'},
    {'date': 'Jan 25', 'week': 'Week 0'},
  ];

  // Weekly comparison
  static const _weekComparison = [
    {'metric': 'Workouts',    'thisWeek': '4/5',     'lastWeek': '5/5',     'up': false, 'pct': 20},
    {'metric': 'Avg Calories','thisWeek': '2,057',   'lastWeek': '2,085',   'up': false, 'pct': 1},
    {'metric': 'Protein Avg', 'thisWeek': '138g',    'lastWeek': '132g',    'up': true,  'pct': 5},
    {'metric': 'Weight',      'thisWeek': '74.5 kg', 'lastWeek': '75.0 kg', 'up': true,  'pct': 1},
    {'metric': 'Water Avg',   'thisWeek': '6.2 L',   'lastWeek': '5.8 L',   'up': true,  'pct': 7},
  ];

  // Coach feedback
  static const _coachComments = [
    {'text': 'Amazing consistency this week! Your protein intake is much better. Keep pushing on lower body days.', 'type': 'praise', 'date': 'Feb 14'},
    {'text': 'Try adding 5 min mobility work after leg days. Your recovery will improve significantly.', 'type': 'tip', 'date': 'Feb 10'},
  ];

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final notifItems = demoTraineeInboxNotifications();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 20,
        title: const Text(
          'guider.',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        actions: [
          NotificationInboxButton(
            items: notifItems,
            badgeCount: notifItems.isNotEmpty ? notifItems.length : null,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is TraineeProgressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          if (state is TraineeProgressLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final measurements = state is TraineeProgressLoaded ? state.measurements : [];
          final pictures     = state is TraineeProgressLoaded ? state.pictures : [];
          final inbodyReports = state is TraineeProgressLoaded ? state.inbodyReports : <InBodyReport>[];

          final sortedMeasurements = measurements.toList()
            ..sort((a, b) => b.date.compareTo(a.date));
          final latestWeight = sortedMeasurements.isNotEmpty
              ? sortedMeasurements.first.weight?.toStringAsFixed(1) ?? '--'
              : '--';
          final startWeight = sortedMeasurements.isNotEmpty
              ? sortedMeasurements.last.weight?.toStringAsFixed(1) ?? '--'
              : '--';

          final isUploading =
              state is TraineeProgressLoaded && state.isUploading;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildAppleWatchSection(),
                  const SizedBox(height: 12),
                  _buildKpiGrid(latestWeight),
                  const SizedBox(height: 12),
                  _buildWeightGoalCard(startWeight, latestWeight, context),
                  const SizedBox(height: 24),
                  _buildChartsSection(),
                  const SizedBox(height: 16),
                  _buildProgressPhotosSection(pictures, isUploading: isUploading),
                  const SizedBox(height: 16),
                  _buildInbodySection(inbodyReports, isUploading: isUploading),
                  const SizedBox(height: 16),
                  _buildAchievementsSection(),
                  const SizedBox(height: 16),
                  _buildWeeklyComparisonSection(),
                  const SizedBox(height: 16),
                  _buildCoachFeedbackSection(),
                  const SizedBox(height: 16),
                  _buildEncouragementBanner(),
                ],
              ),
              if (_showWatchAuth) _buildWatchAuthModal(),
              if (isUploading)
                const _UploadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'My Progress',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              SizedBox(height: 2),
              Text(
                'Track your fitness journey',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              _buildTimeTab('week'),
              _buildTimeTab('month'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeTab(String range) {
    final active = _timeRange == range;
    return GestureDetector(
      onTap: () => setState(() => _timeRange = range),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          range[0].toUpperCase() + range.substring(1),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  // ── Apple Watch ───────────────────────────────────────────────────────────────

  Widget _buildAppleWatchSection() {
    if (!_watchConnected) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.watch_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Connect Apple Watch',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  SizedBox(height: 2),
                  Text('Sync workouts & health data',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _showWatchAuth = true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Connect',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    // Connected state — 3 circular metrics
    return Container(
      padding: const EdgeInsets.all(14),
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
              const Icon(Icons.watch, size: 14, color: AppColors.success),
              const SizedBox(width: 6),
              const Text('Apple Watch Connected',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _watchConnected = false),
                child: const Text('Disconnect',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildWatchMetric('Heart Rate', '72', 'BPM',   72 / 100,  const Color(0xFFEF4444))),
              Expanded(child: _buildWatchMetric('Steps',      '8,420', '/ 10,000', 8420 / 10000, const Color(0xFF3B82F6))),
              Expanded(child: _buildWatchMetric('Sleep',      '7.2h', '/ 8h', 7.2 / 8,   const Color(0xFF8B5CF6))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWatchMetric(String label, String value, String unit, double fraction, Color color) {
    final pct = (fraction * 100).clamp(0.0, 100.0);
    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: CustomPaint(
            painter: _CircularMetricPainter(fraction: fraction, color: color),
            child: Center(
              child: Text(
                '${pct.round()}%',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text('$value $unit', style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildWatchAuthModal() {
    return GestureDetector(
      onTap: () => setState(() => _showWatchAuth = false),
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // prevent dismiss on card tap
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 30)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Connect Apple Watch',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('Allow access to the following health data:',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ...['Heart Rate', 'Steps', 'Sleep Hours'].map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Text(p, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _showWatchAuth = false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Deny', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() { _watchConnected = true; _showWatchAuth = false; }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Allow', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── KPI Grid ──────────────────────────────────────────────────────────────────

  Widget _buildKpiGrid(String latestWeight) {
    final kpis = [
      {
        'label': 'Current Weight',
        'value': '$latestWeight kg',
        'sub': '↓ ${(_startWeight - _currentWeight).toStringAsFixed(1)} kg total',
        'color': AppColors.primary,
        'icon': Icons.trending_down_rounded,
      },
      {
        'label': 'Workout Rate',
        'value': '80%',
        'sub': '4/5 this week',
        'color': AppColors.success,
        'icon': Icons.fitness_center_rounded,
      },
      {
        'label': 'Nutrition',
        'value': '80%',
        'sub': '8-day streak',
        'color': AppColors.warning,
        'icon': Icons.restaurant_rounded,
      },
      {
        'label': 'Workout Streak',
        'value': '7 days',
        'sub': 'Best: 12',
        'color': const Color(0xFFF97316),
        'icon': Icons.local_fire_department_rounded,
      },
    ];

    return Column(
      children: [
        Row(children: [
          Expanded(child: _buildKpiCard(kpis[0])),
          const SizedBox(width: 8),
          Expanded(child: _buildKpiCard(kpis[1])),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _buildKpiCard(kpis[2])),
          const SizedBox(width: 8),
          Expanded(child: _buildKpiCard(kpis[3])),
        ]),
      ],
    );
  }

  Widget _buildKpiCard(Map<String, dynamic> kpi) {
    final color = kpi['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(kpi['icon'] as IconData, size: 13, color: color),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      kpi['label'] as String,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                kpi['value'] as String,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5),
              ),
              const SizedBox(height: 2),
              Text(
                kpi['sub'] as String,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Weight Goal ───────────────────────────────────────────────────────────────

  Widget _buildWeightGoalCard(String startWeight, String latestWeight, BuildContext context) {
    final goalPct = ((_startWeight - _currentWeight) / (_startWeight - _goalWeight) * 100).clamp(0.0, 100.0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weight Goal Progress',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text('${goalPct.round()}% there',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: goalPct / 100,
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Start: $startWeight kg',
                  style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
              Text('Now: $latestWeight kg',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const Text('Goal: 72 kg',
                  style: TextStyle(fontSize: 9, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildLogButton(
                  label: '+ Log Weight',
                  color: AppColors.primary,
                  onTap: () => _showLogWeightDialog(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLogButton(
                  label: '+ Log Measurements',
                  color: AppColors.success,
                  onTap: () => _showLogMeasurementsDialog(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogButton({required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ),
    );
  }

  // ── Charts ────────────────────────────────────────────────────────────────────

  Widget _buildChartsSection() {
    const tabs = [
      {'key': 'weight',   'label': 'Weight',   'icon': Icons.trending_down_rounded},
      {'key': 'calories', 'label': 'Calories', 'icon': Icons.local_fire_department_rounded},
      {'key': 'macros',   'label': 'Macros',   'icon': Icons.donut_small_rounded},
      {'key': 'body',     'label': 'Body',     'icon': Icons.accessibility_new_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bar_chart_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            const Text('Charts & Trends',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 10),

        // Tab row
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: tabs.map((t) {
              final active = _activeChart == t['key'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _activeChart = t['key'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: active
                          ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 1))]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(t['icon'] as IconData,
                            size: 11,
                            color: active ? AppColors.primary : AppColors.textMuted),
                        const SizedBox(width: 3),
                        Text(
                          t['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: active ? AppColors.primary : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // Active chart content
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: KeyedSubtree(
            key: ValueKey(_activeChart),
            child: _buildActiveChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveChart() {
    switch (_activeChart) {
      case 'weight':
        return _buildWeightChart();
      case 'calories':
        return _buildCalorieChart();
      case 'macros':
        return _buildMacrosChart();
      case 'body':
        return _buildBodyTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWeightChart() {
    final data   = _timeRange == 'week' ? _weightWeek   : _weightMonth;
    final labels = _timeRange == 'week' ? _weightWeekLabels : _weightMonthLabels;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weight Trend',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Row(
                children: [
                  _buildLegendDot(AppColors.primary, 'Actual'),
                  const SizedBox(width: 10),
                  _buildLegendDot(AppColors.success, 'Goal', dashed: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: CustomPaint(
              painter: _WeightChartPainter(
                data: List<double>.from(data),
                labels: List<String>.from(labels),
                goalWeight: _goalWeight,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Calories',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Text('Target: $_calTarget cal',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: CustomPaint(
              painter: _BarChartPainter(data: _calorieData, target: _calTarget, labels: _calLabels),
              size: Size.infinite,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avg: ${(_calorieData.reduce((a, b) => a + b) / _calorieData.length).round()} cal',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                '7-day total: ${_calorieData.reduce((a, b) => a + b)} cal',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Macro Adherence This Week',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          ..._macros.asMap().entries.map((e) {
            final m     = e.value;
            final color = m['color'] as Color;
            final pct   = m['pct'] as int;
            final isLast = e.key == _macros.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                          ),
                          const SizedBox(width: 6),
                          Text(m['name'] as String,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ],
                      ),
                      Text('$pct%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: pct >= 80 ? AppColors.success : AppColors.warning,
                          )),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 8,
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: AppColors.surface,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text('Target: ${m['target']}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBodyTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Body Measurements',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ..._bodyMeasurements.asMap().entries.map((e) {
            final m      = e.value;
            final isFirst = e.key == 0;
            final good   = m['good'] as bool;
            final change = (m['current'] as int) - (m['prev'] as int);
            final total  = (m['current'] as int) - (m['start'] as int);
            final changeStr = '${change > 0 ? '+' : ''}$change';
            final totalStr  = '${total > 0 ? '+' : ''}$total';
            final badgeColor = good ? AppColors.success : AppColors.warning;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: isFirst ? null : const Border(top: BorderSide(color: AppColors.surface)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(changeStr,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: badgeColor)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['part'] as String,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text('${m['start']} → ${m['current']} ${m['unit']}',
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${m['current']}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            TextSpan(
                              text: ' ${m['unit']}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Text('Total: $totalStr ${m['unit']}',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: badgeColor)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label, {bool dashed = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 2,
          decoration: BoxDecoration(
            color: dashed ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(1),
            border: dashed ? Border.all(color: color) : null,
          ),
        ),
        const SizedBox(width: 3),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
      ],
    );
  }

  // ── Progress Photos ───────────────────────────────────────────────────────────

  Widget _buildProgressPhotosSection(
    List pictures, {
    bool isUploading = false,
  }) {
    // Merge real server pictures with static demo sets for display
    final realPictures = pictures.cast<dynamic>();
    final totalSets = realPictures.isNotEmpty ? realPictures.length : _photoSets.length;
    final visibleReal = _photosExpanded ? realPictures : realPictures.take(2).toList();
    final visibleDemo = _photosExpanded ? _photoSets : _photoSets.take(2).toList();
    final useReal = realPictures.isNotEmpty;
    final hiddenCount = totalSets - 2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              const Icon(Icons.photo_camera_outlined, size: 14, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              const Text('Progress Photos',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(6)),
                child: Text('$totalSets sets',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: isUploading ? null : () => _showProgressPhotoSheet(context),
                child: Text(
                  '+ Upload',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isUploading ? AppColors.textMuted : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Real photo rows from server
          if (useReal)
            ...visibleReal.asMap().entries.map((e) {
              final pic = e.value;
              final isLast = e.key == visibleReal.length - 1;
              final dateStr = pic.date ?? '';
              final uploadedAt = pic.uploadedAt ?? '';
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(dateStr.isNotEmpty ? dateStr : uploadedAt,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPhotoSlot('Front', pic.frontPictureUrl),
                        const SizedBox(width: 8),
                        _buildPhotoSlot('Side',  pic.sidePictureUrl),
                        const SizedBox(width: 8),
                        _buildPhotoSlot('Back',  pic.backPictureUrl),
                      ],
                    ),
                  ],
                ),
              );
            })
          else
            // Demo placeholder rows
            ...visibleDemo.asMap().entries.map((e) {
              final group  = e.value;
              final isLast = e.key == visibleDemo.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(group['date']!,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                        const SizedBox(width: 4),
                        Text('(${group['week']})',
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPhotoSlot('Front', null),
                        const SizedBox(width: 8),
                        _buildPhotoSlot('Side',  null),
                        const SizedBox(width: 8),
                        _buildPhotoSlot('Back',  null),
                      ],
                    ),
                  ],
                ),
              );
            }),

          // Show more / less
          if (totalSets > 2) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => setState(() => _photosExpanded = !_photosExpanded),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_photosExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      _photosExpanded
                          ? 'Show Less'
                          : 'Show $hiddenCount More Set${hiddenCount > 1 ? 's' : ''}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Add new photo set CTA
          const SizedBox(height: 10),
          GestureDetector(
            onTap: isUploading ? null : () => _showProgressPhotoSheet(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(isUploading ? 0.02 : 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(isUploading ? 0.1 : 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 16,
                      color: isUploading ? AppColors.textMuted : AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Add New Photo Set',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isUploading ? AppColors.textMuted : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlot(String label, String? url) {
    return Expanded(
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          image: url != null && url.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: url == null || url.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_camera_outlined, size: 16, color: AppColors.textMuted),
                  const SizedBox(height: 4),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                ],
              )
            : Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                        fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
      ),
    );
  }

  // ── InBody Reports ────────────────────────────────────────────────────────────

  Widget _buildInbodySection(
    List<InBodyReport> reports, {
    bool isUploading = false,
  }) {
    const purple = Color(0xFF8B5CF6);
    final sorted = reports.toList()
      ..sort((a, b) {
        final da = a.uploadedAt;
        final db = b.uploadedAt;
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 4),
          initiallyExpanded: false,
          title: Row(
            children: [
              const Icon(Icons.analytics_outlined, size: 20, color: purple),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'InBody Reports',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${sorted.length}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              // Upload button inside the title row
              GestureDetector(
                onTap: isUploading ? null : () => _showInBodyUploadSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isUploading
                        ? AppColors.surface
                        : purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isUploading
                          ? AppColors.border
                          : purple.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.upload_file_outlined,
                        size: 12,
                        color: isUploading ? AppColors.textMuted : purple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Upload',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isUploading ? AppColors.textMuted : purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          subtitle: const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'View or upload InBody / body-composition reports.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
          children: [
            if (sorted.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    const Icon(Icons.analytics_outlined, size: 32, color: AppColors.textMuted),
                    const SizedBox(height: 8),
                    const Text(
                      'No InBody reports yet.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: isUploading ? null : () => _showInBodyUploadSheet(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: purple.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: purple.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload_file_outlined, size: 14,
                                color: isUploading ? AppColors.textMuted : purple),
                            const SizedBox(width: 6),
                            Text(
                              'Upload Your First Report',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isUploading ? AppColors.textMuted : purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...sorted.map((r) {
                final uri = resolveTraineeMediaUrl(r.fileUrl);
                final label = r.fileName ??
                    (r.uploadedAt != null
                        ? '${r.uploadedAt!.toLocal()}'.split('.').first
                        : 'Report ${r.id.isNotEmpty ? r.id : uri.path}');
                return Padding(
                  key: ValueKey('trainee-inbody-${r.id}-${r.fileUrl}'),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    backgroundColor: AppColors.surface,
                    collapsedBackgroundColor: AppColors.surface,
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildInbodyFileTypeBadge(r),
                      ],
                    ),
                    subtitle: r.uploadedAt != null
                        ? Text(
                            '${r.uploadedAt!.toLocal()}'.split('.').first,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          )
                        : null,
                    children: [
                      InBodyReportFilePreview(
                        uri: uri,
                        isPdf: r.isPdf,
                        isImage: r.isImage,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildInbodyFileTypeBadge(InBodyReport r) {
    final isPdf = r.isPdf;
    final isImage = r.isImage;
    final label = isPdf ? 'PDF' : isImage ? 'Image' : 'File';
    final Color bg;
    final Color fg;
    if (isPdf) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    } else if (isImage) {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1D4ED8);
    } else {
      bg = AppColors.surface;
      fg = AppColors.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  // ── Milestones & Achievements ─────────────────────────────────────────────────

  Widget _buildAchievementsSection() {
    final earned = _badges.where((b) => b.earned).toList();
    final locked = _badges.where((b) => !b.earned).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.warning),
            SizedBox(width: 6),
            Text('Milestones & Achievements',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 10),

        // Earned badges — horizontal scroll
        Text('EARNED (${earned.length})',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
        const SizedBox(height: 8),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: earned.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final b = earned[i];
              return _buildEarnedBadgeCard(b);
            },
          ),
        ),

        const SizedBox(height: 16),

        // In-progress badges — vertical list
        Text('IN PROGRESS (${locked.length})',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
        const SizedBox(height: 8),
        ...locked.map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildLockedBadgeRow(b),
        )),
      ],
    );
  }

  Widget _buildEarnedBadgeCard(_Badge b) {
    final isGold   = b.tier == 'gold';
    final isSilver = b.tier == 'silver';
    final bgGrad   = isGold
        ? const LinearGradient(colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : isSilver
            ? const LinearGradient(colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)], begin: Alignment.topLeft, end: Alignment.bottomRight)
            : null;
    final borderColor = isGold
        ? const Color(0xFFFBBF24).withOpacity(0.4)
        : isSilver
            ? const Color(0xFF94A3B8).withOpacity(0.3)
            : AppColors.border;

    return GestureDetector(
      onTap: () => setState(() => _badgeDetailId = _badgeDetailId == b.hashCode ? null : b.hashCode),
      child: Container(
        width: 88,
        padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
        decoration: BoxDecoration(
          gradient: bgGrad,
          color: bgGrad == null ? Colors.white : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BadgeIcon(type: b.icon, size: 36, earned: true, tier: b.tier),
            const SizedBox(height: 6),
            Text(b.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2)),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isGold) const Icon(Icons.star_rounded, size: 8, color: Color(0xFFF59E0B)),
                Text(
                  b.date ?? '',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: isGold ? const Color(0xFFD97706) : isSilver ? AppColors.textMuted : AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedBadgeRow(_Badge b) {
    final progress = b.progress ?? 0;
    final total    = b.total ?? 1;
    final fraction = (progress / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _BadgeIcon(type: b.icon, size: 40, earned: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(b.desc,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      value: fraction,
                      backgroundColor: AppColors.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${progress.toInt()}/${total.toInt()}',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ── Weekly Comparison ─────────────────────────────────────────────────────────

  Widget _buildWeeklyComparisonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.swap_vert_rounded, size: 16, color: Color(0xFF8B5CF6)),
            SizedBox(width: 6),
            Text('Weekly Comparison',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: const [
                    Expanded(flex: 2, child: Text('Metric',      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted))),
                    Expanded(flex: 1, child: Text('This Week',   style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted), textAlign: TextAlign.center)),
                    Expanded(flex: 1, child: Text('Last Week',   style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted), textAlign: TextAlign.center)),
                    SizedBox(width: 44, child: Text('Change',    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted), textAlign: TextAlign.right)),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.surface),

              ..._weekComparison.asMap().entries.map((e) {
                final row   = e.value;
                final isLast = e.key == _weekComparison.length - 1;
                final up    = row['up'] as bool;
                final pct   = row['pct'] as int;
                final chipColor = up ? AppColors.success : AppColors.warning;

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.surface)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2,
                        child: Text(row['metric'] as String,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                      Expanded(flex: 1,
                        child: Text(row['thisWeek'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                      Expanded(flex: 1,
                        child: Text(row['lastWeek'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                      SizedBox(
                        width: 44,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: chipColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${up ? '↑' : '↓'} $pct%',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: chipColor),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ── Coach Feedback ────────────────────────────────────────────────────────────

  Widget _buildCoachFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.primary),
            SizedBox(width: 6),
            Text('Coach Feedback',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 10),

        ..._coachComments.map((c) {
          final isPraise  = c['type'] == 'praise';
          final color     = isPraise ? AppColors.success : AppColors.primary;
          final bgColor   = isPraise ? AppColors.success.withOpacity(0.06) : AppColors.primary.withOpacity(0.06);
          final borderCol = isPraise ? AppColors.success.withOpacity(0.15) : AppColors.primary.withOpacity(0.15);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isPraise ? Icons.star_rounded : Icons.help_outline_rounded,
                      size: 14,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['text'] as String,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
                        const SizedBox(height: 4),
                        Text('Coach Mike · ${c['date']}',
                            style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // Weekly Reflection
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weekly Reflection',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'How do you feel about your progress this week?\nWhat will you focus on next?',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Encouragement Banner ──────────────────────────────────────────────────────

  Widget _buildEncouragementBanner() {
    final lostKg = (_startWeight - _currentWeight).toStringAsFixed(1);
    final goalPct = ((_startWeight - _currentWeight) / (_startWeight - _goalWeight) * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.workoutGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text("You're doing great, Sarah!",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            'Down $lostKg kg in 6 weeks — $goalPct% to your goal!',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────────

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
          decoration: const InputDecoration(hintText: 'e.g. 75.0', suffixText: 'kg'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text.trim());
              if (weight != null) {
                final today = DateTime.now();
                final date  = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
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
    final weightCtrl      = TextEditingController();
    final bodyFatCtrl     = TextEditingController();
    final muscleMassCtrl  = TextEditingController();
    final chestCtrl       = TextEditingController();
    final waistCtrl       = TextEditingController();
    final armsCtrl        = TextEditingController();
    final hipsCtrl        = TextEditingController();
    final thighsCtrl      = TextEditingController();
    final bloc = context.read<TraineeProgressBloc>();

    Widget field(TextEditingController ctrl, String label, String suffix) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, suffixText: suffix, isDense: true, border: const OutlineInputBorder()),
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
              field(weightCtrl,     'Weight',      'kg'),
              field(bodyFatCtrl,    'Body Fat %',  '%'),
              field(muscleMassCtrl, 'Muscle Mass', 'kg'),
              field(chestCtrl,      'Chest',       'cm'),
              field(waistCtrl,      'Waist',       'cm'),
              field(armsCtrl,       'Arms',        'cm'),
              field(hipsCtrl,       'Hips',        'cm'),
              field(thighsCtrl,     'Thighs',      'cm'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              double? parse(TextEditingController c) => double.tryParse(c.text.trim());
              final today = DateTime.now();
              final date  = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
              final data  = <String, dynamic>{'date': date};
              if (parse(weightCtrl)     != null) data['weight']            = parse(weightCtrl);
              if (parse(bodyFatCtrl)    != null) data['bodyFatPercentage'] = parse(bodyFatCtrl);
              if (parse(muscleMassCtrl) != null) data['muscleMass']        = parse(muscleMassCtrl);
              if (parse(chestCtrl)      != null) data['chest']             = parse(chestCtrl);
              if (parse(waistCtrl)      != null) data['waist']             = parse(waistCtrl);
              if (parse(armsCtrl)       != null) data['arms']              = parse(armsCtrl);
              if (parse(hipsCtrl)       != null) data['hips']              = parse(hipsCtrl);
              if (parse(thighsCtrl)     != null) data['thighs']            = parse(thighsCtrl);
              if (data.length > 1) { bloc.add(AddMeasurement(data)); Navigator.pop(ctx); }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Progress Photo Picker Sheet ───────────────────────────────────────────────

  void _showProgressPhotoSheet(BuildContext context) {
    final bloc = context.read<TraineeProgressBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ProgressPhotoSheet(
        onUpload: (frontPath, sidePath, backPath, notes) {
          bloc.add(UploadProgressPhoto(
            frontPath: frontPath,
            sidePath: sidePath,
            backPath: backPath,
            notes: notes,
          ));
        },
      ),
    );
  }

  // ── InBody Upload Sheet ───────────────────────────────────────────────────────

  void _showInBodyUploadSheet(BuildContext context) {
    final bloc = context.read<TraineeProgressBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _InBodyUploadSheet(
        onUpload: (filePath, label) {
          bloc.add(UploadInBodyReport(filePath: filePath, label: label));
        },
      ),
    );
  }
}

// ── Upload Overlay ────────────────────────────────────────────────────────────

class _UploadingOverlay extends StatelessWidget {
  const _UploadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.35),
      child: const Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text(
                  'Uploading…',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Progress Photo Picker Sheet ───────────────────────────────────────────────

class _ProgressPhotoSheet extends StatefulWidget {
  final void Function(String? frontPath, String? sidePath, String? backPath, String? notes) onUpload;

  const _ProgressPhotoSheet({required this.onUpload});

  @override
  State<_ProgressPhotoSheet> createState() => _ProgressPhotoSheetState();
}

class _ProgressPhotoSheetState extends State<_ProgressPhotoSheet> {
  XFile? _front;
  XFile? _side;
  XFile? _back;
  final _notesCtrl = TextEditingController();
  final _picker = ImagePicker();

  Future<void> _pick(String angle) async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (img == null) return;
    setState(() {
      if (angle == 'Front') _front = img;
      if (angle == 'Side')  _side  = img;
      if (angle == 'Back')  _back  = img;
    });
  }

  bool get _hasAny => _front != null || _side != null || _back != null;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                'Add Progress Photos',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pick one or more angle photos. All are optional.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Three photo slots
              Row(
                children: ['Front', 'Side', 'Back'].map((angle) {
                  XFile? picked = angle == 'Front'
                      ? _front
                      : angle == 'Side'
                          ? _side
                          : _back;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _pick(angle),
                      child: _PhotoPickerSlot(angle: angle, file: picked),
                    ),
                  );
                }).expand((w) => [w, const SizedBox(width: 10)]).toList()
                  ..removeLast(),
              ),
              const SizedBox(height: 16),

              // Notes
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Notes (optional)',
                  hintStyle: const TextStyle(fontSize: 13),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Upload button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _hasAny
                      ? () {
                          Navigator.pop(context);
                          widget.onUpload(
                            _front?.path,
                            _side?.path,
                            _back?.path,
                            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text('Upload Photos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surface,
                    disabledForegroundColor: AppColors.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPickerSlot extends StatelessWidget {
  final String angle;
  final XFile? file;

  const _PhotoPickerSlot({required this.angle, this.file});

  @override
  Widget build(BuildContext context) {
    final hasPick = file != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 110,
      decoration: BoxDecoration(
        color: hasPick ? Colors.transparent : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasPick ? AppColors.primary : AppColors.border,
          width: hasPick ? 2 : 1,
        ),
        image: hasPick
            ? DecorationImage(
                image: FileImage(File(file!.path)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          if (!hasPick)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.add_a_photo_outlined,
                    size: 22, color: AppColors.textMuted),
                const SizedBox(height: 6),
                Text(
                  angle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted),
                ),
              ],
            ),
          if (hasPick)
            Positioned(
              bottom: 6,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    angle,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          if (hasPick)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 13, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

// ── InBody Upload Sheet ───────────────────────────────────────────────────────

class _InBodyUploadSheet extends StatefulWidget {
  final void Function(String filePath, String? label) onUpload;

  const _InBodyUploadSheet({required this.onUpload});

  @override
  State<_InBodyUploadSheet> createState() => _InBodyUploadSheetState();
}

class _InBodyUploadSheetState extends State<_InBodyUploadSheet> {
  PlatformFile? _picked;
  final _labelCtrl = TextEditingController();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'heic'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _picked = result.files.first);
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF8B5CF6);
    final hasPick = _picked != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const Text(
                'Upload InBody Report',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Accepted formats: PDF, JPG, PNG, WEBP, HEIC',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Drop zone / pick button
              GestureDetector(
                onTap: _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: hasPick
                        ? purple.withOpacity(0.05)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: hasPick ? purple : AppColors.border,
                      width: hasPick ? 2 : 1,
                    ),
                  ),
                  child: hasPick
                      ? Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: purple.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _picked!.extension?.toLowerCase() == 'pdf'
                                    ? Icons.picture_as_pdf_outlined
                                    : Icons.image_outlined,
                                size: 22,
                                color: purple,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _picked!.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _picked!.size > 0
                                  ? '${(_picked!.size / 1024).toStringAsFixed(1)} KB'
                                  : '',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to change file',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: purple.withOpacity(0.7),
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: purple.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.upload_file_outlined,
                                  size: 24, color: purple),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Tap to select a file',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'PDF, JPG, PNG, WEBP, HEIC',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Optional label
              TextField(
                controller: _labelCtrl,
                decoration: InputDecoration(
                  hintText: 'Label (optional, e.g. "March 2025")',
                  hintStyle: const TextStyle(fontSize: 13),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Upload button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: hasPick && _picked!.path != null
                      ? () {
                          Navigator.pop(context);
                          widget.onUpload(
                            _picked!.path!,
                            _labelCtrl.text.trim().isEmpty
                                ? null
                                : _labelCtrl.text.trim(),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text('Upload Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surface,
                    disabledForegroundColor: AppColors.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Badge Icon Widget ─────────────────────────────────────────────────────────

class _BadgeIcon extends StatelessWidget {
  final String  type;
  final double  size;
  final bool    earned;
  final String? tier;

  const _BadgeIcon({required this.type, required this.size, required this.earned, this.tier});

  @override
  Widget build(BuildContext context) {
    final config = _iconConfig();
    final icon   = config['icon'] as IconData;
    final color  = earned ? (config['color'] as Color) : AppColors.textMuted;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: earned ? color.withOpacity(0.15) : AppColors.surface,
        border: earned
            ? Border.all(color: color.withOpacity(0.3), width: 1.5)
            : Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: size * 0.45, color: color),
    );
  }

  Map<String, dynamic> _iconConfig() {
    switch (type) {
      case 'fire':     return {'icon': Icons.local_fire_department_rounded, 'color': const Color(0xFFF97316)};
      case 'dumbbell': return {'icon': Icons.fitness_center_rounded,        'color': const Color(0xFF34D399)};
      case 'apple':    return {'icon': Icons.restaurant_rounded,            'color': const Color(0xFF10B981)};
      case 'camera':   return {'icon': Icons.photo_camera_rounded,          'color': const Color(0xFF3B82F6)};
      case 'target':   return {'icon': Icons.my_location_rounded,           'color': const Color(0xFFF59E0B)};
      case 'star':     return {'icon': Icons.star_rounded,                  'color': const Color(0xFF34D399)};
      case 'drop':     return {'icon': Icons.water_drop_rounded,            'color': const Color(0xFF3B82F6)};
      case 'trend':    return {'icon': Icons.trending_down_rounded,         'color': const Color(0xFF10B981)};
      default:         return {'icon': Icons.emoji_events_rounded,          'color': AppColors.primary};
    }
  }
}

// ── Circular Metric Painter (Apple Watch) ─────────────────────────────────────

class _CircularMetricPainter extends CustomPainter {
  final double fraction;
  final Color  color;

  const _CircularMetricPainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = math.min(cx, cy) - 4;
    const startAngle = -math.pi / 2;
    const sweep      = 2 * math.pi;

    // Track
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()
          ..color = const Color(0xFFF1F5F9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5);

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      startAngle,
      sweep * fraction.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CircularMetricPainter old) => old.fraction != fraction;
}

// ── Weight Line Chart Painter ─────────────────────────────────────────────────

class _WeightChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final double       goalWeight;

  _WeightChartPainter({required this.data, required this.labels, required this.goalWeight});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const padL = 10.0, padR = 20.0, padT = 16.0, padB = 28.0;
    final double minVal = math.min(data.reduce(math.min) - 0.5, goalWeight - 0.5);
    final double maxVal = data.reduce(math.max) + 0.5;
    final double range  = maxVal - minVal;
    final double w = size.width  - padL - padR;
    final double h = size.height - padT - padB;

    // Grid lines
    final gridPaint = Paint()..color = const Color(0xFFF1F5F9)..strokeWidth = 1;
    for (final f in [0.25, 0.5, 0.75]) {
      final y = padT + h * f;
      canvas.drawLine(Offset(padL, y), Offset(padL + w, y), gridPaint);
    }

    // Points
    final pts = data.indexed.map((e) {
      final x = padL + (e.$1 / (data.length - 1)) * w;
      final y = padT + h - ((e.$2 - minVal) / range) * h;
      return Offset(x, y);
    }).toList();

    // Goal line
    final goalY = padT + h - ((goalWeight - minVal) / range) * h;
    final dashPaint = Paint()
      ..color = AppColors.success.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    _drawDashedLine(canvas, Offset(padL, goalY), Offset(padL + w, goalY), dashPaint);

    // Goal label
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Goal',
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.success),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(padL + w + 3, goalY - tp.height / 2));

    // Fill
    final fillPath = Path()..moveTo(pts.first.dx, padT + h);
    for (final p in pts) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(pts.last.dx, padT + h);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()
      ..color = AppColors.primary.withOpacity(0.1)
      ..style = PaintingStyle.fill);

    // Line
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      linePath.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(linePath, Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Points
    for (int i = 0; i < pts.length; i++) {
      final isLast = i == pts.length - 1;
      canvas.drawCircle(pts[i], isLast ? 5 : 3.5, Paint()
        ..color = isLast ? AppColors.primary : Colors.white
        ..style = PaintingStyle.fill);
      canvas.drawCircle(pts[i], isLast ? 5 : 3.5, Paint()
        ..color = AppColors.primary
        ..strokeWidth = isLast ? 2 : 1.5
        ..style = PaintingStyle.stroke);
    }

    // X-axis labels
    final lp = TextPainter(textDirection: ui.TextDirection.ltr);
    for (int i = 0; i < labels.length && i < pts.length; i++) {
      lp.text = TextSpan(
        text: labels[i],
        style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
      );
      lp.layout();
      lp.paint(canvas, Offset(pts[i].dx - lp.width / 2, size.height - padB + 6));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLen = 4.0, gapLen = 3.0;
    final dir   = (end - start);
    final total = dir.distance;
    final unit  = dir / total;
    double dist = 0;
    bool   dash = true;
    while (dist < total) {
      final segLen = math.min(dash ? dashLen : gapLen, total - dist);
      if (dash) {
        canvas.drawLine(start + unit * dist, start + unit * (dist + segLen), paint);
      }
      dist += segLen;
      dash = !dash;
    }
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) => old.data != data || old.goalWeight != goalWeight;
}

// ── Bar Chart Painter (Calories) ──────────────────────────────────────────────

class _BarChartPainter extends CustomPainter {
  final List<int>    data;
  final int          target;
  final List<String> labels;

  const _BarChartPainter({required this.data, required this.target, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const padL = 10.0, padR = 10.0, padT = 10.0, padB = 24.0;
    final maxVal = (data.reduce(math.max) * 1.1).toDouble();
    final w      = size.width  - padL - padR;
    final h      = size.height - padT - padB;
    final barW   = (w / data.length) - 4;

    // Target line
    final targetY = padT + h - (target / maxVal * h);
    final dashPaint = Paint()
      ..color = AppColors.success.withOpacity(0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    _drawDash(canvas, Offset(padL, targetY), Offset(padL + w, targetY), dashPaint);

    // Bars
    for (int i = 0; i < data.length; i++) {
      final barH  = (data[i] / maxVal) * h;
      final x     = padL + i * (w / data.length) + 2;
      final isOver = data[i] > target;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, padT + h - barH, barW, barH),
          const Radius.circular(4),
        ),
        Paint()..color = (isOver ? AppColors.warning : AppColors.primary).withOpacity(0.8),
      );

      // Label
      final lp = TextPainter(
        text: TextSpan(text: labels[i], style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      lp.paint(canvas, Offset(x + barW / 2 - lp.width / 2, size.height - padB + 6));
    }
  }

  void _drawDash(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLen = 3.0, gapLen = 3.0;
    final dir   = (end - start);
    final total = dir.distance;
    final unit  = dir / total;
    double dist = 0;
    bool   dash = true;
    while (dist < total) {
      final segLen = math.min(dash ? dashLen : gapLen, total - dist);
      if (dash) canvas.drawLine(start + unit * dist, start + unit * (dist + segLen), paint);
      dist += segLen;
      dash = !dash;
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.data != data;
}

// ── Extension for indexed iteration ──────────────────────────────────────────

extension _IndexedIterable<T> on Iterable<T> {
  Iterable<(int, T)> get indexed sync* {
    var i = 0;
    for (final e in this) {
      yield (i++, e);
    }
  }
}
