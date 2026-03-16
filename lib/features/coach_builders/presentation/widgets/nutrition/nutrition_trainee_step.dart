import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidr/core/theme/app_colors.dart';
import '../../bloc/nutrition_builder_bloc.dart';
import '../../bloc/nutrition_builder_event.dart';
import '../../bloc/nutrition_builder_state.dart';
import '../trainee_card.dart';

class NutritionTraineeStep extends StatelessWidget {
  const NutritionTraineeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NutritionBuilderBloc, NutritionBuilderState>(
      builder: (context, state) {
        if (state.traineesLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.allTrainees.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline,
                    size: 64, color: AppColors.textMuted),
                const SizedBox(height: 12),
                const Text('No active trainees found',
                    style: TextStyle(
                        fontSize: 16, color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _SearchBar(),
              const SizedBox(height: 16),
              _SelectAllRow(state: state),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: state.filteredTrainees.length,
                  itemBuilder: (context, i) {
                    final t = state.filteredTrainees[i];
                    return TraineeCard(
                      trainee: t,
                      isSelected: state.selectedTraineeIds.contains(t.id),
                      onTap: () => context
                          .read<NutritionBuilderBloc>()
                          .add(NutritionToggleTrainee(t.id)),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (q) =>
          context.read<NutritionBuilderBloc>().add(NutritionFilterTrainees(q)),
      decoration: InputDecoration(
        hintText: 'Search trainees...',
        prefixIcon: const Icon(Icons.search),
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

class _SelectAllRow extends StatelessWidget {
  final NutritionBuilderState state;
  const _SelectAllRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final allSelected =
        state.selectedTraineeIds.length == state.filteredTrainees.length &&
            state.filteredTrainees.isNotEmpty;
    return GestureDetector(
      onTap: () => context
          .read<NutritionBuilderBloc>()
          .add(NutritionSelectAllTrainees()),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: allSelected ? AppColors.primary : Colors.white,
              border: Border.all(
                  color: allSelected ? AppColors.primary : AppColors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: allSelected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            'Select all active trainees (${state.filteredTrainees.length})',
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
