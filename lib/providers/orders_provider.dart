import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shops_app/providers/cart_provider.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime time;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.time,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders;
  final String? authToken;
  final String? userID;

  Orders(this._orders, this.authToken, this.userID);

  List<OrderItem> get orders => _orders;

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
      "https://flutter-shop-2a40d-default-rtdb.firebaseio.com/orders$userID.json?auth=$authToken",
    );
    final response = await http.get(url);
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    final List<OrderItem> orders = [];

    responseData.forEach((orderID, order) {
      final List<CartItem> products = [];
      (order["items"] as Map<String, dynamic>).forEach((cartItemID, cartItem) {
        products.add(
          CartItem(
            id: cartItemID,
            title: cartItem["title"],
            price: cartItem["price"],
            quantity: cartItem["quantity"],
          ),
        );
      });

      orders.add(OrderItem(
        id: orderID,
        amount: order["amount"],
        products: products,
        time: DateTime.parse(order["time"]),
      ));
    });

    _orders = orders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
      "https://flutter-shop-2a40d-default-rtdb.firebaseio.com/orders/$userID.json?auth=$authToken",
    );
    final Map<String, dynamic> cartMap = {};
    final time = DateTime.now();
    cartProducts.forEach((cartItem) {
      cartMap[cartItem.id] = {
        "title": cartItem.title,
        "price": cartItem.price,
        "quantity": cartItem.quantity,
      };
    });
    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            "amount": total,
            "time": time.toIso8601String(),
            "items": cartMap,
          },
        ),
      );
      _orders.insert(
        0,
        OrderItem(
          id: jsonDecode(response.body)["name"],
          amount: total,
          time: time,
          products: cartProducts,
        ),
      );
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}
