import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_flash_deals_analytics/controller/flash_deal_analytics_controller.dart';
import 'package:tjara/app/modules/admin_products_config_module/admin_flash_deals_analytics/model/flash_deal_analytics_model.dart';
import 'package:tjara/app/modules/modules_admin/add_product_admin/widgets/admin_ui_components.dart';

class AnalyticsCharts extends GetView<FlashDealAnalyticsController> {
  const AnalyticsCharts({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingAnalytics.value) {
        return const AdminShimmer(width: double.infinity, height: 300);
      }

      final data = controller.analytics.value;
      if (data == null) return const SizedBox.shrink();

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPerformanceChart(data),
          const SizedBox(height: 16),
          _buildStatusDistributionChart(data),
          const SizedBox(height: 16),
          _buildTopShopsChart(data),
          const SizedBox(height: 16),
          _buildHourlyChart(data),
        ],
      );
    });
  }

  /// 1. Deals Performance Over Time — Line Chart
  Widget _buildPerformanceChart(OverallAnalyticsResponse data) {
    if (data.dealsOverTime.isEmpty) {
      return _chartCard(
        'Deals Performance Over Time',
        Icons.show_chart,
        _buildEmptyChart('No performance data available'),
      );
    }

    final spots = data.dealsOverTime;

    return _chartCard(
      'Deals Performance Over Time',
      Icons.show_chart,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendRow([
            _LegendItem('Total Deals', AdminTheme.primaryColor),
            _LegendItem('Purchased', AdminTheme.successColor),
            _LegendItem('Skipped', AdminTheme.warningColor),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateInterval(
                    spots
                        .map((e) => e.deals.toDouble())
                        .reduce((a, b) => a > b ? a : b),
                  ),
                  getDrawingHorizontalLine:
                      (value) => const FlLine(
                        color: AdminTheme.borderColor,
                        strokeWidth: 1,
                      ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget:
                          (value, meta) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: AdminTheme.textMuted,
                              fontSize: 10,
                            ),
                          ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: (spots.length / 5).ceilToDouble().clamp(
                        1,
                        double.infinity,
                      ),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= spots.length) {
                          return const SizedBox.shrink();
                        }
                        final date = spots[index].date;
                        final short =
                            date.length >= 5 ? date.substring(5) : date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            short,
                            style: const TextStyle(
                              color: AdminTheme.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _lineBarData(
                    spots
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(
                            e.key.toDouble(),
                            e.value.deals.toDouble(),
                          ),
                        )
                        .toList(),
                    AdminTheme.primaryColor,
                  ),
                  _lineBarData(
                    spots
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(
                            e.key.toDouble(),
                            e.value.purchased.toDouble(),
                          ),
                        )
                        .toList(),
                    AdminTheme.successColor,
                  ),
                  _lineBarData(
                    spots
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(
                            e.key.toDouble(),
                            e.value.skipped.toDouble(),
                          ),
                        )
                        .toList(),
                    AdminTheme.warningColor,
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final colors = [
                          AdminTheme.primaryColor,
                          AdminTheme.successColor,
                          AdminTheme.warningColor,
                        ];
                        final labels = ['Deals', 'Purchased', 'Skipped'];
                        return LineTooltipItem(
                          '${labels[spot.barIndex]}: ${spot.y.toInt()}',
                          TextStyle(
                            color: colors[spot.barIndex],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Status Distribution — Donut/Pie Chart
  Widget _buildStatusDistributionChart(OverallAnalyticsResponse data) {
    final breakdown = data.statusBreakdown;
    if (breakdown.total == 0) {
      return _chartCard(
        'Status Distribution',
        Icons.donut_large,
        _buildEmptyChart('No status data available'),
      );
    }

    final sections = <PieChartSectionData>[];
    final legends = <_LegendItem>[];

    void addSection(String label, int value, Color color) {
      if (value > 0) {
        final percentage = (value / breakdown.total * 100);
        sections.add(
          PieChartSectionData(
            value: value.toDouble(),
            color: color,
            title: '${percentage.toStringAsFixed(0)}%',
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            radius: 50,
          ),
        );
        legends.add(_LegendItem('$label ($value)', color));
      }
    }

    addSection('Purchased', breakdown.purchased, AdminTheme.successColor);
    addSection('Skipped', breakdown.skipped, AdminTheme.warningColor);
    addSection('Expired', breakdown.expired, AdminTheme.errorColor);
    addSection('Active', breakdown.active, AdminTheme.primaryColor);

    return _chartCard(
      'Status Distribution',
      Icons.donut_large,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 45,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(enabled: true),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildLegendRow(legends),
        ],
      ),
    );
  }

  /// 3. Top Performing Shops — Horizontal Bar Chart
  Widget _buildTopShopsChart(OverallAnalyticsResponse data) {
    if (data.topShops.isEmpty) {
      return _chartCard(
        'Top Performing Shops',
        Icons.store,
        _buildEmptyChart('No shop data available'),
      );
    }

    final shops = data.topShops.take(5).toList();
    final maxDeals =
        shops
            .map((s) => s.totalDeals)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

    return _chartCard(
      'Top Performing Shops',
      Icons.store,
      SizedBox(
        height: shops.length * 52.0 + 20,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxDeals * 1.2,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${shops[group.x].shopName}\n${rod.toY.toInt()} deals',
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 80,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= shops.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        shops[index].shopName.length > 12
                            ? '${shops[index].shopName.substring(0, 12)}...'
                            : shops[index].shopName,
                        style: const TextStyle(
                          color: AdminTheme.textSecondary,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: false,
              getDrawingVerticalLine:
                  (value) => const FlLine(
                    color: AdminTheme.borderColor,
                    strokeWidth: 1,
                  ),
            ),
            barGroups:
                shops.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.totalDeals.toDouble(),
                        color: _shopBarColor(entry.key),
                        width: 18,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  /// 4. Deals by Hour of Day — Line Chart
  Widget _buildHourlyChart(OverallAnalyticsResponse data) {
    if (data.hourlyDistribution.isEmpty) {
      return _chartCard(
        'Deals by Hour of Day',
        Icons.access_time,
        _buildEmptyChart('No hourly data available'),
      );
    }

    final hourly = data.hourlyDistribution;
    final maxCount =
        hourly.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();

    return _chartCard(
      'Deals by Hour of Day',
      Icons.access_time,
      SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _calculateInterval(maxCount),
              getDrawingHorizontalLine:
                  (value) => const FlLine(
                    color: AdminTheme.borderColor,
                    strokeWidth: 1,
                  ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 35,
                  getTitlesWidget:
                      (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: AdminTheme.textMuted,
                          fontSize: 10,
                        ),
                      ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 4,
                  getTitlesWidget: (value, meta) {
                    final hour = value.toInt();
                    if (hour < 0 || hour > 23 || hour % 4 != 0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: const TextStyle(
                          color: AdminTheme.textMuted,
                          fontSize: 9,
                        ),
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              _lineBarData(
                hourly
                    .map((e) => FlSpot(e.hour.toDouble(), e.count.toDouble()))
                    .toList(),
                AdminTheme.accentColor,
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.x.toInt()}:00 — ${spot.y.toInt()} deals',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ───

  Widget _chartCard(String title, IconData icon, Widget child) {
    return AdminCard(title: title, icon: icon, child: child);
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bar_chart, size: 40, color: AdminTheme.borderColor),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: AdminTheme.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(List<_LegendItem> items) {
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children:
          items
              .map(
                (item) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: AdminTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
    );
  }

  LineChartBarData _lineBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2.5,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }

  double _calculateInterval(double maxValue) {
    if (maxValue <= 5) return 1;
    if (maxValue <= 20) return 5;
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 25;
    return (maxValue / 4).ceilToDouble();
  }

  Color _shopBarColor(int index) {
    const colors = [
      AdminTheme.primaryColor,
      AdminTheme.successColor,
      AdminTheme.accentColor,
      AdminTheme.warningColor,
      AdminTheme.primaryLight,
    ];
    return colors[index % colors.length];
  }
}

class _LegendItem {
  final String label;
  final Color color;
  _LegendItem(this.label, this.color);
}
