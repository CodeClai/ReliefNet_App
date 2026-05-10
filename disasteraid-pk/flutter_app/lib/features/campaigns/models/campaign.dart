class Campaign {
  final int id;
  final int ngoId;
  final String title;
  final String description;
  final String category;
  final double targetAmount;
  final double raisedAmount;
  final String? imageUrl;
  final String? location;
  final String status;
  final String? orgName;
  final DateTime createdAt;
  final DateTime? endDate;
  
  // CHANGED: Platform bank details instead of NGO bank
  final String? platformBankName;
  final String? platformAccountTitle;
  final String? platformAccountNumber;
  final String? platformIban;

  Campaign({
    required this.id,
    required this.ngoId,
    required this.title,
    required this.description,
    required this.category,
    required this.targetAmount,
    required this.raisedAmount,
    this.imageUrl,
    this.location,
    required this.status,
    this.orgName,
    required this.createdAt,
    this.endDate,
    this.platformBankName,
    this.platformAccountTitle,
    this.platformAccountNumber,
    this.platformIban,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] is int? json['id'] : int.parse(json['id'].toString()),
      ngoId: json['ngo_id'] is int? json['ngo_id'] : int.parse(json['ngo_id'].toString()),
      title: json['title']?? '',
      description: json['description']?? '',
      category: json['category']?? 'general',
      targetAmount: double.tryParse(json['target_amount']?.toString()?? '0')?? 0.0,
      raisedAmount: double.tryParse(json['raised_amount']?.toString()?? '0')?? 0.0,
      imageUrl: json['image_url'],
      location: json['location'],
      status: json['status']?? 'ACTIVE',
      orgName: json['org_name'],
      createdAt: DateTime.parse(json['created_at']),
      endDate: json['end_date']!= null? DateTime.parse(json['end_date']) : null,
      // CHANGED
      platformBankName: json['platform_bank_name'],
      platformAccountTitle: json['platform_account_title'],
      platformAccountNumber: json['platform_account_number'],
      platformIban: json['platform_iban'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ngo_id': ngoId,
      'title': title,
      'description': description,
      'category': category,
      'target_amount': targetAmount,
      'raised_amount': raisedAmount,
      'image_url': imageUrl,
      'location': location,
      'status': status,
      'org_name': orgName,
      'created_at': createdAt.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'platform_bank_name': platformBankName,
      'platform_account_title': platformAccountTitle,
      'platform_account_number': platformAccountNumber,
      'platform_iban': platformIban,
    };
  }

  double get progress => targetAmount > 0? (raisedAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  int get percentRaised => (progress * 100).toInt();

  int? get daysLeft {
    if (endDate == null) return null;
    final diff = endDate!.difference(DateTime.now()).inDays;
    return diff < 0? 0 : diff;
  }
}