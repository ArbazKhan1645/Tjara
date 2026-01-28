import 'package:flutter/material.dart';

class EditInfofield extends StatelessWidget {
  final String initial;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final maxlines;

  const EditInfofield({super.key, 
    required this.initial,
    this.controller,
    this.onChanged,
    this.maxlines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        maxLines: maxlines,
        initialValue: initial,
        style: TextStyle(fontSize: 16, color: Colors.blueGrey[700]),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.blueGrey.shade100),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.blueGrey.shade100),
          ),
        ),
      ),
    );
  }
}
