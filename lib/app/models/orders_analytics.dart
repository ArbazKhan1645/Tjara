class OrderAnalyticsModel {
  Analytics? analytics;

  OrderAnalyticsModel({this.analytics});

  OrderAnalyticsModel.fromJson(Map<String, dynamic> json) {
    analytics =
        json['analytics'] != null
            ? Analytics.fromJson(json['analytics'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (analytics != null) {
      data['analytics'] = analytics!.toJson();
    }
    return data;
  }
}

class Analytics {
  int? totalOrders;
  int? totalPendingOrders;
  int? totalProcessingOrders;
  int? totalShippingOrders;
  int? totalCompletedOrders;
  int? totalCancelledOrders;
  double? totalOrderValue;
  double? totalDeliveryFees; // Changed from int to double
  double? totalAdminCommission;
  double? totalVendorEarnings;
  double? completedOrdersValue;
  double? pendingOrdersValue; // Changed from int to double
  double? processingOrdersValue; // Changed from int to double
  double? shippingOrdersValue;
  double? cancelledOrdersValue;
  int? paidOrdersCount;
  int? pendingPaymentsCount;
  int? failedPaymentsCount;
  String? dateFilterApplied;
  dynamic customDateRange; // Changed from Null to dynamic
  FiltersApplied? filtersApplied;

  Analytics({
    this.totalOrders,
    this.totalPendingOrders,
    this.totalProcessingOrders,
    this.totalShippingOrders,
    this.totalCompletedOrders,
    this.totalCancelledOrders,
    this.totalOrderValue,
    this.totalDeliveryFees,
    this.totalAdminCommission,
    this.totalVendorEarnings,
    this.completedOrdersValue,
    this.pendingOrdersValue,
    this.processingOrdersValue,
    this.shippingOrdersValue,
    this.cancelledOrdersValue,
    this.paidOrdersCount,
    this.pendingPaymentsCount,
    this.failedPaymentsCount,
    this.dateFilterApplied,
    this.customDateRange,
    this.filtersApplied,
  });

  Analytics.fromJson(Map<String, dynamic> json) {
    totalOrders = _toInt(json['total_orders']);
    totalPendingOrders = _toInt(json['total_pending_orders']);
    totalProcessingOrders = _toInt(json['total_processing_orders']);
    totalShippingOrders = _toInt(json['total_shipping_orders']);
    totalCompletedOrders = _toInt(json['total_completed_orders']);
    totalCancelledOrders = _toInt(json['total_cancelled_orders']);
    totalOrderValue = _toDouble(json['total_order_value']);
    totalDeliveryFees = _toDouble(json['total_delivery_fees']);
    totalAdminCommission = _toDouble(json['total_admin_commission']);
    totalVendorEarnings = _toDouble(json['total_vendor_earnings']);
    completedOrdersValue = _toDouble(json['completed_orders_value']);
    pendingOrdersValue = _toDouble(json['pending_orders_value']);
    processingOrdersValue = _toDouble(json['processing_orders_value']);
    shippingOrdersValue = _toDouble(json['shipping_orders_value']);
    cancelledOrdersValue = _toDouble(json['cancelled_orders_value']);
    paidOrdersCount = _toInt(json['paid_orders_count']);
    pendingPaymentsCount = _toInt(json['pending_payments_count']);
    failedPaymentsCount = _toInt(json['failed_payments_count']);
    dateFilterApplied = json['date_filter_applied'];
    customDateRange = json['custom_date_range'];
    filtersApplied =
        json['filters_applied'] != null
            ? FiltersApplied.fromJson(json['filters_applied'])
            : null;
  }

  // Helper method to safely convert to double
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Helper method to safely convert to int
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_orders'] = totalOrders;
    data['total_pending_orders'] = totalPendingOrders;
    data['total_processing_orders'] = totalProcessingOrders;
    data['total_shipping_orders'] = totalShippingOrders;
    data['total_completed_orders'] = totalCompletedOrders;
    data['total_cancelled_orders'] = totalCancelledOrders;
    data['total_order_value'] = totalOrderValue;
    data['total_delivery_fees'] = totalDeliveryFees;
    data['total_admin_commission'] = totalAdminCommission;
    data['total_vendor_earnings'] = totalVendorEarnings;
    data['completed_orders_value'] = completedOrdersValue;
    data['pending_orders_value'] = pendingOrdersValue;
    data['processing_orders_value'] = processingOrdersValue;
    data['shipping_orders_value'] = shippingOrdersValue;
    data['cancelled_orders_value'] = cancelledOrdersValue;
    data['paid_orders_count'] = paidOrdersCount;
    data['pending_payments_count'] = pendingPaymentsCount;
    data['failed_payments_count'] = failedPaymentsCount;
    data['date_filter_applied'] = dateFilterApplied;
    data['custom_date_range'] = customDateRange;
    if (filtersApplied != null) {
      data['filters_applied'] = filtersApplied!.toJson();
    }
    return data;
  }
}

class FiltersApplied {
  bool? search;
  bool? searchByBuyerName;
  bool? searchByPhone;
  bool? columnFilters;
  bool? transactionFilters;
  bool? metaFilters;

  FiltersApplied({
    this.search,
    this.searchByBuyerName,
    this.searchByPhone,
    this.columnFilters,
    this.transactionFilters,
    this.metaFilters,
  });

  FiltersApplied.fromJson(Map<String, dynamic> json) {
    search = json['search'];
    searchByBuyerName = json['search_by_buyer_name'];
    searchByPhone = json['search_by_phone'];
    columnFilters = json['column_filters'];
    transactionFilters = json['transaction_filters'];
    metaFilters = json['meta_filters'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['search'] = search;
    data['search_by_buyer_name'] = searchByBuyerName;
    data['search_by_phone'] = searchByPhone;
    data['column_filters'] = columnFilters;
    data['transaction_filters'] = transactionFilters;
    data['meta_filters'] = metaFilters;
    return data;
  }
}