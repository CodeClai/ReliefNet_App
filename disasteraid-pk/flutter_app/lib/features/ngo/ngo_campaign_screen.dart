import 'package:flutter/material.dart';
import 'package:disasteraid_pk/features/campaigns/models/campaign.dart';
import 'package:disasteraid_pk/features/campaigns/screens/campaign_create_screen.dart';
import '../../core/api/api_client.dart';

class NgoCampaignsScreen extends StatefulWidget {
  const NgoCampaignsScreen({super.key});
  @override
  State<NgoCampaignsScreen> createState() => _NgoCampaignsScreenState();
}

class _NgoCampaignsScreenState extends State<NgoCampaignsScreen> {
  final _api = ApiClient();
  List<Campaign> _campaigns = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    setState(() { _loading = true; _error = null; });
    try {
      final ngoRes = await _api.dio.get('/ngos/me');
      final ngoId = ngoRes.data['data']['id'];
      final res = await _api.dio.get('/campaigns', queryParameters: {'ngo_id': ngoId});
      setState(() {
        _campaigns = (res.data['data'] as List).map((e) => Campaign.fromJson(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadCampaigns,
        child: _loading
           ? const Center(child: CircularProgressIndicator())
            : _error!= null
               ? Center(child: Text('Error: $_error'))
                : _campaigns.isEmpty
                   ? _buildEmptyState()
                    : _buildCampaignList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CampaignCreateScreen()),
          );
          if (created == true) _loadCampaigns();
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Campaign'),
      ),
    );
  }

  Widget _buildCampaignList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _campaigns.length,
      itemBuilder: (context, i) {
        final c = _campaigns[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(children: [
                  Chip(label: Text(c.status), visualDensity: VisualDensity.compact),
                  const SizedBox(width: 8),
                  Chip(label: Text(c.category), visualDensity: VisualDensity.compact),
                ]),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: (c.raisedAmount / c.targetAmount).clamp(0.0, 1.0)),
                const SizedBox(height: 4),
                Text('PKR ${c.raisedAmount.toInt()} / ${c.targetAmount.toInt()}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No campaigns yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Create your first campaign to start receiving donations', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}