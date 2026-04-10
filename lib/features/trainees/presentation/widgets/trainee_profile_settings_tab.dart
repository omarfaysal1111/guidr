import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/trainee.dart';

/// Settings tab: status alerts, trainee info rows, archive / delete actions.
class TraineeProfileSettingsTab extends StatelessWidget {
  final Trainee trainee;
  final Trainee? profileFromDetail;
  final bool detailLoading;

  const TraineeProfileSettingsTab({
    super.key,
    required this.trainee,
    required this.profileFromDetail,
    required this.detailLoading,
  });

  Trainee get _p => profileFromDetail ?? trainee;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
      children: [
        if (detailLoading) const LinearProgressIndicator(minHeight: 2),
        if (detailLoading) const SizedBox(height: 8),
        ..._buildAlertBanners(_p.alerts),
        if (_p.alerts.isNotEmpty) const SizedBox(height: 12),
        _TraineeInfoCard(profile: _p),
        const SizedBox(height: 16),
        _ArchiveTraineeButton(
          onPressed: () => _confirmArchive(context),
        ),
        const SizedBox(height: 12),
        _DeleteTraineeButton(
          onPressed: () => _confirmDelete(context),
        ),
      ],
    );
  }

  List<Widget> _buildAlertBanners(List<String> codes) {
    final widgets = <Widget>[];
    for (final code in codes) {
      final w = _bannerForCode(code);
      if (w != null) {
        if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 10));
        widgets.add(w);
      }
    }
    return widgets;
  }

  Widget? _bannerForCode(String code) {
    switch (code) {
      case 'missed':
        return const _SettingsAlertBanner(
          background: Color(0xFFFFE4E6),
          borderColor: Color(0xFFFECDD3),
          iconBg: Color(0xFFFFCCD0),
          icon: Icons.fitness_center,
          iconColor: Color(0xFFDC2626),
          message: 'Missed workouts',
          messageColor: Color(0xFFB91C1C),
        );
      case 'nutrition':
        return const _SettingsAlertBanner(
          background: Color(0xFFFEF9C3),
          borderColor: Color(0xFFFEF08A),
          iconBg: Color(0xFFFEF08A),
          icon: Icons.eco_outlined,
          iconColor: Color(0xFFD97706),
          message: 'Low nutrition adherence',
          messageColor: Color(0xFFB45309),
        );
      case 'plateau':
        return const _SettingsAlertBanner(
          background: Color(0xFFEDE9FE),
          borderColor: Color(0xFFC4B5FD),
          iconBg: Color(0xFFDDD6FE),
          icon: Icons.show_chart_rounded,
          iconColor: Color(0xFF7C3AED),
          message: 'Weight plateau (3+ weeks)',
          messageColor: Color(0xFF5B21B6),
        );
      default:
        return null;
    }
  }

  Future<void> _confirmArchive(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive trainee?'),
        content: Text(
          '${_p.name} will be archived. You can restore them later if your app supports it.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade700),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Archive is not connected to the API yet.')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete trainee permanently?'),
        content: Text(
          'This will remove ${_p.name} and their data. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete is not connected to the API yet.')),
      );
    }
  }
}

class _SettingsAlertBanner extends StatelessWidget {
  final Color background;
  final Color borderColor;
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String message;
  final Color messageColor;

  const _SettingsAlertBanner({
    required this.background,
    required this.borderColor,
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.messageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: messageColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TraineeInfoCard extends StatelessWidget {
  final Trainee profile;

  const _TraineeInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final notes = profile.notes?.trim();
    final rows = [
      ('Name', profile.name),
      ('Email', profile.email),
      ('Goal', profile.goal),
      ('Level', profile.level),
      ('Notes', (notes == null || notes.isEmpty) ? '—' : notes),
    ];

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Trainee Info',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...rows.asMap().entries.map((e) {
            final last = e.key == rows.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 88,
                        child: Text(
                          e.value.$1,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          e.value.$2,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!last) const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _ArchiveTraineeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ArchiveTraineeButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.inventory_2_outlined, color: Colors.orange.shade800),
        label: Text(
          'Archive Trainee',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.orange.shade900,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF7ED),
          foregroundColor: Colors.orange.shade900,
          side: BorderSide(color: Colors.orange.shade400, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

class _DeleteTraineeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DeleteTraineeButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFB91C1C)),
        label: const Text(
          'Delete Trainee Permanently',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFFB91C1C),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFEF2F2),
          foregroundColor: const Color(0xFFB91C1C),
          side: const BorderSide(color: Color(0xFFF87171), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
