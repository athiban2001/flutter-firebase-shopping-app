import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/providers/products_provider.dart';
import 'package:shops_app/screens/edit_product_screen.dart';
import 'package:shops_app/widgets/app_drawer.dart';
import 'package:shops_app/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const route = "/user-products";

  Future<void> fetchProducts(BuildContext context) {
    return Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(filterByUser: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Products"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductsScreen.route);
            },
            icon: Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: fetchProducts(context),
        builder: (context, snapshot) => Consumer<Products>(
          builder: (context, products, _) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => fetchProducts(context),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: products.products.length,
                          itemBuilder: (_, index) => Column(
                            children: [
                              UserProductItem(
                                id: products.products[index].id,
                                title: products.products[index].title,
                                imageURL: products.products[index].imageURL,
                              ),
                              Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
