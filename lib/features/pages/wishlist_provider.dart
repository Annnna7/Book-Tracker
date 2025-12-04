import 'package:flutter/material.dart';
import '../../models/book_model.dart';

class WishlistProvider with ChangeNotifier {
  List<Book> _wishlistBooks = [
    Book.simple( // 
      title: 'Мастер и Маргарита',
      author: 'Михаил Булгаков',
      description: 'Великий роман о добре и зле, любви и творчестве',
    ),
    Book.simple( //
      title: '1984',
      author: 'Джордж Оруэлл',
      description: 'Антиутопия о тоталитарном обществе',
    ),
  ];
  
  List<Book> get wishlistBooks => _wishlistBooks;
  
  void addToWishlist(Book book) {
    _wishlistBooks.add(book);
    notifyListeners();
  }
  
  void removeFromWishlist(Book book) {
    _wishlistBooks.removeWhere((b) => b.title == book.title && b.author == book.author);
    notifyListeners();
  }
  
  bool isInWishlist(Book book) {
    return _wishlistBooks.any((b) => b.title == book.title && b.author == book.author);
  }
}