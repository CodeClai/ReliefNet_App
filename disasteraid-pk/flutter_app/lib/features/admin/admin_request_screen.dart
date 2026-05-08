import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});
  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  List _requests = [];
  List _ngos = [];
  bool _loading = true;
  String _filter = 'PENDING';
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _api.dio.get('/admin/aid-requests', queryParameters: {'status': _filter}),
        _api.dio.get('/ngos', queryParameters: {'status': 'APPROVED'}),
      ]);
      setState(() {
        _requests = results[0].data['data'];
        _ngos = results[1].data['data'];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Load failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _assignNgo(int requestId, int ngoId, String beneficiaryName, String ngoName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Assign Request?'),
        content: Text('Assign $beneficiaryName\'s request to $ngoName?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Assign')),
        ],
      ),
    );
    if (confirmed!= true) return;

    try {
      await _api.dio.patch('/admin/aid-requests/$requestId/assign', data: {
        'ngo_id': ngoId,
        'status': 'APPROVED',
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assigned to $ngoName'), backgroundColor: Colors.green),
        );
        _loadData();
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error']?? 'Assignment failed';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _rejectRequest(int requestId, String beneficiaryName) async {
    final controller = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Reject Request'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason *',
            hintText: 'Duplicate, outside service area, etc',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reason required')));
                return;
              }
              Navigator.pop(context, controller.text.trim());
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (reason == null) return;

    try {
      await _api.dio.patch('/admin/aid-requests/$requestId/assign', data: {
        'status': 'REJECTED',
        'rejection_reason': reason,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request rejected'), backgroundColor: Colors.orange),
        );
        _loadData();
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error']?? 'Rejection failed';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'CRITICAL': return Colors.red;
      case 'HIGH': return Colors.deepOrange;
      case 'MEDIUM': return Colors.amber[700]!;
      default: return Colors.green;
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
            children: ['PENDING', 'APPROVED', 'ASSIGNED', 'REJECTED', 'FULFILLED'].map((f) =>
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f),
                  selected: _filter == f,
                  onSelected: (_) { setState(() => _filter = f); _loadData(); },
                ),
              )
            ).toList(),
          ),
        ),
        Expanded(
          child: _loading
          ? const Center(child: CircularProgressIndicator())
            : _requests.isEmpty
            ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No $_filter requests', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _requests.length,
                    itemBuilder: (context, i) {
                      final r = _requests[i];
                      final items = (r['items_needed'] as List?)?.join(', ')?? r['category']?? 'Aid';
                      final isGeneral = r['campaign_id'] == null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _urgencyColor(r['urgency']).withOpacity(0.1),
                            child: Text(r['urgency'][0], style: TextStyle(color: _urgencyColor(r['urgency']), fontWeight: FontWeight.bold)),
                          ),
                          title: Row(
                            children: [
                              Expanded(child: Text(r['beneficiary_name']?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold))),
                              if (isGeneral) Chip(
                                label: const Text('GENERAL', style: TextStyle(fontSize: 10)),
                                backgroundColor: Colors.purple[50],
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${r['category']} - Family: ${r['family_size']}'),
                              Text(r['location']?? 'Unknown', style: const TextStyle(fontSize: 12)),
                              Text('Created: ${r['created_at'].toString().split('T')[0]}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (r['campaign_title']!= null)...[
                                    Text('Campaign: ${r['campaign_title']}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                  ],
                                  Text('Items: $items'),
                                  const SizedBox(height: 8),
                                  Text('Description:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                                  const SizedBox(height: 4),
                                  Text(r['description']?? 'No description'),
                                  const SizedBox(height: 12),
                                  if (r['org_name']!= null)...[
                                    Text('Current NGO: ${r['org_name']}', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 12),
                                  ],
                                  if (_filter == 'PENDING')...[
                                    Text('Assign to NGO:', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                  ..._ngos.map((ngo) => ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.business, size: 20),
                                      title: Text(ngo['org_name'], style: const TextStyle(fontSize: 14)),
                                      trailing: FilledButton(
                                        onPressed: () => _assignNgo(r['id'], ngo['id'], r['beneficiary_name'], ngo['org_name']),
                                        child: const Text('Assign'),
                                      ),
                                    )),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () => _rejectRequest(r['id'], r['beneficiary_name']),
                                        icon: const Icon(Icons.close),
                                        label: const Text('Reject Request'),
                                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                      ),
                                    ),
                                  ],
                                  if (r['rejection_reason']!= null)...[
                                    Text('Rejection Reason:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red[700])),
                                    const SizedBox(height: 4),
                                    Text(r['rejection_reason'], style: TextStyle(color: Colors.red[700])),
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