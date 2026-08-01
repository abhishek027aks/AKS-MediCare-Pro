import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Plain `sqflite` only ships native database factories for
  // Android / iOS / macOS. On Windows and Linux desktop we need to
  // swap in the FFI-based factory before any openDatabase() call —
  // otherwise every DB call fails with "databaseFactory not
  // initialized". Mobile/macOS keep using the default sqflite
  // factory as normal.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    const ProviderScope(
      child: AKSMediCareProApp(),
    ),
  );
}
