import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

class BlogListView extends StatelessWidget {
  const BlogListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) {
          return const SizedBox(height: 15);
        },
        itemCount: 5,
        itemBuilder: (context, index) {
          return const Blogwidget();
        });
  }
}

class Blogwidget extends StatelessWidget {
  const Blogwidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 460,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xffE4E7E9),
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              offset: const Offset(0, 2.64),
              blurRadius: 33.05,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(9),
                      topRight: Radius.circular(9))),
              child: Image.asset(
                'assets/images/redcar.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Container(
                  child: Image.asset(
                    'assets/images/UserCircle.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 5, right: 15),
                  child: Text(
                    "Cameron",
                    style: TextStyle(
                        color: Color(0xff475156),
                        fontSize: 11,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Container(
                  child: Image.asset(
                    'assets/images/CalendarBlank.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 5, right: 15),
                  child: Text(
                    "1 Feb, 2020",
                    style: TextStyle(
                        color: Color(0xff475156),
                        fontSize: 11,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Container(
                  child: Image.asset(
                    'assets/images/ChatCircleDots.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                const Text(
                  "738",
                  style: TextStyle(
                      color: Color(0xff475156),
                      fontSize: 11,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
                "Curabitur pulvinar aliquam lectus, non blandit erat mattis vitae. ",
                style: defaultTextStyle.copyWith()),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Mauris scelerisque odio id rutrum volutpat. Pellentesque urna odio, vulputate at tortor vitae, hendrerit blandit lorem. ",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              height: 40,
              width: 130,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(1.62)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Read More",
                      style: TextStyle(
                          color: Color(0xffD21642),
                          fontWeight: FontWeight.w700,
                          fontSize: 11),
                    ),
                  ),
                  Container(
                    child: Image.asset(
                      'assets/images/ArrowRight.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
