import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/views/auth_view.dart';
import 'package:shop/views/products_over_view.dart';

class AuthOrHomeView extends StatelessWidget {
  const AuthOrHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of(
      context,
    );

    return FutureBuilder(
        future: auth.tryAutoLogin(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.error != null) {
            return const Center(
              child: Text('Ocurred an error'),
            );
          } else {
            return auth.isAuth ? const ProductsOverView() : const AuthView();
          }
        }));
  }
}
