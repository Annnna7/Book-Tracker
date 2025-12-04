import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/book_model.dart';

class WishlistProvider extends ChangeNotifier {
  List<Book> _wishlistBooks = [];
  static const String _wishlistKey = 'wishlist_books';

  List<Book> get wishlistBooks => _wishlistBooks;

  WishlistProvider() {
    _loadWishlist();
  }

  // Загрузка вишлиста из SharedPreferences
  Future<void> _loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? wishlistJson = prefs.getString(_wishlistKey);
      
      if (wishlistJson != null && wishlistJson.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(wishlistJson);
        _wishlistBooks = jsonList
            .map((item) => Book.fromMap(item))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Ошибка загрузки вишлиста: $e');
    }
  }

  // Сохранение вишлиста в SharedPreferences
  Future<void> _saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _wishlistBooks.map((book) => book.toMap()).toList();
      final wishlistJson = json.encode(jsonList);
      await prefs.setString(_wishlistKey, wishlistJson);
    } catch (e) {
      print('Ошибка сохранения вишлиста: $e');
    }
  }

  // Добавление книги в вишлист
  Future<void> addToWishlist(Book book) async {
    // Проверяем, нет ли уже такой книги
    if (!_wishlistBooks.any((item) => item == book)) {
      _wishlistBooks.add(book);
      await _saveWishlist();
      notifyListeners();
    }
  }

  // Удаление книги из вишлиста
  Future<void> removeFromWishlist(Book book) async {
    _wishlistBooks.removeWhere((item) => item == book);
    await _saveWishlist();
    notifyListeners();
  }

  // Проверка, есть ли книга в вишлисте
  bool isInWishlist(Book book) {
    return _wishlistBooks.any((item) => item == book);
  }

  // Очистка вишлиста
  Future<void> clearWishlist() async {
    _wishlistBooks.clear();
    await _saveWishlist();
    notifyListeners();
  }
}
