import 'package:flutter/material.dart';
import '../../models/book_model.dart';

class ReadBooksProvider with ChangeNotifier {
  List<Book> _readBooks = [];
  
  List<Book> get readBooks => _readBooks;
  
  void addToReadBooks(Book book) {
    if (!_readBooks.any((b) => b.title == book.title && b.author == book.author)) {
      _readBooks.add(book);
      notifyListeners();
    }
  }
  
  void removeFromReadBooks(Book book) {
    _readBooks.removeWhere((b) => b.title == book.title && b.author == book.author);
    notifyListeners();
  }
  
  bool isInReadBooks(Book book) {
    return _readBooks.any((b) => b.title == book.title && b.author == book.author);
  }
}