class Donation {
  final int id;
  final double amount;
  final String status;
  final String campaignTitle;
  final String orgName;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? receiptUrl;
  final String? paymentMethod;
  final String? rejectionReason;

  Donation.fromJson(Map<String, dynamic> json)
      : id = json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        amount = double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
        status = json['status']?.toString() ?? 'PENDING',
        campaignTitle = json['campaign_title']?.toString() ?? 'Unknown Campaign',
        orgName = json['org_name']?.toString() ?? 'NGO',
        createdAt = json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        verifiedAt = json['verified_at'] != null
            ? DateTime.tryParse(json['verified_at'].toString())
            : null,
        receiptUrl = json['receipt_url']?.toString(),
        paymentMethod = json['payment_method']?.toString(),
        rejectionReason = json['rejection_reason']?.toString();
}