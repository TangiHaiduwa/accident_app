import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertDetailsScreen extends StatelessWidget {
  final String location;
  final String time;
  final String severity;

  const AlertDetailsScreen({
    super.key,
    required this.location,
    required this.time,
    required this.severity,
  });

  Color _getSeverityColor() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🚨 ALERT DETAILS',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Incident Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.car_crash,
                        color: _getSeverityColor(),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.access_time,
                    label: 'Time Reported:',
                    value: time,
                  ),
                  _buildDetailRow(
                    icon: Icons.warning,
                    label: 'Severity:',
                    value: severity,
                    valueColor: _getSeverityColor(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Response Status
            const Text(
              'RESPONSE STATUS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatusItem(
                      icon: Icons.local_police,
                      title: 'Police Notified',
                      status: 'En Route',
                      time: '5 mins ago',
                      color: Colors.blue,
                    ),
                    const Divider(height: 24),
                    _buildStatusItem(
                      icon: Icons.local_hospital,
                      title: 'Medical Response',
                      status: 'Dispatched',
                      time: '3 mins ago',
                      color: Colors.green,
                    ),
                    const Divider(height: 24),
                    _buildStatusItem(
                      icon: Icons.fire_truck,
                      title: 'Fire Department',
                      status: 'Standing By',
                      time: '7 mins ago',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Location Map Preview
            const Text(
              'LOCATION',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/map_placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: FloatingActionButton.small(
                      onPressed: () => _openMaps(location),
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.map, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.call),
                    label: const Text('Call Emergency'),
                    onPressed: () => _callEmergency(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Resolve'),
                    onPressed: () => _markAsResolved(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String status,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Text(time, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      ],
    );
  }

  Future<void> _openMaps(String location) async {
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}',
    );

    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri);
    } else {
      ScaffoldMessenger.of(
        GlobalKey<ScaffoldMessengerState>().currentState!.context,
      ).showSnackBar(const SnackBar(content: Text('Could not launch maps')));
    }
  }

  Future<void> _callEmergency() async {
    final Uri phoneUri = Uri.parse('tel:112');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(
        GlobalKey<ScaffoldMessengerState>().currentState!.context,
      ).showSnackBar(
        const SnackBar(content: Text('Could not launch phone app')),
      );
    }
  }

  void _markAsResolved(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Resolved'),
        content: const Text('Are you sure this incident has been resolved?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Incident marked as resolved'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}
