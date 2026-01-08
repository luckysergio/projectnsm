class Invoice {
  final int? id;
  final String invoiceNumber;
  final String invoiceDate;

  final String customerName;
  final String? customerPhone;
  final String? customerAddress;

  final double subtotal;
  final double total;
  final String? notes;

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerName,
    this.customerPhone,
    this.customerAddress,
    required this.subtotal,
    required this.total,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'subtotal': subtotal,
      'total': total,
      'notes': notes,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      invoiceNumber: map['invoice_number'],
      invoiceDate: map['invoice_date'],
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      customerAddress: map['customer_address'],
      subtotal: (map['subtotal'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      notes: map['notes'],
    );
  }
}
