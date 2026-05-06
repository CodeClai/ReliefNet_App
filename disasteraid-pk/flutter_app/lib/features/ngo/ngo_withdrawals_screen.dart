import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class NgoWithdrawalsScreen extends StatefulWidget {
  const NgoWithdrawalsScreen({super.key});
  @override
  State<NgoWithdrawalsScreen> createState() => _NgoWithdrawalsScreenState();
}

class _NgoWithdrawalsScreenState extends State<NgoWithdrawalsScreen> {
  List _withdrawals = [];
  Map<String, dynamic>? _wallet;
  bool _loading = true;
  String? _error;
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _api.dio.get('/ngos/wallet'),
        _api.dio.get('/ngos/withdrawals'),
      ]);
      setState(() {
        _wallet = results[0].data['data'];
        _withdrawals = results[1].data['data'];
        _loading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data['error']?? 'Failed to load data';
        _loading = false;
      });
    }
  }

  Future<void> _showWithdrawDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _WithdrawDialog(balance: double.parse(_wallet?['balance'].toString()?? '0')),
    );
    if (result == true) _loadData();
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
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error!= null) return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_error!),
        const SizedBox(height: 16),
        FilledButton(onPressed: _loadData, child: const Text('Retry')),
      ],
    ));

    final balance = double.parse(_wallet?['balance'].toString()?? '0');

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('Available Balance', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('PKR ${balance.toInt()}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: balance >= 100? _showWithdrawDialog : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Request Withdrawal'),
                    style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  ),
                  if (balance < 100) Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Minimum withdrawal: 100 PKR', style: TextStyle(fontSize: 12, color: Colors.orange[700])),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Withdrawal History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_withdrawals.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No withdrawals yet'),
                ],
              ),
            ))
          else
           ..._withdrawals.map((w) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _statusColor(w['status']).withOpacity(0.1),
                  child: Icon(Icons.account_balance, color: _statusColor(w['status'])),
                ),
                title: Text('PKR ${double.parse(w['amount'].toString()).toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${w['bank_name']} - ${w['account_number']}'),
                    Text(w['created_at'].toString().split('T')[0], style: const TextStyle(fontSize: 12)),
                    if (w['status'] == 'REJECTED' && w['rejection_reason']!= null)
                      Text('Reason: ${w['rejection_reason']}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                ),
                trailing: Chip(
                  label: Text(w['status'], style: const TextStyle(fontSize: 11)),
                  backgroundColor: _statusColor(w['status']).withOpacity(0.1),
                  labelStyle: TextStyle(color: _statusColor(w['status'])),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            )),
        ],
      ),
    );
  }
}

class _WithdrawDialog extends StatefulWidget {
  final double balance;
  const _WithdrawDialog({required this.balance});

  @override
  State<_WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<_WithdrawDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _bankController = TextEditingController();
  final _titleController = TextEditingController();
  final _accountController = TextEditingController();
  final _ibanController = TextEditingController();
  bool _submitting = false;
  final _api = ApiClient();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      await _api.dio.post('/ngos/withdrawals', data: {
        'amount': double.parse(_amountController.text),
        'bank_name': _bankController.text.trim(),
        'account_title': _titleController.text.trim(),
        'account_number': _accountController.text.trim(),
        'iban': _ibanController.text.trim().toUpperCase(),
      });
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal request submitted'), backgroundColor: Colors.green),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error']?? 'Request failed';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request Withdrawal'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Available: PKR ${widget.balance.toInt()}', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount (PKR)', prefixText: 'PKR ', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final amt = double.tryParse(v);
                  if (amt == null || amt < 100) return 'Minimum 100 PKR';
                  if (amt > widget.balance) return 'Insufficient balance';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bankController,
                decoration: const InputDecoration(labelText: 'Bank Name', border: OutlineInputBorder()),
                validator: (v) => v!.trim().length < 3? 'Min 3 characters' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Account Title', border: OutlineInputBorder()),
                validator: (v) => v!.trim().length < 3? 'Min 3 characters' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _accountController,
                decoration: const InputDecoration(labelText: 'Account Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.trim().length < 8? 'Min 8 digits' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ibanController,
                decoration: const InputDecoration(labelText: 'IBAN (24 chars)', border: OutlineInputBorder()),
                textCapitalization: TextCapitalization.characters,
                maxLength: 24,
                validator: (v) => v!.trim().length!= 24? 'IBAN must be 24 characters' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _submitting? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submitting? null : _submit, child: _submitting? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit')),
      ],
    );
  }
}