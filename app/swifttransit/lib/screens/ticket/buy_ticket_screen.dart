import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/dashboard_provider.dart';
import '../../core/colors.dart';

class BuyTicketScreen extends StatefulWidget {
  const BuyTicketScreen({super.key});

  @override
  State<BuyTicketScreen> createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends State<BuyTicketScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  List<String> _departureSuggestions = [];
  List<String> _destinationSuggestions = [];
  bool _showDepartureSuggestions = false;
  bool _showDestinationSuggestions = false;

  @override
  void initState() {
    super.initState();
    // Initialize provider state if needed
  }

  void _onSearchChanged(String query, bool isDeparture) async {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    final suggestions = await provider.searchStops(query);
    setState(() {
      if (isDeparture) {
        _departureSuggestions = suggestions;
        _showDepartureSuggestions = true;
        _showDestinationSuggestions = false;
      } else {
        _destinationSuggestions = suggestions;
        _showDestinationSuggestions = true;
        _showDepartureSuggestions = false;
      }
    });
  }

  void _selectSuggestion(String suggestion, bool isDeparture) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    setState(() {
      if (isDeparture) {
        _departureController.text = suggestion;
        provider.setDeparture(suggestion);
        _showDepartureSuggestions = false;
      } else {
        _destinationController.text = suggestion;
        provider.setDestination(suggestion);
        _showDestinationSuggestions = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(23.8103, 90.4125), // Dhaka
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.swifttransit',
              ),
              PolylineLayer(
                polylines: [
                  if (provider.routePoints.isNotEmpty)
                    Polyline(
                      points: provider.routePoints,
                      strokeWidth: 4.0,
                      color: AppColors.primary,
                    ),
                ],
              ),
              MarkerLayer(markers: provider.markers),
            ],
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Where do you want to go?",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Departure Input
                    _buildInput(
                      controller: _departureController,
                      hint: "From (e.g. Gulistan)",
                      icon: Icons.location_on_outlined,
                      onChanged: (val) => _onSearchChanged(val, true),
                    ),
                    if (_showDepartureSuggestions)
                      _buildSuggestionsList(_departureSuggestions, true),

                    const SizedBox(height: 16),

                    // Destination Input
                    _buildInput(
                      controller: _destinationController,
                      hint: "To (e.g. Savar)",
                      icon: Icons.location_on,
                      onChanged: (val) => _onSearchChanged(val, false),
                    ),
                    if (_showDestinationSuggestions)
                      _buildSuggestionsList(_destinationSuggestions, false),

                    const SizedBox(height: 24),

                    // Search Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          await provider.searchBus();
                          // Zoom to fit route if found
                          if (provider.routePoints.isNotEmpty) {
                            // Simple centering on first point for now
                            _mapController.move(provider.routePoints.first, 13);
                          }
                        },
                        child: Text(
                          "Search Route",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (provider.currentRouteId != null)
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => provider.buyTicket(context),
                          child: Text(
                            "Buy Ticket",
                            style: GoogleFonts.poppins(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(List<String> suggestions, bool isDeparture) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(suggestions[index]),
            onTap: () => _selectSuggestion(suggestions[index], isDeparture),
          );
        },
      ),
    );
  }
}
