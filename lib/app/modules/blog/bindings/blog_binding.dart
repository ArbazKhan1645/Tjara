import 'package:get/get.dart';

import 'package:tjara/app/modules/blog/controllers/blog_controller.dart';

class BlogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlogController>(
      () => BlogController(),
    );
  }
}
