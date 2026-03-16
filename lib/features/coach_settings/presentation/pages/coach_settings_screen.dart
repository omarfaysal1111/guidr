import 'package:flutter/material.dart';
import 'package:guidr/features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoachSettingsScreen extends StatelessWidget {
  const CoachSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildSettingsSection('Account', [
            _buildSettingsTile(Icons.person_outline, 'Edit Profile'),
            _buildSettingsTile(
              Icons.star_border,
              'Subscription Plan',
              trailing: const Text(
                'Free',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildSettingsTile(Icons.credit_card, 'Billing Info'),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection('Preferences', [
            _buildSettingsTile(Icons.notifications_none, 'Notifications'),
            _buildSettingsTile(Icons.language, 'Language'),
          ]),
          const SizedBox(height: 24),
          _buildSettingsSection('Support', [
            _buildSettingsTile(Icons.help_outline, 'Help Center'),
            _buildSettingsTile(Icons.message_outlined, 'Contact Us'),
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
            child: const Text('Log Out'),
          ),
        ],
      ),
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
          title.toUpperCase(),
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

  Widget _buildSettingsTile(IconData icon, String title, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: () {},
    );
  }
}
