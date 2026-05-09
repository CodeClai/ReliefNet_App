import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/api/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _role = 'donor';
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  final Map<String, Map<String, dynamic>> _roles = {
    'donor': {'label': 'Donor', 'icon': Icons.favorite, 'desc': 'Support campaigns with PKR'},
    'ngo': {'label': 'NGO', 'icon': Icons.corporate_fare, 'desc': 'Run campaigns & manage aid'},
    'volunteer': {'label': 'Volunteer', 'icon': Icons.volunteer_activism, 'desc': 'Deliver aid to beneficiaries'},
    'beneficiary': {'label': 'Beneficiary', 'icon': Icons.family_restroom, 'desc': 'Request aid for your needs'},
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    if (email.isEmpty && phone.isEmpty) {
      setState(() => _error = 'Email or Phone required');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      await context.read<AuthProvider>().register(
        name: _nameController.text.trim(),
        email: email.isEmpty? null : email,
        phone: phone.isEmpty? null : phone,
        password: _passwordController.text,
        role: _role,
      );
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString()); // ApiException has clean message
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Join DisasterAid PK', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Select your role to get started', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) => v!.trim().length < 2? 'Enter your name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v!.isEmpty && _phoneController.text.isEmpty) return null;
                if (v.isNotEmpty &&!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                  return 'Invalid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                prefixIcon: const Icon(Icons.phone_outlined),
                hintText: '03XXXXXXXXX',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v!.isEmpty && _emailController.text.isEmpty) return null;
                if (v.isNotEmpty &&!RegExp(r'^03\d{9}$').hasMatch(v)) {
                  return 'Format: 03XXXXXXXXX';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure =!_obscure),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              obscureText: _obscure,
              validator: (v) => v!.length < 6? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 24),
            Text('I am a', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
          ..._roles.entries.map((entry) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _role == entry.key
                 ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300]!,
                  width: _role == entry.key? 2 : 1,
                ),
              ),
              child: RadioListTile<String>(
                value: entry.key,
                groupValue: _role,
                onChanged: (v) => setState(() => _role = v!),
                title: Row(children: [
                  Icon(entry.value['icon'], color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(entry.value['label'], style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
                subtitle: Text(entry.value['desc'], style: const TextStyle(fontSize: 12)),
              ),
            )),
            if (_error!= null)...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: TextStyle(color: Colors.red[700]))),
                ]),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading? null : _register,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Create Account', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}