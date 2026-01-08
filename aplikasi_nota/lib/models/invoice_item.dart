class InvoiceItem {
  String productName;
  int qty;
  String unit;
  double price;
  double subtotal;

  InvoiceItem({
    required this.productName,
    required this.qty,
    required this.unit,
    required this.price,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'product_name': productName,
      'qty': qty,
      'unit': unit,
      'price': price,
      'subtotal': subtotal,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      productName: map['product_name'] ?? '',
      qty: map['qty'] ?? 0,
      unit: map['unit'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
    );
  }
}
