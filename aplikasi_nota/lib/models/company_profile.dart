class CompanyProfile {
  int? id;
  String name;
  String owner;
  String bankAccount;
  String address;
  String phone;
  String email;
  String socialMedia;
  String website;

  CompanyProfile({
    this.id,
    required this.name,
    required this.owner,
    this.bankAccount = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.socialMedia = '',
    this.website = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'owner': owner,
      'bank_account': bankAccount,
      'address': address,
      'phone': phone,
      'email': email,
      'social_media': socialMedia,
      'website': website,
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
      email: map['email'] as String? ?? '',
      socialMedia: map['social_media'] as String? ?? '',
      website: map['website'] as String? ?? '',
    );
  }
}
