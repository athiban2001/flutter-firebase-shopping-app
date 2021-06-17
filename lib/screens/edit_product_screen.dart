import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/providers/product_provider.dart';
import 'package:shops_app/providers/products_provider.dart';

class EditProductsScreen extends StatefulWidget {
  static const route = "/edit-products";

  final String productID;

  EditProductsScreen({required this.productID});

  @override
  _EditProductsScreenState createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  final imageInputController = TextEditingController();
  final imageURLFocusNode = FocusNode();
  final form = GlobalKey<FormState>();
  var isLoading = false;
  final Map<String, dynamic> formValues = {
    "title": "",
    "description": "",
    "imageURL": "",
    "price": 0.00,
  };

  void initState() {
    super.initState();
    imageURLFocusNode.addListener(updateImageURL);
    if (widget.productID != "") {
      final product = Provider.of<Products>(context, listen: false)
          .findProductByID(widget.productID);
      formValues["title"] = product.title;
      formValues["description"] = product.description;
      formValues["imageURL"] = product.imageURL;
      imageInputController.text = formValues["imageURL"];
      formValues["price"] = product.price;
    }
  }

  void updateImageURL() {
    if (!imageURLFocusNode.hasFocus && imageInputController.text.isNotEmpty) {
      final urlPattern =
          r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
      if (RegExp(urlPattern, caseSensitive: false)
              .firstMatch(imageInputController.text) ==
          null) {
        return;
      }
      setState(() {});
    }
  }

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

  Future<void> saveForm() async {
    if (form.currentState?.validate() ?? false) {
      form.currentState?.save();
      if (widget.productID == "") {
        try {
          setState(() {
            isLoading = true;
          });
          await Provider.of<Products>(context, listen: false).addProduct(
            formValues["title"],
            formValues["description"],
            formValues["imageURL"],
            formValues["price"],
          );
        } catch (_) {
          await showAlertDialog();
        } finally {
          setState(() {
            isLoading = false;
          });
          Navigator.of(context).pop();
        }
      } else {
        try {
          setState(() {
            isLoading = true;
          });
          await Provider.of<Products>(context, listen: false).editProduct(
            Product(
              id: widget.productID,
              title: formValues["title"],
              description: formValues["description"],
              imageURL: formValues["imageURL"],
              price: formValues["price"],
            ),
          );
        } catch (_) {
          await showAlertDialog();
        } finally {
          setState(() {
            isLoading = false;
          });
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(imageInputController.text);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: [
          IconButton(
            onPressed: saveForm,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: form,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Title",
                      ),
                      initialValue: formValues["title"],
                      textInputAction: TextInputAction.next,
                      onSaved: (title) {
                        formValues["title"] = title;
                      },
                      validator: (title) {
                        if (title?.length == 0) {
                          return "Please Enter a Title";
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: "Price",
                      ),
                      initialValue:
                          (formValues["price"] as double).toStringAsFixed(2),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onSaved: (price) {
                        formValues["price"] = double.parse(price ?? "0.00");
                      },
                      validator: (price) {
                        if (price?.length == 0) {
                          return "Please Enter a Price";
                        }
                        if (double.tryParse(price ?? "0.00") == null) {
                          return "Please Enter a Valid Number";
                        }
                        if (double.parse(price ?? "0.00") <= 0) {
                          return "Please Enter a number greater than 0";
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Description",
                      ),
                      initialValue: formValues["description"],
                      keyboardType: TextInputType.multiline,
                      onSaved: (description) {
                        formValues["description"] = description;
                      },
                      validator: (description) {
                        if (description?.length == 0) {
                          return "Please Enter a description";
                        }
                        if ((description ?? "").length < 10) {
                          return "Should be atleast 10 characters long.";
                        }

                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: imageInputController.text.isEmpty
                              ? Center(
                                  child: Text("Enter URL"),
                                )
                              : FittedBox(
                                  child: Image.network(
                                    imageInputController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Image URL",
                            ),
                            controller: imageInputController,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            focusNode: imageURLFocusNode,
                            onFieldSubmitted: (_) => saveForm(),
                            onSaved: (imageURL) {
                              formValues["imageURL"] = imageURL;
                            },
                            validator: (imageURL) {
                              if (imageURL?.length == 0) {
                                return "Please Enter a URL";
                              }
                              final urlPattern =
                                  r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
                              if (RegExp(urlPattern, caseSensitive: false)
                                      .firstMatch(imageURL ?? "") ==
                                  null) {
                                return "Please Enter a Valid URL";
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    imageURLFocusNode.removeListener(updateImageURL);
    imageURLFocusNode.dispose();
    imageInputController.dispose();
    super.dispose();
  }
}
