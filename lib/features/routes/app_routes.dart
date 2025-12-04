// lib/features/routes/app_routes.dart
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/book_search_page.dart';
import '../pages/wishlist_page.dart';
import '../pages/read_books_page.dart';
import '../pages/statistics_page.dart';
import '../pages/notes_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String addBook = '/add-book';
  static const String wishlist = '/wishlist';
  static const String readBooks = '/read-books';
  static const String statistics = '/statistics';
  static const String notes = '/notes';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case addBook:
        return MaterialPageRoute(builder: (_) => const BookSearchPage());
      case wishlist:
        return MaterialPageRoute(builder: (_) => const WishlistPage());
      case readBooks:
        return MaterialPageRoute(builder: (_) => const ReadBooksPage());
      case statistics:
        return MaterialPageRoute(builder: (_) => const StatisticsPage());
      case notes:
        return MaterialPageRoute(builder: (_) => const NotesPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Нет маршрута для ${settings.name}')),
          ),
        );
    }
  }
}