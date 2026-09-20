import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lord_jesus_christ_fellowship/about_us.dart';
import 'package:lord_jesus_christ_fellowship/messages/list_of_messages.dart';
import 'package:lord_jesus_christ_fellowship/series/list_of_series.dart';

import 'consts/messages_data.dart';
import 'services/message_service.dart';
import 'video/message_player.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ==========================================================
  // LATEST MESSAGES
  // ==========================================================

  Stream<List<MessageModel>> _latestMessages() {
    return MessageService.instance.messagesStream();
  }

  // ==========================================================
  // SERIES
  // ==========================================================

  Stream<List<SeriesModel>> _seriesStream() {
    return MessageService.instance.seriesStream();
  }

  // ==========================================================
  // DATE
  // ==========================================================

  DateTime _getFirestoreDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  // ==========================================================
  // YEAR GROUPING
  // ==========================================================

  Map<int, int> _groupMessagesByYear(List<MessageModel> messages) {
    final Map<int, int> yearCounts = {};

    for (final message in messages) {
      final year = message.messageDate.year;

      yearCounts[year] = (yearCounts[year] ?? 0) + 1;
    }

    return yearCounts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: ListView(
        children: [
          // ==========================================================
          // HEADER
          // ==========================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Lord Jesus Christ Fellowship',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      Get.to(() => AboutUsPage());
                    },
                    icon: const Icon(
                      Icons.info_outlined,
                      color: Color(0xFF333333),
                    ),
                    tooltip: 'About',
                  ),
                ),
              ],
            ),
          ),

          // ==========================================================
          // HERO
          // ==========================================================
          // ==========================================================
          // HERO SECTION
          // ==========================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              height: 390,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3157D5).withOpacity(0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ==================================================
                    // CHURCH IMAGE
                    // ==================================================
                    Image.asset(
                      'assets/hero-image.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF3157D5),
                          child: const Icon(
                            Icons.church_rounded,
                            color: Colors.white,
                            size: 80,
                          ),
                        );
                      },
                    ),

                    // ==================================================
                    // MAIN DARK / BLUE GRADIENT
                    // ==================================================
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.18),
                            const Color(0xFF3157D5).withOpacity(0.18),
                            const Color(0xFF101A3D).withOpacity(0.88),
                          ],
                          stops: const [0.0, 0.42, 1.0],
                        ),
                      ),
                    ),

                    // ==================================================
                    // BLUE COLOR GLOW
                    // ==================================================
                    Positioned(
                      top: -100,
                      right: -70,
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF3157D5).withOpacity(0.35),
                        ),
                      ),
                    ),

                    // ==================================================
                    // DECORATIVE CIRCLE
                    // ==================================================
                    Positioned(
                      left: -80,
                      bottom: 80,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                    ),

                    // ==================================================
                    // TOP BADGE
                    // ==================================================
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.90),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.church_rounded,
                              size: 15,
                              color: Color(0xFF3157D5),
                            ),
                            SizedBox(width: 7),
                            Text(
                              'LORD JESUS CHRIST',
                              style: TextStyle(
                                color: Color(0xFF3157D5),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ==================================================
                    // TOP RIGHT ICON
                    // ==================================================
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.28),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.22),
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    // ==================================================
                    // MAIN CONTENT
                    // ==================================================
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 90,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ప్రభువైన యేసు క్రీస్తు',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 29,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 10,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'నామములో శుభములు 🙏',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          Container(
                            width: 45,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ==================================================
                    // BOTTOM GLASS CARD
                    // ==================================================
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.38),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white,
                                size: 21,
                              ),
                            ),

                            const SizedBox(width: 11),

                            // Text
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Faith • Hope • Love',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Walking together in His grace',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Arrow
                            // Container(
                            //   width: 34,
                            //   height: 34,
                            //   decoration: BoxDecoration(
                            //     color: Colors.white.withOpacity(0.14),
                            //     shape: BoxShape.circle,
                            //   ),
                            //   child: const Icon(
                            //     Icons.arrow_forward_rounded,
                            //     color: Colors.white,
                            //     size: 18,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //   child: Container(
          //     width: double.infinity,
          //     height: 360,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(28),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.12),
          //           blurRadius: 24,
          //           offset: const Offset(0, 10),
          //         ),
          //       ],
          //     ),
          //     child: ClipRRect(
          //       borderRadius: BorderRadius.circular(28),
          //       child: Stack(
          //         fit: StackFit.expand,
          //         children: [
          //           Image.asset(
          //             'assets/hero-image.png',
          //             fit: BoxFit.cover,
          //             errorBuilder: (context, error, stackTrace) {
          //               return Container(
          //                 color: const Color(0xFFE9ECF3),
          //                 child: const Icon(
          //                   Icons.image_not_supported_outlined,
          //                   size: 50,
          //                   color: Colors.grey,
          //                 ),
          //               );
          //             },
          //           ),

          //           Container(
          //             decoration: BoxDecoration(
          //               gradient: LinearGradient(
          //                 begin: Alignment.topCenter,
          //                 end: Alignment.bottomCenter,
          //                 colors: [
          //                   Colors.white.withOpacity(0.75),
          //                   Colors.white.withOpacity(0.05),
          //                   Colors.black.withOpacity(0.35),
          //                 ],
          //                 stops: const [0.0, 0.45, 1.0],
          //               ),
          //             ),
          //           ),

          //           // TOP TEXT
          //           Positioned(
          //             top: 20,
          //             left: 20,
          //             right: 20,
          //             child: Column(
          //               children: [
          //                 const Text(
          //                   'LORD JESUS CHRIST',
          //                   style: TextStyle(
          //                     color: Color(0xFF3157D5),
          //                     fontSize: 11,
          //                     fontWeight: FontWeight.w800,
          //                     letterSpacing: 2,
          //                   ),
          //                 ),
          //                 const SizedBox(height: 8),
          //                 const Text(
          //                   'ప్రభువైన యేసు క్రీస్తు\nనామములో శుభములు 🙏',
          //                   textAlign: TextAlign.center,
          //                   style: TextStyle(
          //                     color: Color(0xFF171717),
          //                     fontSize: 26,
          //                     fontWeight: FontWeight.w800,
          //                     height: 1.25,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),

          //           // BOTTOM CONTENT
          //           Positioned(
          //             left: 20,
          //             right: 20,
          //             bottom: 20,
          //             child: Container(
          //               padding: const EdgeInsets.all(16),
          //               decoration: BoxDecoration(
          //                 color: Colors.black.withOpacity(0.45),
          //                 borderRadius: BorderRadius.circular(20),
          //                 border: Border.all(
          //                   color: Colors.white.withOpacity(0.25),
          //                 ),
          //               ),
          //               child: Row(
          //                 children: [
          //                   Container(
          //                     width: 44,
          //                     height: 44,
          //                     decoration: BoxDecoration(
          //                       color: Colors.white.withOpacity(0.95),
          //                       shape: BoxShape.circle,
          //                     ),
          //                     child: const Icon(
          //                       Icons.auto_awesome_rounded,
          //                       color: Color(0xFF3157D5),
          //                     ),
          //                   ),
          //                   const SizedBox(width: 12),
          //                   const Expanded(
          //                     child: Column(
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: [
          //                         Text(
          //                           'Faith • Hope • Love',
          //                           style: TextStyle(
          //                             color: Colors.white,
          //                             fontSize: 14,
          //                             fontWeight: FontWeight.w700,
          //                           ),
          //                         ),
          //                         SizedBox(height: 3),
          //                         Text(
          //                           'Walking together in His grace',
          //                           style: TextStyle(
          //                             color: Colors.white70,
          //                             fontSize: 11,
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),

          // ==========================================================
          // NEW MESSAGES
          // ==========================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'New Messages',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const MessagesList());
                      },
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                StreamBuilder<List<MessageModel>>(
                  stream: _latestMessages(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3157D5),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      debugPrint('Messages error: ${snapshot.error}');

                      return const Center(
                        child: Text('Unable to load messages'),
                      );
                    }

                    final allMessages = snapshot.data ?? [];

                    if (allMessages.isEmpty) {
                      return const Center(child: Text('No messages found'));
                    }

                    final latestMessages = allMessages.take(3).toList();

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: latestMessages.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 14);
                      },
                      itemBuilder: (context, index) {
                        final message = latestMessages[index];

                        return _videoCard(context: context, message: message);
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // ==========================================================
          // SERIES
          // ==========================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'New Series',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => SeriesList());
                      },
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                StreamBuilder<List<SeriesModel>>(
                  stream: _seriesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF3157D5),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      debugPrint('Series error: ${snapshot.error}');

                      return const Center(child: Text('Unable to load series'));
                    }

                    final seriesData = snapshot.data ?? [];

                    if (seriesData.isEmpty) {
                      return const Center(child: Text('No series found'));
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: seriesData.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.82,
                          ),
                      itemBuilder: (context, index) {
                        final series = seriesData[index];

                        return _seriesCard(
                          image: series.seriesImage,
                          title: series.seriesTitle,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          // ==========================================================
          // YEARS
          // ==========================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: StreamBuilder<List<MessageModel>>(
              stream: MessageService.instance.messagesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                if (snapshot.hasError) {
                  debugPrint('Years/messages error: ${snapshot.error}');

                  return const SizedBox.shrink();
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const SizedBox.shrink();
                }

                final yearCounts = _groupMessagesByYear(messages);

                final years = yearCounts.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Messages by Year',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(() => const MessagesList());
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // YEAR GRID
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: years.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.95,
                          ),
                      itemBuilder: (context, index) {
                        final year = years[index];
                        final count = yearCounts[year] ?? 0;

                        return _yearCard(year: year, messageCount: count);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// YEAR CARD
// ==========================================================

Widget _yearCard({required int year, required int messageCount}) {
  return GestureDetector(
    onTap: () {
      Get.to(() => MessagesList(year: year));
    },
    child: Container(
      height: 155,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3157D5), Color(0xFF233FA8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3157D5).withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Decorative circle
          Positioned(
            right: -35,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const Spacer(),

                // Year
                Text(
                  year.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 4),

                // Message count
                Row(
                  children: [
                    const Icon(
                      Icons.play_circle_outline_rounded,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$messageCount '
                      '${messageCount == 1 ? 'message' : 'messages'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Bottom action
                Row(
                  children: [
                    const Text(
                      'View messages',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ==========================================================
// SERIES CARD
// ==========================================================

Widget _seriesCard({required String image, required String title}) {
  return GestureDetector(
    onTap: () {
      Get.to(() => MessagesList(seriesTitle: title));
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE9EBF0),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 42,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),

            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'SERIES',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),

            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
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
// DATE FORMAT
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

// ==========================================================
// YOUTUBE ID
// ==========================================================

String? _extractYouTubeId(String url) {
  try {
    final uri = Uri.parse(url);

    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
    }

    if (uri.host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];

      if (videoId != null && videoId.isNotEmpty) {
        return videoId;
      }

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

// ==========================================================
// VIDEO CARD
// ==========================================================

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
