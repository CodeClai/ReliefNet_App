import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});
  @override
  State<AdminAuditScreen> createState() => _AdminAuditScreenState();
}

class _AdminAuditScreenState extends State<AdminAuditScreen> {
  List _logs = [];
  bool _loading = true;
  String _filter = 'all';
  final _api = ApiClient();

  final _actions = ['all', 'APPROVE_NGO', 'REJECT_NGO', 'SUSPEND_NGO'];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _loading = true);
    try {
      final res = await _api.dio.get('/admin/audit-logs', queryParameters: {
        'action': _filter == 'all'? null : _filter,
      });
      setState(() { _logs = res.data['data']; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Color _actionColor(String action) {
    if (action.contains('APPROVE')) return Colors.green;
    if (action.contains('REJECT') || action.contains('SUSPEND')) return Colors.red;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: _actions.map((f) =>
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f == 'all'? 'ALL' : f.replaceAll('_', ' ')),
                  selected: _filter == f,
                  onSelected: (_) { setState(() => _filter = f); _loadLogs(); },
                ),
              )
            ).toList(),
          ),
        ),
        Expanded(
          child: _loading? const Center(child: CircularProgressIndicator())
            : _logs.isEmpty? const Center(child: Text('No audit logs'))
            : RefreshIndicator(
                onRefresh: _loadLogs,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _logs.length,
                  itemBuilder: (_, i) {
                    final l = _logs[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _actionColor(l['action']).withOpacity(0.1),
                          child: Icon(Icons.history, color: _actionColor(l['action']), size: 20),
                        ),
                        title: Text('${l['action'].replaceAll('_', ' ')}: ${l['target_name']?? l['target_id']}'),
                        subtitle: Text('by ${l['admin_name']?? 'Unknown'} - ${l['created_at'].toString().split('T')[0]}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (l['old_value']!= null)...[
                                  Text('Old Value:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                                  Text(l['old_value'].toString(), style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 8),
                                ],
                                if (l['new_value']!= null)...[
                                  Text('New Value:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                                  Text(l['new_value'].toString(), style: const TextStyle(fontSize: 12)),
                                  const SizedBox(height: 8),
                                ],
                                if (l['reason']!= null)...[
                                  Text('Reason:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                                  Text(l['reason']),
                                  const SizedBox(height: 8),
                                ],
                                Text('IP: ${l['ip_address']?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                Text('Time: ${l['created_at']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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