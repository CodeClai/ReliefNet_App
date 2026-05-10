import 'package:disasteraid_pk/features/admin/admin_audit_screen.dart';
import 'package:disasteraid_pk/features/admin/admin_request_screen.dart';
import 'package:disasteraid_pk/features/admin/admin_reports_screen.dart';
import 'package:disasteraid_pk/features/admin/admin_donations_screen.dart'; // ADDED
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/api/api_client.dart';
import '../../../shared/widgets/error_state.dart';
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

  final List<Widget> _screens = [
    const _AdminStatsTab(),
    const AdminNgosScreen(),
    const AdminCampaignsScreen(),
    const AdminDonationsScreen(), // ADDED
    const AdminWithdrawalsScreen(),
    const AdminRequestsScreen(),
    const AdminReportsScreen(),
    const AdminAuditScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'NGOs',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Campaigns',
          ),
          // ADDED: Donations tab
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: 'Donations',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Withdrawals',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_outlined),
            selectedIcon: Icon(Icons.report),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Audit',
          ),
        ],
      ),
    );
  }
}

class _AdminStatsTab extends StatefulWidget {
  const _AdminStatsTab();

  @override
  State<_AdminStatsTab> createState() => _AdminStatsTabState();
}

class _AdminStatsTabState extends State<_AdminStatsTab> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;
  final _api = ApiClient();
  final _currency = NumberFormat.compact(locale: 'en_PK');

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _api.dio.get('/admin/stats');
      if (mounted) {
        setState(() { _stats = res.data; _loading = false; });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to load stats'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _buildBody(cs, tt),
    );
  }

  Widget _buildBody(ColorScheme cs, TextTheme tt) {
    if (_loading) return _buildShimmer();
    if (_error!= null) return ErrorState(message: _error!, onRetry: _loadStats);
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
          Text('Platform Overview', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _StatCard(
                title: 'Total Users',
                value: '${users['total']?? 0}',
                icon: Icons.people_outline,
                color: Colors.blue,
              ),
              _StatCard(
                title: 'Donors',
                value: '${users['donors']?? 0}',
                icon: Icons.favorite_outline,
                color: Colors.pink,
              ),
              _StatCard(
                title: 'NGOs',
                value: '${ngos['approved']?? 0}/${users['ngos']?? 0}',
                icon: Icons.verified_outlined,
                color: Colors.green,
              ),
              _StatCard(
                title: 'Pending NGOs',
                value: '${ngos['pending']?? 0}',
                icon: Icons.pending_outlined,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Campaigns & Donations', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _StatCard(
                title: 'Active Campaigns',
                value: '${campaigns['active']?? 0}/${campaigns['total']?? 0}',
                icon: Icons.campaign_outlined,
                color: Colors.teal,
              ),
              _StatCard(
                title: 'Total Raised',
                value: 'PKR ${_currency.format(_parseAmount(donations['total_amount']))}',
                icon: Icons.volunteer_activism_outlined,
                color: Colors.purple,
              ),
              _StatCard(
                title: 'Total Target',
                value: 'PKR ${_currency.format(_parseAmount(campaigns['total_target']))}',
                icon: Icons.flag_outlined,
                color: Colors.indigo,
              ),
              _StatCard(
                title: 'Donations',
                value: '${donations['total_donations']?? 0}',
                icon: Icons.receipt_long_outlined,
                color: Colors.brown,
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _parseAmount(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString())?? 0;
  }

  Widget _buildShimmer() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 24, width: 200, color: Colors.white),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: List.generate(4, (_) => Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                )),
              ),
              const SizedBox(height: 24),
              Container(height: 24, width: 250, color: Colors.white),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: List.generate(4, (_) => Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Icon(Icons.arrow_outward, color: color.withOpacity(0.5), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: tt.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}