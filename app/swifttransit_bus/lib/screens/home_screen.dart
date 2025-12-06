import 'dart:async';

import 'package:flutter/material.dart';
import 'package:swifttransit_bus/main.dart';
import 'package:swifttransit_bus/models/route_models.dart';
import 'package:swifttransit_bus/screens/ticket_scan_screen.dart';
import 'package:swifttransit_bus/screens/login_screen.dart';
import 'package:swifttransit_bus/services/api_service.dart';
import 'package:swifttransit_bus/services/location_service.dart';
import 'package:swifttransit_bus/services/route_storage.dart';
import 'package:swifttransit_bus/services/socket_service.dart';
import 'package:swifttransit_bus/utils/route_resolver.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.apiService,
    required this.session,
    required this.route,
    required this.storage,
    required this.locationService,
    required this.socketService,
  });

  final ApiService apiService;
  final SessionData session;
  final BusRoute route;
  final RouteStorage storage;
  final LocationService locationService;
  final SocketService socketService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late RouteResolver _resolver;
  StreamSubscription<LatLng>? _locationSubscription;
  LatLng? _lastPosition;
  RouteStop? _currentStop;
  RouteStop? _selectedStop;
  bool _tracking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolver = RouteResolver(route: widget.route);
    widget.socketService.connect(widget.session.token, widget.session.routeId);
    _startTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    widget.socketService.dispose();
    super.dispose();
  }

  void _startTracking() {
    _locationSubscription = widget.locationService.positionStream().listen(
      (position) {
        setState(() {
          _lastPosition = position;
          _currentStop = _resolver.resolveCurrentStop(position);
          if (_selectedStop != null &&
              _currentStop?.name == _selectedStop?.name) {
            _selectedStop = null;
          }
          _tracking = true;
          _error = null;
        });
        widget.socketService.sendPosition(
          token: widget.session.token,
          position: position,
          routeId: widget.session.routeId,
          busCredentialId: widget.session.busCredentialId,
        );
      },
      onError: (err) {
        setState(() {
          _error = err.toString();
          _tracking = false;
        });
      },
    );
  }

  void _setManualStop(RouteStop stop) {
    _resolver.setCurrentStop(stop, lockToStop: true);
    setState(() {
      _currentStop = stop;
      _selectedStop = stop;
      _error = null;
    });
  }

  Future<void> _handleStopTap(RouteStop stop) async {
    try {
      final position =
          _lastPosition ?? await widget.locationService.currentPosition();
      _lastPosition = position;
      final isInside = stop.contains(position);
      if (isInside) {
        _setManualStop(stop);
        return;
      }

      final confirmed =
          await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Confirm stoppage'),
              content: Text(
                'You do not appear to be inside ${stop.name}. Are you currently at this stoppage?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('No'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Yes, update'),
                ),
              ],
            ),
          ) ??
          false;

      if (confirmed) {
        _setManualStop(stop);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _refreshRoute() async {
    try {
      final freshRoute = await widget.apiService.fetchRoute(
        routeId: widget.session.routeId,
        token: widget.session.token,
      );
      await widget.storage.saveRoute(freshRoute);
      setState(() {
        _resolver = RouteResolver(route: freshRoute);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.storage.clear();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => LoginScreen(
              apiService: widget.apiService,
              storage: widget.storage,
              locationService: widget.locationService,
              socketService: widget.socketService,
            ),
          ),
          (route) => false,
        );
      }
    }
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TicketScanScreen(
          apiService: widget.apiService,
          session: widget.session,
          currentStop:
              _currentStop ??
              const RouteStop(name: 'Unknown', order: 0, polygon: []),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 80,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Swift Transit',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF258BA1),
              ),
            ),
            Text(
              '${widget.route.name} (${widget.session.variant.toUpperCase()})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refreshRoute,
            icon: const Icon(Icons.refresh, size: 28),
            tooltip: 'Refresh route',
            color: Colors.grey[700],
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, size: 28, color: Colors.red),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: _openScanner,
          backgroundColor: const Color(0xFF258BA1),
          elevation: 4,
          child: const Icon(
            Icons.qr_code_scanner,
            size: 36,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _tracking
                          ? [Colors.green[400]!, Colors.green[600]!]
                          : [Colors.orange[400]!, Colors.orange[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (_tracking ? Colors.green : Colors.orange)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _tracking ? Icons.gps_fixed : Icons.gps_off,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _tracking ? 'Tracking Active' : 'Tracking Idle',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bus: ${widget.session.busId}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Current Stop
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF258BA1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF258BA1),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Stoppage',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _currentStop?.name ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[100]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              children: [
                Text(
                  'Route Stoppages',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.route.stops.length} Stops',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.route.stops.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No stops found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.route.stops.length,
                    itemBuilder: (_, index) {
                      final stop = widget.route.stops[index];
                      final isCurrent = stop.name == _currentStop?.name;
                      final isSelected = stop.name == _selectedStop?.name;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFF258BA1)
                              : (isSelected ? Colors.blue[50] : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: isSelected
                              ? Border.all(
                                  color: const Color(0xFF258BA1),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _handleStopTap(stop),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isCurrent
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.grey[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        stop.order.toString(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isCurrent
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      stop.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrent
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isCurrent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'HERE',
                                        style: TextStyle(
                                          color: Color(0xFF258BA1),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
