import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/order.dart';
import 'package:shop/providers/cart.dart';

class OrderList with ChangeNotifier {
  final String _token;
  final String _uid;
  List<Order> _items = [];
  final String _baseURL = 'https://shop-app-b0b3a-default-rtdb.firebaseio.com';

  OrderList([
    this._token = '',
    this._items = const [],
    this._uid = '',
  ]);

  List<Order> get items => [..._items];

  int get itemsCount => _items.length;

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response =
        await post(Uri.parse('$_baseURL/orders/$_uid.json?auth=$_token'),
            body: jsonEncode({
              'total': cart.totalAmount,
              'date': date.toIso8601String(),
              'products': cart.items.values
                  .map((item) => {
                        'id': item.id,
                        'productId': item.productId,
                        'name': item.name,
                        'quantity': item.quantity,
                        'price': item.price
                      })
                  .toList(),
            }));

    final id = jsonDecode(response.body)['name'];

    _items.insert(
      0,
      Order(
        id: id,
        total: cart.totalAmount,
        products: cart.items.values.toList(),
        date: date,
      ),
    );

    notifyListeners();
  }

  Future<void> loadOrders() async {
    _items.clear();
    final response =
        await get(Uri.parse('$_baseURL/orders/$_uid.json?auth=$_token'));
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((orderId, orderData) {
      _items.add(
        (Order(
          id: orderId,
          date: DateTime.parse(orderData['date']),
          total: double.parse(orderData['total'].toString()),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                    id: item['id'],
                    productId: item['productId'],
                    name: item['name'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ))
              .toList(),
        )),
      );
    });

    _items = items.reversed.toList();
    notifyListeners();
  }
}
