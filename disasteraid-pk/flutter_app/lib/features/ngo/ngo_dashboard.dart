import 'package:disasteraid_pk/features/ngo/ngo_campaign_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/api/api_client.dart';
import 'ngo_withdrawals_screen.dart';

class NgoDashboard extends StatefulWidget {
  const NgoDashboard({super.key});
  @override
  State<NgoDashboard> createState() => _NgoDashboardState();
}

class _NgoDashboardState extends State<NgoDashboard> {
  int _index = 0;
  Map<String, dynamic>? _wallet;
  bool _loading = true;
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final res = await _api.dio.get('/ngos/wallet');
      setState(() { _wallet = res.data['data']; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboardTab(),
      const NgoCampaignsScreen(),
      const NgoWithdrawalsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadWallet),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => context.read<AuthProvider>().logout()),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.campaign), label: 'Campaigns'),
          NavigationDestination(icon: Icon(Icons.account_balance), label: 'Withdrawals'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    
    return RefreshIndicator(
      onRefresh: _loadWallet,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Wallet Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard('Available Balance', 'PKR ${_formatNumber(_wallet?['balance'])}', Icons.account_balance_wallet, Colors.green),
              _buildStatCard('Total Received', 'PKR ${_formatNumber(_wallet?['total_received'])}', Icons.arrow_downward, Colors.blue),
              _buildStatCard('Total Withdrawn', 'PKR ${_formatNumber(_wallet?['total_withdrawn'])}', Icons.arrow_upward, Colors.orange),
              _buildStatCard('Status', 'Active', Icons.verified, Colors.teal),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => setState(() => _index = 2),
            icon: const Icon(Icons.add),
            label: const Text('Request Withdrawal'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic num) {
    if (num == null) return '0';
    final n = double.tryParse(num.toString())?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toInt().toString();
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.1), radius: 16, child: Icon(icon, color: color, size: 18)),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}