import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lord_jesus_christ_fellowship/saved/saved_message_page.dart';

import '../consts/messages_data.dart';
import '../services/message_service.dart';
import '../video/message_player.dart';

class MessagesList extends StatefulWidget {
  final String? seriesTitle;
  final int? year;

  const MessagesList({super.key, this.seriesTitle, this.year});

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  List<MessageModel> filteredMessages = [];

  StreamSubscription<List<MessageModel>>? _subscription;

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _listenToMessages();
  }

  // ======================================================
  // LISTEN TO MESSAGES
  // ======================================================

  void _listenToMessages() {
    _subscription = MessageService.instance.messagesStream().listen(
      (allMessages) {
        if (!mounted) {
          return;
        }

        _updateMessages(allMessages);
      },
      onError: (error) {
        debugPrint('Messages stream error: $error');

        if (!mounted) {
          return;
        }

        setState(() {
          _loading = false;
        });
      },
    );
  }

  // ======================================================
  // FILTER MESSAGES
  // ======================================================

  void _updateMessages(List<MessageModel> allMessages) {
    List<MessageModel> filtered = List<MessageModel>.from(allMessages);

    // ------------------------------------------------------
    // FILTER BY SERIES
    // ------------------------------------------------------

    if (widget.seriesTitle != null && widget.seriesTitle!.trim().isNotEmpty) {
      final series = widget.seriesTitle!.trim().toLowerCase();

      filtered = filtered.where((message) {
        return message.messageSeries.trim().toLowerCase() == series;
      }).toList();
    }

    // ------------------------------------------------------
    // FILTER BY YEAR
    // ------------------------------------------------------

    if (widget.year != null) {
      filtered = filtered.where((message) {
        return message.messageDate.year == widget.year;
      }).toList();
    }

    // ------------------------------------------------------
    // SORT BY MESSAGE DATE
    // ------------------------------------------------------

    filtered.sort((a, b) => b.messageDate.compareTo(a.messageDate));

    setState(() {
      filteredMessages = filtered;
      _loading = false;
    });
  }

  // ======================================================
  // PAGE TITLE
  // ======================================================

  String get _pageTitle {
    final hasSeries =
        widget.seriesTitle != null && widget.seriesTitle!.trim().isNotEmpty;

    final hasYear = widget.year != null;

    if (hasSeries && hasYear) {
      return '${widget.seriesTitle} • ${widget.year}';
    }

    if (hasSeries) {
      return widget.seriesTitle!.trim();
    }

    if (hasYear) {
      return '${widget.year} Messages';
    }

    return 'All Messages';
  }

  // ======================================================
  // PAGE SUBTITLE
  // ======================================================

  String get _pageSubtitle {
    final count = filteredMessages.length;

    if (count == 0) {
      return 'No messages available';
    }

    return '$count ${count == 1 ? 'message' : 'messages'}';
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            _header(),

            const SizedBox(height: 18),

            Expanded(child: _buildMessageList()),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // HEADER
  // ======================================================

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          // ------------------------------------------------
          // BACK BUTTON
          // ------------------------------------------------
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Get.back(),
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: Color(0xFF222222),
              ),
            ),
          ),

          const SizedBox(width: 13),

          // ------------------------------------------------
          // TITLE
          // ------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _pageTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _pageSubtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ------------------------------------------------
          // COUNT
          // ------------------------------------------------
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          //   decoration: BoxDecoration(
          //     color: const Color(0xFFE9EEFF),
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          //   child: Text(
          //     '${filteredMessages.length}',
          //     style: const TextStyle(
          //       color: Color(0xFF3157D5),
          //       fontSize: 13,
          //       fontWeight: FontWeight.w800,
          //     ),
          //   ),
          // ),
          const SizedBox(width: 6),

          // ------------------------------------------------
          // SAVED MESSAGES
          // ------------------------------------------------
          GestureDetector(
            onTap: () {
              Get.to(() => SavedMessagesPage());
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bookmark_outline_rounded,
                color: Color(0xFF3157D5),
                size: 21,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // MESSAGE LIST
  // ======================================================

  Widget _buildMessageList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF3157D5),
        ),
      );
    }

    if (filteredMessages.isEmpty) {
      return _emptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
      itemCount: filteredMessages.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 14);
      },
      itemBuilder: (context, index) {
        final message = filteredMessages[index];

        return _videoCard(context: context, message: message);
      },
    );
  }

  // ======================================================
  // EMPTY STATE
  // ======================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.video_library_outlined,
                size: 35,
                color: Color(0xFF3157D5),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              widget.year != null
                  ? 'No messages for ${widget.year}'
                  : widget.seriesTitle != null
                  ? 'No messages in this series'
                  : 'No messages found',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Messages will appear here when they are available.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// VIDEO CARD
// ======================================================

Widget _videoCard({
  required BuildContext context,
  required MessageModel message,
}) {
  final videoId = _extractYouTubeId(message.messageUrl);

  return GestureDetector(
    onTap: () {
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
            // ==================================================
            // YOUTUBE THUMBNAIL
            // ==================================================
            SizedBox(
              width: 132,
              height: 112,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: videoId != null
                        ? Image.network(
                            'https://img.youtube.com/vi/'
                            '$videoId/hqdefault.jpg',
                            fit: BoxFit.cover,
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
                            errorBuilder: (context, error, stackTrace) {
                              return _thumbnailPlaceholder();
                            },
                          )
                        : _thumbnailPlaceholder(),
                  ),

                  // ------------------------------------------------
                  // OVERLAY
                  // ------------------------------------------------
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

                  // ------------------------------------------------
                  // PLAY BUTTON
                  // ------------------------------------------------
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

                  // ------------------------------------------------
                  // DURATION
                  // ------------------------------------------------
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

            // ==================================================
            // MESSAGE INFORMATION
            // ==================================================
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
                    // ------------------------------------------------
                    // TITLE
                    // ------------------------------------------------
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

                    // ------------------------------------------------
                    // SERIES
                    // ------------------------------------------------
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

                    // ------------------------------------------------
                    // DATE
                    // ------------------------------------------------
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

            // ==================================================
            // ARROW
            // ==================================================
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

// ======================================================
// THUMBNAIL PLACEHOLDER
// ======================================================

Widget _thumbnailPlaceholder() {
  return Container(
    color: const Color(0xFFE9EBF0),
    child: const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 35,
        color: Colors.grey,
      ),
    ),
  );
}

// ======================================================
// EXTRACT YOUTUBE VIDEO ID
// ======================================================

String? _extractYouTubeId(String url) {
  try {
    final uri = Uri.parse(url.trim());

    // ==================================================
    // youtu.be/VIDEO_ID
    // ==================================================

    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
    }

    // ==================================================
    // youtube.com/watch?v=VIDEO_ID
    // ==================================================

    if (uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];

      if (videoId != null && videoId.isNotEmpty) {
        return videoId;
      }

      // ==================================================
      // youtube.com/shorts/VIDEO_ID
      // ==================================================

      if (uri.pathSegments.contains('shorts')) {
        final index = uri.pathSegments.indexOf('shorts');

        if (index + 1 < uri.pathSegments.length) {
          return uri.pathSegments[index + 1];
        }
      }

      // ==================================================
      // youtube.com/embed/VIDEO_ID
      // ==================================================

      if (uri.pathSegments.contains('embed')) {
        final index = uri.pathSegments.indexOf('embed');

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
