import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../services/campaign_service.dart';
import '../models/campaign.dart';
import 'campaign_detail_screen.dart';
import '../../../shared/widgets/report_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';

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

  final List<Map<String, dynamic>> _categories = [
    {'key': 'all', 'label': 'All', 'icon': Icons.apps},
    {'key': 'FOOD', 'label': 'Food', 'icon': Icons.restaurant},
    {'key': 'MEDICAL', 'label': 'Medical', 'icon': Icons.medical_services},
    {'key': 'SHELTER', 'label': 'Shelter', 'icon': Icons.home},
    {'key': 'EDUCATION', 'label': 'Education', 'icon': Icons.school},
    {'key': 'CLOTHING', 'label': 'Clothing', 'icon': Icons.checkroom},
    {'key': 'OTHER', 'label': 'Other', 'icon': Icons.category},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _service.getAllCampaigns(
        category: _selectedCategory == 'all'? null : _selectedCategory,
      );
      if (mounted) setState(() {
        _campaigns = list;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Failed to load campaigns';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Campaigns'),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat['key'] ||
                    (cat['key'] == 'all' && _selectedCategory == null);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(cat['icon'], size: 18),
                    label: Text(cat['label']),
                    selected: selected,
                    showCheckmark: false,
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat['key'] == 'all'? null : cat['key']);
                      _load();
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Campaign Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: _load,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return _buildShimmerGrid();
    if (_error!= null) return ErrorState(message: _error!, onRetry: _load);
    if (_campaigns.isEmpty) return _buildEmptyState();
    return _buildCampaignGrid();
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.campaign_outlined,
      title: 'No campaigns found',
      subtitle: _selectedCategory == null
         ? 'Check back later for new campaigns'
          : 'Try selecting a different category',
      onAction: _load,
      actionLabel: 'Refresh',
    );
  }

  Widget _buildCampaignGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _campaigns.length,
      itemBuilder: (context, i) => _CampaignCard(campaign: _campaigns[i]),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final Campaign campaign;
  const _CampaignCard({required this.campaign});

  Color _urgencyColor(BuildContext context) {
    final percent = campaign.percentRaised;
    if (percent < 30) return Theme.of(context).colorScheme.error;
    if (percent < 70) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CampaignDetailScreen(id: campaign.id)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Report + Urgency
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: campaign.imageUrl!= null
                     ? CachedNetworkImage(
                          imageUrl: campaign.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: cs.surfaceVariant),
                          errorWidget: (_, __, ___) => Container(
                            color: cs.surfaceVariant,
                            child: Icon(Icons.image_not_supported, color: cs.onSurfaceVariant),
                          ),
                        )
                      : Container(
                          color: cs.surfaceVariant,
                          child: Icon(Icons.campaign, size: 40, color: cs.onSurfaceVariant),
                        ),
                ),
                // Urgency Pill
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _urgencyColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${campaign.percentRaised}%',
                      style: tt.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Report Menu
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => ReportDialog(
                          targetType: 'campaign',
                          targetId: campaign.id,
                          targetName: campaign.title,
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.more_vert, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Text(
                      campaign.category,
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Title
                    Text(
                      campaign.title,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Org
                    Text(
                      campaign.orgName?? 'Verified NGO',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Progress
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: campaign.progress,
                        backgroundColor: cs.surfaceVariant,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PKR ${_formatAmount(campaign.raisedAmount)}',
                          style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${campaign.percentRaised}%',
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toInt().toString();
  }
}