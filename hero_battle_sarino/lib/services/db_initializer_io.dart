import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializeDatabaseFactory() {
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
