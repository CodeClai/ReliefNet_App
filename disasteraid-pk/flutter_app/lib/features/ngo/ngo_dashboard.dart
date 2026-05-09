import 'package:disasteraid_pk/features/ngo/ngo_aid_requests_screen.dart';
import 'package:disasteraid_pk/features/ngo/ngo_campaign_screen.dart';
import 'package:disasteraid_pk/features/ngo/ngo_dashboard_screen.dart';
import 'package:disasteraid_pk/features/ngo/ngo_withdrawals_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';

class NgoDashboard extends StatefulWidget {
  const NgoDashboard({super.key});
  @override
  State<NgoDashboard> createState() => _NgoDashboardState();
}

class _NgoDashboardState extends State<NgoDashboard> {
  int _index = 0;

  final List<Widget> _screens = [
    const NGODashboardScreen(),
    const NgoCampaignsScreen(),
    const NgoAidRequestsScreen(),
    const NgoWithdrawalsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Dashboard'),
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
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Campaigns',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Withdrawals',
          ),
        ],
      ),
    );
  }
}