import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_provider.dart';
import '../services/campaign_service.dart';
import '../models/campaign.dart';
import 'campaign_detail_screen.dart';

class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({super.key});
  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  final _service = CampaignService();
  List<Campaign> _campaigns = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final list = await _service.getAllCampaigns();
      setState(() { _campaigns = list; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Campaigns'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => context.read<AuthProvider>().logout())],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
           ? const Center(child: CircularProgressIndicator())
            : _campaigns.isEmpty
               ? const Center(child: Text('No campaigns found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _campaigns.length,
                    itemBuilder: (context, i) {
                      final c = _campaigns[i];
                      final progress = c.targetAmount > 0? c.raisedAmount / c.targetAmount : 0.0;
                      return Card(
                        child: ListTile(
                          title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.orgName?? 'NGO', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(value: progress.clamp(0, 1)),
                              Text('Rs ${c.raisedAmount.toInt()} / ${c.targetAmount.toInt()}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          trailing: Chip(label: Text(c.category)),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CampaignDetailScreen(id: c.id))),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
