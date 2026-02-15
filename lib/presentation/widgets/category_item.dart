import 'package:flutter/material.dart';
import 'package:amork/data/models/category_model.dart';
class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;

  const CategoryItem({
    super.key,
    required this.category,
    this.isSelected = false
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFD54F) : const Color(0xFFFFF8E1), // Active/Inactive colors
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Image.network(
              category.icon,
              errorBuilder: (c, o, s) => const Icon(Icons.restaurant, color: Colors.orange),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}