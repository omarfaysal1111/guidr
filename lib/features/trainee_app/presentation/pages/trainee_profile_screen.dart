// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/l10n/app_localizations.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/locale/locale_cubit.dart';
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guidr/features/trainee_app/domain/entities/trainee_app_profile.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';
import '../bloc/trainee_profile_cubit.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────

class TraineeProfileScreen extends StatelessWidget {
  const TraineeProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TraineeProfileCubit(
        repository: di.sl<TraineeAppRepository>(),
      )..loadProfile(),
      child: const _TraineeProfileView(),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────

class _TraineeProfileView extends StatelessWidget {
  const _TraineeProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<TraineeProfileCubit, TraineeProfileState>(
        builder: (context, state) {
          if (state is TraineeProfileLoading || state is TraineeProfileInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is TraineeProfileError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 52,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<TraineeProfileCubit>().loadProfile(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final p = (state as TraineeProfileLoaded).profile;
          return _buildContent(context, p);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TraineeAppProfile p) {
    final l = AppLocalizations.of(context);
    return CustomScrollView(
      slivers: [
        // ── Gradient Profile Header ──────────────────────────────────────────
        SliverToBoxAdapter(child: _ProfileHeader(profile: p)),

        // ── Sections ────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Account ───────────────────────────────────────────────────
              _SectionGroup(
                title: l.account.toUpperCase(),
                tiles: [
                  _SectionTile(
                    icon: Icons.person_outline_rounded,
                    label: l.editProfile,
                    onTap: () => _openEditProfile(context, p),
                  ),
                  _SectionTile(
                    icon: Icons.star_border_rounded,
                    label: l.subscriptionPlan,
                    trailing: _PlanBadge(
                        label: l.free, color: AppColors.primary),
                    onTap: () => _showSheet(context, const _SubscriptionSheet()),
                  ),
                  _SectionTile(
                    icon: Icons.credit_card_outlined,
                    label: l.billingInfo,
                    onTap: () => _showSheet(context, const _BillingSheet()),
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Preferences ───────────────────────────────────────────────
              _SectionGroup(
                title: l.preferences.toUpperCase(),
                tiles: [
                  _SectionTile(
                    icon: Icons.notifications_none_rounded,
                    label: l.notifications,
                    onTap: () =>
                        _showSheet(context, const _NotificationsSheet()),
                  ),
                  _SectionTile(
                    icon: Icons.language_rounded,
                    label: l.language,
                    trailing: _TraineeLanguageBadge(),
                    onTap: () => _showLanguagePicker(context, l),
                  ),
                  _SectionTile(
                    icon: Icons.straighten_outlined,
                    label: l.units,
                    trailing: _TraineeUnitsBadge(),
                    onTap: () => _showUnitsPicker(context, l),
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Support ───────────────────────────────────────────────────
              _SectionGroup(
                title: l.support.toUpperCase(),
                tiles: [
                  _SectionTile(
                    icon: Icons.help_outline_rounded,
                    label: l.helpCenter,
                    onTap: () => _showSheet(context, const _HelpCenterSheet()),
                  ),
                  _SectionTile(
                    icon: Icons.message_outlined,
                    label: l.contactUs,
                    onTap: () => _showSheet(context, const _ContactSheet()),
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // ── Logout ────────────────────────────────────────────────────
              _LogoutButton(),
              const SizedBox(height: 12),

              // ── Delete Account ────────────────────────────────────────────
              _DeleteAccountButton(),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Navigation helpers ───────────────────────────────────────────────────

  void _openEditProfile(BuildContext context, TraineeAppProfile profile) {
    final cubit = context.read<TraineeProfileCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: _TraineeEditProfileScreen(profile: profile),
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
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: _TraineeLanguagePickerSheet(l: l),
      ),
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
      builder: (ctx) => BlocProvider.value(
        value: cubit,
        child: _TraineeUnitsPickerSheet(l: l),
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final TraineeAppProfile profile;
  const _ProfileHeader({required this.profile});

  String _initial() {
    final t = profile.fullName.trim();
    return t.isNotEmpty ? t[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, Color(0xFF1A5C3A), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          child: Column(
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 28),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white.withOpacity(0.18),
                      child: Text(
                        _initial(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        size: 14, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                profile.fullName.isNotEmpty ? profile.fullName : 'Trainee',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                profile.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.72),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (profile.fitnessGoal != null &&
                  profile.fitnessGoal!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.track_changes_rounded,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        profile.fitnessGoal!.trim(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Edit Profile Screen ──────────────────────────────────────────────────────

class _TraineeEditProfileScreen extends StatefulWidget {
  final TraineeAppProfile profile;
  const _TraineeEditProfileScreen({required this.profile});

  @override
  State<_TraineeEditProfileScreen> createState() =>
      _TraineeEditProfileScreenState();
}

class _TraineeEditProfileScreenState
    extends State<_TraineeEditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _goalCtrl;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.profile.fullName);
    _goalCtrl =
        TextEditingController(text: widget.profile.fitnessGoal ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TraineeProfileCubit, TraineeProfileState>(
      listenWhen: (prev, curr) =>
          prev is TraineeProfileLoading && curr is TraineeProfileLoaded,
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
      child: BlocBuilder<TraineeProfileCubit, TraineeProfileState>(
        builder: (context, state) {
          final loading = state is TraineeProfileLoading;
          final error =
              state is TraineeProfileError ? state.message : null;

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
                  controller:
                      TextEditingController(text: widget.profile.email),
                  hint: 'Email address',
                  icon: Icons.email_outlined,
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                _FormField(
                  label: 'Fitness Goal',
                  controller: _goalCtrl,
                  hint: 'e.g. Lose weight, Build muscle…',
                  icon: Icons.track_changes_rounded,
                  maxLines: 3,
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
    context.read<TraineeProfileCubit>().updateProfile(
          fullName: name,
          fitnessGoal: _goalCtrl.text.trim().isEmpty
              ? null
              : _goalCtrl.text.trim(),
        );
  }
}

// ─── Subscription Sheet ───────────────────────────────────────────────────────

class _SubscriptionSheet extends StatelessWidget {
  const _SubscriptionSheet();

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
              'Subscription Plan',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage your membership',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            _SubscriptionCard(
              name: 'Free',
              description: 'Basic access to your assigned plans',
              features: const [
                'Access workout plans',
                'View nutrition plans',
                'Progress tracking',
              ],
              isActive: true,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            _SubscriptionCard(
              name: 'Premium',
              description: 'Unlock the full coaching experience',
              features: const [
                'Advanced analytics',
                'Meal customisation',
                'Direct messaging',
                'Priority coach access',
              ],
              isActive: false,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final String name;
  final String description;
  final List<String> features;
  final bool isActive;
  final Color color;

  const _SubscriptionCard({
    required this.name,
    required this.description,
    required this.features,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.05) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color.withOpacity(0.5) : AppColors.border,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Active',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color),
                  ),
                ),
              ],
              const Spacer(),
              if (!isActive)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 32),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Upgrade'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 14, color: color),
                  const SizedBox(width: 8),
                  Text(
                    f,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Billing Sheet ────────────────────────────────────────────────────────────

class _BillingSheet extends StatelessWidget {
  const _BillingSheet();

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
              'Billing Info',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.credit_card_outlined,
                      size: 32, color: AppColors.textMuted),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No payment method',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Add a card to upgrade your plan',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add Payment Method'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Notifications Sheet ──────────────────────────────────────────────────────

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  bool _pushEnabled = true;
  bool _mealReminders = true;
  bool _workoutReminders = true;
  bool _weeklyReport = true;
  bool _coachMessages = true;
  bool _planUpdates = false;
  bool _marketing = false;

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
              'Choose what you want to be notified about',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
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
              icon: Icons.restaurant_outlined,
              label: 'Meal Reminders',
              value: _mealReminders,
              onChanged:
                  _pushEnabled ? (v) => setState(() => _mealReminders = v) : null,
            ),
            _NotifToggle(
              icon: Icons.fitness_center_outlined,
              label: 'Workout Reminders',
              value: _workoutReminders,
              onChanged: _pushEnabled
                  ? (v) => setState(() => _workoutReminders = v)
                  : null,
            ),
            _NotifToggle(
              icon: Icons.bar_chart_rounded,
              label: 'Weekly Progress Report',
              value: _weeklyReport,
              onChanged:
                  _pushEnabled ? (v) => setState(() => _weeklyReport = v) : null,
            ),
            _NotifToggle(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Coach Messages',
              value: _coachMessages,
              onChanged: _pushEnabled
                  ? (v) => setState(() => _coachMessages = v)
                  : null,
            ),
            _NotifToggle(
              icon: Icons.update_rounded,
              label: 'Plan Updates',
              value: _planUpdates,
              onChanged:
                  _pushEnabled ? (v) => setState(() => _planUpdates = v) : null,
            ),
            _NotifToggle(
              icon: Icons.campaign_outlined,
              label: 'Promotions & Tips',
              value: _marketing,
              onChanged:
                  _pushEnabled ? (v) => setState(() => _marketing = v) : null,
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
              child: Icon(icon,
                  size: 19,
                  color: highlight
                      ? AppColors.primary
                      : AppColors.textSecondary),
            ),
            title: Text(
              label,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            subtitle: subtitle != null
                ? Text(subtitle!,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted))
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

// ─── Help Center Sheet ────────────────────────────────────────────────────────

class _HelpCenterSheet extends StatelessWidget {
  const _HelpCenterSheet();

  static const _faqs = [
    _FAQ(
      q: 'How do I log a completed meal?',
      a: 'Open the Nutrition tab, expand a meal card, and tap "Mark Done" after eating.',
    ),
    _FAQ(
      q: 'Can I add food not in my plan?',
      a: 'Yes! Tap the + icon in the top-right of the Nutrition screen to log extra food.',
    ),
    _FAQ(
      q: 'How do I track a workout session?',
      a: 'Go to the Workout tab, open your plan, and start a session. Log sets and reps as you go.',
    ),
    _FAQ(
      q: 'Can I switch my coach?',
      a: 'Contact your current coach or reach our support team to request a coach change.',
    ),
    _FAQ(
      q: 'How do I change my fitness goal?',
      a: 'Go to Profile → Edit Profile and update your Fitness Goal field.',
    ),
    _FAQ(
      q: 'How do I reset my password?',
      a: 'On the login screen, tap "Forgot password?" and follow the email instructions.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const SizedBox(height: 16),
              const Text(
                'Help Center',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Frequently asked questions',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  controller: scrollCtrl,
                  itemCount: _faqs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      _FAQTile(faq: _faqs[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FAQ {
  final String q;
  final String a;
  const _FAQ({required this.q, required this.a});
}

class _FAQTile extends StatefulWidget {
  final _FAQ faq;
  const _FAQTile({required this.faq});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              _open ? AppColors.primary.withOpacity(0.4) : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.q,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                widget.faq.a,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Contact Sheet ────────────────────────────────────────────────────────────

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
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
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
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

// ─── Section Group ────────────────────────────────────────────────────────────

class _SectionGroup extends StatelessWidget {
  final String title;
  final List<Widget> tiles;
  const _SectionGroup({required this.title, required this.tiles});

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

// ─── Section Tile ─────────────────────────────────────────────────────────────

class _SectionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLast;

  const _SectionTile({
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

// ─── Plan Badge ───────────────────────────────────────────────────────────────

class _PlanBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _PlanBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text(l.logOut),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.warning,
          side:
              BorderSide(color: AppColors.warning.withOpacity(0.45)),
          backgroundColor: AppColors.warning.withOpacity(0.06),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── Delete Account Button ────────────────────────────────────────────────────

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          final authBloc = context.read<AuthBloc>();
          showDialog<void>(
            context: context,
            builder: (_) => _DeleteAccountDialog(authBloc: authBloc),
          );
        },
        icon: const Icon(Icons.delete_forever_outlined, size: 18),
        label: const Text('Delete Account'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side:
              BorderSide(color: AppColors.error.withOpacity(0.45)),
          backgroundColor: AppColors.error.withOpacity(0.06),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── Delete Account Dialog ────────────────────────────────────────────────────

class _DeleteAccountDialog extends StatefulWidget {
  final AuthBloc authBloc;
  const _DeleteAccountDialog({required this.authBloc});

  @override
  State<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
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
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            'This will permanently delete your account and all your data. This action cannot be undone.',
            style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5),
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
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.error),
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
            disabledBackgroundColor:
                AppColors.error.withOpacity(0.3),
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

// ─── Shared handle widget ─────────────────────────────────────────────────────

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

// ─── Form field helper ────────────────────────────────────────────────────────

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
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
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
              borderSide:
                  const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Locale Badges ────────────────────────────────────────────────────────────

class _TraineeLanguageBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final label = state.isArabic
            ? AppLocalizations.of(context).languageArabic
            : AppLocalizations.of(context).languageEnglish;
        return _SmallBadge(label: label);
      },
    );
  }
}

class _TraineeUnitsBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final label = state.isMetric
            ? AppLocalizations.of(context).kg
            : AppLocalizations.of(context).inchUnit;
        return _SmallBadge(label: label);
      },
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;
  const _SmallBadge({required this.label});

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

class _TraineeLanguagePickerSheet extends StatelessWidget {
  final AppLocalizations l;
  const _TraineeLanguagePickerSheet({required this.l});

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
                icon: '🇺🇸',
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
                icon: '🇸🇦',
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

class _TraineeUnitsPickerSheet extends StatelessWidget {
  final AppLocalizations l;
  const _TraineeUnitsPickerSheet({required this.l});

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
                icon: '📏',
                label: l.unitsMetric,
                isSelected: state.isMetric,
                onTap: () {
                  context.read<LocaleCubit>().setUnits('metric');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              _PickerOption(
                icon: '📐',
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
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            Text(icon, style: const TextStyle(fontSize: 22)),
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
