import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/auth/application/auth_provider.dart';
import '../../features/dashboard/application/dashboard_provider.dart';

class AppProviders {
  static List<SingleChildWidget> get providers => [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(initialBalance: 0.0, initialPoints: 0),
        ),
      ];
}
