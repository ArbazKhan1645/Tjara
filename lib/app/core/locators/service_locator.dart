import 'package:get/get.dart';

import '../../services/app/app_service.dart';
import '../../services/auth/auth_service.dart';

Future<void> initDependencies() async {
  await _initAppService();
  await _initSetupServices();
}

Future<void> _initAppService() async {
  await Get.putAsync(() => AppService().init());
  await Get.putAsync(() => AuthService().init());
}

Future<void> _initSetupServices() async {}
