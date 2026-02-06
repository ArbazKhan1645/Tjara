/// Flash Deal Product Model
class FlashDealProduct {
  final String id;
  final String name;
  final String? image;
  final String? price;
  final String? salePrice;
  final String? status;
  final String? is_deal;

  FlashDealProduct({
    required this.id,
    required this.name,
    this.image,
    this.price,
    this.salePrice,
    this.status,
    required this.is_deal,
  });

  factory FlashDealProduct.fromJson(Map<String, dynamic> json) {
    String? thumbnailUrl;
    if (json['thumbnail'] != null && json['thumbnail']['media'] != null) {
      thumbnailUrl = json['thumbnail']['media']['url'];
    }

    return FlashDealProduct(
      id: json['id'] ?? '',
      is_deal: json['is_deal'].toString(),
      name: json['name'] ?? '',
      image: thumbnailUrl ?? json['image'],
      price: json['price']?.toString(),
      salePrice: json['sale_price']?.toString(),
      status: json['status'],
    );
  }
}

/// Flash Deal Settings Model
class FlashDealSettings {
  // Enable/Disable
  final bool flashDealsEnabled;

  // Duration settings
  final String activeTimeValue;
  final String activeTimeUnit;
  final String intervalTimeValue;
  final String intervalTimeUnit;

  // Scheduling
  final String schedulingMode; // 'live' or 'schedule'
  final String? startTime;
  final String? timeLimitHours;

  // Purchase limits
  final bool purchaseLimitEnabled;
  final String? purchaseLimitPerStore;

  // Lock duration
  final String? lockDuration;

  // Product sort orders
  final String flashDealsProductsSortOrder;
  final String skippedDealsProductsSortOrder;
  final String expiredDealsProductsSortOrder;
  final String soldDealsProductsSortOrder;

  // Current deal info
  final String? currentDealProductId;
  final String? currentDealStartTime;
  final String? currentDealEndTime;

  // No deals content
  final String? noDealsHeadline;
  final String? noDealsDescription;
  final String? noDealsDir;

  // Group icon clicks
  final String? groupIconClicks;

  FlashDealSettings({
    required this.flashDealsEnabled,
    required this.activeTimeValue,
    required this.activeTimeUnit,
    required this.intervalTimeValue,
    required this.intervalTimeUnit,
    required this.schedulingMode,
    this.startTime,
    this.timeLimitHours,
    required this.purchaseLimitEnabled,
    this.purchaseLimitPerStore,
    this.lockDuration,
    required this.flashDealsProductsSortOrder,
    required this.skippedDealsProductsSortOrder,
    required this.expiredDealsProductsSortOrder,
    required this.soldDealsProductsSortOrder,
    this.currentDealProductId,
    this.currentDealStartTime,
    this.currentDealEndTime,
    this.noDealsHeadline,
    this.noDealsDescription,
    this.noDealsDir,
    this.groupIconClicks,
  });

  factory FlashDealSettings.fromJson(Map<String, dynamic> options) {
    return FlashDealSettings(
      flashDealsEnabled: options['flash_deals_enabled'] == '1',
      activeTimeValue:
          options['flash_deals_active_time_value']?.toString() ?? '1',
      activeTimeUnit:
          options['flash_deals_active_time_unit']?.toString() ?? 'minutes',
      intervalTimeValue:
          options['flash_deals_interval_time_value']?.toString() ?? '30',
      intervalTimeUnit:
          options['flash_deals_interval_time_unit']?.toString() ?? 'seconds',
      schedulingMode:
          options['flash_deals_scheduling_mode']?.toString() ?? 'live',
      startTime: options['flash_deals_start_time']?.toString(),
      timeLimitHours: options['flash_deals_time_limit_hours']?.toString(),
      purchaseLimitEnabled:
          options['flash_deals_purchase_limit_enabled'] == '1',
      purchaseLimitPerStore:
          options['flash_deals_purchase_limit_per_store']?.toString(),
      lockDuration: options['flash_deal_lock_duration']?.toString(),
      flashDealsProductsSortOrder:
          options['flash_deals_products_sort_order']?.toString() ?? '',
      skippedDealsProductsSortOrder:
          options['skipped_deals_products_sort_order']?.toString() ?? '',
      expiredDealsProductsSortOrder:
          options['expired_deals_products_sort_order']?.toString() ?? '',
      soldDealsProductsSortOrder:
          options['sold_deals_products_sort_order']?.toString() ?? '',
      currentDealProductId: options['current_deal_product_id']?.toString(),
      currentDealStartTime: options['current_deal_start_time']?.toString(),
      currentDealEndTime: options['current_deal_end_time']?.toString(),
      noDealsHeadline:
          options['no_flash_deals_found_content_headline']?.toString(),
      noDealsDescription:
          options['no_flash_deals_found_content_description']?.toString(),
      noDealsDir: options['no_flash_deals_found_content_dir']?.toString(),
      groupIconClicks: options['flash_deals_group_icon_clicks']?.toString(),
    );
  }

  /// Get list of product IDs from sort order string
  List<String> get activeProductIds => _parseIds(flashDealsProductsSortOrder);
  List<String> get skippedProductIds =>
      _parseIds(skippedDealsProductsSortOrder);
  List<String> get expiredProductIds =>
      _parseIds(expiredDealsProductsSortOrder);
  List<String> get soldProductIds => _parseIds(soldDealsProductsSortOrder);

  List<String> _parseIds(String sortOrder) {
    if (sortOrder.isEmpty) return [];
    return sortOrder.split(',').where((id) => id.trim().isNotEmpty).toList();
  }

  /// Convert duration to seconds
  int get dealDurationSeconds {
    final value = int.tryParse(activeTimeValue) ?? 1;
    switch (activeTimeUnit.toLowerCase()) {
      case 'seconds':
        return value;
      case 'minutes':
        return value * 60;
      case 'hours':
        return value * 3600;
      default:
        return value * 60;
    }
  }

  /// Convert interval to seconds
  int get intervalSeconds {
    final value = int.tryParse(intervalTimeValue) ?? 30;
    switch (intervalTimeUnit.toLowerCase()) {
      case 'seconds':
        return value;
      case 'minutes':
        return value * 60;
      case 'hours':
        return value * 3600;
      default:
        return value;
    }
  }
}

/// Settings API Response
class SettingsResponse {
  final Map<String, dynamic> options;
  final String? provider;

  SettingsResponse({required this.options, this.provider});

  factory SettingsResponse.fromJson(Map<String, dynamic> json) {
    return SettingsResponse(
      options: json['options'] ?? {},
      provider: json['provider']?.toString(),
    );
  }

  FlashDealSettings get flashDealSettings =>
      FlashDealSettings.fromJson(options);
}

/// Products Response for search
class FlashDealProductsResponse {
  final FlashDealProductsPagination products;

  FlashDealProductsResponse({required this.products});

  factory FlashDealProductsResponse.fromJson(Map<String, dynamic> json) {
    return FlashDealProductsResponse(
      products: FlashDealProductsPagination.fromJson(json['products'] ?? {}),
    );
  }
}

class FlashDealProductsPagination {
  final List<FlashDealProduct> data;
  final int total;

  FlashDealProductsPagination({required this.data, required this.total});

  factory FlashDealProductsPagination.fromJson(Map<String, dynamic> json) {
    return FlashDealProductsPagination(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => FlashDealProduct.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}
