import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/providers/products_provider.dart';
import 'package:shops_app/screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id, title, imageURL;

  UserProductItem(
      {required this.id, required this.title, required this.imageURL});

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageURL),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditProductsScreen.route, arguments: id);
            },
            icon: Icon(Icons.edit),
            color: Theme.of(context).primaryColor,
          ),
          IconButton(
            onPressed: () async {
              try {
                await Provider.of<Products>(context, listen: false)
                    .deleteProduct(id);
              } catch (_) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      "Deleting Product Failed",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
            },
            icon: Icon(Icons.delete),
            color: Theme.of(context).errorColor,
          ),
        ],
      ),
    );
  }
}
