import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/providers/cart_provider.dart';
import 'package:shops_app/providers/products_provider.dart';
import 'package:shops_app/screens/cart_screen.dart';
import 'package:shops_app/widgets/app_drawer.dart';
import 'package:shops_app/widgets/badge.dart';
import 'package:shops_app/widgets/products_grid.dart';

enum FilterOptions { Favourites, All }

class ProductsOverviewScreen extends StatefulWidget {
  static const route = "/products-overview";

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var showFavouritesOnly = false;
  var isLoading = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) => {
              setState(() {
                isLoading = false;
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flipkart"),
        actions: [
          PopupMenuButton<FilterOptions>(
            onSelected: (selectedValue) {
              if (selectedValue == FilterOptions.Favourites) {
                setState(() {
                  showFavouritesOnly = true;
                });
                return;
              }
              setState(() {
                showFavouritesOnly = false;
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                enabled: !showFavouritesOnly,
                child: Text("Only Favourites"),
                value: FilterOptions.Favourites,
              ),
              PopupMenuItem(
                enabled: showFavouritesOnly,
                child: Text("Show All"),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, carts, child) => Badge(
              value: carts.totalItems.toString(),
              child: child!,
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.route);
              },
              icon: Icon(
                Icons.shopping_cart,
              ),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(
              showFavouritesOnly: showFavouritesOnly,
            ),
    );
  }
}
