import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../config/app_config.dart';
import '../../data/services/api_service.dart';
import '../../data/services/location_service.dart';
import '../../data/services/socket_service.dart';
import '../../data/storage/route_storage.dart';
import '../../features/auth/application/session_provider.dart';

class AppProviders {
  static List<SingleChildWidget> build() {
    final apiService = ApiService(baseUrl: AppConfig.apiBaseUrl);
    final storage = RouteStorage();
    final locationService = LocationService();
    final socketService = SocketService(url: AppConfig.socketUrl);

    return [
      Provider.value(value: apiService),
      Provider.value(value: storage),
      Provider.value(value: locationService),
      Provider.value(value: socketService),
      ChangeNotifierProvider(
        create: (_) => SessionProvider(
          apiService: apiService,
          storage: storage,
          socketService: socketService,
        ),
      ),
    ];
  }
}
