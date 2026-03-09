import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CoachChatSystemScreen extends StatelessWidget {
  const CoachChatSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 4, // Mock data count
        itemBuilder: (context, index) {
          final isUnread = index == 0;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(
                ['S', 'A', 'L', 'N'][index],
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            title: Text(
              ['Sarah M.', 'Ahmed K.', 'Lina R.', 'Nadia H.'][index],
              style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal),
            ),
            subtitle: Text(
              ['Got it, thanks!', 'When is our next session?', 'Loved the new plan.', 'I missed my workout yesterday.'][index],
              style: TextStyle(
                color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ['2m ago', '1h ago', 'Yesterday', 'Mon'][index],
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnread ? AppColors.primary : AppColors.textMuted,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isUnread)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  )
              ],
            ),
            onTap: () {
              // Navigate to specific chat thread
            },
          );
        },
      ),
    );
  }
}
