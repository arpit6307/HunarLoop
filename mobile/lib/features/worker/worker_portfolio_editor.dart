import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/router/router.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../core/utils/crop_dialog.dart';
import '../../core/services/cloudinary_service.dart';
import '../auth/onboarding_screen.dart'; // import BrutalistCard
import '../customer/worker_profile.dart'; // import VideoPlayerOverlay

class WorkerPortfolioEditorScreen extends ConsumerStatefulWidget {
  const WorkerPortfolioEditorScreen({super.key});

  @override
  ConsumerState<WorkerPortfolioEditorScreen> createState() => _WorkerPortfolioEditorScreenState();
}

class _WorkerPortfolioEditorScreenState extends ConsumerState<WorkerPortfolioEditorScreen> {
  final TextEditingController _videoTitleController = TextEditingController();

  bool _isUploadingVideo = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _videoTitleController.dispose();
    super.dispose();
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
                'SELECT IMAGE SOURCE',
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

  Future<void> _updateCoverImage(String uid, String base64Str) async {
    if (uid == 'guest') return;
    try {
      // Compress to tiny JPEG first
      final compressed = await compressBase64Image(base64Str, maxDim: 600, quality: 0.6);
      if (compressed == null) return;

      // Try uploading to Cloudinary
      final cloudinaryUrl = await uploadImage(compressed);
      final finalUrl = cloudinaryUrl ?? compressed;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'coverImageUrl': finalUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('COVER IMAGE UPDATED SUCCESSFULLY!'), backgroundColor: Colors.black),
        );
      }
    } catch (e) {
      debugPrint('Error updating cover image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR UPDATING COVER: ${e.toString().toUpperCase()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateAvatar(String uid, String base64Str) async {
    if (uid == 'guest') return;
    try {
      // Compress to tiny JPEG first
      final compressed = await compressBase64Image(base64Str, maxDim: 200, quality: 0.6);
      if (compressed == null) return;

      // Try uploading to Cloudinary
      final cloudinaryUrl = await uploadImage(compressed);
      final finalUrl = cloudinaryUrl ?? compressed;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'avatarUrl': finalUrl,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PROFILE PICTURE UPDATED SUCCESSFULLY!'), backgroundColor: Colors.black),
        );
      }
    } catch (e) {
      debugPrint('Error updating avatar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR UPDATING AVATAR: ${e.toString().toUpperCase()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _simulateVideoUpload(String uid, List<Map<String, dynamic>> currentVideos, String fileName) async {
    final title = _videoTitleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE ENTER A VIDEO TITLE'), backgroundColor: Colors.black),
      );
      return;
    }

    setState(() {
      _isUploadingVideo = true;
      _uploadProgress = 0.1;
    });

    try {
      // 1. Upload to Cloudinary
      final cloudinaryUrl = await uploadVideo(fileName);
      
      setState(() {
        _uploadProgress = 0.8;
      });

      // Fallback if Cloudinary fails
      final finalUrl = cloudinaryUrl ?? fileName;

      final mockVideo = {
        'title': title.toUpperCase(),
        'url': finalUrl,
        'duration': '1:${(15 + currentVideos.length * 12) % 60}',
      };

      currentVideos.add(mockVideo);

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'portfolioVideos': currentVideos,
      });

      if (mounted) {
        setState(() {
          _isUploadingVideo = false;
          _uploadProgress = 1.0;
        });
        _videoTitleController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cloudinaryUrl != null 
                ? 'WORK VIDEO UPLOADED TO CLOUDINARY!' 
                : 'UPLOADED LOCALLY (CONFIGURE CLOUDINARY FOR PERMANENT SAVING)'), 
            backgroundColor: Colors.black,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingVideo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR: ${e.toString().toUpperCase()}'), backgroundColor: Colors.red),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final borderCol = isDark ? Colors.white : Colors.black;
    final bgCol = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final mutedTextCol = isDark ? const Color(0xFFB0B0B0) : AppColors.textMuted;
    
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final coverImageUrl = data['coverImageUrl'] as String?;
        final avatarUrl = data['avatarUrl'] as String?;
        
        // Auto-compress existing large images to clear up 1MB document limit
        if (uid != 'guest') {
          if (coverImageUrl != null && coverImageUrl.length > 50000) {
            scheduleMicrotask(() async {
              try {
                final compressed = await compressBase64Image(coverImageUrl, maxDim: 600, quality: 0.5);
                if (compressed != null && compressed.length < coverImageUrl.length) {
                  await FirebaseFirestore.instance.collection('users').doc(uid).update({'coverImageUrl': compressed});
                }
              } catch (_) {}
            });
          }
          if (avatarUrl != null && avatarUrl.length > 30000) {
            scheduleMicrotask(() async {
              try {
                final compressed = await compressBase64Image(avatarUrl, maxDim: 200, quality: 0.5);
                if (compressed != null && compressed.length < avatarUrl.length) {
                  await FirebaseFirestore.instance.collection('users').doc(uid).update({'avatarUrl': compressed});
                }
              } catch (_) {}
            });
          }
        }

        final name = data['name'] ?? 'Worker';
        final category = data['category'] ?? 'Plumber';
        final portfolioImages = List<String>.from(data['portfolioImages'] ?? []);
        final portfolioVideos = List<Map<String, dynamic>>.from(
          (data['portfolioVideos'] as List<dynamic>?)?.map((x) => Map<String, dynamic>.from(x)) ?? []
        );

        final screenW = MediaQuery.of(context).size.width;
        final isSmall = screenW < 360;

        return Scaffold(
          appBar: AppBar(
            title: const Text('PORTFOLIO & COVER EDITOR'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: textCol),
              onPressed: () {
                ref.read(navigationProvider.notifier).goBack();
              },
            ),
            actions: [
              if (uid != 'guest')
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    icon: const Icon(Icons.cleaning_services_rounded, color: Colors.red, size: 22),
                    tooltip: 'CLEAN BANNER & DP (FREE 1MB SPACE)',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(color: Colors.black, width: 3.0),
                          ),
                          title: const Text('FREE UP PROFILE SPACE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                          content: const Text(
                            'THIS WILL RESET YOUR COVER BANNER AND PROFILE PICTURE TO CLEAR UNCOMPRESSED SPACE (~1MB) SO YOU CAN UPLOAD NEW PORTFOLIO PHOTOS AND VIDEOS.',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('CANCEL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('FREE SPACE NOW', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        try {
                          await FirebaseFirestore.instance.collection('users').doc(uid).update({
                            'coverImageUrl': FieldValue.delete(),
                            'avatarUrl': FieldValue.delete(),
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('PROFILE SPACE CLEARED! UPLOAD COVERS & PORTFOLIO NOW.'), backgroundColor: Colors.black),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ERROR: ${e.toString().toUpperCase()}'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Cover Image & Avatar section
                  SizedBox(
                    height: 240,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Cover Image Banner
                        GestureDetector(
                          onTap: () async {
                            final img = await _pickImageWithSource();
                            if (img == null) return;
                            if (!context.mounted) return;
                            
                            final cropped = await showDialog<String>(
                              context: context,
                              builder: (ctx) => CropDialog(imageBase64: img, isCover: true),
                            );
                            if (cropped != null) {
                              await _updateCoverImage(uid, cropped);
                            }
                          },
                          child: Container(
                            height: 170,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border(bottom: BorderSide(color: borderCol, width: 3.0)),
                              image: coverImageUrl != null && coverImageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: coverImageUrl.startsWith('data:')
                                          ? MemoryImage(base64Decode(coverImageUrl.split(',').last)) as ImageProvider
                                          : NetworkImage(coverImageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: coverImageUrl == null || coverImageUrl.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_photo_alternate_outlined, color: AppColors.accent, size: 36),
                                        SizedBox(height: 6),
                                        Text('TAP TO ADD COVER IMAGE', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 10)),
                                      ],
                                    ),
                                  )
                                : Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        color: Colors.black,
                                        child: const Text('EDIT COVER', style: TextStyle(color: AppColors.accent, fontSize: 9, fontWeight: FontWeight.w900)),
                                      ),
                                    ),
                                  ),
                          ),
                        ),

                        // Avatar circular overlay
                        Positioned(
                          left: isSmall ? 16 : 24,
                          bottom: 10,
                          child: GestureDetector(
                            onTap: () async {
                              final img = await _pickImageWithSource();
                              if (img == null) return;
                              if (!context.mounted) return;
                              
                              final cropped = await showDialog<String>(
                                context: context,
                                builder: (ctx) => CropDialog(imageBase64: img),
                              );
                              if (cropped != null) {
                                await _updateAvatar(uid, cropped);
                              }
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                BrutalistCard(
                                  color: AppColors.highlightPink,
                                  shadowOffset: 4.0,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      image: avatarUrl != null && avatarUrl.isNotEmpty
                                          ? DecorationImage(
                                              image: avatarUrl.startsWith('data:')
                                                  ? MemoryImage(base64Decode(avatarUrl.split(',').last)) as ImageProvider
                                                  : NetworkImage(avatarUrl),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: avatarUrl == null || avatarUrl.isEmpty
                                        ? Icon(Icons.person, size: 36, color: textCol)
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: -4,
                                  right: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      border: Border.all(color: Colors.black, width: 2.0),
                                    ),
                                    child: const Icon(Icons.camera_alt_outlined, size: 12, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name.toString().toUpperCase(),
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textCol),
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
                          category.toString().toUpperCase(),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: mutedTextCol),
                        ),
                        const SizedBox(height: 28),

                        // 2. Photos Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('PORTFOLIO PHOTOS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textCol)),
                            Text('${portfolioImages.length} PHOTOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: mutedTextCol)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: portfolioImages.length + 1,
                          itemBuilder: (context, index) {
                            if (index == portfolioImages.length) {
                              // Add Button
                              return GestureDetector(
                                onTap: () async {
                                  final img = await _pickImageWithSource();
                                  if (img == null) return;
                                  if (!context.mounted) return;

                                  final cropped = await showDialog<String>(
                                    context: context,
                                    builder: (ctx) => CropDialog(imageBase64: img, isPortfolio: true),
                                  );

                                  if (cropped != null) {
                                    try {
                                      // Compress portfolio image (JPEG 0.6, maxDim 400)
                                      final compressed = await compressBase64Image(cropped, maxDim: 400, quality: 0.6);
                                      if (compressed != null) {
                                        // Try uploading to Cloudinary
                                        final cloudinaryUrl = await uploadImage(compressed);
                                        final finalUrl = cloudinaryUrl ?? compressed;

                                        portfolioImages.add(finalUrl);
                                        await FirebaseFirestore.instance.collection('users').doc(uid).update({
                                          'portfolioImages': portfolioImages,
                                        });
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('PORTFOLIO PHOTO ADDED SUCCESSFULLY!'), backgroundColor: Colors.black),
                                          );
                                        }
                                      }
                                                                    } catch (e) {
                                      debugPrint('Error adding portfolio photo: $e');
                                      if (context.mounted) {
                                        final isSizeError = e.toString().contains('exceeds the maximum allowed size') || 
                                                            e.toString().contains('exceeds the maximum allowed');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isSizeError
                                                  ? 'PROFILE SPACE FULL! TAP THE RED BROOM ICON AT THE TOP TO FREE UP SPACE.'
                                                  : 'ERROR ADDING PHOTO: ${e.toString().toUpperCase()}',
                                            ),
                                            backgroundColor: Colors.red,
                                            duration: const Duration(seconds: 6),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderCol, width: 2.0),
                                    color: isDark ? Colors.black26 : Colors.grey.shade100,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined, color: textCol, size: 20),
                                      const SizedBox(height: 4),
                                      const Text('ADD PHOTO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900)),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final imgBase64 = portfolioImages[index];
                            return Stack(
                              children: [
                                GestureDetector(
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
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () async {
                                      portfolioImages.removeAt(index);
                                      await FirebaseFirestore.instance.collection('users').doc(uid).update({
                                        'portfolioImages': portfolioImages,
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      color: Colors.red,
                                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // 3. Videos Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('PORTFOLIO VIDEOS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textCol)),
                            Text('${portfolioVideos.length} VIDEOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: mutedTextCol)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (portfolioVideos.isEmpty)
                          BrutalistCard(
                            color: bgCol,
                            shadowOffset: 3.0,
                            padding: const EdgeInsets.all(16),
                            child: const Center(
                              child: Text(
                                'NO WORK VIDEOS ADDED YET',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted),
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
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onTap: () => _playVideo(context, title, url),
                                  child: BrutalistCard(
                                    color: bgCol,
                                    shadowOffset: 2.0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent,
                                            border: Border.all(color: Colors.black, width: 1.5),
                                          ),
                                          child: const Icon(Icons.play_arrow, color: Colors.black, size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title.toString().toUpperCase(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: textCol),
                                              ),
                                              Text(
                                                'DURATION: $duration • ${url.startsWith("blob:") ? "LOCAL VIDEO FILE" : url}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 8, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                          onPressed: () async {
                                            portfolioVideos.removeAt(index);
                                            await FirebaseFirestore.instance.collection('users').doc(uid).update({
                                              'portfolioVideos': portfolioVideos,
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 24),

                        // Add Video form card
                        BrutalistCard(
                          color: bgCol,
                          shadowOffset: 3.0,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ADD NEW WORK VIDEO',
                                style: TextStyle(fontWeight: FontWeight.w900, color: textCol, fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _videoTitleController,
                                textCapitalization: TextCapitalization.characters,
                                style: TextStyle(color: textCol, fontSize: 13, fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                  hintText: 'ENTER VIDEO TITLE (E.G. BASIN LEAK REPAIR)',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                              const SizedBox(height: 16),

                              if (_isUploadingVideo) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 14,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black, width: 2.0),
                                          color: Colors.grey.shade100,
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: _uploadProgress,
                                          child: Container(
                                            color: AppColors.accent,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${(_uploadProgress * 100).toInt()}%',
                                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: textCol),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'COMPRESSING & UPLOADING HIGH-DEF WORK VIDEO...',
                                  style: TextStyle(fontSize: 8, color: Colors.blue, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 16),
                              ],

                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _isUploadingVideo
                                          ? null
                                          : () async {
                                              final title = _videoTitleController.text.trim();
                                              if (title.isEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('PLEASE ENTER A VIDEO TITLE FIRST'), backgroundColor: Colors.black),
                                                );
                                                return;
                                              }
                                              final fileName = await pickVideoFromGallery();
                                              if (fileName == null) return;
                                              if (!context.mounted) return;
                                              _simulateVideoUpload(uid, portfolioVideos, fileName);
                                            },
                                      child: BrutalistCard(
                                        color: Colors.black,
                                        shadowOffset: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          child: Center(
                                            child: Text(
                                              'CHOOSE VIDEO FROM GALLERY',
                                              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
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
