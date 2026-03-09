import 'package:flutter/material.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/trainees/domain/entities/trainee.dart';
import 'package:guidr/features/trainees/domain/repositories/trainees_repository.dart';

class NutritionPlanBuilderScreen extends StatefulWidget {
  final VoidCallback onBackPressed;

  const NutritionPlanBuilderScreen({super.key, required this.onBackPressed});

  @override
  State<NutritionPlanBuilderScreen> createState() => _NutritionPlanBuilderScreenState();
}

class _NutritionPlanBuilderScreenState extends State<NutritionPlanBuilderScreen> {
  int _currentStep = 1;
  List<Trainee> _allTrainees = [];
  List<Trainee> _filteredTrainees = [];
  Set<int> _selectedTraineeIds = {};
  bool _traineesLoading = true;

  // Step 2
  String? _selectedNutritionTemplateId;

  // Step 3
  final _planNameController = TextEditingController();
  List<String> _breakfastMeals = [];
  List<String> _lunchMeals = [];
  List<String> _dinnerMeals = [];
  List<String> _snackMeals = [];
  bool _breakfastExpanded = true;
  bool _lunchExpanded = false;
  bool _dinnerExpanded = false;
  bool _snacksExpanded = true;

  // Step 4
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _recurrence = 'One-time';
  bool _remindBefore = true;
  bool _alertIfMissed = true;

  @override
  void initState() {
    super.initState();
    _loadTrainees();
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
    _planNameController.dispose();
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

  int get _totalMeals =>
      _breakfastMeals.length + _lunchMeals.length + _dinnerMeals.length + _snackMeals.length;

  int get _estimatedKcal => _totalMeals * 400;

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
      'Nutrition Plan Builder',
      'Choose Starting Point',
      'Build Nutrition Plan',
      'When to assign',
      'Review',
    ];
    final subtitles = [
      'Step 1: Select trainees',
      'Step 2: Template or custom',
      'Step 3: Add & customize meals',
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
    const steps = ['Trainees', 'Template', 'Meals', 'Schedule', 'Review'];
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
        return _buildStep3Meals();
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
    final templates = [
      {
        'id': '1',
        'title': 'High Protein — Muscle Building',
        'difficulty': 'Intermediate',
        'difficultyColor': AppColors.success,
        'desc': 'High protein · ~2200 kcal',
        'tags': ['Chicken breast', 'Eggs', 'Greek yogurt', 'Whey', 'Macros'],
        'count': '4 meals',
      },
      {
        'id': '2',
        'title': 'Low Carb — Fat Loss',
        'difficulty': 'Advanced',
        'difficultyColor': AppColors.error,
        'desc': 'Low carb · ~1800 kcal',
        'tags': ['Avocado', 'Salmon', 'Leafy greens', 'Nuts', 'Macros'],
        'count': '4 meals',
      },
      {
        'id': '3',
        'title': 'Balanced — Maintenance',
        'difficulty': 'Beginner',
        'difficultyColor': Colors.blue,
        'desc': 'Balanced macros · ~2000 kcal',
        'tags': ['Whole grains', 'Lean protein', 'Vegetables', 'Fruits', 'Macros'],
        'count': '5 meals',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _selectedNutritionTemplateId = null);
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
                    'Build a completely custom nutrition plan',
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
          ...templates.map((t) => _buildTemplateCard(t)),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> t) {
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
                  t['title'] as String,
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
                  color: (t['difficultyColor'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  t['difficulty'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: t['difficultyColor'] as Color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            t['desc'] as String,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (t['tags'] as List<String>)
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          Text(
            t['count'] as String,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedNutritionTemplateId = t['id'] as String;
                  if (_selectedNutritionTemplateId == '1') {
                    _breakfastMeals = ['Eggs & spinach', 'Greek yogurt'];
                    _lunchMeals = ['Grilled chicken salad', 'Brown rice'];
                    _dinnerMeals = ['Salmon with vegetables', 'Cottage cheese'];
                    _snackMeals = ['Protein shake', 'Almonds'];
                  } else if (_selectedNutritionTemplateId == '2') {
                    _breakfastMeals = ['Avocado eggs', 'Bulletproof coffee'];
                    _lunchMeals = ['Grilled salmon', 'Leafy green salad'];
                    _dinnerMeals = ['Chicken stir-fry', 'Broccoli'];
                    _snackMeals = ['Cheese', 'Macadamia nuts'];
                  } else if (_selectedNutritionTemplateId == '3') {
                    _breakfastMeals = ['Oatmeal with berries', 'Whole grain toast'];
                    _lunchMeals = ['Turkey wrap', 'Mixed vegetables'];
                    _dinnerMeals = ['Grilled fish', 'Quinoa', 'Steamed veggies'];
                    _snackMeals = ['Apple', 'Hummus with carrots'];
                  }
                  _currentStep = 3;
                });
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

  Widget _buildStep3Meals() {
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
            controller: _planNameController,
            decoration: InputDecoration(
              hintText: 'Nutrition plan name *',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatBox('$_totalMeals MEALS'),
              const SizedBox(width: 8),
              _buildStatBox('~$_estimatedKcal KCAL'),
              const SizedBox(width: 8),
              _buildStatBox('3 MACROS'),
            ],
          ),
          const SizedBox(height: 24),
          _buildMealSection(
            icon: Icons.wb_sunny_outlined,
            iconColor: AppColors.warning,
            title: 'Breakfast',
            count: _breakfastMeals.length,
            expanded: _breakfastExpanded,
            onToggle: () => setState(() => _breakfastExpanded = !_breakfastExpanded),
            meals: _breakfastMeals,
          ),
          const SizedBox(height: 12),
          _buildMealSection(
            icon: Icons.wb_cloudy_outlined,
            iconColor: AppColors.primary,
            title: 'Lunch',
            count: _lunchMeals.length,
            expanded: _lunchExpanded,
            onToggle: () => setState(() => _lunchExpanded = !_lunchExpanded),
            meals: _lunchMeals,
          ),
          const SizedBox(height: 12),
          _buildMealSection(
            icon: Icons.nights_stay_outlined,
            iconColor: Colors.indigo,
            title: 'Dinner',
            count: _dinnerMeals.length,
            expanded: _dinnerExpanded,
            onToggle: () => setState(() => _dinnerExpanded = !_dinnerExpanded),
            meals: _dinnerMeals,
          ),
          const SizedBox(height: 12),
          _buildMealSection(
            icon: Icons.restaurant,
            iconColor: Colors.blue,
            title: 'Snacks',
            count: _snackMeals.length,
            expanded: _snacksExpanded,
            onToggle: () => setState(() => _snacksExpanded = !_snacksExpanded),
            meals: _snackMeals,
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
                  _planNameController.text.isEmpty ? 'Add a nutrition plan name' : 'Nutrition plan ready',
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

  Widget _buildMealSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    required bool expanded,
    required VoidCallback onToggle,
    required List<String> meals,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.add, size: 18, color: AppColors.primary),
                      label: Text(
                        'Add',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary, style: BorderStyle.solid),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.search, size: 18, color: AppColors.textMuted),
                      label: Text(
                        'Library',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (meals.isNotEmpty)
              ...meals.map(
                (m) => Padding(
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
                        m,
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
                      'Alert me if plan missed',
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
                        _planNameController.text.isEmpty ? 'ok' : _planNameController.text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$_totalMeals meals · ~$_estimatedKcal kcal',
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
    final allMeals = [
      ..._breakfastMeals.map((m) => ('Breakfast', m)),
      ..._lunchMeals.map((m) => ('Lunch', m)),
      ..._dinnerMeals.map((m) => ('Dinner', m)),
      ..._snackMeals.map((m) => ('Snacks', m)),
    ];

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
                  _planNameController.text.isEmpty ? 'ok' : _planNameController.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$_totalMeals meals · ~$_estimatedKcal kcal',
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
            title: 'Meals',
            onEdit: () => setState(() => _currentStep = 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...allMeals.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.$2,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                item.$1,
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
            onPressed: () {},
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
                  onPressed: () => widget.onBackPressed(),
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
                  onPressed: () => widget.onBackPressed(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Assign Nutrition Plan →'),
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
