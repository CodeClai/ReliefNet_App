import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/campaign_service.dart';
import '../models/campaign.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  final int id;
  const CampaignDetailScreen({super.key, required this.id});

  @override
  ConsumerState<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen> {
  Campaign? campaign;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = ref.read(campaignServiceProvider);
    final c = await service.getCampaign(widget.id);
    setState(() { campaign = c; loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final c = campaign!;
    final progress = c.raisedAmount / c.targetAmount;

    return Scaffold(
      appBar: AppBar(title: Text(c.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.imageUrl!= null) Image.network(c.imageUrl!),
            const SizedBox(height: 16),
            Text(c.title, style: Theme.of(context).textTheme.headlineSmall),
            Text('By ${c.orgName}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress.clamp(0, 1), minHeight: 8),
            Text('Rs ${c.raisedAmount.toInt()} raised of Rs ${c.targetAmount.toInt()}'),
            const SizedBox(height: 16),
            Text(c.description),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Donations coming in Module 4')),
                  );
                },
                child: const Text('Donate Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
