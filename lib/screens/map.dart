import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.initialLocation, this.isSelecting = true});

  final LatLng? initialLocation;
  final bool isSelecting;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.initialLocation ?? const LatLng(48.7363, 19.1462);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelecting ? 'Select Location' : 'Place on Map'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: widget.initialLocation == null ? 12 : 16,
          onTap: (tapPosition, point) {
            if (!widget.isSelecting) return;
            setState(() => _selectedLocation = point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.favorite_places_app',
          ),
          if (_selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedLocation!,
                  width: 50,
                  height: 50,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 46,
                  ),
                ),
              ],
            ),
          const SimpleAttributionWidget(
            source: Text('OpenStreetMap contributors'),
          ),
        ],
      ),
      bottomNavigationBar: widget.isSelecting
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: _selectedLocation == null
                      ? null
                      : () => Navigator.of(context).pop(_selectedLocation),
                  icon: const Icon(Icons.check),
                  label: const Text('Use This Location'),
                ),
              ),
            )
          : null,
    );
  }
}
