// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/helpers/alerts.dart';
import 'package:tjara/app/models/order_model.dart';
import 'package:http/http.dart' as http;

class OrdersDashboardController extends GetxController {
  var selectedOrder = Rxn<Order>();

  void setSelectedOrder(Order newOrder) {
    isShowndisputescreen.value = false;

    selectedOrder.value = newOrder;
  }

  RxBool isShowndisputescreen = false.obs;
  void setisSHowndispute(bool val) {
    isShowndisputescreen.value = val;
    update();
  }

  var isLoading = true.obs;
  var orderItems = <OrderItem>[].obs;
  Future<void> deleteOrder(String id, BuildContext context) async {
    final url = Uri.parse("https://api.libanbuy.com/api/orders/$id/delete");

    try {
      final response = await http.delete(
        url,
        headers: {
          "X-Request-From": "Application",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        NotificationHelper.showSuccess(context, 'Deleted', data['message']);
        // Optionally refresh the order list here or remove from local list
      } else {
        NotificationHelper.showError(
          context,
          'Failed',
          'Failed to delete the order',
        );
      }
    } catch (e) {
      NotificationHelper.showError(context, 'Error', e.toString());
    }
  }

  Future<void> fetchOrderItems(String id) async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/orders/$id/items'),
        headers: {"X-Request-From": "Application"},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final items =
            (jsonData['orderItems'] as List)
                .map((item) => OrderItem.fromJson(item))
                .toList();
        orderItems.assignAll(items);
      } else {
        Get.snackbar('Error', 'Failed to fetch data');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<List<OrderItem>> fetchOrderItemsFuture(String id) async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/orders/$id/items'),
        headers: {"X-Request-From": "Application"},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final items =
            (jsonData['orderItems'] as List)
                .map((item) => OrderItem.fromJson(item))
                .toList();
        return items;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ==========================================
  // ORDER STATUS OPTIONS
  // ==========================================
  static const List<String> orderStatusOptions = [
    'Pending',
    'On Hold',
    'Awaiting Payment',
    'Cancelled',
    'Refunded',
    'Processing / Awaiting Pickup',
    'Awaiting Fulfillment',
    'Shipping',
    'Delivered',
    'Completed',
    'Returned',
    'Reshipping',
    'Reshipped',
    'Failed',
  ];

  // ==========================================
  // PAYMENT STATUS OPTIONS
  // ==========================================
  static const List<String> paymentStatusOptions = [
    'Pending',
    'Paid',
    'Failed',
  ];

  // Update Order Status with Dialog
  Future<void> showUpdateOrderStatusDialog(
    String id,
    BuildContext context,
    String currentStatus,
  ) async {
    final String? selectedStatus = await showDialog<String>(
      context: context,
      builder:
          (context) => _StatusSelectionDialog(
            title: 'Update Order Status',
            options: orderStatusOptions,
            currentValue: currentStatus,
          ),
    );

    if (selectedStatus != null && selectedStatus != currentStatus) {
      await _updateOrderField(id, context, 'status', selectedStatus);
    }
  }

  // Update Payment Status with Dialog
  Future<void> showUpdatePaymentStatusDialog(
    String id,
    BuildContext context,
    String currentStatus,
  ) async {
    final String? selectedStatus = await showDialog<String>(
      context: context,
      builder:
          (context) => _StatusSelectionDialog(
            title: 'Update Payment Status',
            options: paymentStatusOptions,
            currentValue: currentStatus,
          ),
    );

    if (selectedStatus != null && selectedStatus != currentStatus) {
      await _updateOrderField(id, context, 'payment_status', selectedStatus);
    }
  }

  // Generic update method for any field
  Future<void> _updateOrderField(
    String id,
    BuildContext context,
    String fieldName,
    String value,
  ) async {
    final url = Uri.parse("https://api.libanbuy.com/api/orders/$id/update");

    try {
      final response = await http.put(
        url,
        headers: {
          "X-Request-From": "Application",
          "Content-Type": "application/json",
        },
        body: jsonEncode({fieldName: value.toLowerCase()}),
      );

      if (response.statusCode == 200) {
        if (selectedOrder.value != null) {
          if (fieldName == 'status') {
            selectedOrder.value!.status = value.toLowerCase();
          }
          // Trigger UI update
          selectedOrder.refresh();
        }
        final data = jsonDecode(response.body);
        NotificationHelper.showSuccess(context, 'Success', data['message']);
      } else {
        NotificationHelper.showError(
          context,
          'Failed',
          'Failed to update $fieldName',
        );
      }
    } catch (e) {
      NotificationHelper.showError(context, 'Error', e.toString());
    }
  }

  // Old method - kept for backward compatibility (Cancel order)
  Future<void> updateOrderStatus(String id, BuildContext context) async {
    final url = Uri.parse("https://api.libanbuy.com/api/orders/$id/update");

    try {
      final response = await http.put(
        url,
        headers: {
          "X-Request-From": "Application",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"status": "cancelled"}),
      );

      if (response.statusCode == 200) {
        if (selectedOrder.value != null) {
          selectedOrder.value!.status = 'cancelled';
        }
        final data = jsonDecode(response.body);
        NotificationHelper.showSuccess(context, 'Success', data['message']);
      } else {
        NotificationHelper.showError(
          context,
          'failed ',
          'Failed to cancelled order',
        );
      }
    } catch (e) {
      NotificationHelper.showError(context, 'failed to update', e.toString());
    }
  }

  Future<void> converttoAddtoCart(String id, BuildContext context) async {
    final url = Uri.parse("https://api.libanbuy.com/api/orders/$id/update");

    try {
      final response = await http.put(
        url,
        headers: {
          "X-Request-From": "Application",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"status": "cancelled", 'convert_to_cart': 'true'}),
      );

      if (response.statusCode == 200) {
        selectedOrder.value!.status = 'cancelled';
        final data = jsonDecode(response.body);
        NotificationHelper.showSuccess(context, 'Success', data['message']);
      } else {
        NotificationHelper.showError(
          context,
          'failed ',
          'Failed to cancelled order',
        );
      }
    } catch (e) {
      NotificationHelper.showError(context, 'failed to update', e.toString());
    }
  }

  Future<void> addOrderDispute(
    String id,
    BuildContext context,
    userid,
    reason,
    description,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.libanbuy.com/api/order-disputes/insert"),
        headers: {
          "Content-Type": "application/json",
          "user-id": userid.toString(),
          "X-Request-From": "Application",
        },
        body: jsonEncode({
          "order_id": id,
          "reason": reason,
          "description": description,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        NotificationHelper.showSuccess(context, 'Success', data['message']);
        setisSHowndispute(false);
      } else {
        NotificationHelper.showError(
          context,
          'failed ',
          'Failed to Create Dispute order',
        );
      }
    } catch (e) {
      NotificationHelper.showError(
        context,
        'failed to Create Dispute',
        e.toString(),
      );
    }
  }
}

class OrderItem {
  String id;
  String orderId;
  String productId;
  int quantity;
  double price;
  Product product;
  String imageUrl;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.product,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      productId: json['product_id'] ?? '',
      quantity:
          (json['quantity'] is int)
              ? json['quantity']
              : int.tryParse(json['quantity'].toString()) ?? 0,
      price:
          (json['price'] is num)
              ? json['price'].toDouble()
              : double.tryParse(json['price'].toString()) ?? 0.0,
      product: Product.fromJson(json['product'] ?? {}),
      imageUrl: json['thumbnail']?['media']?['optimized_media_url'] ?? '',
    );
  }
}

class Product {
  String id;
  String name;
  String description;
  double price;
  String status;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Product',
      description: json['description'] ?? 'No description available',
      price:
          (json['price'] is num)
              ? json['price'].toDouble()
              : double.tryParse(json['price'].toString()) ?? 0.0,
      status: json['status'] ?? 'unknown',
    );
  }
}

// ==========================================
// STATUS SELECTION DIALOG
// ==========================================
class _StatusSelectionDialog extends StatefulWidget {
  final String title;
  final List<String> options;
  final String currentValue;

  const _StatusSelectionDialog({
    required this.title,
    required this.options,
    required this.currentValue,
  });

  @override
  State<_StatusSelectionDialog> createState() => _StatusSelectionDialogState();
}

class _StatusSelectionDialogState extends State<_StatusSelectionDialog> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    // Match current value with options (case-insensitive)
    _selectedValue = widget.options.firstWhere(
      (opt) => opt.toLowerCase() == widget.currentValue.toLowerCase(),
      orElse: () => widget.options.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE91E63)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedValue,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items:
                      widget.options.map((String value) {
                        final isSelected = value == _selectedValue;
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                  selectedItemBuilder: (context) {
                    return widget.options.map((String value) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      );
                    }).toList();
                  },
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedValue = newValue);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedValue),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Update Status'),
        ),
      ],
    );
  }
}
