import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/di/app_providers.dart';

void bootstrap() {
  runApp(
    MultiProvider(
      providers: AppProviders.build(),
      child: const SwiftTransitBusApp(),
    ),
  );
}
