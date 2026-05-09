import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:disasteraid_pk/core/api/api_client.dart';

class CampaignMapScreen extends StatefulWidget {
  const CampaignMapScreen({super.key});
  @override
  State<CampaignMapScreen> createState() => _CampaignMapScreenState();
}

class _CampaignMapScreenState extends State<CampaignMapScreen> {
  List<Map<String, dynamic>> campaigns = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    try {
      final api = ApiClient();
      final res = await api.dio.get('/campaigns/map');
      setState(() {
        campaigns = List<Map<String, dynamic>>.from(res.data['data']);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print('Map load error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campaigns Near You')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(30.3753, 69.3451), // Pakistan center
                initialZoom: 6,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.disasteraid.pk',
                ),
                MarkerLayer(
                  markers: campaigns.map((c) {
                    final lat = c['latitude'] as num?;
                    final lng = c['longitude'] as num?;
                    if (lat == null || lng == null) return null;
                    
                    return Marker(
                      point: LatLng(lat.toDouble(), lng.toDouble()),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _showCampaignSheet(c),
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    );
                  }).whereType<Marker>().toList(),
                ),
              ],
            ),
    );
  }

  void _showCampaignSheet(Map<String, dynamic> c) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('By ${c['org_name']}'),
            Text('Raised: PKR ${c['raised_amount']} / ${c['target_amount']}'),
            Text('Category: ${c['category']}'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to campaign detail
              },
              child: const Text('View Campaign'),
            ),
          ],
        ),
      ),
    );
  }
}