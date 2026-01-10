class Offer {
  final int? id;
  final String offerNumber;
  final String offerDate;
  final String subject;
  final String customerName;
  final String project;
  final String sales;
  final String salesPhone;
  final double subtotal;
  final double total;
  final String? notes;

  Offer({
    this.id,
    required this.offerNumber,
    required this.offerDate,
    required this.subject,
    required this.customerName,
    required this.project,
    required this.sales,
    required this.salesPhone,
    required this.subtotal,
    required this.total,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'offer_number': offerNumber,
      'offer_date': offerDate,
      'subject': subject,
      'customer_name': customerName,
      'project': project,
      'sales': sales,
      'sales_phone': salesPhone,
      'subtotal': subtotal,
      'total': total,
      'notes': notes,
    };
  }

  factory Offer.fromMap(Map<String, dynamic> map) {
    int? id;
    final rawId = map['id'];
    if (rawId != null) {
      if (rawId is int) {
        id = rawId;
      } else if (rawId is double) {
        id = rawId.toInt();
      } else if (rawId is String) {
        id = int.tryParse(rawId);
      }
    }

    return Offer(
      id: id,
      offerNumber: map['offer_number'] ?? '',
      offerDate: map['offer_date'] ?? '',
      subject: map['subject'] ?? '',
      customerName: map['customer_name'] ?? '',
      project: map['project'] ?? '',
      sales: map['sales'] ?? '',
      salesPhone: map['sales_phone'] ?? '',
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'],
    );
  }
}
