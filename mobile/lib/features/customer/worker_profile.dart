import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/router.dart';
import '../../core/models/worker.dart';
import '../auth/onboarding_screen.dart'; // import BrutalistCard
import '../../core/utils/web_video_player.dart';
import 'customer_home.dart';
import '../../core/utils/localization.dart';

class CustomerWorkerProfileScreen extends ConsumerStatefulWidget {
  const CustomerWorkerProfileScreen({super.key});

  @override
  ConsumerState<CustomerWorkerProfileScreen> createState() => _CustomerWorkerProfileScreenState();
}

class _CustomerWorkerProfileScreenState extends ConsumerState<CustomerWorkerProfileScreen> {
  late final ScrollController _scrollController;
  int _selectedMediaTab = 0; // 0 for Photos, 1 for Videos

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showLightbox(BuildContext context, String imgBase64) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? Colors.black : Colors.black87;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: bgCol,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              // Zoomable image
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.memory(
                      base64Decode(imgBase64.split(',').last),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Close button at top right
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      border: Border.all(color: Colors.black, width: 2.0),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _playVideo(BuildContext context, String title, String url) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(240),
      pageBuilder: (context, anim1, anim2) {
        return VideoPlayerOverlay(title: title, url: url);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final borderCol = isDark ? Colors.white : Colors.black;
    final navState = ref.watch(navigationProvider);
    final args = navState.arguments as Map<String, dynamic>?;
    final worker = args?['worker'] as Worker? ?? mockWorkers[0];
    final selectedSkill = args?['selectedSkill'] as String?;
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(worker.id).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final name = data['name'] ?? worker.name;
        final category = data['category'] ?? worker.category;
        final pricePerHour = data['pricePerHour'] ?? worker.pricePerHour;
        final experienceYears = data['experienceYears'] ?? worker.experienceYears;
        final skills = List<String>.from(data['skills'] ?? worker.skills);
        final avatarUrl = data['avatarUrl'] ?? worker.avatarUrl;
        final isVerified = data['isVerified'] as bool? ?? worker.isVerified;
        final hunarScore = data['hunarScore'] ?? worker.hunarScore;
        final rating = data['rating'] ?? worker.rating;
        final portfolioImages = List<String>.from(data['portfolioImages'] ?? []);
        final coverImageUrl = data['coverImageUrl'] as String?;
        final portfolioVideos = List<Map<String, dynamic>>.from(
          (data['portfolioVideos'] as List<dynamic>?)?.map((x) => Map<String, dynamic>.from(x)) ?? []
        );

        return Scaffold(
          body: Stack(
            children: [
              // Content
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header image / Cover banner with overlapping avatar
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Cover Image Banner
                        Container(
                          height: isSmall ? 140 : 180,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: const Border(bottom: BorderSide(color: Colors.black, width: 3.0)),
                            image: coverImageUrl != null && coverImageUrl.isNotEmpty
                                ? DecorationImage(
                                    image: coverImageUrl.startsWith('data:')
                                        ? MemoryImage(base64Decode(coverImageUrl.split(',').last)) as ImageProvider
                                        : NetworkImage(coverImageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.accent, size: 24),
                                    onPressed: () {
                                      ref.read(navigationProvider.notifier).goBack();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.favorite_border_rounded, color: AppColors.accent, size: 24),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Avatar overlapping the bottom of the cover banner
                        Positioned(
                          left: isSmall ? 16 : 24,
                          bottom: isSmall ? -30 : -40,
                          child: BrutalistCard(
                            color: Colors.white,
                            shadowOffset: 4.0,
                            child: Container(
                              width: isSmall ? 64 : 80,
                              height: isSmall ? 64 : 80,
                              alignment: Alignment.center,
                              child: avatarUrl != null && avatarUrl.isNotEmpty
                                  ? (avatarUrl.startsWith('data:')
                                      ? Image.memory(
                                          base64Decode(avatarUrl.split(',').last),
                                          fit: BoxFit.cover,
                                          width: isSmall ? 64 : 80,
                                          height: isSmall ? 64 : 80,
                                        )
                                      : Image.network(
                                          avatarUrl,
                                          fit: BoxFit.cover,
                                          width: isSmall ? 64 : 80,
                                          height: isSmall ? 64 : 80,
                                          errorBuilder: (c, e, s) => Icon(worker.profileIcon, size: isSmall ? 30 : 40, color: textCol),
                                        ))
                                  : Icon(worker.profileIcon, size: isSmall ? 30 : 40, color: textCol),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Spacer to clear the overlapping avatar
                    SizedBox(height: isSmall ? 38 : 48),

                    // Name, Verified Badge, Category, Skills — on the solid body
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isSmall ? 16.0 : 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name.toString().toUpperCase(),
                                  style: TextStyle(fontSize: isSmall ? 18 : 22, fontWeight: FontWeight.w900, color: textCol),
                                ),
                              ),
                              if (isVerified) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.verified_rounded, color: Colors.green, size: 22),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.toString().toUpperCase(),
                            style: TextStyle(fontSize: isSmall ? 11 : 13, color: textCol, fontWeight: FontWeight.w900),
                          ),
                          if (skills.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: skills.map((skill) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  border: Border.all(color: Colors.black, width: 1.5),
                                ),
                                child: Text(
                                  skill.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // Body content
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isSmall ? 16.0 : 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Trust stats dashboard
                          BrutalistCard(
                            color: Colors.white,
                            shadowOffset: 4.0,
                            padding: EdgeInsets.all(isSmall ? 10 : 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(child: _buildProfileStat(AppLocalizations.translate('hunar_score', locale), '$hunarScore/100', textCol)),
                                _buildVerticalDivider(),
                                Expanded(child: _buildProfileStat(AppLocalizations.translate('rating', locale), '$rating ⭐', textCol)),
                                _buildVerticalDivider(),
                                Expanded(child: _buildProfileStat(AppLocalizations.translate('experience', locale), experienceYears.toString().toUpperCase(), textCol)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Actions: View Portfolio button
                          SizedBox(
                            width: double.infinity,
                            child: BrutalistCard(
                              onTap: () {
                                if (_scrollController.hasClients) {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOut,
                                  );
                                }
                              },
                              color: Colors.black,
                              shadowOffset: 4.0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.photo_library_outlined, color: AppColors.accent),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.translate('view_portfolio_gallery', locale),
                                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Detailed statistics list
                          Text(
                            AppLocalizations.translate('performance_metrics', locale),
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textCol),
                          ),
                          const SizedBox(height: 12),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance.collection('users').doc(worker.id).snapshots(),
                            builder: (context, workerDocSnapshot) {
                              final data = workerDocSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                              final wSettings = data['settings'] as Map<String, dynamic>? ?? {};
                              final showEarnings = wSettings['showEarningsPublicly'] as bool? ?? false;
                              
                              int earnings = 12400;
                              if (worker.id == 'w1') {
                                earnings = 15400;
                              } else if (worker.id == 'w2') {
                                earnings = 23800;
                              } else if (worker.id == 'w3') {
                                earnings = 31200;
                              } else if (worker.id == 'w4') {
                                earnings = 8900;
                              }

                              return BrutalistCard(
                                color: Colors.white,
                                shadowOffset: 3.0,
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _buildMetricRow(context, AppLocalizations.translate('job_completion_rate', locale), worker.completionRate),
                                    const Divider(color: Colors.black, thickness: 1.0),
                                    _buildMetricRow(context, AppLocalizations.translate('average_response_time', locale), worker.responseTime),
                                    const Divider(color: Colors.black, thickness: 1.0),
                                    _buildMetricRow(context, AppLocalizations.translate('service_area_radius', locale), 'Up to 10 km'),
                                    const Divider(color: Colors.black, thickness: 1.0),
                                    _buildMetricRow(context, AppLocalizations.translate('completed_bookings', locale), '${worker.reviewsCount}+ Jobs'),
                                    if (showEarnings) ...[
                                      const Divider(color: Colors.black, thickness: 1.0),
                                      _buildMetricRow(context, AppLocalizations.translate('total_earnings', locale), '₹$earnings'),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Portfolio Gallery
                          Text(
                            AppLocalizations.translate('portfolio_gallery', locale),
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textCol),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedMediaTab = 0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _selectedMediaTab == 0 ? Colors.black : Colors.white,
                                      border: Border.all(color: Colors.black, width: 2.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${AppLocalizations.translate('photos', locale).toUpperCase()} (${portfolioImages.length})',
                                        style: TextStyle(
                                          color: _selectedMediaTab == 0 ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedMediaTab = 1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: _selectedMediaTab == 1 ? Colors.black : Colors.white,
                                      border: Border.all(color: Colors.black, width: 2.0),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${AppLocalizations.translate('videos', locale).toUpperCase()} (${portfolioVideos.length})',
                                        style: TextStyle(
                                          color: _selectedMediaTab == 1 ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_selectedMediaTab == 0) ...[
                            if (portfolioImages.isEmpty)
                              BrutalistCard(
                                color: Colors.white,
                                shadowOffset: 3.0,
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.translate('no_photos_yet', locale),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textMuted),
                                  ),
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.0,
                                ),
                                itemCount: portfolioImages.length,
                                itemBuilder: (context, index) {
                                  final imgBase64 = portfolioImages[index];
                                  return GestureDetector(
                                    onTap: () => _showLightbox(context, imgBase64),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: borderCol, width: 2.0),
                                      ),
                                      child: ClipRRect(
                                        child: Image.memory(
                                          base64Decode(imgBase64.split(',').last),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ] else ...[
                            if (portfolioVideos.isEmpty)
                              BrutalistCard(
                                color: Colors.white,
                                shadowOffset: 3.0,
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: Text(
                                    AppLocalizations.translate('no_videos_yet', locale),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textMuted),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: portfolioVideos.length,
                                itemBuilder: (context, index) {
                                  final video = portfolioVideos[index];
                                  final title = video['title'] ?? 'WORK VIDEO';
                                  final url = video['url'] ?? '';
                                  final duration = video['duration'] ?? 'LINK';

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () => _playVideo(context, title, url),
                                      child: BrutalistCard(
                                        color: Colors.white,
                                        shadowOffset: 3.0,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.accent,
                                                border: Border.all(color: Colors.black, width: 2.0),
                                              ),
                                              child: const Icon(Icons.play_arrow_rounded, color: Colors.black),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    title.toString().toUpperCase(),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: textCol),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${AppLocalizations.translate('duration', locale)}: $duration • ${AppLocalizations.translate('tap_to_play', locale)}',
                                                    style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],

                          const SizedBox(height: 120), // padding for bottom CTA
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Fixed Book Now CTA
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(isSmall ? 14 : 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.black, width: 3.0)),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppLocalizations.translate('estimated_pricing', locale), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                          Text(
                            '₹$pricePerHour/HOUR',
                            style: TextStyle(fontSize: isSmall ? 16 : 18, fontWeight: FontWeight.w900, color: Colors.black),
                          ),
                        ],
                      ),
                      const Spacer(),
                      BrutalistCard(
                        onTap: () {
                          final updatedWorker = Worker(
                            id: worker.id,
                            name: name,
                            category: category,
                            skills: skills,
                            rating: worker.rating,
                            reviewsCount: worker.reviewsCount,
                            hunarScore: hunarScore is num ? hunarScore.toInt() : worker.hunarScore,
                            location: data['location'] ?? worker.location,
                            pricePerHour: pricePerHour is num ? pricePerHour.toInt() : worker.pricePerHour,
                            distanceKm: worker.distanceKm,
                            experienceYears: experienceYears,
                            completionRate: worker.completionRate,
                            responseTime: worker.responseTime,
                            profileIcon: worker.profileIcon,
                            avatarUrl: avatarUrl,
                            isVerified: isVerified,
                          );
                          ref.read(navigationProvider.notifier).navigateTo(
                            AppRoute.customerBooking,
                            arguments: {
                              'worker': updatedWorker,
                              'selectedSkill': selectedSkill,
                            },
                          );
                        },
                        color: AppColors.accent,
                        shadowOffset: 3.0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: isSmall ? 24 : 32, vertical: 12),
                          child: Text(
                            AppLocalizations.translate('book_now', locale),
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: isSmall ? 12 : 14, color: Colors.black),
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
      },
    );
  }

  Widget _buildProfileStat(String title, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 2.5,
      height: 30,
      color: Colors.black,
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: textCol, fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }
}

// Live Call Simulator widget
class LiveDemoCallOverlay extends StatefulWidget {
  final Worker worker;
  const LiveDemoCallOverlay({super.key, required this.worker});

  @override
  State<LiveDemoCallOverlay> createState() => _LiveDemoCallOverlayState();
}

class _LiveDemoCallOverlayState extends State<LiveDemoCallOverlay> {
  int _secondsRemaining = 120; // 2 minutes
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LIVE DEMO CALL',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                      ),
                      Text(
                        widget.worker.name.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      border: Border.all(color: Colors.white, width: 2.0),
                    ),
                    child: Text(
                      _formatTime(_secondsRemaining),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Mock Video Box showing tool demonstration (No emojis!)
              BrutalistCard(
                color: Colors.white,
                shadowOffset: 0,
                child: SizedBox(
                  width: double.infinity,
                  height: 280,
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(widget.worker.profileIcon, size: 56, color: textCol),
                            const SizedBox(height: 16),
                            const Text(
                              'SIMULATED VIDEO STREAM...',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              color: Colors.black,
                              child: const Text(
                                'SHOWING TOOLBOX SAMPLES',
                                style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Client stream picture-in-picture
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          width: 70,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            border: Border.all(color: Colors.white, width: 2.0),
                          ),
                          child: const Center(
                            child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Actions Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white10,
                    child: IconButton(
                      icon: const Icon(Icons.mic_none_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 24),
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.call_end_outlined, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white10,
                    child: IconButton(
                      icon: const Icon(Icons.videocam_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerBookingScreen extends StatefulWidget {
  const CustomerBookingScreen({super.key});

  @override
  State<CustomerBookingScreen> createState() => _CustomerBookingScreenState();
}

class _CustomerBookingScreenState extends State<CustomerBookingScreen> {
  int _selectedDayIndex = 0;
  int _selectedHourIndex = 0;
  final TextEditingController _descController = TextEditingController();

  final List<String> _days = ['TODAY', 'TOMORROW', '21 JUNE', '22 JUNE'];
  final List<String> _slots = ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM', '06:00 PM'];

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final locale = ref.watch(localeProvider);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textCol = isDark ? Colors.white : Colors.black;
        final navState = ref.watch(navigationProvider);
        final args = navState.arguments as Map<String, dynamic>?;
        final worker = args?['worker'] as Worker? ?? mockWorkers[0];
        final selectedSkill = args?['selectedSkill'] as String?;
        if (selectedSkill != null && _descController.text.isEmpty) {
          _descController.text = "I NEED HELP WITH: $selectedSkill\n\n";
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.translate('job_details', locale)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textCol),
              onPressed: () {
                ref.read(navigationProvider.notifier).goBack();
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Worker context card
                  BrutalistCard(
                    color: Colors.white,
                    shadowOffset: 4.0,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        BrutalistCard(
                          color: AppColors.highlightGreen,
                          shadowOffset: 0,
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            child: Icon(worker.profileIcon, size: 22, color: textCol),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(worker.name.toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textCol)),
                            Text('${worker.category.toUpperCase()} PARTNER', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Spacer(),
                        Text('₹${worker.pricePerHour}/HR', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: textCol)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Select Date
                  Text(AppLocalizations.translate('select_date', locale), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textCol)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _days.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedDayIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDayIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.white,
                              border: Border.all(color: Colors.black, width: 2.5),
                            ),
                            child: Center(
                              child: Text(
                                _days[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Select Time Slot
                  Text(AppLocalizations.translate('select_time_slot', locale), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textCol)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _slots.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedHourIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedHourIndex = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.white,
                              border: Border.all(color: Colors.black, width: 2.5),
                            ),
                            child: Center(
                              child: Text(
                                _slots[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Job Questionnaire
                  Text(AppLocalizations.translate('job_details', locale), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textCol)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.translate('describe_issue_placeholder', locale),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Photo attachment button
                  GestureDetector(
                    onTap: () {},
                    child: BrutalistCard(
                      color: Colors.white,
                      shadowOffset: 2.0,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, color: textCol),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.translate('add_job_photos', locale), style: TextStyle(color: textCol, fontWeight: FontWeight.w900, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(navigationProvider.notifier).navigateTo(
                          AppRoute.customerPayment,
                          arguments: {
                            'worker': worker,
                            'date': _days[_selectedDayIndex],
                            'slot': _slots[_selectedHourIndex],
                            'desc': _descController.text,
                          },
                        );
                      },
                      child: BrutalistCard(
                        color: Colors.black,
                        shadowOffset: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              AppLocalizations.translate('proceed_to_payment', locale),
                              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CustomerPaymentScreen extends ConsumerWidget {
  const CustomerPaymentScreen({super.key});

  void _showRazorpaySimulatedPopup(BuildContext context, WidgetRef ref, Worker worker, Map<String, dynamic>? args) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1D212C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textCol = isDark ? Colors.white : Colors.black;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 3.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RAZORPAY LIVE',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textCol),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.black,
                    child: const Text(
                      'SECURE ESCROW',
                      style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'PAY TO HUNARLOOP ESCROW ACCOUNT',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'AMOUNT: ₹${(worker.pricePerHour * 2) + 60}',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: textCol),
              ),
              const SizedBox(height: 24),
              
              // Pay buttons
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    Navigator.pop(context); // close sheet
                    
                    final profile = ref.read(userProfileProvider);
                    final uid = profile?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? 'guest';
                    final customerName = profile?.name ?? 'Customer';
                    final bookingRef = FirebaseFirestore.instance.collection('bookings').doc();
                    await bookingRef.set({
                      'bookingId': bookingRef.id,
                      'customerId': uid,
                      'customerName': customerName,
                      'workerId': worker.id,
                      'workerName': worker.name,
                      'category': worker.category,
                      'slot': '${args?['date'] ?? 'TODAY'}, ${args?['slot'] ?? '11:00 AM'}',
                      'price': (worker.pricePerHour * 2) + 60,
                      'status': 'ON THE WAY',
                      'createdAt': FieldValue.serverTimestamp(),
                      'description': args?['desc'] ?? '',
                    });

                    ref.read(navigationProvider.notifier).resetTo(
                      AppRoute.customerActiveBooking,
                      arguments: {
                        'bookingId': bookingRef.id,
                        'worker': worker,
                      },
                    );
                  },
                  child: BrutalistCard(
                    color: AppColors.accent,
                    shadowOffset: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment_outlined, color: textCol),
                          SizedBox(width: 8),
                          Text('PAY VIA UPI / NETBANKING', style: TextStyle(fontWeight: FontWeight.w900, color: textCol)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL PAYMENT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final navState = ref.watch(navigationProvider);
    final args = navState.arguments as Map<String, dynamic>?;
    final worker = args?['worker'] as Worker? ?? mockWorkers[0];
    
    final int itemTotal = worker.pricePerHour * 2;
    const int convenienceFee = 40;
    const int gst = 20;
    final int grandTotal = itemTotal + convenienceFee + gst;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate('payment_summary', locale)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textCol),
          onPressed: () {
            ref.read(navigationProvider.notifier).goBack();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.translate('job_summary', locale), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textCol)),
              const SizedBox(height: 12),
              
              BrutalistCard(
                color: Colors.white,
                shadowOffset: 3.0,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow('Worker', worker.name.toUpperCase()),
                    _buildSummaryRow('Skill Category', worker.category.toUpperCase()),
                    _buildSummaryRow('Scheduled Slot', '${args?['date'] ?? 'TODAY'}, ${args?['slot'] ?? '11:00 AM'}'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(AppLocalizations.translate('billing_breakup', locale), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textCol)),
              const SizedBox(height: 12),

              BrutalistCard(
                color: Colors.white,
                shadowOffset: 3.0,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow('Base Pricing (₹${worker.pricePerHour}/hr x 2 hrs)', '₹$itemTotal'),
                    _buildSummaryRow('Escrow Handling Fee', '₹$convenienceFee'),
                    _buildSummaryRow('GST (18%)', '₹$gst'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: Colors.black, thickness: 1.5),
                    ),
                    _buildSummaryRow('Grand Total (Held in Escrow)', '₹$grandTotal', isBold: true, highlight: true),
                  ],
                ),
              ),

              const Spacer(),

              BrutalistCard(
                color: Colors.white,
                shadowOffset: 0,
                padding: const EdgeInsets.all(16),
                child: const Row(
                  children: [
                    Icon(Icons.security_outlined, color: Colors.black),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your money is safe. Payment is only released to the worker once you approve completion.',
                        style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => _showRazorpaySimulatedPopup(context, ref, worker, args),
                  child: BrutalistCard(
                    color: Colors.black,
                    shadowOffset: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          AppLocalizations.translate('proceed_to_checkout', locale),
                          style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              fontSize: isBold ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerActiveBookingScreen extends ConsumerStatefulWidget {
  const CustomerActiveBookingScreen({super.key});

  @override
  ConsumerState<CustomerActiveBookingScreen> createState() => _CustomerActiveBookingScreenState();
}

class _CustomerActiveBookingScreenState extends ConsumerState<CustomerActiveBookingScreen> {
  double _trackingProgress = 0.05;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_trackingProgress < 0.9) {
        setState(() {
          _trackingProgress += 0.15;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final navState = ref.watch(navigationProvider);
    final args = navState.arguments as Map<String, dynamic>?;
    final bookingId = args?['bookingId'] as String?;
    final worker = args?['worker'] as Worker? ?? mockWorkers[0];
    final uid = ref.watch(userProfileProvider)?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final settings = userData['settings'] as Map<String, dynamic>? ?? {};
        final locationAccess = settings['locationAccess'] as bool? ?? true;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.translate('track_booking', locale)),
            actions: [
              IconButton(
                icon: Icon(Icons.phone_outlined, color: textCol),
                onPressed: () {},
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tracker details
                  BrutalistCard(
                    color: Colors.white,
                    shadowOffset: 4.0,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('STATUS: PARTNER ON THE WAY', style: TextStyle(color: textCol, fontWeight: FontWeight.w900, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(
                              locationAccess
                                  ? (_trackingProgress >= 0.8 ? 'Arriving in 1 minute' : 'Estimated Arrival: 12 mins')
                                  : 'Estimated Arrival: BLOCKED',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textCol),
                            ),
                          ],
                        ),
                        CircularProgressIndicator(color: textCol, strokeWidth: 3.5),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mock Map tracking box
                  Expanded(
                    child: BrutalistCard(
                      color: Colors.white,
                      shadowOffset: 4.0,
                      child: !locationAccess
                          ? Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.location_off_outlined, color: Colors.red, size: 40),
                                    SizedBox(height: 8),
                                    Text(
                                      'MAP TRACKING BLOCKED',
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: textCol),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'ENABLE LOCATION ACCESS IN PROFILE SETTINGS',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: GridPainter(),
                                  ),
                                ),
                                
                                // Client location
                                Positioned(
                                  top: 50,
                                  left: 100,
                                  child: Column(
                                    children: [
                                      Icon(Icons.home_outlined, color: textCol, size: 28),
                                      Text('YOU', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: textCol)),
                                    ],
                                  ),
                                ),
                                
                                // Worker location
                                AnimatedPositioned(
                                  duration: const Duration(seconds: 1),
                                  top: 50 + (200 * (1 - _trackingProgress)),
                                  left: 100 + (100 * (1 - _trackingProgress)),
                                  child: Column(
                                    children: [
                                      Icon(Icons.directions_bike_outlined, color: textCol, size: 28),
                                      Text(worker.name.split(' ')[0].toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: textCol)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

              // Worker Card
              BrutalistCard(
                color: Colors.white,
                shadowOffset: 3.0,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    BrutalistCard(
                      color: AppColors.accent,
                      shadowOffset: 0,
                      child: SizedBox(
                        width: 38,
                        height: 38,
                        child: Icon(worker.profileIcon, color: textCol, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(worker.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: textCol, fontSize: 14)),
                          Text(
                            '${worker.isVerified ? "VERIFIED" : "UNVERIFIED"} ${worker.category.toUpperCase()} PARTNER',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ref.read(customerTabProvider.notifier).setTab(3);
                        ref.read(navigationProvider.notifier).resetTo(AppRoute.customerHome);
                      },
                      child: Icon(Icons.chat_bubble_outline_rounded, color: textCol),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Complete / Approve button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(color: Colors.black, width: 3.0),
                          ),
                          title: const Text('MARK JOB COMPLETE?', style: TextStyle(fontWeight: FontWeight.w900)),
                          content: Text(
                            'Approving this will instantly release the escrow payment to ${worker.name.toUpperCase()}\'s UPI account.',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('CANCEL', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                
                                if (bookingId != null) {
                                  await FirebaseFirestore.instance
                                      .collection('bookings')
                                      .doc(bookingId)
                                      .update({'status': 'COMPLETED'});
                                }
                                
                                if (!context.mounted) return;
                                ref.read(navigationProvider.notifier).resetTo(AppRoute.customerHome);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Payment Released Successfully! Thank you.'),
                                    backgroundColor: Colors.black,
                                  ),
                                );
                              },
                              child: Text('APPROVE & RELEASE', style: TextStyle(color: textCol, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const BrutalistCard(
                    color: Colors.black,
                    shadowOffset: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'APPROVE & MARK COMPLETE',
                          style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha(38)
      ..strokeWidth = 1.5;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VideoPlayerOverlay extends StatefulWidget {
  final String title;
  final String url;

  const VideoPlayerOverlay({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<VideoPlayerOverlay> createState() => _VideoPlayerOverlayState();
}

class _VideoPlayerOverlayState extends State<VideoPlayerOverlay> with SingleTickerProviderStateMixin {
  bool _isPlaying = true;
  int _currentSeconds = 0;
  final int _totalSeconds = 105; // 1m45s
  Timer? _timer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPlaying) {
        setState(() {
          if (_currentSeconds < _totalSeconds) {
            _currentSeconds++;
          } else {
            _isPlaying = false;
            _currentSeconds = 0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _rewind() {
    setState(() {
      _currentSeconds = (_currentSeconds - 10).clamp(0, _totalSeconds);
    });
  }

  void _fastForward() {
    setState(() {
      _currentSeconds = (_currentSeconds + 10).clamp(0, _totalSeconds);
    });
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final bgCol = isDark ? const Color(0xFF121212) : Colors.white;
    final borderCol = isDark ? Colors.white : Colors.black;

    // Resolve URL to play real video
    final resolvedUrl = widget.url.startsWith('http://') || 
                          widget.url.startsWith('https://') || 
                          widget.url.startsWith('blob:')
        ? widget.url
        : 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4';

    final progress = _currentSeconds / _totalSeconds;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: bgCol,
              border: Border.all(color: borderCol, width: 3.0),
              boxShadow: [
                BoxShadow(
                  color: borderCol,
                  offset: const Offset(8, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    border: Border(bottom: BorderSide(color: borderCol, width: 3.0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 2.0),
                          ),
                          child: const Icon(Icons.close, color: Colors.black, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                if (kIsWeb) ...[
                  // Real HTML5 Video View for web
                  Container(
                    height: 280,
                    color: Colors.black,
                    child: createWebVideoPlayer('video-player-${resolvedUrl.hashCode}', resolvedUrl),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: borderCol, width: 3.0)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: Colors.black, width: 2.0),
                              ),
                              child: const Center(
                                child: Text(
                                  'CLOSE PLAYER',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Simulated Screen Area for mobile
                  Container(
                    height: 200,
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Grid background visual
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.15,
                            child: CustomPaint(
                              painter: GridPainter(),
                            ),
                          ),
                        ),
                        // Video Status
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                final scale = 1.0 + (_animationController.value * 0.15);
                                return Transform.scale(
                                  scale: _isPlaying ? scale : 1.0,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: _isPlaying ? AppColors.accent : Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2.0),
                                    ),
                                    child: Icon(
                                      _isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                      color: Colors.black,
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isPlaying ? 'SIMULATING VIDEO STREAM...' : 'PAUSED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                widget.url,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 9,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Progress Info & Controls
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: borderCol, width: 3.0)),
                    ),
                    child: Column(
                      children: [
                        // Durations
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_currentSeconds),
                              style: TextStyle(
                                color: textCol,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(_totalSeconds),
                              style: TextStyle(
                                color: textCol,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Progress Bar
                        GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            final RenderBox box = context.findRenderObject() as RenderBox;
                            final localPos = box.globalToLocal(details.globalPosition);
                            final w = box.size.width - 32; // padding
                            final pct = (localPos.dx / w).clamp(0.0, 1.0);
                            setState(() {
                              _currentSeconds = (pct * _totalSeconds).toInt();
                            });
                          },
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.grey[200],
                              border: Border.all(color: borderCol, width: 2.0),
                            ),
                            child: Stack(
                              children: [
                                FractionallySizedBox(
                                  widthFactor: progress,
                                  child: Container(
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Rewind
                            _buildControlButton(
                              icon: Icons.replay_10_rounded,
                              onTap: _rewind,
                              borderCol: borderCol,
                            ),
                            const SizedBox(width: 16),
                            // Play/Pause
                            _buildControlButton(
                              icon: _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              onTap: _togglePlay,
                              isLarge: true,
                              borderCol: borderCol,
                            ),
                            const SizedBox(width: 16),
                            // Fast forward
                            _buildControlButton(
                              icon: Icons.forward_10_rounded,
                              onTap: _fastForward,
                              borderCol: borderCol,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Close Button
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border.all(color: Colors.black, width: 2.0),
                              ),
                              child: const Center(
                                child: Text(
                                  'CLOSE PLAYER',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color borderCol,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 12 : 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderCol, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: borderCol,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black,
          size: isLarge ? 28 : 20,
        ),
      ),
    );
  }
}
