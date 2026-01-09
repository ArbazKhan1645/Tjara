// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tjara/app/models/chat_messages/chat_messages_model.dart';
import 'package:tjara/app/services/auth/auth_service.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

class ProductChatResponse {
  final List<ProductChatMessage>? productChatMessages;

  ProductChatResponse({this.productChatMessages});

  factory ProductChatResponse.fromJson(Map<String, dynamic> json) {
    return ProductChatResponse(
      productChatMessages:
          (json['ProductChatMessages'] as List?)
              ?.map((item) => ProductChatMessage.fromJson(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProductChatMessages':
          productChatMessages?.map((msg) => msg.toJson()).toList(),
    };
  }
}

class ProductChatMessage {
  final String? id;
  final String? chatId;
  final String? userId;
  final String? message;
  final String? messageType;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userRole;
  final String? userFirstName;
  final String? userLastName;
  final String? userThumbnail;

  ProductChatMessage({
    this.id,
    this.chatId,
    this.userId,
    this.message,
    this.messageType,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.userRole,
    this.userFirstName,
    this.userLastName,
    this.userThumbnail,
  });

  factory ProductChatMessage.fromJson(Map<String, dynamic> json) {
    return ProductChatMessage(
      id: json['id'],
      chatId: json['chat_id'],
      userId: json['user_id'],
      message: json['message'],
      messageType: json['message_type'],
      status: json['status'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      userRole: json['user_role'],
      userFirstName: json['user_first_name'],
      userLastName: json['user_last_name'],
      userThumbnail: json['user_thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'user_id': userId,
      'message': message,
      'message_type': messageType,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user_role': userRole,
      'user_first_name': userFirstName,
      'user_last_name': userLastName,
      'user_thumbnail': userThumbnail,
    };
  }
}

class ChatDialogWidget extends StatefulWidget {
  const ChatDialogWidget({
    super.key,
    required this.uid,
    this.traderName,
    this.traderAvatar,
    required this.model,
  });
  final String uid;
  final String? traderName;
  final String? traderAvatar;
  final ChatData? model;

  @override
  State<ChatDialogWidget> createState() => _ChatDialogWidgetState();
}

class _ChatDialogWidgetState extends State<ChatDialogWidget> {
  final TextEditingController _messageController = TextEditingController();
  late Future<List<ProductChatMessage>> _messagesFuture;
  List<ProductChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messagesFuture = fetchMessages(widget.uid);
    _messagesFuture.then((msgs) {
      setState(() {
        _messages = msgs;
      });
    });
  }

  Future<List<ProductChatMessage>> fetchMessages(String uid) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('chat_messages_$uid');

    try {
      final response = await http.get(
        Uri.parse('https://api.libanbuy.com/api/products/chats/$uid/messages'),
        headers: {"X-Request-From": "Application"},
      );

      if (response.statusCode == 200) {
        await prefs.setString('chat_messages_$uid', response.body);
        final result =
            ProductChatResponse.fromJson(
              json.decode(response.body),
            ).productChatMessages ??
            [];
        return result;
      } else {
        if (jsonDecode(response.body)['message'] == 'No Msgs found!') {
          return [];
        } else {
          throw Exception('Failed to load messages: ${response.body}');
        }
      }
    } catch (e) {
      print('Error fetching messages: $e');
      // Return cached data if available, otherwise empty list
      if (cachedData != null) {
        final cachedJson = json.decode(cachedData);
        return ProductChatResponse.fromJson(cachedJson).productChatMessages ??
            [];
      }
      return [];
    }
  }

  Future<bool> sendMessage(String message) async {
    if (message.trim().isEmpty) return false;

    setState(() {
      _isLoading = true;
    });

    // Create a temporary message to show immediately
    final tempMessage = ProductChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      createdAt: DateTime.now(),
      userId: AuthService.instance.authCustomer?.user?.id ?? '',
      chatId: widget.uid,
    );

    // Add message to the list immediately for better UX
    setState(() {
      _messages.add(tempMessage);
      _messageController.clear();
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://api.libanbuy.com/api/products/chats/${widget.uid}/messages/insert',
        ),
        headers: {
          'Content-Type': 'application/json',
          "X-Request-From": "Application",
          "user-id":
              AuthService.instance.authCustomer?.user?.id.toString() ?? '',
        },
        body: jsonEncode({'message': message, "message_type": "text"}),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // If successful, replace the temp message with the real one
        final responseData = jsonDecode(response.body);
        final realMessage = ProductChatMessage.fromJson(
          responseData['newMessage'] ?? responseData,
        );

        setState(() {
          // Replace temp message with real one if possible
          final index = _messages.indexWhere((msg) => msg.id == tempMessage.id);
          if (index != -1) {
            _messages[index] = realMessage;
          }
        });

        // Update cache
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(
          'chat_messages_${widget.uid}',
          jsonEncode(
            ProductChatResponse(productChatMessages: _messages).toJson(),
          ),
        );

        return true;
      } else {
        print('Failed to send message: ${response.body}');
        // Keep the temp message in the list even if API failed
        return false;
      }
    } catch (e) {
      print('Error sending message: $e');
      setState(() {
        _isLoading = false;
      });
      // Keep the temp message in the list even if API failed
      return false;
    }
  }

  String getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';

    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header with trader info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // Trader avatar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFFFFFFF),
                      radius: 20,
                      child: Image.asset('assets/images/simple.png'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Trader name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.model?.user?.firstName ?? AuthService.instance.authCustomer?.user?.firstName ?? ''} ${widget.model?.user?.lastName ?? AuthService.instance.authCustomer?.user?.lastName ?? ' '}',
                          style: defaultTextStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.model?.product?.name ?? ''} ',
                          style: defaultTextStyle.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.black87),
                      iconSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Messages list
            Expanded(
              child: FutureBuilder<List<ProductChatMessage>>(
                future: _messagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      _messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFF0D9488),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading messages...',
                            style: defaultTextStyle.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError && _messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red.shade600,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading messages',
                            style: defaultTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _messagesFuture = fetchMessages(widget.uid);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Retry',
                              style: defaultTextStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Use local messages list that includes both API results and local additions
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    reverse: false,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];

                      final isMine =
                          message.userId ==
                          AuthService.instance.authCustomer?.user?.id;

                      return Align(
                        alignment:
                            isMine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isMine
                                    ? const Color(0xFF0D9488)
                                    : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.message ?? '',
                                style: defaultTextStyle.copyWith(
                                  color: isMine ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                getTimeAgo(message.createdAt),
                                style: defaultTextStyle.copyWith(
                                  color:
                                      isMine
                                          ? Colors.white70
                                          : Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Message input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // Text input field
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: defaultTextStyle.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: defaultTextStyle.copyWith(fontSize: 14),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          sendMessage(text);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Submit button
                  Container(
                    decoration: BoxDecoration(
                      color:
                          _isLoading
                              ? Colors.grey.shade300
                              : const Color(0xFF0D9488),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () => sendMessage(_messageController.text),
                      icon:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

// Example of how to use this widget:
// showDialog(
//   context: context,
//   builder: (context) => ChatDialogWidget(
//     uid: 'chat-id-123',
//     traderName: 'Majid Haffar',
//     traderAvatar: '', // Optional avatar URL
//   ),
// );
