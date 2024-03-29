// import 'dart:developer';
// import 'dart:io';

// import 'package:drift/drift.dart';
// import 'package:drift/native.dart';
// import 'package:drift/wasm.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;
// import 'package:sqlite3/sqlite3.dart';
// import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

// part 'database.g.dart';

// class TransactionItems extends Table {
//   IntColumn get productId => integer()();
//   TextColumn get productName => text()();
//   RealColumn get initialPrice => real()();
//   RealColumn get productPrice => real()();
//   IntColumn get quantity => integer()();
//   TextColumn get unitTag => text().nullable()();
//   TextColumn get image => text().nullable()();
// }

// @DriftDatabase(tables: [TransactionItems])
// class MyDatabase extends _$MyDatabase {
//   MyDatabase() : super(_openConnection());

//   @override
//   int get schemaVersion => 1;
// }

// LazyDatabase _openConnection() {
//   // the LazyDatabase util lets us find the right location for the file async.
//   return LazyDatabase(() async {
//     // put the database file, called db.sqlite here, into the documents folder
//     // for your app.
//     final dbHolder = await getApplicationDocumentsDirectory();
//     final file = File(p.join(dbHolder.path, 'db.sqlite'));

//     // Also work around limitations on old Android versions
//     if (Platform.isAndroid) {
//       log("isAndroid");
//       await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
//     }

//     // Make sqlite3 pick a more suitable location for temporary files - the
//     // one from the system may be inaccessible due to sandboxing.
//     final cachebase = (await getTemporaryDirectory()).path;

//     sqlite3.tempDirectory = cachebase;

//     return NativeDatabase.createInBackground(file);
//   });
// }

// DatabaseConnection connectOnWeb() {
//   return DatabaseConnection.delayed(Future(() async {
//     final result = await WasmDatabase.open(
//       databaseName: 'my_database',
//       sqlite3Uri: Uri.parse('sqlite3.wasm'),
//       driftWorkerUri: Uri.parse('drift_worker.js'),
//     );

//     if (result.missingFeatures.isNotEmpty) {
//       // Depending how central local persistence is to your app, you may want
//       // to show a warning to the user if only unrealiable implemetentations
//       // are available.
//       log('Using ${result.chosenImplementation} due to missing browser '
//           'features: ${result.missingFeatures}');
//     }

//     return result.resolvedExecutor;
//   }));
// }
