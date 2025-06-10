import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gzresturent/features/home/controller/cart_controller.dart';
import '../../../models/ordermodal.dart';
import '../repository/order_repository.dart';
import '../../../core/utility.dart';
// Provides a real-time stream of orders for a specific user based on their userId.
// Uses `family` to allow passing dynamic userId as a parameter.
final userOrdersProvider = StreamProvider.family<List<OrderModel>, String>((
  ref,
  userId,
) {
  final orderController = ref.watch(orderControllerProvider.notifier); // Watch the order controller
  return orderController.fetchUserOrders(userId); // Fetch user's orders from the controller
});

// Provides a real-time stream of all orders (admin/global view).
final allOrdersProvider = StreamProvider((ref) {
  final orderController = ref.watch(orderControllerProvider.notifier); // Watch the order controller
  return orderController.fetchAllOrders(); // Fetch all orders
});

// Provider for the OrderController, which handles order-related logic and loading state.
final orderControllerProvider = StateNotifierProvider<OrderController, bool>(
  (ref) => OrderController(
    orderRepository: ref.watch(orderRepositoryProvider), // Inject order repository
    ref: ref,
  ),
);

// OrderController manages placing, updating, and fetching orders.
// Extends StateNotifier<bool> to manage loading state.
class OrderController extends StateNotifier<bool> {
  final OrderRepository _orderRepository; // Handles database operations
  final Ref _ref; // Used to interact with other providers (e.g., cart)

  // Constructor initializing the repository and reference to providers.
  OrderController({required OrderRepository orderRepository, required Ref ref})
    : _orderRepository = orderRepository,
      _ref = ref,
      super(false); // Initial loading state is false

  // Places a new order and clears the user's cart after successful order placement.
  void placeOrder(OrderModel order, context) async {
    state = true; // Start loading
    final res = await _orderRepository.placeOrder(order); // Try placing the order
    state = false; // End loading

    // Handle result: show error or success and clear cart
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref
          .read(cartControllerProvider.notifier) // Get the cart controller
          .clearCart(
            context: context,
            userId: FirebaseAuth.instance.currentUser!.uid, // Clear cart for current user
          );
      showOrderSuccessDialog(context); // Show success confirmation dialog
    });
  }

  // Updates the status of a specific order (e.g., to "delivered", "cancelled").
  void updateOrderStatus(String orderId, String status, context) async {
    state = true; // Start loading
    final res = await _orderRepository.updateOrderStatus(orderId, status); // Update in DB
    state = false; // End loading

    res.fold((l) => showSnackBar(context, l.message), (r) {}); // Show error if any
  }

  // Fetches all orders placed by a specific user, sorted by latest first.
  Stream<List<OrderModel>> fetchUserOrders(String userId) {
    return _orderRepository.fetchUserOrders(userId).map((orders) {
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort descending
      return orders;
    });
  }

  // Fetches all orders in the system (admin view), sorted by latest first.
  Stream<List<OrderModel>> fetchAllOrders() {
    return _orderRepository.fetchAllOrders().map((orders) {
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort descending
      return orders;
    });
  }
}
