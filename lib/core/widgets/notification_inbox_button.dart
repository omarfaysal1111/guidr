import 'package:flutter/material.dart';
import 'package:guidr/core/theme/app_colors.dart';

/// A single line in the notification inbox popover.
class AppInboxNotification {
  const AppInboxNotification({
    required this.title,
    required this.body,
    required this.accent,
    this.icon = Icons.notifications_none_outlined,
    this.onTap,
  });

  final String title;
  final String body;
  final Color accent;
  final IconData icon;
  final VoidCallback? onTap;
}

/// Sample notifications for trainee surfaces until a backend inbox exists.
List<AppInboxNotification> demoTraineeInboxNotifications() {
  return const [
    AppInboxNotification(
      title: 'Coach message',
      body: 'Great progress this week! Let us adjust your next block.',
      accent: Color(0xFF8B5CF6),
      icon: Icons.chat_bubble_outline,
    ),
    AppInboxNotification(
      title: 'Workout completed',
      body: 'You finished today’s session. +7 day streak.',
      accent: AppColors.success,
      icon: Icons.fitness_center,
    ),
    AppInboxNotification(
      title: 'Nutrition reminder',
      body: 'Log lunch before 2pm to keep your plan on track.',
      accent: AppColors.warning,
      icon: Icons.restaurant_outlined,
    ),
  ];
}

/// Bell control that opens a platform-style notification panel under the icon.
class NotificationInboxButton extends StatefulWidget {
  const NotificationInboxButton({
    super.key,
    required this.items,
    this.badgeCount,
    this.headerTitle = 'Notifications',
    this.coachStyle = false,
  });

  final List<AppInboxNotification> items;
  final int? badgeCount;
  final String headerTitle;

  /// When true, uses the circular outlined bell used on coach home.
  final bool coachStyle;

  @override
  State<NotificationInboxButton> createState() =>
      _NotificationInboxButtonState();
}

class _NotificationInboxButtonState extends State<NotificationInboxButton> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }

  void _toggle() {
    if (_entry != null) {
      _removeOverlay();
      return;
    }
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) {
        final size = MediaQuery.sizeOf(ctx);
        final rtl = Directionality.of(ctx) == TextDirection.rtl;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _removeOverlay();
                  if (mounted) setState(() {});
                },
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: rtl ? Alignment.bottomLeft : Alignment.bottomRight,
              followerAnchor: rtl ? Alignment.topLeft : Alignment.topRight,
              offset: const Offset(0,6),
              child: Material(
                elevation: 12,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(14),
                color: AppColors.card,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: (size.width - 32).clamp(250, 350),
                    maxHeight: size.height * 0.55,
                  ),
                  child: _InboxPanel(
                    headerTitle: widget.headerTitle,
                    items: widget.items,
                    onItemTap: () {
                      _removeOverlay();
                      if (mounted) setState(() {});
                    },
                    listMaxHeight: (size.height * 0.4).clamp(200.0, 400.0),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    _entry = entry;
    overlay.insert(entry);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final showBadge = widget.badgeCount != null && widget.badgeCount! > 0;
    final label = !showBadge
        ? null
        : (widget.badgeCount! > 99 ? '99+' : '${widget.badgeCount}');

    return CompositedTransformTarget(
      link: _link,
      child: widget.coachStyle
          ? Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: _toggle,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    if (showBadge)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              label!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Notifications',
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: _toggle,
                ),
                if (showBadge)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Text(
                        label!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _InboxPanel extends StatelessWidget {
  const _InboxPanel({
    required this.headerTitle,
    required this.items,
    required this.onItemTap,
    required this.listMaxHeight,
  });

  final String headerTitle;
  final List<AppInboxNotification> items;
  final VoidCallback onItemTap;
  final double listMaxHeight;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: headerTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    headerTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onItemTap,
                  icon: const Icon(Icons.close, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 40,
                    color: AppColors.textMuted.withOpacity(0.6),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No notifications',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "You're all caught up.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: listMaxHeight,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AppColors.border,
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, i) {
                  final n = items[i];
                  return InkWell(
                    onTap: n.onTap == null
                        ? null
                        : () {
                            n.onTap!();
                            onItemTap();
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: n.accent.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              n.icon,
                              size: 18,
                              color: n.accent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  n.body,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.35,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
