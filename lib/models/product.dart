import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  final String _baseURL = 'https://shop-app-b0b3a-default-rtdb.firebaseio.com';

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String token, String uid) async {
    try {
      isFavorite = !isFavorite;
      notifyListeners();

      final response = await put(
          Uri.parse('$_baseURL/userFavorite/$uid/$id.json?auth=$token'),
          body: jsonEncode(isFavorite));

      if (response.statusCode >= 400) {
        isFavorite = !isFavorite;
        notifyListeners();
      }
    } catch (_) {
      isFavorite = !isFavorite;
      notifyListeners();
    }
  }
}
