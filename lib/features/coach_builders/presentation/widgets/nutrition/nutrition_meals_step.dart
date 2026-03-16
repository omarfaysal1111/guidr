import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import '../../bloc/nutrition_builder_bloc.dart';
import '../../bloc/nutrition_builder_event.dart';
import '../../bloc/nutrition_builder_state.dart';

class NutritionMealsStep extends StatelessWidget {
  const NutritionMealsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionBuilderBloc, NutritionBuilderState>(
      builder: (context, state) {
        final selectedNames = state.allTrainees
            .where((t) => state.selectedTraineeIds.contains(t.id))
            .map((t) => t.name)
            .join(', ');

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (selectedNames.isNotEmpty)
              _TraineeBanner(names: selectedNames),
            const SizedBox(height: 16),
            _PlanNameField(name: state.planName),
            const SizedBox(height: 20),
            _StatsRow(totalMeals: state.totalMeals, kcal: state.estimatedKcal),
            const SizedBox(height: 24),
            _MealSection(
              section: MealSection.breakfast,
              label: 'Breakfast',
              icon: Icons.wb_sunny_outlined,
              iconColor: AppColors.warning,
              items: state.breakfast,
              expanded: state.breakfastExpanded,
            ),
            const SizedBox(height: 12),
            _MealSection(
              section: MealSection.lunch,
              label: 'Lunch',
              icon: Icons.wb_cloudy_outlined,
              iconColor: AppColors.primary,
              items: state.lunch,
              expanded: state.lunchExpanded,
            ),
            const SizedBox(height: 12),
            _MealSection(
              section: MealSection.dinner,
              label: 'Dinner',
              icon: Icons.nights_stay_outlined,
              iconColor: Colors.indigo,
              items: state.dinner,
              expanded: state.dinnerExpanded,
            ),
            const SizedBox(height: 12),
            _MealSection(
              section: MealSection.snacks,
              label: 'Snacks',
              icon: Icons.restaurant,
              iconColor: const Color(0xFF3B82F6),
              items: state.snacks,
              expanded: state.snacksExpanded,
            ),
            const SizedBox(height: 16),
            _StatusBanner(planName: state.planName),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

class _TraineeBanner extends StatelessWidget {
  final String names;
  const _TraineeBanner({required this.names});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_outline, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(names,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _PlanNameField extends StatelessWidget {
  final String name;
  const _PlanNameField({required this.name});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: name,
      onChanged: (v) => context
          .read<NutritionBuilderBloc>()
          .add(NutritionUpdateMetadata(planName: v)),
      decoration: InputDecoration(
        hintText: 'Nutrition plan name *',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int totalMeals;
  final int kcal;
  const _StatsRow({required this.totalMeals, required this.kcal});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(label: '$totalMeals MEALS'),
        const SizedBox(width: 8),
        _StatBox(label: '~$kcal KCAL'),
        const SizedBox(width: 8),
        _StatBox(label: '3 MACROS'),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  const _StatBox({required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
        ),
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  final MealSection section;
  final String label;
  final IconData icon;
  final Color iconColor;
  final List<String> items;
  final bool expanded;

  const _MealSection({
    required this.section,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.items,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => context
                .read<NutritionBuilderBloc>()
                .add(NutritionToggleMealSection(section)),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('$label (${items.length})',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                  ),
                  Icon(
                      expanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1),
            _AddButtons(section: section, sectionLabel: label),
            ...items.asMap().entries.map((e) => _MealItemRow(
                section: section,
                index: e.key,
                name: e.value,
                dotColor: iconColor)),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _MealItemRow extends StatelessWidget {
  final MealSection section;
  final int index;
  final String name;
  final Color dotColor;

  const _MealItemRow({
    required this.section,
    required this.index,
    required this.name,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textPrimary)),
          ),
          InkWell(
            onTap: () => context
                .read<NutritionBuilderBloc>()
                .add(NutritionRemoveMealItem(section, index)),
            child:
                const Icon(Icons.close, size: 16, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _AddButtons extends StatelessWidget {
  final MealSection section;
  final String sectionLabel;
  const _AddButtons({required this.section, required this.sectionLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showAddCustomDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showLibrarySheet(context),
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Library'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3B82F6),
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCustomDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final bloc = context.read<NutritionBuilderBloc>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to $sectionLabel'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
              hintText: 'e.g. Greek yogurt with berries',
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                bloc.add(NutritionAddMealItem.custom(section, name));
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Add',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLibrarySheet(BuildContext context) {
    final bloc = context.read<NutritionBuilderBloc>();
    bloc.add(NutritionLoadIngredientLibrary());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollCtrl) {
            return BlocProvider.value(
              value: bloc,
              child: _LibraryContent(
                  section: section,
                  sectionLabel: sectionLabel,
                  scrollController: scrollCtrl),
            );
          },
        );
      },
    );
  }
}

class _LibraryContent extends StatefulWidget {
  final MealSection section;
  final String sectionLabel;
  final ScrollController scrollController;
  const _LibraryContent({
    required this.section,
    required this.sectionLabel,
    required this.scrollController,
  });

  @override
  State<_LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<_LibraryContent> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionBuilderBloc, NutritionBuilderState>(
      builder: (context, state) {
        final filtered = _query.isEmpty
            ? state.ingredientLibrary
            : state.ingredientLibrary
                .where(
                    (i) => i.name.toLowerCase().contains(_query.toLowerCase()))
                .toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text('${widget.sectionLabel} Library',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextField(
                onChanged: (q) => setState(() => _query = q),
                decoration: InputDecoration(
                  hintText: 'Search ingredients...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (state.libraryLoading)
              const Expanded(
                  child: Center(child: CircularProgressIndicator()))
            else if (filtered.isEmpty)
              const Expanded(
                  child: Center(
                      child: Text('No ingredients available.',
                          style: TextStyle(color: AppColors.textSecondary))))
            else
              Expanded(
                child: ListView.builder(
                  controller: widget.scrollController,
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final ing = filtered[i];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.restaurant,
                            size: 20, color: AppColors.primary),
                      ),
                      title: Text(ing.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          '${ing.calories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                      trailing: const Icon(Icons.add_circle_outline,
                          color: AppColors.primary),
                      onTap: () {
                        context.read<NutritionBuilderBloc>().add(
                            NutritionAddMealItem.fromLibrary(
                                widget.section, ing));
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String planName;
  const _StatusBanner({required this.planName});

  @override
  Widget build(BuildContext context) {
    final ready = planName.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ready ? AppColors.successLight : AppColors.warningLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: (ready ? AppColors.success : AppColors.warning)
                .withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(ready ? Icons.check_circle : Icons.info_outline,
              size: 20, color: ready ? AppColors.success : AppColors.warning),
          const SizedBox(width: 10),
          Text(
            ready ? 'Nutrition plan ready' : 'Add a nutrition plan name',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ready ? AppColors.success : AppColors.warning),
          ),
        ],
      ),
    );
  }
}
