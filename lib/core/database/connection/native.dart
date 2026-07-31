import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

QueryExecutor constructDb() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'cafe_pos', 'db.sqlite'));
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    return NativeDatabase.createInBackground(file);
  });
}
