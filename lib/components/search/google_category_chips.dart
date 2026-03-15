import 'package:flutter/material.dart';

class GoogleCategoryChips extends StatelessWidget {
  final Function(String) onCategoryPressed;

  const GoogleCategoryChips({super.key, required this.onCategoryPressed});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.restaurant, 'label': 'レストラン'},
      {'icon': Icons.local_gas_station, 'label': 'ガソリン'},
      {'icon': Icons.hotel, 'label': 'ホテル'},
      {'icon': Icons.local_cafe, 'label': 'カフェ'},
      {'icon': Icons.shopping_bag, 'label': 'ショッピング'},
    ];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: Icon(category['icon'] as IconData, size: 16),
              label: Text(category['label'] as String),
              onPressed: () => onCategoryPressed(category['label'] as String),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          );
        },
      ),
    );
  }
}
