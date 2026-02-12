import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/modules/modules_admin/cars/controllers/cars_controller.dart';
import 'package:tjara/app/services/dashbopard_services/admin_cars_service.dart';

class CarsView extends StatefulWidget {
  const CarsView({super.key});

  @override
  State<CarsView> createState() => _CarsViewState();
}

class _CarsViewState extends State<CarsView> {
  late AdminCarsService _adminCarsService;

  @override
  void initState() {
    super.initState();

    _adminCarsService = Get.put(AdminCarsService());
    _adminCarsService.fetchProducts(refresh: true, showLoader: true);
  }

  @override
  Widget build(BuildContext context) {
    return const AdminCarsPage();
  }
}
