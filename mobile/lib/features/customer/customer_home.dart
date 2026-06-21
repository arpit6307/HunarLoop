import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/router.dart';
import '../../core/models/worker.dart';
import '../../core/models/skills_data.dart';
import '../auth/onboarding_screen.dart'; // import BrutalistCard and userProfileProvider
import '../../core/utils/image_picker_helper.dart';
import '../../core/utils/crop_dialog.dart';
import '../../core/utils/localization.dart';
import '../../core/utils/support_center.dart';

class CustomerTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int val) {
    state = val;
  }
}

final customerTabProvider = NotifierProvider<CustomerTabNotifier, int>(CustomerTabNotifier.new);

class SearchFilterNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setFilter(String val) {
    state = val;
  }
}

final searchFilterProvider = NotifierProvider<SearchFilterNotifier, String>(SearchFilterNotifier.new);

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(customerTabProvider);
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final strokeCol = isDark ? Colors.white : Colors.black;
    final textCol = isDark ? Colors.white : Colors.black;
    final unselectedCol = isDark ? const Color(0xFFB0B0B0) : AppColors.textMuted;

    Widget activeView;
    switch (activeTab) {
      case 0:
        activeView = const CustomerHomeTabView();
        break;
      case 1:
        activeView = const CustomerSearchTabView();
        break;
      case 2:
        activeView = const CustomerBookingsTabView();
        break;
      case 3:
        activeView = const CustomerChatTabView();
        break;
      case 4:
        activeView = const CustomerProfileTabView();
        break;
      default:
        activeView = const CustomerHomeTabView();
    }

    final user = FirebaseAuth.instance.currentUser;
    final scaffold = Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: strokeCol, width: 3.0)),
          color: bgCol,
        ),
        child: BottomNavigationBar(
          currentIndex: activeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: bgCol,
          selectedItemColor: textCol,
          unselectedItemColor: unselectedCol,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: isSmall ? 8.0 : 10.0),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: isSmall ? 8.0 : 10.0),
          onTap: (index) {
            ref.read(customerTabProvider.notifier).setTab(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined, size: 20),
              activeIcon: const Icon(Icons.home_filled, size: 22),
              label: AppLocalizations.translate('home', locale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search_rounded, size: 20),
              label: AppLocalizations.translate('search', locale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today_outlined, size: 18),
              label: AppLocalizations.translate('bookings', locale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: AppLocalizations.translate('chat', locale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded, size: 20),
              label: AppLocalizations.translate('profile', locale),
            ),
          ],
        ),
      ),
      body: SafeArea(child: activeView),
    );

    if (user != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final isDisabled = data['isDisabled'] as bool? ?? false;
            if (isDisabled) {
              return Scaffold(
                backgroundColor: isDark ? const Color(0xFF0E1116) : const Color(0xFFFFE600),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: BrutalistCard(
                      color: Colors.white,
                      shadowOffset: 6.0,
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.gavel_rounded, color: Colors.red, size: 64),
                          const SizedBox(height: 16),
                          const Text(
                            'ACCOUNT DISABLED',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Your account has been disabled by the administration for violating platform guidelines. Please contact support@hunarloop.in for assistance.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              ref.read(userProfileProvider.notifier).clearUser();
                              ref.read(navigationProvider.notifier).resetTo(AppRoute.splash);
                            },
                            child: const BrutalistCard(
                              color: Colors.black,
                              shadowOffset: 0,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                child: Text(
                                  'LOGOUT & RETURN',
                                  style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          }
          return scaffold;
        },
      );
    }
    return scaffold;
  }
}

void _promptLocationPermission(BuildContext context, String uid) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bgCol = isDark ? const Color(0xFF1E1E1E) : Colors.white;
  final borderCol = isDark ? Colors.white : Colors.black;
  final textCol = isDark ? Colors.white : Colors.black;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: bgCol,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: borderCol, width: 3.0),
      ),
      title: Row(
        children: [
          Icon(Icons.location_on, color: textCol),
          const SizedBox(width: 8),
          Text(
            'LOCATION ACCESS',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textCol),
          ),
        ],
      ),
      content: Text(
        'ALLOW HUNARLOOP TO ACCESS YOUR DEVICE LOCATION TO MATCH YOU WITH NEARBY SERVICES?',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textCol),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await FirebaseFirestore.instance.collection('users').doc(uid).set({
              'settings': {'locationAccess': false},
            }, SetOptions(merge: true));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('LOCATION ACCESS DENIED. YOU CAN ENABLE IT IN SETTINGS.'),
                  backgroundColor: Colors.black,
                ),
              );
            }
          },
          child: const Text('DON\'T ALLOW', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);
            await FirebaseFirestore.instance.collection('users').doc(uid).set({
              'settings': {'locationAccess': true},
            }, SetOptions(merge: true));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('LOCATION ACCESS ALLOWED. LOCATION ENABLED IN SETTINGS!'),
                  backgroundColor: Colors.black,
                ),
              );
            }
          },
          child: Text('ALLOW', style: TextStyle(color: textCol, fontWeight: FontWeight.w900)),
        ),
      ],
    ),
  );
}

// ----------------------------------------------------
// TAB 0: HOME VIEW
// ----------------------------------------------------
class CustomerHomeTabView extends ConsumerWidget {
  const CustomerHomeTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final userProfile = ref.watch(userProfileProvider);
    final uid = userProfile?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final displayName = userProfile?.name.toUpperCase() ?? 'GUEST USER';
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final settings = userData['settings'] as Map<String, dynamic>? ?? {};
        
        if (uid != 'guest' && userSnapshot.hasData && userSnapshot.data!.exists) {
          if (settings['locationAccess'] == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _promptLocationPermission(context, uid);
            });
          }
        }

        final locationAccess = settings['locationAccess'] as bool? ?? true;
        final isVerified = userData['isVerified'] as bool? ?? false;
        final verificationStatus = userData['verificationStatus'] ?? 'none';
        final isUserVerified = isVerified || verificationStatus == 'approved';

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 12.0 : 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Top Row location and logout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 2.0),
                          ),
                          child: Icon(Icons.location_on_outlined, color: textCol, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      locationAccess ? 'HAZRATGANJ, LUCKNOW' : 'LOCATION DISABLED',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: textCol,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.keyboard_arrow_down_rounded, color: textCol, size: 16),
                                ],
                              ),
                              Text(
                                locationAccess ? 'UTTAR PRADESH' : 'BLOCKED IN SETTINGS',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          border: Border.all(color: Colors.black, width: 2.0),
                        ),
                        child: Icon(Icons.notifications_none_rounded, color: textCol, size: 18),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Hero Greeting Card
              BrutalistCard(
                color: AppColors.accent,
                shadowOffset: 4.0,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'NAMASTE, $displayName!',
                            style: TextStyle(
                              fontSize: isSmall ? 18 : 24,
                              fontWeight: FontWeight.w900,
                              color: textCol,
                            ),
                          ),
                        ),
                        if (isUserVerified) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: isSmall ? 20 : 26,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'READY TO WORK OR HIRE TODAY?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: textCol,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Categories Header
              Text(
                'BROWSE SKILLS BY CATEGORY',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textCol),
              ),
              const SizedBox(height: 12),

              // Scrollable Categories Row
              SizedBox(
                height: 104,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final cat = allCategories[index];
                    return _buildCategoryItem(context, ref, cat);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Recommended matches
              Text(
                'AI SMART MATCHES NEAR YOU',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textCol),
              ),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'worker')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('ERROR LOADING MATCHES');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: textCol));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  final List<Worker> workers = [];
                  for (final doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    
                    // Filter out private or offline workers
                    final isOnline = data['isOnline'] as bool? ?? true;
                    final wSettings = data['settings'] as Map<String, dynamic>? ?? {};
                    final privacyMode = wSettings['privacyMode'] as bool? ?? false;
                    if (!isOnline || privacyMode) {
                      continue;
                    }

                    final category = data['category'] ?? 'Home Services';
                    final icon = getCategoryIcon(category);

                    workers.add(Worker(
                      id: data['uid'] ?? doc.id,
                      name: data['name'] ?? 'Worker',
                      category: category,
                      skills: List<String>.from(data['skills'] ?? []),
                      rating: (data['rating'] ?? '4.8').toString(),
                      reviewsCount: data['reviewsCount'] ?? 42,
                      hunarScore: data['hunarScore'] ?? 90,
                      location: data['location'] ?? 'Hazratganj, Lucknow',
                      pricePerHour: data['pricePerHour'] ?? 350,
                      distanceKm: (data['distanceKm'] ?? 1.5).toDouble(),
                      experienceYears: data['experienceYears'] ?? '5 Years',
                      completionRate: data['completionRate'] ?? '95%',
                      responseTime: data['responseTime'] ?? '5 Mins',
                      profileIcon: icon,
                      avatarUrl: data['avatarUrl'] as String?,
                      isVerified: data['isVerified'] as bool? ?? false,
                    ));
                  }

                  if (workers.isEmpty) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      child: BrutalistCard(
                        color: AppColors.highlightPink,
                        shadowOffset: 4.0,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.people_outline_rounded, size: 48, color: Colors.black),
                            const SizedBox(height: 12),
                            const Text(
                              'NO ACTIVE PARTNERS YET',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Be the first to register as a worker or check back soon!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: workers.map((worker) => _buildWorkerCard(context, ref, worker, locationAccess)).toList(),
                  );
                },
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(BuildContext context, WidgetRef ref, CategoryInfo category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 78,
      child: Column(
        children: [
          BrutalistCard(
            onTap: () {
              ref.read(navigationProvider.notifier).navigateTo(
                AppRoute.customerCategoryDetails,
                arguments: category,
              );
            },
            color: category.color,
            shadowOffset: 3.0,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Center(
                child: Icon(category.icon, size: 24, color: textCol),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textCol),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(BuildContext context, WidgetRef ref, Worker worker, bool locationAccess) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: BrutalistCard(
        onTap: () {
          ref.read(navigationProvider.notifier).navigateTo(
            AppRoute.customerWorkerProfile,
            arguments: {'worker': worker},
          );
        },
        color: Colors.white,
        shadowOffset: 4.0,
        padding: EdgeInsets.all(isSmall ? 10.0 : 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BrutalistCard(
              color: AppColors.highlightPink,
              shadowOffset: 0,
              child: Container(
                width: isSmall ? 38 : 48,
                height: isSmall ? 38 : 48,
                alignment: Alignment.center,
                child: worker.avatarUrl != null && worker.avatarUrl!.isNotEmpty
                    ? (worker.avatarUrl!.startsWith('data:')
                        ? Image.memory(
                            base64Decode(worker.avatarUrl!.split(',').last),
                            fit: BoxFit.cover,
                            width: isSmall ? 38 : 48,
                            height: isSmall ? 38 : 48,
                          )
                        : Image.network(
                            worker.avatarUrl!,
                            fit: BoxFit.cover,
                            width: isSmall ? 38 : 48,
                            height: isSmall ? 38 : 48,
                            errorBuilder: (c, e, s) => Icon(worker.profileIcon, size: isSmall ? 18 : 24, color: textCol),
                          ))
                    : Icon(worker.profileIcon, size: isSmall ? 18 : 24, color: textCol),
              ),
            ),
            SizedBox(width: isSmall ? 10 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                worker.name.toUpperCase(),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: isSmall ? 13 : 15,
                                  fontWeight: FontWeight.w900,
                                  color: textCol,
                                ),
                              ),
                            ),
                            if (worker.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: Colors.green, size: 16),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        color: Colors.black,
                        child: Text(
                          'SCORE: ${worker.hunarScore}',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${worker.category.toUpperCase()} • ${worker.experienceYears.toUpperCase()} EXP',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: isSmall ? 10 : 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: textCol, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        worker.rating,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textCol),
                      ),
                      Text(
                        ' (${worker.reviewsCount})',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.location_on_outlined, color: textCol, size: 12),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          locationAccess ? '${worker.distanceKm} KM' : 'BLOCKED',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
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
}

// ----------------------------------------------------
// TAB 1: SEARCH VIEW
// ----------------------------------------------------
class CustomerSearchTabView extends ConsumerStatefulWidget {
  const CustomerSearchTabView({super.key});

  @override
  ConsumerState<CustomerSearchTabView> createState() => _CustomerSearchTabViewState();
}

class _CustomerSearchTabViewState extends ConsumerState<CustomerSearchTabView> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(searchFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final query = ref.watch(searchFilterProvider);
    final userProfile = ref.watch(userProfileProvider);
    final uid = userProfile?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
        final settings = userData['settings'] as Map<String, dynamic>? ?? {};
        final locationAccess = settings['locationAccess'] as bool? ?? true;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'worker')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('ERROR LOADING SEARCH RESULTS'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: textCol));
            }

            final docs = snapshot.data?.docs ?? [];
            final List<Worker> workers = [];
            for (final doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              
              // Filter out private or offline workers
              final isOnline = data['isOnline'] as bool? ?? true;
              final wSettings = data['settings'] as Map<String, dynamic>? ?? {};
              final privacyMode = wSettings['privacyMode'] as bool? ?? false;
              if (!isOnline || privacyMode) {
                continue;
              }

              final name = (data['name'] ?? '').toString().toLowerCase();
              final category = (data['category'] ?? '').toString().toLowerCase();
              final skills = List<String>.from(data['skills'] ?? []).map((s) => s.toLowerCase()).toList();
              final q = query.toLowerCase();

              // Apply client-side category filter chip
              if (_selectedCategoryFilter != null &&
                  category != _selectedCategoryFilter!.toLowerCase()) {
                continue;
              }

              // Apply client-side search query (matching name, category, or skills)
              if (q.isNotEmpty) {
                final matchesName = name.contains(q);
                final matchesCategory = category.contains(q);
                final matchesSkills = skills.any((skill) => skill.contains(q));
                if (!matchesName && !matchesCategory && !matchesSkills) {
                  continue;
                }
              }

              final icon = getCategoryIcon(data['category'] ?? 'Home Services');

              workers.add(Worker(
                id: data['uid'] ?? doc.id,
                name: data['name'] ?? 'Worker',
                category: data['category'] ?? 'Home Services',
                skills: List<String>.from(data['skills'] ?? []),
                rating: (data['rating'] ?? '4.8').toString(),
                reviewsCount: data['reviewsCount'] ?? 42,
                hunarScore: data['hunarScore'] ?? 90,
                location: data['location'] ?? 'Hazratganj, Lucknow',
                pricePerHour: data['pricePerHour'] ?? 350,
                distanceKm: (data['distanceKm'] ?? 1.5).toDouble(),
                experienceYears: data['experienceYears'] ?? '5 Years',
                completionRate: data['completionRate'] ?? '95%',
                responseTime: data['responseTime'] ?? '5 Mins',
                profileIcon: icon,
                avatarUrl: data['avatarUrl'] as String?,
                isVerified: data['isVerified'] as bool? ?? false,
              ));
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Search Textbox
                  BrutalistCard(
                    color: Colors.white,
                    shadowOffset: 3.0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: textCol),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(color: textCol, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              hintText: 'SEARCH SERVICES...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onChanged: (val) {
                              ref.read(searchFilterProvider.notifier).setFilter(val.trim());
                            },
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, color: textCol),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchFilterProvider.notifier).setFilter('');
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: allCategories.map((cat) {
                        final isSelected = _selectedCategoryFilter == cat.name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10, bottom: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedCategoryFilter = null;
                                } else {
                                  _selectedCategoryFilter = cat.name;
                                }
                              });
                            },
                            child: BrutalistCard(
                              color: isSelected
                                  ? AppColors.accent
                                  : (isDark ? const Color(0xFF1D212C) : Colors.white),
                              shadowOffset: 2.0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    cat.icon,
                                    size: 14,
                                    color: isSelected ? Colors.black : textCol,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat.name.toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : textCol,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AVAILABLE PARTNERS (${workers.length})',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: textCol),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: workers.isEmpty
                        ? Center(
                            child: Text(
                              'NO LOCAL PARTNERS FOUND',
                              style: TextStyle(fontWeight: FontWeight.w900, color: textCol),
                            ),
                          )
                        : ListView.builder(
                            itemCount: workers.length,
                            itemBuilder: (context, index) {
                              final worker = workers[index];
                              final screenW = MediaQuery.of(context).size.width;
                              final isSmall = screenW < 360;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: BrutalistCard(
                                  onTap: () {
                                    ref.read(navigationProvider.notifier).navigateTo(
                                      AppRoute.customerWorkerProfile,
                                      arguments: {'worker': worker},
                                    );
                                  },
                                  color: Colors.white,
                                  shadowOffset: 4.0,
                                  padding: EdgeInsets.all(isSmall ? 10.0 : 16.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      BrutalistCard(
                                        color: AppColors.highlightBlue,
                                        shadowOffset: 0,
                                        child: Container(
                                          width: isSmall ? 38 : 48,
                                          height: isSmall ? 38 : 48,
                                          alignment: Alignment.center,
                                          child: worker.avatarUrl != null && worker.avatarUrl!.isNotEmpty
                                              ? (worker.avatarUrl!.startsWith('data:')
                                                  ? Image.memory(
                                                      base64Decode(worker.avatarUrl!.split(',').last),
                                                      fit: BoxFit.cover,
                                                      width: isSmall ? 38 : 48,
                                                      height: isSmall ? 38 : 48,
                                                    )
                                                  : Image.network(
                                                      worker.avatarUrl!,
                                                      fit: BoxFit.cover,
                                                      width: isSmall ? 38 : 48,
                                                      height: isSmall ? 38 : 48,
                                                      errorBuilder: (c, e, s) => Icon(worker.profileIcon, size: isSmall ? 18 : 24, color: textCol),
                                                    ))
                                              : Icon(worker.profileIcon, size: isSmall ? 18 : 24, color: textCol),
                                        ),
                                      ),
                                      SizedBox(width: isSmall ? 10 : 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    worker.name.toUpperCase(),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(fontSize: isSmall ? 13 : 15, fontWeight: FontWeight.w900, color: textCol),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '₹${worker.pricePerHour}/HR',
                                                  style: TextStyle(fontSize: isSmall ? 11 : 13, fontWeight: FontWeight.w900, color: textCol),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${worker.category.toUpperCase()} • ${worker.experienceYears.toUpperCase()} EXP',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(fontSize: isSmall ? 10 : 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.star_rounded, color: textCol, size: 14),
                                                const SizedBox(width: 2),
                                                Text(
                                                  worker.rating,
                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textCol),
                                                ),
                                                SizedBox(width: isSmall ? 8 : 12),
                                                Icon(Icons.location_on_outlined, color: textCol, size: 12),
                                                const SizedBox(width: 2),
                                                Flexible(
                                                  child: Text(
                                                    locationAccess ? '${worker.distanceKm} KM' : 'BLOCKED',
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                  color: Colors.black,
                                                  child: Text(
                                                    'SCORE: ${worker.hunarScore}',
                                                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.accent),
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
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ----------------------------------------------------
// TAB 2: BOOKINGS VIEW
// ----------------------------------------------------
class CustomerBookingsTabView extends ConsumerWidget {
  const CustomerBookingsTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final userProfile = ref.watch(userProfileProvider);
    final uid = userProfile?.uid ?? 'guest';
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('customerId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: textCol));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('ERROR LOADING BOOKINGS'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text(
              'NO ACTIVE BOOKINGS YET',
              style: TextStyle(fontWeight: FontWeight.w900, color: textCol),
            ),
          );
        }

        final bookings = docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 14.0 : 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'YOUR ACTIVE BOOKINGS',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: isSmall ? 14 : 16, color: textCol),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final item = bookings[index];
                    final status = item['status'] ?? 'PENDING';
                    final isTrackingAvailable = status == 'ON THE WAY';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: BrutalistCard(
                        color: Colors.white,
                        shadowOffset: 4.0,
                        padding: EdgeInsets.all(isSmall ? 12 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    (item['workerName'] as String? ?? 'WORKER').toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: isSmall ? 13 : 15, color: textCol),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  color: Colors.black,
                                  child: Text(
                                    status,
                                    style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: isSmall ? 8 : 9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SERVICE: ${(item['category'] as String? ?? '').toUpperCase()}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: isSmall ? 10 : 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'SLOT: ${item['slot']}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: isSmall ? 10 : 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'TOTAL PRICE: ₹${item['price']} (HELD IN ESCROW)',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontSize: isSmall ? 10 : 11, color: textCol, fontWeight: FontWeight.w900),
                            ),
                            if (status == 'COMPLETED') ...[
                              const SizedBox(height: 12),
                              BrutalistCard(
                                color: Colors.green,
                                shadowOffset: 0,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: const Center(
                                  child: Text(
                                    'PAYOUT RELEASED',
                                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ] else ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  if (isTrackingAvailable) ...[
                                    Expanded(
                                      child: BrutalistCard(
                                        onTap: () {
                                          ref.read(navigationProvider.notifier).navigateTo(
                                            AppRoute.customerActiveBooking,
                                            arguments: {
                                              'bookingId': item['bookingId'],
                                              'worker': Worker(
                                                id: item['workerId'] ?? '',
                                                name: item['workerName'] ?? '',
                                                category: item['category'] ?? '',
                                                skills: const [],
                                                rating: '4.8',
                                                reviewsCount: 42,
                                                hunarScore: 90,
                                                location: 'Hazratganj, Lucknow',
                                                pricePerHour: 350,
                                                distanceKm: 1.5,
                                                experienceYears: '5 Years',
                                                completionRate: '95%',
                                                responseTime: '5 Mins',
                                                profileIcon: getCategoryIcon(item['category'] ?? ''),
                                              ),
                                            },
                                          );
                                        },
                                        color: AppColors.accent,
                                        shadowOffset: 3.0,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: const Center(
                                          child: Text('TRACK LOCATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: BrutalistCard(
                                      onTap: () async {
                                        final bId = item['bookingId'];
                                        if (bId != null) {
                                          await FirebaseFirestore.instance
                                              .collection('bookings')
                                              .doc(bId)
                                              .update({'status': 'COMPLETED'});
                                        }
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('ESCROW RELEASED SUCCESSFULLY!'),
                                            backgroundColor: Colors.black,
                                          ),
                                        );
                                      },
                                      color: Colors.black,
                                      shadowOffset: 3.0,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: const Center(
                                        child: Text(
                                          'RELEASE PAYOUT',
                                          style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------
// TAB 3: CHAT VIEW (Working Messenger with Firestore!)
// ----------------------------------------------------
class CustomerChatTabView extends ConsumerWidget {
  const CustomerChatTabView({super.key});

  void _openChatRoom(BuildContext context, String workerName, String chatId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(title: workerName, chatId: chatId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final userProfile = ref.watch(userProfileProvider);
    final uid = userProfile?.uid ?? 'guest';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('customerId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: textCol));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('ERROR LOADING CHAT CHANNELS'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Text(
              'NO ACTIVE CHATS YET',
              style: TextStyle(fontWeight: FontWeight.w900, color: textCol),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          key: const ValueKey('chat_tab'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'CHAT MESSAGES',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final booking = docs[index].data() as Map<String, dynamic>;
                    final workerName = booking['workerName'] ?? 'WORKER';
                    final chatId = booking['bookingId'] ?? docs[index].id;
                    final category = booking['category'] ?? 'SERVICE';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _openChatRoom(context, workerName, chatId),
                        child: BrutalistCard(
                          color: Colors.white,
                          shadowOffset: 3.0,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              BrutalistCard(
                                color: AppColors.highlightPink,
                                shadowOffset: 0,
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: Icon(Icons.chat_bubble_outline_rounded, color: textCol, size: 20),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            workerName.toString().toUpperCase(),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          category.toString().toUpperCase(),
                                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('chats')
                                          .doc(chatId)
                                          .collection('messages')
                                          .orderBy('timestamp', descending: true)
                                          .limit(1)
                                          .snapshots(),
                                      builder: (context, msgSnapshot) {
                                        String lastMsg = 'TAP TO CHAT WITH PARTNER';
                                        if (msgSnapshot.hasData && msgSnapshot.data!.docs.isNotEmpty) {
                                          lastMsg = msgSnapshot.data!.docs.first.get('text') ?? '';
                                        }
                                        return Text(
                                          lastMsg.toUpperCase(),
                                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        );
                                      },
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
              ),
            ],
          ),
        );
      },
    );
  }
}

// Interactive Chat Room Dialog Screen
class ChatRoomScreen extends ConsumerStatefulWidget {
  final String title;
  final String chatId;
  const ChatRoomScreen({super.key, required this.title, required this.chatId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _msgController = TextEditingController();

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();

    final myEmail = ref.read(userProfileProvider)?.email ?? FirebaseAuth.instance.currentUser?.email ?? 'CUSTOMER';

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'text': text,
      'sender': myEmail,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final myEmail = ref.watch(userProfileProvider)?.email ?? FirebaseAuth.instance.currentUser?.email ?? 'customer@hunarloop.in';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textCol),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  // Fallback mock messages if Firestore is empty or offline
                  List<Map<String, dynamic>> messages = [];
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    messages = snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                  } else {
                    messages = [
                      {'text': 'Hello! I am on my way to your location.', 'sender': 'sunil@hunarloop.in'},
                      {'text': 'Ok, sure! Thanks.', 'sender': myEmail},
                    ];
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['sender'] == myEmail;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                          child: BrutalistCard(
                            color: isMe ? AppColors.accent : Colors.white,
                            shadowOffset: 2.0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Text(
                              msg['text'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            // Textfield and Send button in footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1D212C) : Colors.white,
                border: const Border(top: BorderSide(color: Colors.black, width: 3.0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'TYPE MESSAGE HERE...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const BrutalistCard(
                      color: Colors.black,
                      shadowOffset: 0,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send_rounded, color: AppColors.accent, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// TAB 4: PROFILE VIEW
// ----------------------------------------------------
class CustomerProfileTabView extends ConsumerStatefulWidget {
  const CustomerProfileTabView({super.key});

  @override
  ConsumerState<CustomerProfileTabView> createState() => _CustomerProfileTabViewState();
}

class _CustomerProfileTabViewState extends ConsumerState<CustomerProfileTabView> {
  // Settings local state
  bool _pushNotifications = true;
  bool _darkMode = false;
  String _language = 'ENGLISH';
  String _state = 'Uttar Pradesh';
  bool _locationAccess = true;
  bool _privacyMode = false;
  bool _settingsLoaded = false;

  String _idType = 'Aadhaar Card';
  final TextEditingController _idController = TextEditingController();
  String? _idCardPhotoBase64;
  String? _idCardPhotoBackBase64;
  bool _isSubmittingId = false;
  bool _showIdNumber = false;

  StreamSubscription<DocumentSnapshot>? _settingsSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToSettings();
  }

  void _subscribeToSettings() {
    final uid = ref.read(userProfileProvider)?.uid ?? 'guest';
    if (uid == 'guest') {
      return;
    }
    
    _settingsSubscription?.cancel();
    _settingsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final data = snapshot.data() ?? {};
        final settings = data['settings'] as Map<String, dynamic>? ?? {};
        setState(() {
          _pushNotifications = settings['pushNotifications'] as bool? ?? true;
          _darkMode = settings['darkMode'] as bool? ?? false;
          _language = settings['language'] as String? ?? 'ENGLISH';
          _state = settings['state'] as String? ?? 'Uttar Pradesh';
          _locationAccess = settings['locationAccess'] as bool? ?? true;
          _privacyMode = settings['privacyMode'] as bool? ?? false;
          _settingsLoaded = true;
        });

        // Ensure theme and locale are synced
        final fallbackLocale = AppLocalizations.getFallbackLocale(_language);
        if (ref.read(localeProvider) != fallbackLocale) {
          ref.read(localeProvider.notifier).setLocale(fallbackLocale);
        }
        final expectedThemeMode = _darkMode ? ThemeMode.dark : ThemeMode.light;
        if (ref.read(themeModeProvider) != expectedThemeMode) {
          ref.read(themeModeProvider.notifier).setThemeMode(expectedThemeMode);
        }
      }
    });
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    _idController.dispose();
    super.dispose();
  }

  void _loadSettingsFromData(Map<String, dynamic> data) {
    if (_settingsLoaded) {
      return;
    }
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    _pushNotifications = settings['pushNotifications'] as bool? ?? true;
    _darkMode = settings['darkMode'] as bool? ?? false;
    _language = settings['language'] as String? ?? 'ENGLISH';
    _state = settings['state'] as String? ?? 'Uttar Pradesh';
    _locationAccess = settings['locationAccess'] as bool? ?? true;
    _privacyMode = settings['privacyMode'] as bool? ?? false;
    _settingsLoaded = true;
  }

  Future<void> _updateSettingInFirestore(String uid, String key, dynamic value) async {
    if (uid == 'guest') {
      return;
    }
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'settings': {key: value},
    }, SetOptions(merge: true));
  }

  void _showEditProfileDialog(BuildContext context, String uid, Map<String, dynamic> currentData, UserProfile? profile, WidgetRef ref) {
    final nameController = TextEditingController(text: currentData['name'] ?? profile?.name ?? '');
    final phoneController = TextEditingController(text: currentData['phone'] ?? profile?.phone ?? '');
    final addressController = TextEditingController(text: currentData['address'] ?? '');
    
    String preferredContact = currentData['preferredContact'] ?? 'In-App Chat';
    final contactMethods = ['In-App Chat', 'Phone Calls', 'WhatsApp/SMS'];
    if (!contactMethods.contains(preferredContact)) preferredContact = 'In-App Chat';

    String preferredSlot = currentData['preferredSlot'] ?? 'Morning (9 AM - 12 PM)';
    final slotOptions = ['Morning (9 AM - 12 PM)', 'Afternoon (12 PM - 4 PM)', 'Evening (4 PM - 8 PM)'];
    if (!slotOptions.contains(preferredSlot)) preferredSlot = 'Morning (9 AM - 12 PM)';

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final dialogBg = isDark ? const Color(0xFF1D212C) : Colors.white;
            final textCol = isDark ? Colors.white : Colors.black;
            return AlertDialog(
              backgroundColor: dialogBg,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(color: Colors.black, width: 3.0),
              ),
              title: Text(
                'EDIT PROFILE DETAILS',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textCol),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('FULL NAME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    const Text('PHONE NUMBER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    const Text('SERVICE ADDRESS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: addressController,
                      maxLines: 2,
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 14),
                    const Text('PREFERRED CONTACT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: preferredContact,
                      dropdownColor: dialogBg,
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: contactMethods.map((m) {
                        return DropdownMenuItem<String>(
                          value: m,
                          child: Text(m.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            preferredContact = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text('PREFERRED SLOT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: preferredSlot,
                      dropdownColor: dialogBg,
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: slotOptions.map((s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Text(s.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            preferredSlot = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('CANCEL', style: TextStyle(color: textCol, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final phone = phoneController.text.trim();
                    final address = addressController.text.trim();

                    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PLEASE FILL ALL FIELDS'), backgroundColor: Colors.black),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance.collection('users').doc(uid).update({
                      'name': name,
                      'phone': phone,
                      'address': address,
                      'preferredContact': preferredContact,
                      'preferredSlot': preferredSlot,
                    });

                    final profile = ref.read(userProfileProvider);
                    if (profile != null) {
                      ref.read(userProfileProvider.notifier).setUser(UserProfile(
                        uid: profile.uid,
                        name: name,
                        email: profile.email,
                        phone: phone,
                        role: profile.role,
                      ));
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PROFILE UPDATED SUCCESSFULLY!'), backgroundColor: Colors.black),
                      );
                    }
                  },
                  child: Text('SAVE CHANGES', style: TextStyle(color: textCol, fontWeight: FontWeight.w900)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSettingToggleRow(BuildContext context, String label, bool value, ValueChanged<bool> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: textCol)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: isDark ? Colors.white : Colors.black,
            activeTrackColor: AppColors.accent,
            inactiveThumbColor: isDark ? Colors.black : Colors.white,
            inactiveTrackColor: isDark ? Colors.white12 : AppColors.textMuted.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTapRow(BuildContext context, String label, {String? trailing, Color? textColor, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = textColor ?? (isDark ? Colors.white : Colors.black);
    final iconCol = isDark ? Colors.white : Colors.black;
    final mutedTextCol = isDark ? const Color(0xFFB0B0B0) : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: textCol)),
            if (trailing != null)
              Text(trailing, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: textColor ?? mutedTextCol))
            else
              Icon(Icons.chevron_right_rounded, color: iconCol, size: 20),
          ],
        ),
      ),
    );
  }

  Future<String?> _pickImageWithSource() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textCol = isDark ? Colors.white : Colors.black;

    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: bgCol,
      shape: Border(
        top: BorderSide(color: textCol, width: 3.0),
        left: BorderSide(color: textCol, width: 3.0),
        right: BorderSide(color: textCol, width: 3.0),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SELECT ID PHOTO SOURCE',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: textCol),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: textCol),
                title: Text('TAKE PHOTO (CAMERA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textCol)),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
              Divider(color: textCol, thickness: 1.5),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: textCol),
                title: Text('CHOOSE FROM GALLERY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textCol)),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return null;
    if (source == 'camera') {
      return captureImageFromCamera();
    } else if (source == 'gallery') {
      return pickImageFromGallery();
    }
    return null;
  }

  Widget _buildUploadCard({
    required String title,
    required String? imageBase64,
    required VoidCallback onTap,
    required VoidCallback onDelete,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: BrutalistCard(
        color: imageBase64 != null ? bgCol : const Color(0xFFFFFAD1),
        shadowOffset: 2.0,
        child: Container(
          height: 120,
          width: double.infinity,
          alignment: Alignment.center,
          child: imageBase64 != null
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: Image.memory(
                        base64Decode(imageBase64.split(',').last),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, color: Colors.black, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'TAP TO CAPTURE OR UPLOAD PHOTO',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: Colors.black54),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _submitVerification(String uid) async {
    final idNo = _idController.text.trim();
    if (idNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE ENTER A VALID ID NUMBER'), backgroundColor: Colors.black),
      );
      return;
    }
    if (_idType == 'Aadhaar Card') {
      if (_idCardPhotoBase64 == null || _idCardPhotoBackBase64 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PLEASE UPLOAD BOTH FRONT AND BACK PHOTOS OF YOUR AADHAAR CARD'), backgroundColor: Colors.black),
        );
        return;
      }
    } else {
      if (_idCardPhotoBase64 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PLEASE UPLOAD A PHOTO OF YOUR ID CARD'), backgroundColor: Colors.black),
        );
        return;
      }
    }

    setState(() => _isSubmittingId = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'idType': _idType,
        'idNumber': idNo,
        'idCardPhoto': _idCardPhotoBase64,
        if (_idType == 'Aadhaar Card') 'idCardPhotoBack': _idCardPhotoBackBase64,
        'verificationStatus': 'pending',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID SUBMITTED FOR REVIEW!'), backgroundColor: Colors.black),
      );
      _idController.clear();
      setState(() {
        _idCardPhotoBase64 = null;
        _idCardPhotoBackBase64 = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ERROR SUBMITTING ID: ${e.toString().toUpperCase()}'), backgroundColor: Colors.black),
      );
    } finally {
      setState(() => _isSubmittingId = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final uid = profile?.uid ?? 'guest';
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final borderCol = isDark ? Colors.white : Colors.black;
    final bgCol = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final mutedTextCol = isDark ? const Color(0xFFB0B0B0) : AppColors.textMuted;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        _loadSettingsFromData(data);
        final email = data['email'] ?? profile?.email ?? 'GUEST@HUNARLOOP.IN';
        final phone = data['phone'] ?? profile?.phone ?? '9999999999';
        final address = data['address'] ?? 'NOT ADDED YET';
        final preferredContact = data['preferredContact'] ?? 'IN-APP CHAT';
        final preferredSlot = data['preferredSlot'] ?? 'MORNING (9 AM - 12 PM)';
        final name = data['name'] ?? profile?.name ?? 'GUEST USER';
        final avatarUrl = data['avatarUrl'] as String?;
        final isVerified = data['isVerified'] as bool? ?? false;
        final verificationStatus = data['verificationStatus'] ?? 'none';

        return SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 14.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isSmall ? 10 : 20),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final base64Image = await pickImageFromGallery();
                        if (base64Image == null) return;
                        if (!context.mounted) return;

                        final croppedBase64 = await showDialog<String>(
                          context: context,
                          builder: (context) => CropDialog(imageBase64: base64Image),
                        );

                        if (croppedBase64 != null && uid != 'guest') {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .update({'avatarUrl': croppedBase64});
                        }
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          BrutalistCard(
                            color: AppColors.highlightPink,
                            shadowOffset: 4.0,
                            child: SizedBox(
                              width: isSmall ? 64 : 80,
                              height: isSmall ? 64 : 80,
                              child: avatarUrl != null && avatarUrl.isNotEmpty
                                  ? (avatarUrl.startsWith('data:')
                                      ? Image.memory(
                                          base64Decode(avatarUrl.split(',').last),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          avatarUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Icon(Icons.person_outline_rounded, size: isSmall ? 28 : 36, color: textCol),
                                        ))
                                  : Icon(Icons.person_outline_rounded, size: isSmall ? 28 : 36, color: textCol),
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.rectangle,
                                border: Border.all(color: borderCol, width: 2.0),
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: isSmall ? 11 : 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name.toString().toUpperCase(),
                          style: TextStyle(fontSize: isSmall ? 18 : 22, fontWeight: FontWeight.w900, color: textCol),
                        ),
                        if (isVerified || verificationStatus == 'approved') ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: isSmall ? 18 : 22,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      email.toString().toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: mutedTextCol),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmall ? 16 : 28),
              
              BrutalistCard(
                color: bgCol,
                shadowOffset: 4.0,
                padding: EdgeInsets.all(isSmall ? 12 : 16),
                child: Column(
                  children: [
                    _buildProfileDetailRow(context, 'PHONE', phone.toString().toUpperCase()),
                    Divider(color: borderCol, thickness: 1.0),
                    _buildProfileDetailRow(
                      context,
                      'ADDRESS',
                      _locationAccess ? address.toString().toUpperCase() : 'BLOCKED IN SETTINGS',
                    ),
                    Divider(color: borderCol, thickness: 1.0),
                    _buildProfileDetailRow(context, 'CONTACT METHOD', preferredContact.toString().toUpperCase()),
                    Divider(color: borderCol, thickness: 1.0),
                    _buildProfileDetailRow(context, 'PREFERRED SLOT', preferredSlot.toString().toUpperCase()),
                    Divider(color: borderCol, thickness: 1.0),
                    _buildProfileDetailRow(context, 'ACCOUNT ROLE', 'CUSTOMER'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                child: BrutalistCard(
                  onTap: () => _showEditProfileDialog(context, uid, data, profile, ref),
                  color: AppColors.accent,
                  shadowOffset: 3.0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: isSmall ? 10 : 12),
                    child: Center(
                      child: Text(
                        AppLocalizations.translate('edit_profile', locale),
                        style: TextStyle(color: textCol, fontWeight: FontWeight.w900, fontSize: 11),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Government ID Verification Section
              (() {
                final verificationStatus = data['verificationStatus'] ?? 'none';
                final isVerified = data['isVerified'] as bool? ?? false;
                final currentIdType = data['idType'] ?? 'Aadhaar Card';
                final idNumber = data['idNumber'] ?? '';

                String maskIdNumber(String idNo, bool show) {
                  if (show) return idNo;
                  final clean = idNo.replaceAll(' ', '');
                  if (clean.length <= 4) return '••••';
                  if (clean.length == 12) {
                    return '•••• •••• ${clean.substring(8)}';
                  } else {
                    return '•••• •••• ${clean.substring(clean.length - 4)}';
                  }
                }

                return BrutalistCard(
                  color: bgCol,
                  shadowOffset: 3.0,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'GOVERNMENT ID VERIFICATION',
                            style: TextStyle(fontWeight: FontWeight.w900, color: textCol, fontSize: 12),
                          ),
                          if (isVerified || verificationStatus == 'approved')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              color: Colors.blue,
                              child: const Text('VERIFIED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8)),
                            )
                          else if (verificationStatus == 'pending')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              color: Colors.orange,
                              child: const Text('PENDING REVIEW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8)),
                            )
                          else if (verificationStatus == 'rejected')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              color: Colors.red,
                              child: const Text('REJECTED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8)),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              color: Colors.red,
                              child: const Text('UNVERIFIED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Verify your identity using Aadhaar or PAN card. This will unlock a verified badge and give you a higher Hunar Score.',
                        style: TextStyle(color: mutedTextCol, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      if (isVerified || verificationStatus == 'approved') ...[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.blue, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  'YOUR ID WAS VERIFIED SUCCESSFULLY!',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.blue),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderCol, width: 2.0),
                                    color: isDark ? Colors.black26 : Colors.grey.shade100,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${currentIdType.toUpperCase()}: ${maskIdNumber(idNumber, _showIdNumber)}',
                                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: textCol),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _showIdNumber ? Icons.visibility : Icons.visibility_off,
                                          color: textCol,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showIdNumber = !_showIdNumber;
                                          });
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(Icons.copy_rounded, color: textCol, size: 18),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: idNumber));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('ID NUMBER COPIED TO CLIPBOARD'), backgroundColor: Colors.black),
                                          );
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else if (verificationStatus == 'pending') ...[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderCol, width: 2.0),
                                    color: isDark ? Colors.black26 : Colors.grey.shade100,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${currentIdType.toUpperCase()}: ${maskIdNumber(idNumber, _showIdNumber)}',
                                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: textCol),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _showIdNumber ? Icons.visibility : Icons.visibility_off,
                                          color: textCol,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showIdNumber = !_showIdNumber;
                                          });
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(Icons.copy_rounded, color: textCol, size: 18),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: idNumber));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('ID NUMBER COPIED TO CLIPBOARD'), backgroundColor: Colors.black),
                                          );
                                        },
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'ID details submitted. Admin panel will verify and issue your Green Badge shortly.',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: mutedTextCol),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        if (verificationStatus == 'rejected') ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: const Text(
                              'THE UPLOADED ID WAS NOT READABLE. PLEASE UPLOAD A CLEAR PHOTO AND SUBMIT AGAIN.',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 8),
                            ),
                          ),
                        ],
                        DropdownButtonFormField<String>(
                          initialValue: _idType,
                          dropdownColor: bgCol,
                          style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 13),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: ['Aadhaar Card', 'PAN Card', 'Voter ID', 'Driving License'].map((id) {
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(id.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _idType = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _idController,
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (value) {
                            final upper = value.toUpperCase();
                            if (upper != value) {
                              _idController.value = _idController.value.copyWith(
                                text: upper,
                                selection: TextSelection.collapsed(offset: upper.length),
                              );
                            }
                          },
                          style: TextStyle(color: textCol, fontSize: 13, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: 'ENTER ID NUMBER',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_idType == 'Aadhaar Card') ...[
                          _buildUploadCard(
                            title: 'Aadhaar Card Front Photo',
                            imageBase64: _idCardPhotoBase64,
                            onTap: () async {
                              final img = await _pickImageWithSource();
                              if (img != null) {
                                setState(() {
                                  _idCardPhotoBase64 = img;
                                });
                              }
                            },
                            onDelete: () {
                              setState(() {
                                _idCardPhotoBase64 = null;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildUploadCard(
                            title: 'Aadhaar Card Back Photo',
                            imageBase64: _idCardPhotoBackBase64,
                            onTap: () async {
                              final img = await _pickImageWithSource();
                              if (img != null) {
                                setState(() {
                                  _idCardPhotoBackBase64 = img;
                                });
                              }
                            },
                            onDelete: () {
                              setState(() {
                                _idCardPhotoBackBase64 = null;
                              });
                            },
                          ),
                        ] else ...[
                          _buildUploadCard(
                            title: '$_idType Front Photo',
                            imageBase64: _idCardPhotoBase64,
                            onTap: () async {
                              final img = await _pickImageWithSource();
                              if (img != null) {
                                setState(() {
                                  _idCardPhotoBase64 = img;
                                });
                              }
                            },
                            onDelete: () {
                              setState(() {
                                _idCardPhotoBase64 = null;
                              });
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: _isSubmittingId ? null : () => _submitVerification(uid),
                            child: BrutalistCard(
                              color: Colors.black,
                              shadowOffset: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: _isSubmittingId
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
                                        )
                                      : const Text('SUBMIT FOR REVIEW', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 11)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              })(),

              const SizedBox(height: 24),
              Text(
                AppLocalizations.translate('settings', locale),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textCol),
              ),
              const SizedBox(height: 12),
              BrutalistCard(
                color: bgCol,
                shadowOffset: 4.0,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSettingToggleRow(context, AppLocalizations.translate('push_notifications', locale), _pushNotifications, (val) {
                      setState(() => _pushNotifications = val);
                      _updateSettingInFirestore(uid, 'pushNotifications', val);
                    }),
                    Divider(color: borderCol, thickness: 1),
                    _buildSettingToggleRow(context, AppLocalizations.translate('dark_mode', locale), _darkMode, (val) {
                      setState(() => _darkMode = val);
                      _updateSettingInFirestore(uid, 'darkMode', val);
                      ref.read(themeModeProvider.notifier).setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                    }),
                    Divider(color: borderCol, thickness: 1),
                    // State / UT dropdown row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('STATE / UT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: textCol)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: borderCol, width: 2),
                              color: bgCol,
                            ),
                            child: DropdownButton<String>(
                              value: AppLocalizations.stateLanguages.containsKey(_state) ? _state : AppLocalizations.stateLanguages.keys.first,
                              underline: const SizedBox.shrink(),
                              dropdownColor: bgCol,
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: textCol),
                              items: AppLocalizations.stateLanguages.keys.map((s) {
                                return DropdownMenuItem(
                                  value: s,
                                  child: Text(s.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  final newState = val;
                                  final availableLangs = AppLocalizations.stateLanguages[newState] ?? ['English'];
                                  final defaultLang = availableLangs[0].toUpperCase();
                                  
                                  setState(() {
                                    _state = newState;
                                    _language = defaultLang;
                                  });
                                  
                                  _updateSettingInFirestore(uid, 'state', newState);
                                  _updateSettingInFirestore(uid, 'language', defaultLang);
                                  ref.read(localeProvider.notifier).setLocale(AppLocalizations.getFallbackLocale(defaultLang));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: borderCol, thickness: 1),
                    // Language dropdown row
                    (() {
                      final availableLangs = AppLocalizations.stateLanguages[_state] ?? ['English', 'Hindi'];
                      final normalizedLangs = availableLangs.map((l) => l.toUpperCase()).toList();
                      if (!normalizedLangs.contains('ENGLISH')) {
                        normalizedLangs.add('ENGLISH');
                      }
                      final currentLang = normalizedLangs.contains(_language.toUpperCase())
                          ? _language.toUpperCase()
                          : normalizedLangs.first;
                          
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppLocalizations.translate('language', locale), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: textCol)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: borderCol, width: 2),
                                color: bgCol,
                              ),
                              child: DropdownButton<String>(
                                value: currentLang,
                                underline: const SizedBox.shrink(),
                                dropdownColor: bgCol,
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: textCol),
                                items: normalizedLangs.map((lang) {
                                  return DropdownMenuItem(
                                    value: lang,
                                    child: Text(lang),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _language = val;
                                    });
                                    _updateSettingInFirestore(uid, 'language', val);
                                    ref.read(localeProvider.notifier).setLocale(AppLocalizations.getFallbackLocale(val));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    })(),
                    Divider(color: borderCol, thickness: 1),
                    _buildSettingToggleRow(context, AppLocalizations.translate('location_access', locale), _locationAccess, (val) {
                      setState(() => _locationAccess = val);
                      _updateSettingInFirestore(uid, 'locationAccess', val);
                    }),
                    Divider(color: borderCol, thickness: 1),
                    _buildSettingToggleRow(context, AppLocalizations.translate('privacy_mode', locale), _privacyMode, (val) {
                      setState(() => _privacyMode = val);
                      _updateSettingInFirestore(uid, 'privacyMode', val);
                    }),
                    Divider(color: borderCol, thickness: 1),
                    _buildSettingTapRow(context, AppLocalizations.translate('help_support', locale), onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const SupportCenterSheet(),
                      );
                    }),
                    Divider(color: borderCol, thickness: 1),
                    _buildSettingTapRow(context, AppLocalizations.translate('app_version', locale), trailing: 'V1.0.0', onTap: () {}),
                    Divider(color: borderCol, thickness: 1),
                    _buildSettingTapRow(context, AppLocalizations.translate('delete_account', locale), textColor: Colors.red, onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: bgCol,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(color: borderCol, width: 3.0),
                          ),
                          title: Text(AppLocalizations.translate('delete_account', locale), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.red)),
                          content: const Text(
                            'ARE YOU SURE YOU WANT TO PERMANENTLY DELETE YOUR ACCOUNT? THIS WILL WIPE ALL DATABASE ENTRIES. THIS ACTION IS IRREVERSIBLE.',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('CANCEL', style: TextStyle(color: textCol, fontWeight: FontWeight.bold)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx); // Close confirmation dialog
                                
                                // Show second dialog asking for registered email verification
                                final emailConfirmController = TextEditingController();
                                showDialog(
                                  context: context,
                                  builder: (ctx2) => AlertDialog(
                                    backgroundColor: bgCol,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                      side: BorderSide(color: borderCol, width: 3.0),
                                    ),
                                    title: Text('VERIFY EMAIL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: textCol)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'TO DESTRUCTIVELY DELETE YOUR ACCOUNT, PLEASE ENTER YOUR REGISTERED EMAIL ($email) BELOW:',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: textCol),
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: emailConfirmController,
                                          style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 13),
                                          decoration: const InputDecoration(
                                            hintText: 'ENTER REGISTERED EMAIL',
                                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx2),
                                        child: Text('CANCEL', style: TextStyle(color: textCol, fontWeight: FontWeight.bold)),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final enteredEmail = emailConfirmController.text.trim().toLowerCase();
                                          final actualEmail = email.toString().trim().toLowerCase();
                                          
                                          if (enteredEmail != actualEmail) {
                                            Navigator.pop(ctx2);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('EMAIL VERIFICATION FAILED. DELETION CANCELLED.'),
                                                backgroundColor: Colors.black,
                                              ),
                                            );
                                            return;
                                          }
                                          
                                          Navigator.pop(ctx2);
                                          try {
                                            if (uid != 'guest') {
                                              await FirebaseFirestore.instance.collection('users').doc(uid).delete();
                                            }
                                            await FirebaseAuth.instance.currentUser?.delete();
                                          } catch (_) {
                                            // Fallback signout
                                          }
                                          await FirebaseAuth.instance.signOut();
                                          ref.read(userProfileProvider.notifier).clearUser();
                                          ref.read(navigationProvider.notifier).resetTo(AppRoute.roleSelection);
                                        },
                                        child: const Text('CONFIRM DELETE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text('PROCEED', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    ref.read(userProfileProvider.notifier).clearUser();
                    ref.read(navigationProvider.notifier).resetTo(AppRoute.roleSelection);
                  },
                  child: BrutalistCard(
                    color: Colors.black,
                    shadowOffset: 3.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: Text(
                          AppLocalizations.translate('sign_out', locale),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.accent),
                        ),
                      ),
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

  Widget _buildProfileDetailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final mutedTextCol = isDark ? const Color(0xFFB0B0B0) : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: mutedTextCol)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: textCol),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerSearchResultsScreen extends StatelessWidget {
  const CustomerSearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SEARCH RESULTS'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textCol),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Text(
          'Search results are integrated into the Search tab.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
