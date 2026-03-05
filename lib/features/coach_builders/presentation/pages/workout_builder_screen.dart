import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WorkoutBuilderScreen extends StatefulWidget {
  final VoidCallback onBackPressed;

  const WorkoutBuilderScreen({super.key, required this.onBackPressed});

  @override
  State<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends State<WorkoutBuilderScreen> {
  final List<String> _exercises = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onBackPressed,
        ),
        title: const Text('New Workout'),
        actions: [
          TextButton(
            onPressed: () {
              // Save
              widget.onBackPressed();
            },
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextFormField(
              decoration: const InputDecoration(
                hintText: 'Workout Title',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          const Divider(),
          Expanded(
            child: _exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text('No exercises added yet', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.drag_handle),
                        title: Text(_exercises[index]),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _exercises.add('Exercise ${_exercises.length + 1}');
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          )
        ],
      ),
    );
  }
}
