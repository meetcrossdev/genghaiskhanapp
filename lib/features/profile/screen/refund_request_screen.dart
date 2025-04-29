import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gzresturent/features/home/controller/refund_controller.dart';
import 'package:uuid/uuid.dart';
import '../../../models/refund_request.dart';

class RefundRequestScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String paymentIntentId;
  final double maxAmount;
  final String userId;
  final String orderTrackid;

  const RefundRequestScreen({
    super.key,
    required this.orderId,
    required this.paymentIntentId,
    required this.maxAmount,
    required this.userId,
    required this.orderTrackid,
  });

  @override
  ConsumerState<RefundRequestScreen> createState() =>
      _RefundRequestScreenState();
}

class _RefundRequestScreenState extends ConsumerState<RefundRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  final _topicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.maxAmount.toString();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final refund = RefundRequest(
      id: const Uuid().v4(),
      userId: widget.userId,
      orderTrackid: widget.orderTrackid,
      orderId: widget.orderId,
      paymentIntentId: widget.paymentIntentId,
      amount: widget.maxAmount.toInt(), // convert to cents
      reason: _reasonController.text.trim(),
      status: 'pending',
      createdAt: DateTime.now(),
      topic: _topicController.text.trim(),
    );

    ref
        .read(refundControllerProvider.notifier)
        .submitRefundRequest(refund: refund, context: context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(refundControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Complaint")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _topicController,

                        decoration: const InputDecoration(
                          labelText: "Topic",
                          prefixIcon: Icon(Icons.message),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Enter a topic";
                          }
                        },
                      ),
                      SizedBox(height: 10.h), // TextFormField(
                      //   controller: _amountController,
                      //   keyboardType: const TextInputType.numberWithOptions(
                      //     decimal: true,
                      //   ),
                      //   decoration: const InputDecoration(
                      //     labelText: "Refund Amount",
                      //     prefixIcon: Icon(Icons.attach_money),
                      //     border: OutlineInputBorder(),
                      //   ),
                      //   validator: (val) {
                      //     if (val == null || val.isEmpty) {
                      //       return "Enter a valid amount";
                      //     }
                      //     final amount = double.tryParse(val);
                      //     if (amount == null || amount <= 0) {
                      //       return "Invalid amount";
                      //     }
                      //     if ((amount) > widget.maxAmount) {
                      //       return "Amount exceeds max refundable";
                      //     }
                      //     return null;
                      //   },
                      // ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Reason",
                          prefixIcon: Icon(Icons.message),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Enter a reason";
                          }
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.replay_circle_filled),
                          onPressed: isLoading ? null : _submit,
                          label:
                              isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text("Submit Complaint"),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16),
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
      ),
    );
  }
}
