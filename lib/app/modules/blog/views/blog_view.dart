import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:tjara/app/core/utils/constants/assets_manager.dart';

import '../../../core/utils/thems/theme.dart';
import '../../../core/widgets/appbar.dart';
import '../../../core/widgets/base.dart';
import '../controllers/blog_controller.dart';
import '../widgets/blogs_items.dart';

class BlogView extends GetView<BlogController> {
  const BlogView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BlogController>(
        init: BlogController(),
        builder: (controller) {
          return Scaffold(
              backgroundColor: Colors.white,
              appBar: CustomAppBar(),
              body: CheckoutViewBody());
        });
  }
}

class CheckoutViewBody extends StatelessWidget {
  const CheckoutViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonBaseBodyScreen(scrollController: ScrollController(), screens: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Text("Home", style: defaultTextStyle.copyWith(fontSize: 16)),
            Text(" /  ", style: defaultTextStyle.copyWith(fontSize: 16)),
            Text("Blog",
                style: defaultTextStyle.copyWith(
                    fontSize: 16, color: Color(0xffD21642))),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffEAEAEA)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintStyle: defaultTextStyle.copyWith(
                            color: Colors.grey.shade400, fontSize: 14),
                        hintText: 'Search in store',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.tune, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 10),
      Container(
        color: const Color.fromRGBO(233, 233, 233, 1),
        height: 45,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: 94,
              height: 32,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  color: Colors.white,
                  border: Border.all(color: Color(0xffECECEC))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Sort by',
                      style: defaultTextStyle.copyWith(
                          fontSize: 14, fontWeight: FontWeight.w300)),
                  SizedBox(width: 5),
                  Image.asset(AppAssets.dropdown)
                ],
              ),
            ),
          ),
        ),
      ),
      SizedBox(height: 20),
      BlogListView(),
      SizedBox(height: 150),
    ]);
  }
}
