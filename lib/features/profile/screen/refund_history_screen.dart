import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/features/home/controller/refund_controller.dart';
import 'package:intl/intl.dart';

import '../../../models/refund_request.dart';

class RefundHistoryScreen extends ConsumerWidget {
  final String userId;

  const RefundHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refundStream = ref.watch(userRefundsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text("My Refund Requests")),
      body: refundStream.when(
        data: (refunds) {
          if (refunds.isEmpty) {
            return const Center(
              child: Text(
                "No refund requests found.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: refunds.length,
            itemBuilder: (context, index) {
              final refund = refunds[index];
              return _RefundCard(refund: refund);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _RefundCard extends StatefulWidget {
  final RefundRequest refund;

  const _RefundCard({required this.refund});

  @override
  State<_RefundCard> createState() => _RefundCardState();
}

class _RefundCardState extends State<_RefundCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAdminMessage(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Admin Message"),
            content: Text(widget.refund.adminMessage ?? 'no message data'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final refund = widget.refund;
    final theme = Theme.of(context);
    final dateFormatted = DateFormat.yMMMd().format(refund.createdAt);
    final amountFormatted = (refund.amount / 100).toStringAsFixed(2);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Track ID: ${refund.orderTrackid}",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.text_fields_outlined, size: 20),
                const SizedBox(width: 6),
                Text(" ${refund.topic}", style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 6),
            if (refund.reason.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.message_outlined, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      refund.reason,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Chip(
                  label: Text(refund.status.toUpperCase()),
                  backgroundColor: _getStatusColor(refund.status, context),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                const Spacer(),

                refund.adminMessage != null
                    ? ScaleTransition(
                      scale: _scaleAnimation,
                      child: IconButton(
                        icon: const Icon(
                          Icons.mark_chat_unread_rounded,
                          color: Colors.blue,
                        ),
                        tooltip: 'Admin Message',
                        onPressed: () => _showAdminMessage(context),
                      ),
                    )
                    : Container(),
                const SizedBox(width: 8),
                Text(
                  dateFormatted,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, BuildContext context) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
