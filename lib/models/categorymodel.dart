// lib/models/category_model.dart
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final bool isDefault;
  
  const Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.isDefault = false,
  });

   
  
  // Create a copy with updated fields
  Category copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }
  
  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint,
      'icon_family': icon.fontFamily,
      'icon_package': icon.fontPackage,
      'is_default': isDefault,
    };
  }
  
  // Convert to Map for Firestore (referenced in firebaseCloudfire.dart)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint,
      'iconFamily': icon.fontFamily,
      'iconPackage': icon.fontPackage,
      'isDefault': isDefault,
    };
  }
  
  // Create from JSON
   factory Category.fromJson(Map<String, dynamic> json) {

    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(json['color'] as int),
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      isDefault: json['is_default'] as bool? ?? false,
    );

  }

  // Create from Map (Firestore document)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      icon: IconData(
        map['icon'] as int,
        fontFamily: map['iconFamily'] as String?,
        fontPackage: map['iconPackage'] as String?,
      ),
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }
}