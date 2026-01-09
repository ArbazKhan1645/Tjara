import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/more/widgets/moreview_body.dart';
import 'package:tjara/app/modules/more/controllers/more_controller.dart';

class MoreView extends GetView<MoreController> {
  const MoreView({super.key});
  @override
  Widget build(BuildContext context) {
    return const MoreviewBody();
  }
}
