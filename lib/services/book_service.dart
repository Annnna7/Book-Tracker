import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/book_model.dart';

/// Сервис для работы с API OpenLibrary
/// 
/// Этот сервис предоставляет функциональность для:
/// - Поиска книг по различным критериям (название, автор)
/// - Получения детальной информации о конкретной книге
/// - Преобразования данных API в объекты модели Book
/// - Обработки ошибок и грациозной деградации при сетевых проблемах
/// 
/// Архитектура сервиса:
/// - Статические методы для простого доступа из любого места приложения
/// - Разделение на базовый поиск и детальную загрузку
/// - Кэширование URL и конфигурации запросов
/// - Обработка различных форматов данных OpenLibrary API

class BookService {
  static const String _baseUrl = 'https://openlibrary.org';

  /// Выполняет поиск книг по заданному запросу
  /// 
  /// Процесс поиска:
  /// 1. Кодирует запрос для поддержки кириллицы и специальных символов
  /// 2. Выполняет HTTP GET запрос к API поиска OpenLibrary
  /// 3. Парсит JSON ответ и извлекает массив документов (docs)
  /// 4. Преобразует каждый документ в объект Book
  /// 5. Обрабатывает ошибки и возвращает пустой список при неудаче
  /// 
  /// @param query - поисковый запрос (название книги, автор)
  /// @return Future<List<Book>> - список найденных книг
  /// 
  /// @throws HttpException при сетевых ошибках
  /// @throws FormatException при проблемах парсинга JSON

  static Future<List<Book>> searchBooks(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/search.json?q=${Uri.encodeQueryComponent(query)}&limit=20'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> docs = data['docs'];

        List<Book> books = [];

        for (var doc in docs) {
          // *** 1. Извлекаем ЖАНР (Genre) ***
          final dynamic subjects = doc['subject'];
          String? genre; 
          if (subjects is List && subjects.isNotEmpty) {
            final firstSubject = subjects[0];
            if (firstSubject is String) {
              genre = firstSubject;
            }
          }

          final dynamic authorNames = doc['author_name'];
          String authorText;

          if (authorNames is List && authorNames.isNotEmpty) {
            // Если это список и он не пуст, объединяем его элементы
            authorText = authorNames.map((a) => a.toString()).join(', ');
          } else {
            authorText = 'Автор неизвестен';
          }

// *** 3. Извлекаем ИЗДАТЕЛЬСТВО (Publisher) ***
          final dynamic publishers = doc['publisher'];
          String? publisher;
          if (publishers is List && publishers.isNotEmpty) {
            // Безопасное приведение, берем первый элемент, если он строка
            final firstPublisher = publishers[0];
            if (firstPublisher is String) {
              publisher = firstPublisher;
            }
          }
          final String bookKey = doc['key'] ?? '';

          books.add(Book(
            title: doc['title'] ?? 'Без названия',
            author: authorText,
            coverUrl: doc['cover_i'] != null
                ? 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-M.jpg'
                : null,
            key: bookKey,
            description: null,
            genre: genre,
            publisher: publisher,
            totalPages: null,
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

  /// Загружает детальную информацию о конкретной книге
  /// 
  /// Используется для обогащения базовых данных, полученных из поиска:
  /// - Подробное описание книги
  /// - Точное количество страниц
  /// - Дополнительные метаданные
  /// 
  /// @param bookKey - уникальный идентификатор книги в OpenLibrary
  /// @return Future<BookDetailsData?> - объект с детальными данными или null
  /// 
  /// @throws HttpException при сетевых ошибках
  /// @throws FormatException при проблемах парсинга JSON

  static Future<BookDetailsData?> fetchBookDetails(String? bookKey) async {
    if (bookKey == null || bookKey.isEmpty)
      return null; // Возвращаем пустые данные

    try {
      final response = await http.get(
        Uri.parse('https://openlibrary.org$bookKey.json'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Извлечение описания
        String? description;
        if (data['description'] != null) {
          if (data['description'] is String) {
            description = data['description'];
          } else if (data['description'] is Map) {
            description = data['description']['value'];
          }
        }

        // Извлечение количества страниц 
        int? numberOfPages;
        if (data['number_of_pages'] is int) {
          numberOfPages = data['number_of_pages'];
        }

        return BookDetailsData(
          description: description,
          numberOfPages: numberOfPages,
        );
      }
      return BookDetailsData();
    } catch (e) {
      return BookDetailsData();
    }
  }
}

class BookDetailsData {
  final String? description;
  final int? numberOfPages;

  BookDetailsData({this.description, this.numberOfPages});
}
