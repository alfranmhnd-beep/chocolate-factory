enum ItemType { cocoa, sugar, milk, mass, chocolate, package }

enum StationKind {
  rawStorage, grinder, mixer, heater, temperer, mold, cooler,
  packaging, warehouse, orderDesk
}

class Order {
  final int id;
  final String product;
  final int quantity;
  final int reward;
  final double expiresAt;
  int delivered = 0;
  Order({
    required this.id,
    required this.product,
    required this.quantity,
    required this.reward,
    required this.expiresAt,
  });
}

class ProductStack {
  final String product;
  int quantity;
  ProductStack(this.product, this.quantity);
}
