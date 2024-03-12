
import 'package:drift/drift.dart';
import 'package:shinda_app/database/table.dart';
import 'package:shinda_app/database/connection/connection.dart' as impl;

part 'database.g.dart';

@DriftDatabase(tables: [TransactionItems])
class MyDatabase extends _$MyDatabase {
  MyDatabase() : super(impl.openConnection());

  @override
  int get schemaVersion => 1;
}
