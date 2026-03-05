import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TraineeWorkoutScreen extends StatefulWidget {
  const TraineeWorkoutScreen({super.key});

  @override
  State<TraineeWorkoutScreen> createState() => _TraineeWorkoutScreenState();
}

class _TraineeWorkoutScreenState extends State<TraineeWorkoutScreen> {
  final List<bool> _completedSets = List.generate(4, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upper Body Power'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A. Barbell Bench Press',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Focus on explosive concentric phase. Keep shoulders retracted.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Video Placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
              ),
            ),
            const SizedBox(height: 32),

            // Sets
            const Text('Sets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(4, (index) => _buildSetRow(index, '8', '185 lbs')),
            
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {},
              child: const Text('Next Exercise'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(int index, String reps, String weight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInput(reps, 'Reps'),
                _buildInput(weight, 'Weight'),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              setState(() {
                _completedSets[index] = !_completedSets[index];
              });
            },
            icon: Icon(
              _completedSets[index] ? Icons.check_circle : Icons.circle_outlined,
              color: _completedSets[index] ? AppColors.success : AppColors.border,
              size: 28,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInput(String hint, String label) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(hint, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
