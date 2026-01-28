import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class EmailAnalyticsWidget extends StatefulWidget {
  final String userId;
  final String shopId;

  const EmailAnalyticsWidget({
    super.key,
    required this.userId,
    required this.shopId,
  });

  @override
  State<EmailAnalyticsWidget> createState() => _EmailAnalyticsWidgetState();
}

class _EmailAnalyticsWidgetState extends State<EmailAnalyticsWidget> {
  DateTime selectedDate = DateTime.now();
  EmailAnalyticsData? analyticsData;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final url =
          'https://api.libanbuy.com/api/emails/analytics?start_date=$dateStr&end_date=&aggregated_by=&limit=&offset=';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-request-from': 'Dashboard',
          'user-id': widget.userId,
          'shop-id': widget.shopId,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          analyticsData = EmailAnalyticsData.fromJson(data['analytics']);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load analytics data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      fetchAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (isLoading)
              _buildShimmerContent()
            else if (errorMessage != null)
              _buildErrorWidget()
            else if (analyticsData != null)
              _buildAnalyticsContent()
            else
              const Center(child: Text('No data available')),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 400;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Email Analytics',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: isSmallScreen ? 14 : 16),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                      style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerContent() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          _buildShimmerGrid(),
          const SizedBox(height: 16),
          _buildShimmerEngagementMetrics(),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid based on screen width
        int crossAxisCount = 2;
        if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }
        if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        }

        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: crossAxisCount,
          childAspectRatio: constraints.maxWidth > 600 ? 1.8 : 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: List.generate(6, (index) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(width: 60, height: 20, color: Colors.white),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildShimmerEngagementMetrics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid based on screen width
        int crossAxisCount = 2;
        if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }
        if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        }

        return GridView.count(
          shrinkWrap: true,
          crossAxisCount: crossAxisCount,
          childAspectRatio: constraints.maxWidth > 600 ? 1.8 : 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: List.generate(4, (index) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: double.infinity,
                    height: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(width: 60, height: 20, color: Colors.white),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: fetchAnalytics, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return Column(
      children: [
        _buildMainMetrics(),
        const SizedBox(height: 16),
        _buildEngagementMetrics(),
      ],
    );
  }

  Widget _buildMainMetrics() {
    final metrics = [
      MetricItem('Total Emails', analyticsData!.totalEmails, Colors.blue),
      MetricItem('Delivered', analyticsData!.totalDelivered, Colors.green),
      MetricItem('Opens', analyticsData!.totalOpens, Colors.orange),
      MetricItem('Clicks', analyticsData!.totalClicks, Colors.purple),
      MetricItem('Bounces', analyticsData!.totalBounces, Colors.red),
      MetricItem('Unsubscribes', analyticsData!.totalUnsubscribes, Colors.grey),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid based on screen width
        int crossAxisCount = 2;
        if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }
        if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          childAspectRatio: constraints.maxWidth > 600 ? 1.8 : 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: metrics.map((metric) => _buildMetricCard(metric)).toList(),
        );
      },
    );
  }

  Widget _buildEngagementMetrics() {
    final engagementMetrics = [
      MetricItem(
        'Open Rate',
        '${analyticsData!.engagementMetrics.openRate}%',
        Colors.blue,
      ),
      MetricItem(
        'Click Rate',
        '${analyticsData!.engagementMetrics.clickRate}%',
        Colors.purple,
      ),
      MetricItem(
        'Bounce Rate',
        '${analyticsData!.engagementMetrics.bounceRate}%',
        Colors.red,
      ),
      MetricItem(
        'Unsubscribe Rate',
        '${analyticsData!.engagementMetrics.unsubscribesRate}%',
        Colors.grey,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Engagement Metrics',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid based on screen width
            int crossAxisCount = 2;
            if (constraints.maxWidth > 600) {
              crossAxisCount = 3;
            }
            if (constraints.maxWidth > 900) {
              crossAxisCount = 4;
            }

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              childAspectRatio: constraints.maxWidth > 600 ? 1.8 : 1.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children:
                  engagementMetrics
                      .map((metric) => _buildMetricCard(metric))
                      .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(MetricItem metric) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: metric.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: metric.color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              metric.title,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              metric.value.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: metric.color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class MetricItem {
  final String title;
  final dynamic value;
  final Color color;

  MetricItem(this.title, this.value, this.color);
}

class EmailAnalyticsData {
  final int totalEmails;
  final int totalDelivered;
  final int totalBounces;
  final int totalSpamReports;
  final int totalOpens;
  final int totalClicks;
  final int totalUniqueOpens;
  final int totalUniqueClicks;
  final int totalUnsubscribes;
  final EngagementMetrics engagementMetrics;
  final DetailedMetrics detailedMetrics;

  EmailAnalyticsData({
    required this.totalEmails,
    required this.totalDelivered,
    required this.totalBounces,
    required this.totalSpamReports,
    required this.totalOpens,
    required this.totalClicks,
    required this.totalUniqueOpens,
    required this.totalUniqueClicks,
    required this.totalUnsubscribes,
    required this.engagementMetrics,
    required this.detailedMetrics,
  });

  factory EmailAnalyticsData.fromJson(Map<String, dynamic> json) {
    return EmailAnalyticsData(
      totalEmails: json['total_emails'] ?? 0,
      totalDelivered: json['total_delivered'] ?? 0,
      totalBounces: json['total_bounces'] ?? 0,
      totalSpamReports: json['total_spam_reports'] ?? 0,
      totalOpens: json['total_opens'] ?? 0,
      totalClicks: json['total_clicks'] ?? 0,
      totalUniqueOpens: json['total_unique_opens'] ?? 0,
      totalUniqueClicks: json['total_unique_clicks'] ?? 0,
      totalUnsubscribes: json['total_unsubscribes'] ?? 0,
      engagementMetrics: EngagementMetrics.fromJson(
        json['engagement_metrics'] ?? {},
      ),
      detailedMetrics: DetailedMetrics.fromJson(json['detailed_metrics'] ?? {}),
    );
  }
}

class EngagementMetrics {
  final double openRate;
  final double clickRate;
  final double bounceRate;
  final double unsubscribesRate;

  EngagementMetrics({
    required this.openRate,
    required this.clickRate,
    required this.bounceRate,
    required this.unsubscribesRate,
  });

  factory EngagementMetrics.fromJson(Map<String, dynamic> json) {
    return EngagementMetrics(
      openRate: (json['open_rate'] ?? 0.0).toDouble(),
      clickRate: (json['click_rate'] ?? 0.0).toDouble(),
      bounceRate: (json['bounce_rate'] ?? 0.0).toDouble(),
      unsubscribesRate: (json['unsubscribes_rate'] ?? 0.0).toDouble(),
    );
  }
}

class DetailedMetrics {
  final int processed;
  final int delivered;
  final int bounces;
  final int spamReports;
  final int opens;
  final int clicks;
  final int uniqueOpens;
  final int uniqueClicks;
  final int blocks;
  final int bounceDrops;
  final int deferred;
  final int invalidEmails;
  final int spamReportDrops;
  final int unsubscribeDrops;
  final int unsubscribes;

  DetailedMetrics({
    required this.processed,
    required this.delivered,
    required this.bounces,
    required this.spamReports,
    required this.opens,
    required this.clicks,
    required this.uniqueOpens,
    required this.uniqueClicks,
    required this.blocks,
    required this.bounceDrops,
    required this.deferred,
    required this.invalidEmails,
    required this.spamReportDrops,
    required this.unsubscribeDrops,
    required this.unsubscribes,
  });

  factory DetailedMetrics.fromJson(Map<String, dynamic> json) {
    return DetailedMetrics(
      processed: json['processed'] ?? 0,
      delivered: json['delivered'] ?? 0,
      bounces: json['bounces'] ?? 0,
      spamReports: json['spam_reports'] ?? 0,
      opens: json['opens'] ?? 0,
      clicks: json['clicks'] ?? 0,
      uniqueOpens: json['unique_opens'] ?? 0,
      uniqueClicks: json['unique_clicks'] ?? 0,
      blocks: json['blocks'] ?? 0,
      bounceDrops: json['bounce_drops'] ?? 0,
      deferred: json['deferred'] ?? 0,
      invalidEmails: json['invalid_emails'] ?? 0,
      spamReportDrops: json['spam_report_drops'] ?? 0,
      unsubscribeDrops: json['unsubscribe_drops'] ?? 0,
      unsubscribes: json['unsubscribes'] ?? 0,
    );
  }
}
