import 'package:flutter/material.dart';

Widget tableCellWithFlagStatusAndIcon({
  required int flag,
  required VoidCallback onIconTap,
  TextStyle? style,
}) {
  String displayText;
  IconData iconData;

  if (flag == 1) {
    displayText = "Sold";
    iconData = Icons.edit_note_rounded;
  } else if (flag == 2) {
    displayText = "Yes";
    iconData = Icons.edit_note_rounded;
  } else {
    displayText = "No";
    iconData = Icons.edit_note_rounded;
  }

  return Expanded(
    child: Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          Text(
            displayText,
            style:
                style ??
                const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 5),
          IconButton(
            onPressed: onIconTap,
            icon: Icon(iconData, color: Colors.red, size: 20),
          ),
        ],
      ),
    ),
  );
}
