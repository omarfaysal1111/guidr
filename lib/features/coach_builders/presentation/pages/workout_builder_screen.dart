import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/storage/local_storage.dart';
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/coach_builders/data/repositories/builders_repository_impl.dart';
import 'package:guidr/features/coach_builders/domain/entities/exercise.dart';
import 'package:guidr/features/trainees/domain/entities/trainee.dart';
import 'package:guidr/features/trainees/domain/repositories/trainees_repository.dart';

class WorkoutBuilderScreen extends StatefulWidget {
  final VoidCallback onBackPressed;

  const WorkoutBuilderScreen({super.key, required this.onBackPressed});

  @override
  State<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends State<WorkoutBuilderScreen> {
  static const _workoutTemplatesKey = 'coach_workout_templates';
  static const _workoutDraftsKey = 'coach_workout_drafts';

  int _currentStep = 1;
  List<Trainee> _allTrainees = [];
  List<Trainee> _filteredTrainees = [];
  Set<int> _selectedTraineeIds = {};
  bool _traineesLoading = true;

  // Step 3
  final _workoutNameController = TextEditingController();
  String _difficulty = 'Easy';
  final _planInstructionController = TextEditingController();
  final _planCautionController = TextEditingController();
  List<String> _warmUpExercises = ['Dynamic Warm-up'];
  List<String> _mainExercises = [];
  List<String> _coolDownExercises = [];
  bool _warmUpExpanded = true;
  bool _mainExpanded = false;
  bool _coolDownExpanded = true;

  // Step 4
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _recurrence = 'One-time';
  bool _remindBefore = true;
  bool _alertIfMissed = true;

  // Data sources
  final LocalStorage _localStorage = di.sl<LocalStorage>();
  final BuildersRepository _buildersRepository = di.sl<BuildersRepository>();
  List<Exercise> _exerciseLibrary = [];
  bool _exerciseLibraryLoading = false;
  bool _exerciseLibraryLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadTrainees();
     _loadApiPlans();
  }

  Future<void> _loadTrainees() async {
    try {
      final repo = di.sl<TraineesRepository>();
      final trainees = await repo.getMyTrainees();
      final active = trainees.where((t) => t.status == 'active').toList();
      setState(() {
        _allTrainees = active;
        _filteredTrainees = active;
        _traineesLoading = false;
      });
    } catch (_) {
      setState(() {
        _allTrainees = _getMockTrainees();
        _filteredTrainees = _allTrainees;
        _traineesLoading = false;
      });
    }
  }

  Future<void> _loadApiPlans() async {
    try {
      await _buildersRepository.getMyExercisePlans();
      await _loadExerciseLibrary();
    } catch (_) {
      // ignore API errors here; UI can fall back to local/static templates
    }
  }

  Future<void> _loadExerciseLibrary() async {
    if (_exerciseLibraryLoaded || _exerciseLibraryLoading) return;
    setState(() {
      _exerciseLibraryLoading = true;
    });
    try {
      final exercises = await _buildersRepository.getExercises();
      _exerciseLibrary = exercises;
      _exerciseLibraryLoaded = true;
    } catch (_) {
      _exerciseLibrary = [];
    } finally {
      if (mounted) {
        setState(() {
          _exerciseLibraryLoading = false;
        });
      }
    }
  }

  List<Trainee> _getMockTrainees() {
    return [
      const Trainee(
        id: 1,
        name: 'Sarah M.',
        email: 'sarah@example.com',
        avatar: 'S',
        goal: 'Weight loss',
        level: 'Intermediate',
        adherence: 80,
        status: 'active',
        weight: '—',
        lastActivity: '—',
        nextSession: '—',
        joined: '—',
        alerts: [],
      ),
      const Trainee(
        id: 2,
        name: 'Ahmed K.',
        email: 'ahmed@example.com',
        avatar: 'A',
        goal: 'Muscle gain',
        level: 'Advanced',
        adherence: 65,
        status: 'active',
        weight: '—',
        lastActivity: '—',
        nextSession: '—',
        joined: '—',
        alerts: [],
      ),
      const Trainee(
        id: 3,
        name: 'Lina R.',
        email: 'lina@example.com',
        avatar: 'L',
        goal: 'Toning',
        level: 'Beginner',
        adherence: 92,
        status: 'active',
        weight: '—',
        lastActivity: '—',
        nextSession: '—',
        joined: '—',
        alerts: [],
      ),
      const Trainee(
        id: 4,
        name: 'Nadia H.',
        email: 'nadia@example.com',
        avatar: 'N',
        goal: 'Weight loss',
        level: 'Beginner',
        adherence: 45,
        status: 'active',
        weight: '—',
        lastActivity: '—',
        nextSession: '—',
        joined: '—',
        alerts: [],
      ),
      const Trainee(
        id: 5,
        name: 'Youssef A.',
        email: 'youssef@example.com',
        avatar: 'Y',
        goal: 'Flexibility',
        level: 'Beginner',
        adherence: 35,
        status: 'active',
        weight: '—',
        lastActivity: '—',
        nextSession: '—',
        joined: '—',
        alerts: [],
      ),
      const Trainee(
        id: 6,
        name: 'Fatima Z.',
        email: 'fatima@example.com',
        avatar: 'F',
        goal: 'Maintenance',
        level: 'Advanced',
        adherence: 88,
        status: 'active',
        weight: '—',
        lastActivity: '—',
        nextSession: '—',
        joined: '—',
        alerts: [],
      ),
    ];
  }

  static const _traineeConditions = {
    1: 'Knee injury',
    4: 'Traveling often',
  };

  static const _traineeAlerts = {1, 2, 4, 5};

  @override
  void dispose() {
    _workoutNameController.dispose();
    _planInstructionController.dispose();
    _planCautionController.dispose();
    super.dispose();
  }

  void _filterTrainees(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTrainees = _allTrainees;
      } else {
        final q = query.toLowerCase();
        _filteredTrainees = _allTrainees
            .where((t) =>
                t.name.toLowerCase().contains(q) ||
                t.email.toLowerCase().contains(q) ||
                t.goal.toLowerCase().contains(q))
            .toList();
      }
    });
  }

  void _toggleTrainee(int id) {
    setState(() {
      if (_selectedTraineeIds.contains(id)) {
        _selectedTraineeIds.remove(id);
      } else {
        _selectedTraineeIds.add(id);
      }
    });
  }

  void _selectAllTrainees() {
    setState(() {
      if (_selectedTraineeIds.length == _filteredTrainees.length) {
        _selectedTraineeIds.clear();
      } else {
        _selectedTraineeIds = _filteredTrainees.map((t) => t.id).toSet();
      }
    });
  }

  List<Trainee> get _selectedTrainees =>
      _allTrainees.where((t) => _selectedTraineeIds.contains(t.id)).toList();

  Future<void> _saveWorkoutPlanToLocal({required bool isDraft}) async {
    final title =
        _workoutNameController.text.isEmpty ? 'Untitled workout' : _workoutNameController.text;
    final data = <String, dynamic>{
      'title': title,
      'difficulty': _difficulty,
      'createdAt': DateTime.now().toIso8601String(),
      'isDraft': isDraft,
    };
    final key = isDraft ? _workoutDraftsKey : _workoutTemplatesKey;
    final existing = _localStorage.getStringList(key);
    existing.add(jsonEncode(data));
    await _localStorage.saveStringList(key, existing);
  }

  Future<void> _createWorkoutPlanOnServer() async {
    try {
      final title =
          _workoutNameController.text.isEmpty ? 'Untitled workout' : _workoutNameController.text;
      final payload = <String, dynamic>{
        'title': title,
        'description': 'Created from Workout Builder',
      };
      await _buildersRepository.createExercisePlan(payload);
    } catch (_) {
      // Ignore server errors here; coach still keeps local draft/template
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: _buildStepContent(),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final titles = [
      'Workout Builder',
      'Choose Starting Point',
      'Build Workout',
      'When to assign',
      'Review',
    ];
    final subtitles = [
      'Step 1: Select trainees',
      'Step 2: Template or custom',
      'Step 3: Add & customize exercises',
      'Step 4: When to assign',
      'Step 5: Final check',
    ];
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textPrimary),
        ),
        onPressed: () {
          if (_currentStep > 1) {
            setState(() => _currentStep--);
          } else {
            widget.onBackPressed();
          }
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titles[_currentStep - 1],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            subtitles[_currentStep - 1],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        if (_currentStep == 3)
          IconButton(
            icon: Icon(Icons.description_outlined, color: AppColors.textMuted),
            onPressed: () {},
          ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    const steps = ['Trainees', 'Template', 'Exercises', 'Schedule', 'Review'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          for (int i = 0; i < 5; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  color: _currentStep > i ? AppColors.primary : AppColors.border,
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _currentStep > i + 1 || _currentStep == i + 1
                        ? AppColors.primary
                        : AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: _currentStep > i + 1
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _currentStep == i + 1 ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[i],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _currentStep >= i + 1 ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ],
            ),
            if (i < 4)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  color: _currentStep > i + 1 ? AppColors.primary : AppColors.border,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1SelectTrainees();
      case 2:
        return _buildStep2Template();
      case 3:
        return _buildStep3Exercises();
      case 4:
        return _buildStep4Schedule();
      case 5:
        return _buildStep5Review();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1SelectTrainees() {
    if (_traineesLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 20, color: AppColors.textMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: _filterTrainees,
                    decoration: const InputDecoration(
                      hintText: 'Search trainees...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _selectAllTrainees,
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _selectedTraineeIds.length == _filteredTrainees.length && _filteredTrainees.isNotEmpty
                        ? AppColors.primary
                        : Colors.white,
                    border: Border.all(
                      color: _selectedTraineeIds.length == _filteredTrainees.length && _filteredTrainees.isNotEmpty
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _selectedTraineeIds.length == _filteredTrainees.length && _filteredTrainees.isNotEmpty
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select all active trainees (${_filteredTrainees.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._filteredTrainees.map((t) => _buildTraineeCard(t)),
        ],
      ),
    );
  }

  Widget _buildTraineeCard(Trainee t) {
    final isSelected = _selectedTraineeIds.contains(t.id);
    final hasAlert = _traineeAlerts.contains(t.id);
    final condition = _traineeConditions[t.id];
    final adherenceColor = t.adherence >= 80
        ? AppColors.success
        : t.adherence >= 50
            ? AppColors.warning
            : AppColors.error;

    return GestureDetector(
      onTap: () => _toggleTrainee(t.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
              child: Text(
                t.avatar,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        t.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (hasAlert) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.error_outline, size: 16, color: AppColors.error),
                      ],
                    ],
                  ),
                  Text(
                    '${t.goal} · ${t.level}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (condition != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          condition,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${t.adherence}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: adherenceColor,
                  ),
                ),
                const Text(
                  'adherence',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2Template() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _currentStep = 3);
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF34D399), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 28),
                  SizedBox(height: 8),
                  Text(
                    'Start from Scratch',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Build a completely custom workout',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: Row(
              children: [
                Icon(Icons.description_outlined, color: AppColors.warning, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Drafts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Continue editing saved plans',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'SAVED TEMPLATES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildLocalWorkoutTemplates(),
        ],
      ),
    );
  }

  List<Widget> _buildLocalWorkoutTemplates() {
    final stored = _localStorage.getStringList(_workoutTemplatesKey);
    if (stored.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            "You don't have any saved templates",
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ];
    }

    return stored.map((raw) {
      Map<String, dynamic> data;
      try {
        data = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        data = const {};
      }
      return _buildLocalWorkoutTemplateCard(data);
    }).toList();
  }

  Widget _buildLocalWorkoutTemplateCard(Map<String, dynamic> t) {
    final title = (t['title'] as String?) ?? 'Untitled workout';
    final difficulty = (t['difficulty'] as String?) ?? 'Custom';
    final createdAt = (t['createdAt'] as String?);
    final createdLabel = createdAt != null
        ? 'Saved on ${DateTime.tryParse(createdAt)?.toLocal().toString().split(' ').first ?? ''}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  difficulty,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (createdLabel.isNotEmpty) ...[
            Text(
              createdLabel,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                setState(() => _currentStep = 3);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Use template →',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Exercises() {
    final totalExercises = _warmUpExercises.length + _mainExercises.length + _coolDownExercises.length;
    final totalMinutes = totalExercises * 2;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedTrainees.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.people_outline, size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    _selectedTrainees.map((t) => t.name).join(', '),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _workoutNameController,
            decoration: InputDecoration(
              hintText: 'Workout name *',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'DIFFICULTY LEVEL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Easy', 'Medium', 'Hard'].map((d) {
              final isSelected = _difficulty == d;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _difficulty = d),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PLAN INSTRUCTION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _planInstructionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'General instructions for this plan...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PLAN CAUTION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _planCautionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Safety warnings for plan...',
                        filled: true,
                        fillColor: AppColors.warningLight.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.warning.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatBox('$totalExercises EXERCISES'),
              const SizedBox(width: 8),
              _buildStatBox('~$totalMinutes MINUTES'),
              const SizedBox(width: 8),
              _buildStatBox('0 MUSCLES'),
            ],
          ),
          const SizedBox(height: 24),
          _buildExerciseSection(
            icon: Icons.local_fire_department,
            iconColor: AppColors.warning,
            title: 'Warm-up',
            count: _warmUpExercises.length,
            expanded: _warmUpExpanded,
            onToggle: () => setState(() => _warmUpExpanded = !_warmUpExpanded),
            exercises: _warmUpExercises,
            showAddButtons: true,
          ),
          const SizedBox(height: 12),
          _buildExerciseSection(
            icon: Icons.fitness_center,
            iconColor: AppColors.primary,
            title: 'Main Exercises',
            count: _mainExercises.length,
            expanded: _mainExpanded,
            onToggle: () => setState(() => _mainExpanded = !_mainExpanded),
            exercises: _mainExercises,
            showAddButtons: true,
          ),
          const SizedBox(height: 12),
          _buildExerciseSection(
            icon: Icons.favorite,
            iconColor: Colors.blue,
            title: 'Cool-down',
            count: _coolDownExercises.length,
            expanded: _coolDownExpanded,
            onToggle: () => setState(() => _coolDownExpanded = !_coolDownExpanded),
            exercises: _coolDownExercises,
            showAddButtons: true,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 20, color: AppColors.success),
                const SizedBox(width: 10),
                Text(
                  _workoutNameController.text.isEmpty ? 'Add a workout name' : 'Workout ready',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    required bool expanded,
    required VoidCallback onToggle,
    required List<String> exercises,
    required bool showAddButtons,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: iconColor),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            if (showAddButtons)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _addCustomExercise(exercises, title),
                        icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                        label: const Text(
                          'Add',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.primary, style: BorderStyle.solid),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openExerciseLibrarySheet(exercises, title),
                        icon: const Icon(Icons.search,
                            size: 18, color: AppColors.textMuted),
                        label: const Text(
                          'Library',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (exercises.isNotEmpty)
              ...exercises.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        e,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Future<void> _addCustomExercise(List<String> targetList, String sectionTitle) async {
    final name = await _showTextInputDialog(
      title: 'Add to $sectionTitle',
      hintText: 'e.g. Dynamic Warm-up',
    );
    if (name == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      targetList.add(trimmed);
    });
  }

  Future<void> _openExerciseLibrarySheet(
      List<String> targetList, String sectionTitle) async {
    await _loadExerciseLibrary();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        List<Exercise> visible = List.of(_exerciseLibrary);
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Exercise library',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 18, color: AppColors.textMuted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Search exercises...',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (q) {
                                setModalState(() {
                                  if (q.isEmpty) {
                                    visible = List.of(_exerciseLibrary);
                                  } else {
                                    final lower = q.toLowerCase();
                                    visible = _exerciseLibrary
                                        .where((e) => e.name.toLowerCase().contains(lower))
                                        .toList();
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_exerciseLibraryLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    else if (visible.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No exercises available.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: visible.length,
                          itemBuilder: (ctx, index) {
                            final ex = visible[index];
                            return ListTile(
                              title: Text(
                                ex.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: ex.description != null && ex.description!.isNotEmpty
                                  ? Text(
                                      ex.description!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  targetList.add(ex.name);
                                });
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _showTextInputDialog({
    required String title,
    required String hintText,
  }) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: hintText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop(controller.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep4Schedule() {
    final monthNames = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'DATE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'TIME',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (time != null) setState(() => _selectedTime = time);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'RECURRENCE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['One-time', 'Weekly', 'Bi-weekly', 'Monthly'].map((r) {
              final isSelected = _recurrence == r;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _recurrence = r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          r,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Remind trainee before session',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Switch(
                      value: _remindBefore,
                      onChanged: (v) => setState(() => _remindBefore = v),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Alert me if workout missed',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Switch(
                      value: _alertIfMissed,
                      onChanged: (v) => setState(() => _alertIfMissed = v),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        monthNames[_selectedDate.month - 1],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${_selectedDate.day}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _workoutNameController.text.isEmpty ? 'ok' : _workoutNameController.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_selectedTime.hour == 0 ? 12 : _selectedTime.hour > 12 ? _selectedTime.hour - 12 : _selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.hour >= 12 ? 'PM' : 'AM'} · 1 exercises · ~2 min',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$_recurrence session',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5Review() {
    final totalExercises = _warmUpExercises.length + _mainExercises.length + _coolDownExercises.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _workoutNameController.text.isEmpty ? 'ok' : _workoutNameController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$totalExercises exercises · ~${totalExercises * 2} min',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildReviewCard(
            title: 'Assigned to',
            onEdit: () => setState(() => _currentStep = 1),
            child: Row(
              children: [
                if (_selectedTrainees.isNotEmpty) ...[
                  CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      _selectedTrainees.first.avatar,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedTrainees.map((t) => t.name).join(', '),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ] else
                  const Text(
                    'No trainee selected',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            title: 'Schedule',
            onEdit: () => setState(() => _currentStep = 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${_getWeekday(_selectedDate)}, ${_getMonthName(_selectedDate)} ${_selectedDate.day}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                      Text(
                        '${_selectedTime.hour == 0 ? 12 : _selectedTime.hour > 12 ? _selectedTime.hour - 12 : _selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.hour >= 12 ? 'PM' : 'AM'} · $_recurrence',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            title: 'Exercises',
            onEdit: () => setState(() => _currentStep = 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ..._warmUpExercises.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                '1 sets × 5 min. — Rest —',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            title: 'Notifications',
            onEdit: () => setState(() => _currentStep = 4),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: AppColors.success),
                const SizedBox(width: 8),
                Text(
                  'Trainee will be reminded · ${_alertIfMissed ? '✓' : ''} Alert if missed',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await _saveWorkoutPlanToLocal(isDraft: false);
            },
            icon: Icon(Icons.folder_outlined, color: AppColors.primary),
            label: Text(
              'Save as Template',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await _saveWorkoutPlanToLocal(isDraft: true);
                    widget.onBackPressed();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Draft'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await _createWorkoutPlanOnServer();
                    widget.onBackPressed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Assign Workout →'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String title,
    required VoidCallback onEdit,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: onEdit,
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  String _getWeekday(DateTime d) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[d.weekday - 1];
  }

  String _getMonthName(DateTime d) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[d.month - 1];
  }

  Widget _buildBottomButton() {
    if (_currentStep == 5) return const SizedBox.shrink();

    String buttonText;
    VoidCallback? onPressed;
    switch (_currentStep) {
      case 1:
        buttonText = 'Continue with ${_selectedTraineeIds.length} trainee${_selectedTraineeIds.length == 1 ? '' : 's'} →';
        onPressed = _selectedTraineeIds.isEmpty
            ? null
            : () => setState(() => _currentStep = 2);
        break;
      case 2:
        return const SizedBox.shrink();
      case 3:
        buttonText = 'Continue to Schedule →';
        onPressed = () => setState(() => _currentStep = 4);
        break;
      case 4:
        buttonText = 'Review & Confirm →';
        onPressed = () => setState(() => _currentStep = 5);
        break;
      default:
        buttonText = 'Continue →';
        onPressed = () {};
    }

    if (_currentStep == 2) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: onPressed != null ? AppColors.primary : AppColors.textMuted,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
