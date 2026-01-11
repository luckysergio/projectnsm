class CompanyProfile {
  int? id;
  String name;
  String owner;
  String bankAccount;
  String address;
  String phone;

  CompanyProfile({
    this.id,
    required this.name,
    required this.owner,
    this.bankAccount = '',
    this.address = '',
    this.phone = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'owner': owner,
      'bank_account': bankAccount,
      'address': address,
      'phone': phone,
    };
  }

  factory CompanyProfile.fromMap(Map<String, dynamic> map) {
    return CompanyProfile(
      id: map['id'] as int?,
      name: map['name'] as String,
      owner: map['owner'] as String,
      bankAccount: map['bank_account'] as String? ?? '',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
    );
  }
}
