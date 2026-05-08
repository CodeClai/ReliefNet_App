import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});
  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  List _reports = [];
  bool _loading = true;
  String _filter = 'PENDING';
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);
    try {
      final res = await _api.dio.get('/admin/reports', queryParameters: {'status': _filter});
      setState(() { _reports = res.data['data']; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _resolve(int id, String status) async {
    final notes = await showDialog<String>(
      context: context,
      builder: (_) {
        final c = TextEditingController();
        return AlertDialog(
          title: Text('$status Report'),
          content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Admin notes', border: OutlineInputBorder()), maxLines: 3),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, c.text), child: const Text('Confirm')),
          ],
        );
      },
    );
    if (notes == null) return;

    try {
      await _api.dio.patch('/admin/reports/$id', data: {'status': status, 'admin_notes': notes});
      _loadReports();
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.response?.data['error']?? 'Failed')));
    }
  }

  Color _reasonColor(String reason) {
    switch (reason) {
      case 'SCAM': return Colors.red;
      case 'FAKE': return Colors.orange;
      case 'HARASSMENT': return Colors.purple;
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
            children: ['PENDING', 'REVIEWED', 'RESOLVED', 'DISMISSED'].map((f) =>
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f),
                  selected: _filter == f,
                  onSelected: (_) { setState(() => _filter = f); _loadReports(); },
                ),
              )
            ).toList(),
          ),
        ),
        Expanded(
          child: _loading? const Center(child: CircularProgressIndicator())
            : _reports.isEmpty? Center(child: Text('No $_filter reports'))
            : RefreshIndicator(
                onRefresh: _loadReports,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _reports.length,
                  itemBuilder: (_, i) {
                    final r = _reports[i];
                    return Card(
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _reasonColor(r['reason']).withOpacity(0.1),
                          child: Icon(Icons.flag, color: _reasonColor(r['reason'])),
                        ),
                        title: Text('${r['target_type'].toUpperCase()}: ${r['target_name']?? r['target_id']}'),
                        subtitle: Text('${r['reason']} - by ${r['reporter_name']?? 'Anonymous'}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (r['description']!= null)...[
                                  Text('Details:', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text(r['description']),
                                  const SizedBox(height: 12),
                                ],
                                Text('Reported: ${r['created_at'].toString().split('T')[0]}'),
                                if (r['admin_notes']!= null)...[
                                  const SizedBox(height: 8),
                                  Text('Admin Notes:', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text(r['admin_notes']),
                                ],
                                if (_filter == 'PENDING')...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(child: OutlinedButton(onPressed: () => _resolve(r['id'], 'DISMISSED'), child: const Text('Dismiss'))),
                                      const SizedBox(width: 8),
                                      Expanded(child: FilledButton(onPressed: () => _resolve(r['id'], 'RESOLVED'), child: const Text('Resolve'))),
                                    ],
                                  ),
                                ],
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
}