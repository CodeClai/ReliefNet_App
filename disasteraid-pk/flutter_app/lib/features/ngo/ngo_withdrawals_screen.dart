import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api/api_client.dart';
import 'models/withdrawal.dart'; // ADD THIS

class NgoWithdrawalsScreen extends StatefulWidget {
  const NgoWithdrawalsScreen({super.key});
  @override
  State<NgoWithdrawalsScreen> createState() => _NgoWithdrawalsScreenState();
}

class _NgoWithdrawalsScreenState extends State<NgoWithdrawalsScreen> {
  List<Withdrawal> _withdrawals = []; // CHANGED: List<Withdrawal>
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
        _withdrawals = (results[1].data['data'] as List) // CHANGED: Use model
          .map((e) => Withdrawal.fromJson(e))
          .toList();
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
      case 'COMPLETED': return Colors.green;
      case 'APPROVED': return Colors.blue;
      case 'REJECTED': return Colors.red;
      case 'PENDING': return Colors.orange;
      default: return Colors.grey;
    }
  }

  void _showWithdrawalDetails(Withdrawal w) { // CHANGED: Withdrawal not Map
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Withdrawal Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDetailRow('Amount', 'PKR ${w.amount.toInt()}'), // CHANGED: w.amount
            _buildDetailRow('Status', w.status),
            _buildDetailRow('Bank', w.bankName),
            _buildDetailRow('Account Title', w.accountTitle),
            _buildDetailRow('Account #', w.accountNumber),
            _buildDetailRow('IBAN', w.iban),
            _buildDetailRow('Requested', w.requestedAt.toString().split(' ')[0]),
            if (w.processedAt!= null) _buildDetailRow('Processed', w.processedAt.toString().split(' ')[0]),
            if (w.adminNotes!= null)...[
              const SizedBox(height: 12),
              Text('Admin Notes:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
              const SizedBox(height: 4),
              Text(w.adminNotes!),
            ],
            if (w.rejectionReason!= null)...[
              const SizedBox(height: 12),
              Text('Rejection Reason:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red[700])),
              const SizedBox(height: 4),
              Text(w.rejectionReason!),
            ],
            if (w.transferProofUrl!= null)...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(w.transferProofUrl!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('View Transfer Proof'),
                ),
              ),
            ],
            SizedBox(height: MediaQuery.of(ctx).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.end)),
        ],
      ),
    );
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
                onTap: () => _showWithdrawalDetails(w),
                leading: CircleAvatar(
                  backgroundColor: _statusColor(w.status).withOpacity(0.1),
                  child: Icon(Icons.account_balance, color: _statusColor(w.status)),
                ),
                title: Text('PKR ${w.amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)), // CHANGED
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${w.bankName} - ${w.accountNumber}'), // CHANGED
                    Text(w.requestedAt.toString().split(' ')[0], style: const TextStyle(fontSize: 12)), // CHANGED
                    if (w.status == 'REJECTED' && w.rejectionReason!= null)
                      Text('Reason: ${w.rejectionReason}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                    if (w.status == 'APPROVED')
                      Text('Awaiting transfer', style: TextStyle(color: Colors.blue[700], fontSize: 12)),
                  ],
                ),
                trailing: Chip(
                  label: Text(w.status, style: const TextStyle(fontSize: 11)),
                  backgroundColor: _statusColor(w.status).withOpacity(0.1),
                  labelStyle: TextStyle(color: _statusColor(w.status)),
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
  bool _loadingBank = true; // ADD THIS
  final _api = ApiClient();

  @override
  void initState() { // ADD THIS
    super.initState();
    _loadBankDetails();
  }

  Future<void> _loadBankDetails() async { // ADD THIS
    try {
      final res = await _api.dio.get('/ngos/profile');
      final profile = res.data['data'];
      setState(() {
        _bankController.text = profile['bank_name']?? '';
        _titleController.text = profile['bank_account_title']?? '';
        _accountController.text = profile['bank_account_number']?? '';
        _ibanController.text = profile['bank_iban']?? '';
        _loadingBank = false;
      });
    } catch (e) {
      setState(() => _loadingBank = false);
    }
  }

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
      content: _loadingBank // CHANGED: Show loader while fetching bank details
        ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
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
                      validator: (v) {
                        if (v!.trim().length!= 24) return 'IBAN must be 24 characters';
                        if (!v.startsWith('PK')) return 'IBAN must start with PK';
                        return null;
                      },
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