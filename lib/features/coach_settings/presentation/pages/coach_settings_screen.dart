import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/l10n/app_localizations.dart';
import 'package:guidr/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';

class CoachSettingsScreen extends StatelessWidget {
  const CoachSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildSettingsSection(l.account.toUpperCase(), [
            _buildSettingsTile(Icons.person_outline, l.editProfile),
            _buildSettingsTile(
              Icons.star_border,
              l.subscriptionPlan,
              trailing: Text(
                l.free,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildSettingsTile(Icons.credit_card, l.billingInfo),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(l.preferences.toUpperCase(), [
            _buildSettingsTile(Icons.notifications_none, l.notifications),
            _buildSettingsTile(
              Icons.language,
              l.language,
              onTap: () => _showLanguagePicker(context),
              trailing: _LanguageBadge(),
            ),
            _buildSettingsTile(
              Icons.straighten_outlined,
              l.units,
              onTap: () => _showUnitsPicker(context),
              trailing: _UnitsBadge(),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection(l.support.toUpperCase(), [
            _buildSettingsTile(Icons.help_outline, l.helpCenter),
            _buildSettingsTile(Icons.message_outlined, l.contactUs),
          ]),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorLight,
              foregroundColor: AppColors.error,
              elevation: 0,
            ),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(l.logOut),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<LocaleCubit>();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: cubit,
          child: _LanguagePickerSheet(l: l),
        );
      },
    );
  }

  void _showUnitsPicker(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cubit = context.read<LocaleCubit>();
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: cubit,
          child: _UnitsPickerSheet(l: l),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            'M',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mahmoud',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'mahmoud@fitcoach.com',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap ?? () {},
    );
  }
}

// ─── Language Badge ───────────────────────────────────────────────────────────

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
              _LanguageOption(
                flag: '🇺🇸',
                label: l.languageEnglish,
                isSelected: !state.isArabic,
                onTap: () {
                  context.read<LocaleCubit>().setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              _LanguageOption(
                flag: '🇸🇦',
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

class _LanguageOption extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
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

// ─── Units Picker Sheet ───────────────────────────────────────────────────────

class _UnitsPickerSheet extends StatelessWidget {
  final AppLocalizations l;
  const _UnitsPickerSheet({required this.l});

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
              _LanguageOption(
                flag: '📏',
                label: l.unitsMetric,
                isSelected: state.isMetric,
                onTap: () {
                  context.read<LocaleCubit>().setUnits('metric');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
              _LanguageOption(
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
