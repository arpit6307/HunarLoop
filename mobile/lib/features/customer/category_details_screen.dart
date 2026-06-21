import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/router.dart';
import '../../core/models/worker.dart';
import '../../core/models/skills_data.dart';
import '../auth/onboarding_screen.dart'; // import BrutalistCard

class CategoryDetailsScreen extends ConsumerStatefulWidget {
  const CategoryDetailsScreen({super.key});

  @override
  ConsumerState<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends ConsumerState<CategoryDetailsScreen> {
  String? _selectedSkill;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final bgCol = isDark ? const Color(0xFF0E1116) : const Color(0xFFFFE600);
    final cardBg = isDark ? const Color(0xFF1D212C) : Colors.white;

    final navState = ref.watch(navigationProvider);
    final category = navState.arguments as CategoryInfo? ?? allCategories[0];

    return Scaffold(
      backgroundColor: bgCol,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textCol),
          onPressed: () {
            ref.read(navigationProvider.notifier).goBack();
          },
        ),
        title: Text(
          category.name.toUpperCase(),
          style: TextStyle(
            color: textCol,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Info Banner Card
              BrutalistCard(
                color: category.color,
                shadowOffset: 4.0,
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BrutalistCard(
                      color: Colors.white,
                      shadowOffset: 0,
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        child: Icon(category.icon, size: 28, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.description,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section 1: Choose a Skill
              Text(
                'BROWSE SKILLS IN THIS CATEGORY',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: textCol,
                ),
              ),
              const SizedBox(height: 12),

              // Grid of 20 skills
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: category.skills.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.7,
                ),
                itemBuilder: (context, index) {
                  final skill = category.skills[index];
                  final isSelected = _selectedSkill == skill.name;

                  return BrutalistCard(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSkill = null;
                        } else {
                          _selectedSkill = skill.name;
                        }
                      });
                    },
                    color: isSelected ? category.color : cardBg,
                    shadowOffset: isSelected ? 4.0 : 2.0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          skill.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.black : textCol,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          skill.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.black.withAlpha(180)
                                : (isDark ? const Color(0xFF8E95A5) : AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Section 2: Workers Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _selectedSkill == null
                          ? 'AVAILABLE PARTNERS'
                          : 'PARTNERS SPECIALIZED IN: ${_selectedSkill!.toUpperCase()}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: textCol,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_selectedSkill != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSkill = null;
                        });
                      },
                      child: Text(
                        'CLEAR FILTER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.accent : Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Fetch workers and filter
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'worker')
                    .where('category', isEqualTo: category.name)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('ERROR LOADING PARTNERS',
                        style: TextStyle(fontWeight: FontWeight.bold));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: textCol));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return _buildNoWorkersCard(context, category.name);
                  }

                  final List<Worker> allWorkersInCategory = [];
                  for (final doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final isOnline = data['isOnline'] as bool? ?? true;
                    final wSettings = data['settings'] as Map<String, dynamic>? ?? {};
                    final privacyMode = wSettings['privacyMode'] as bool? ?? false;
                    if (!isOnline || privacyMode) {
                      continue;
                    }

                    final catName = data['category'] ?? category.name;
                    allWorkersInCategory.add(Worker(
                      id: data['uid'] ?? doc.id,
                      name: data['name'] ?? 'Worker',
                      category: catName,
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
                      profileIcon: getCategoryIcon(catName),
                      avatarUrl: data['avatarUrl'] as String?,
                      isVerified: data['isVerified'] as bool? ?? false,
                    ));
                  }

                  if (allWorkersInCategory.isEmpty) {
                    return _buildNoWorkersCard(context, category.name);
                  }

                  // Apply filter based on selectedSkill
                  List<Worker> displayedWorkers = allWorkersInCategory;
                  bool isFallbackActive = false;

                  if (_selectedSkill != null) {
                    final filtered = allWorkersInCategory
                        .where((w) => w.skills.any((s) => s.toLowerCase() == _selectedSkill!.toLowerCase()))
                        .toList();
                    if (filtered.isNotEmpty) {
                      displayedWorkers = filtered;
                    } else {
                      isFallbackActive = true;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isFallbackActive) ...[
                        BrutalistCard(
                          color: AppColors.highlightPink,
                          shadowOffset: 3.0,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: Colors.black, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "NO WORKER SPECIALIZED IN '$_selectedSkill' ONLINE. BOOK ANY GENERAL '${category.name}' PARTNER BELOW AND SPECIFY THIS SKILL.",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      ...displayedWorkers.map((worker) => _buildWorkerCard(context, worker)),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoWorkersCard(BuildContext context, String categoryName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    return BrutalistCard(
      color: isDark ? const Color(0xFF1D212C) : Colors.white,
      shadowOffset: 3.0,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded, size: 40, color: textCol),
            const SizedBox(height: 12),
            Text(
              'NO ACTIVE PARTNERS IN $categoryName',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: textCol,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please check back later or select another category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerCard(BuildContext context, Worker worker) {
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
            arguments: {
              'worker': worker,
              'selectedSkill': _selectedSkill,
            },
          );
        },
        color: isDark ? const Color(0xFF1D212C) : Colors.white,
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
                            errorBuilder: (c, e, s) =>
                                Icon(worker.profileIcon, size: isSmall ? 18 : 24, color: textCol),
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
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // List matching skills
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: worker.skills.map((s) {
                      final isMatched = _selectedSkill != null && s.toLowerCase() == _selectedSkill!.toLowerCase();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isMatched
                              ? AppColors.accent
                              : (isDark ? const Color(0xFF2C3242) : const Color(0xFFF0F0F0)),
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
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
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '₹${worker.pricePerHour}/HR',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: textCol,
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
