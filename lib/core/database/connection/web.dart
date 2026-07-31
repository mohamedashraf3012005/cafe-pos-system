import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor constructDb() {
  return WebDatabase('cafe_pos_web');
}
