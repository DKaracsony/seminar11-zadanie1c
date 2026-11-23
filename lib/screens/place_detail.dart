import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';
import '../widgets/map_preview.dart';
import 'map.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final coordinates = LatLng(
      place.location.latitude,
      place.location.longitude,
    );

    return Scaffold(
      appBar: AppBar(title: Text(place.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 300,
              child: Image.file(place.image, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          place.location.address,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GPS: ${place.location.latitude.toStringAsFixed(6)}, '
                    '${place.location.longitude.toStringAsFixed(6)}',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: MapPreview(
                      latitude: place.location.latitude,
                      longitude: place.location.longitude,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MapScreen(
                            initialLocation: coordinates,
                            isSelecting: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Tap the map to view it full screen.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
