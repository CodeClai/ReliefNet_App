import 'dart:io';
import 'package:disasteraid_pk/core/api/api_client.dart';
import 'package:disasteraid_pk/features/campaigns/services/campaign_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

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
  File? _imageFile;
  bool _loading = false;
  final _picker = ImagePicker();
  final api = ApiClient();

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _target.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked!= null) setState(() => _imageFile = File(picked.path));
  }

Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _loading = true);

  try {
    final formData = FormData.fromMap({
      'title': _title.text.trim(),
      'description': _desc.text.trim(),
      'category': _category,
      'target_amount': _target.text.trim(),
      'location': _location.text.trim(),
      if (_imageFile!= null)
        'image': await MultipartFile.fromFile(
          _imageFile!.path,
          filename: _imageFile!.path.split('/').last,
        ),
    });

    await CampaignService().createCampaign(formData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campaign created successfully')),
      );
      Navigator.pop(context, true);
    }
  } on DioException catch (e) {
    final msg = e.response?.data['error']?? 'Failed to create campaign';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  } finally {
    if (mounted) setState(() => _loading = false);
  }
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
            // Image Picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _imageFile == null
               ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text('Tap to add campaign image', style: TextStyle(color: Colors.grey[600])),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                    ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v!.trim().isEmpty? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _desc,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
              validator: (v) => v!.trim().length < 10? 'Min 10 chars' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: _category,
              items: ['food', 'medical', 'shelter', 'education', 'general']
              .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
                 .toList(),
              onChanged: (v) => setState(() => _category = v!),
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _target,
              decoration: InputDecoration(
                labelText: 'Target Amount (PKR)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v!.isEmpty) return 'Required';
                final amount = double.tryParse(v);
                if (amount == null || amount < 1000) return 'Min PKR 1,000';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _location,
              decoration: InputDecoration(
                labelText: 'Location (City/Area)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v!.trim().isEmpty? 'Required' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading? null : _submit,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: _loading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Create Campaign', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}