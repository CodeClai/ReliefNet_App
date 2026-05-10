import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class ReportDialog extends StatefulWidget {
  final String targetType; // 'user', 'campaign', 'request'
  final int targetId;
  final String targetName;

  const ReportDialog({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.targetName,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String _reason = 'SPAM';
  final _descController = TextEditingController();
  bool _loading = false;
  final _api = ApiClient();

  final _reasons = ['SPAM', 'SCAM', 'INAPPROPRIATE', 'FAKE', 'HARASSMENT', 'OTHER'];

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await _api.dio.post('/reports', data: {
        'target_type': widget.targetType,
        'target_id': widget.targetId,
        'reason': _reason,
        'description': _descController.text.trim().isEmpty? null : _descController.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted'), backgroundColor: Colors.green),
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error']?? 'Report failed';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report ${widget.targetName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reason:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
          ..._reasons.map((r) => RadioListTile(
              dense: true,
              title: Text(r),
              value: r,
              groupValue: _reason,
              onChanged: (v) => setState(() => _reason = v!),
            )),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Details (optional)',
                hintText: 'Provide more context...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _loading? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: _loading? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Report'),
        ),
      ],
    );
  }
}