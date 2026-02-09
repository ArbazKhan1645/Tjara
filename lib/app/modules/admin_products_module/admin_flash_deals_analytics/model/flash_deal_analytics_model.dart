/// Safe int parser — handles String, int, double, null
int _parseInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

/// Safe double parser — handles String, int, double, null
double _parseDouble(dynamic value, [double fallback = 0]) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

/// Overall Analytics Response
class OverallAnalyticsResponse {
  final int totalDeals;
  final int purchasedCount;
  final int skippedCount;
  final int expiredCount;
  final double totalRevenue;
  final double conversionRate;
  final int totalViews;
  final int totalClicks;
  final double skipRate;
  final List<DealOverTime> dealsOverTime;
  final StatusBreakdown statusBreakdown;
  final List<TopShop> topShops;
  final List<HourlyDistribution> hourlyDistribution;

  OverallAnalyticsResponse({
    required this.totalDeals,
    required this.purchasedCount,
    required this.skippedCount,
    required this.expiredCount,
    required this.totalRevenue,
    required this.conversionRate,
    required this.totalViews,
    required this.totalClicks,
    required this.skipRate,
    required this.dealsOverTime,
    required this.statusBreakdown,
    required this.topShops,
    required this.hourlyDistribution,
  });

  factory OverallAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return OverallAnalyticsResponse(
      totalDeals: _parseInt(json['total_deals']),
      purchasedCount: _parseInt(json['purchased_count']),
      skippedCount: _parseInt(json['skipped_count']),
      expiredCount: _parseInt(json['expired_count']),
      totalRevenue: _parseDouble(json['total_revenue']),
      conversionRate: _parseDouble(json['conversion_rate']),
      totalViews: _parseInt(json['total_views']),
      totalClicks: _parseInt(json['total_clicks']),
      skipRate: _parseDouble(json['skip_rate']),
      dealsOverTime:
          (json['deals_over_time'] as List<dynamic>?)
              ?.map((e) => DealOverTime.fromJson(e))
              .toList() ??
          [],
      statusBreakdown: StatusBreakdown.fromJson(json['status_breakdown'] ?? {}),
      topShops:
          (json['top_shops'] as List<dynamic>?)
              ?.map((e) => TopShop.fromJson(e))
              .toList() ??
          [],
      hourlyDistribution:
          (json['hourly_distribution'] as List<dynamic>?)
              ?.map((e) => HourlyDistribution.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Deal performance data point over time
class DealOverTime {
  final String date;
  final int deals;
  final int purchased;
  final int skipped;

  DealOverTime({
    required this.date,
    required this.deals,
    required this.purchased,
    required this.skipped,
  });

  factory DealOverTime.fromJson(Map<String, dynamic> json) {
    return DealOverTime(
      date: json['date']?.toString() ?? '',
      deals: _parseInt(json['deals']),
      purchased: _parseInt(json['purchased']),
      skipped: _parseInt(json['skipped']),
    );
  }
}

/// Status breakdown for pie/donut chart
class StatusBreakdown {
  final int purchased;
  final int skipped;
  final int expired;
  final int active;

  StatusBreakdown({
    required this.purchased,
    required this.skipped,
    required this.expired,
    required this.active,
  });

  factory StatusBreakdown.fromJson(Map<String, dynamic> json) {
    return StatusBreakdown(
      purchased: _parseInt(json['purchased']),
      skipped: _parseInt(json['skipped']),
      expired: _parseInt(json['expired']),
      active: _parseInt(json['active']),
    );
  }

  int get total => purchased + skipped + expired + active;
}

/// Top performing shop
class TopShop {
  final String shopName;
  final int totalDeals;
  final double revenue;

  TopShop({
    required this.shopName,
    required this.totalDeals,
    required this.revenue,
  });

  factory TopShop.fromJson(Map<String, dynamic> json) {
    return TopShop(
      shopName: json['shop_name']?.toString() ?? '',
      totalDeals: _parseInt(json['total_deals']),
      revenue: _parseDouble(json['revenue']),
    );
  }
}

/// Hourly distribution data point
class HourlyDistribution {
  final int hour;
  final int count;

  HourlyDistribution({required this.hour, required this.count});

  factory HourlyDistribution.fromJson(Map<String, dynamic> json) {
    return HourlyDistribution(
      hour: _parseInt(json['hour']),
      count: _parseInt(json['count']),
    );
  }
}

/// Flash Deal History Item
class FlashDealHistoryItem {
  final String id;
  final String productName;
  final String? productImage;
  final String? originalPrice;
  final String? dealPrice;
  final String status;
  final String? startedAt;
  final String? endedAt;
  final int views;
  final int clicks;
  final String? shopName;

  FlashDealHistoryItem({
    required this.id,
    required this.productName,
    this.productImage,
    this.originalPrice,
    this.dealPrice,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.views = 0,
    this.clicks = 0,
    this.shopName,
  });

  factory FlashDealHistoryItem.fromJson(Map<String, dynamic> json) {
    // Product data can be nested under 'product' key or flat
    final product = json['product'] as Map<String, dynamic>? ?? {};

    // Image: try multiple paths
    String? imageUrl;
    if (json['product_image'] != null) {
      imageUrl = json['product_image'].toString();
    } else if (product['thumbnail'] != null &&
        product['thumbnail'] is Map &&
        product['thumbnail']['media'] != null &&
        product['thumbnail']['media'] is Map) {
      imageUrl = product['thumbnail']['media']['url']?.toString();
    } else if (json['thumbnail'] != null &&
        json['thumbnail'] is Map &&
        json['thumbnail']['media'] != null &&
        json['thumbnail']['media'] is Map) {
      imageUrl = json['thumbnail']['media']['url']?.toString();
    } else if (product['image'] != null) {
      imageUrl = product['image'].toString();
    }

    // Product name: try nested product.name, then flat product_name, then name
    final name =
        product['name']?.toString() ??
        json['product_name']?.toString() ??
        json['name']?.toString() ??
        '';

    // Price: try flat fields first, then nested product fields
    final originalPrice =
        json['original_price']?.toString() ??
        product['price']?.toString() ??
        json['price']?.toString();
    final dealPrice =
        json['deal_price']?.toString() ??
        product['sale_price']?.toString() ??
        json['sale_price']?.toString();

    // Shop name: try flat, then nested product.shop
    String? shopName;
    if (json['shop_name'] != null) {
      shopName = json['shop_name'].toString();
    } else if (product['shop'] != null && product['shop'] is Map) {
      shopName = product['shop']['name']?.toString();
    } else if (json['shop'] != null && json['shop'] is Map) {
      shopName = json['shop']['name']?.toString();
    }

    return FlashDealHistoryItem(
      id: json['id']?.toString() ?? '',
      productName: name,
      productImage: imageUrl,
      originalPrice: originalPrice,
      dealPrice: dealPrice,
      status: json['status']?.toString() ?? '',
      startedAt: json['started_at']?.toString(),
      endedAt: json['ended_at']?.toString(),
      views: _parseInt(json['views']),
      clicks: _parseInt(json['clicks']),
      shopName: shopName,
    );
  }
}

/// Flash Deal History Paginated Response
class FlashDealHistoryResponse {
  final List<FlashDealHistoryItem> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  FlashDealHistoryResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  factory FlashDealHistoryResponse.fromJson(Map<String, dynamic> json) {
    final flashDeals = json['flash_deal_products'] ?? json['data'] ?? {};
    final List<dynamic> dataList =
        flashDeals is Map
            ? (flashDeals['data'] as List<dynamic>? ?? [])
            : (flashDeals is List ? flashDeals : []);

    final pagination = flashDeals is Map ? flashDeals : json;

    return FlashDealHistoryResponse(
      data:
          dataList.map((item) => FlashDealHistoryItem.fromJson(item)).toList(),
      currentPage: _parseInt(pagination['current_page'], 1),
      lastPage: _parseInt(pagination['last_page'], 1),
      total: _parseInt(pagination['total']),
      perPage: _parseInt(pagination['per_page'], 10),
    );
  }
}
