import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../models/place.dart';
import '../screens/map.dart';
import '../services/address_service.dart';
import 'map_preview.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectLocation});

  final void Function(PlaceLocation location) onSelectLocation;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _selectedLocation;
  bool _isLoading = false;

  Future<void> _saveCoordinates(double latitude, double longitude) async {
    setState(() => _isLoading = true);
    try {
      final address = await AddressService.getAddress(latitude, longitude);
      if (!mounted) return;
      final location = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      setState(() => _selectedLocation = location);
      widget.onSelectLocation(location);
    } catch (error) {
      _showError('Could not save location: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final gps = Location();
      var serviceEnabled = await gps.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await gps.requestService();
        if (!serviceEnabled) throw Exception('Location services are disabled.');
      }

      var permission = await gps.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await gps.requestPermission();
      }
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.grantedLimited) {
        throw Exception('Location permission was not granted.');
      }

      final coordinates = await gps.getLocation();

      if (!mounted) return;

      await _saveCoordinates(coordinates.latitude, coordinates.longitude);
    } catch (error) {
      _showError('Could not get GPS location: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectOnMap() async {
    if (_isLoading) return;
    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => MapScreen(
          initialLocation: _selectedLocation == null
              ? null
              : LatLng(
                  _selectedLocation!.latitude,
                  _selectedLocation!.longitude,
                ),
          isSelecting: true,
        ),
      ),
    );
    if (picked == null || !mounted) return;
    await _saveCoordinates(picked.latitude, picked.longitude);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedLocation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 170,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : selected == null
              ? Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('No location chosen.'),
                )
              : MapPreview(
                  latitude: selected.latitude,
                  longitude: selected.longitude,
                  onTap: _selectOnMap,
                ),
        ),
        const SizedBox(height: 8),
        if (selected != null)
          Text(
            '${selected.address}\n'
            '${selected.latitude.toStringAsFixed(5)}, '
            '${selected.longitude.toStringAsFixed(5)}',
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: _isLoading ? null : _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
            ),
            TextButton.icon(
              onPressed: _isLoading ? null : _selectOnMap,
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
            ),
          ],
        ),
      ],
    );
  }
}
