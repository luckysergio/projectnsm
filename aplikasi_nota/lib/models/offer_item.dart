class OfferItem {
  final int? id;
  final int? offerId;

  String productName;
  String? quality;
  double qty; // Ubah dari int ke double
  String unit;
  double price;
  double subtotal;

  OfferItem({
    this.id,
    this.offerId,
    required this.productName,
    this.quality,
    required this.qty, // Sekarang tipe double
    required this.unit,
    required this.price,
    required this.subtotal,
  });

  // Copy method untuk pembaruan item
  OfferItem copyWith({
    int? id,
    int? offerId,
    String? productName,
    String? quality,
    double? qty,
    String? unit,
    double? price,
    double? subtotal,
  }) {
    return OfferItem(
      id: id ?? this.id,
      offerId: offerId ?? this.offerId,
      productName: productName ?? this.productName,
      quality: quality ?? this.quality,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      subtotal: subtotal ??
          (qty != null || price != null
              ? (qty ?? this.qty) * (price ?? this.price)
              : this.subtotal),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'offer_id': offerId,
      'product_name': productName,
      'quality': quality,
      'qty': qty,
      'unit': unit,
      'price': price,
      'subtotal': subtotal,
    };
  }

  factory OfferItem.fromMap(Map<String, dynamic> map) {
    return OfferItem(
      id: map['id'],
      offerId: map['offer_id'],
      productName: map['product_name'] ?? '',
      quality: map['quality'],
      qty: (map['qty'] as num?)?.toDouble() ?? 0.0, // Konversi ke double
      unit: map['unit'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'OfferItem(productName: $productName, qty: $qty, unit: $unit, price: $price, subtotal: $subtotal)';
  }
}
