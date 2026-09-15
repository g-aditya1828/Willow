import 'package:flutter/material.dart';

enum TagType { alert, clean, swap, warning }

class FoodItem {
  final String id;
  final String category;
  final String title;
  final String subtitle;
  final double price;
  final double rating;
  final String imageUrl;
  final String tagText;
  final TagType tagType;

  const FoodItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.tagText,
    required this.tagType,
  });
}
