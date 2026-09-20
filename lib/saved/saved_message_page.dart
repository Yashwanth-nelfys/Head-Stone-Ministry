import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../consts/messages_data.dart';
import '../services/message_service.dart';
import '../video/message_player.dart';
import 'saved_messages_controller.dart';

class SavedMessagesPage extends StatelessWidget {
  const SavedMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final savedController = Get.find<SavedMessagesController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),

        title: const Text(
          'Saved Messages',
          style: TextStyle(
            color: Color(0xFF171717),
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: StreamBuilder<List<MessageModel>>(
        stream: MessageService.instance.messagesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3157D5)),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load messages'));
          }

          final allMessages = snapshot.data ?? [];

          return Obx(() {
            final savedMessages = allMessages.where((message) {
              return savedController.savedMessageIds.contains(message.id);
            }).toList();

            if (savedMessages.isEmpty) {
              return const Center(
                child: Text(
                  'No saved messages',
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: savedMessages.length,
              separatorBuilder: (_, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final message = savedMessages[index];

                return _videoCard(context: context, message: message);
              },
            );
          });
        },
      ),
    );
  }
}

Widget _videoCard({
  required BuildContext context,
  required MessageModel message,
}) {
  final videoId = _extractYouTubeId(message.messageUrl);

  return GestureDetector(
    onTap: () {
      // ==========================================
      // Open selected video
      // ==========================================

      Get.to(() => MessagesPlayer(message: message));
    },
    child: Container(
      height: 112,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            // ==========================================
            // YOUTUBE THUMBNAIL
            // ==========================================
            SizedBox(
              width: 132,
              height: 112,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Thumbnail
                  Positioned.fill(
                    child: videoId != null
                        ? Image.network(
                            'https://img.youtube.com/vi/'
                            '$videoId/hqdefault.jpg',
                            fit: BoxFit.cover,

                            // Loading
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return Container(
                                color: const Color(0xFFE9EBF0),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF3157D5),
                                  ),
                                ),
                              );
                            },

                            // Error
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFE9EBF0),
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 35,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFFE9EBF0),
                            child: const Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                            ),
                          ),
                  ),

                  // ==========================================
                  // DARK IMAGE OVERLAY
                  // ==========================================
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ==========================================
                  // PLAY BUTTON
                  // ==========================================
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.94),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF3157D5),
                      size: 25,
                    ),
                  ),

                  // ==========================================
                  // DURATION
                  // ==========================================
                  Positioned(
                    right: 7,
                    bottom: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.78),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        message.messageLength,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // VIDEO INFORMATION
            // ==========================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      message.messageTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 7),

                    // Series
                    Row(
                      children: [
                        const Icon(
                          Icons.video_collection_outlined,
                          size: 13,
                          color: Color(0xFF3157D5),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            message.messageSeries,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF3157D5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            _formatDate(message.messageDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // ARROW
            // ==========================================
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF666666),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String? _extractYouTubeId(String url) {
  try {
    final uri = Uri.parse(url);

    // ==========================================
    // youtu.be/VIDEO_ID
    // ==========================================
    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
    }

    // ==========================================
    // youtube.com/watch?v=VIDEO_ID
    // ==========================================
    if (uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];

      if (videoId != null && videoId.isNotEmpty) {
        return videoId;
      }

      // ==========================================
      // youtube.com/shorts/VIDEO_ID
      // ==========================================
      if (uri.pathSegments.contains('shorts')) {
        final index = uri.pathSegments.indexOf('shorts');

        if (index + 1 < uri.pathSegments.length) {
          return uri.pathSegments[index + 1];
        }
      }
    }
  } catch (e) {
    debugPrint('Invalid YouTube URL: $e');
  }

  return null;
}

// ======================================================
// DATE FORMAT
// ======================================================

String _formatDate(DateTime date) {
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

  return '${months[date.month - 1]} '
      '${date.day}, '
      '${date.year}';
}
