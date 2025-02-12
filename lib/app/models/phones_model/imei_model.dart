class ImeiCheckResponse {
  final int id;
  final String ulid;
  final String status;
  final String service;
  final int serviceId;
  final DateTime createdAt;
  final String imei;
  final String? imei2;
  final String? sn;
  final String? phoneNumber;
  final String? text;
  final String tokenKey;
  final String tokenRequestPrice;
  final ImeiCheckResult result;
  final bool isCustomResult;
  final DateTime requestedAt;
  final String? customFormatResponse;
  final int processingCountdown;

  ImeiCheckResponse({
    required this.id,
    required this.ulid,
    required this.status,
    required this.service,
    required this.serviceId,
    required this.createdAt,
    required this.imei,
    this.imei2,
    this.sn,
    this.phoneNumber,
    this.text,
    required this.tokenKey,
    required this.tokenRequestPrice,
    required this.result,
    required this.isCustomResult,
    required this.requestedAt,
    this.customFormatResponse,
    required this.processingCountdown,
  });

  // CopyWith method
  ImeiCheckResponse copyWith({
    int? id,
    String? ulid,
    String? status,
    String? service,
    int? serviceId,
    DateTime? createdAt,
    String? imei,
    String? imei2,
    String? sn,
    String? phoneNumber,
    String? text,
    String? tokenKey,
    String? tokenRequestPrice,
    ImeiCheckResult? result,
    bool? isCustomResult,
    DateTime? requestedAt,
    String? customFormatResponse,
    int? processingCountdown,
  }) {
    return ImeiCheckResponse(
      id: id ?? this.id,
      ulid: ulid ?? this.ulid,
      status: status ?? this.status,
      service: service ?? this.service,
      serviceId: serviceId ?? this.serviceId,
      createdAt: createdAt ?? this.createdAt,
      imei: imei ?? this.imei,
      imei2: imei2 ?? this.imei2,
      sn: sn ?? this.sn,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      text: text ?? this.text,
      tokenKey: tokenKey ?? this.tokenKey,
      tokenRequestPrice: tokenRequestPrice ?? this.tokenRequestPrice,
      result: result ?? this.result,
      isCustomResult: isCustomResult ?? this.isCustomResult,
      requestedAt: requestedAt ?? this.requestedAt,
      customFormatResponse: customFormatResponse ?? this.customFormatResponse,
      processingCountdown: processingCountdown ?? this.processingCountdown,
    );
  }

  // Method to convert from JSON
  factory ImeiCheckResponse.fromJson(Map<String, dynamic> json) {
    return ImeiCheckResponse(
      id: json['id'],
      ulid: json['ulid'],
      status: json['status'],
      service: json['service'],
      serviceId: json['service_id'],
      createdAt: DateTime.parse(json['created_at']),
      imei: json['imei'],
      imei2: json['imei2'],
      sn: json['sn'],
      phoneNumber: json['phone_number'],
      text: json['text'],
      tokenKey: json['token_key'],
      tokenRequestPrice: json['token_request_price'],
      result: ImeiCheckResult.fromJson(json['result']),
      isCustomResult: json['is_custom_result'],
      requestedAt: DateTime.parse(json['requested_at']),
      customFormatResponse: json['custom_format_response'],
      processingCountdown: json['processing_countdown'],
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ulid': ulid,
      'status': status,
      'service': service,
      'service_id': serviceId,
      'created_at': createdAt.toIso8601String(),
      'imei': imei,
      'imei2': imei2,
      'sn': sn,
      'phone_number': phoneNumber,
      'text': text,
      'token_key': tokenKey,
      'token_request_price': tokenRequestPrice,
      'result': result.toJson(),
      'is_custom_result': isCustomResult,
      'requested_at': requestedAt.toIso8601String(),
      'custom_format_response': customFormatResponse,
      'processing_countdown': processingCountdown,
    };
  }
}

class ImeiCheckResult {
  final String imei;
  final String brandName;
  final String model;

  ImeiCheckResult({
    required this.imei,
    required this.brandName,
    required this.model,
  });

  // Method to convert from JSON
  factory ImeiCheckResult.fromJson(Map<String, dynamic> json) {
    return ImeiCheckResult(
      imei: json['imei'],
      brandName: json['brand_name'],
      model: json['model'],
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'imei': imei,
      'brand_name': brandName,
      'model': model,
    };
  }
}
