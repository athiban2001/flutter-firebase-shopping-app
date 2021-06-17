import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/widgets.dart';
import 'package:shops_app/providers/product_provider.dart';

class Products with ChangeNotifier {
  // List<Product> _products = [
  //   Product(
  //     id: 'p1',
  //     title: 'Red Shirt',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageURL:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   Product(
  //     id: 'p2',
  //     title: 'Trousers',
  //     description: 'A nice pair of trousers.',
  //     price: 59.99,
  //     imageURL:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  //   ),
  //   Product(
  //     id: 'p3',
  //     title: 'Yellow Scarf',
  //     description: 'Warm and cozy - exactly what you need for the winter.',
  //     price: 19.99,
  //     imageURL:
  //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  //   ),
  //   Product(
  //     id: 'p4',
  //     title: 'A Pan',
  //     description: 'Prepare any meal you want.',
  //     price: 49.99,
  //     imageURL:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  //   ),
  // ];
  final String? authToken;
  final String? userID;
  List<Product> _products;

  Products(this._products, this.authToken, this.userID);

  List<Product> get products {
    return _products;
  }

  List<Product> get favouriteProducts {
    return _products.where((product) => product.isFavourite).toList();
  }

  Product findProductByID(String productID) {
    return _products.firstWhere((product) => product.id == productID);
  }

  Future<void> fetchAndSetProducts({bool filterByUser = false}) async {
    final filters = filterByUser ? '&orderBy="userID"&equalTo="$userID"' : '';
    final prodURL = Uri.parse(
      'https://flutter-shop-2a40d-default-rtdb.firebaseio.com/products.json?auth=$authToken$filters',
    );
    final prodResponse = await http.get(prodURL);
    final prodResponseBody =
        jsonDecode(prodResponse.body) as Map<String, dynamic>?;

    if (prodResponseBody == null) {
      return;
    }

    final favURL = Uri.parse(
      "https://flutter-shop-2a40d-default-rtdb.firebaseio.com/userFavourites/$userID.json?auth=$authToken",
    );
    final favResponse = await http.get(favURL);
    final favResponseBody =
        jsonDecode(favResponse.body) as Map<String, dynamic>?;

    final List<Product> fetchedProducts = [];
    prodResponseBody.forEach(
      (key, value) {
        bool isFavourite = false;
        if (favResponseBody == null) {
          isFavourite = false;
        } else if (favResponseBody[key] != null) {
          isFavourite = favResponseBody[key];
        }
        final product = Product(
          id: key,
          title: value["title"],
          description: value["description"],
          imageURL: value["imageURL"],
          price: value["price"],
          isFavourite: isFavourite,
        );
        fetchedProducts.add(product);
      },
    );
    _products = fetchedProducts;
    notifyListeners();
  }

  Future<void> addProduct(
      String title, String description, String imageURL, double price) async {
    final url = Uri.parse(
      "https://flutter-shop-2a40d-default-rtdb.firebaseio.com/products.json?auth=$authToken",
    );
    var response = await http.post(
      url,
      headers: {
        "content-type": "application/json",
      },
      body: jsonEncode(
        {
          "title": title,
          "description": description,
          "imageURL": imageURL,
          "price": price,
          "userID": userID,
        },
      ),
    );
    _products.add(
      Product(
        id: jsonDecode(response.body)["name"],
        title: title,
        description: description,
        price: price,
        imageURL: imageURL,
      ),
    );
    notifyListeners();
  }

  Future<void> editProduct(Product product) async {
    final url = Uri.parse(
      "https://flutter-shop-2a40d-default-rtdb.firebaseio.com/products/${product.id}.json?auth=$authToken",
    );
    final productIndex = _products.indexWhere((prod) => prod.id == product.id);
    if (productIndex >= 0) {
      await http.patch(
        url,
        body: jsonEncode({
          "title": product.title,
          "description": product.description,
          "price": product.price,
          "imageURL": product.imageURL,
        }),
      );
      _products[productIndex] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productID) async {
    final url = Uri.parse(
      "https://flutter-shop-2a40d-default-rtdb.firebaseio.com/products/$productID.json?auth=$authToken",
    );
    final productIndex =
        _products.indexWhere((product) => product.id == productID);
    final product = _products[productIndex];
    _products.removeWhere((product) => product.id == productID);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode > 400) {
      _products.insert(productIndex, product);
      notifyListeners();
      throw Error();
    }
  }
}
