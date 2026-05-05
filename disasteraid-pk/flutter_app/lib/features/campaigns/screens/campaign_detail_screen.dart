import 'package:flutter/material.dart';
import '../services/campaign_service.dart';
import '../models/campaign.dart';

class CampaignDetailScreen extends StatefulWidget {
  final int id;
  const CampaignDetailScreen({super.key, required this.id});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen> {
  final _service = CampaignService();
  Campaign? campaign;
  bool loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final c = await _service.getCampaign(widget.id);
      setState(() { campaign = c; loading = false; });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (campaign == null) return const Scaffold(body: Center(child: Text('Campaign not found')));
    final c = campaign!;
    final progress = c.targetAmount > 0? c.raisedAmount / c.targetAmount : 0.0;

    return Scaffold(
      appBar: AppBar(title: Text(c.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.imageUrl!= null) ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(c.imageUrl!, height: 200, width: double.infinity, fit: BoxFit.cover)),
            const SizedBox(height: 16),
            Text(c.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text('By ${c.orgName}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progress.clamp(0, 1), minHeight: 8, borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 8),
            Text('Rs ${c.raisedAmount.toInt()} raised of Rs ${c.targetAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Text('About', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(c.description),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donations - Module 4'))),
                style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: const Text('Donate Now', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
