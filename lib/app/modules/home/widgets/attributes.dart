import 'package:flutter/material.dart';
import 'package:tjara/app/models/products/variation.dart';

class ProductVariationDisplay extends StatefulWidget {
  final ProductVariationShop variation;
  final Function(Map<String, Map<String, dynamic>>, String?)
  onAttributesSelected;

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
  // Updated to store name, id, and price for each attribute
  Map<String, Map<String, dynamic>> selectedAttributes = {};
  String? selectedVariationId;

  @override
  void initState() {
    super.initState();
    debugPrint('ProductVariationDisplay initialized');
    debugPrint('Variation data: ${widget.variation}');
  }

  Map<String, List<String>> getUniqueAttributes() {
    final Map<String, List<String>> attributes = {};

    final shopVariations = widget.variation.shop;
    if (shopVariations == null || shopVariations.isEmpty) {
      debugPrint('Shop data is null or empty');
      return attributes;
    }

    for (final variation in shopVariations) {
      final attributeItems = variation.attributes?.attributeItems;
      if (attributeItems == null || attributeItems.isEmpty) {
        debugPrint('attributeItems are null or empty');
        continue;
      }

      for (final item in attributeItems) {
        final attribute = item.attribute;
        final attributeItem = item.attributeItem;

        if (attribute == null || attributeItem == null) {
          debugPrint('attribute or attributeItem is null');
          continue;
        }

        final attributeName = attribute.name?.toString() ?? '';
        final value = attributeItem.name?.toString() ?? '';

        if (attributeName.isEmpty || value.isEmpty) {
          debugPrint('attributeName or value is empty');
          continue;
        }

        attributes.putIfAbsent(attributeName, () => []);
        if (!attributes[attributeName]!.contains(value)) {
          attributes[attributeName]!.add(value);
        }
      }
    }

    debugPrint('Unique attributes: $attributes');
    return attributes;
  }

  // Helper method to get unique attributes and their values
  // Map<String, List<String>> getUniqueAttributes() {
  //   Map<String, List<String>> attributes = {};

  //   if (widget.variation.shop == null) {
  //     debugPrint('Shop data is null');
  //     return attributes; // Return empty map if shop is null
  //   }

  //   for (var variation in widget.variation.shop!) {
  //     if (variation.attributes == null ||
  //         variation.attributes!.attributeItems == null) {
  //       debugPrint('Attributes or attributeItems are null for a variation');
  //       continue; // Skip if attributes or attributeItems are null
  //     }

  //     for (var attributeItem in variation.attributes!.attributeItems!) {
  //       if (attributeItem.attribute == null ||
  //           attributeItem.attributeItem == null) {
  //         debugPrint('Attribute or attributeItem is null');
  //         continue; // Skip if attribute or attributeItem is null
  //       }

  //       String attributeName = attributeItem.attribute!.name.toString();
  //       String value = attributeItem.attributeItem!.name.toString();

  //       if (!attributes.containsKey(attributeName)) {
  //         attributes[attributeName] = [];
  //       }

  //       if (!attributes[attributeName]!.contains(value)) {
  //         attributes[attributeName]!.add(value);
  //       }
  //     }
  //   }

  //   debugPrint('Unique attributes: $attributes');
  //   return attributes;
  // }

  // Helper method to get the ID and price of an attribute value
  Map<String, dynamic> _getAttributeDetails(
    String attributeName,
    String attributeValue,
  ) {
    if (widget.variation.shop == null) {
      return {};
    }

    for (var variation in widget.variation.shop!) {
      if (variation.attributes == null ||
          variation.attributes!.attributeItems == null) {
        continue;
      }

      for (var attributeItem in variation.attributes!.attributeItems!) {
        if (attributeItem.attribute == null ||
            attributeItem.attributeItem == null) {
          continue;
        }

        if (attributeItem.attribute!.name.toString() == attributeName &&
            attributeItem.attributeItem!.name.toString() == attributeValue) {
          return {
            'name': attributeValue,
            'id': attributeItem.attributeItem!.id.toString(),
            'price': variation.price, // Include the price
          };
        }
      }
    }

    return {};
  }

  // Method to find the matching variation based on selected attributes
  dynamic _findMatchingVariation() {
    if (selectedAttributes.isEmpty) {
      debugPrint('No attributes selected yet');
      return null;
    }

    if (widget.variation.shop == null) {
      debugPrint('Shop data is null');
      return null;
    }

    for (var variation in widget.variation.shop!) {
      if (variation.attributes == null ||
          variation.attributes!.attributeItems == null) {
        continue;
      }

      bool isMatch = true;

      for (var entry in selectedAttributes.entries) {
        final String attributeName = entry.key;
        final String attributeValue = entry.value['name']!;

        bool hasMatchingAttribute = false;
        for (var attributeItem in variation.attributes!.attributeItems!) {
          if (attributeItem.attribute == null ||
              attributeItem.attributeItem == null) {
            continue;
          }

          if (attributeItem.attribute!.name.toString() == attributeName &&
              attributeItem.attributeItem!.name.toString() == attributeValue) {
            hasMatchingAttribute = true;
            break;
          }
        }

        if (!hasMatchingAttribute) {
          isMatch = false;
          break;
        }
      }

      if (isMatch) {
        debugPrint('Matching variation found: $variation');
        selectedVariationId = variation.id.toString();
        return variation;
      }
    }

    debugPrint('No matching variation found');
    selectedVariationId = null;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    try {
      final attributes = getUniqueAttributes();
      final matchingVariation = _findMatchingVariation();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price and Stock Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${matchingVariation?.price?.toStringAsFixed(2) ?? widget.variation.shop!.first.price!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              Text(
                '(${matchingVariation?.stock ?? widget.variation.shop![0].stock}) in Stock',
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
                  children:
                      entry.value.map((value) {
                        final isSelected =
                            selectedAttributes[entry.key]?['name'] == value;

                        return entry.key == 'Colors'
                            ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedAttributes[entry.key] =
                                      _getAttributeDetails(entry.key, value);
                                  // Find the matching variation immediately after selection
                                  _findMatchingVariation();
                                });
                                widget.onAttributesSelected(
                                  selectedAttributes,
                                  selectedVariationId,
                                );
                              },
                              child: CircleAvatar(
                                radius: 19,
                                backgroundColor: Colors.grey.shade300,
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: _getColorFromString(value),
                                  child:
                                      isSelected
                                          ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),
                              ),
                            )
                            : InkWell(
                              onTap: () {
                                setState(() {
                                  selectedAttributes[entry.key] =
                                      _getAttributeDetails(entry.key, value);
                                  // Find the matching variation immediately after selection
                                  _findMatchingVariation();
                                });
                                widget.onAttributesSelected(
                                  selectedAttributes,
                                  selectedVariationId,
                                );
                              },
                              child: IntrinsicWidth(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: const Color(0xffF7F7F7),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? Colors.pink
                                              : const Color(0xffDCDCDC),
                                    ),
                                  ),
                                  child: Center(child: Text(value)),
                                ),
                              ),
                            );
                      }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),
        ],
      );
    } catch (e) {
      // Log the error and return a fallback UI
      debugPrint('Error in ProductVariationDisplay: $e');
      return const Center(
        child: Text('Something went wrong. Please try again later.'),
      );
    }
  }
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
    'gold': const Color(0xFFFFD700),
    'silver': const Color(0xFFC0C0C0),
    'bronze': const Color(0xFFCD7F32),
    'maroon': const Color(0xFF800000),
    'navy': const Color(0xFF000080),
    'olive': const Color(0xFF808000),
    'turquoise': const Color(0xFF40E0D0),
    'beige': const Color(0xFFF5F5DC),
    'coral': const Color(0xFFFF7F50),
    'lavender': const Color(0xFFE6E6FA),
    'crimson': const Color(0xFFDC143C),
    'plum': const Color(0xFFDDA0DD),
    'khaki': const Color(0xFFF0E68C),
    'ivory': const Color(0xFFFFFFF0),
    'chartreuse': const Color(0xFF7FFF00),
    'aquamarine': const Color(0xFF7FFFD4),
    'azure': const Color(0xFFF0FFFF),
    'bisque': const Color(0xFFFFE4C4),
    'cadet blue': const Color(0xFF5F9EA0),
    'chocolate': const Color(0xFFD2691E),
    'dark cyan': const Color(0xFF008B8B),
    'dark khaki': const Color(0xFFBDB76B),
    'dark olive green': const Color(0xFF556B2F),
    'dark orchid': const Color(0xFF9932CC),
    'dark salmon': const Color(0xFFE9967A),
    'dark slate gray': const Color(0xFF2F4F4F),
    'dark turquoise': const Color(0xFF00CED1),
    'firebrick': const Color(0xFFB22222),
    'forest green': const Color(0xFF228B22),
    'gainsboro': const Color(0xFFDCDCDC),
    'ghost white': const Color(0xFFF8F8FF),
    'honeydew': const Color(0xFFF0FFF0),
    'hot pink': const Color(0xFFFF69B4),
    'indian red': const Color(0xFFCD5C5C),
    'light coral': const Color(0xFFF08080),
    'light cyan': const Color(0xFFE0FFFF),
    'light goldenrod yellow': const Color(0xFFFAFAD2),
    'light pink': const Color(0xFFFFB6C1),
    'light salmon': const Color(0xFFFFA07A),
    'light sea green': const Color(0xFF20B2AA),
    'light sky blue': const Color(0xFF87CEFA),
    'light slate gray': const Color(0xFF778899),
    'medium aquamarine': const Color(0xFF66CDAA),
    'medium blue': const Color(0xFF0000CD),
    'medium orchid': const Color(0xFFBA55D3),
    'medium purple': const Color(0xFF9370DB),
    'medium sea green': const Color(0xFF3CB371),
    'medium slate blue': const Color(0xFF7B68EE),
    'medium turquoise': const Color(0xFF48D1CC),
    'midnight blue': const Color(0xFF191970),
    'mint cream': const Color(0xFFF5FFFA),
    'misty rose': const Color(0xFFFFE4E1),
    'moccasin': const Color(0xFFFFE4B5),
    'navajo white': const Color(0xFFFFDEAD),
    'old lace': const Color(0xFFFDF5E6),
    'pale goldenrod': const Color(0xFFEEE8AA),
    'pale green': const Color(0xFF98FB98),
    'pale turquoise': const Color(0xFFAFEEEE),
    'pale violet red': const Color(0xFFDB7093),
    'papaya whip': const Color(0xFFFFEFD5),
    'peach puff': const Color(0xFFFFDAB9),
    'peru': const Color(0xFFCD853F),
    'powder blue': const Color(0xFFB0E0E6),
    'rosy brown': const Color(0xFFBC8F8F),
    'royal blue': const Color(0xFF4169E1),
    'saddle brown': const Color(0xFF8B4513),
    'sandy brown': const Color(0xFFF4A460),
    'sea green': const Color(0xFF2E8B57),
    'seashell': const Color(0xFFFFF5EE),
    'sienna': const Color(0xFFA0522D),
    'sky blue': const Color(0xFF87CEEB),
    'slate blue': const Color(0xFF6A5ACD),
    'slate gray': const Color(0xFF708090),
    'spring green': const Color(0xFF00FF7F),
    'steel blue': const Color(0xFF4682B4),
    'tan': const Color(0xFFD2B48C),
    'thistle': const Color(0xFFD8BFD8),
    'tomato': const Color(0xFFFF6347),
    'wheat': const Color(0xFFF5DEB3),
    'white smoke': const Color(0xFFF5F5F5),
  };

  return colors[colorName.toLowerCase()] ??
      Colors.grey; // Default to grey if color not found
}

// Helper method to determine text color based on background
