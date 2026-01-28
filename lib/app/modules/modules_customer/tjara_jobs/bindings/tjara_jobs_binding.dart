import 'package:get/get.dart';

import 'package:tjara/app/modules/modules_customer/tjara_jobs/controllers/tjara_jobs_controller.dart';

class TjaraJobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TjaraJobsController>(() => TjaraJobsController());
  }
}
