// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/l10n/app_localizations.dart';
import 'package:guidr/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/coach_profile_bloc.dart';
import '../../domain/entities/coach_profile.dart';
import '../../../subscription/presentation/pages/subscription_screen.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

class CoachSettingsScreen extends StatelessWidget {
  const CoachSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<CoachProfileBloc>()..add(LoadCoachProfile()),
      child: const _CoachSettingsView(),
    );
  }
}

// ---------------------------------------------------------------------------
// Main view
// ---------------------------------------------------------------------------

class _CoachSettingsView extends StatelessWidget {
  const _CoachSettingsView();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          l.settings,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<CoachProfileBloc, CoachProfileState>(
        builder: (context, profileState) {
          final profile =
              profileState is CoachProfileLoaded ? profileState.profile : null;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
            children: [
              _ProfileHeader(profile: profile),
              const SizedBox(height: 28),

              // ── Account ────────────────────────────────────────────────
              _SettingsSection(
                title: l.account.toUpperCase(),
                tiles: [
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    label: l.editProfile,
                    onTap: () => _openEditProfile(context, profile),
                  ),
                  _SettingsTile(
                    icon: Icons.star_border_rounded,
                    label: l.subscriptionPlan,
                    trailing: _PlanBadge(label: l.free),
                    onTap: () => _openSubscription(context),
                  ),
                  _SettingsTile(
                    icon: Icons.credit_card_outlined,
                    label: l.billingInfo,
                    onTap: () => _openSubscription(context),
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Preferences ────────────────────────────────────────────
              _SettingsSection(
                title: l.preferences.toUpperCase(),
                tiles: [
                  _SettingsTile(
                    icon: Icons.notifications_none_rounded,
                    label: l.notifications,
                    onTap: () =>
                        _showSheet(context, const _NotificationsSheet()),
                  ),
                  _SettingsTile(
                    icon: Icons.language_rounded,
                    label: l.language,
                    trailing: _LanguageBadge(),
                    onTap: () => _showLanguagePicker(context, l),
                  ),
                  _SettingsTile(
                    icon: Icons.straighten_outlined,
                    label: l.units,
                    trailing: _UnitsBadge(),
                    onTap: () => _showUnitsPicker(context, l),
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Support (Help Center removed) ──────────────────────────
              _SettingsSection(
                title: l.support.toUpperCase(),
                tiles: [
                  _SettingsTile(
                    icon: Icons.message_outlined,
                    label: l.contactUs,
                    onTap: () => _showSheet(context, const _ContactSheet()),
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // ── Danger zone ────────────────────────────────────────────
              _DangerButton(
                label: l.logOut,
                icon: Icons.logout_rounded,
                color: AppColors.warning,
                onTap: () => context.read<AuthBloc>().add(LogoutRequested()),
              ),
              const SizedBox(height: 12),
              _DangerButton(
                label: 'Delete Account',
                icon: Icons.delete_forever_outlined,
                color: AppColors.error,
                onTap: () => _showDeleteDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Navigation helpers ───────────────────────────────────────────────────

  void _openSubscription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SubscriptionScreen()),
    );
  }

  void _openEditProfile(BuildContext context, CoachProfile? profile) {
    final bloc = context.read<CoachProfileBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: _CoachEditProfileScreen(profile: profile),
        ),
      ),
    );
  }

  void _showSheet(BuildContext context, Widget child) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => child,
    );
  }

  void _showLanguagePicker(BuildContext context, AppLocalizations l) {
    final cubit = context.read<LocaleCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) =>
          BlocProvider.value(value: cubit, child: _LanguagePickerSheet(l: l)),
    );
  }

  void _showUnitsPicker(BuildContext context, AppLocalizations l) {
    final cubit = context.read<LocaleCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) =>
          BlocProvider.value(value: cubit, child: _UnitsPickerSheet(l: l)),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => _DeleteAccountDialog(authBloc: authBloc),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile header
// ---------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  final CoachProfile? profile;
  const _ProfileHeader({this.profile});

  @override
  Widget build(BuildContext context) {
    final name = profile?.fullName ?? '…';
    final email = profile?.email ?? '';
    final spec = profile?.specialisation ?? '';
    final initial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
          ),
          child: CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (email.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  email,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
              if (spec.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    spec,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Edit Profile Screen
// ---------------------------------------------------------------------------

class _CoachEditProfileScreen extends StatefulWidget {
  final CoachProfile? profile;
  const _CoachEditProfileScreen({this.profile});

  @override
  State<_CoachEditProfileScreen> createState() =>
      _CoachEditProfileScreenState();
}

class _CoachEditProfileScreenState extends State<_CoachEditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _specCtrl;
  late final TextEditingController _bioCtrl;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.profile?.fullName ?? '');
    _specCtrl =
        TextEditingController(text: widget.profile?.specialisation ?? '');
    _bioCtrl = TextEditingController(text: widget.profile?.bio ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _specCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CoachProfileBloc, CoachProfileState>(
      listenWhen: (prev, curr) =>
          prev is CoachProfileLoading && curr is CoachProfileLoaded,
      listener: (context, state) {
        if (!_saved) {
          _saved = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.of(context).pop();
        }
      },
      child: BlocBuilder<CoachProfileBloc, CoachProfileState>(
        builder: (context, state) {
          final loading = state is CoachProfileLoading;
          final error =
              state is CoachProfileError ? state.message : null;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            error,
                            style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _FormField(
                  label: 'Full Name',
                  controller: _nameCtrl,
                  hint: 'Your name',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),
                _FormField(
                  label: 'Email',
                  controller: TextEditingController(
                      text: widget.profile?.email ?? ''),
                  hint: 'Email address',
                  icon: Icons.email_outlined,
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                _FormField(
                  label: 'Specialisation',
                  controller: _specCtrl,
                  hint: 'e.g. Strength & Conditioning',
                  icon: Icons.fitness_center_outlined,
                ),
                const SizedBox(height: 16),
                _FormField(
                  label: 'Bio',
                  controller: _bioCtrl,
                  hint: 'Tell trainees about yourself…',
                  icon: Icons.notes_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: loading ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _saved = false;
    context.read<CoachProfileBloc>().add(UpdateCoachProfile(
          fullName: name,
          specialisation: _specCtrl.text.trim().isEmpty
              ? null
              : _specCtrl.text.trim(),
          bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        ));
  }
}

// ---------------------------------------------------------------------------
// Notifications Sheet
// ---------------------------------------------------------------------------

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  bool _pushEnabled = true;
  bool _newTrainee = true;
  bool _traineeCheckin = true;
  bool _workoutCompleted = true;
  bool _mealCompleted = false;
  bool _weeklyReport = true;
  bool _appUpdates = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(),
            const SizedBox(height: 16),
            const Text(
              'Notifications',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage what alerts you receive',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _NotifToggle(
              icon: Icons.notifications_active_outlined,
              label: 'Push Notifications',
              subtitle: 'Master switch for all alerts',
              value: _pushEnabled,
              onChanged: (v) => setState(() => _pushEnabled = v),
              highlight: true,
            ),
            const Divider(color: AppColors.border, height: 1),
            _NotifToggle(
              icon: Icons.person_add_outlined,
              label: 'New Trainee Request',
              value: _newTrainee,
              onChanged: _pushEnabled
                  ? (v) => setState(() => _newTrainee = v)
                  : null,
            ),
            _NotifToggle(
              icon: Icons.track_changes_rounded,
              label: 'Trainee Check-In',
              value: _traineeCheckin,
              onChanged: _pushEnabled
                  ? (v) => setState(() => _traineeCheckin = v)
                  : null,
            ),
            _NotifToggle(
              icon: Icons.fitness_center_outlined,
              label: 'Workout Completed',
              value: _workoutCompleted,
              onChanged: _pushEnabled
                  ? (v) => setState(() => _workoutCompleted = v)
                  : null,
            ),
            _NotifToggle(
              icon: Icons.restaurant_outlined,
              label: 'Meal Logged',
              value: _mealCompleted,
              onChanged: _pushEnabled
                  ? (v) => setState(() => _mealCompleted = v)
                  : null,
            ),
            _NotifToggle(
              icon: Icons.bar_chart_rounded,
              label: 'Weekly Analytics Report',
              value: _weeklyReport,
              onChanged: _pushEnabled
                  ? (v) => setState(() => _weeklyReport = v)
                  : null,
            ),
            _NotifToggle(
              icon: Icons.system_update_outlined,
              label: 'App Updates',
              value: _appUpdates,
              onChanged: _pushEnabled
                  ? (v) => setState(() => _appUpdates = v)
                  : null,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final void Function(bool)? onChanged;
  final bool highlight;
  final bool isLast;

  const _NotifToggle({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.highlight = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onChanged == null ? 0.45 : 1.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: highlight
                    ? AppColors.primaryLight
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 19,
                color: highlight
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            title: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: highlight
                    ? AppColors.textPrimary
                    : AppColors.textPrimary,
              ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle!,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  )
                : null,
            trailing: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ),
          if (!isLast)
            const Divider(
                height: 1, indent: 52, color: AppColors.border),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Contact Sheet
// ---------------------------------------------------------------------------

class _ContactSheet extends StatelessWidget {
  const _ContactSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHandle(),
            const SizedBox(height: 16),
            const Text(
              'Contact Us',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'We\'re here to help. Reach out anytime.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _ContactTile(
              icon: Icons.email_outlined,
              label: 'Email Support',
              value: 'support@guidr.app',
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            _ContactTile(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Live Chat',
              value: 'Available Mon–Fri, 9am–6pm',
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 10),
            _ContactTile(
              icon: Icons.public_rounded,
              label: 'Help Website',
              value: 'help.guidr.app',
              color: const Color(0xFF0EA5E9),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Delete Account Dialog
// ---------------------------------------------------------------------------

class _DeleteAccountDialog extends StatefulWidget {
  final AuthBloc authBloc;
  const _DeleteAccountDialog({required this.authBloc});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _ctrl = TextEditingController();
  bool _confirmed = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.error, size: 24),
          SizedBox(width: 10),
          Text(
            'Delete Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This action is permanent and cannot be undone. All your data, trainees, and plans will be deleted.',
            style: TextStyle(
                fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Type DELETE to confirm:',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ctrl,
            onChanged: (v) =>
                setState(() => _confirmed = v.trim() == 'DELETE'),
            decoration: InputDecoration(
              hintText: 'DELETE',
              hintStyle: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        FilledButton(
          onPressed: _confirmed
              ? () {
                  Navigator.pop(context);
                  widget.authBloc.add(LogoutRequested());
                }
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            disabledBackgroundColor: AppColors.error.withOpacity(0.3),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Delete Account',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const _SettingsSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 9),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(children: tiles),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLast;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 19),
          ),
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: trailing ??
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
          onTap: onTap,
        ),
        if (!isLast)
          const Divider(
              height: 1, indent: 64, endIndent: 16, color: AppColors.border),
      ],
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DangerButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.45)),
          backgroundColor: color.withOpacity(0.06),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final String label;
  const _PlanBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── Form field helper ────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final bool readOnly;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          style: const TextStyle(
              fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: AppColors.textMuted, fontSize: 13),
            prefixIcon: Icon(icon,
                size: 19, color: AppColors.textSecondary),
            filled: true,
            fillColor: readOnly ? AppColors.surface : AppColors.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Language Badge ────────────────────────────────────────────────────────────

class _LanguageBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final label = state.isArabic
            ? AppLocalizations.of(context).languageArabic
            : AppLocalizations.of(context).languageEnglish;
        return _Badge(label: label);
      },
    );
  }
}

// ─── Units Badge ──────────────────────────────────────────────────────────────

class _UnitsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final label = state.isMetric
            ? AppLocalizations.of(context).kg
            : AppLocalizations.of(context).inchUnit;
        return _Badge(label: label);
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─── Language Picker Sheet ────────────────────────────────────────────────────

class _LanguagePickerSheet extends StatelessWidget {
  final AppLocalizations l;
  const _LanguagePickerSheet({required this.l});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const SizedBox(height: 16),
              Text(
                l.selectLanguage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _PickerOption(
                flag: '🇺🇸',
                label: l.languageEnglish,
                isSelected: !state.isArabic,
                onTap: () {
                  context
                      .read<LocaleCubit>()
                      .setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              _PickerOption(
                flag: '🇸🇦',
                label: l.languageArabic,
                isSelected: state.isArabic,
                onTap: () {
                  context
                      .read<LocaleCubit>()
                      .setLocale(const Locale('ar'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Units Picker Sheet ───────────────────────────────────────────────────────

class _UnitsPickerSheet extends StatelessWidget {
  final AppLocalizations l;
  const _UnitsPickerSheet({required this.l});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const SizedBox(height: 16),
              Text(
                l.selectUnits,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _PickerOption(
                flag: '📏',
                label: l.unitsMetric,
                isSelected: state.isMetric,
                onTap: () {
                  context.read<LocaleCubit>().setUnits('metric');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              _PickerOption(
                flag: '📐',
                label: l.unitsImperial,
                isSelected: !state.isMetric,
                onTap: () {
                  context.read<LocaleCubit>().setUnits('imperial');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PickerOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PickerOption({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
