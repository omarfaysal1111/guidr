import 'package:flutter/material.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/features/trainee_app/domain/entities/trainee_dashboard_today.dart';
import 'package:guidr/features/trainee_app/domain/repositories/trainee_app_repository.dart';
import '../../../../core/theme/app_colors.dart';

class TraineeNutritionScreen extends StatefulWidget {
  const TraineeNutritionScreen({super.key});

  @override
  State<TraineeNutritionScreen> createState() => _TraineeNutritionScreenState();
}

class _TraineeNutritionScreenState extends State<TraineeNutritionScreen> {
  TraineeDashboardToday? _dashboard;
  bool _loading = true;
  String? _error;
  final Map<String, bool> _mealCompleted = {
    'Breakfast': false,
    'Lunch': false,
    'Snack': false,
    'Dinner': false,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = di.sl<TraineeAppRepository>();
      final dashboard = await repo.getDashboardToday();
      setState(() {
        _dashboard = dashboard;
        _loading = false;
        // Initialize completion from calories (very rough heuristic)
        final c = dashboard.todayNutritionSummary.caloriesConsumed;
        _mealCompleted['Breakfast'] = c > 0;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = _dashboard;
    final summary = dashboard?.todayNutritionSummary;
    final coachName = dashboard?.coach.fullName;
    final caloriesConsumed = summary?.caloriesConsumed ?? 0;
    final caloriesTarget = summary?.caloriesTarget ?? 0;
    final caloriesRemaining =
        caloriesTarget > 0 ? (caloriesTarget - caloriesConsumed).clamp(0, caloriesTarget) : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 20,
        title:  Text(
          'guider.',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon:  Icon(Icons.notifications_none_outlined,
                color: AppColors.textPrimary),
            onPressed: () {},
          ),
          Padding(
            padding:  EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child:  Icon(Icons.person, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: _loading
            ?  Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _error != null
                ? ListView(
                    padding:  EdgeInsets.all(20),
                    children: [
                      Text(
                        _error!,
                        style:  TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                       SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _load,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:  Text('Retry'),
                      ),
                    ],
                  )
                : ListView(
                    padding:
                         EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                       SizedBox(height: 8),
                      // Header
                      Text(
                        "Today's Nutrition",
                        style:  TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                       SizedBox(height: 4),
                      Text(
                        coachName != null && coachName.isNotEmpty
                            ? 'Assigned by $coachName'
                            : 'Assigned by your coach',
                        style:  TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                       SizedBox(height: 4),
                       Text(
                        '1/4 meals logged',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                       SizedBox(height: 16),

                      // Main nutrition card
                      Container(
                        padding:  EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CircularProgressIndicator(
                                        value: 1,
                                        strokeWidth: 8,
                                        backgroundColor: AppColors.surface,
                                        valueColor:
                                             AlwaysStoppedAnimation<Color>(
                                                AppColors.surface),
                                      ),
                                      CircularProgressIndicator(
                                        value: caloriesTarget > 0
                                            ? caloriesConsumed /
                                                caloriesTarget
                                            : 0,
                                        strokeWidth: 8,
                                        backgroundColor: Colors.transparent,
                                        valueColor:
                                             AlwaysStoppedAnimation<Color>(
                                                AppColors.primary),
                                      ),
                                      Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '$caloriesConsumed',
                                              style:  TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              '/${caloriesTarget > 0 ? caloriesTarget : 0} cal',
                                              style:  TextStyle(
                                                fontSize: 11,
                                                color:
                                                    AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                 SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _MacroLegendRow(
                                        label: 'Protein',
                                        value: summary != null
                                            ? '${summary.proteinGrams}/${summary.proteinTarget}g'
                                            : '—',
                                        color: Colors.purple,
                                      ),
                                      _MacroLegendRow(
                                        label: 'Carbs',
                                        value: summary != null
                                            ? '${summary.carbsGrams}/${summary.carbsTarget}g'
                                            : '—',
                                        color: Colors.orange,
                                      ),
                                      _MacroLegendRow(
                                        label: 'Fat',
                                        value: summary != null
                                            ? '${summary.fatGrams}/${summary.fatTarget}g'
                                            : '—',
                                        color: Colors.redAccent,
                                      ),
                                       SizedBox(height: 6),
                                      Text(
                                        '$caloriesRemaining cal remaining',
                                        style:  TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                             SizedBox(height: 16),

                            // Water intake
                            Text(
                              'Water Intake',
                              style:  TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                             SizedBox(height: 8),
                            Row(
                              children: [
                                Wrap(
                                  spacing: 6,
                                  children: List.generate(
                                    8,
                                    (index) => Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: index < 5
                                            ? AppColors.primaryLight
                                            : AppColors.surface,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.local_drink,
                                        size: 16,
                                        color: index < 5
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                 Spacer(),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: AppColors.primaryLight,
                                    padding:  EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child:  Text(
                                    '+250ml',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                       SizedBox(height: 20),

                      // Meals list (structure only, using total calories)
                       Text(
                        'Meals',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                       SizedBox(height: 10),
                      _mealCard(
                        title: summary!.meals[0].name,
                        description: summary.meals[0].name+summary.meals[1].name+summary.meals[0].name,
                        kcal: caloriesConsumed > 0
                            ? '$caloriesConsumed cal'
                            : '0 cal',
                        logged: _mealCompleted['Breakfast'] ?? false,
                        onToggle: () => _toggleMeal('Breakfast', 1),
                      ),
                       SizedBox(height: 10),
                      _mealCard(
                        title: 'Lunch',
                        description:
                            'Grilled Chicken Breast, Brown Rice, Steamed Broccoli',
                        kcal: '0 cal',
                        logged: _mealCompleted['Lunch'] ?? false,
                        onToggle: () => _toggleMeal('Lunch', 2),
                      ),
                       SizedBox(height: 10),
                      _mealCard(
                        title: 'Snack',
                        description: 'Greek Yogurt, Mixed Berries',
                        kcal: '0 cal',
                        logged: _mealCompleted['Snack'] ?? false,
                        onToggle: () => _toggleMeal('Snack', 3),
                      ),
                       SizedBox(height: 10),
                      _mealCard(
                        title: 'Dinner',
                        description:
                            'Salmon Fillet, Sweet Potato, Mixed Salad + Olive Oil',
                        kcal: '0 cal',
                        logged: _mealCompleted['Dinner'] ?? false,
                        onToggle: () => _toggleMeal('Dinner', 4),
                      ),

                       SizedBox(height: 24),

                      // Coach Notes & Tips (static scaffolding)
                      Container(
                        padding:  EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                              'Coach Notes & Tips',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                             SizedBox(height: 10),
                            _tipRow(
                              icon: Icons.lightbulb_outline,
                              label: 'Daily Tip',
                              text:
                                  'Try to spread protein intake across all meals for better absorption. Aim for 30–40g per meal.',
                              color: AppColors.primary,
                            ),
                             SizedBox(height: 8),
                            _tipRow(
                              icon: Icons.notifications_none_outlined,
                              label: 'Reminder',
                              text:
                                  'Avoid dairy within 1 hour of iron-rich meals for better nutrient absorption.',
                              color: AppColors.warning,
                            ),
                             SizedBox(height: 12),
                             Text(
                              'Your Notes',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                             SizedBox(height: 6),
                            Container(
                              padding:  EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child:  Text(
                                'Add a note about today’s meals…',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                       SizedBox(height: 20),

                      // Logging streak + badges section (using real streak where available)
                      if (dashboard != null) ...[
                        Container(
                          padding:  EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                '8-Day Logging Streak',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                               SizedBox(height: 6),
                               Text(
                                'Log all meals to keep your streak alive!',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                               SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child:  LinearProgressIndicator(
                                  value: 0.8,
                                  minHeight: 6,
                                  backgroundColor: AppColors.surface,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          AppColors.primary),
                                ),
                              ),
                               SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children:  [
                                  Text(
                                    '8 days ago',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'Today',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                         SizedBox(height: 16),
                        Container(
                          padding:  EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                'Nutrition Badges',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                               SizedBox(height: 10),
                              Row(
                                children: [
                                  _badgeChip('Clean Eater', earned: true),
                                  _badgeChip('Protein Pro', earned: true),
                                  _badgeChip('On Target', earned: false),
                                  _badgeChip('Hydrated', earned: false),
                                ],
                              ),
                               SizedBox(height: 10),
                               Text(
                                '3 meals left to log — you’ve got this!',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }

  Widget _mealCard({
    required String title,
    required String description,
    required String kcal,
    required bool logged,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onToggle,
      child: Container(
        padding:  EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              logged ? Icons.check_circle : Icons.radio_button_unchecked,
              color: logged ? AppColors.success : AppColors.textSecondary,
            ),
             SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:  TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                   SizedBox(height: 4),
                  Text(
                    description,
                    style:  TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
             SizedBox(width: 8),
            Text(
              kcal,
              style:  TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipRow({
    required IconData icon,
    required String label,
    required String text,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:  EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
         SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:  TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
               SizedBox(height: 4),
              Text(
                text,
                style:  TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badgeChip(String label, {required bool earned}) {
    return Container(
      margin:  EdgeInsets.only(right: 8),
      padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: earned ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: earned ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: earned ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Future<void> _toggleMeal(String key, int mealId) async {
    final current = _mealCompleted[key] ?? false;
    // Optimistic update
    setState(() {
      _mealCompleted[key] = !current;
    });

    try {
      final repo = di.sl<TraineeAppRepository>();
      await repo.completeMeal(mealId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !current ? 'Meal marked as completed.' : 'Meal marked as not completed.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Revert on error
      setState(() {
        _mealCompleted[key] = current;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }
}

class _MacroLegendRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

   _MacroLegendRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
           SizedBox(width: 6),
          Text(
            label,
            style:  TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
           Spacer(),
          Text(
            value,
            style:  TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
