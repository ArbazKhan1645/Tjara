import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class UserAnalyticsWidget extends StatefulWidget {
  const UserAnalyticsWidget({super.key});

  @override
  State<UserAnalyticsWidget> createState() => _UserAnalyticsWidgetState();
}

class _UserAnalyticsWidgetState extends State<UserAnalyticsWidget> {
  Map<String, dynamic>? analyticsData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    setState(() => isLoading = true);

    final url = Uri.parse('https://api.libanbuy.com/api/users/analytics');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Request-From': 'Application',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          analyticsData = jsonData['analytics'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load analytics');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error: $e');
    }
  }

  Widget buildCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShimmerCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 80,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return isLoading
        ? Column(children: List.generate(4, (_) => buildShimmerCard()))
        : analyticsData == null
        ? const Center(child: Text('Failed to load analytics'))
        : Column(
          children: [
            buildCard(
              'Total Users',
              analyticsData!['total_users'],
              Icons.group,
              theme.primaryColor,
            ),
            buildCard(
              'Admins',
              analyticsData!['total_admins'],
              Icons.admin_panel_settings,
              Colors.red,
            ),
            buildCard(
              'Vendors',
              analyticsData!['total_vendors'],
              Icons.store,
              Colors.orange,
            ),
            buildCard(
              'Customers',
              analyticsData!['total_customers'],
              Icons.person,
              Colors.green,
            ),
          ],
        );
  }
}
