import 'package:disasteraid_pk/features/chat/screens/services/chat_badge_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:disasteraid_pk/core/api/api_client.dart';
import 'package:shimmer/shimmer.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _api = ApiClient();
  List<Map<String, dynamic>> chats = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final res = await _api.dio.get('/chat');
      if (!mounted) return;
      setState(() {
        chats = List<Map<String, dynamic>>.from(res.data); // Backend now returns array directly
        loading = false;
      });
      // Update global badge count
      if (mounted) context.read<ChatBadgeProvider>().refreshUnread();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  Widget _buildShimmer() {
    return ListView.separated(
      itemCount: 6,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListTile(
          leading: const CircleAvatar(radius: 24),
          title: Container(height: 16, color: Colors.white),
          subtitle: Container(height: 12, margin: const EdgeInsets.only(top: 8), color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 80, color: cs.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No active chats', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Start a conversation by requesting aid or responding to a request',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load chats', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _loadChats,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        scrolledUnderElevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: loading
           ? _buildShimmer()
            : error!= null
               ? _buildError()
                : chats.isEmpty
                   ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadChats,
                        child: ListView.separated(
                          itemCount: chats.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                          itemBuilder: (_, i) {
                            final chat = chats[i];
                            final unread = chat['unread_count'] as int;
                            final name = chat['other_user_name']?? 'Unknown';

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: cs.primaryContainer,
                                child: Text(
                                  name.isNotEmpty? name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    color: cs.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: TextStyle(
                                  fontWeight: unread > 0? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                chat['last_message']?? 'Start chatting',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: unread > 0? FontWeight.w600 : FontWeight.normal,
                                  color: unread > 0? cs.onSurface : cs.onSurfaceVariant,
                                ),
                              ),
                              trailing: unread > 0
                                 ? Badge(
                                      label: Text('$unread'),
                                      backgroundColor: cs.primary,
                                    )
                                  : Text(
                                      _formatTime(chat['last_message_at']),
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      requestId: chat['request_id'],
                                      otherUserName: name,
                                    ),
                                  ),
                                );
                                _loadChats();
                              },
                            );
                          },
                        ),
                      ),
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      if (diff.inDays == 1) return 'Yesterday';
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }
}