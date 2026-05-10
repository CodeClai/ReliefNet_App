import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:disasteraid_pk/core/api/api_client.dart';
import 'package:disasteraid_pk/features/volunteers/deliver_aid_screen.dart';
import '../../../shared/widgets/error_state.dart';

class VolunteerMapScreen extends StatefulWidget {
  const VolunteerMapScreen({super.key});
  @override
  State<VolunteerMapScreen> createState() => _VolunteerMapScreenState();
}

class _VolunteerMapScreenState extends State<VolunteerMapScreen> {
  List<Map<String, dynamic>> _aidRequests = [];
  bool _loading = true;
  String? _error;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadAidRequests();
  }

  Future<void> _loadAidRequests() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ApiClient();
      final res = await api.dio.get('/volunteers/tasks/available');
      if (mounted) {
        setState(() {
          // ApiClient unwraps {success, data} -> returns array
          _aidRequests = List<Map<String, dynamic>>.from(res.data)
           .where((r) => r['latitude']!= null && r['longitude']!= null)
           .toList();
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load map data';
          _loading = false;
        });
      }
    }
  }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.amber[700]!;
      default:
        return Colors.green;
    }
  }

  void _centerOnPakistan() {
    _mapController.move(const LatLng(30.3753, 69.3451), 6);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Map'),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Center map',
            onPressed: _centerOnPakistan,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadAidRequests,
          ),
        ],
      ),
      body: _buildBody(cs),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error!= null) return ErrorState(message: _error!, onRetry: _loadAidRequests);
    if (_aidRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No tasks on map', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Available tasks will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(30.3753, 69.3451), // Pakistan
            initialZoom: 6,
            minZoom: 5,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.disasteraid.pk',
            ),
            MarkerLayer(
              markers: _aidRequests.map((r) {
                final lat = (r['latitude'] as num).toDouble();
                final lng = (r['longitude'] as num).toDouble();
                final color = _urgencyColor(r['urgency']);

                return Marker(
                  point: LatLng(lat, lng),
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () => _showRequestSheet(r),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        // Legend
        Positioned(
          top: 16,
          right: 16,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Urgency', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  _legendItem('Critical', Colors.red),
                  const SizedBox(height: 4),
                  _legendItem('High', Colors.orange),
                  const SizedBox(height: 4),
                  _legendItem('Medium', Colors.amber[700]!),
                  const SizedBox(height: 4),
                  _legendItem('Low', Colors.green),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  void _showRequestSheet(Map<String, dynamic> r) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final urgencyColor = _urgencyColor(r['urgency']);
    final items = (r['items_needed'] as List?)?.join(', ')?? 'Aid';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgencyColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    r['urgency'],
                    style: tt.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r['category'],
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Details
            _detailRow(Icons.person_outline, 'Beneficiary', r['beneficiary_name']),
            const SizedBox(height: 12),
            _detailRow(Icons.people_outline, 'Family Size', '${r['family_size']}'),
            const SizedBox(height: 12),
            _detailRow(Icons.location_on_outlined, 'Address', r['location']?? 'Unknown'),
            const SizedBox(height: 12),
            _detailRow(Icons.inventory_2_outlined, 'Items Needed', items),
            if (r['description']!= null)...[
              const SizedBox(height: 12),
              _detailRow(Icons.notes_outlined, 'Notes', r['description']),
            ],
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeliverAidScreen(
                        aidId: r['id'],
                        victimName: r['beneficiary_name'],
                        location: r['location']?? 'Unknown',
                      ),
                    ),
                  ).then((_) => _loadAidRequests());
                },
                icon: const Icon(Icons.add_task),
                label: const Text('Accept & Deliver'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: cs.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}