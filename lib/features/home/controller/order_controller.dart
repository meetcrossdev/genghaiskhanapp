import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/features/home/controller/cart_controller.dart';
import '../../../models/ordermodal.dart';
import '../repository/order_repository.dart';
import '../../../core/utility.dart';

final userOrdersProvider = StreamProvider.family<List<OrderModel>, String>((
  ref,
  userId,
) {
  final orderController = ref.watch(orderControllerProvider.notifier);
  return orderController.fetchUserOrders(userId);
});

final allOrdersProvider = StreamProvider((ref) {
  final orderController = ref.watch(orderControllerProvider.notifier);
  return orderController.fetchAllOrders();
});

final orderControllerProvider = StateNotifierProvider<OrderController, bool>(
  (ref) => OrderController(
    orderRepository: ref.watch(orderRepositoryProvider),
    ref: ref,
  ),
);

class OrderController extends StateNotifier<bool> {
  final OrderRepository _orderRepository;
  final Ref _ref;

  OrderController({required OrderRepository orderRepository, required Ref ref})
    : _orderRepository = orderRepository,
      _ref = ref,
      super(false);

  void placeOrder(OrderModel order, context) async {
    state = true;
    final res = await _orderRepository.placeOrder(order);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref
          .read(cartControllerProvider.notifier)
          .clearCart(
            context: context,
            userId: FirebaseAuth.instance.currentUser!.uid,
          );
      showOrderSuccessDialog(context);
    });
  }

  void updateOrderStatus(String orderId, String status, context) async {
    state = true;
    final res = await _orderRepository.updateOrderStatus(orderId, status);
    state = false;

    res.fold((l) => showSnackBar(context, l.message), (r) {});
  }

  Stream<List<OrderModel>> fetchUserOrders(String userId) {
    return _orderRepository.fetchUserOrders(userId).map((orders) {
      // Sort orders by createdAt descending (latest first)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  Stream<List<OrderModel>> fetchAllOrders() {
    return _orderRepository.fetchAllOrders().map((orders) {
      // Sort orders by createdAt descending (latest first)
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }
}
