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
  setisSHowndispute(bool val) {
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
        // Add null check before updating
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
