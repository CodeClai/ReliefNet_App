import 'package:flutter/material.dart';
import '../services/campaign_service.dart';

class CampaignCreateScreen extends StatefulWidget {
  const CampaignCreateScreen({super.key});
  @override
  State<CampaignCreateScreen> createState() => _CampaignCreateScreenState();
}

class _CampaignCreateScreenState extends State<CampaignCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _target = TextEditingController();
  final _location = TextEditingController();
  String _category = 'food';
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await CampaignService().createCampaign({
        'title': _title.text,
        'description': _desc.text,
        'category': _category,
        'target_amount': double.parse(_target.text),
        'location': _location.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Campaign created')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Campaign')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _title, decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), validator: (v) => v!.isEmpty? 'Required' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _desc, decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), maxLines: 3, validator: (v) => v!.length < 10? 'Min 10 chars' : null),
            const SizedBox(height: 16),
            DropdownButtonFormField(value: _category, items: ['food','medical','shelter','education'].map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(), onChanged: (v) => setState(() => _category = v!), decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextFormField(controller: _target, decoration: InputDecoration(labelText: 'Target Amount (Rs)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty? 'Required' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _location, decoration: InputDecoration(labelText: 'Location', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 24),
            FilledButton(onPressed: _loading? null : _submit, style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)), child: _loading? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Campaign', style: TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
