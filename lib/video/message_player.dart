import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../consts/messages_data.dart';
import '../pdf/pdf_viewer.dart';
import '../saved/saved_messages_controller.dart';

class MessagesPlayer extends StatefulWidget {
  final MessageModel message;

  const MessagesPlayer({super.key, required this.message});

  @override
  State<MessagesPlayer> createState() => _MessagesPlayerState();
}

class _MessagesPlayerState extends State<MessagesPlayer> {
  late YoutubePlayerController _controller;

  final savedController = Get.find<SavedMessagesController>();

  bool _isFullScreen = false;

  static const Color primaryBlue = Color(0xFF3157D5);
  static const Color backgroundColor = Color(0xFFF6F7FB);

  @override
  void initState() {
    super.initState();

    final videoId = YoutubePlayer.convertUrlToId(widget.message.messageUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        hideControls: false,
        controlsVisibleAtStart: true,
        disableDragSeek: false,
        forceHD: false,
      ),
    );
  }

  // ==========================================================
  // ENTER FULLSCREEN
  // ==========================================================

  Future<void> _enterFullScreen() async {
    if (!mounted) return;

    setState(() {
      _isFullScreen = true;
    });

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // ==========================================================
  // EXIT FULLSCREEN
  // ==========================================================

  Future<void> _exitFullScreen() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (mounted) {
      setState(() {
        _isFullScreen = false;
      });
    }
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _controller.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,

        showVideoProgressIndicator: true,

        progressIndicatorColor: primaryBlue,

        progressColors: const ProgressBarColors(
          playedColor: primaryBlue,
          handleColor: primaryBlue,
          bufferedColor: Color(0xFF8FA4E8),
          backgroundColor: Color(0xFF555555),
        ),

        bottomActions: const [
          CurrentPosition(),
          SizedBox(width: 8),
          ProgressBar(isExpanded: true),
          SizedBox(width: 8),
          RemainingDuration(),
          SizedBox(width: 8),
          PlaybackSpeedButton(),
          FullScreenButton(),
        ],

        onReady: () {
          debugPrint('YouTube player ready');
        },

        onEnded: (metadata) {
          debugPrint('Video ended');
        },
      ),

      onEnterFullScreen: _enterFullScreen,

      onExitFullScreen: _exitFullScreen,

      builder: (context, player) {
        // ======================================================
        // FULLSCREEN
        // ======================================================

        if (_isFullScreen) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: player),
          );
        }

        // ======================================================
        // NORMAL PAGE
        // ======================================================

        return _buildNormalPage(context, player);
      },
    );
  }

  // ==========================================================
  // NORMAL PAGE
  // ==========================================================

  Widget _buildNormalPage(BuildContext context, Widget player) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,

        leadingWidth: 62,

        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () => Get.back(),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 17,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
            ),
          ),
        ),

        title: Text(
          widget.message.messageTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF171717),
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        centerTitle: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ==================================================
              // VIDEO PLAYER
              // ==================================================
              _buildVideoPlayer(player),

              const SizedBox(height: 24),

              // ==================================================
              // MESSAGE CONTENT
              // ==================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // SERIES
                    // ==================================================
                    _buildSeriesBadge(),

                    const SizedBox(height: 12),

                    // ==================================================
                    // TITLE + SAVE
                    // ==================================================
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.message.messageTitle,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF171717),
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              height: 1.18,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        _buildSaveButton(),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // SPEAKER
                    // ==================================================
                    if (widget.message.messageSpeaker.trim().isNotEmpty)
                      _buildSpeaker(),

                    const SizedBox(height: 14),

                    // ==================================================
                    // DATE + DURATION
                    // ==================================================
                    _buildMetadata(),

                    const SizedBox(height: 28),

                    // ==================================================
                    // DESCRIPTION
                    // ==================================================
                    _buildDescription(),

                    // ==================================================
                    // PDF
                    // ==================================================
                    if (widget.message.messageNotes.trim().isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildPdfCard(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // VIDEO PLAYER CARD
  // ==========================================================

  Widget _buildVideoPlayer(Widget player) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.12),
            blurRadius: 30,
            spreadRadius: 1,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              // YouTube player
              Positioned.fill(child: player),

              // Top gradient
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 85,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Video information
              Positioned(
                top: 13,
                left: 14,
                right: 14,
                child: IgnorePointer(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),

                      const SizedBox(width: 9),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.message.messageSeries,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),

                            if (widget.message.messageSpeaker.trim().isNotEmpty)
                              Text(
                                widget.message.messageSpeaker,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.78),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SERIES BADGE
  // ==========================================================

  Widget _buildSeriesBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEFF),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: primaryBlue.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.video_collection_outlined,
            size: 14,
            color: primaryBlue,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              widget.message.messageSeries,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: primaryBlue,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SPEAKER
  // ==========================================================

  Widget _buildSpeaker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9EAF0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE9EEFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: primaryBlue,
              size: 21,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Speaker',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  widget.message.messageSpeaker,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // METADATA
  // ==========================================================

  Widget _buildMetadata() {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: [
        _metadataChip(
          icon: Icons.calendar_today_rounded,
          text: _formatDate(widget.message.messageDate),
        ),

        if (widget.message.messageLength.trim().isNotEmpty)
          _metadataChip(
            icon: Icons.access_time_rounded,
            text: widget.message.messageLength,
          ),
      ],
    );
  }

  Widget _metadataChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E9EE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),

          const SizedBox(width: 6),

          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SAVE BUTTON
  // ==========================================================

  Widget _buildSaveButton() {
    return Obx(() {
      final isSaved = savedController.isSaved(widget.message.id);

      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            savedController.toggleSaved(widget.message.id);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSaved ? const Color(0xFFE9EEFF) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSaved
                    ? primaryBlue.withOpacity(0.25)
                    : const Color(0xFFE8E9EE),
              ),
            ),
            child: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? primaryBlue : const Color(0xFF333333),
              size: 22,
            ),
          ),
        ),
      );
    });
  }

  // ==========================================================
  // DESCRIPTION
  // ==========================================================

  Widget _buildDescription() {
    final description = widget.message.messageDescription.trim();

    if (description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEEF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EEFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 18,
                  color: primaryBlue,
                ),
              ),

              const SizedBox(width: 10),

              const Text(
                'About this message',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF171717),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.65,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PDF CARD
  // ==========================================================

  Widget _buildPdfCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEEF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Get.to(
              () => PdfViewerPage(
                pdfUrl: widget.message.messageNotes,
                title: widget.message.messageTitle,
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFFE53935),
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF171717),
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'View sermon notes in PDF',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF777777),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F8),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Color(0xFF555555),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // DATE
  // ==========================================================

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
}
