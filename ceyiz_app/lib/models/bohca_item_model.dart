import 'package:equatable/equatable.dart';

class BohcaItemModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final bool isPurchased;
  final List<String> photoUrls;
  final DateTime createdAt;

  const BohcaItemModel({
    required this.id,
    required this.name,
    required this.description,
    this.category = 'Bohça',
    required this.price,
    this.isPurchased = false,
    required this.photoUrls,
    required this.createdAt,
  });

  BohcaItemModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    bool? isPurchased,
    List<String>? photoUrls,
    DateTime? createdAt,
  }) {
    return BohcaItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
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
      'description': description,
      'category': category,
      'price': price,
      'isPurchased': isPurchased,
      'photoUrls': photoUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BohcaItemModel.fromJson(Map<String, dynamic> json) {
    return BohcaItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String? ?? 'Bohça',
      price: (json['price'] as num).toDouble(),
      isPurchased: json['isPurchased'] as bool? ?? false,
      photoUrls: (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        price,
        isPurchased,
        photoUrls,
        createdAt,
      ];
}
