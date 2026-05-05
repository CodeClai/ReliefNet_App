import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/auth/auth_provider.dart';
import 'core/api/api_client.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/ngo/ngo_onboard_screen.dart';
import 'features/admin/admin_ngos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..checkAuth(),
      child: MaterialApp(
        title: 'DisasterAid PK',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), useMaterial3: true),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/ngo/onboard': (_) => const NgoOnboardScreen(),
          '/admin/ngos': (_) => const AdminNgosScreen(),
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _ngoStatus;
  String? _rejectReason;
  bool _loadingStatus = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user?['role'] == 'ngo') _fetchNgoStatus();
  }

  Future<void> _fetchNgoStatus() async {
    setState(() => _loadingStatus = true);
    try {
      final res = await ApiClient().dio.get('/ngos/me');
      setState(() {
        _ngoStatus = res.data['data']?['status'];
        _rejectReason = res.data['data']?['rejection_reason'];
      });
    } catch (e) {
      // NGO profile not created yet
    } finally {
      setState(() => _loadingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isNgo = user?['role'] == 'ngo';
    final isAdmin = user?['role'] == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('DisasterAid PK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('Welcome ${user?['name']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Chip(label: Text('Role: ${user?['role']}'.toUpperCase()), backgroundColor: Theme.of(context).colorScheme.primaryContainer),
            const SizedBox(height: 32),
            if (isNgo)...[
              if (_loadingStatus) const CircularProgressIndicator()
              else if (_ngoStatus == 'APPROVED')
                const Chip(label: Text('VERIFIED NGO'), backgroundColor: Colors.green, labelStyle: TextStyle(color: Colors.white))
              else if (_ngoStatus == 'PENDING')
                const Chip(label: Text('PENDING APPROVAL'), backgroundColor: Colors.orange, labelStyle: TextStyle(color: Colors.white))
              else if (_ngoStatus == 'REJECTED')...[
                const Chip(label: Text('REJECTED'), backgroundColor: Colors.red, labelStyle: TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                if (_rejectReason!= null) Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text('Reason: $_rejectReason', style: TextStyle(color: Colors.red[700]), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(onPressed: () => Navigator.pushNamed(context, '/ngo/onboard').then((_) => _fetchNgoStatus()), icon: const Icon(Icons.refresh), label: const Text('Resubmit Profile')),
              ] else
                FilledButton.icon(onPressed: () => Navigator.pushNamed(context, '/ngo/onboard').then((_) => _fetchNgoStatus()), icon: const Icon(Icons.business), label: const Text('Complete NGO Profile')),
            ],
            if (isAdmin) FilledButton.icon(onPressed: () => Navigator.pushNamed(context, '/admin/ngos'), icon: const Icon(Icons.approval), label: const Text('Review NGOs')),
          ],
        ),
      ),
    );
  }
}