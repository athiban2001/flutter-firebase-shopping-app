import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/providers/product_provider.dart';
import 'package:shops_app/providers/products_provider.dart';
import 'package:shops_app/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavouritesOnly;

  ProductsGrid({required this.showFavouritesOnly});

  @override
  Widget build(BuildContext context) {
    List<Product> products;
    if (showFavouritesOnly) {
      products = Provider.of<Products>(context).favouriteProducts;
    } else {
      products = Provider.of<Products>(context).products;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: products[index],
        child: ProductItem(),
      ),
    );
  }
}
