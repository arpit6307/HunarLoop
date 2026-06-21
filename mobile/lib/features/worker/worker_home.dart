import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/router.dart';
import '../auth/onboarding_screen.dart'; // import BrutalistCard
import '../../core/utils/support_center.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../core/utils/crop_dialog.dart';
import '../../core/utils/localization.dart';

class WorkerHomeScreen extends ConsumerStatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  ConsumerState<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends ConsumerState<WorkerHomeScreen> {
  int _selectedTab = 0;

  Future<void> _simulateBookingCreation(BuildContext context, WidgetRef ref) async {
    final uid = ref.read(userProfileProvider)?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final name = ref.read(userProfileProvider)?.name ?? 'Worker';
    
    // Fetch category and rate from worker's Firestore document
    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = docSnapshot.data() ?? {};
    final category = data['category'] ?? 'Plumber';
    final pricePerHour = data['pricePerHour'] ?? 350;
    final isOnline = data['isOnline'] as bool? ?? true;

    if (!isOnline) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('YOU ARE OFFLINE. SWITCH TO ONLINE STATUS TO RECEIVE NEW JOB REQUESTS.'),
            backgroundColor: Colors.black,
          ),
        );
      }
      return;
    }

    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    final pushNotifications = settings['pushNotifications'] as bool? ?? true;
    final autoAcceptJobs = settings['autoAcceptJobs'] as bool? ?? false;
    final availabilityRadiusStr = settings['availabilityRadius'] as String? ?? '10 KM';

    if (!pushNotifications) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PUSH NOTIFICATIONS ARE DISABLED. ENABLE THEM IN YOUR PROFILE SETTINGS TO RECEIVE NEW JOB REQUESTS.'),
            backgroundColor: Colors.black,
          ),
        );
      }
      return;
    }

    // Availability Radius Check
    final radiusLimit = double.tryParse(availabilityRadiusStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 10.0;
    const jobDistance = 12.0; // Simulated job distance is 12 KM
    
    if (jobDistance > radiusLimit) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('INCOMING JOB REQUEST IS OUTSIDE YOUR AVAILABILITY RADIUS (12 KM > ${radiusLimit.toInt()} KM). REQUEST BLOCKED.'),
            backgroundColor: Colors.black,
          ),
        );
      }
      return;
    }

    final bookingRef = FirebaseFirestore.instance.collection('bookings').doc('sim_booking_$uid');
    
    if (autoAcceptJobs) {
      await bookingRef.set({
        'bookingId': bookingRef.id,
        'customerId': 'sim_customer',
        'customerName': 'Arpit Singh Yadav',
        'workerId': uid,
        'workerName': name,
        'category': category,
        'slot': 'TOMORROW, 09:00 AM',
        'price': pricePerHour * 2,
        'status': 'ACCEPTED',
        'createdAt': FieldValue.serverTimestamp(),
        'description': 'Tap leak check in kitchen sink. Also review hot water pipe alignment.',
        'location': 'Hazratganj, Lucknow',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NEW JOB REQUEST AUTO-ACCEPTED VIA SETTINGS!'),
            backgroundColor: Colors.black,
          ),
        );
        ref.read(navigationProvider.notifier).navigateTo(
          AppRoute.workerJobDetails,
          arguments: {'bookingId': bookingRef.id},
        );
      }
      return;
    }

    await bookingRef.set({
      'bookingId': bookingRef.id,
      'customerId': 'sim_customer',
      'customerName': 'Arpit Singh Yadav',
      'workerId': uid,
      'workerName': name,
      'category': category,
      'slot': 'TOMORROW, 09:00 AM',
      'price': pricePerHour * 2,
      'status': 'PENDING',
      'createdAt': FieldValue.serverTimestamp(),
      'description': 'Tap leak check in kitchen sink. Also review hot water pipe alignment.',
      'location': 'Hazratganj, Lucknow',
    });

    if (context.mounted) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final bgCol = isDark ? const Color(0xFF1E1E1E) : Colors.white;
      final textCol = isDark ? Colors.white : Colors.black;
      final borderCol = isDark ? Colors.white : Colors.black;
      final mutedTextCol = isDark ? const Color(0xFFB0B0B0) : AppColors.textMuted;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: bgCol,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: borderCol, width: 3.0),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: textCol),
                const SizedBox(width: 8),
                Text(
                  'NEW REQUEST!',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textCol),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CUSTOMER: ARPIT SINGH YADAV',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: textCol),
                ),
                const SizedBox(height: 6),
                Text(
                  'SERVICE: ${category.toString().toUpperCase()}',
                  style: TextStyle(fontSize: 12, color: mutedTextCol, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'LOCATION: GOMTI NAGAR, HAZRATGANJ (12 KM AWAY)',
                  style: TextStyle(fontSize: 12, color: mutedTextCol, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'ESTIMATED PAYOUT: ₹${pricePerHour * 2} (2 HRS)',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: textCol),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    border: Border.all(color: borderCol, width: 2.0),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.timer_outlined, color: Colors.black, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'REQUEST EXPIRES IN 45S',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await bookingRef.delete();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('DECLINE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
              ),
              TextButton(
                onPressed: () async {
                  await bookingRef.update({'status': 'ACCEPTED'});
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.read(navigationProvider.notifier).navigateTo(
                      AppRoute.workerJobDetails,
                      arguments: {'bookingId': bookingRef.id},
                    );
                  }
                },
                child: Text('ACCEPT JOB', style: TextStyle(color: textCol, fontWeight: FontWeight.w900)),
              ),
            ],
          );
        },
      );
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
          'ALLOW HUNARLOOP TO ACCESS YOUR DEVICE LOCATION TO FIND JOBS NEAR YOU?',
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
                    content: Text('LOCATION ACCESS ALLOWED! AUTOMATICALLY SET ON IN SETTINGS.'),
                    backgroundColor: Colors.black,
                  ),
                );
              }
            },
            child: const Text('ALLOW', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final name = userProfile?.name.toUpperCase() ?? 'SUNIL KUMAR';
    final uid = userProfile?.uid ?? 'guest';
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final strokeCol = isDark ? Colors.white : Colors.black;
    final textCol = isDark ? Colors.white : Colors.black;
    final unselectedCol = isDark ? const Color(0xFFB0B0B0) : AppColors.textMuted;

    Widget activeView;
    switch (_selectedTab) {
      case 0:
        activeView = _buildDashboardTabView(context, name, uid, locale);
        break;
      case 1:
        activeView = const WorkerEarningsTabView();
        break;
      case 2:
        activeView = const WorkerProfileTabView();
        break;
      default:
        activeView = _buildDashboardTabView(context, name, uid, locale);
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
          currentIndex: _selectedTab,
          onTap: (index) {
            setState(() {
              _selectedTab = index;
            });
          },
          backgroundColor: bgCol,
          selectedItemColor: textCol,
          unselectedItemColor: unselectedCol,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: AppLocalizations.translate('home', locale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.payments_outlined),
              label: AppLocalizations.translate('earnings', locale),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded),
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

  Widget _buildDashboardTabView(BuildContext context, String name, String uid, String locale) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.hasData && userSnapshot.data!.exists
            ? userSnapshot.data!.data() as Map<String, dynamic>
            : {};
        final hunarScore = userData['hunarScore'] ?? 90;
        final isOnline = userData['isOnline'] as bool? ?? true;

        if (uid != 'guest' && userSnapshot.hasData && userSnapshot.data!.exists) {
          final settings = userData['settings'] as Map<String, dynamic>? ?? {};
          if (settings['locationAccess'] == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _promptLocationPermission(context, uid);
            });
          }
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where('workerId', isEqualTo: uid)
              .snapshots(),
          builder: (context, bookingsSnapshot) {
            int todayEarnings = 0;
            List<Map<String, dynamic>> upcomingBookings = [];

            if (bookingsSnapshot.hasData && bookingsSnapshot.data!.docs.isNotEmpty) {
              for (final doc in bookingsSnapshot.data!.docs) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['status'] == 'COMPLETED') {
                  final price = data['price'] ?? 0;
                  if (price is num) {
                    todayEarnings += price.toInt();
                  }
                } else if (data['status'] == 'PENDING' || data['status'] == 'ACCEPTED' || data['status'] == 'ARRIVED') {
                  upcomingBookings.add(data);
                }
              }
            }

            final screenW = MediaQuery.of(context).size.width;
            final isSmall = screenW < 380;

            return SingleChildScrollView(
              padding: EdgeInsets.all(isSmall ? 16.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row availability toggle & logout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            BrutalistCard(
                              color: Colors.white,
                              shadowOffset: 0,
                              child: Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                child: Icon(Icons.build_outlined, color: textCol, size: 20),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontWeight: FontWeight.w900, color: textCol, fontSize: 14),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: isOnline ? Colors.green : Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isOnline ? AppLocalizations.translate('online', locale) : AppLocalizations.translate('offline', locale),
                                        style: TextStyle(color: isOnline ? Colors.green : Colors.grey, fontSize: 9, fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Row(
                        children: [
                          Switch(
                            value: isOnline,
                            activeTrackColor: Colors.black,
                            activeThumbColor: Colors.white,
                            inactiveThumbColor: Colors.black,
                            inactiveTrackColor: Colors.white,
                            onChanged: (val) async {
                              if (uid != 'guest') {
                                await FirebaseFirestore.instance.collection('users').doc(uid).update({
                                  'isOnline': val,
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Stats dashboard widget
                  Text(AppLocalizations.translate('todays_performance', locale), style: TextStyle(fontSize: isSmall ? 14 : 16, fontWeight: FontWeight.w900, color: textCol)),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildDashboardStatCard(context, AppLocalizations.translate('earnings', locale), '₹$todayEarnings', Icons.payments_outlined, AppColors.highlightGreen, isSmall: isSmall),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDashboardStatCard(context, AppLocalizations.translate('hunar_score', locale), '$hunarScore/100', Icons.shield_outlined, AppColors.highlightBlue, isSmall: isSmall),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Simulated booking triggers
                  BrutalistCard(
                    color: Colors.white,
                    shadowOffset: 4.0,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.translate('simulate_booking', locale),
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.translate('simulate_desc', locale),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () => _simulateBookingCreation(context, ref),
                            child: BrutalistCard(
                              color: AppColors.accent,
                              shadowOffset: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Center(
                                  child: Text(AppLocalizations.translate('simulate_alert_btn', locale), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: textCol)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Scheduled calendar list
                  Text(AppLocalizations.translate('upcoming_schedule', locale), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textCol)),
                  const SizedBox(height: 12),
                  if (upcomingBookings.isEmpty)
                    BrutalistCard(
                      color: Colors.white,
                      shadowOffset: 3.0,
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          AppLocalizations.translate('no_upcoming_bookings', locale),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textMuted),
                        ),
                      ),
                    )
                  else
                    ...upcomingBookings.map((booking) {
                      final clientName = booking['customerName'] ?? 'CLIENT';
                      final category = booking['category'] ?? 'SERVICE';
                      final location = booking['location'] ?? 'Hazratganj, Lucknow';
                      final slot = booking['slot'] ?? 'Tomorrow';
                      final bId = booking['bookingId'] ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            if (bId.isNotEmpty) {
                              ref.read(navigationProvider.notifier).navigateTo(
                                AppRoute.workerJobDetails,
                                arguments: {'bookingId': bId},
                              );
                            }
                          },
                          child: _buildScheduleCard(context, slot.toString().toUpperCase(), clientName.toString().toUpperCase(), category.toString().toUpperCase(), location.toString().toUpperCase()),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDashboardStatCard(BuildContext context, String title, String value, IconData icon, Color color, {bool isSmall = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    return BrutalistCard(
      color: Colors.white,
      shadowOffset: 4.0,
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black, width: 2.0),
            ),
            child: Icon(icon, color: textCol, size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: isSmall ? 16 : 18, fontWeight: FontWeight.w900, color: textCol)),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(BuildContext context, String time, String client, String task, String loc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;
    return BrutalistCard(
      onTap: () {
        // Make schedule card click interactive
      },
      color: Colors.white,
      shadowOffset: 3.0,
      padding: EdgeInsets.all(isSmall ? 10 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: TextStyle(fontSize: isSmall ? 10 : 11, fontWeight: FontWeight.w900, color: textCol)),
                const SizedBox(height: 4),
                Text(client, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: isSmall ? 12 : 13, fontWeight: FontWeight.w900, color: textCol)),
                Text('$task • $loc', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: isSmall ? 9 : 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios_rounded, color: textCol, size: isSmall ? 12 : 14),
        ],
      ),
    );
  }
}

class WorkerEarningsTabView extends ConsumerWidget {
  const WorkerEarningsTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final uid = ref.watch(userProfileProvider)?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 380;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('workerId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        List<Map<String, dynamic>> completedBookings = [];
        int totalEarnings = 0;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['status'] == 'COMPLETED') {
              completedBookings.add(data);
              final price = data['price'] ?? 0;
              if (price is num) {
                totalEarnings += price.toInt();
              }
            }
          }
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR EARNINGS',
                style: TextStyle(fontSize: isSmall ? 18 : 22, fontWeight: FontWeight.w900, color: textCol),
              ),
              const SizedBox(height: 16),
              
              // Total Earnings Card
              BrutalistCard(
                color: AppColors.highlightGreen,
                shadowOffset: 4.0,
                padding: EdgeInsets.all(isSmall ? 16 : 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL OUTSTANDING & PAID',
                            style: TextStyle(fontSize: 10, color: textCol, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹$totalEarnings',
                            style: TextStyle(fontSize: isSmall ? 24 : 32, fontWeight: FontWeight.w900, color: textCol),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.white,
                      child: Icon(Icons.account_balance_wallet_outlined, size: 32, color: textCol),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'COMPLETED PAYOUTS LOG',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textCol),
              ),
              const SizedBox(height: 12),

              if (completedBookings.isEmpty) ...[
                const BrutalistCard(
                  color: Colors.white,
                  shadowOffset: 3.0,
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'NO PAYOUTS EARNED YET',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textMuted),
                    ),
                  ),
                ),
              ] else ...[
                ...completedBookings.map((b) {
                  final name = (b['customerName'] as String? ?? 'CLIENT').toUpperCase();
                  final category = (b['category'] as String? ?? b['description'] as String? ?? 'JOB').toUpperCase();
                  final slot = b['slot'] ?? 'RECENT';
                  final price = b['price'] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildPayoutRow(context, name, category, slot, price is num ? price.toInt() : 0),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPayoutRow(BuildContext context, String clientName, String service, String date, int amount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;
    return BrutalistCard(
      color: Colors.white,
      shadowOffset: 3.0,
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PAYOUT FROM $clientName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: isSmall ? 11 : 12, fontWeight: FontWeight.w900, color: textCol),
                ),
                const SizedBox(height: 4),
                Text(
                  '$service • $date'.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: isSmall ? 9 : 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹$amount',
                style: TextStyle(fontSize: isSmall ? 13 : 14, fontWeight: FontWeight.w900, color: textCol),
              ),
              Text(
                'ESCROW RELEASED',
                style: TextStyle(fontSize: isSmall ? 7 : 8, color: Colors.green, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkerProfileTabView extends ConsumerStatefulWidget {
  const WorkerProfileTabView({super.key});

  @override
  ConsumerState<WorkerProfileTabView> createState() => _WorkerProfileTabViewState();
}

class _WorkerProfileTabViewState extends ConsumerState<WorkerProfileTabView> {
  // Settings state
  bool _pushNotifications = true;
  bool _autoAcceptJobs = false;
  String _availabilityRadius = '10 KM';
  bool _showEarningsPublicly = false;
  bool _darkMode = false;
  String _language = 'ENGLISH';
  String _state = 'Uttar Pradesh';
  bool _locationAccess = true;
  bool _privacyMode = false;

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
    final uid = ref.read(userProfileProvider)?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? 'guest';
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
          _pushNotifications = settings['pushNotifications'] ?? true;
          _autoAcceptJobs = settings['autoAcceptJobs'] ?? false;
          _availabilityRadius = settings['availabilityRadius'] ?? '10 KM';
          _showEarningsPublicly = settings['showEarningsPublicly'] ?? false;
          _darkMode = settings['darkMode'] ?? false;
          _language = settings['language'] ?? 'ENGLISH';
          _state = settings['state'] ?? 'Uttar Pradesh';
          _locationAccess = settings['locationAccess'] ?? true;
          _privacyMode = settings['privacyMode'] ?? false;
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

  Future<void> _updateSetting(String uid, String key, dynamic value) async {
    if (uid == 'guest') {
      return;
    }
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'settings': {key: value},
    }, SetOptions(merge: true));
  }

  void _showEditProfileDialog(BuildContext context, String uid, Map<String, dynamic> currentData, UserProfile? profile, WidgetRef ref) {
    final categories = [
      'Plumber',
      'Home Tutor',
      'Mehendi Artist',
      'Cook/Chef',
      'Electrician',
      'Photographer',
      'Beautician',
      'Darzi / Tailor',
      'Pet Groomer',
      'Personal Trainer',
      'AC Technician'
    ];

    String selectedCategory = currentData['category'] ?? 'Plumber';
    if (!categories.contains(selectedCategory)) {
      selectedCategory = 'Plumber';
    }

    final rateController = TextEditingController(text: (currentData['pricePerHour'] ?? 350).toString());
    final expController = TextEditingController(text: currentData['experienceYears'] ?? '1 Year');
    final locController = TextEditingController(text: currentData['location'] ?? 'Hazratganj, Lucknow');
    final phoneController = TextEditingController(text: currentData['phone'] ?? profile?.phone ?? '');
    final skillsController = TextEditingController(text: List<String>.from(currentData['skills'] ?? []).join(', '));

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
                    const Text('SKILL CATEGORY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      dropdownColor: dialogBg,
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text('HOURLY RATE (₹)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: rateController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'E.G. 350',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('EXPERIENCE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: expController,
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'E.G. 3 YEARS',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('LOCATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: locController,
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'E.G. HAZRATGANJ, LUCKNOW',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('PHONE NUMBER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'E.G. 9876543210',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('SKILLS (COMMA SEPARATED)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: skillsController,
                      textCapitalization: TextCapitalization.words,
                      style: TextStyle(color: textCol, fontWeight: FontWeight.bold, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'E.G. PLUMBING, LEAK REPAIR, PIPE FITTING',
                      ),
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
                    final rate = int.tryParse(rateController.text.trim()) ?? 350;
                    final exp = expController.text.trim();
                    final loc = locController.text.trim();
                    final phoneVal = phoneController.text.trim();
                    final skillsInput = skillsController.text.trim();
                    final skillsList = skillsInput.split(',')
                        .map((s) => s.trim().toUpperCase())
                        .where((s) => s.isNotEmpty)
                        .toList();

                    if (exp.isEmpty || loc.isEmpty || phoneVal.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PLEASE FILL ALL FIELDS'), backgroundColor: Colors.black),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance.collection('users').doc(uid).update({
                      'category': selectedCategory,
                      'pricePerHour': rate,
                      'experienceYears': exp,
                      'location': loc,
                      'phone': phoneVal,
                      'skills': skillsList,
                    });

                    if (profile != null) {
                      ref.read(userProfileProvider.notifier).setUser(UserProfile(
                        uid: profile.uid,
                        name: profile.name,
                        email: profile.email,
                        phone: phoneVal,
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
                    Icon(Icons.add_a_photo_outlined, color: Colors.black, size: 32),
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
    final userProfile = ref.watch(userProfileProvider);
    final name = userProfile?.name.toUpperCase() ?? 'SUNIL KUMAR';
    final email = userProfile?.email ?? 'sunil@hunarloop.in';
    final phone = userProfile?.phone ?? '9876543210';
    final uid = userProfile?.uid ?? 'guest';
    final screenW = MediaQuery.of(context).size.width;
    final isSmall = screenW < 360;
    final avatarSize = isSmall ? 56.0 : 72.0;
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
        final category = data['category'] ?? 'Plumber';
        final location = data['location'] ?? 'Hazratganj, Lucknow';
        final price = data['pricePerHour'] ?? 350;
        final exp = data['experienceYears'] ?? '1 Year';
        final avatarUrl = data['avatarUrl'] as String?;



        return SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.translate('partner_profile', locale),
                style: TextStyle(fontSize: isSmall ? 18 : 22, fontWeight: FontWeight.w900, color: textCol),
              ),
              const SizedBox(height: 16),

              // LinkedIn-style Profile Header Card
              BrutalistCard(
                color: Colors.white,
                shadowOffset: 4.0,
                padding: EdgeInsets.zero, // Zero padding for full-bleed cover banner
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Cover Image Banner
                    GestureDetector(
                      onTap: () async {
                        final base64Image = await pickImageFromGallery();
                        if (base64Image == null) return;
                        if (!context.mounted) return;

                        final croppedBase64 = await showDialog<String>(
                          context: context,
                          builder: (context) => CropDialog(imageBase64: base64Image, isCover: true),
                        );

                        if (croppedBase64 != null && uid != 'guest') {
                          try {
                            final compressed = await compressBase64Image(croppedBase64, maxDim: 600, quality: 0.6);
                            if (compressed != null) {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .update({'coverImageUrl': compressed});
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('COVER BANNER UPDATED!'), backgroundColor: Colors.black),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('ERROR UPDATING COVER: ${e.toString().toUpperCase()}'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        }
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 130,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              image: data['coverImageUrl'] != null && (data['coverImageUrl'] as String).isNotEmpty
                                  ? DecorationImage(
                                      image: (data['coverImageUrl'] as String).startsWith('data:')
                                          ? MemoryImage(base64Decode((data['coverImageUrl'] as String).split(',').last)) as ImageProvider
                                          : NetworkImage(data['coverImageUrl'] as String),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: data['coverImageUrl'] == null || (data['coverImageUrl'] as String).isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined, color: AppColors.accent, size: 28),
                                        SizedBox(height: 4),
                                        Text('TAP TO ADD COVER IMAGE', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 8)),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                          // Camera Icon overlay for cover image at top-right
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                border: Border.all(color: Colors.black, width: 2.0),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          // 2. Profile Avatar DP overlapping the cover banner
                          Positioned(
                            left: 16,
                            bottom: -30,
                            child: GestureDetector(
                              onTap: () async {
                                final base64Image = await pickImageFromGallery();
                                if (base64Image == null) return;
                                if (!context.mounted) return;

                                final croppedBase64 = await showDialog<String>(
                                  context: context,
                                  builder: (context) => CropDialog(imageBase64: base64Image),
                                );

                                if (croppedBase64 != null && uid != 'guest') {
                                  try {
                                    final compressed = await compressBase64Image(croppedBase64, maxDim: 200, quality: 0.6);
                                    if (compressed != null) {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(uid)
                                          .update({'avatarUrl': compressed});
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('PROFILE PICTURE UPDATED!'), backgroundColor: Colors.black),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('ERROR UPDATING AVATAR: ${e.toString().toUpperCase()}'), backgroundColor: Colors.red),
                                      );
                                    }
                                  }
                                }
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  BrutalistCard(
                                    color: AppColors.highlightPink,
                                    shadowOffset: 4.0,
                                    child: SizedBox(
                                      width: avatarSize,
                                      height: avatarSize,
                                      child: avatarUrl != null && avatarUrl.isNotEmpty
                                          ? (avatarUrl.startsWith('data:')
                                              ? Image.memory(
                                                  base64Decode(avatarUrl.split(',').last),
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  avatarUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) => Icon(Icons.build_outlined, size: isSmall ? 24 : 32, color: Colors.black),
                                                ))
                                          : Icon(Icons.build_outlined, size: isSmall ? 24 : 32, color: Colors.black),
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
                                        border: Border.all(color: Colors.black, width: 2.0),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: isSmall ? 10 : 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. Spacer to clear the overlapping avatar
                    const SizedBox(height: 38),

                    // 4. Name, Verified Badge, Category — on the solid white card body
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: TextStyle(fontSize: isSmall ? 16 : 19, fontWeight: FontWeight.w900, color: Colors.black),
                                ),
                              ),
                              if (data['isVerified'] as bool? ?? false) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.verified_rounded, color: Colors.green, size: 20),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (data['isVerified'] as bool? ?? false)
                                ? 'VERIFIED ${category.toString().toUpperCase()} PARTNER'
                                : '${(data['verificationStatus'] ?? 'unverified').toString().toUpperCase()} ${category.toString().toUpperCase()} PARTNER',
                            style: TextStyle(fontSize: isSmall ? 9 : 10, color: AppColors.textMuted, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                child: BrutalistCard(
                  onTap: () => _showEditProfileDialog(context, uid, data, userProfile, ref),
                  color: AppColors.accent,
                  shadowOffset: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        AppLocalizations.translate('edit_profile', locale),
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: BrutalistCard(
                  onTap: () {
                    ref.read(navigationProvider.notifier).navigateTo(AppRoute.workerPortfolioEditor);
                  },
                  color: Colors.white,
                  shadowOffset: 3.0,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        'EDIT COVER & PORTFOLIO',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12),
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
                              color: Colors.green,
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
                                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 40),
                                const SizedBox(height: 8),
                                Text(
                                  'YOUR ID WAS VERIFIED SUCCESSFULLY!',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.green),
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
                AppLocalizations.translate('account_info', locale),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textCol),
              ),
              const SizedBox(height: 12),
              BrutalistCard(
                color: Colors.white,
                shadowOffset: 3.0,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow('Email Address', email),
                    Divider(color: borderCol, thickness: 1.5),
                    _buildInfoRow('Phone Number', phone),
                    Divider(color: borderCol, thickness: 1.5),
                    _buildInfoRow('Skill Category', category.toString().toUpperCase()),
                    Divider(color: borderCol, thickness: 1.5),
                    _buildInfoRow('Hourly Rate', '₹$price/HR'),
                    Divider(color: borderCol, thickness: 1.5),
                    _buildInfoRow('Experience', exp.toString().toUpperCase()),
                    Divider(color: borderCol, thickness: 1.5),
                    _buildInfoRow('Location', location.toString().toUpperCase()),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 24),

              // ─── SETTINGS SECTION ───
              Text(
                AppLocalizations.translate('settings', locale),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textCol),
              ),
              const SizedBox(height: 12),
              BrutalistCard(
                color: Colors.white,
                shadowOffset: 3.0,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Push Notifications
                    _buildSettingsToggle(
                      label: AppLocalizations.translate('push_notifications', locale),
                      value: _pushNotifications,
                      onChanged: (val) {
                        setState(() => _pushNotifications = val);
                        _updateSetting(uid, 'pushNotifications', val);
                      },
                    ),
                    Divider(color: borderCol, thickness: 1),

                    // Auto-Accept Jobs
                    _buildSettingsToggle(
                      label: AppLocalizations.translate('auto_accept_jobs', locale),
                      value: _autoAcceptJobs,
                      onChanged: (val) {
                        setState(() => _autoAcceptJobs = val);
                        _updateSetting(uid, 'autoAcceptJobs', val);
                      },
                    ),
                    Divider(color: borderCol, thickness: 1),

                    // Availability Radius
                    _buildSettingsDropdown(
                      label: AppLocalizations.translate('availability_radius', locale),
                      value: _availabilityRadius,
                      options: const ['5 KM', '10 KM', '25 KM', '50 KM'],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _availabilityRadius = val);
                          _updateSetting(uid, 'availabilityRadius', val);
                        }
                      },
                    ),
                    Divider(color: borderCol, thickness: 1),

                    // Show Earnings Publicly
                    _buildSettingsToggle(
                      label: AppLocalizations.translate('show_earnings_publicly', locale),
                      value: _showEarningsPublicly,
                      onChanged: (val) {
                        setState(() => _showEarningsPublicly = val);
                        _updateSetting(uid, 'showEarningsPublicly', val);
                      },
                    ),
                    Divider(color: borderCol, thickness: 1),

                    // Dark Mode
                    _buildSettingsToggle(
                      label: AppLocalizations.translate('dark_mode', locale),
                      value: _darkMode,
                      onChanged: (val) {
                        setState(() => _darkMode = val);
                        _updateSetting(uid, 'darkMode', val);
                        ref.read(themeModeProvider.notifier).setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                    Divider(color: borderCol, thickness: 1),

                    // State / UT
                    _buildSettingsDropdown(
                      label: 'STATE / UT',
                      value: AppLocalizations.stateLanguages.containsKey(_state) ? _state : AppLocalizations.stateLanguages.keys.first,
                      options: AppLocalizations.stateLanguages.keys.toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final newState = val;
                          final availableLangs = AppLocalizations.stateLanguages[newState] ?? ['English'];
                          final defaultLang = availableLangs[0].toUpperCase();
                          setState(() {
                            _state = newState;
                            _language = defaultLang;
                          });
                          _updateSetting(uid, 'state', newState);
                          _updateSetting(uid, 'language', defaultLang);
                          ref.read(localeProvider.notifier).setLocale(AppLocalizations.getFallbackLocale(defaultLang));
                        }
                      },
                    ),
                    Divider(color: borderCol, thickness: 1),

                    // Language
                    (() {
                      final availableLangs = AppLocalizations.stateLanguages[_state] ?? ['English', 'Hindi'];
                      final normalizedLangs = availableLangs.map((l) => l.toUpperCase()).toList();
                      if (!normalizedLangs.contains('ENGLISH')) {
                        normalizedLangs.add('ENGLISH');
                      }
                      final currentLang = normalizedLangs.contains(_language.toUpperCase())
                          ? _language.toUpperCase()
                          : normalizedLangs.first;
                          
                      return _buildSettingsDropdown(
                        label: AppLocalizations.translate('language', locale),
                        value: currentLang,
                        options: normalizedLangs,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _language = val;
                            });
                            _updateSetting(uid, 'language', val);
                            ref.read(localeProvider.notifier).setLocale(AppLocalizations.getFallbackLocale(val));
                          }
                        },
                      );
                    })(),
                    Divider(color: borderCol, thickness: 1),

                    // Location Access
                    _buildSettingsToggle(
                      label: AppLocalizations.translate('location_access', locale),
                      value: _locationAccess,
                      onChanged: (val) {
                        setState(() => _locationAccess = val);
                        _updateSetting(uid, 'locationAccess', val);
                      },
                    ),
                    Divider(color: borderCol, thickness: 1),

                    // Privacy Mode
                    _buildSettingsToggle(
                      label: AppLocalizations.translate('privacy_mode', locale),
                      value: _privacyMode,
                      onChanged: (val) {
                        setState(() => _privacyMode = val);
                        _updateSetting(uid, 'privacyMode', val);
                      },
                    ),
                    Divider(color: borderCol, thickness: 1),

                    // Help & Support
                    _buildSettingsTappableRow(
                      label: AppLocalizations.translate('help_support', locale),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const SupportCenterSheet(),
                        );
                      },
                    ),
                    Divider(color: borderCol, thickness: 1),

                    // App Version
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.translate('app_version', locale),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedTextCol),
                          ),
                          Text(
                            'V1.0.0',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: textCol),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: borderCol, thickness: 1),

                    // Delete Account
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: bgCol,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(color: borderCol, width: 3.0),
                            ),
                            title: Text(
                              AppLocalizations.translate('delete_account', locale),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.red),
                            ),
                            content: const Text(
                              'ARE YOU SURE YOU WANT TO PERMANENTLY DELETE YOUR ACCOUNT? THIS WILL WIPE ALL DATABASE ENTRIES. THIS ACTION IS IRREVERSIBLE.',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('CANCEL', style: TextStyle(color: textCol, fontWeight: FontWeight.bold)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
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
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.translate('delete_account', locale),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.red),
                            ),
                            const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: BrutalistCard(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    ref.read(userProfileProvider.notifier).clearUser();
                    ref.read(navigationProvider.notifier).resetTo(AppRoute.roleSelection);
                  },
                  color: Colors.black,
                  shadowOffset: 3.0,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'LOGOUT FROM ACCOUNT',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 13),
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

  Widget _buildSettingsToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textCol),
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: isDark ? Colors.white : Colors.black,
            activeThumbColor: isDark ? Colors.black : Colors.white,
            inactiveThumbColor: isDark ? Colors.white : Colors.black,
            inactiveTrackColor: isDark ? Colors.white12 : Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final borderCol = isDark ? Colors.white : Colors.black;
    final bgCol = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textCol),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: borderCol, width: 2),
              color: bgCol,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                dropdownColor: bgCol,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textCol),
                icon: Icon(Icons.arrow_drop_down, color: textCol, size: 18),
                isDense: true,
                items: options.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: Text(opt, style: TextStyle(color: textCol)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTappableRow({
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textCol),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: textCol, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final mutedCol = isDark ? const Color(0xFFB0B0B0) : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: mutedCol, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(color: textCol, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerJobDetailsScreen extends ConsumerWidget {
  const WorkerJobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final navState = ref.watch(navigationProvider);
    final args = navState.arguments as Map<String, dynamic>?;
    final bookingId = args?['bookingId'] as String? ?? '';

    if (bookingId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('JOB NAVIGATION')),
        body: const Center(child: Text('NO ACTIVE BOOKING ID FOUND')),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').doc(bookingId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('JOB NAVIGATION')),
            body: const Center(child: Text('ERROR LOADING JOB DETAILS')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('JOB NAVIGATION')),
            body: const Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }

        final bookingData = snapshot.data?.data() as Map<String, dynamic>?;
        if (bookingData == null || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('JOB NAVIGATION')),
            body: const Center(child: Text('BOOKING NOT FOUND OR CANCELLED')),
          );
        }

        final status = bookingData['status'] ?? 'PENDING';
        final desc = bookingData['description'] ?? '';
        final customerId = bookingData['customerId'] ?? '';

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(customerId).snapshots(),
          builder: (context, customerSnapshot) {
            final customerData = customerSnapshot.data?.data() as Map<String, dynamic>? ?? {};
            final clientSettings = customerData['settings'] as Map<String, dynamic>? ?? {};
            final clientPrivacyMode = clientSettings['privacyMode'] as bool? ?? false;

            final clientName = clientPrivacyMode 
                ? 'ANONYMOUS CLIENT' 
                : (bookingData['customerName'] ?? 'CLIENT');
            final location = clientPrivacyMode 
                ? 'CONFIDENTIAL (PRIVACY MODE)' 
                : (bookingData['location'] ?? 'Hazratganj, Lucknow');

            return Scaffold(
              appBar: AppBar(
                title: const Text('JOB NAVIGATION'),
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
                      // Client info card
                      BrutalistCard(
                        color: Colors.white,
                        shadowOffset: 4.0,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            BrutalistCard(
                              color: AppColors.highlightBlue,
                              shadowOffset: 0,
                              child: SizedBox(
                                width: 38,
                                height: 38,
                                child: Icon(Icons.person_outline_rounded, color: textCol, size: 20),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(clientName.toString().toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: textCol, fontSize: 14)),
                                      if ((customerData['isVerified'] as bool? ?? false) || (customerData['verificationStatus'] == 'approved')) ...[
                                        const SizedBox(width: 4),
                                        const Icon(Icons.verified, color: Colors.blue, size: 16),
                                      ],
                                    ],
                                  ),
                                  Text('CLIENT • ${location.toString().toUpperCase()}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Icon(Icons.chat_bubble_outline_rounded, color: textCol),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Job descriptions
                      Text('REQUESTED WORK', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textCol)),
                      const SizedBox(height: 8),
                      BrutalistCard(
                        color: Colors.white,
                        shadowOffset: 3.0,
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          desc.toString().toUpperCase(),
                          style: TextStyle(color: textCol, fontSize: 12, fontWeight: FontWeight.bold, height: 1.4),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Map placeholder
                      Expanded(
                        child: BrutalistCard(
                          color: Colors.white,
                          shadowOffset: 4.0,
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.map_outlined, color: textCol, size: 40),
                                    const SizedBox(height: 12),
                                    Text(
                                      status == 'ACCEPTED' 
                                          ? 'Routing map to $location...' 
                                          : status == 'ARRIVED' 
                                              ? 'Awaiting completion confirmation...'
                                              : 'Job completed successfully!',
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Navigation Status actions
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () async {
                            if (status == 'ACCEPTED' || status == 'PENDING') {
                              await FirebaseFirestore.instance
                                  .collection('bookings')
                                  .doc(bookingId)
                                  .update({'status': 'ARRIVED'});
                            } else if (status == 'ARRIVED') {
                              await FirebaseFirestore.instance
                                  .collection('bookings')
                                  .doc(bookingId)
                                  .update({'status': 'COMPLETED'});
                            } else {
                              ref.read(navigationProvider.notifier).resetTo(AppRoute.workerHome);
                            }
                          },
                          child: BrutalistCard(
                            color: Colors.black,
                            shadowOffset: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  status == 'ACCEPTED' || status == 'PENDING'
                                      ? 'MARK AS ARRIVED' 
                                      : status == 'ARRIVED' 
                                          ? 'MARK AS JOB COMPLETED'
                                          : 'EXIT TO DASHBOARD',
                                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 13),
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
      },
    );
  }
}
