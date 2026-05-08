import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api/api_client.dart';

class AdminWithdrawalsScreen extends StatefulWidget {
  const AdminWithdrawalsScreen({super.key});
  @override
  State<AdminWithdrawalsScreen> createState() => _AdminWithdrawalsScreenState();
}

class _AdminWithdrawalsScreenState extends State<AdminWithdrawalsScreen> {
  List _withdrawals = [];
  bool _loading = true;
  String _filter = 'PENDING';
  String? _error;
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadWithdrawals();
  }

  Future<void> _loadWithdrawals() async {
    setState(() { _loading = true; _error = null; });
    try {
      final params = _filter == 'ALL'? <String, dynamic>{} : {'status': _filter};
      final res = await _api.dio.get('/admin/withdrawals', queryParameters: params);
      setState(() { _withdrawals = res.data['data']; _loading = false; });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data['error']?? 'Failed to load withdrawals';
        _loading = false;
      });
    }
  }

  Future<void> _approveWithdrawal(int id) async {
    final notes = await showDialog<String>(
      context: context,
      builder: (context) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Approve Withdrawal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This will mark the request as approved. You still need to transfer money and mark COMPLETED.'),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  labelText: 'Admin Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Approve')),
          ],
        );
      },
    );
    if (notes == null) return;
    await _submitStatus(id, 'APPROVED', adminNotes: notes);
  }

  Future<void> _completeWithdrawal(int id, double amount) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img == null) return;

    final notesCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Withdrawal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Confirm you transferred PKR ${amount.toInt()} to the NGO bank account.'),
            const SizedBox(height: 16),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Transaction Ref / Notes',
                hintText: 'Bank transfer ID',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Complete')),
        ],
      ),
    );
    if (confirmed!= true) return;

    await _submitStatus(id, 'COMPLETED', adminNotes: notesCtrl.text.trim(), proofFile: img);
  }

  Future<void> _rejectWithdrawal(int id) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Reject Withdrawal'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Rejection Reason',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (ctrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reason required')));
                  return;
                }
                Navigator.pop(context, ctrl.text.trim());
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
    if (reason == null) return;
    await _submitStatus(id, 'REJECTED', rejectionReason: reason);
  }

  Future<void> _submitStatus(int id, String status, {String? adminNotes, String? rejectionReason, XFile? proofFile}) async {
    try {
      FormData formData;
      if (proofFile!= null) {
        formData = FormData.fromMap({
          'status': status,
          'admin_notes': adminNotes,
          'proof': await MultipartFile.fromFile(proofFile.path),
        });
      } else {
        formData = FormData.fromMap({
          'status': status,
          'admin_notes': adminNotes,
          'rejection_reason': rejectionReason,
        });
      }

      await _api.dio.patch('/admin/withdrawals/$id', data: formData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Withdrawal $status'), backgroundColor: Colors.green),
        );
        _loadWithdrawals();
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error']?? 'Failed to process';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green;
      case 'APPROVED': return Colors.blue;
      case 'REJECTED': return Colors.red;
      case 'PENDING': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: ['ALL', 'PENDING', 'APPROVED', 'COMPLETED', 'REJECTED'].map((f) =>
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f),
                  selected: _filter == f,
                  onSelected: (_) { setState(() => _filter = f); _loadWithdrawals(); },
                ),
              )
            ).toList(),
          ),
        ),
        Expanded(
          child: _loading
        ? const Center(child: CircularProgressIndicator())
            : _error!= null
        ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _loadWithdrawals, child: const Text('Retry')),
                    ],
                  ),
                )
            : _withdrawals.isEmpty
        ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No $_filter withdrawals', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                )
                : RefreshIndicator(
                    onRefresh: _loadWithdrawals,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _withdrawals.length,
                      itemBuilder: (context, i) {
                        final w = _withdrawals[i];
                        final amount = double.tryParse(w['amount']?.toString()?? '0')?? 0;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: _statusColor(w['status']).withOpacity(0.1),
                              child: Icon(Icons.account_balance_wallet, color: _statusColor(w['status']), size: 20),
                            ),
                            title: Text(
                              'PKR ${amount.toInt()} - ${w['org_name']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${w['bank_name']} | ${w['requested_at']?.toString().split('T')[0]?? ''}'), // FIXED
                            trailing: Chip(
                              label: Text(w['status'], style: const TextStyle(fontSize: 11)),
                              backgroundColor: _statusColor(w['status']).withOpacity(0.1),
                              labelStyle: TextStyle(color: _statusColor(w['status'])),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _detailRow('Account Title', w['account_title']),
                                    _detailRow('Account Number', w['account_number']),
                                    _detailRow('IBAN', w['iban']),
                                    _detailRow('Requester', w['requester_email']),
                                    if (w['admin_notes']!= null) _detailRow('Admin Notes', w['admin_notes'], Colors.blue),
                                    if (w['rejection_reason']!= null) _detailRow('Rejection Reason', w['rejection_reason'], Colors.red),
                                    if (w['transfer_proof_url']!= null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: TextButton.icon(
                                          onPressed: () async {
                                            final url = Uri.parse(w['transfer_proof_url']);
                                            if (await canLaunchUrl(url)) await launchUrl(url);
                                          },
                                          icon: const Icon(Icons.image, size: 16),
                                          label: const Text('View Transfer Proof'),
                                        ),
                                      ),
                                    if (w['processed_at']!= null) _detailRow('Processed At', w['processed_at'].toString().split('T')[0]),
                                    const SizedBox(height: 16),
                                    if (w['status'] == 'PENDING')
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _rejectWithdrawal(w['id']),
                                              icon: const Icon(Icons.close),
                                              label: const Text('Reject'),
                                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: FilledButton.icon(
                                              onPressed: () => _approveWithdrawal(w['id']),
                                              icon: const Icon(Icons.check),
                                              label: const Text('Approve'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (w['status'] == 'APPROVED')
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton.icon(
                                          onPressed: () => _completeWithdrawal(w['id'], amount),
                                          icon: const Icon(Icons.upload_file),
                                          label: const Text('Upload Proof & Complete'),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _detailRow(String label, String? value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value?? 'N/A', style: TextStyle(color: color))),
        ],
      ),
    );
  }
}