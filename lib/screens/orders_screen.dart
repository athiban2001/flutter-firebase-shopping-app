import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/providers/orders_provider.dart' show Orders;
import 'package:shops_app/widgets/app_drawer.dart';
import 'package:shops_app/widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const route = "/orders-screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return Consumer<Orders>(
            builder: (context, orders, _) => ListView.builder(
              itemCount: orders.orders.length,
              itemBuilder: (context, index) => OrderItem(
                order: orders.orders[index],
              ),
            ),
          );
        },
      ),
    );
  }
}
