import 'package:flutter/material.dart';

import 'package:swifttransit_bus/data/services/api_service.dart';
import 'package:swifttransit_bus/data/services/socket_service.dart';
import 'package:swifttransit_bus/data/storage/route_storage.dart';
import 'package:swifttransit_bus/features/auth/domain/entities/session_data.dart';
import 'package:swifttransit_bus/features/routes/domain/models/route_models.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider({
    required this.apiService,
    required this.storage,
    required this.socketService,
  });

  final ApiService apiService;
  final RouteStorage storage;
  final SocketService socketService;

  SessionData? session;
  BusRoute? route;
  bool isRestoring = true;
  bool isAuthenticating = false;
  String? error;

  Future<void> restoreSession() async {
    isRestoring = true;
    notifyListeners();

    final token = await storage.token;
    final routeId = await storage.routeId;
    final busId = await storage.busId;
    final busCredentialId = await storage.busCredentialId;
    final variant = await storage.variant;
    final registrationNumber = await storage.registrationNumber;
    final cachedRoute = await storage.cachedRoute;

    if (token != null &&
        routeId != null &&
        busId != null &&
        busCredentialId != null &&
        variant != null &&
        cachedRoute != null) {
      session = SessionData(
        token: token,
        routeId: routeId,
        busId: busId,
        busCredentialId: busCredentialId,
        variant: variant,
        registrationNumber: registrationNumber ?? "",
      );
      route = cachedRoute;
    }

    isRestoring = false;
    notifyListeners();
  }

  Future<bool> login({
    required String busId,
    required String password,
    required String variant,
  }) async {
    isAuthenticating = true;
    error = null;
    notifyListeners();

    try {
      final login = await apiService.login(
        busIdentifier: busId,
        password: password,
        variant: variant,
      );

      final fetchedRoute = await apiService.fetchRoute(
        routeId: login.routeId,
        token: login.token,
      );

      await storage.saveAuth(
        token: login.token,
        routeId: login.routeId,
        busId: login.busId,
        busCredentialId: login.busCredentialId,
        variant: login.variant,
        registrationNumber: login.registrationNumber,
      );
      await storage.saveRoute(fetchedRoute);

      session = SessionData(
        token: login.token,
        routeId: login.routeId,
        busId: login.busId,
        busCredentialId: login.busCredentialId,
        variant: login.variant,
        registrationNumber: login.registrationNumber,
      );
      route = fetchedRoute;
      socketService.connect(login.token, login.routeId);

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isAuthenticating = false;
      notifyListeners();
    }
  }

  void updateRoute(BusRoute updatedRoute) {
    route = updatedRoute;
    notifyListeners();
  }

  Future<void> logout() async {
    await storage.clear();
    session = null;
    route = null;
    socketService.dispose();
    notifyListeners();
  }
}
