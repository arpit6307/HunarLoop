import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/onboarding_screen.dart';
import '../theme/app_colors.dart';

class SupportCenterSheet extends ConsumerStatefulWidget {
  const SupportCenterSheet({super.key});

  @override
  ConsumerState<SupportCenterSheet> createState() => _SupportCenterSheetState();
}

class _SupportCenterSheetState extends ConsumerState<SupportCenterSheet> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket(UserProfile profile) async {
    final msg = _messageController.text.trim();
    if (msg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PLEASE ENTER YOUR MESSAGE FIRST'),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final ticketId = 'ticket_${DateTime.now().millisecondsSinceEpoch}_${profile.uid.substring(0, 4)}';
      await FirebaseFirestore.instance.collection('support_tickets').doc(ticketId).set({
        'ticketId': ticketId,
        'uid': profile.uid,
        'name': profile.name,
        'role': profile.role,
        'message': msg,
        'adminReply': '',
        'status': 'open',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SUPPORT TICKET SUBMITTED SUCCESSFULLY!'),
            backgroundColor: Colors.black,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ERROR SUBMITTING TICKET: ${e.toString().toUpperCase()}'),
            backgroundColor: Colors.black,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? Colors.white : Colors.black;
    final bgCol = isDark ? const Color(0xFF0E1116) : const Color(0xFFFFE600);
    final cardCol = isDark ? const Color(0xFF1D212C) : Colors.white;

    if (userProfile == null) {
      return Container(
        color: cardCol,
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Text(
            'PLEASE SIGN IN TO ACCESS HELP & SUPPORT',
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.red),
          ),
        ),
      );
    }

    return Container(
      color: bgCol,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HUNARLOOP SUPPORT DESK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textCol,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    border: Border.all(color: textCol, width: 2.0),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'File a support request or query below. Our administrative team will reply in real-time.',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // File ticket text input
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  maxLines: 2,
                  style: TextStyle(color: textCol, fontSize: 13, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    hintText: 'DESCRIBE YOUR ISSUE...',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _isSubmitting ? null : () => _submitTicket(userProfile),
                child: BrutalistCard(
                  color: Colors.black,
                  shadowOffset: 0,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
                          )
                        : const Text(
                            'SUBMIT',
                            style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 11),
                          ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Text(
            'TICKET HISTORY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textCol,
            ),
          ),
          const SizedBox(height: 10),

          // Support query list
          SizedBox(
            height: 220,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('support_tickets')
                  .where('uid', isEqualTo: userProfile.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('ERROR LOADING TICKETS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.black));
                }

                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'NO ACTIVE TICKETS. FILE ONE ABOVE!',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white30 : Colors.black38),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, idx) {
                    final data = docs[idx].data() as Map<String, dynamic>;
                    final msg = data['message'] ?? '';
                    final reply = data['adminReply'] ?? '';
                    final status = data['status'] ?? 'open';
                    final isResolved = status == 'resolved';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: BrutalistCard(
                        color: cardCol,
                        shadowOffset: 2.0,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isResolved ? 'RESOLVED' : 'OPEN TICKET',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: isResolved ? Colors.green : Colors.red,
                                  ),
                                ),
                                if (data['timestamp'] != null)
                                  Text(
                                    (data['timestamp'] as Timestamp).toDate().toString().substring(0, 16),
                                    style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Q: $msg',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textCol),
                            ),
                            if (reply.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                color: Colors.green.withAlpha(26),
                                child: Text(
                                  'Reply: $reply',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.green),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
