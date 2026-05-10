import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/api/api_client.dart';

class AdminDonationsScreen extends StatefulWidget {
  const AdminDonationsScreen({super.key});

  @override
  State<AdminDonationsScreen> createState() => _AdminDonationsScreenState();
}

class _AdminDonationsScreenState extends State<AdminDonationsScreen> {
  List<dynamic> _pendingDonations = [];
  bool _loading = true;
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => _loading = true);
    try {
      final res = await _api.dio.get('/donations/pending');
      setState(() {
        _pendingDonations = res.data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load: $e')),
        );
      }
    }
  }

  Future<void> _verifyDonation(int donationId, bool approve) async {
    final rejectionController = TextEditingController();
    String? reason;

    if (!approve) {
      reason = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Reject Donation'),
          content: TextField(
            controller: rejectionController,
            decoration: const InputDecoration(
              labelText: 'Rejection Reason *',
              hintText: 'e.g. Invalid screenshot',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, rejectionController.text),
              child: const Text('Reject'),
            ),
          ],
        ),
      );
      if (reason == null || reason.isEmpty) return;
    }

    try {
      await _api.dio.patch('/donations/$donationId/verify', data: {
        'status': approve? 'VERIFIED' : 'REJECTED',
        'rejection_reason': reason,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve? 'Donation verified' : 'Donation rejected'),
            backgroundColor: approve? Colors.green : Colors.orange,
          ),
        );
        _loadPending();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _viewProof(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Payment Proof'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => const Icon(Icons.error, size: 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Donations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPending,
          ),
        ],
      ),
      body: _loading
         ? const Center(child: CircularProgressIndicator())
          : _pendingDonations.isEmpty
             ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                      const SizedBox(height: 16),
                      Text('No pending donations', style: tt.titleLarge),
                      const SizedBox(height: 8),
                      Text('All donations are verified', style: tt.bodyMedium),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPending,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingDonations.length,
                    itemBuilder: (ctx, i) {
                      final d = _pendingDonations[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'PKR ${_formatAmount(d['amount'])}',
                                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Chip(
                                    label: const Text('PENDING'),
                                    backgroundColor: Colors.orange[100],
                                    labelStyle: TextStyle(color: Colors.orange[900]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildRow('Campaign', d['campaign_title']),
                              _buildRow('NGO', d['org_name']),
                              _buildRow('Donor', d['donor_name']),
                              _buildRow('Email', d['donor_email']),
                              _buildRow('Phone', d['donor_phone']?? 'N/A'),
                              _buildRow('Ref', d['bank_reference']),
                              _buildRow('Date', _formatDate(d['created_at'])),
                              if (d['donor_note']!= null)
                                _buildRow('Note', d['donor_note']),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.image),
                                      label: const Text('View Proof'),
                                      onPressed: () => _viewProof(d['proof_of_payment_url']),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: FilledButton.icon(
                                      icon: const Icon(Icons.check),
                                      label: const Text('Verify'),
                                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                                      onPressed: () => _verifyDonation(d['id'], true),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.close),
                                      label: const Text('Reject'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      onPressed: () => _verifyDonation(d['id'], false),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value?? 'N/A')),
        ],
      ),
    );
  }

  String _formatAmount(dynamic amount) {
    final amt = double.tryParse(amount.toString())?? 0;
    if (amt >= 1000000) return '${(amt / 1000000).toStringAsFixed(1)}M';
    if (amt >= 1000) return '${(amt / 1000).toStringAsFixed(0)}K';
    return amt.toInt().toString();
  }

  String _formatDate(String iso) {
    final dt = DateTime.parse(iso);
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}