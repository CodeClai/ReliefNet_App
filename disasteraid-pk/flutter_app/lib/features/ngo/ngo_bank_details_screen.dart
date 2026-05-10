import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class NgoBankDetailsScreen extends StatefulWidget {
  const NgoBankDetailsScreen({super.key});
  @override
  State<NgoBankDetailsScreen> createState() => _NgoBankDetailsScreenState();
}

class _NgoBankDetailsScreenState extends State<NgoBankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankName = TextEditingController();
  final _accountTitle = TextEditingController();
  final _accountNumber = TextEditingController();
  final _iban = TextEditingController();
  bool _loading = false;
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadDetails(); // This calls the method
  }

  Future<void> _loadDetails() async {
    try {
      final res = await _api.dio.get('/ngos/me');
      final data = res.data; // Already unwrapped by ApiClient
      _bankName.text = data['bank_name']?? '';
      _accountTitle.text = data['bank_account_title']?? '';
      _accountNumber.text = data['bank_account_number']?? '';
      _iban.text = data['bank_iban']?? '';
      setState(() {});
    } catch (e) {
      // Silent fail, form stays empty
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _api.dio.put('/ngos/bank-details', data: {
        'bank_name': _bankName.text.trim(),
        'bank_account_title': _accountTitle.text.trim(),
        'bank_account_number': _accountNumber.text.trim(),
        'bank_iban': _iban.text.trim().toUpperCase(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bank details saved'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error']?? 'Save failed';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bank Details')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Donors will transfer to this account. Must match your NGO name.', 
              style: TextStyle(color: Colors.orange)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _bankName,
              decoration: const InputDecoration(labelText: 'Bank Name *', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountTitle,
              decoration: const InputDecoration(labelText: 'Account Title *', hintText: 'Must match NGO name', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _accountNumber,
              decoration: const InputDecoration(labelText: 'Account Number *', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _iban,
              decoration: const InputDecoration(labelText: 'IBAN *', hintText: 'PK36SCBL0000001123456702', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ||!v.startsWith('PK')? 'Valid IBAN required' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading? null : _save,
              child: _loading? const CircularProgressIndicator() : const Text('Save Bank Details'),
            ),
          ],
        ),
      ),
    );
  }
}