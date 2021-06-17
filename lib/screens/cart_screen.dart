import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/providers/cart_provider.dart' show Cart;
import 'package:shops_app/widgets/cart_item.dart';
import 'package:shops_app/widgets/order_now.dart';

class CartScreen extends StatelessWidget {
  static const route = "/cart-screen";

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Shopping Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      "\$${cart.totalAmount.toStringAsFixed(2)}",
                      style: Theme.of(context).primaryTextTheme.bodyText1,
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderNow(cart: cart),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: cart.totalItems,
                itemBuilder: (context, index) {
                  final cartItem = cart.items.values.toList()[index];
                  return CartItem(
                    id: cartItem.id,
                    title: cartItem.title,
                    price: cartItem.price,
                    quantity: cartItem.quantity,
                    productID: cart.items.keys.toList()[index],
                  );
                }),
          ),
        ],
      ),
    );
  }
}
