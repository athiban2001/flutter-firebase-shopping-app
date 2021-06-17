import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id, title, description, imageURL;
  final double price;
  bool isFavourite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageURL,
    this.isFavourite = false,
  });

  Future<void> toggleFavourite(String? token, String? userID) async {
    final url = Uri.parse(
      "https://flutter-shop-2a40d-default-rtdb.firebaseio.com/userFavourites/$userID/$id.json?auth=$token",
    );
    isFavourite = !isFavourite;
    notifyListeners();
    try {
      await http.put(
        url,
        body: jsonEncode(
          isFavourite,
        ),
      );
    } catch (e) {
      isFavourite = !isFavourite;
      notifyListeners();
      throw e;
    }
  }
}
