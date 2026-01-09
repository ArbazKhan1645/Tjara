import 'package:get/get.dart';

import 'package:tjara/app/models/categories/categories_model.dart';
import 'package:tjara/app/models/products/products_model.dart';

class SplashScreenController extends GetxController {}

class DataService {
  static final DataService instance = DataService._internal();
  DataService._internal();

  CategoryModel? categories;
  ProductModel? products;
}
