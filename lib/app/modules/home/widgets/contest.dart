import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

class ContestScreen extends StatelessWidget {
  const ContestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Contests",
                    style: defaultTextStyle.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    )),
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
            SizedBox(height: 30),
            SizedBox(
              child: ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemCount: 2,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return const ContestItem();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContestItem extends StatelessWidget {
  const ContestItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            offset: Offset(0, 2.64),
            blurRadius: 33.05,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/contest.png', // Replace with actual contest image URL
                height: 256,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 10),
            Text('11 days left',
                style: defaultTextStyle.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.red)),
            const SizedBox(height: 5),
            Text("Tjara Child's Day Giveaway",
                style: defaultTextStyle.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                )),
            const SizedBox(height: 15),
            Text(
                "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.",
                style: defaultTextStyle.copyWith(
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                    color: Colors.grey)),
            const SizedBox(height: 20),
            MaterialButton(
              onPressed: () {},
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              minWidth: 140,
              height: 50,
              child: Text('Participate',
                  style: defaultTextStyle.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  )),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}
