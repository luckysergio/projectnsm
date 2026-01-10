class Offer {
  final int? id;
  final String offerNumber;
  final String offerDate;
  final String subject;
  final String customerName;
  final String project;
  final String sales; // ← TAMBAHKAN INI
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
    required this.sales, // ← wajib di constructor
    required this.subtotal,
    required this.total,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'offer_number': offerNumber,
        'offer_date': offerDate,
        'subject': subject,
        'customer_name': customerName,
        'project': project,
        'sales': sales,
        'subtotal': subtotal,
        'total': total,
        'notes': notes,
      };

  factory Offer.fromMap(Map<String, dynamic> map) => Offer(
        id: map['id'],
        offerNumber: map['offer_number'],
        offerDate: map['offer_date'],
        subject: map['subject'],
        customerName: map['customer_name'],
        project: map['project'],
        sales: map['sales'] ?? '',
        subtotal: map['subtotal'],
        total: map['total'],
        notes: map['notes'],
      );
}
