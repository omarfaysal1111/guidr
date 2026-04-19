import 'dart:async';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/inbody_report.dart';
import '../bloc/trainees_bloc.dart';
import '../utils/trainee_media_url.dart';
import '../../../trainee_progress/domain/entities/trainee_measurement.dart';
import '../../../trainee_progress/domain/entities/trainee_progress_picture.dart';
import '../../domain/entities/coach_trainee_detail.dart';
import '../../domain/entities/coach_trainee_progress_extra.dart';
import 'inbody_report_file_preview.dart';
import 'trainee_progress_photos_gallery_section.dart';

DateTime? _pictureDateForPic(TraineeProgressPicture p) {
  return DateTime.tryParse(p.uploadedAt ?? '') ?? DateTime.tryParse(p.date);
}

Future<bool> _confirmTraineeGoalDismiss(
  BuildContext context,
  String traineeId,
  String goalId,
) async {
  if (goalId.isEmpty) return false;
  final bloc = context.read<TraineesBloc>();
  final prior = bloc.state;
  if (prior is TraineesLoaded && prior.goalsSaving) return false;

  bloc.add(DeleteGoalEvent(traineeId: traineeId, goalId: goalId));

  try {
    await bloc.stream.firstWhere((s) {
      return s is TraineesLoaded && !s.goalsSaving;
    });
  } catch (_) {
    return false;
  }

  if (!context.mounted) return false;
  final st = bloc.state;
  if (st is! TraineesLoaded) return false;
  return st.goalsError == null;
}

/// Progress tab: weight trend, this week, measurements, photos, feedback, coach notes, goals.
class TraineeProfileProgressTab extends StatefulWidget {
  final CoachTraineeDetail? detail;
  final bool loading;

  const TraineeProfileProgressTab({
    super.key,
    required this.detail,
    required this.loading,
  });

  @override
  State<TraineeProfileProgressTab> createState() => _TraineeProfileProgressTabState();
}

class _TraineeProfileProgressTabState extends State<TraineeProfileProgressTab> {
  late final TextEditingController _coachNotesController;
  late final TextEditingController _cautionController;
  DateTimeRange? _photoRange;

  @override
  void initState() {
    super.initState();
    final d = widget.detail;
    _coachNotesController = TextEditingController(text: d?.coachNotesToTrainee ?? '');
    _cautionController = TextEditingController(text: d?.coachCautionNotes ?? '');
  }

  @override
  void didUpdateWidget(covariant TraineeProfileProgressTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final n = widget.detail;
    final o = oldWidget.detail;
    if (o == null && n != null) {
      _coachNotesController.text = n.coachNotesToTrainee ?? '';
      _cautionController.text = n.coachCautionNotes ?? '';
      return;
    }
    if (n?.coachNotesToTrainee != o?.coachNotesToTrainee) {
      _coachNotesController.text = n?.coachNotesToTrainee ?? '';
    }
    if (n?.coachCautionNotes != o?.coachCautionNotes) {
      _cautionController.text = n?.coachCautionNotes ?? '';
    }
  }

  @override
  void dispose() {
    _coachNotesController.dispose();
    _cautionController.dispose();
    super.dispose();
  }

  static DateTime _mDate(TraineeMeasurement m) {
    final r = DateTime.tryParse(m.recordedAt ?? '');
    if (r != null) return r;
    return DateTime.tryParse(m.date) ?? DateTime(1970);
  }

  static List<double> _weightSeries(List<TraineeMeasurement> all) {
    final withW = all.where((e) => e.weight != null).toList()
      ..sort((a, b) => _mDate(a).compareTo(_mDate(b)));
    if (withW.isEmpty) return [];
    final slice = withW.length > 5 ? withW.sublist(withW.length - 5) : withW;
    return slice.map((e) => e.weight!).toList();
  }

  static TraineeMeasurement? _latestCircumference(List<TraineeMeasurement> all) {
    if (all.isEmpty) return null;
    final sorted = [...all]..sort((a, b) => _mDate(b).compareTo(_mDate(a)));
    for (final m in sorted) {
      if (m.chest != null ||
          m.waist != null ||
          m.hips != null ||
          m.arms != null ||
          m.thighs != null) {
        return m;
      }
    }
    return sorted.first;
  }

  List<TraineeProgressPicture> _filteredPictures(List<TraineeProgressPicture> pics) {
    final range = _photoRange;
    if (range == null) return List<TraineeProgressPicture>.from(pics);
    return pics.where((p) {
      final d = _pictureDateForPic(p);
      if (d == null) return true;
      return !d.isBefore(range.start) && !d.isAfter(range.end);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loading && widget.detail == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    final d = widget.detail;
    if (d == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Could not load progress data.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final weights = _weightSeries(d.recentMeasurements);
    final wp = d.workoutProgress;
    final np = d.nutritionProgress;
    final wFrac = wp.targetThisWeek > 0
        ? (wp.completedThisWeek / wp.targetThisWeek).clamp(0.0, 1.0)
        : 0.0;
    final nFrac = np.mealsTarget > 0
        ? (np.mealsLogged / np.mealsTarget).clamp(0.0, 1.0)
        : 0.0;

    final latest = _latestCircumference(d.recentMeasurements);
    final pics = _filteredPictures(d.recentPictures);
    pics.sort((a, b) {
      final da = _pictureDateForPic(a) ?? DateTime(0);
      final db = _pictureDateForPic(b) ?? DateTime(0);
      return db.compareTo(da);
    });
    final name = d.profile.name;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
        _ProgressSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Weight Trend',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const _FromTraineeBadge(),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: weights.isEmpty
                    ? const Center(
                        child: Text(
                          'No weight logs yet.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: CustomPaint(
                                painter: _WeightTrendPainter(weights: weights),
                                child: const SizedBox.expand(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              weights.length,
                              (i) => Text(
                                'W${i + 1}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ProgressSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                wp.countsForToday ? 'Today' : 'This Week',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              _RedProgressRow(
                label: 'Workouts',
                done: wp.completedThisWeek,
                total: wp.targetThisWeek,
                fraction: wFrac,
              ),
              const SizedBox(height: 14),
              _RedProgressRow(
                label: 'Nutrition',
                done: np.mealsLogged,
                total: np.mealsTarget,
                fraction: nFrac,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ProgressSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Body Measurements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const _FromTraineeBadge(),
                ],
              ),
              const SizedBox(height: 14),
              _MeasurementGrid(latest: latest),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _InBodyCard(
          traineeId: d.profile.id.toString(),
          reports: d.inbodyReports,
        ),
        const SizedBox(height: 14),
        TraineeProgressPhotosGallerySection(
          traineeId: d.profile.id.toString(),
          photos: d.progressPhotos,
        ),
        const SizedBox(height: 14),
        _ProgressPhotosCard(
          pictures: d.recentPictures,
          filtered: pics,
          range: _photoRange,
          onPickRange: () async {
            final now = DateTime.now();
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(now.year - 3),
              lastDate: DateTime(now.year + 1),
              initialDateRange: _photoRange ??
                  DateTimeRange(
                    start: now.subtract(const Duration(days: 30)),
                    end: now,
                  ),
            );
            if (picked != null) setState(() => _photoRange = picked);
          },
          onClearRange: () => setState(() => _photoRange = null),
        ),
        const SizedBox(height: 14),
        _TraineeFeedbackCard(entries: d.traineeFeedback),
        const SizedBox(height: 14),
        _CoachNotesCard(
          traineeId: d.profile.id.toString(),
          traineeName: name,
          coachNotesController: _coachNotesController,
          cautionController: _cautionController,
        ),
        const SizedBox(height: 14),
        _GoalsCard(
          traineeId: d.profile.id.toString(),
          goals: d.traineeGoals,
        ),
      ],
    );
  }
}

class _FromTraineeBadge extends StatelessWidget {
  const _FromTraineeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'From Trainee',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.success,
        ),
      ),
    );
  }
}

class _InBodyFileTypeBadge extends StatelessWidget {
  final InBodyReport report;

  const _InBodyFileTypeBadge({required this.report});

  @override
  Widget build(BuildContext context) {
    final isPdf = report.isPdf;
    final isImage = report.isImage;
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
}

/// Collapsible InBody reports for the coach: upload + list with PDF/image badges.
class _InBodyCard extends StatelessWidget {
  final String traineeId;
  final List<InBodyReport> reports;

  const _InBodyCard({
    required this.traineeId,
    required this.reports,
  });

  Future<void> _pickAndUpload(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg', 'gif', 'webp'],
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final f = result.files.single;
    final bytes = f.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not read the selected file. Try a smaller file or re-save the export.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (!context.mounted) return;
    context.read<TraineesBloc>().add(
          UploadInBodyReportEvent(
            traineeId: traineeId,
            fileBytes: bytes,
            fileName: f.name,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TraineesBloc, TraineesState>(
      listenWhen: (previous, current) {
        if (previous is! TraineesLoaded || current is! TraineesLoaded) return false;
        return previous.inbodyUploadSaving &&
            !current.inbodyUploadSaving &&
            current.inbodyUploadError != null;
      },
      listener: (context, state) {
        if (state is TraineesLoaded && state.inbodyUploadError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.inbodyUploadError!),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<TraineesBloc, TraineesState>(
        buildWhen: (previous, current) {
          if (previous is! TraineesLoaded || current is! TraineesLoaded) {
            return current is TraineesLoaded;
          }
          return previous.inbodyUploadSaving != current.inbodyUploadSaving;
        },
        builder: (context, state) {
          final uploading = state is TraineesLoaded && state.inbodyUploadSaving;
          final count = reports.length;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 8),
                initiallyExpanded: false,
                title: Row(
                  children: [
                    Icon(Icons.analytics_outlined, size: 22, color: Colors.teal.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'InBody reports',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '$count',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Upload scans or PDFs from the device. Expand a row to preview.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: uploading ? null : () => _pickAndUpload(context),
                      icon: uploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file_rounded, size: 20),
                      label: Text(uploading ? 'Uploading…' : 'Upload image or PDF'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (reports.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No InBody reports yet.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    )
                  else
                    ...reports.map((r) {
                      final uri = resolveTraineeMediaUrl(r.fileUrl);
                      final label = r.fileName ??
                          (r.uploadedAt != null
                              ? '${r.uploadedAt!.toLocal()}'.split('.').first
                              : 'Report ${r.id.isNotEmpty ? r.id : uri.path}');
                      return Padding(
                        key: ValueKey('inbody-${r.id}-${r.fileUrl}'),
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
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _InBodyFileTypeBadge(report: r),
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
        },
      ),
    );
  }
}

class _ProgressSectionCard extends StatelessWidget {
  final Widget child;

  const _ProgressSectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RedProgressRow extends StatelessWidget {
  final String label;
  final int done;
  final int total;
  final double fraction;

  const _RedProgressRow({
    required this.label,
    required this.done,
    required this.total,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (fraction * 100).round() : 0;
    final color = pct >= 70
        ? AppColors.primary
        : pct >= 40
            ? AppColors.warning
            : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            Text(
              '$done/$total  ($pct%)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MeasurementGrid extends StatelessWidget {
  final TraineeMeasurement? latest;

  const _MeasurementGrid({required this.latest});

  String _v(double? x) => x == null ? '—' : x.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    final m = latest;
    final tiles = [
      (_v(m?.chest), 'Chest', 'Cm'),
      (_v(m?.waist), 'Waist', 'Cm'),
      (_v(m?.hips), 'Hips', 'Cm'),
      (_v(m?.arms), 'Arms', 'Cm'),
      (_v(m?.thighs), 'Thighs', 'Cm'),
    ];

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _MeasTile(value: tiles[i].$1, label: tiles[i].$2, unit: tiles[i].$3)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _MeasTile(value: tiles[3].$1, label: tiles[3].$2, unit: tiles[3].$3)),
            const SizedBox(width: 8),
            Expanded(child: _MeasTile(value: tiles[4].$1, label: tiles[4].$2, unit: tiles[4].$3)),
            const SizedBox(width: 8),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

class _MeasTile extends StatelessWidget {
  final String value;
  final String label;
  final String unit;

  const _MeasTile({
    required this.value,
    required this.label,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$label ($unit)',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ProgressPhotosCard extends StatelessWidget {
  final List<TraineeProgressPicture> pictures;
  final List<TraineeProgressPicture> filtered;
  final DateTimeRange? range;
  final VoidCallback onPickRange;
  final VoidCallback onClearRange;

  const _ProgressPhotosCard({
    required this.pictures,
    required this.filtered,
    required this.range,
    required this.onPickRange,
    required this.onClearRange,
  });

  static String _formatPhotoDate(DateTime? d) {
    if (d == null) return '—';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final latest = filtered.isNotEmpty ? filtered.first : null;
    final dt = latest != null
        ? (DateTime.tryParse(latest.uploadedAt ?? '') ?? DateTime.tryParse(latest.date))
        : null;

    return _ProgressSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_camera_outlined, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Pose check-ins',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  '${pictures.length} sets',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              const _FromTraineeBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onPickRange,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        range == null
                            ? 'All dates'
                            : '${range!.start.day}/${range!.start.month}/${range!.start.year} to ${range!.end.day}/${range!.end.month}/${range!.end.year}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                    if (range != null)
                      TextButton(onPressed: onClearRange, child: const Text('Clear')),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _formatPhotoDate(dt),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          if (latest == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No photos in this range.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _PhotoSlot(
                    label: 'Front',
                    url: latest.frontPictureUrl,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PhotoSlot(
                    label: 'Side',
                    url: latest.sidePictureUrl,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PhotoSlot(
                    label: 'Back',
                    url: latest.backPictureUrl,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final String label;
  final String? url;

  const _PhotoSlot({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.85,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          image: url != null && url!.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(url!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        alignment: Alignment.center,
        child: url == null || url!.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_camera_outlined, size: 28, color: AppColors.textMuted.withValues(alpha: 0.7)),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

class _TraineeFeedbackCard extends StatelessWidget {
  final List<CoachTraineeFeedbackEntry> entries;

  const _TraineeFeedbackCard({required this.entries});

  static String _shortDate(DateTime? d) {
    if (d == null) return '—';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries]..sort((a, b) {
        final da = a.submittedAt ?? DateTime(1970);
        final db = b.submittedAt ?? DateTime(1970);
        return db.compareTo(da);
      });

    return _ProgressSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 22, color: Colors.purple.shade400),
              const SizedBox(width: 8),
              const Text(
                'Trainee Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (sorted.isEmpty)
            const Text(
              'No feedback entries yet.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          else
            ...sorted.asMap().entries.map((e) {
              final i = e.key;
              final ent = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4FC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _shortDate(ent.submittedAt),
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          if (i == 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Latest',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.purple.shade600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ent.message,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _CoachNotesCard extends StatelessWidget {
  final String traineeId;
  final String traineeName;
  final TextEditingController coachNotesController;
  final TextEditingController cautionController;

  const _CoachNotesCard({
    required this.traineeId,
    required this.traineeName,
    required this.coachNotesController,
    required this.cautionController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<TraineesBloc, TraineesState>(
      listenWhen: (previous, current) {
        if (previous is! TraineesLoaded || current is! TraineesLoaded) return false;
        return previous.coachNotesSaving && !current.coachNotesSaving;
      },
      listener: (context, state) {
        if (state is! TraineesLoaded) return;
        final messenger = ScaffoldMessenger.of(context);
        final err = state.coachNotesError;
        if (err != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(err),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Notes saved for $traineeName'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: _ProgressSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note_rounded, size: 24, color: Colors.teal.shade600),
                const SizedBox(width: 8),
                const Text(
                  'Coach Notes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.description_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Feedback for $traineeName',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: coachNotesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your feedback here... This will be visible to the trainee.',
                hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.85), fontSize: 13),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange.shade700),
                const SizedBox(width: 6),
                Text(
                  'Caution / Medical Notes',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cautionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Injuries, restrictions, things to watch out for...',
                hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.85), fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFFFFDE7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange.shade200),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: BlocBuilder<TraineesBloc, TraineesState>(
                buildWhen: (previous, current) {
                  if (previous is! TraineesLoaded || current is! TraineesLoaded) {
                    return current is TraineesLoaded;
                  }
                  return previous.coachNotesSaving != current.coachNotesSaving;
                },
                builder: (context, state) {
                  final saving = state is TraineesLoaded && state.coachNotesSaving;
                  return FilledButton.icon(
                    onPressed: saving
                        ? null
                        : () {
                            context.read<TraineesBloc>().add(
                                  SaveCoachNotesEvent(
                                    traineeId: traineeId,
                                    feedback: coachNotesController.text,
                                    caution: cautionController.text,
                                  ),
                                );
                          },
                    icon: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_rounded, size: 18),
                    label: Text(saving ? 'Saving…' : 'Save Notes'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalsCard extends StatefulWidget {
  final String traineeId;
  final List<CoachTraineeGoalItem> goals;

  const _GoalsCard({required this.traineeId, required this.goals});

  @override
  State<_GoalsCard> createState() => _GoalsCardState();
}

class _GoalsCardState extends State<_GoalsCard> {
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _submitAdd(BuildContext context, bool saving) {
    final text = _addController.text.trim();
    if (text.isEmpty || saving) return;
    context.read<TraineesBloc>().add(
          AddGoalEvent(traineeId: widget.traineeId, title: text),
        );
    _addController.clear();
  }

  void _showEditGoalSheet(BuildContext context, CoachTraineeGoalItem goal) {
    final editCtrl = TextEditingController(text: goal.title);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return BlocProvider.value(
          value: context.read<TraineesBloc>(),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Edit Goal',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: editCtrl,
                    autofocus: true,
                    maxLines: 3,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Goal description…',
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.surface,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final newTitle = editCtrl.text.trim();
                        if (newTitle.isEmpty || newTitle == goal.title) {
                          Navigator.of(sheetCtx).pop();
                          return;
                        }
                        context.read<TraineesBloc>().add(
                              EditGoalEvent(
                                traineeId: widget.traineeId,
                                goalId: goal.id,
                                newTitle: newTitle,
                              ),
                            );
                        Navigator.of(sheetCtx).pop();
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(editCtrl.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TraineesBloc, TraineesState>(
      listenWhen: (previous, current) {
        if (previous is! TraineesLoaded || current is! TraineesLoaded) return false;
        return previous.goalsSaving && !current.goalsSaving && current.goalsError != null;
      },
      listener: (context, state) {
        if (state is TraineesLoaded && state.goalsError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.goalsError!),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: BlocBuilder<TraineesBloc, TraineesState>(
        buildWhen: (previous, current) {
          if (previous is! TraineesLoaded || current is! TraineesLoaded) {
            return current is TraineesLoaded;
          }
          return previous.goalsSaving != current.goalsSaving;
        },
        builder: (context, state) {
          final saving = state is TraineesLoaded && state.goalsSaving;
          final goals = widget.goals;
          final done = goals.where((g) => g.completed).length;

          return _ProgressSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.track_changes, size: 22, color: Colors.teal.shade600),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Goals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '$done/${goals.length} done',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to mark done · Tap ✏ to edit · Swipe left to delete',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: 12),
                if (goals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No goals listed yet.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  )
                else
                  ...goals.asMap().entries.map((e) {
                    final i = e.key;
                    final g = e.value;
                    final last = i == goals.length - 1;
                    return Column(
                      children: [
                        Dismissible(
                          key: ValueKey('goal-${widget.traineeId}-${g.id}-$i'),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) =>
                              _confirmTraineeGoalDismiss(context, widget.traineeId, g.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 18),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.delete_outline_rounded, color: AppColors.error),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: saving || g.id.isEmpty
                                  ? null
                                  : () {
                                      context.read<TraineesBloc>().add(
                                            ToggleGoalEvent(
                                              traineeId: widget.traineeId,
                                              goalId: g.id,
                                              completed: !g.completed,
                                            ),
                                          );
                                    },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: g.completed ? AppColors.primary : AppColors.border,
                                          width: 2,
                                        ),
                                        color: g.completed ? AppColors.primaryLight : null,
                                      ),
                                      child: g.completed
                                          ? const Icon(Icons.check, size: 16, color: AppColors.primary)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        g.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                          decoration: g.completed ? TextDecoration.lineThrough : null,
                                          decorationColor: AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: saving || g.id.isEmpty
                                          ? null
                                          : () => _showEditGoalSheet(context, g),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8, top: 2),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                          color: saving || g.id.isEmpty
                                              ? AppColors.textMuted.withValues(alpha: 0.4)
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (!last) const Divider(height: 1),
                      ],
                    );
                  }),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addController,
                        enabled: !saving,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        onSubmitted: (_) => _submitAdd(context, saving),
                        decoration: InputDecoration(
                          hintText: 'Add a new goal...',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: saving ? null : () => _submitAdd(context, saving),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(44, 44),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.add_rounded, size: 22),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WeightTrendPainter extends CustomPainter {
  final List<double> weights;

  _WeightTrendPainter({required this.weights});

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.isEmpty) return;

    const topPad = 28.0;
    const bottomPad = 8.0;
    const sidePad = 6.0;
    final rect = Rect.fromLTWH(
      sidePad,
      topPad,
      size.width - 2 * sidePad,
      size.height - topPad - bottomPad,
    );

    if (weights.length == 1) {
      final cx = rect.center.dx;
      final cy = rect.center.dy;
      _drawDot(canvas, Offset(cx, cy), highlight: true);
      return;
    }

    var minV = weights.reduce(math.min);
    var maxV = weights.reduce(math.max);
    if ((maxV - minV).abs() < 0.5) {
      minV -= 1;
      maxV += 1;
    }

    final pts = <Offset>[];
    for (var i = 0; i < weights.length; i++) {
      final t = i / (weights.length - 1);
      final x = rect.left + t * rect.width;
      final ny = (weights[i] - minV) / (maxV - minV);
      final y = rect.bottom - ny * rect.height;
      pts.add(Offset(x, y));
    }

    final fillPath = Path()
      ..moveTo(pts.first.dx, rect.bottom)
      ..lineTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      fillPath.lineTo(pts[i].dx, pts[i].dy);
    }
    fillPath.lineTo(pts.last.dx, rect.bottom);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.primary.withValues(alpha: 0.22),
        AppColors.primary.withValues(alpha: 0.02),
      ],
    );
    canvas.drawPath(
      fillPath,
      Paint()..shader = gradient.createShader(rect),
    );

    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      linePath.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var i = 0; i < pts.length; i++) {
      _drawDot(canvas, pts[i], highlight: i == pts.length - 1);
    }
  }

  void _drawDot(Canvas canvas, Offset c, {required bool highlight}) {
    final r = highlight ? 7.0 : 5.0;
    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = highlight ? 2.5 : 2,
    );
    if (highlight) {
      final tp = TextPainter(
        text: TextSpan(
          text: weights.last.toStringAsFixed(0),
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - 22));
    }
  }

  @override
  bool shouldRepaint(covariant _WeightTrendPainter oldDelegate) {
    return oldDelegate.weights != weights;
  }
}
