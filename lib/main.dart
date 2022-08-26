import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/order_list.dart';
import 'package:shop/providers/product_list.dart';
import 'package:shop/utils/app_routes.dart';
import 'package:shop/utils/custom_route.dart';
import 'package:shop/views/auth_or_home_view.dart';
import 'package:shop/views/cart_view.dart';
import 'package:shop/views/orders_view.dart';
import 'package:shop/views/product_detail_view.dart';
import 'package:shop/views/product_form_view.dart';
import 'package:shop/views/products_view.dart';

void main() async {
  await dotenv.load(fileName: '.emv');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProxyProvider<Auth, ProductList>(
          create: (_) => ProductList(),
          update: (context, auth, previous) {
            return ProductList(
              auth.token ?? '',
              previous?.items ?? [],
              auth.uid ?? '',
            );
          },
        ),
        ChangeNotifierProxyProvider<Auth, OrderList>(
          create: (_) => OrderList(),
          update: (context, auth, previous) {
            return OrderList(
              auth.token ?? '',
              previous?.items ?? [],
              auth.uid ?? '',
            );
          },
        ),
        ChangeNotifierProvider(create: (_) => Cart()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.purple,
          ).copyWith(
            secondary: Colors.deepOrange,
          ),
          fontFamily: 'Lato',
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CustomPageTransitionBuilder(),
          }),
        ),
        initialRoute: AppRoutes.authOrHome,
        routes: {
          AppRoutes.productDetail: (context) => const ProductDetailView(),
          AppRoutes.cart: (context) => const CartView(),
          AppRoutes.order: (context) => const OrdersView(),
          AppRoutes.products: (context) => const ProductsView(),
          AppRoutes.productForm: (context) => const ProductFormView(),
          AppRoutes.authOrHome: (context) => const AuthOrHomeView(),
        },
      ),
    );
  }
}
