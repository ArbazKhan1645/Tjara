import 'package:flutter/material.dart';
import 'package:tjara/app/core/utils/thems/theme.dart';

class JobSearchBox extends StatelessWidget {
  const JobSearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 80, bottom: 50, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Color(0xFF2C3E50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "There Are ",
              style:
                  defaultTextStyle.copyWith(fontSize: 25, color: Colors.white),
              children: [
                TextSpan(
                  text: "93,178",
                  style: defaultTextStyle.copyWith(
                    fontSize: 25,
                    color: Color(0xFFFFEB3B),
                  ),
                ),
                TextSpan(
                  text: " Postings \n Here For you!",
                ),
              ],
            ),
          ),
          SizedBox(height: 25),
          // Search Box 1
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Job title, keywords, or company",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          // Search Box 2
          Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "City or postcode",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25),
          // Find Jobs Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFD9183B), // Red Color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Find Jobs",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
