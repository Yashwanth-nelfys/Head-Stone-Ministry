import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../consts/messages_data.dart';
import '../services/message_service.dart';
import '../video/message_player.dart';
import 'add_edit_message.dart';
import 'series_dashboard.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<MessageModel> _messages = [];

  String _searchQuery = '';

  bool _loading = true;

  StreamSubscription<List<MessageModel>>? _subscription;

  @override
  void initState() {
    super.initState();

    _listenToMessages();
  }

  void _listenToMessages() {
    _subscription = MessageService.instance.messagesStream().listen(
      (messages) {
        if (!mounted) return;

        setState(() {
          _messages = messages;
          _loading = false;
        });
      },
      onError: (error) {
        debugPrint('Messages stream error: $error');

        if (!mounted) return;

        setState(() {
          _loading = false;
        });

        Get.snackbar(
          'Error',
          'Unable to load messages.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  List<MessageModel> get _filteredMessages {
    if (_searchQuery.trim().isEmpty) {
      return _messages;
    }

    final query = _searchQuery.toLowerCase().trim();

    return _messages.where((message) {
      return message.messageTitle.toLowerCase().contains(query) ||
          message.messageSeries.toLowerCase().contains(query) ||
          message.messageSpeaker.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _addMessage() async {
    await Get.to<MessageModel>(() => const AddEditMessage());
  }

  Future<void> _editMessage(MessageModel message) async {
    await Get.to<MessageModel>(() => AddEditMessage(message: message));
  }

  Future<void> _deleteMessage(MessageModel message) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(
          'Delete Message?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${message.messageTitle}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await MessageService.instance.deleteMessage(message);

      Get.snackbar(
        'Deleted',
        'Message removed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      debugPrint('Delete error: $e');

      Get.snackbar(
        'Error',
        'Unable to delete message.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _logout() {
    Get.offAllNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    final filteredMessages = _filteredMessages;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF171717),
        title: const Text(
          'Admin Panel',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Manage Series',
            onPressed: () {
              Get.to(() => const SeriesDashboard());
            },
            icon: const Icon(Icons.video_collection_outlined),
          ),

          // IconButton(
          //   tooltip: 'Lock Admin Panel',
          //   onPressed: _logout,
          //   icon: const Icon(Icons.lock_outline_rounded),
          // ),
          const SizedBox(width: 8),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMessage,
        backgroundColor: const Color(0xFF3157D5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Message',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_messages.length} Messages',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Manage your fellowship messages.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 16),

                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search messages...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3157D5)),
                  )
                : filteredMessages.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filteredMessages.length,
                    itemBuilder: (context, index) {
                      return _adminMessageCard(filteredMessages[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.video_library_outlined,
              size: 34,
              color: Color(0xFF3157D5),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No messages found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Try another search or add a new message.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _adminMessageCard(MessageModel message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.play_circle_outline_rounded,
                color: Color(0xFF3157D5),
                size: 28,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.messageTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    message.messageSeries,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3157D5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    message.messageSpeaker,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editMessage(message);
                } else if (value == 'delete') {
                  _deleteMessage(message);
                } else if (value == 'preview') {
                  Get.to(() => MessagesPlayer(message: message));
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'preview',
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow_rounded),
                      SizedBox(width: 10),
                      Text('Preview'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
