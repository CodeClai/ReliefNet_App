import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';

class ManualDonateSheet extends StatefulWidget {
  final int campaignId;
  final String campaignTitle;
  const ManualDonateSheet({super.key, required this.campaignId, required this.campaignTitle});

  @override
  State<ManualDonateSheet> createState() => _ManualDonateSheetState();
}

class _ManualDonateSheetState extends State<ManualDonateSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  XFile? _proof;
  bool _loading = false;
  Map? _bankDetails;
  final _api = ApiClient();

  Future<void> _pickProof() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img!= null) setState(() => _proof = img);
  }

  Future<void> _submit() async {
    if (_amount.text.isEmpty || double.tryParse(_amount.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid amount')));
      return;
    }
    if (_proof == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload payment screenshot')));
      return;
    }

    setState(() => _loading = true);
    try {
      final formData = FormData.fromMap({
        'campaign_id': widget.campaignId,
        'amount': _amount.text,
        'donor_note': _note.text.trim(),
        'proof': await MultipartFile.fromFile(_proof!.path),
      });

      final res = await _api.dio.post('/donations/manual', data: formData);
      setState(() {
        _bankDetails = res.data['bank_details'];
        _loading = false;
      });
    } on DioException catch (e) {
      setState(() => _loading = false);
      final msg = e.response?.data['error']?? 'Donation failed';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bankDetails!= null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text('Transfer Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildRow('Bank', _bankDetails!['bank_name']),
                    _buildRow('Account Title', _bankDetails!['account_title']),
                    _buildRow('Account #', _bankDetails!['account_number']),
                    _buildRow('IBAN', _bankDetails!['iban']),
                    const Divider(),
                    _buildRow('Amount', 'PKR ${_bankDetails!['amount']}'),
                    _buildRow('Reference', _bankDetails!['reference'], copy: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('1. Transfer the exact amount\n2. Use the reference above\n3. Admin will verify in 24hrs', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Donate to ${widget.campaignTitle}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (PKR) *', prefixText: 'PKR ', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickProof,
              icon: Icon(_proof == null? Icons.upload : Icons.check),
              label: Text(_proof == null? 'Upload Payment Screenshot *' : 'Screenshot Selected'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading? null : _submit,
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: _loading? const CircularProgressIndicator() : const Text('Submit Donation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool copy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (copy)...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: () {
                    // Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
                  },
                  child: const Icon(Icons.copy, size: 16),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}