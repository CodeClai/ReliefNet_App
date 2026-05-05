import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/campaign_provider.dart';
import 'campaign_detail_screen.dart';

class CampaignListScreen extends ConsumerWidget {
  const CampaignListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaigns = ref.watch(allCampaignsProvider(null));

    return Scaffold(
      appBar: AppBar(title: const Text('Active Campaigns')),
      body: campaigns.when(
        data: (list) => list.isEmpty
            ? const Center(child: Text('No active campaigns'))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final c = list[i];
                  final progress = c.raisedAmount / c.targetAmount;
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: c.imageUrl!= null
                          ? Image.network(c.imageUrl!, width: 60, fit: BoxFit.cover)
                          : const Icon(Icons.campaign, size: 40),
                      title: Text(c.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.orgName?? 'NGO'),
                          LinearProgressIndicator(value: progress.clamp(0, 1)),
                          Text('Rs ${c.raisedAmount.toInt()} / ${c.targetAmount.toInt()}'),
                        ],
                      ),
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => CampaignDetailScreen(id: c.id),
                      )),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
