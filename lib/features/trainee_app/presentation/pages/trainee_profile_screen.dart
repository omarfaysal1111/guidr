import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guidr/features/trainee_app/domain/entities/trainee_app_profile.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';

class TraineeProfileScreen extends StatefulWidget {
  const TraineeProfileScreen({super.key});

  @override
  State<TraineeProfileScreen> createState() => _TraineeProfileScreenState();
}

class _TraineeProfileScreenState extends State<TraineeProfileScreen> {
  late Future<TraineeAppProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = di.sl<TraineeAppRepository>().getMyProfile();
  }

  Future<void> _reload() async {
    setState(() {
      _profileFuture = di.sl<TraineeAppRepository>().getMyProfile();
    });
    await _profileFuture;
  }

  String _initial(String name) {
    final t = name.trim();
    if (t.isEmpty) return '?';
    return t[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<TraineeAppProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final p = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      _initial(p.fullName),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.fullName.isNotEmpty ? p.fullName : 'Trainee',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.email,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        if (p.fitnessGoal != null &&
                            p.fitnessGoal!.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            p.fitnessGoal!.trim(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _section(
                'Account',
                [
                  _tile(Icons.person_outline, 'Edit profile', onTap: () {}),
                  _tile(Icons.star_border, 'Subscription plan',
                      trailing: const Text(
                        'Free',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {}),
                  _tile(Icons.credit_card, 'Billing info', onTap: () {}),
                ],
              ),
              const SizedBox(height: 24),
              _section(
                'Preferences',
                [
                  _tile(Icons.notifications_none, 'Notifications',
                      onTap: () {}),
                  _tile(Icons.language, 'Language', onTap: () {}),
                ],
              ),
              const SizedBox(height: 24),
              _section(
                'Support',
                [
                  _tile(Icons.help_outline, 'Help center', onTap: () {}),
                  _tile(Icons.message_outlined, 'Contact us', onTap: () {}),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorLight,
                  foregroundColor: AppColors.error,
                  elevation: 0,
                ),
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutRequested());
                },
                child: const Text('Log out'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
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

  Widget _tile(
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing:
          trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
