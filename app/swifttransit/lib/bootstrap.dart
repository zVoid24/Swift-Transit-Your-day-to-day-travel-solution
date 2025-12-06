import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/di/app_providers.dart';

Future<void> bootstrap() async {
  runApp(
    MultiProvider(
      providers: AppProviders.providers,
      child: const SwiftTransitApp(),
    ),
  );
}
