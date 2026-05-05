import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class AdminNgosScreen extends StatefulWidget {
  const AdminNgosScreen({super.key});
  @override
  State<AdminNgosScreen> createState() => _AdminNgosScreenState();
}

class _AdminNgosScreenState extends State<AdminNgosScreen> {
  List _ngos = [];
  bool _loading = true;
  String? _error;
  String _filter = 'PENDING';
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _fetchNgos();
  }

  Future<void> _fetchNgos() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _api.dio.get('/admin/ngos', queryParameters: {
        if (_filter!= 'ALL') 'status': _filter,
      });
      setState(() { _ngos = res.data['data']; _loading = false; });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data['error']?? 'Failed to load NGOs';
        _loading = false;
      });
    }
  }

  Future<void> _approve(int id) async {
    try {
      await _api.dio.patch('/admin/ngos/$id/approve');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NGO Approved'), backgroundColor: Colors.green),
        );
        _fetchNgos();
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error']?? 'Approval failed';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _reject(int id) async {
    final reason = await _showRejectDialog();
    if (reason == null) return;

    try {
      await _api.dio.patch('/admin/ngos/$id/reject', data: {'reason': reason});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('NGO Rejected'), backgroundColor: Colors.orange),
        );
        _fetchNgos();
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error']?? 'Rejection failed';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject NGO'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason',
            hintText: 'Missing documents, invalid info...',
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
            child: const Text('Reject'),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Future<void> _openDoc(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open document')));
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'APPROVED': return Colors.green;
      case 'REJECTED': return Colors.red;
      case 'PENDING': return Colors.orange;
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
            children: ['ALL', 'PENDING', 'APPROVED', 'REJECTED'].map((f) =>
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f),
                  selected: _filter == f,
                  onSelected: (_) { setState(() => _filter = f); _fetchNgos(); },
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
                      FilledButton(onPressed: _fetchNgos, child: const Text('Retry')),
                    ],
                  ),
                )
            : _ngos.isEmpty
        ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No $_filter NGOs', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                )
                : RefreshIndicator(
                    onRefresh: _fetchNgos,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _ngos.length,
                      itemBuilder: (context, i) {
                        final ngo = _ngos[i];
                        final docs = List<String>.from(ngo['docs_url']?? []);
                        final status = ngo['status']?? 'PENDING';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: _statusColor(status).withOpacity(0.1),
                              child: Icon(Icons.business, color: _statusColor(status)),
                            ),
                            title: Text(ngo['org_name']?? 'Unknown NGO', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Reg: ${ngo['registration_number']?? 'N/A'}'),
                                Chip(
                                  label: Text(status, style: const TextStyle(fontSize: 11)),
                                  backgroundColor: _statusColor(status).withOpacity(0.1),
                                  labelStyle: TextStyle(color: _statusColor(status)),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _infoRow('Contact Person', ngo['contact_person']),
                                    _infoRow('Email', ngo['email']),
                                    _infoRow('Phone', ngo['phone']),
                                    const SizedBox(height: 12),
                                    Text('Mission', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
                                    const SizedBox(height: 4),
                                    Text(ngo['mission']?? 'No mission provided'),
                                    const SizedBox(height: 16),
                                    if (docs.isNotEmpty)...[
                                      Text('Documents (${docs.length})', style: const TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                  ...docs.map((url) => url.toLowerCase().contains('.pdf')
                                       ? ListTile(
                                              dense: true,
                                              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                              title: Text(url.split('/').last, style: const TextStyle(fontSize: 12)),
                                              trailing: const Icon(Icons.open_in_new, size: 18),
                                              onTap: () => _openDoc(url),
                                              contentPadding: EdgeInsets.zero,
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: InkWell(
                                                  onTap: () => _openDoc(url),
                                                  child: CachedNetworkImage(
                                                    imageUrl: url,
                                                    height: 120,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    placeholder: (c, u) => Container(
                                                      height: 120,
                                                      color: Colors.grey[200],
                                                      child: const Center(child: CircularProgressIndicator()),
                                                    ),
                                                    errorWidget: (c, u, e) => Container(
                                                      height: 120,
                                                      color: Colors.grey[200],
                                                      child: const Icon(Icons.error),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )),
                                    ],
                                    if (status == 'PENDING')...[
                                      const SizedBox(height: 16),
                                      Row(children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _reject(ngo['id']),
                                            icon: const Icon(Icons.close),
                                            label: const Text('Reject'),
                                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: FilledButton.icon(
                                            onPressed: () => _approve(ngo['id']),
                                            icon: const Icon(Icons.check),
                                            label: const Text('Approve'),
                                          ),
                                        ),
                                      ]),
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

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value?? 'N/A')),
        ],
      ),
    );
  }
}