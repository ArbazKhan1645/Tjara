import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:tjara/app/services/auth/auth_service.dart';

class ResellerAnalyticsWidget extends StatefulWidget {
  const ResellerAnalyticsWidget({super.key});

  @override
  State<ResellerAnalyticsWidget> createState() =>
      _ResellerAnalyticsWidgetState();
}

class _ResellerAnalyticsWidgetState extends State<ResellerAnalyticsWidget> {
  Map<String, dynamic>? analyticsData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    final url = Uri.parse(
      'https://api.libanbuy.com/api/reseller-program-transactions/analytics',
    );
    try {
      final userid = AuthService.instance.authCustomer?.user?.id;

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-request-from': 'Dashboard',
          'user-id': userid.toString(),
        },
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          analyticsData = json['reseller_program_transaction_analytics'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => isLoading = false);
    }
  }

  Widget buildCard({
    required String title,
    required String value,
    required Color backgroundColor,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: const Color(0xff0D9488)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '\$$value',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShimmerCard() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        height: 80,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(children: [buildShimmerCard(), buildShimmerCard()]),
                Row(children: [buildShimmerCard(), buildShimmerCard()]),
              ],
            ),
          ),
        )
        : analyticsData == null
        ? const Center(child: Text('Failed to load data'))
        : Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                Row(
                  children: [
                    buildCard(
                      title: 'Available Bonus',
                      value:
                          analyticsData!['total_reseller_program_bonus_earnings_available']
                              .toStringAsFixed(2),
                      backgroundColor: Colors.red.shade700,
                    ),
                    buildCard(
                      title: 'Pending Bonus',
                      value:
                          analyticsData!['total_reseller_program_bonus_earnings_pending']
                              .toStringAsFixed(2),
                      backgroundColor: Colors.red.shade700,
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildCard(
                      title: 'Available Commission',
                      value:
                          analyticsData!['total_reseller_program_referral_earnings_available']
                              .toStringAsFixed(2),
                      backgroundColor: Colors.green.shade800,
                    ),
                    buildCard(
                      title: 'Pending Commission',
                      value:
                          analyticsData!['total_reseller_program_referral_earnings_pending']
                              .toStringAsFixed(2),
                      backgroundColor: Colors.green.shade800,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
  }
}
