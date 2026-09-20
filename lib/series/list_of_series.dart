import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../consts/messages_data.dart';
import '../messages/list_of_messages.dart';
import '../services/message_service.dart';

class SeriesList extends StatelessWidget {
  const SeriesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        scrolledUnderElevation: 0,

        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
              size: 18,
              color: Color(0xFF222222),
            ),
          ),
        ),

        title: const Text(
          'All Series',
          style: TextStyle(
            color: Color(0xFF171717),
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: false,
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: SafeArea(
        child: StreamBuilder<List<SeriesModel>>(
          stream: MessageService.instance.seriesStream(),
          builder: (context, snapshot) {
            // ======================================================
            // LOADING
            // ======================================================
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3157D5)),
              );
            }

            // ======================================================
            // ERROR
            // ======================================================
            if (snapshot.hasError) {
              debugPrint('Firestore Series Error: ${snapshot.error}');

              return _errorState();
            }

            // ======================================================
            // SERIES DATA
            // ======================================================
            final seriesData = snapshot.data ?? [];

            // ======================================================
            // NO DATA
            // ======================================================
            if (seriesData.isEmpty) {
              return _emptyState();
            }

            // ======================================================
            // SERIES GRID
            // ======================================================
            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),

              itemCount: seriesData.length,

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),

          child: Stack(
            fit: StackFit.expand,

            children: [
              // --------------------------------
              // Background Image
              // --------------------------------
              Image.network(
                image,
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

              // --------------------------------
              // Gradient Overlay
              // --------------------------------
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

              // --------------------------------
              // SERIES Badge
              // --------------------------------
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
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

              // --------------------------------
              // Arrow Button
              // --------------------------------
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Get.to(() => MessagesList(seriesTitle: title));
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ),

              // --------------------------------
              // Bottom Title
              // --------------------------------
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
  // EMPTY STATE
  // ==========================================================

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEFF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.video_collection_outlined,
                size: 40,
                color: Color(0xFF3157D5),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No Series Available',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171717),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'There are no message series available yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ERROR STATE
  // ==========================================================

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEFF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Color(0xFF3157D5),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Unable to Load Series',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171717),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
