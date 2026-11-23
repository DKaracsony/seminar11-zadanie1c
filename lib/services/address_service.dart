import 'package:geocoding/geocoding.dart';

class AddressService {
  static final Geocoding _geocoding = Geocoding();

  static Future<String> getAddress(double latitude, double longitude) async {
    final coordinateText =
        '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

    try {
      final results = await _geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (results.isNotEmpty) {
        final place = results.first;
        final parts = [
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ];
        final address = parts
            .whereType<String>()
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty)
            .toSet()
            .join(', ');
        if (address.isNotEmpty) return address;
      }
    } catch (_) {
      
    }
    return 'Coordinates: $coordinateText';
  }
}
