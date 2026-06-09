class CartItem {
  final String id;
  final String name;
  final String price;
  final String unit;
  final String farmerName;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.farmerName,
    this.quantity = 1,
  });

  double get totalPrice => double.parse(price) * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'unit': unit,
      'farmerName': farmerName,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      unit: json['unit'],
      farmerName: json['farmerName'],
      quantity: json['quantity'],
    );
  }
}
