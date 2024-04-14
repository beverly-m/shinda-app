import 'dart:io' show File, Platform;

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, getTemporaryDirectory;
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' show sqlite3;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart'
    show applyWorkaroundToOpenSqlite3OnOldAndroidVersions;

DatabaseConnection openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbHolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbHolder.path, 'db.sqlite'));

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;

    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createBackgroundConnection(file);
  }));
}
