import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final IconData iconData;
  final Color color;
  final String route;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconData,
    required this.color,
    required this.route,
  });
}
