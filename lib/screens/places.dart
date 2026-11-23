import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/user_places.dart';
import '../widgets/places_list.dart';
import 'add_place.dart';

class PlacesScreen extends ConsumerStatefulWidget {
  const PlacesScreen({super.key});

  @override
  ConsumerState<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends ConsumerState<PlacesScreen> {
  late final Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = Future.microtask(
      () => ref.read(userPlacesProvider.notifier).loadPlaces(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(userPlacesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        actions: [
          IconButton(
            tooltip: 'Add place',
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddPlaceScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load saved places: ${snapshot.error}'),
              ),
            );
          }
          return PlacesList(places: places);
        },
      ),
    );
  }
}
