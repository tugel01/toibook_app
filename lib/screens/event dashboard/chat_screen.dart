import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/chat/chat_message.dart';
import 'package:toibook_app/providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final int conversationId;
  final String vendorName;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.vendorName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ChatProvider>();
      await provider.loadMessages(widget.conversationId);
      await provider.markRead(widget.conversationId);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    setState(() => _isSending = true);

    try {
      await context.read<ChatProvider>().sendMessage(
        widget.conversationId,
        text,
      );
      _scrollToBottom(animated: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final messages = provider.messagesFor(widget.conversationId);
    final isLoading = provider.isLoadingMessagesFor(widget.conversationId);
    final error = provider.messagesErrorFor(widget.conversationId);
    final currentUserId = provider.currentUserId;

    // Scroll to bottom when new messages arrive
    if (messages.isNotEmpty) {
      _scrollToBottom(animated: true);
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                widget.vendorName.isNotEmpty
                    ? widget.vendorName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(widget.vendorName, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : error != null
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Could not load messages.'),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed:
                                () => context.read<ChatProvider>().loadMessages(
                                  widget.conversationId,
                                ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : messages.isEmpty
                    ? Center(
                      child: Text(
                        'No messages yet.\nWrite a message!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUserId;
                        final showDate =
                            index == 0 ||
                            _isDifferentDay(
                              messages[index - 1].createdAt,
                              message.createdAt,
                            );

                        return Column(
                          children: [
                            if (showDate)
                              _DateDivider(isoString: message.createdAt),
                            _MessageBubble(
                              message: message,
                              isMe: isMe,
                              timeLabel: _formatTime(message.createdAt),
                            ),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            _isSending
                                ? Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.5)
                                : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child:
                          _isSending
                              ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isDifferentDay(String iso1, String iso2) {
    try {
      final d1 = DateTime.parse(iso1).toLocal();
      final d2 = DateTime.parse(iso2).toLocal();
      return d1.day != d2.day || d1.month != d2.month || d1.year != d2.year;
    } catch (_) {
      return false;
    }
  }
}

// Date divider between messages
class _DateDivider extends StatelessWidget {
  final String isoString;

  const _DateDivider({required this.isoString});

  String get _label {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      return '${dt.day}.${dt.month}.${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String timeLabel;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.timeLabel,
  });

  Widget _buildTicks(BuildContext context) {
    if (!isMe) return const SizedBox.shrink();

    switch (message.status) {
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 14,
          color: Colors.white.withValues(alpha: 0.7),
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: 14,
          color: Colors.white.withValues(alpha: 0.7),
        );
      case MessageStatus.read:
        return const Icon(Icons.done_all, size: 14, color: Colors.blue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color:
              isMe
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color:
                    isMe
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isMe
                            ? Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: 0.7)
                            : Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 4),
                _buildTicks(context),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
