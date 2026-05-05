import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class AdminCampaignsScreen extends StatefulWidget {
  const AdminCampaignsScreen({super.key});
  @override
  State<AdminCampaignsScreen> createState() => _AdminCampaignsScreenState();
}

class _AdminCampaignsScreenState extends State<AdminCampaignsScreen> {
  List _campaigns = [];
  bool _loading = true;
  String _filter = 'ALL';
  String? _error;
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    setState(() { _loading = true; _error = null; });
    try {
      final Map<String, dynamic> params = _filter == 'ALL'? {} : {'status': _filter};
      final res = await _api.dio.get('/admin/campaigns', queryParameters: params);
      setState(() { _campaigns = res.data['data']; _loading = false; });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data['error']?? 'Failed to load campaigns';
        _loading = false;
      });
    }
  }

  Future<void> _updateStatus(int id, String status, String title) async {
    final confirmed = await _confirmDialog(status, title);
    if (!confirmed) return;

    try {
      await _api.dio.patch('/admin/campaigns/$id/status', data: {'status': status});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Campaign $status'), backgroundColor: Colors.green),
        );
        _loadCampaigns();
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error']?? 'Update failed';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<bool> _confirmDialog(String status, String title) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$status Campaign?'),
        content: Text('Are you sure you want to $status "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
            style: status == 'COMPLETED'? FilledButton.styleFrom(backgroundColor: Colors.red) : null,
          ),
        ],
      ),
    )?? false;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE': return Colors.green;
      case 'PAUSED': return Colors.orange;
      case 'COMPLETED': return Colors.blue;
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
            children: ['ALL', 'ACTIVE', 'PAUSED', 'COMPLETED'].map((f) =>
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f),
                  selected: _filter == f,
                  onSelected: (_) { setState(() => _filter = f); _loadCampaigns(); },
                ),
              )
            ).toList(),
          ),
        ),
        Expanded(
          child: _loading
       ? const Center(child: CircularProgressIndicator())
            : _error!= null
       ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _loadCampaigns, child: const Text('Retry')),
                    ],
                  ),
                )
            : _campaigns.isEmpty
       ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No $_filter campaigns', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                )
                : RefreshIndicator(
                    onRefresh: _loadCampaigns,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _campaigns.length,
                      itemBuilder: (context, i) {
                        final c = _campaigns[i];
                        final target = double.tryParse(c['target_amount']?.toString()?? '0')?? 0;
                        final raised = double.tryParse(c['raised_amount']?.toString()?? '0')?? 0;
                        final progress = target > 0? raised / target : 0.0;
                        final status = c['status']?? 'ACTIVE';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: _statusColor(status).withOpacity(0.1),
                              child: Icon(Icons.campaign, color: _statusColor(status)),
                            ),
                            title: Text(c['title']?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c['org_name']?? 'Unknown NGO', style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(value: progress.clamp(0, 1), minHeight: 6),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'PKR ${raised.toInt()} / ${target.toInt()}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(status, style: const TextStyle(fontSize: 11)),
                              backgroundColor: _statusColor(status).withOpacity(0.1),
                              labelStyle: TextStyle(color: _statusColor(status)),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _detailRow('NGO', '${c['org_name']} (${c['ngo_email']?? 'N/A'})'),
                                    _detailRow('Category', c['category']?? 'N/A'),
                                    _detailRow('Location', c['location']?? 'N/A'),
                                    _detailRow('Created', c['created_at']?.toString().split('T')[0]?? 'N/A'),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        if (status == 'ACTIVE')
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _updateStatus(c['id'], 'PAUSED', c['title']),
                                              icon: const Icon(Icons.pause),
                                              label: const Text('Pause'),
                                            ),
                                          ),
                                        if (status == 'PAUSED')
                                          Expanded(
                                            child: FilledButton.icon(
                                              onPressed: () => _updateStatus(c['id'], 'ACTIVE', c['title']),
                                              icon: const Icon(Icons.play_arrow),
                                              label: const Text('Resume'),
                                            ),
                                          ),
                                        const SizedBox(width: 12),
                                        if (status!= 'COMPLETED')
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _updateStatus(c['id'], 'COMPLETED', c['title']),
                                              icon: const Icon(Icons.check_circle),
                                              label: const Text('Complete'),
                                              style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
                                            ),
                                          ),
                                      ],
                                    ),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}