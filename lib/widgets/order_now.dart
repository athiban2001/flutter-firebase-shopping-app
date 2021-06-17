import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/providers/cart_provider.dart';
import 'package:shops_app/providers/orders_provider.dart';

class OrderNow extends StatefulWidget {
  final Cart cart;

  OrderNow({required this.cart});

  @override
  _OrderNowState createState() => _OrderNowState();
}

class _OrderNowState extends State<OrderNow> {
  var isLoading = false;

  FutureOr<Null> showAlertDialog() {
    return showDialog<Null>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("An Error Occured"),
        content: Text("Something went wrong. Please try again later!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Okay"),
          ),
        ],
      ),
    );
  }

  void addOrder() async {
    setState(() {
      isLoading = true;
    });
    try {
      await Provider.of<Orders>(context, listen: false).addOrder(
        widget.cart.items.values.toList(),
        widget.cart.totalAmount,
      );
      widget.cart.clear();
    } catch (_) {
      await showAlertDialog();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      child: TextButton(
        onPressed: isLoading || widget.cart.totalItems == 0 ? null : addOrder,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isLoading) CircularProgressIndicator(),
            Text(
              "ORDER NOW",
              style: TextStyle(
                color: isLoading
                    ? Theme.of(context).primaryColor.withOpacity(0.3)
                    : Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
