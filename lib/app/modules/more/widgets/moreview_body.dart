import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';
import 'package:tjara/app/modules/authentication/dialogs/contact_us.dart';
import 'package:tjara/app/routes/app_pages.dart';
import 'package:tjara/app/services/auth/apis.dart';

class MoreviewBody extends StatelessWidget {
  const MoreviewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/icons/logo.png',
                  height: 100,
                  fit: BoxFit.fitWidth,
                  width: 100,
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Text(
                    'رؤيتنا في تجارة هي بناء أكبر سوق إلكتروني شامل ومجتمع متكامل يمكّن المشترين والبائعين والموزعين من النجاح. من خلال متاجرنا، نوفر للمستهلكين أسعارًا لا تُنافَس، وتشكيلة واسعة من المنتجات، وتسليمًا سريعًا ومجانيًا، وتجربة تسوق مريحة وخالية من المتاعب. مع نادي تجارة وبرنامج الموزعين، يمكن لأي شخص البدء برأس مال صغير، مع الحصول على التوجيه والدعم اللازمين لتحقيق النجاح. نقدم نظام عمولة تنافسي يتيح للبائعين تحقيق أقصى قدر من الأرباح، إلى جانب خصومات حصرية للموزعين، وعروض مميزة للمستهلكين، وأدوات متقدمة للتسويق الرقمي والتجارة الإلكترونية. نحن لا نبني مجرد منصة للبيع والشراء، بل منظومة متكاملة تفتح أبواب الفرص، وتدعم رواد الأعمال والأفراد للنمو وتحقيق الاستقلال المالي',
                    style: TextStyle(fontSize: 16))),
            Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Text(
                    'at Tjara is to build the most comprehensive online marketplace and an integrated community that empowers buyers, sellers, and resellers to succeed. Through our stores, we provide consumers with unbeatable prices, a vast selection of products, fast and free delivery, and a seamless shopping experience. With Tjara Club and the reseller program, anyone can start with minimal capital while receiving the guidance and support needed to thrive. We offer a competitive commission system that maximizes seller profits, along with exclusive discounts for resellers, special deals for consumers, and advanced tools for digital marketing and e-commerce. We are not just building a platform for buying and selling—we are creating a thriving ecosystem that opens doors to opportunities and supports entrepreneurs and individuals in achieving financial independence.',
                    style: TextStyle(fontSize: 16))),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Row(
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      TextButton(
                          onPressed: () async {},
                          child: Text('Links',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500))),
                      SizedBox(height: 15),
                      buildTextWidget('Home'),
                      SizedBox(height: 4),
                      buildTextWidget('Services'),
                      SizedBox(height: 4),
                      buildTextWidget('Jobs', onPressed: () {
                        Get.toNamed(Routes.STORE_PAGE);
                      }),
                      SizedBox(height: 4),
                      buildTextWidget('Contests'),
                      SizedBox(height: 4),
                      buildTextWidget('Blogs'),
                      SizedBox(height: 4),
                    ],
                  )),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      TextButton(
                          onPressed: () {
                            login();
                          },
                          child: Text('Help',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500))),
                      SizedBox(height: 15),
                      buildTextWidget('Contact us', onPressed: () {
                        showContactDialog(context, ContactFormDialog());
                      }),
                      SizedBox(height: 4),
                      buildTextWidget('Help Center'),
                      SizedBox(height: 4),
                      buildTextWidget('Privacy Policy'),
                      SizedBox(height: 4),
                      buildTextWidget('Terms & Service'),
                      SizedBox(height: 4),
                      buildTextWidget('Reseller Center'),
                      SizedBox(height: 4),
                    ],
                  )),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(11),
                  child: MaterialButton(
                      height: 52,
                      minWidth: 100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onPressed: () {},
                      child: Text("Login",
                          style:
                              defaultTextStyle.copyWith(color: Colors.white))),
                ),
                SizedBox(width: 20),
                Material(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(11),
                  child: MaterialButton(
                      height: 52,
                      minWidth: 100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onPressed: () {},
                      child: Text("Sign up",
                          style:
                              defaultTextStyle.copyWith(color: Colors.white))),
                ),
              ],
            ),
            SizedBox(height: 100),
          ],
        ));
  }
}

buildTextWidget(String name, {void Function()? onPressed}) {
  return TextButton(
      onPressed: onPressed,
      child: Text(
        name,
        style: TextStyle(
            color: Colors.black, fontSize: 15, fontWeight: FontWeight.w400),
        textAlign: TextAlign.left,
      ));
}
