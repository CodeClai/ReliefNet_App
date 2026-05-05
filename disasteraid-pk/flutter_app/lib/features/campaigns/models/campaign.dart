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
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'],
      ngoId: json['ngo_id'],
      title: json['title'],
      description: json['description']?? '',
      category: json['category']?? 'general',
      targetAmount: double.parse(json['target_amount'].toString()),
      raisedAmount: double.parse(json['raised_amount'].toString()),
      imageUrl: json['image_url'],
      location: json['location'],
      status: json['status'],
      orgName: json['org_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
