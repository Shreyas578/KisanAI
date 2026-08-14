import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'drift_database.g.dart';

// Tables definition
class OfflineActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get endpoint => text()();
  TextColumn get payload => text()(); // JSON string
  TextColumn get method => text().withDefault(const Constant('POST'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class CropCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get details => text()(); // JSON string
  @override
  Set<Column> get primaryKey => {id};
}

class WeatherCache extends Table {
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get data => text()(); // JSON string
  @override
  Set<Column> get primaryKey => {date};
}

@DriftDatabase(tables: [OfflineActions, CropCache, WeatherCache])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kisan_ai.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
