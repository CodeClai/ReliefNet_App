import 'package:disasteraid_pk/features/campaigns/models/campaign.dart';
import 'package:disasteraid_pk/features/campaigns/screens/campaign_create_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/api/api_client.dart';

class NgoDashboard extends StatefulWidget {
  const NgoDashboard({super.key});
  @override
  State<NgoDashboard> createState() => _NgoDashboardState();
}

class _NgoDashboardState extends State<NgoDashboard> {
  final api = ApiClient();
  Map<String, dynamic>? wallet;
  List<Campaign> campaigns = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { loading = true; error = null; });
    try {
      final results = await Future.wait([
        api.dio.get('/ngos/wallet'),
        api.dio.get('/ngos/campaigns'),
      ]);
      setState(() {
        wallet = results[0].data['data'];
        campaigns = (results[1].data['data'] as List)
           .map((e) => Campaign.fromJson(e))
           .toList();
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: loading
         ? const Center(child: CircularProgressIndicator())
          : error!= null
          ? Center(child: Text('Error: $error'))
            : campaigns.isEmpty
            ? _buildEmptyState()
              : _buildDashboard(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CampaignCreateScreen()),
          );
          if (created == true) _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Campaign'),
      ),
    );
  }

  Widget _buildDashboard() {
    final balance = double.tryParse(wallet?['balance']?.toString()?? '0')?? 0;
    final totalReceived = double.tryParse(wallet?['total_received']?.toString()?? '0')?? 0;
    final totalWithdrawn = double.tryParse(wallet?['total_withdrawn']?.toString()?? '0')?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Wallet Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Wallet Balance', style: Theme.of(context).textTheme.titleMedium),
                    Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'PKR ${balance.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statItem('Total Received', 'PKR ${totalReceived.toStringAsFixed(0)}'),
                    _statItem('Withdrawn', 'PKR ${totalWithdrawn.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: balance < 100? null : () {
                    // TODO: Navigate to withdrawal screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Withdrawal screen coming next')),
                    );
                  },
                  icon: const Icon(Icons.money),
                  label: const Text('Withdraw Funds'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Campaigns Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Campaigns', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text('${campaigns.length} Total', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 12),
        // Campaign List
      ...campaigns.map((c) => Card(
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
                LinearProgressIndicator(
                  value: (c.raisedAmount / c.targetAmount).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 4),
                Text(
                  'PKR ${c.raisedAmount.toInt()} / ${c.targetAmount.toInt()}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            onTap: () {
              // TODO: Navigate to campaign detail
            },
          ),
        )),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
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
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create Campaign'),
            onPressed: () async {
              final created = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CampaignCreateScreen()),
              );
              if (created == true) _loadData();
            },
          ),
        ],
      ),
    );
  }
}