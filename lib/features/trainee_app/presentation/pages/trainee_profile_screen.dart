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
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
        SliverToBoxAdapter(
          child: _ProfileHeader(profile: p),
        ),

        // ── Sections ────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Account
              _SectionGroup(
                title: l.account.toUpperCase(),
                tiles: [
                  _SectionTile(
                    icon: Icons.person_outline_rounded,
                    label: l.editProfile,
                    onTap: () {},
                  ),
                  _SectionTile(
                    icon: Icons.star_border_rounded,
                    label: l.subscriptionPlan,
                    trailing: _PlanBadge(label: l.free, color: AppColors.primary),
                    onTap: () {},
                  ),
                  _SectionTile(
                    icon: Icons.credit_card_outlined,
                    label: l.billingInfo,
                    onTap: () {},
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Preferences
              _SectionGroup(
                title: l.preferences.toUpperCase(),
                tiles: [
                  _SectionTile(
                    icon: Icons.notifications_none_rounded,
                    label: l.notifications,
                    onTap: () {},
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

              // Support
              _SectionGroup(
                title: l.support.toUpperCase(),
                tiles: [
                  _SectionTile(
                    icon: Icons.help_outline_rounded,
                    label: l.helpCenter,
                    onTap: () {},
                  ),
                  _SectionTile(
                    icon: Icons.message_outlined,
                    label: l.contactUs,
                    onTap: () {},
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Logout
              _LogoutButton(),
            ]),
          ),
        ),
      ],
    );
  }

  void _showLanguagePicker(BuildContext context, AppLocalizations l) {
    final cubit = context.read<LocaleCubit>();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              // Top bar title
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

              // Avatar with edit badge
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
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
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Name
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

              // Email
              Text(
                profile.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Goal badge
              if (profile.fitnessGoal != null &&
                  profile.fitnessGoal!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.track_changes_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
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
                color: Colors.black.withValues(alpha: 0.03),
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
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
          onTap: onTap,
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 64,
            endIndent: 16,
            color: AppColors.border,
          ),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
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
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.45)),
          backgroundColor: AppColors.errorLight.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── Locale Badges (trainee profile) ─────────────────────────────────────────

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

// ─── Language Picker Sheet (trainee) ─────────────────────────────────────────

class _TraineeLanguagePickerSheet extends StatelessWidget {
  final AppLocalizations l;
  const _TraineeLanguagePickerSheet({required this.l});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  context.read<LocaleCubit>().setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              _PickerOption(
                icon: '🇸🇦',
                label: l.languageArabic,
                isSelected: state.isArabic,
                onTap: () {
                  context.read<LocaleCubit>().setLocale(const Locale('ar'));
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

// ─── Units Picker Sheet (trainee) ─────────────────────────────────────────────

class _TraineeUnitsPickerSheet extends StatelessWidget {
  final AppLocalizations l;
  const _TraineeUnitsPickerSheet({required this.l});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
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
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
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
