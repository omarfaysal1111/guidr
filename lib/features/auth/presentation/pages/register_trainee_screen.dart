import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';

class RegisterTraineeScreen extends StatefulWidget {
  const RegisterTraineeScreen({super.key});

  @override
  State<RegisterTraineeScreen> createState() => _RegisterTraineeScreenState();
}

class _RegisterTraineeScreenState extends State<RegisterTraineeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _invitationTokenController = TextEditingController();
  String _fitnessGoal = 'General Fitness';

  static const _fitnessGoals = [
    'General Fitness',
    'Lose weight',
    'Build muscle',
    'Improve endurance',
    'Increase strength',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _invitationTokenController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            RegisterTraineeRequested(
              fullName: _fullNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              invitationToken: _invitationTokenController.text.trim(),
              fitnessGoal: _fitnessGoal,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildLogoHeader('Create your account'),
                      const SizedBox(height: 32),
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        obscureText: false,
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Please enter your name'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        obscureText: false,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(v.trim())) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _invitationTokenController,
                        label: 'Invitation Code',
                        icon: Icons.card_giftcard_outlined,
                        obscureText: false,
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Please enter your invitation code'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      _buildFitnessGoalDropdown(),
                      const SizedBox(height: 32),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is AuthLoading) {
                            return const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            );
                          }
                          return ElevatedButton(
                            onPressed: _onRegister,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.white, width: 2),
            ),
            prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5)),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildFitnessGoalDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FITNESS GOAL'.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _fitnessGoal,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.white.withOpacity(0.5)),
              items: _fitnessGoals
                  .map(
                    (g) => DropdownMenuItem(
                      value: g,
                      child: Text(g),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _fitnessGoal = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoHeader(String subtitle) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Icon(Icons.fitness_center, size: 32, color: Colors.white),
        ),
        const SizedBox(height: 24),
        const Text(
          'FitCoach Pro',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
