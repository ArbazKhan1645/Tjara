import 'package:flutter/material.dart';

class QuantitySelector extends StatefulWidget {
  final TextEditingController controller;
  final int maxQuantity;
  final int minQuantity;
  final ValueChanged<int>? onQuantityChanged;

  const QuantitySelector({
    super.key,
    required this.controller,
    this.maxQuantity = 999,
    this.minQuantity = 1,
    this.onQuantityChanged,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Ensure minimum quantity is set
    if (widget.controller.text.isEmpty ||
        int.tryParse(widget.controller.text) == null ||
        int.parse(widget.controller.text) < widget.minQuantity) {
      widget.controller.text = widget.minQuantity.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  int get currentQuantity {
    return int.tryParse(widget.controller.text) ?? widget.minQuantity;
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity >= widget.minQuantity &&
        newQuantity <= widget.maxQuantity) {
      setState(() {
        widget.controller.text = newQuantity.toString();
      });
      widget.onQuantityChanged?.call(newQuantity);
    }
  }

  void _incrementQuantity() {
    _updateQuantity(currentQuantity + 1);
  }

  void _decrementQuantity() {
    _updateQuantity(currentQuantity - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quantity input field (white background)
        Container(
          width: 90,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.controller.text.isEmpty
                  ? widget.minQuantity.toString()
                  : widget.controller.text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 2), // Small gap between input and buttons
        // Plus and minus buttons (separate red buttons)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Plus button
            GestureDetector(
              onTap:
                  currentQuantity < widget.maxQuantity
                      ? _incrementQuantity
                      : null,
              child: Container(
                width: 30,
                height: 20,
                decoration: BoxDecoration(
                  color:
                      currentQuantity < widget.maxQuantity
                          ? Colors.red
                          : Colors.grey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 14),
              ),
            ),
            const SizedBox(height: 2), // Small gap between buttons
            // Minus button
            GestureDetector(
              onTap:
                  currentQuantity > widget.minQuantity
                      ? _decrementQuantity
                      : null,
              child: Container(
                width: 30,
                height: 20,
                decoration: BoxDecoration(
                  color:
                      currentQuantity > widget.minQuantity
                          ? Colors.red
                          : Colors.grey,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.remove, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
