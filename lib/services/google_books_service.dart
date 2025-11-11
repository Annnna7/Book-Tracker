import 'api_service.dart';
import '../models/Book.dart';

/// Сервис для работы с Google Books API
class GoogleBooksService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1';
  final String apiKey;

  GoogleBooksService({required this.apiKey}) {
    if (apiKey.isEmpty || apiKey == 'your_actual_api_key_here') {
      throw ArgumentError('Google Books API key is not configured properly');
    }
  }

  /// Поиск книг в Google Books API
  Future<ApiResponse<List<Book>>> searchBooks(String query) async {
    return ApiService.get(
      url: '$_baseUrl/volumes?q=${Uri.encodeQueryComponent(query)}'
          '&maxResults=20'
          '&printType=books'  // Только книги, исключает журналы
          '&langRestrict=ru'  // Ограничение по языку (опционально)
          '&key=$apiKey',
      parser: (data) => _parseSearchResults(data),
    );
  }

  /// Получение детальной информации о книге
  Future<ApiResponse<Book>> fetchBookDetails(String bookId) async {
    return ApiService.get(
      url: '$_baseUrl/volumes/$bookId?key=$apiKey',
      parser: (data) => _parseBookDetails(data),
    );
  }

  /// Парсинг результатов поиска Google Books
  static List<Book> _parseSearchResults(Map<String, dynamic> data) {
    final List<dynamic> items = data['items'] ?? [];
    return items
        .where((item) => item != null && item is Map<String, dynamic>)
        .map(_parseBookFromVolume)
        .where((book) => book.title != 'Без названия') // Фильтруем некорректные
        .toList();
  }

  /// Парсинг книги из Volume данных Google Books
  static Book _parseBookFromVolume(dynamic item) {
    final volumeInfo = item['volumeInfo'] ?? {};

    // Обработка авторов - согласно документации authors это List<String>
    final List<dynamic>? authors = volumeInfo['authors'] as List?;
    String authorText;
    if (authors != null && authors.isNotEmpty) {
      authorText = authors
          .where((a) => a != null)
          .map((a) => a.toString())
          .join(', ');
    } else {
      authorText = 'Автор неизвестен';
    }

    // Обработка обложки - согласно документации есть несколько размеров
    String? coverUrl;
    final imageLinks = volumeInfo['imageLinks'] as Map?;
    if (imageLinks != null) {
      // Предпочитаем средний размер, если нет - маленький, если нет - большой
      coverUrl = imageLinks['thumbnail']?.toString()?.replaceAll('http://', 'https://') ??
          imageLinks['smallThumbnail']?.toString()?.replaceAll('http://', 'https://') ??
          imageLinks['medium']?.toString()?.replaceAll('http://', 'https://') ??
          imageLinks['large']?.toString()?.replaceAll('http://', 'https://');
    }

    // Обработка категорий (жанров) - согласно документации categories это List<String>
    final List<dynamic>? categories = volumeInfo['categories'] as List?;
    String? genre;
    if (categories != null && categories.isNotEmpty) {
      final firstCategory = categories.first;
      if (firstCategory != null) {
        genre = firstCategory.toString();
        // Можно разбить по слешам, если категории в формате "Fiction/Mystery"
        if (genre.contains('/')) {
          genre = genre.split('/').first;
        }
      }
    }

    // Обработка даты публикации - может быть в формате "YYYY", "YYYY-MM", "YYYY-MM-DD"
    String? publishedDate = volumeInfo['publishedDate']?.toString();
    if (publishedDate != null && publishedDate.length >= 4) {
      publishedDate = publishedDate.substring(0, 4); // Берем только год
    }

    // Обработка описания - может содержать HTML теги
    String? description = volumeInfo['description']?.toString();
    if (description != null) {
      // Упрощенная очистка от HTML тегов
      description = description
          .replaceAll(RegExp(r'<[^>]*>'), '') // Удаляем HTML теги
          .replaceAll(RegExp(r'\s+'), ' ') // Убираем лишние пробелы
          .trim();

      // Ограничиваем длину описания
      if (description.length > 500) {
        description = '${description.substring(0, 500)}...';
      }
    }

    return Book(
      title: volumeInfo['title']?.toString() ?? 'Без названия',
      author: authorText,
      coverUrl: coverUrl,
      key: item['id']?.toString(), // ID книги в Google Books
      description: description,
      genre: genre,
      publisher: volumeInfo['publisher']?.toString(),
      totalPages: volumeInfo['pageCount'] as int?,
      firstPublishDate: publishedDate,
      // Дополнительные поля, специфичные для Google Books
      subjects: categories?.whereType<String>().toList(),
    );
  }

  /// Парсинг детальной информации о книге
  static Book _parseBookDetails(Map<String, dynamic> data) {
    // Используем тот же парсер, что и для поиска
    return _parseBookFromVolume(data);
  }

  /// Поиск книг по автору
  Future<ApiResponse<List<Book>>> searchBooksByAuthor(String author) async {
    return ApiService.get(
      url: '$_baseUrl/volumes?q=inauthor:${Uri.encodeQueryComponent(author)}'
          '&maxResults=20'
          '&printType=books'
          '&key=$apiKey',
      parser: (data) => _parseSearchResults(data),
    );
  }

  /// Поиск книг по названию
  Future<ApiResponse<List<Book>>> searchBooksByTitle(String title) async {
    return ApiService.get(
      url: '$_baseUrl/volumes?q=intitle:${Uri.encodeQueryComponent(title)}'
          '&maxResults=20'
          '&printType=books'
          '&key=$apiKey',
      parser: (data) => _parseSearchResults(data),
    );
  }
}