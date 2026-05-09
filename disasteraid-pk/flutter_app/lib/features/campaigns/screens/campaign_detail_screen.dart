import 'package:disasteraid_pk/features/campaigns/widgets/manual_donate_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/api/api_client.dart';
import '../services/campaign_service.dart';
import '../models/campaign.dart';
import '../../../shared/widgets/report_dialog.dart';

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
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final c = await _service.getCampaign(widget.id);
      if (mounted) {
        setState(() {
          campaign = c;
          loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          error = e.message;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = 'Failed to load campaign';
          loading = false;
        });
      }
    }
  }

  void _showDonateDialog() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.credit_card, color: Theme.of(context).colorScheme.primary),
              title: const Text('Donate via Card / JazzCash'),
              subtitle: const Text('Instant payment - Coming Soon'),
              onTap: () {
                Navigator.pop(ctx);
                _showMockDonateSheet();
              },
            ),
            ListTile(
              leading: Icon(Icons.account_balance, color: Theme.of(context).colorScheme.primary),
              title: const Text('Bank Transfer'),
              subtitle: const Text('Transfer + Upload Slip - Available Now'),
              trailing: const Chip(label: Text('ACTIVE'), visualDensity: VisualDensity.compact),
              onTap: () {
                Navigator.pop(ctx);
                _showManualDonateSheet();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showMockDonateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => DonateSheet(
        campaign: campaign!,
        onSuccess: () {
          _load();
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showManualDonateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => ManualDonateSheet(
        campaignId: campaign!.id,
        campaignTitle: campaign!.title,
      ),
    ).then((_) => _load());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'PAUSED':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton:!loading && campaign!= null && campaign!.status == 'ACTIVE'
         ? FloatingActionButton.extended(
              onPressed: _showDonateDialog,
              icon: const Icon(Icons.favorite),
              label: const Text('Donate Now'),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (loading) return _buildShimmer();
    if (error!= null) return _buildError();
    if (campaign == null) return _buildNotFound();
    return _buildContent();
  }

  Widget _buildShimmer() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(toolbarHeight: 0, pinned: true),
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Container(height: 240, color: Colors.white),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(height: 20, width: 200, color: Colors.white),
                      const SizedBox(height: 16),
                      Container(height: 100, color: Colors.white),
                      const SizedBox(height: 16),
                      Container(height: 200, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Error', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Campaign not found')),
    );
  }

  Widget _buildContent() {
    final c = campaign!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              tooltip: 'Report',
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ReportDialog(
                  targetType: 'campaign',
                  targetId: c.id,
                  targetName: c.title,
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: c.imageUrl!= null
               ? CachedNetworkImage(
                    imageUrl: c.imageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: cs.surfaceVariant,
                      child: Icon(Icons.campaign, size: 80, color: cs.onSurfaceVariant),
                    ),
                  )
                : Container(
                    color: cs.surfaceVariant,
                    child: Icon(Icons.campaign, size: 80, color: cs.onSurfaceVariant),
                  ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category + Status
                Row(
                  children: [
                    Chip(
                      label: Text(c.category),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: cs.primaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(c.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _statusColor(c.status)),
                      ),
                      child: Text(
                        c.status,
                        style: tt.labelSmall?.copyWith(
                          color: _statusColor(c.status),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  c.title,
                  style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Org + Location
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 16, color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Text(c.orgName?? 'Verified NGO', style: tt.bodyMedium),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(c.location?? 'Pakistan', style: tt.bodyMedium),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Progress Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Raised', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(
                                'PKR ${_formatAmount(c.raisedAmount)}',
                                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Goal', style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(
                                'PKR ${_formatAmount(c.targetAmount)}',
                                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: c.progress,
                          minHeight: 10,
                          backgroundColor: cs.surface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${c.percentRaised}% funded • ${c.daysLeft?? '∞'} days left',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Description
                Text(
                  'About this campaign',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  c.description,
                  style: tt.bodyLarge?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toInt().toString();
  }
}

class DonateSheet extends StatefulWidget {
  final Campaign campaign;
  final VoidCallback onSuccess;

  const DonateSheet({super.key, required this.campaign, required this.onSuccess});

  @override
  State<DonateSheet> createState() => _DonateSheetState();
}

class _DonateSheetState extends State<DonateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _paymentMethod = 'MOCK';
  bool _loading = false;
  final _api = ApiClient();

  final List<int> _quickAmounts = [500, 1000, 5000, 10000];

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _donate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final res = await _api.dio.post('/donations', data: {
        'campaign_id': widget.campaign.id,
        'amount': double.parse(_amountController.text),
        'donor_name': _nameController.text.trim(),
        'donor_email': _emailController.text.trim().isEmpty? null : _emailController.text.trim(),
        'payment_method': _paymentMethod,
        'is_anonymous': false,
      });

      if (mounted) {
        final txnRef = res.data['transaction_ref'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Donation successful! Ref: ${txnRef.substring(0, 8)}...'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onSuccess();
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error']?? 'Donation failed';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 8,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Donate to ${widget.campaign.title}',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Quick amounts', style: tt.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _quickAmounts
                 .map((amt) => ChoiceChip(
                        label: Text('PKR $amt'),
                        selected: _amountController.text == amt.toString(),
                        onSelected: (_) => setState(() => _amountController.text = amt.toString()),
                      ))
                 .toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (PKR)',
                prefixText: 'PKR ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v!.isEmpty) return 'Required';
                final amt = int.tryParse(v);
                if (amt == null || amt < 100) return 'Min PKR 100';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.trim().isEmpty? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: ['MOCK', 'JAZZCASH', 'EASYPAISA', 'STRIPE']
                 .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                 .toList(),
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading? null : _donate,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                   ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Confirm Donation', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}