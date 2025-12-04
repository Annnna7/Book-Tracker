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
/// - Сериализацию для локального хранения
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

  const Book.simple({
    required this.title,
    required this.author,
    this.coverUrl,
    this.description,
  }) : genre = null,
       publisher = null,
       totalPages = null,
       firstPublishDate = null,
       subjects = null,
       subjectPlaces = null,
       subjectTimes = null,
       key = null;

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
      subjectPlaces: _parseStringList(json['subject_places']), 
      subjectTimes: _parseStringList(json['subject_times']), 
      key: json['key'],
    );
  }


  // Конструктор для загрузки из Map (из SharedPreferences)
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      title: map['title'] ?? '',
      author: map['author'] ?? 'Неизвестный автор',
      coverUrl: map['coverUrl'],
      description: map['description'],
      genre: map['genre'],
      publisher: map['publisher'],
      totalPages: map['totalPages'],
      firstPublishDate: map['firstPublishDate'],
      subjects: map['subjects'] != null ? List<String>.from(map['subjects']) : null,
      subjectPlaces: map['subjectPlaces'] != null ? List<String>.from(map['subjectPlaces']) : null,
      subjectTimes: map['subjectTimes'] != null ? List<String>.from(map['subjectTimes']) : null,
      key: map['key'],
    );
  }

  // Метод для сериализации в Map (для сохранения)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'description': description,
      'genre': genre,
      'publisher': publisher,
      'totalPages': totalPages,
      'firstPublishDate': firstPublishDate,
      'subjects': subjects,
      'subjectPlaces': subjectPlaces,
      'subjectTimes': subjectTimes,
      'key': key,
    };
  }

  // Метод для сериализации в JSON строку
  Map<String, dynamic> toJson() => toMap();

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
      description: description ?? this.description, 
      firstPublishDate: firstPublishDate ?? this.firstPublishDate,
      subjects: subjects ?? this.subjects,
      subjectPlaces: subjectPlaces ?? this.subjectPlaces,
      subjectTimes: subjectTimes ?? this.subjectTimes,
      totalPages: totalPages ?? this.totalPages,
      publisher: publisher ?? this.publisher, 
      genre: genre ?? this.genre,
    );
  }

  // Переопределение equals и hashCode для сравнения книг по ключу
  @override
bool operator ==(Object other) {
  if (identical(this, other)) return true;
  
  return other is Book &&
      runtimeType == other.runtimeType &&
      ((key != null && other.key != null && key == other.key) ||
       (title == other.title && author == other.author));
}
  @override
  int get hashCode {
    if (key != null) return key.hashCode;
    return title.hashCode ^ author.hashCode;
  }

  // Для отладки
  @override
  String toString() {
    return 'Book(title: $title, author: $author)';
  }
}
