import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final Random _random = Random();
  final List<AccidentMarker> _accidents = [
    AccidentMarker(
      location: LatLng(-22.5633, 17.0758),
      title: "Independence Ave Collision",
      severity: "High",
      time: "5 mins ago",
      vehicles: 2,
      injuries: 1,
    ),
    AccidentMarker(
      location: LatLng(-22.5472, 17.0789),
      title: "Mandume Rd Rollover",
      severity: "Medium",
      time: "17 mins ago",
      vehicles: 1,
      injuries: 0,
    ),
  ];

  bool _showHeatmap = false;
  bool _showTraffic = true;
  bool _showEmergencyRoutes = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '🚨 LIVE ACCIDENT MAP',
          style: TextStyle(letterSpacing: 1.2),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade900, Colors.redAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(LatLng(-22.5609, 17.0658), 13.0);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(-22.5609, 17.0658),
              initialZoom: 13.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.accident_alert_app',
              ),
              if (_showTraffic)
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=YOUR_API_KEY",
                  subdomains: const ['a', 'b', 'c'],
                ),
              if (_showHeatmap)
                CircleLayer(
                  circles: _accidents
                      .map(
                        (accident) => CircleMarker(
                          point: accident.location,
                          color: _getSeverityColor(
                            accident.severity,
                          ).withOpacity(0.5),
                          borderColor: _getSeverityColor(accident.severity),
                          borderStrokeWidth: 2,
                          radius: accident.vehicles * 10.0,
                        ),
                      )
                      .toList(),
                ),
              MarkerLayer(
                markers: _accidents
                    .map((accident) => _buildAccidentMarker(accident))
                    .toList(),
              ),
              if (_showEmergencyRoutes)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        LatLng(-22.5609, 17.0658),
                        _accidents[0].location,
                      ],
                      color: Colors.red.withOpacity(0.7),
                      strokeWidth: 4,
                      strokeCap: StrokeCap.round,
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                _MapControlButton(
                  icon: Icons.emergency,
                  color: Colors.red,
                  onPressed: () => _showEmergencyRoutesDialog(context),
                ).animate().shake(delay: 5.seconds),
                const SizedBox(height: 10),
                _MapControlButton(
                  icon: Icons.thermostat,
                  color: _showHeatmap ? Colors.orange : Colors.grey,
                  onPressed: () => setState(() => _showHeatmap = !_showHeatmap),
                ),
                const SizedBox(height: 10),
                _MapControlButton(
                  icon: Icons.traffic,
                  color: _showTraffic ? Colors.blue : Colors.grey,
                  onPressed: () => setState(() => _showTraffic = !_showTraffic),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: _AccidentSummaryCard(accidents: _accidents),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.refresh),
        onPressed: () => _refreshMapData(),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case "critical":
        return Colors.red;
      case "high":
        return Colors.orange;
      case "medium":
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  Marker _buildAccidentMarker(AccidentMarker accident) {
    return Marker(
      width: 80.0,
      height: 80.0,
      point: accident.location,
      child: GestureDetector(
        onTap: () => _showAccidentDetails(context, accident),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.car_crash,
              color: _getSeverityColor(accident.severity),
              size: 36,
            ),
            if (accident.vehicles > 1)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${accident.vehicles}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAccidentDetails(BuildContext context, AccidentMarker accident) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.car_crash,
                  color: _getSeverityColor(accident.severity),
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  accident.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _DetailRow(
              icon: Icons.access_time,
              label: "Time:",
              value: accident.time,
            ),
            _DetailRow(
              icon: Icons.directions_car,
              label: "Vehicles:",
              value: "${accident.vehicles}",
            ),
            _DetailRow(
              icon: Icons.medical_services,
              label: "Injuries:",
              value: "${accident.injuries}",
            ),
            _DetailRow(
              icon: Icons.warning,
              label: "Severity:",
              value: accident.severity,
              valueColor: _getSeverityColor(accident.severity),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _mapController.move(accident.location, 15.0);
                },
                child: const Text("ZOOM TO LOCATION"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyRoutesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Emergency Routes",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Display optimal routes for emergency services to reach accident locations",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() => _showEmergencyRoutes = true);
              Navigator.pop(context);
            },
            child: const Text("Show Routes"),
          ),
        ],
      ),
    );
  }

  void _refreshMapData() {
    setState(() {
      _accidents.add(
        AccidentMarker(
          location: LatLng(
            -22.5609 + (0.01 * (_random.nextDouble() - 0.5)),
            17.0658 + (0.01 * (_random.nextDouble() - 0.5)),
          ),
          title: "New Incident",
          severity: ["Low", "Medium", "High"][_random.nextInt(3)],
          time: "Just now",
          vehicles: _random.nextInt(3) + 1,
          injuries: _random.nextInt(2),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Map data refreshed"),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _MapControlButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      mini: true,
      backgroundColor: Colors.black.withOpacity(0.7),
      onPressed: onPressed,
      child: Icon(icon, color: color),
    );
  }
}

class _AccidentSummaryCard extends StatelessWidget {
  final List<AccidentMarker> accidents;

  const _AccidentSummaryCard({required this.accidents});

  @override
  Widget build(BuildContext context) {
    final criticalCount = accidents
        .where((a) => a.severity == "Critical")
        .length;
    final highCount = accidents.where((a) => a.severity == "High").length;
    final totalInjuries = accidents.fold(0, (sum, a) => sum + a.injuries);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ACTIVE INCIDENTS",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${accidents.length}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _StatIndicator(
            color: Colors.red,
            label: "Critical:",
            value: "$criticalCount",
          ),
          _StatIndicator(
            color: Colors.orange,
            label: "High:",
            value: "$highCount",
          ),
          _StatIndicator(
            color: Colors.amber,
            label: "Injuries:",
            value: "$totalInjuries",
          ),
        ],
      ),
    );
  }
}

class _StatIndicator extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _StatIndicator({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white70),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AccidentMarker {
  final LatLng location;
  final String title;
  final String severity;
  final String time;
  final int vehicles;
  final int injuries;

  AccidentMarker({
    required this.location,
    required this.title,
    required this.severity,
    required this.time,
    required this.vehicles,
    required this.injuries,
  });
}
