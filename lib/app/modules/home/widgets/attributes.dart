import 'package:flutter/material.dart';
import '../../../models/products/variation.dart';

class ProductVariationDisplay extends StatefulWidget {
  final ProductVariationShop variation;
  final Function(Map<String, String>) onAttributesSelected;

  const ProductVariationDisplay({
    super.key,
    required this.variation,
    required this.onAttributesSelected,
  });

  @override
  State<ProductVariationDisplay> createState() =>
      _ProductVariationDisplayState();
}

class _ProductVariationDisplayState extends State<ProductVariationDisplay> {
  Map<String, String> selectedAttributes = {};

  Map<String, List<String>> getUniqueAttributes() {
    Map<String, List<String>> attributes = {};

    for (var variation in widget.variation.shop!) {
      for (var attributeItem in variation.attributes!.attributeItems!) {
        String attributeName = attributeItem.attribute!.name.toString();
        String value = attributeItem.attributeItem!.name.toString();

        if (!attributes.containsKey(attributeName)) {
          attributes[attributeName] = [];
        }
        if (!attributes[attributeName]!.contains(value)) {
          attributes[attributeName]!.add(value);
        }
      }
    }

    return attributes;
  }

  @override
  Widget build(BuildContext context) {
    final attributes = getUniqueAttributes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price and Stock Display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${widget.variation.shop!.first.price!.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            Text(
              '(${widget.variation.shop!.first.stock}) Available in Stock',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Attributes Selection
        ...attributes.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${entry.key}:',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Attribute Options
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: entry.value.map((value) {
                  final isSelected = selectedAttributes[entry.key] == value;

                  return entry.key == 'Colors'
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAttributes[entry.key] = value;
                            });
                            widget.onAttributesSelected(selectedAttributes);
                          },
                          child: CircleAvatar(
                              radius: 19,
                              backgroundColor: Colors.grey.shade300,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: _getColorFromString(value),
                                child: isSelected
                                    ? Icon(Icons.check, color: Colors.white)
                                    : null,
                              )),
                        )
                      : InkWell(
                          onTap: () {
                            setState(() {
                              selectedAttributes[entry.key] = value;
                            });
                            widget.onAttributesSelected(selectedAttributes);
                          },
                          child: Container(
                            height: 40,
                            width: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: Color(0xffF7F7F7),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.pink
                                      : Color(0xffDCDCDC),
                                )),
                            child: Center(child: Text(value)),
                          ));
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          );
        }),
      ],
    );
  }

  // Helper method to convert color string to Color object
  Color _getColorFromString(String colorName) {
    final colors = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'black': Colors.black,
      'white': Colors.white,
      'yellow': Colors.yellow,
      'pink': Colors.pink,
      'purple': Colors.purple,
      'orange': Colors.orange,
      'brown': Colors.brown,
      'cyan': Colors.cyan,
      'indigo': Colors.indigo,
      'teal': Colors.teal,
      'amber': Colors.amber,
      'lime': Colors.lime,
      'deep orange': Colors.deepOrange,
      'deep purple': Colors.deepPurple,
      'light blue': Colors.lightBlue,
      'light green': Colors.lightGreen,
      'grey': Colors.grey,
      'blue grey': Colors.blueGrey,
      'gold': Color(0xFFFFD700),
      'silver': Color(0xFFC0C0C0),
      'bronze': Color(0xFFCD7F32),
      'maroon': Color(0xFF800000),
      'navy': Color(0xFF000080),
      'olive': Color(0xFF808000),
      'turquoise': Color(0xFF40E0D0),
      'beige': Color(0xFFF5F5DC),
      'coral': Color(0xFFFF7F50),
      'lavender': Color(0xFFE6E6FA),
      'crimson': Color(0xFFDC143C),
      'plum': Color(0xFFDDA0DD),
      'khaki': Color(0xFFF0E68C),
      'ivory': Color(0xFFFFFFF0),
      'chartreuse': Color(0xFF7FFF00),
      'aquamarine': Color(0xFF7FFFD4),
      'azure': Color(0xFFF0FFFF),
      'bisque': Color(0xFFFFE4C4),
      'cadet blue': Color(0xFF5F9EA0),
      'chocolate': Color(0xFFD2691E),
      'dark cyan': Color(0xFF008B8B),
      'dark khaki': Color(0xFFBDB76B),
      'dark olive green': Color(0xFF556B2F),
      'dark orchid': Color(0xFF9932CC),
      'dark salmon': Color(0xFFE9967A),
      'dark slate gray': Color(0xFF2F4F4F),
      'dark turquoise': Color(0xFF00CED1),
      'firebrick': Color(0xFFB22222),
      'forest green': Color(0xFF228B22),
      'gainsboro': Color(0xFFDCDCDC),
      'ghost white': Color(0xFFF8F8FF),
      'honeydew': Color(0xFFF0FFF0),
      'hot pink': Color(0xFFFF69B4),
      'indian red': Color(0xFFCD5C5C),
      'light coral': Color(0xFFF08080),
      'light cyan': Color(0xFFE0FFFF),
      'light goldenrod yellow': Color(0xFFFAFAD2),
      'light pink': Color(0xFFFFB6C1),
      'light salmon': Color(0xFFFFA07A),
      'light sea green': Color(0xFF20B2AA),
      'light sky blue': Color(0xFF87CEFA),
      'light slate gray': Color(0xFF778899),
      'medium aquamarine': Color(0xFF66CDAA),
      'medium blue': Color(0xFF0000CD),
      'medium orchid': Color(0xFFBA55D3),
      'medium purple': Color(0xFF9370DB),
      'medium sea green': Color(0xFF3CB371),
      'medium slate blue': Color(0xFF7B68EE),
      'medium turquoise': Color(0xFF48D1CC),
      'midnight blue': Color(0xFF191970),
      'mint cream': Color(0xFFF5FFFA),
      'misty rose': Color(0xFFFFE4E1),
      'moccasin': Color(0xFFFFE4B5),
      'navajo white': Color(0xFFFFDEAD),
      'old lace': Color(0xFFFDF5E6),
      'pale goldenrod': Color(0xFFEEE8AA),
      'pale green': Color(0xFF98FB98),
      'pale turquoise': Color(0xFFAFEEEE),
      'pale violet red': Color(0xFFDB7093),
      'papaya whip': Color(0xFFFFEFD5),
      'peach puff': Color(0xFFFFDAB9),
      'peru': Color(0xFFCD853F),
      'powder blue': Color(0xFFB0E0E6),
      'rosy brown': Color(0xFFBC8F8F),
      'royal blue': Color(0xFF4169E1),
      'saddle brown': Color(0xFF8B4513),
      'sandy brown': Color(0xFFF4A460),
      'sea green': Color(0xFF2E8B57),
      'seashell': Color(0xFFFFF5EE),
      'sienna': Color(0xFFA0522D),
      'sky blue': Color(0xFF87CEEB),
      'slate blue': Color(0xFF6A5ACD),
      'slate gray': Color(0xFF708090),
      'spring green': Color(0xFF00FF7F),
      'steel blue': Color(0xFF4682B4),
      'tan': Color(0xFFD2B48C),
      'thistle': Color(0xFFD8BFD8),
      'tomato': Color(0xFFFF6347),
      'wheat': Color(0xFFF5DEB3),
      'white smoke': Color(0xFFF5F5F5),
    };

    return colors[colorName.toLowerCase()] ??
        Colors.grey; // Default to grey if color not found
  }

  // Helper method to determine text color based on background
  Color _getContrastColor(Color backgroundColor) {
    if (ThemeData.estimateBrightnessForColor(backgroundColor) ==
        Brightness.dark) {
      return Colors.white;
    }
    return Colors.black;
  }
}
