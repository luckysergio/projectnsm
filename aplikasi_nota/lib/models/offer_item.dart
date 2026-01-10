class OfferItem {
  final int? id;
  final int? offerId;

  String productName;
  String? quality;
  int qty;
  String unit;
  double price;
  double subtotal;

  OfferItem({
    this.id,
    this.offerId,
    required this.productName,
    this.quality,
    required this.qty,
    required this.unit,
    required this.price,
    required this.subtotal,
  });

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
      qty: map['qty'] ?? 0,
      unit: map['unit'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
    );
  }
}
