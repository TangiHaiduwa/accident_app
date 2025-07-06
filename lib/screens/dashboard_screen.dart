import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'map_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'alert_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _emergencyMode = false;

  final List<Widget> _pages = [
    const _DashboardHome(),
    const MapScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButton: _emergencyMode
          ? _EmergencyFloatingPanel(
              onCancel: () => setState(() => _emergencyMode = false),
            )
          : FloatingActionButton(
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.warning, size: 28),
              onPressed: () => setState(() => _emergencyMode = true),
            ).animate().shake(delay: 2.seconds),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: AnimatedSwitcher(duration: 300.ms, child: _pages[_selectedIndex]),
      bottomNavigationBar: _GlassNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🚨 CRITICAL ALERTS",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _CriticalAlertCard(
                      location: "Independence Ave",
                      time: "JUST NOW",
                      severity: "HIGH IMPACT",
                      vehicles: 3,
                      injuries: 2,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AlertDetailsScreen(
                              location: "Independence Ave",
                              time: "JUST NOW",
                              severity: "HIGH IMPACT",
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _StatCard(
                    icon: _stats[index].icon,
                    value: _stats[index].value,
                    label: _stats[index].label,
                    color: _stats[index].color,
                  ),
                  childCount: _stats.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AlertTimelineItem(
                      alert: _recentAlerts[index],
                      isFirst: index == 0,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlertDetailsScreen(
                              location: _recentAlerts[index].location,
                              time: _recentAlerts[index].time,
                              severity: index == 0 ? "HIGH" : "MODERATE",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  childCount: _recentAlerts.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyFloatingPanel extends StatelessWidget {
  final VoidCallback onCancel;

  const _EmergencyFloatingPanel({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Colors.red.shade900, Colors.redAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emergency, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          const Text(
            "EMERGENCY MODE ACTIVATED",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Dispatch emergency services to your location?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onCancel,
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    onCancel();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Emergency services dispatched!"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                  child: const Text("Dispatch Now"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassNavigationBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.5),
            selectedLabelStyle: const TextStyle(fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: "Dashboard",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_rounded),
                label: "Live Map",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                label: "History",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded),
                label: "Settings",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CriticalAlertCard extends StatelessWidget {
  final String location;
  final String time;
  final String severity;
  final int vehicles;
  final int injuries;
  final VoidCallback onTap;

  const _CriticalAlertCard({
    required this.location,
    required this.time,
    required this.severity,
    required this.vehicles,
    required this.injuries,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.red.shade800, Colors.red.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    severity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  time,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              location,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _AlertMetric(
                  icon: Icons.directions_car,
                  value: "$vehicles",
                  label: "Vehicles",
                ),
                const SizedBox(width: 20),
                _AlertMetric(
                  icon: Icons.medical_services,
                  value: "$injuries",
                  label: "Injuries",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _AlertMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white.withOpacity(0.8)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AlertTimelineItem extends StatelessWidget {
  final AlertItem alert;
  final bool isFirst;
  final VoidCallback onTap;

  const _AlertTimelineItem({
    required this.alert,
    required this.isFirst,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFirst ? Colors.redAccent : Colors.blueAccent,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isFirst ? Icons.warning : Icons.notifications,
                  size: 12,
                  color: Colors.white,
                ),
              ),
              if (!isFirst)
                Container(
                  width: 2,
                  height: 50,
                  margin: const EdgeInsets.only(top: 4),
                  color: Colors.white.withOpacity(0.2),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        alert.location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        alert.time,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    alert.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class AlertItem {
  final String location;
  final String time;
  final String description;

  AlertItem({
    required this.location,
    required this.time,
    required this.description,
  });
}

class StatItem {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
}

final List<StatItem> _stats = [
  StatItem(
    icon: Icons.warning_amber_rounded,
    value: "5",
    label: "Active Alerts",
    color: Colors.redAccent,
  ),
  StatItem(
    icon: Icons.timelapse_rounded,
    value: "2.4 min",
    label: "Avg Response",
    color: Colors.blueAccent,
  ),
  StatItem(
    icon: Icons.local_hospital_rounded,
    value: "3",
    label: "Hospitals Nearby",
    color: Colors.greenAccent,
  ),
  StatItem(
    icon: Icons.people_alt_rounded,
    value: "12",
    label: "Responders Active",
    color: Colors.amber,
  ),
];

final List<AlertItem> _recentAlerts = [
  AlertItem(
    location: "Independence Ave",
    time: "1 min ago",
    description: "2 vehicle collision with injuries reported",
  ),
  AlertItem(
    location: "Mandume Ndemufayo Rd",
    time: "17 mins ago",
    description: "Single vehicle rollover",
  ),
  AlertItem(
    location: "Western Bypass",
    time: "42 mins ago",
    description: "Multi-car pileup, heavy traffic",
  ),
  AlertItem(
    location: "Sam Nujoma Drive",
    time: "1.5 hrs ago",
    description: "Pedestrian incident",
  ),
];
