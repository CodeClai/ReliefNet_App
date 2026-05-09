class Withdrawal {
  final int id;
  final double amount;
  final String status;
  final String bankName;
  final String accountTitle;
  final String accountNumber;
  final String iban;
  final String? adminNotes;
  final String? rejectionReason;
  final String? transferProofUrl;
  final DateTime requestedAt;
  final DateTime? processedAt;

  Withdrawal.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        amount = double.parse(json['amount'].toString()),
        status = json['status'],
        bankName = json['bank_name'],
        accountTitle = json['account_title'],
        accountNumber = json['account_number'],
        iban = json['iban'],
        adminNotes = json['admin_notes'],
        rejectionReason = json['rejection_reason'],
        transferProofUrl = json['transfer_proof_url'],
        requestedAt = DateTime.parse(json['requested_at']),
        processedAt = json['processed_at'] != null? DateTime.parse(json['processed_at']) : null;
}