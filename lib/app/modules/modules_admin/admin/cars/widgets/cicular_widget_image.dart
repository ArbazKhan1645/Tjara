import 'package:flutter/material.dart';

class CircularWidgetWithImage extends StatelessWidget {
  final String imageUrl;

  const CircularWidgetWithImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white, // Super white border
          width: 4,
        ),
      ),
      child: Container(
        width: 50, // Small circular image inside
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
