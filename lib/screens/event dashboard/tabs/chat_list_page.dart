import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/chat/conversation_preview.dart';
import 'package:toibook_app/providers/chat_provider.dart';
import 'package:toibook_app/screens/event%20dashboard/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inDays == 0) {
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$h:$m';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dt.weekday - 1];
      } else {
        return '${dt.day}.${dt.month}.${dt.year}';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          // Socket status indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.circle,
              size: 10,
              color: provider.isSocketConnected ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
      body:
          provider.isLoadingConversations
              ? const Center(child: CircularProgressIndicator())
              : provider.conversationsError != null
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load conversations.'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed:
                          () =>
                              context.read<ChatProvider>().loadConversations(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : provider.conversations.isEmpty
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No conversations yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a chat with a vendor from saved vendors',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.separated(
                itemCount: provider.conversations.length,
                separatorBuilder:
                    (_, _) => const Divider(height: 1, indent: 80),
                itemBuilder: (context, index) {
                  final conv = provider.conversations[index];
                  return _ConversationTile(
                    conversation: conv,
                    timeLabel: _formatTime(conv.lastMessageCreatedAt),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChatScreen(
                                  conversationId: conv.conversationId,
                                  vendorName: conv.otherParticipantName,
                                ),
                          ),
                        ),
                  );
                },
              ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationPreview conversation;
  final String timeLabel;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          conversation.otherParticipantName.isNotEmpty
              ? conversation.otherParticipantName[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      title: Text(
        conversation.otherParticipantName,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        conversation.lastMessageText ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color:
              hasUnread
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.outline,
          fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            timeLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color:
                  hasUnread
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          if (hasUnread)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
