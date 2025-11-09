/// Модель данных, представляющая книгу в приложении BookTracker
/// 
/// Эта модель является центральной сущностью приложения и содержит:
/// - Основные метаданные книги (название, автор, обложка)
/// - Детальную информацию (описание, жанр, издательство)
/// - Библиографические данные (количество страниц, дата публикации)
/// - Тематические категории (темы, места, временные периоды)
/// - Идентификаторы для интеграции с OpenLibrary API
/// 
/// Модель поддерживает:
/// - Создание из JSON данных OpenLibrary API
/// - Иммутабельные обновления через copyWith
/// - Обработку различных форматов данных API
/// - Грациозную обработку отсутствующих данных
/// 
/// Архитектурная роль:
/// - Единый источник истины для данных о книгах
/// - Совместимость между различными компонентами приложения
/// - Поддержка как базовых, так и расширенных данных
library book_model;

class Book {
  final String title;
  final String author;
  final String? coverUrl;
  final String? description;
  final String? genre;
  final String? publisher;
  final int? totalPages;
  final String? firstPublishDate;
  final List<String>? subjects;
  final List<String>? subjectPlaces;
  final List<String>? subjectTimes;
  final String? key;

  Book({
    required this.title,
    required this.author,
    this.coverUrl,
    this.description,
    this.genre,
    this.publisher,
    this.totalPages,
    this.firstPublishDate,
    this.subjects,
    this.subjectPlaces,
    this.subjectTimes,
    this.key,
  });

  // Исправленный фабричный метод fromJson
  factory Book.fromJson(Map<String, dynamic> json) {
    // 1. Автор
    String author = 'Неизвестный автор';
    if (json['authors'] != null && json['authors'].isNotEmpty) {
      final authorData = json['authors'][0];
      if (authorData['author'] is Map && authorData['author']['key'] != null) {
        author = _extractAuthorName(authorData['author']['key']);
      }
    }

    // 2. Обложка
    String? coverUrl;
    if (json['covers'] != null && json['covers'].isNotEmpty) {
      final coverId = json['covers'][0];
      coverUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    }

    // 3. Описание (может быть String или Map)
    String? description;
    if (json['description'] != null) {
      if (json['description'] is String) {
        description = json['description'];
      } else if (json['description'] is Map &&
          json['description']['value'] != null) {
        description = json['description']['value'];
      }
    }

    return Book(
      title: json['title'] ?? 'Без названия',
      author: author,
      coverUrl: coverUrl,
      description: description,
      genre: json['genre'],
      publisher: _extractPublisher(json),
      totalPages: json['number_of_pages'] ?? json['total_pages'],
      firstPublishDate: json['first_publish_date'], 
      subjects: _parseStringList(json['subjects']), 
      subjectPlaces:
          _parseStringList(json['subject_places']), 
      subjectTimes:
          _parseStringList(json['subject_times']), 
      key: json['key'],
    );
  }

  static String _extractAuthorName(String authorKey) {
    final parts = authorKey.split('/').last;
    return parts.replaceAll('_', ' ').replaceAll('OL', '');
  }

  static String? _extractPublisher(Map<String, dynamic> json) {
    if (json['publishers'] != null && json['publishers'].isNotEmpty) {
      return json['publishers'][0];
    }
    return json['publisher'];
  }

  static List<String>? _parseStringList(dynamic data) {
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return null;
  }

  Book copyWith({
    String? title,
    String? author,
    String? coverUrl,
    String? key,
    String? description, 
    String? firstPublishDate, 
    List<String>? subjects, 
    List<String>? subjectPlaces, 
    List<String>? subjectTimes, 
    int? totalPages,
    String? publisher, 
  String? genre,
  }) {
    return Book(
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      key: key ?? this.key,
      description:
          description ?? this.description, 
      firstPublishDate: firstPublishDate ?? this.firstPublishDate,
      subjects: subjects ?? this.subjects,
      subjectPlaces: subjectPlaces ?? this.subjectPlaces,
      subjectTimes: subjectTimes ?? this.subjectTimes,
      totalPages: totalPages ?? this.totalPages,
      publisher: publisher ?? this.publisher, 
    genre: genre ?? this.genre,
    );
  }
}
