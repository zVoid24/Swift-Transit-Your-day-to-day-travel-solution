import 'package:flutter/material.dart';

import 'package:swifttransit/core/colors.dart';

import 'routes/app_routes.dart';

class SwiftTransitApp extends StatelessWidget {
  const SwiftTransitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swift Transit',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      initialRoute: AppRoutes.root,
      routes: AppRoutes.routes,
    );
  }
}
