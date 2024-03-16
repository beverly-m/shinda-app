import 'package:drift/drift.dart';

class TransactionItems extends Table {
  IntColumn get productId => integer()();
  TextColumn get productName => text()();
  RealColumn get initialPrice => real()();
  RealColumn get productPrice => real()();
  IntColumn get quantity => integer()();
  IntColumn get quantityAvailable => integer()();
  TextColumn get unitTag => text().nullable()();
  TextColumn get image => text().nullable()();
}
