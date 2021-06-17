import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shops_app/helpers/custom_route.dart';
import 'package:shops_app/providers/auth_provider.dart';
import 'package:shops_app/providers/cart_provider.dart';
import 'package:shops_app/providers/orders_provider.dart';
import 'package:shops_app/providers/products_provider.dart';
import 'package:shops_app/screens/auth_screen.dart';
import 'package:shops_app/screens/cart_screen.dart';
import 'package:shops_app/screens/edit_product_screen.dart';
import 'package:shops_app/screens/orders_screen.dart';
import 'package:shops_app/screens/product_details_screen.dart';
import 'package:shops_app/screens/products_overview_screen.dart';
import 'package:shops_app/screens/splash_screen.dart';
import 'package:shops_app/screens/user_products_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => Cart(),
          lazy: false,
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) {
            final auth = Provider.of<Auth>(context, listen: false);
            return Products([], auth.token, auth.userID);
          },
          update: (_, auth, prevProducts) => Products(
            prevProducts?.products ?? [],
            auth.token,
            auth.userID,
          ),
          lazy: false,
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) {
            final auth = Provider.of<Auth>(context, listen: false);
            return Orders([], auth.token, auth.userID);
          },
          update: (_, auth, prevOrders) =>
              Orders(prevOrders?.orders ?? [], auth.token, auth.userID),
          lazy: false,
        ),
      ],
      builder: (context, __) {
        final auth = Provider.of<Auth>(context);

        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: "Lato",
          ),
          home: auth.isAuthenticated
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SplashScreen();
                    }

                    return AuthScreen();
                  },
                ),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case ProductsOverviewScreen.route:
                return MaterialPageRoute(
                  builder: (_) => ProductsOverviewScreen(),
                );
              case ProductDetailsScreen.route:
                final productID = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(productID: productID),
                );
              case CartScreen.route:
                return MaterialPageRoute(
                  builder: (_) => CartScreen(),
                );
              case OrdersScreen.route:
                return CustomRoute(
                  builder: (_) => OrdersScreen(),
                  settings: settings,
                );
              case UserProductsScreen.route:
                return MaterialPageRoute(
                  builder: (_) => UserProductsScreen(),
                );
              case EditProductsScreen.route:
                var id = "";
                if (settings.arguments != null) {
                  id = settings.arguments as String;
                }
                return MaterialPageRoute(
                  builder: (_) => EditProductsScreen(productID: id),
                );
              case AuthScreen.route:
                return MaterialPageRoute(
                  builder: (_) => AuthScreen(),
                );
            }
          },
        );
      },
    );
  }
}
