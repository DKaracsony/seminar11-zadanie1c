import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/place.dart';

class PlaceDatabase {
  static Future<Database>? _databaseFuture;

  static Future<Database> get database => _databaseFuture ??= _openDatabase();

  static Future<Database> _openDatabase() async {
    final dbFolder = await getDatabasesPath();
    final dbPath = path.join(dbFolder, 'favorite_places.db');

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE places (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            image_path TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            address TEXT NOT NULL
          )
        """);
      },
    );
  }

  static Future<List<Place>> loadPlaces() async {
    final db = await database;
    final rows = await db.query('places', orderBy: 'rowid DESC');

    return rows.map((row) {
      return Place(
        id: row['id'] as String,
        title: row['title'] as String,
        image: File(row['image_path'] as String),
        location: PlaceLocation(
          latitude: (row['latitude'] as num).toDouble(),
          longitude: (row['longitude'] as num).toDouble(),
          address: row['address'] as String,
        ),
      );
    }).toList();
  }

  static Future<void> savePlace(Place place) async {
    final db = await database;
    await db.insert('places', {
      'id': place.id,
      'title': place.title,
      'image_path': place.image.path,
      'latitude': place.location.latitude,
      'longitude': place.location.longitude,
      'address': place.location.address,
    });
  }

  static Future<File> copyImageToAppDirectory(File source, String id) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory(path.join(appDir.path, 'place_images'));
    await imageDir.create(recursive: true);

    final extension = path.extension(source.path).toLowerCase();
    final safeExtension =
        ['.jpg', '.jpeg', '.png', '.webp', '.heic'].contains(extension)
        ? extension
        : '.jpg';
    final destination = path.join(imageDir.path, '$id$safeExtension');
    return source.copy(destination);
  }
}
