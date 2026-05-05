import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
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


      // final params = _filter == 'ALL'? {} : {'status': _filter};

      final params = (_filter == 'ALL'
    ? <String, dynamic>{}
    : {'status': _filter});


      final res = await _api.dio.get('/admin/withdrawals', queryParameters: params);
      setState(() { _withdrawals = res.data['data']; _loading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _processWithdrawal(int id, String action, double amount) async {
    String? ref;
    String? reason;

    if (action == 'APPROVED') {
      ref = await showDialog<String>(
        context: context,
        builder: (context) {
          final ctrl = TextEditingController();
          return AlertDialog(
            title: const Text('Approve Withdrawal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount: PKR ${amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                    labelText: 'Transaction Reference',
                    hintText: 'Bank transfer ID',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  if (ctrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reference required')));
                    return;
                  }
                  Navigator.pop(context, ctrl.text.trim());
                },
                child: const Text('Approve'),
              ),
            ],
          );
        },
      );
      if (ref == null) return;
    } else {
      reason = await showDialog<String>(
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
                child: const Text('Reject'),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          );
        },
      );
      if (reason == null) return;
    }

    try {
      await _api.dio.patch('/admin/withdrawals/$id', data: {
        'status': action,
        'transaction_ref': ref,
        'rejection_reason': reason,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Withdrawal $action'), backgroundColor: Colors.green),
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
      case 'APPROVED': return Colors.green;
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
            children: ['ALL', 'PENDING', 'APPROVED', 'REJECTED'].map((f) =>
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
                              child: Text(
                                'PKR',
                                style: TextStyle(color: _statusColor(w['status']), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              'PKR ${amount.toInt()} - ${w['org_name']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${w['bank_name']} | ${w['created_at']?.toString().split('T')[0]?? ''}'),
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
                                    if (w['iban']!= null) _detailRow('IBAN', w['iban']),
                                    if (w['transaction_ref']!= null)
                                      _detailRow('Transaction Ref', w['transaction_ref'], Colors.green),
                                    if (w['rejection_reason']!= null)
                                      _detailRow('Rejection Reason', w['rejection_reason'], Colors.red),
                                    if (w['processed_at']!= null)
                                      _detailRow('Processed At', w['processed_at'].toString().split('T')[0]),
                                    const SizedBox(height: 16),
                                    if (w['status'] == 'PENDING')
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _processWithdrawal(w['id'], 'REJECTED', amount),
                                              icon: const Icon(Icons.close),
                                              label: const Text('Reject'),
                                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: FilledButton.icon(
                                              onPressed: () => _processWithdrawal(w['id'], 'APPROVED', amount),
                                              icon: const Icon(Icons.check),
                                              label: const Text('Approve'),
                                            ),
                                          ),
                                        ],
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