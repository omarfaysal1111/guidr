import 'package:flutter/material.dart';
import 'package:guidr/core/di/injection_container.dart' as di;
import 'package:guidr/core/theme/app_colors.dart';
import 'package:guidr/features/chat/domain/entities/chat_message_entity.dart';
import 'package:guidr/features/chat/domain/repositories/chat_repository.dart';

class _DateSeparator extends StatelessWidget {
  final String label;

  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.border)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isFromPeer;
  final String peerInitial;

  const _MessageBubble({
    required this.message,
    required this.isFromPeer,
    required this.peerInitial,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = peerInitial.trim();
    final letter = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isFromPeer ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isFromPeer) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: Text(
                letter,
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isFromPeer
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isFromPeer ? AppColors.surface : AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isFromPeer ? 4 : 16),
                      bottomRight: Radius.circular(isFromPeer ? 16 : 4),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isFromPeer ? AppColors.textPrimary : Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatTime(message.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!isFromPeer) const SizedBox(width: 4),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

String _dateLabel(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(dt.year, dt.month, dt.day);
  if (d == today) return 'Today';
  if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
}

/// Real-time chat backed by [ChatRepository] (Firestore). [myRole] is the
/// signed-in user; messages from the other party use [peerInitial] on bubbles.
class FirebaseChatThreadView extends StatefulWidget {
  final String conversationId;
  final String coachId;
  final String traineeId;
  final String currentUserId;
  final ChatSenderRole myRole;
  final String peerTitle;
  final String peerSubtitle;
  final String peerInitial;
  final PreferredSizeWidget appBar;
  final ChatRepository? repository;

  const FirebaseChatThreadView({
    super.key,
    required this.conversationId,
    required this.coachId,
    required this.traineeId,
    required this.currentUserId,
    required this.myRole,
    required this.peerTitle,
    required this.peerSubtitle,
    required this.peerInitial,
    required this.appBar,
    this.repository,
  });

  @override
  State<FirebaseChatThreadView> createState() => _FirebaseChatThreadViewState();
}

class _FirebaseChatThreadViewState extends State<FirebaseChatThreadView> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showEmojiPanel = false;

  ChatRepository get _repo => widget.repository ?? di.sl<ChatRepository>();

  static const _quickEmojis = [
    '\u{1F4AA}',
    '\u{1F525}',
    '\u{2B50}',
    '\u{1F44D}',
    '\u{2705}',
    '\u{1F4AF}',
    '\u{1F389}',
    '\u{1F60A}',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    setState(() => _showEmojiPanel = false);
    await _repo.sendMessage(
      conversationId: widget.conversationId,
      coachId: widget.coachId,
      traineeId: widget.traineeId,
      senderId: widget.currentUserId,
      senderRole: widget.myRole,
      text: text,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<Widget> _buildGroupedMessages(List<ChatMessageEntity> messages) {
    if (messages.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No messages yet.\nSay hello!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ),
        ),
      ];
    }

    final widgets = <Widget>[];
    String? lastLabel;
    for (final m in messages) {
      final label = _dateLabel(m.createdAt);
      if (label != lastLabel) {
        widgets.add(_DateSeparator(label: label));
        lastLabel = label;
      }
      final isPeer = m.senderRole != widget.myRole;
      widgets.add(
        _MessageBubble(
          message: m,
          isFromPeer: isPeer,
          peerInitial: widget.peerInitial,
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.appBar,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessageEntity>>(
              stream: _repo.watchMessages(widget.conversationId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load messages.\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }
                final list = snapshot.data ?? [];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients && list.isNotEmpty) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });
                return ListView(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: _buildGroupedMessages(list),
                );
              },
            ),
          ),
          if (_showEmojiPanel) _buildEmojiPanel(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmojiPanel() {
    return Container(
      color: AppColors.card,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: _quickEmojis
            .map((emoji) => GestureDetector(
                  onTap: () {
                    final prev = _inputController.text;
                    _inputController.value = TextEditingValue(
                      text: prev + emoji,
                      selection: TextSelection.collapsed(
                        offset: prev.length + emoji.length,
                      ),
                    );
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(emoji, style: const TextStyle(fontSize: 26)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    final canSend = _inputController.text.trim().isNotEmpty;
    final hint = 'Message ${widget.peerTitle}...';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.sentiment_satisfied_alt_outlined),
              color: AppColors.textSecondary,
              onPressed: () =>
                  setState(() => _showEmojiPanel = !_showEmojiPanel),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _inputController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: canSend ? _send : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: canSend ? AppColors.primary : AppColors.border,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
