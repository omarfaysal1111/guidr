// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/coach_builders/domain/entities/ingredient.dart';
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
            _StatsRow(state: state),
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

// ── Trainee banner ────────────────────────────────────────────────────────────

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

// ── Plan name field ───────────────────────────────────────────────────────────

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

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final NutritionBuilderState state;
  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasRealData = state.totalCalories > 0;
    return Row(
      children: [
        _StatBox(label: '${state.totalMeals}', sub: 'MEALS'),
        const SizedBox(width: 8),
        _StatBox(
          label: hasRealData
              ? state.totalCalories.toStringAsFixed(0)
              : '~${state.estimatedKcal}',
          sub: 'KCAL',
          highlight: hasRealData,
        ),
        const SizedBox(width: 8),
        _StatBox(
          label: hasRealData
              ? '${state.totalProtein.toStringAsFixed(0)}g'
              : '—',
          sub: 'PROTEIN',
          highlight: hasRealData,
        ),
        const SizedBox(width: 8),
        _StatBox(
          label: hasRealData
              ? '${state.totalCarbs.toStringAsFixed(0)}g'
              : '—',
          sub: 'CARBS',
          highlight: hasRealData,
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String sub;
  final bool highlight;
  const _StatBox({required this.label, required this.sub, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: highlight ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: highlight
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: highlight
                        ? AppColors.primary
                        : AppColors.textPrimary)),
            Text(sub,
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

// ── Meal section ──────────────────────────────────────────────────────────────

class _MealSection extends StatelessWidget {
  final MealSection section;
  final String label;
  final IconData icon;
  final Color iconColor;
  final List<MealIngredientEntry> items;
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
    // Total kcal for this section
    final sectionKcal = items.fold<double>(0, (s, e) => s + e.calories);
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$label (${items.length})',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        if (sectionKcal > 0)
                          Text(
                            '${sectionKcal.toStringAsFixed(0)} kcal',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                          ),
                      ],
                    ),
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
                entry: e.value,
                dotColor: iconColor)),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ── Meal item row ─────────────────────────────────────────────────────────────

class _MealItemRow extends StatelessWidget {
  final MealSection section;
  final int index;
  final MealIngredientEntry entry;
  final Color dotColor;

  const _MealItemRow({
    required this.section,
    required this.index,
    required this.entry,
    required this.dotColor,
  });

  void _updateQty(BuildContext context, double newQty) {
    if (newQty <= 0) return;
    context.read<NutritionBuilderBloc>().add(
        NutritionUpdateMealItemQty(section, index, newQty));
  }

  void _showQtyDialog(BuildContext context) {
    final ctrl =
        TextEditingController(text: entry.quantityG.toStringAsFixed(0));
    final bloc = context.read<NutritionBuilderBloc>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(entry.name,
            style: const TextStyle(fontSize: 15),
            overflow: TextOverflow.ellipsis),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            suffixText: 'g',
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text) ?? entry.quantityG;
              if (v > 0) {
                bloc.add(NutritionUpdateMealItemQty(section, index, v));
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(entry.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
              ),
              // Remove button
              InkWell(
                onTap: () => context
                    .read<NutritionBuilderBloc>()
                    .add(NutritionRemoveMealItem(section, index)),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.close,
                      size: 15, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          if (entry.isFromLibrary) ...[
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  // Macro chips
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _MacroChip(
                            '${entry.calories.toStringAsFixed(0)} kcal',
                            const Color(0xFFF97316)),
                        _MacroChip(
                            'P ${entry.protein.toStringAsFixed(1)}g',
                            const Color(0xFF8B5CF6)),
                        _MacroChip(
                            'C ${entry.carbs.toStringAsFixed(1)}g',
                            const Color(0xFF0EA5E9)),
                        _MacroChip(
                            'F ${entry.fat.toStringAsFixed(1)}g',
                            const Color(0xFFEF4444)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Quantity stepper
                  _QtyPill(
                    qty: entry.quantityG,
                    onDecrement: () =>
                        _updateQty(context, entry.quantityG - 10),
                    onIncrement: () =>
                        _updateQty(context, entry.quantityG + 10),
                    onEdit: () => _showQtyDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MacroChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}

// ── Quantity pill ─────────────────────────────────────────────────────────────

class _QtyPill extends StatelessWidget {
  final double qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onEdit;

  const _QtyPill({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillBtn(icon: Icons.remove, onTap: onDecrement),
          GestureDetector(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '${qty.toStringAsFixed(0)}g',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
            ),
          ),
          _PillBtn(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _PillBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 14, color: AppColors.textSecondary),
      ),
    );
  }
}

// ── Add buttons ───────────────────────────────────────────────────────────────

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
              label: const Text('Add Custom'),
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
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
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
          initialChildSize: 0.75,
          maxChildSize: 0.95,
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

// ── Library bottom sheet ──────────────────────────────────────────────────────

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
                          style:
                              TextStyle(color: AppColors.textSecondary))))
            else
              Expanded(
                child: ListView.builder(
                  controller: widget.scrollController,
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final ing = filtered[i];
                    return _IngredientLibraryTile(
                      ingredient: ing,
                      section: widget.section,
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

// ── Library tile with nutritional facts ──────────────────────────────────────

class _IngredientLibraryTile extends StatelessWidget {
  final Ingredient ingredient;
  final MealSection section;
  const _IngredientLibraryTile(
      {required this.ingredient, required this.section});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showQtyDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restaurant,
                  size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ingredient.name,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  // Macro chips row
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _FactChip(
                          '${ingredient.calories.toStringAsFixed(0)} kcal',
                          const Color(0xFFF97316)),
                      _FactChip('P ${ingredient.protein.toStringAsFixed(1)}g',
                          const Color(0xFF8B5CF6)),
                      _FactChip(
                          'C ${ingredient.carbohydrates.toStringAsFixed(1)}g',
                          const Color(0xFF0EA5E9)),
                      _FactChip('F ${ingredient.fat.toStringAsFixed(1)}g',
                          const Color(0xFFEF4444)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'per ${ingredient.servingQuantityG.toStringAsFixed(0)}g serving',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Add',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showQtyDialog(BuildContext context) {
    final bloc = context.read<NutritionBuilderBloc>();
    final defaultQty = ingredient.servingQuantityG;
    final ctrl =
        TextEditingController(text: defaultQty.toStringAsFixed(0));

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ingredient.name,
            style: const TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nutritional facts card
            _NutritionalFactsCard(ingredient: ingredient),
            const SizedBox(height: 16),
            const Text('Set quantity (grams):',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                suffixText: 'g',
                hintText:
                    'Default: ${defaultQty.toStringAsFixed(0)}g',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty =
                  double.tryParse(ctrl.text) ?? defaultQty;
              bloc.add(NutritionAddMealItem.fromLibrary(
                  section, ingredient, qty > 0 ? qty : defaultQty));
              Navigator.pop(ctx);
              Navigator.pop(context); // close the library sheet
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            child: const Text('Add to Meal',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Nutritional facts card (used in dialog) ───────────────────────────────────

class _NutritionalFactsCard extends StatelessWidget {
  final Ingredient ingredient;
  const _NutritionalFactsCard({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition Facts · per ${ingredient.servingQuantityG.toStringAsFixed(0)}g',
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          _FactRow('Calories',
              '${ingredient.calories.toStringAsFixed(0)} kcal',
              bold: true),
          _FactRow('Protein',
              '${ingredient.protein.toStringAsFixed(1)} g'),
          _FactRow('Carbohydrates',
              '${ingredient.carbohydrates.toStringAsFixed(1)} g'),
          _FactRow(
              'Fat', '${ingredient.fat.toStringAsFixed(1)} g'),
          if (ingredient.water != null)
            _FactRow('Water',
                '${ingredient.water!.toStringAsFixed(2)} g'),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _FactRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      bold ? FontWeight.w700 : FontWeight.normal,
                  color: AppColors.textPrimary)),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      bold ? FontWeight.w700 : FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  final String label;
  final Color color;
  const _FactChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}

// ── Status banner ─────────────────────────────────────────────────────────────

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
              size: 20,
              color: ready ? AppColors.success : AppColors.warning),
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
