import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lord_jesus_christ_fellowship/admin/admin_login.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  static const Color primaryBlue = Color(0xFF3157D5);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color lightBackground = Color(0xFFF7F8FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // =========================================================
            // APP BAR
            // =========================================================
            SliverAppBar(
              backgroundColor: lightBackground,
              elevation: 0,
              pinned: true,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 19,
                      color: darkText,
                    ),
                  ),
                ),
              ),
              title: const Text(
                'About Us',
                style: TextStyle(
                  color: darkText,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
            ),

            // =========================================================
            // CONTENT
            // =========================================================
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // =====================================================
                  // HERO SECTION
                  // =====================================================
                  _buildHeroSection(),

                  const SizedBox(height: 28),

                  // =====================================================
                  // WELCOME
                  // =====================================================
                  _buildSectionTitle(
                    eyebrow: 'WELCOME',
                    title: 'Walking Together in Faith',
                  ),

                  const SizedBox(height: 12),

                  _buildIntroCard(),

                  const SizedBox(height: 30),

                  // =====================================================
                  // OUR HEART
                  // =====================================================
                  _buildSectionTitle(
                    eyebrow: 'OUR HEART',
                    title: 'What We Believe',
                  ),

                  const SizedBox(height: 14),

                  _buildBeliefCard(
                    icon: Icons.favorite_rounded,
                    title: 'Faith',
                    description:
                        'We believe in Jesus Christ and seek to grow together in faith, trusting His word and His guidance in every season of life.',
                    color: const Color(0xFFEAF0FF),
                  ),

                  const SizedBox(height: 12),

                  _buildBeliefCard(
                    icon: Icons.favorite_border_rounded,
                    title: 'Love',
                    description:
                        'We desire to reflect the love of Christ by caring for one another, serving our community, and welcoming everyone with grace.',
                    color: const Color(0xFFFFEEF1),
                  ),

                  const SizedBox(height: 12),

                  _buildBeliefCard(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Hope',
                    description:
                        'Our hope is in Jesus Christ. Through His grace, we encourage one another to live with purpose, joy, and confidence in Him.',
                    color: const Color(0xFFFFF5DF),
                  ),

                  const SizedBox(height: 30),

                  // =====================================================
                  // MISSION
                  // =====================================================
                  _buildMissionCard(),

                  const SizedBox(height: 30),

                  // =====================================================
                  // VERSE
                  // =====================================================
                  _buildBibleVerseCard(),

                  const SizedBox(height: 30),

                  // =====================================================
                  // WHAT WE DO
                  // =====================================================
                  _buildSectionTitle(
                    eyebrow: 'OUR MINISTRY',
                    title: 'Growing Together',
                  ),

                  const SizedBox(height: 14),

                  _buildMinistryGrid(),

                  const SizedBox(height: 30),

                  // =====================================================
                  // CLOSING MESSAGE
                  // =====================================================
                  _buildClosingCard(),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Get.to(() => AdminLogin()),
                        icon: Icon(Icons.admin_panel_settings),
                      ),
                      Text("All Rights Reserved"),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // HERO SECTION
  // ===============================================================

  Widget _buildHeroSection() {
    return Container(
      height: 330,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.14),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Image.asset('assets/logo.png'),

      // ClipRRect(
      //   borderRadius: BorderRadius.circular(28),
      //   child: Stack(
      //     fit: StackFit.expand,
      //     children: [
      //       Image.asset(
      //         'assets/hero-image.png',
      //         fit: BoxFit.cover,
      //         errorBuilder: (context, error, stackTrace) {
      //           return Container(
      //             decoration: const BoxDecoration(
      //               gradient: LinearGradient(
      //                 begin: Alignment.topLeft,
      //                 end: Alignment.bottomRight,
      //                 colors: [Color(0xFFEAF0FF), Color(0xFFDCE5FF)],
      //               ),
      //             ),
      //             child: const Icon(
      //               Icons.church_rounded,
      //               size: 80,
      //               color: primaryBlue,
      //             ),
      //           );
      //         },
      //       ),

      //       // Dark gradient
      //       Container(
      //         decoration: BoxDecoration(
      //           gradient: LinearGradient(
      //             begin: Alignment.topCenter,
      //             end: Alignment.bottomCenter,
      //             colors: [
      //               Colors.white.withOpacity(0.72),
      //               Colors.transparent,
      //               Colors.black.withOpacity(0.78),
      //             ],
      //             stops: const [0.0, 0.42, 1.0],
      //           ),
      //         ),
      //       ),

      //       // Top label
      //       Positioned(
      //         top: 22,
      //         left: 20,
      //         right: 20,
      //         child: Column(
      //           children: [
      //             Container(
      //               padding: const EdgeInsets.symmetric(
      //                 horizontal: 12,
      //                 vertical: 7,
      //               ),
      //               decoration: BoxDecoration(
      //                 color: Colors.white.withOpacity(0.90),
      //                 borderRadius: BorderRadius.circular(30),
      //               ),
      //               child: const Text(
      //                 'LORD JESUS CHRIST FELLOWSHIP',
      //                 style: TextStyle(
      //                   color: primaryBlue,
      //                   fontSize: 9,
      //                   fontWeight: FontWeight.w800,
      //                   letterSpacing: 1.2,
      //                 ),
      //               ),
      //             ),

      //             const SizedBox(height: 16),

      //             const Text(
      //               'ప్రభువైన యేసు క్రీస్తు\nనామములో శుభములు 🙏',
      //               textAlign: TextAlign.center,
      //               style: TextStyle(
      //                 color: darkText,
      //                 fontSize: 25,
      //                 fontWeight: FontWeight.w800,
      //                 height: 1.25,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),

      //       // Bottom content
      //       Positioned(
      //         left: 18,
      //         right: 18,
      //         bottom: 18,
      //         child: Container(
      //           padding: const EdgeInsets.all(15),
      //           decoration: BoxDecoration(
      //             color: Colors.black.withOpacity(0.48),
      //             borderRadius: BorderRadius.circular(20),
      //             border: Border.all(color: Colors.white.withOpacity(0.20)),
      //           ),
      //           child: Row(
      //             children: [
      //               Container(
      //                 width: 45,
      //                 height: 45,
      //                 decoration: BoxDecoration(
      //                   color: Colors.white.withOpacity(0.95),
      //                   shape: BoxShape.circle,
      //                 ),
      //                 child: const Icon(
      //                   Icons.church_rounded,
      //                   color: primaryBlue,
      //                   size: 23,
      //                 ),
      //               ),

      //               const SizedBox(width: 12),

      //               const Expanded(
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Text(
      //                       'Faith • Hope • Love',
      //                       style: TextStyle(
      //                         color: Colors.white,
      //                         fontSize: 14,
      //                         fontWeight: FontWeight.w700,
      //                       ),
      //                     ),
      //                     SizedBox(height: 4),
      //                     Text(
      //                       'Growing together in His grace',
      //                       style: TextStyle(
      //                         color: Colors.white70,
      //                         fontSize: 11,
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  // ===============================================================
  // SECTION TITLE
  // ===============================================================

  Widget _buildSectionTitle({required String eyebrow, required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: primaryBlue,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: darkText,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // INTRO CARD
  // ===============================================================

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to Lord Jesus Christ Fellowship',
            style: TextStyle(
              color: darkText,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'We are a fellowship of believers who desire to know Jesus Christ, '
            'grow in His Word, and walk together in faith, hope, and love.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.65,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Our heart is simple — to encourage people through God’s Word, '
            'share the message of Jesus Christ, and build a community where '
            'everyone can experience His grace and love.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BELIEF CARD
  // ===============================================================

  Widget _buildBeliefCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: primaryBlue, size: 23),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.5,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // MISSION CARD
  // ===============================================================

  Widget _buildMissionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3157D5), Color(0xFF203FA8)],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.20)),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'Our Mission',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'To share the love of Jesus Christ, encourage believers '
            'in their walk with God, and help people discover the hope '
            'and purpose found in Him.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.88),
              fontSize: 13.5,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BIBLE VERSE
  // ===============================================================

  Widget _buildBibleVerseCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0E5C8)),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.format_quote_rounded,
              color: Color(0xFFC5942E),
              size: 25,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            '"For where two or three are gathered together in My name, '
            'I am there in the midst of them."',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF4B402C),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            '— Matthew 18:20',
            style: TextStyle(
              color: Color(0xFFC5942E),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // MINISTRY GRID
  // ===============================================================

  Widget _buildMinistryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.08,
      children: [
        _buildMinistryItem(
          icon: Icons.menu_book_rounded,
          title: 'God’s Word',
          subtitle: 'Learn & grow',
          color: const Color(0xFFEAF0FF),
        ),
        _buildMinistryItem(
          icon: Icons.play_circle_outline_rounded,
          title: 'Messages',
          subtitle: 'Watch & listen',
          color: const Color(0xFFFFEEF1),
        ),
        _buildMinistryItem(
          icon: Icons.groups_rounded,
          title: 'Fellowship',
          subtitle: 'Grow together',
          color: const Color(0xFFEAF8F0),
        ),
        _buildMinistryItem(
          icon: Icons.volunteer_activism_rounded,
          title: 'Service',
          subtitle: 'Serve with love',
          color: const Color(0xFFFFF5DF),
        ),
      ],
    );
  }

  Widget _buildMinistryItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primaryBlue, size: 22),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CLOSING CARD
  // ===============================================================

  Widget _buildClosingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Column(
        children: [
          const Text(
            'You Are Welcome Here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            'Whether you are taking your first step in faith or '
            'have been walking with Christ for many years, '
            'we invite you to grow with us.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3FF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Faith • Hope • Love 🙏',
              style: TextStyle(
                color: primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // COMMON CARD DECORATION
  // ===============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.055),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }
}
