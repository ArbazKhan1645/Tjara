// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:tjara/app/core/locators/cache_images.dart';
import 'package:tjara/app/core/widgets/admin_app_bar_actions.dart';
import 'package:tjara/app/models/disputes/disputes_model.dart';
import 'package:tjara/app/models/order_model.dart';
import 'package:tjara/app/modules/modules_customer/orders_dashboard/controllers/orders_dashboard_controller.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/services/orders_service.dart';

class OrderDisputeChatMessage {
  final String id;
  final String disputeId;
  final String userId;
  final String message;
  final String messageType;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String userRole;
  final String userFirstName;
  final String userLastName;
  final String userThumbnail;

  OrderDisputeChatMessage({
    required this.id,
    required this.disputeId,
    required this.userId,
    required this.message,
    required this.messageType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.userRole,
    required this.userFirstName,
    required this.userLastName,
    required this.userThumbnail,
  });

  factory OrderDisputeChatMessage.fromJson(Map<String, dynamic> json) {
    return OrderDisputeChatMessage(
      id: json['id'] ?? '',
      disputeId: json['dispute_id'] ?? '',
      userId: json['user_id'] ?? '',
      message: json['message'] ?? '',
      messageType: json['message_type'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      userRole: json['user_role'] ?? '',
      userFirstName: json['user_first_name'] ?? '',
      userLastName: json['user_last_name'] ?? '',
      userThumbnail: json['user_thumbnail'] ?? '',
    );
  }
}

class DisputesOrderover extends StatefulWidget {
  final Order order;
  final DisputeData dispute;

  const DisputesOrderover({
    super.key,
    required this.order,
    required this.dispute,
  });

  @override
  State<DisputesOrderover> createState() => _DisputesOrderoverState();
}

class _DisputesOrderoverState extends State<DisputesOrderover> {
  final OrderService _orderService = Get.find<OrderService>();
  final TextEditingController _messageController = TextEditingController();

  // Status dropdown variables
  String? _selectedStatus;
  final List<String> _statusOptions = [
    'open',
    'cancelled',
    'resolved',
    'completed',
  ];
  bool _isStatusChanged = false;
  bool _isUpdatingStatus = false;

  // Chat variables
  bool _isSendingMessage = false;
  String _chatMessagesKey = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    print(widget.order.status?.toLowerCase());

    _selectedStatus =
        widget.order.status != null ? widget.order.status?.toLowerCase() : '';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Status update function
  Future<void> _updateDisputeStatus() async {
    if (_selectedStatus == null) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final response = await http.put(
        Uri.parse(
          'https://api.libanbuy.com/api/order-disputes/${widget.dispute.id}/update-status',
        ),
        headers: {
          "Content-Type": "application/json",
          "X-Request-From": "Application",
        },
        body: json.encode({'status': _selectedStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isStatusChanged = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Go back to refresh the previous screen
        Navigator.of(context).pop();
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update status: ${errorData['message'] ?? 'Unknown error'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUpdatingStatus = false;
      });
    }
  }

  // Fetch chat messages
  Future<List<OrderDisputeChatMessage>> _fetchChatMessages() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.libanbuy.com/api/order-disputes/${widget.dispute.id}/chat/messages',
        ),
        headers: {
          "X-Request-From": "Application",
          'Content-Type': 'application/json',
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final messages =
            (jsonData['orderDisputeChatMessages'] as List)
                .map((message) => OrderDisputeChatMessage.fromJson(message))
                .toList();
        return messages;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Send message function
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isSendingMessage = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://api.libanbuy.com/api/order-disputes/${widget.dispute.id}/chat/messages/insert',
        ),
        headers: {
          "Content-Type": "application/json",
          "X-Request-From": "Application",
          'user-id': AuthService.instance.authCustomer!.user!.id.toString(),
        },
        body: json.encode({
          'message': _messageController.text.trim(),
          'message_type': 'text',
        }),
      );

      if (response.statusCode == 200) {
        _messageController.clear();
        // Refresh messages by updating the key
        setState(() {
          _chatMessagesKey = DateTime.now().millisecondsSinceEpoch.toString();
        });
      } else {
        final errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send message: ${errorData['message'] ?? 'Unknown error'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSendingMessage = false;
      });
    }
  }

  // Add resolve dispute function
  Future<void> _resolveDispute(String orderId) async {
    try {
      // Show confirmation dialog
      final bool? shouldResolve = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Resolve Dispute'),
            content: const Text(
              'Are you sure you want to resolve this dispute? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.green),
                child: const Text('Resolve'),
              ),
            ],
          );
        },
      );

      if (shouldResolve == true) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        // Call the resolve dispute API
        // await _orderService.resolveDispute(orderId);
        await _orderService.fetchOrders();

        // Close loading dialog
        Navigator.of(context).pop();
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dispute resolved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's open
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resolve dispute: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<OrderItem>> fetchOrderItemsFuture(String id) async {
    try {
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

  @override
  Widget build(BuildContext context) {
    const expandedStackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF165E28), Colors.red],
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF165E28),
        actions: [const AdminAppBarActionsSimple()],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: const BoxDecoration(gradient: expandedStackGradient),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: ListView(
              children: [
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Text(
                              'Order ID: #',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red.shade800,
                              ),
                            ),
                            Text(
                              widget.order.meta?['order_id'] ?? '--',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(
                                Icons.arrow_circle_left_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Status Dropdown Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Update Status:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.red.shade800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedStatus,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                items:
                                    _statusOptions.map((String status) {
                                      return DropdownMenuItem<String>(
                                        value: status,
                                        child: Text(status.toUpperCase()),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedStatus = newValue;
                                    _isStatusChanged =
                                        newValue != widget.order.status;
                                  });
                                },
                              ),
                              if (_isStatusChanged) ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isUpdatingStatus
                                            ? null
                                            : _updateDisputeStatus,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child:
                                        _isUpdatingStatus
                                            ? const CircularProgressIndicator(
                                              color: Colors.white,
                                            )
                                            : const Text('Save Status'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Text(
                              'DISPUTE STATUS:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red.shade800,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Text(
                                'DISPUTED',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Text(
                              'SHOP DETAILS:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color.fromARGB(255, 180, 3, 3),
                                  width: 4,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  placeholder:
                                      (context, url) => SizedBox(
                                        height: 110,
                                        child: Image.asset(
                                          'assets/icons/logo.png',
                                        ),
                                      ),
                                  height: 110,
                                  errorWidget:
                                      (context, url, error) => Container(
                                        color: Colors.red,
                                        child: Center(
                                          child: Text(
                                            '${widget.order.shop?.shop?.name?[0].toString() ?? ''}${widget.order.shop?.shop?.name?[1] ?? ''}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 32,
                                            ),
                                          ),
                                        ),
                                      ),
                                  width: 110,
                                  cacheManager: PersistentCacheManager(),
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      widget
                                          .order
                                          .shop
                                          ?.shop
                                          ?.banner
                                          ?.media
                                          ?.url ??
                                      '',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.order.shop?.shop?.name ?? '--',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        buildDetailRow(
                          'Order Status:',
                          widget.order.status ?? '--',
                        ),
                        buildDetailRow(
                          'Payment Status:',
                          widget.order.transaction?.paymentStatus ?? '--',
                        ),
                        buildDetailRow('Tracking Number:', '#--'),
                        buildDetailRow(' ', '-'),
                        buildDetailRow(
                          'Payment Method: ',
                          widget.order.transaction?.paymentMethod ?? '--',
                        ),
                        const SizedBox(height: 60),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Buyer Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildDetailRow(
                          'Full Name:',
                          '${widget.order.buyer?.user?.firstName ?? ''} ${widget.order.buyer?.user?.lastName ?? ''}',
                        ),
                        const SizedBox(height: 20),
                        buildDetailRow(
                          'Email:',
                          widget.order.buyer?.user?.email ?? '',
                        ),
                        const SizedBox(height: 20),
                        buildDetailRow(
                          'Phone Number:',
                          widget.order.buyer?.user?.phone ?? '',
                        ),
                        const SizedBox(height: 20),
                        buildDetailRow(
                          'Order Date:',
                          '${widget.order.createdAt ?? ''}',
                        ),
                        const SizedBox(height: 20),
                        buildDetailRow('Address:', 'Testing Address'),
                        const SizedBox(height: 20),
                        buildDetailRow('Postal:', '0000'),
                        const SizedBox(height: 20),
                        Container(
                          height: 70,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            color: Colors.grey.shade200,
                          ),
                          child: const Row(
                            children: [
                              Expanded(child: Center(child: Text('Item Name'))),
                              Expanded(child: Center(child: Text('Quantity'))),
                            ],
                          ),
                        ),
                        FutureBuilder(
                          future: fetchOrderItemsFuture(widget.order.id ?? ''),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(0),
                                itemCount: snapshot.data?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final item = snapshot.data?[index];
                                  if (item == null) return Container();
                                  return Card(
                                    elevation: 0,
                                    child: ListTile(
                                      leading: Image.network(
                                        item.imageUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                      title: Text(
                                        item.product.name ?? 'Product Name',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(
                                        "\$${item.price ?? '0'}",
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        buildDetailRow(
                          'Subtotal:',
                          widget.order.meta?['initial_total']?.toString() ??
                              '--',
                        ),
                        const SizedBox(height: 10),
                        buildDetailRow('Delivery Fee:', '0'),
                        const Divider(),
                        const SizedBox(height: 10),
                        buildDetailRow(
                          'Total:',
                          widget.order.transaction?.amount?.toString() ?? '--',
                        ),
                        const Divider(),
                        const SizedBox(height: 10),
                        buildDetailRow('Reseller Discount:', '-0'),
                        const Divider(),
                        buildDetailRow(
                          'Total Amount:',
                          widget.order.orderTotal?.toString() ?? '--',
                        ),
                        const SizedBox(height: 30),

                        // Chat Section
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Chat Messages',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 400,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              // Messages List
                              Expanded(
                                child: FutureBuilder<
                                  List<OrderDisputeChatMessage>
                                >(
                                  key: Key(_chatMessagesKey),
                                  future: _fetchChatMessages(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (snapshot.hasError) {
                                      return const Center(
                                        child: Text('Error loading messages'),
                                      );
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                        child: Text('No messages yet'),
                                      );
                                    } else {
                                      return ListView.builder(
                                        padding: const EdgeInsets.all(10),
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          final message = snapshot.data![index];
                                          final bool isAdmin =
                                              message.userRole == 'admin';

                                          return Align(
                                            alignment:
                                                isAdmin
                                                    ? Alignment.centerRight
                                                    : Alignment.centerLeft,
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              padding: const EdgeInsets.all(12),
                                              constraints: BoxConstraints(
                                                maxWidth:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.7,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isAdmin
                                                        ? Colors.blue.shade100
                                                        : Colors.grey.shade200,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${message.userFirstName} ${message.userLastName}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                      color:
                                                          isAdmin
                                                              ? Colors
                                                                  .blue
                                                                  .shade800
                                                              : Colors
                                                                  .grey
                                                                  .shade800,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    message.message,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    message.createdAt,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                              // Message Input
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _messageController,
                                        decoration: InputDecoration(
                                          hintText: 'Type a message...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 10,
                                              ),
                                        ),
                                        maxLines: null,
                                        onSubmitted: (_) => _sendMessage(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: IconButton(
                                        icon:
                                            _isSendingMessage
                                                ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                                : const Icon(
                                                  Icons.send,
                                                  color: Colors.white,
                                                ),
                                        onPressed:
                                            _isSendingMessage
                                                ? null
                                                : _sendMessage,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red.shade800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
