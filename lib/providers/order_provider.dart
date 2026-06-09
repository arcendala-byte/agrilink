import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';

class OrderNotifier extends StateNotifier<List<Order>> {
  OrderNotifier() : super(Order.getSampleOrders());

  void addOrder(Order order) {
    state = [order, ...state];
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    state = state.map((order) {
      if (order.id == orderId) {
        return Order(
          id: order.id,
          orderNumber: order.orderNumber,
          items: order.items,
          subtotal: order.subtotal,
          deliveryFee: order.deliveryFee,
          total: order.total,
          status: newStatus,
          orderDate: order.orderDate,
          deliveryDate: newStatus == OrderStatus.delivered ? DateTime.now() : order.deliveryDate,
          deliveryAddress: order.deliveryAddress,
          farmerName: order.farmerName,
          customerName: order.customerName,
          trackingNumber: order.trackingNumber,
          notes: order.notes,
        );
      }
      return order;
    }).toList();
  }

  void cancelOrder(String orderId) {
    updateOrderStatus(orderId, OrderStatus.cancelled);
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  return OrderNotifier();
});

final activeOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(orderProvider).where((order) => 
    order.status != OrderStatus.delivered && 
    order.status != OrderStatus.cancelled
  ).toList();
});

final orderHistoryProvider = Provider<List<Order>>((ref) {
  return ref.watch(orderProvider).where((order) => 
    order.status == OrderStatus.delivered || 
    order.status == OrderStatus.cancelled
  ).toList();
});
