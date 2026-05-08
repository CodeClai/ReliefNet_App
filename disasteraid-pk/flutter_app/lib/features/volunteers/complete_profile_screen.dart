import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../core/auth/auth_provider.dart';
import 'volunteer_tasks_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});
  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _location = TextEditingController();
  int? _selectedNgoId;
  List<String> _skills = [];
  String _availability = 'FLEXIBLE';
  List<dynamic> _ngos = [];
  bool _loading = false;
  bool _loadingNgos = true;

  @override
  void initState() {
    super.initState();
    _loadNgos();
  }

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  Future<void> _loadNgos() async {
    try {
      final api = ApiClient();
      final res = await api.dio.get('/ngos');
      if (mounted) {
        setState(() {
          _ngos = res.data['data'];
          _loadingNgos = false;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.response?.data['error']?? 'Failed to load NGOs')),
        );
        setState(() => _loadingNgos = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedNgoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an NGO')),
      );
      return;
    }
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final api = ApiClient();
      await api.dio.post('/volunteers/register', data: {
        'ngo_id': _selectedNgoId,
        'location': _location.text.trim(),
        'skills': _skills,
        'availability': _availability,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile completed successfully'), backgroundColor: Colors.green),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const VolunteerTasksScreen()),
          (route) => false,
        );
      }
    } on DioException catch (e) {
      final msg = e.response?.data['error']?? 'Failed to complete profile';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

Future<void> _logout() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Logout?'),
      content: const Text('You need to complete your profile to access volunteer features. Logout now?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
      ],
    ),
  );

  if (confirmed == true && mounted) {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}
@override
Widget build(BuildContext context) {
  return PopScope(
    canPop: false,
    onPopInvoked: (didPop) async {
      if (!didPop) {
        await _logout();
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Complete Volunteer Profile'),
        automaticallyImplyLeading: false, // Remove default back
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _logout,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _loadingNgos
   ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Help us match you with tasks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your profile to start volunteering. You can logout if you want to do this later.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<int>(
                    value: _selectedNgoId,
                    items: _ngos.map((ngo) => DropdownMenuItem<int>(
                      value: ngo['id'],
                      child: Text(ngo['org_name']),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedNgoId = v),
                    decoration: InputDecoration(
                      labelText: 'Select NGO to volunteer for *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v == null? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _location,
                    decoration: InputDecoration(
                      labelText: 'Your City/Location *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) => v!.trim().length < 3? 'Min 3 characters' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField(
                    value: _availability,
                    items: ['WEEKENDS', 'WEEKDAYS', 'FLEXIBLE']
                   .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                   .toList(),
                    onChanged: (v) => setState(() => _availability = v!),
                    decoration: InputDecoration(
                      labelText: 'Availability',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Skills *', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['MEDICAL', 'DRIVING', 'LOGISTICS', 'GENERAL', 'TEACHING', 'CONSTRUCTION']
                   .map((skill) => FilterChip(
                              label: Text(skill),
                              selected: _skills.contains(skill),
                              onSelected: (sel) => setState(() {
                                sel? _skills.add(skill) : _skills.remove(skill);
                              }),
                            ))
                   .toList(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading? null : _submit,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                    child: _loading
                   ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Complete Profile', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loading? null : _logout,
                    child: const Text('Logout and complete later'),
                  ),
                ],
              ),
            ),
    ),
  );
}
  
}