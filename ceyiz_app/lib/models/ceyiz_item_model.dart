import 'package:equatable/equatable.dart';

class CeyizItemModel extends Equatable {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final bool isPurchased;
  final List<String> photoUrls;
  final DateTime createdAt;

  const CeyizItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.isPurchased = false,
    this.photoUrls = const [],
    required this.createdAt,
  });

  CeyizItemModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    double? price,
    bool? isPurchased,
    List<String>? photoUrls,
    DateTime? createdAt,
  }) {
    return CeyizItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      isPurchased: isPurchased ?? this.isPurchased,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'isPurchased': isPurchased,
      'photoUrls': photoUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CeyizItemModel.fromJson(Map<String, dynamic> json) {
    return CeyizItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      isPurchased: json['isPurchased'] as bool,
      photoUrls: (json['photoUrls'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, category, description, price, isPurchased, photoUrls, createdAt];
}
