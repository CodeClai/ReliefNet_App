import 'package:disasteraid_pk/features/admin/admin_request_screen.dart';
import 'package:disasteraid_pk/features/admin/admin_reports_screen.dart'; // ADDED
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/api/api_client.dart';
import 'admin_ngos_screen.dart';
import 'admin_campaigns_screen.dart';
import 'admin_withdrawals_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _index = 0;
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _api.dio.get('/admin/stats');
      setState(() { _stats = res.data['data']; _loading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildStatsTab(),
      const AdminNgosScreen(),
      const AdminCampaignsScreen(),
      const AdminWithdrawalsScreen(),
      const AdminRequestsScreen(),
      const AdminReportsScreen(), // ADDED
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => context.read<AuthProvider>().logout()),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.business), label: 'NGOs'),
          NavigationDestination(icon: Icon(Icons.campaign), label: 'Campaigns'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Withdrawals'),
          NavigationDestination(icon: Icon(Icons.inbox), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.report), label: 'Reports'), // ADDED
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error!= null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadStats, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_stats == null) return const Center(child: Text('No data'));

    final users = _stats!['users']?? {};
    final ngos = _stats!['ngos']?? {};
    final campaigns = _stats!['campaigns']?? {};
    final donations = _stats!['donations']?? {};

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Platform Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard('Total Users', users['total']?.toString()?? '0', Icons.people, Colors.blue),
              _buildStatCard('Donors', users['donors']?.toString()?? '0', Icons.favorite, Colors.pink),
              _buildStatCard('NGOs', '${ngos['approved']?? 0}/${users['ngos']?? 0}', Icons.verified, Colors.green),
              _buildStatCard('Pending NGOs', ngos['pending']?.toString()?? '0', Icons.pending, Colors.orange),
            ],
          ),
          const Divider(height: 32),
          Text('Campaigns & Donations', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard('Active Campaigns', '${campaigns['active']?? 0}/${campaigns['total']?? 0}', Icons.campaign, Colors.teal),
              _buildStatCard('Total Raised', 'PKR ${_formatNumber(donations['total_amount'])}', Icons.volunteer_activism, Colors.purple),
              _buildStatCard('Total Target', 'PKR ${_formatNumber(campaigns['total_target'])}', Icons.flag, Colors.indigo),
              _buildStatCard('Donations Count', donations['total_donations']?.toString()?? '0', Icons.receipt_long, Colors.brown),
            ],
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
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 16,
              child: Icon(icon, color: color, size: 18)
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}