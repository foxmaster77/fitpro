import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/db_factory_stub.dart'
    if (dart.library.html) 'core/db_factory_web.dart';
import 'core/encryption_service.dart';
import 'core/local_database.dart';
import 'state/app_session.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDatabaseFactory();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final encryption = EncryptionService();
  await encryption.initialize();
  // Open/migrate SQLite lazily from AppSessionController so /boot can render.
  final database = LocalDatabase(encryption);

  runApp(
    ProviderScope(
      overrides: [
        encryptionProvider.overrideWithValue(encryption),
        databaseProvider.overrideWithValue(database),
      ],
      child: const FitproApp(),
    ),
  );
}
