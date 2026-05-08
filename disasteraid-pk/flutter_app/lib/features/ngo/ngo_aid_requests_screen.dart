import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class NgoAidRequestsScreen extends StatefulWidget {
  const NgoAidRequestsScreen({super.key});
  @override
  State<NgoAidRequestsScreen> createState() => _NgoAidRequestsScreenState();
}

class _NgoAidRequestsScreenState extends State<NgoAidRequestsScreen> {
  List _requests = [];
  List _volunteers = [];
  bool _loading = true;
  String _filter = 'APPROVED';
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
        _api.dio.get('/ngos/aid-requests', queryParameters: {'status': _filter}),
        _api.dio.get('/ngos/volunteers'),
      ]);
      setState(() {
        _requests = results[0].data['data'];
        _volunteers = results[1].data['data'];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _assignVolunteer(int requestId, int volunteerId, String volunteerName) async {
    try {
      await _api.dio.patch('/ngos/aid-requests/$requestId', data: {
        'status': 'ASSIGNED',
        'volunteer_id': volunteerId,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assigned to $volunteerName'), backgroundColor: Colors.green),
        );
        _loadData();
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error']?? 'Assignment failed';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _updateStatus(int requestId, String newStatus) async {
    try {
      await _api.dio.patch('/ngos/aid-requests/$requestId', data: {'status': newStatus});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus'), backgroundColor: Colors.blue),
        );
        _loadData();
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error']?? 'Update failed';
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
            children: ['APPROVED', 'ASSIGNED', 'DELIVERED', 'FULFILLED', 'REJECTED'].map((f) =>
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
                      Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _urgencyColor(r['urgency']).withOpacity(0.1),
                            child: Text(r['urgency'][0], style: TextStyle(color: _urgencyColor(r['urgency']), fontWeight: FontWeight.bold)),
                          ),
                          title: Text(r['beneficiary_name']?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${r['category']} - Family: ${r['family_size']}'),
                              Text(r['campaign_title']?? 'General Request', style: const TextStyle(fontSize: 12)),
                              Text(r['location']?? 'Unknown', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(r['status'], style: const TextStyle(fontSize: 11)),
                            backgroundColor: Colors.blue[50],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Items: $items'),
                                  const SizedBox(height: 8),
                                  Text('Phone: ${r['beneficiary_phone']?? 'N/A'}'),
                                  const SizedBox(height: 8),
                                  Text('Description:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                                  const SizedBox(height: 4),
                                  Text(r['description']?? 'No description'),
                                  const SizedBox(height: 12),
                                  if (r['volunteer_name']!= null)...[
                                    Text('Assigned to: ${r['volunteer_name']} - ${r['volunteer_phone']?? 'N/A'}',
                                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 12),
                                  ],
                                  if (_filter == 'APPROVED')...[
                                    Text('Assign Volunteer:', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                  ..._volunteers.map((v) => ListTile(
                                      dense: true,
                                      leading: const Icon(Icons.person, size: 20),
                                      title: Text(v['name']?? 'Unknown', style: const TextStyle(fontSize: 14)),
                                      subtitle: Text(v['phone']?? '', style: const TextStyle(fontSize: 12)),
                                      trailing: FilledButton(
                                        onPressed: () => _assignVolunteer(r['id'], v['id'], v['name']),
                                        child: const Text('Assign'),
                                      ),
                                    )),
                                    if (_volunteers.isEmpty)
                                      const Text('No approved volunteers yet', style: TextStyle(color: Colors.orange)),
                                  ],
                                  if (_filter == 'ASSIGNED')...[
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        onPressed: () => _updateStatus(r['id'], 'DELIVERED'),
                                        icon: const Icon(Icons.local_shipping),
                                        label: const Text('Mark as Delivered'),
                                      ),
                                    ),
                                  ],
                                  if (_filter == 'DELIVERED')...[
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        onPressed: () => _updateStatus(r['id'], 'FULFILLED'),
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('Mark as Fulfilled'),
                                        style: FilledButton.styleFrom(backgroundColor: Colors.green),
                                      ),
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