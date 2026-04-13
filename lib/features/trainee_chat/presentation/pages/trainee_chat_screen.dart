import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

enum _Sender { coach, trainee }

class _ChatMessage {
  final String text;
  final _Sender sender;
  final String time;

  const _ChatMessage({
    required this.text,
    required this.sender,
    required this.time,
  });
}

class _MessageGroup {
  final String dateLabel;
  final List<_ChatMessage> messages;

  const _MessageGroup({required this.dateLabel, required this.messages});
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

const _coachName = 'Coach Mike';
const _coachSpecialty = 'Strength & Conditioning';
const _coachBio =
    'Certified personal trainer with 8+ years of experience helping clients '
    'achieve their fitness goals. Specialises in strength training, fat loss, '
    'and athletic performance.';
const _coachRating = '4.9';
const _coachExperience = '8 years';
const _coachClients = '120+';

final List<_MessageGroup> _initialGroups = [
  _MessageGroup(dateLabel: 'Monday', messages: [
    _ChatMessage(
      text: 'Welcome aboard! 🎉 I\'m Coach Mike and I\'ll be guiding you on '
          'your fitness journey. Feel free to ask me anything — workouts, '
          'nutrition, recovery, you name it.',
      sender: _Sender.coach,
      time: '9:00 AM',
    ),
    _ChatMessage(
      text: 'Thanks Coach! Excited to get started. I want to focus on losing '
          'weight and building muscle.',
      sender: _Sender.trainee,
      time: '9:15 AM',
    ),
    _ChatMessage(
      text: 'Great goals! I\'ve built your first workout plan. Check the '
          'Workout tab — we\'re starting with a 4-day upper/lower split. '
          'Trust the process!',
      sender: _Sender.coach,
      time: '9:20 AM',
    ),
  ]),
  _MessageGroup(dateLabel: 'Yesterday', messages: [
    _ChatMessage(
      text: 'Had a great session today! Squats felt much stronger. Followed '
          'your form tips.',
      sender: _Sender.trainee,
      time: '2:10 PM',
    ),
    _ChatMessage(
      text: 'That\'s what I like to hear! 💪 Form first, weight second. '
          'You\'re building the right foundation.',
      sender: _Sender.coach,
      time: '2:15 PM',
    ),
  ]),
  _MessageGroup(dateLabel: 'Today', messages: [
    _ChatMessage(
      text: 'How\'s recovery after yesterday\'s leg day? Remember to stretch '
          'and hydrate!',
      sender: _Sender.coach,
      time: '9:00 AM',
    ),
    _ChatMessage(
      text: 'Legs are a bit sore but I feel good overall. Did 10 mins of '
          'stretching this morning.',
      sender: _Sender.trainee,
      time: '9:45 AM',
    ),
    _ChatMessage(
      text: 'Perfect! That soreness means you hit it right. Rest day today — '
          'light walk if you feel up to it. Big push tomorrow 💥',
      sender: _Sender.coach,
      time: '10:00 AM',
    ),
  ]),
];

const _quickEmojis = ['💪', '🔥', '⭐', '👍', '✅', '💯', '🎉', '😊'];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class TraineeChatScreen extends StatefulWidget {
  const TraineeChatScreen({super.key});

  @override
  State<TraineeChatScreen> createState() => _TraineeChatScreenState();
}

class _TraineeChatScreenState extends State<TraineeChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isMuted = false;
  bool _showEmojiPanel = false;

  // Runtime messages appended by the user go into a "Today" extension
  final List<_ChatMessage> _runtimeMessages = [];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Build the merged group list each time we rebuild
  List<_MessageGroup> get _mergedGroups {
    if (_runtimeMessages.isEmpty) return _initialGroups;

    final result = <_MessageGroup>[];
    bool merged = false;
    for (final group in _initialGroups) {
      if (group.dateLabel == 'Today') {
        result.add(_MessageGroup(
          dateLabel: 'Today',
          messages: [...group.messages, ..._runtimeMessages],
        ));
        merged = true;
      } else {
        result.add(group);
      }
    }
    if (!merged) {
      result.add(
          _MessageGroup(dateLabel: 'Today', messages: _runtimeMessages));
    }
    return result;
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _runtimeMessages.add(_ChatMessage(
        text: text,
        sender: _Sender.trainee,
        time: _currentTime(),
      ));
      _inputController.clear();
      _showEmojiPanel = false;
    });
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

  void _showCoachProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CoachProfileSheet(),
    );
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AttachmentSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildTypingIndicator(),
          if (_showEmojiPanel) _buildEmojiPanel(),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.card,
      elevation: 0,
      titleSpacing: 12,
      title: GestureDetector(
        onTap: _showCoachProfile,
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: const Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.card, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        _coachName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '$_coachRating ★',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Active now · $_coachSpecialty',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isMuted
                ? Icons.notifications_off_outlined
                : Icons.notifications_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: () => setState(() => _isMuted = !_isMuted),
          tooltip: _isMuted ? 'Unmute' : 'Mute',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildMessageList() {
    final groups = _mergedGroups;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: groups.length,
      itemBuilder: (_, i) {
        final group = groups[i];
        return Column(
          children: [
            _DateSeparator(label: group.dateLabel),
            ...group.messages.map((msg) => _MessageBubble(message: msg)),
          ],
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.only(left: 16, bottom: 6),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary,
            child: const Text('M',
                style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Coach Mike is typing...',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
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
                          offset: prev.length + emoji.length),
                    );
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    final canSend = _inputController.text.trim().isNotEmpty;
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
            IconButton(
              icon: const Icon(Icons.attach_file_outlined),
              color: AppColors.textSecondary,
              onPressed: _showAttachmentSheet,
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
                  decoration: const InputDecoration(
                    hintText: 'Message Coach Mike...',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: canSend ? _sendMessage : null,
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

// ---------------------------------------------------------------------------
// Reusable sub-widgets
// ---------------------------------------------------------------------------

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
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  bool get _isCoach => message.sender == _Sender.coach;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            _isCoach ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (_isCoach) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: const Text('M',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: _isCoach
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.68,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isCoach ? AppColors.surface : AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(_isCoach ? 4 : 16),
                      bottomRight: Radius.circular(_isCoach ? 16 : 4),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: _isCoach
                          ? AppColors.textPrimary
                          : Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message.time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (!_isCoach) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _CoachProfileSheet extends StatelessWidget {
  const _CoachProfileSheet();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: const Text(
                  'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      _coachName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _coachSpecialty,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '$_coachRating ★',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'About',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            _coachBio,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              _StatChip(label: 'Experience', value: _coachExperience),
              SizedBox(width: 12),
              _StatChip(label: 'Clients', value: _coachClients),
              SizedBox(width: 12),
              _StatChip(label: 'Rating', value: _coachRating),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentSheet extends StatelessWidget {
  const _AttachmentSheet();

  @override
  Widget build(BuildContext context) {
    const options = [
      ('📷', 'Photo'),
      ('📁', 'File'),
      ('📋', 'Workout Plan'),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Attach',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map(
            (opt) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(opt.$1, style: const TextStyle(fontSize: 24)),
              title: Text(
                opt.$2,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
