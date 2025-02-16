import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/routes/app_pages.dart';

import '../../../core/utils/thems/theme.dart';

class ServicesScreen extends StatelessWidget {
  final List<Map<String, String>> services = const [
    {"icon": "assets/icons/business.png", "title": "Business"},
    {"icon": "assets/icons/data.png", "title": "Data"},
    {"icon": "assets/icons/business.png", "title": "Digital Marketing"},
    {"icon": "assets/icons/data.png", "title": "Electronics Repair"},
    {"icon": "assets/icons/business.png", "title": "Event Planning"},
  ];

  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Services",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "View All",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFD9183B),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Service List
          ListView.builder(
            shrinkWrap: true,
             physics: NeverScrollableScrollPhysics(),
            itemCount: services.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.BLOG);
                },
                child: Container(
                  height: 140,
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.09),
                        offset: Offset(0, 2.64),
                        blurRadius: 33.05,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        height: 64,
                        width: 64,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFFD9183B),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          services[index]["icon"]!,
                          width: 30,
                          height: 30,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 20),
                      // Text Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(services[index]["title"]!,
                                style: defaultTextStyle.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                )),
                            SizedBox(height: 4),
                            Text(
                                "Lorem Ipsum is simply dummy text of the printing",
                                style: defaultTextStyle.copyWith(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w300,
                                )),
                            SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {},
                              child: Row(
                                children: [
                                  Text(
                                    "View Service",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFD9183B),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 14,
                                    color: Color(0xFFD9183B),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
