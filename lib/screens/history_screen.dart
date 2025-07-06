import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'alert_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<AlertHistory> _alerts = [
    AlertHistory(
      location: 'Mandume Ndemufayo Ave',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      severity: 'High',
    ),
    AlertHistory(
      location: 'Independence Ave',
      time: DateTime.now().subtract(const Duration(days: 1)),
      severity: 'Medium',
    ),
    AlertHistory(
      location: 'Robert Mugabe Ave',
      time: DateTime.now().subtract(const Duration(days: 2)),
      severity: 'Critical',
    ),
  ];

  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Critical',
    'High',
    'Medium',
    'Low',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredAlerts = _selectedFilter == 'All'
        ? _alerts
        : _alerts.where((alert) => alert.severity == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📜 ALERT HISTORY',
          style: TextStyle(letterSpacing: 1.2),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade900, Colors.redAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredAlerts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final alert = filteredAlerts[index];
                return _buildAlertCard(context, alert);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: _filterOptions.map((option) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(option),
              selected: _selectedFilter == option,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? option : 'All';
                });
              },
              selectedColor: _getSeverityColor(option),
              labelStyle: TextStyle(
                color: _selectedFilter == option ? Colors.white : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, AlertHistory alert) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlertDetailsScreen(
                location: alert.location,
                time: DateFormat('MMM d, y - h:mm a').format(alert.time),
                severity: alert.severity,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(alert.severity).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.car_crash,
                      color: _getSeverityColor(alert.severity),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.location,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, y - h:mm a').format(alert.time),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [_buildDetailItem(Icons.warning, alert.severity)],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class AlertHistory {
  final String location;
  final DateTime time;
  final String severity;

  AlertHistory({
    required this.location,
    required this.time,
    required this.severity,
  });
}
