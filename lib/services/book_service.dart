import 'dart:convert';
import 'package:http/http.dart' as http;

class BookService {
  static const String _baseUrl = 'https://openlibrary.org';

  static Future<List<Book>> searchBooks(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search.json?q=${Uri.encodeQueryComponent(query)}&limit=20'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> docs = data['docs'];

        List<Book> books = [];

        for (var doc in docs) {
          String? description = await _getBookDescription(doc['key']);

          books.add(Book(
            title: doc['title'] ?? 'Без названия',
            author: doc['author_name'] != null
                ? (doc['author_name'] as List).join(', ')
                : 'Автор неизвестен',
            coverUrl: doc['cover_i'] != null
                ? 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-M.jpg'
                : null,
            description: description,
          ));
        }

        return books;
      }
      return [];
    } catch (e) {
      print('Ошибка поиска: $e');
      return [];
    }
  }

  static Future<String?> _getBookDescription(String? bookKey) async {
    if (bookKey == null) return null;

    try {
      final response = await http.get(
        Uri.parse('https://openlibrary.org$bookKey.json'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['description'] != null) {
          if (data['description'] is String) {
            return data['description'];
          } else if (data['description'] is Map) {
            return data['description']['value'];
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class Book {
  final String title;
  final String author;
  final String? coverUrl;
  final String? description;

  Book({
    required this.title,
    required this.author,
    this.coverUrl,
    this.description,
  });
}