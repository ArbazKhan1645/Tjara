// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../models/users_model.dart/customer_models.dart';
import '../app/app_service.dart';

class AuthService extends GetxService {
  static AuthService get instance => Get.find<AuthService>();
  late final AppService _appService;
  late final BehaviorSubject<LoginResponse?> _authCustomerBehaviorSubject;

  BehaviorSubject<LoginResponse?>? get authCustomerBehaviorSubject =>
      _authCustomerBehaviorSubject;

  Future<AuthService> init() async {
    await _init();
    return this;
  }

  Future<void> _init() async {
    _appService = Get.find<AppService>();
    _authCustomerBehaviorSubject = BehaviorSubject.seeded(null);
    final authCustomerId =
        _appService.sharedPreferences.getString('current_user');
    if (authCustomerId != null) {
      _authCustomerBehaviorSubject
          .add(LoginResponse.fromJson(jsonDecode(authCustomerId)));
    }
  }

  void saveAuthState(LoginResponse customer) {
    _appService.sharedPreferences
        .setString('current_user', jsonEncode(customer.toJson()));
    _authCustomerBehaviorSubject.add(customer);
  }

  LoginResponse? get authCustomer {
    return _authCustomerBehaviorSubject.value;
  }

  bool get islogin {
    return authCustomer != null;
  }

  Future<void> cleanStorage() async {
    await _appService.sharedPreferences.remove('current_user');
    _authCustomerBehaviorSubject.add(null);
  }
}
