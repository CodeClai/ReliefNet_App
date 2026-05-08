import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/auth/auth_provider.dart';
import '../services/campaign_service.dart';
import '../models/campaign.dart';
import 'campaign_detail_screen.dart';
import '../../../shared/widgets/report_dialog.dart'; // ADDED

class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({super.key});
  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  final _service = CampaignService();
  List<Campaign> _campaigns = [];
  bool _loading = true;
  String? _error;
  String? _selectedCategory;

  final List<String> _categories = ['all', 'food', 'medical', 'shelter', 'education', 'general'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _service.getAllCampaigns(
        category: _selectedCategory == 'all'? null : _selectedCategory,
      );
      setState(() { _campaigns = list; _loading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Campaigns'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat || (cat == 'all' && _selectedCategory == null);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: FilterChip(
                    label: Text(cat.toUpperCase()),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat == 'all'? null : cat);
                      _load();
                    },
                  ),
                );
              },
            ),
          ),
          // Campaign List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
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
                          FilledButton(onPressed: _load, child: const Text('Retry')),
                        ],
                      ),
                    )
                : _campaigns.isEmpty
             ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text('No campaigns found', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _campaigns.length,
                        itemBuilder: (context, i) {
                          final c = _campaigns[i];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => CampaignDetailScreen(id: c.id)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image with Report Button Overlay
                                  Stack(
                                    children: [
                                      if (c.imageUrl!= null)
                                        Image.network(
                                          c.imageUrl!,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 180,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image_not_supported, size: 50),
                                          ),
                                        )
                                      else
                                        Container(
                                          height: 180,
                                          color: Colors.grey[300],
                                          child: const Center(child: Icon(Icons.campaign, size: 50)),
                                        ),
                                      // ADDED: Report button top-right
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: PopupMenuButton(
                                            icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                                            itemBuilder: (_) => [
                                              PopupMenuItem(
                                                child: const ListTile(
                                                  leading: Icon(Icons.flag, size: 20),
                                                  title: Text('Report'),
                                                  dense: true,
                                                ),
                                                onTap: () {
                                                  // Use Future.delayed to avoid popup menu context issues
                                                  Future.delayed(Duration.zero, () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) => ReportDialog(
                                                        targetType: 'campaign',
                                                        targetId: c.id,
                                                        targetName: c.title,
                                                      ),
                                                    );
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Chip(
                                              label: Text(c.category.toUpperCase()),
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            const Spacer(),
                                            Text(
                                              c.location?? 'Pakistan',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          c.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          c.orgName?? 'Verified NGO',
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        const SizedBox(height: 12),
                                        LinearProgressIndicator(
                                          value: c.progress,
                                          backgroundColor: Colors.grey[300],
                                          minHeight: 6,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'PKR ${c.raisedAmount.toInt()}',
                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              '${c.percentRaised}% of PKR ${c.targetAmount.toInt()}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}