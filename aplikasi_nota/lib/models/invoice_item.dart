class InvoiceItem {
  String productName;
  double qty;
  String unit;
  double price;
  double subtotal;

  InvoiceItem({
    required this.productName,
    required this.qty,
    required this.unit,
    required this.price,
    double? subtotal, // Jadikan optional
  }) : subtotal = subtotal ?? _calculateSubtotal(qty, price);

  // Method untuk menghitung subtotal
  static double _calculateSubtotal(double qty, double price) {
    return (qty * price);
  }

  // Method untuk memformat angka desimal dengan aman
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        // Hapus karakter non-numerik kecuali titik desimal
        String cleaned = value.replaceAll(RegExp(r'[^\d.-]'), '');
        if (cleaned.isEmpty) return 0.0;
        return double.parse(cleaned);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  // Copy method untuk pembaruan item
  InvoiceItem copyWith({
    String? productName,
    double? qty,
    String? unit,
    double? price,
    double? subtotal,
  }) {
    return InvoiceItem(
      productName: productName ?? this.productName,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      subtotal:
          subtotal, // Biarkan null agar dihitung otomatis jika tidak diberikan
    );
  }

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
      qty: _parseDouble(map['qty']),
      unit: map['unit'] ?? '',
      price: _parseDouble(map['price']),
      subtotal: _parseDouble(map['subtotal']),
    );
  }

  @override
  String toString() {
    return 'InvoiceItem(productName: $productName, qty: $qty, unit: $unit, price: $price, subtotal: $subtotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InvoiceItem &&
        other.productName == productName &&
        other.qty == qty &&
        other.unit == unit &&
        other.price == price &&
        other.subtotal == subtotal;
  }

  @override
  int get hashCode {
    return Object.hash(productName, qty, unit, price, subtotal);
  }
}
