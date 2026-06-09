import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
    final existingIndex = state.indexWhere((i) => i.id == item.id);
    if (existingIndex >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            CartItem(
              id: state[i].id,
              name: state[i].name,
              price: state[i].price,
              unit: state[i].unit,
              farmerName: state[i].farmerName,
              quantity: state[i].quantity + 1,
            )
          else
            state[i],
      ];
    } else {
      state = [...state, item];
    }
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void updateQuantity(String id, int quantity) {
    state = [
      for (final item in state)
        if (item.id == id)
          CartItem(
            id: item.id,
            name: item.name,
            price: item.price,
            unit: item.unit,
            farmerName: item.farmerName,
            quantity: quantity,
          )
        else
          item,
    ];
  }

  void clearCart() {
    state = [];
  }

  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => state.fold(0, (sum, item) => sum + item.totalPrice);
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

final cartTotalItemsProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity);
});

final cartTotalAmountProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold(0, (sum, item) => sum + item.totalPrice);
});
