import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/place.dart';
import '../services/place_database.dart';

class UserPlacesNotifier extends Notifier<List<Place>> {
  Future<void>? _loadingFuture;

  @override
  List<Place> build() => [];

  Future<void> loadPlaces() {
    return _loadingFuture ??= _loadPlacesFromDatabase();
  }

  Future<void> _loadPlacesFromDatabase() async {
    state = await PlaceDatabase.loadPlaces();
  }

  Future<void> addPlace(
    String title,
    File selectedImage,
    PlaceLocation location,
  ) async {
    await loadPlaces();
    final newPlace = Place(
      title: title.trim(),
      image: selectedImage,
      location: location,
    );

    final savedImage = await PlaceDatabase.copyImageToAppDirectory(
      selectedImage,
      newPlace.id,
    );
    final persistedPlace = Place(
      id: newPlace.id,
      title: newPlace.title,
      image: savedImage,
      location: location,
    );

    try {
      await PlaceDatabase.savePlace(persistedPlace);
    } catch (_) {
      if (await savedImage.exists()) {
        await savedImage.delete();
      }
      rethrow;
    }

    state = [persistedPlace, ...state];
  }
}

final userPlacesProvider = NotifierProvider<UserPlacesNotifier, List<Place>>(
  UserPlacesNotifier.new,
);
