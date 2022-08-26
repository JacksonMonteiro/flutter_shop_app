import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/models/product.dart';

class ProductList with ChangeNotifier {
  final String _uid;
  final String _token;
  // ignore: prefer_final_fields
  List<Product> _items = [];
  final String _baseURL = 'https://shop-app-b0b3a-default-rtdb.firebaseio.com';

  List<Product> get items => [..._items];
  List<Product> get favoriteItems =>
      _items.where((product) => product.isFavorite).toList();

  int get itemsCount => _items.length;

  ProductList([this._token = '', this._items = const [], this._uid = '']);

  Future<void> addProduct(Product product) async {
    final response =
        await post(Uri.parse('$_baseURL/products.json?auth=$_token'),
            body: jsonEncode({
              'name': product.title,
              'description': product.description,
              'price': product.price,
              'imageURL': product.imageUrl,
            }));

    final id = jsonDecode(response.body)['name'];

    _items.add(Product(
      id: id,
      title: product.title,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
    ));

    notifyListeners();
  }

  Future<void> loadProducts() async {
    _items.clear();
    final response =
        await get(Uri.parse('$_baseURL/products.json?auth=$_token'));

    if (response.body == 'null') return;

    final favResponse = await get(
      Uri.parse('$_baseURL/userFavorite/$_uid.json?auth=$_token'),
    );

    Map<String, dynamic> favData =
        favResponse.body == 'null' ? {} : jsonDecode(favResponse.body);

    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((productId, productData) {
      final isFavorite = favData[productId] ?? false;

      _items.add((Product(
        id: productId,
        description: productData['description'],
        imageUrl: productData['imageURL'],
        title: productData['name'],
        price: productData['price'],
        isFavorite: isFavorite,
      )));
    });

    notifyListeners();
  }

  Future<void> saveProduct(Map<String, dynamic> data) {
    bool hasId = data['id'] != null;

    final product = Product(
        id: hasId ? data['id'] : Random().nextDouble().toString(),
        title: data['name'],
        description: data['description'],
        price: data['price'],
        imageUrl: data['imageURL']);

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((element) => element.id == product.id);

    if (index >= 0) {
      await patch(
        Uri.parse('$_baseURL/products/${product.id}.json?auth=$_token'),
        body: jsonEncode(
          {
            "name": product.title,
            "description": product.description,
            "price": product.price,
            "imageURL": product.imageUrl,
          },
        ),
      );

      _items[index] = product;
      notifyListeners();
    }

    return Future.value();
  }

  Future<void> removeProduct(Product product) async {
    int index = _items.indexWhere((element) => element.id == product.id);
    if (index >= 0) {
      final product = _items[index];

      _items.remove(product);
      notifyListeners();

      final response = await delete(
        Uri.parse('$_baseURL/products/${product.id}.json?auth=$_token'),
      );

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException(
            message: 'Não foi possível deletar o produto',
            statusCode: response.statusCode);
      }
    }
  }
}
