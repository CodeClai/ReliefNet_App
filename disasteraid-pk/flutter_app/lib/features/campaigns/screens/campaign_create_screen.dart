import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/campaign_service.dart';

class CampaignCreateScreen extends ConsumerStatefulWidget {
  const CampaignCreateScreen({super.key});

  @override
  ConsumerState<CampaignCreateScreen> createState() => _CampaignCreateScreenState();
}

class _CampaignCreateScreenState extends ConsumerState<CampaignCreateScreen> {
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
      final service = ref.read(campaignServiceProvider);
      await service.createCampaign({
        'title': _title.text,
        'description': _desc.text,
        'category': _category,
        'target_amount': double.parse(_target.text),
        'location': _location.text,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _loading = false);
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
            TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v!.isEmpty? 'Required' : null),
            TextFormField(controller: _desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            DropdownButtonFormField(value: _category, items: ['food','medical','shelter','education'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _category = v!), decoration: const InputDecoration(labelText: 'Category')),
            TextFormField(controller: _target, decoration: const InputDecoration(labelText: 'Target Amount (Rs)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty? 'Required' : null),
            TextFormField(controller: _location, decoration: const InputDecoration(labelText: 'Location')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _loading? null : _submit, child: _loading? const CircularProgressIndicator() : const Text('Create')),
          ],
        ),
      ),
    );
  }
}
