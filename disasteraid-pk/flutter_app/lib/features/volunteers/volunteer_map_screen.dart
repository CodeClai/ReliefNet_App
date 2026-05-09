import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:disasteraid_pk/core/api/api_client.dart';
import 'package:disasteraid_pk/features/volunteers/deliver_aid_screen.dart';

class VolunteerMapScreen extends StatefulWidget {
  const VolunteerMapScreen({super.key});
  @override
  State<VolunteerMapScreen> createState() => _VolunteerMapScreenState();
}

class _VolunteerMapScreenState extends State<VolunteerMapScreen> {
  List<Map<String, dynamic>> aidRequests = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAidRequests();
  }

  Future<void> _loadAidRequests() async {
    try {
      final api = ApiClient();
      // You need to create this endpoint: GET /api/aid-requests/map
      final res = await api.dio.get('/aid-requests/map?status=PENDING');
      setState(() {
        aidRequests = List<Map<String, dynamic>>.from(res.data['data']);
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
      appBar: AppBar(title: const Text('Aid Requests Near You')),
      body: loading
         ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(30.3753, 69.3451), // Pakistan
                initialZoom: 6,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.disasteraid.pk',
                ),
                MarkerLayer(
                  markers: aidRequests.map((r) {
                    final lat = r['latitude'] as num?;
                    final lng = r['longitude'] as num?;
                    if (lat == null || lng == null) return null;

                    Color markerColor = r['urgency'] == 'CRITICAL'? Colors.red
                        : r['urgency'] == 'HIGH'? Colors.orange
                        : Colors.blue;

                    return Marker(
                      point: LatLng(lat.toDouble(), lng.toDouble()),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () => _showRequestSheet(r),
                        child: Icon(Icons.location_on, color: markerColor, size: 40),
                      ),
                    );
                  }).whereType<Marker>().toList(),
                ),
              ],
            ),
    );
  }

  void _showRequestSheet(Map<String, dynamic> r) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: r['urgency'] == 'CRITICAL'? Colors.red : Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(r['urgency'], style: const TextStyle(color: Colors.white, fontSize: 11)),
                ),
                const SizedBox(width: 8),
                Text(r['category'], style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text('Beneficiary: ${r['beneficiary_name']}'),
            Text('Family Size: ${r['family_size']}'),
            Text('Address: ${r['address']}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => DeliverAidScreen(
                      aidId: r['id'],
                      victimName: r['beneficiary_name'],
                      location: r['address'],
                    ),
                  ));
                },
                child: const Text('Accept & Deliver'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}