/// Страница детальной информации о книге
///
/// Этот экран отображает полную информацию о выбранной книге, включая:
/// - Обложку книги и основные метаданные (автор, год издания, жанры)
/// - Подробное описание с возможностью развертывания/сворачивания
/// - Дополнительную информацию: издательство, количество страниц, теги
/// - Интерактивные кнопки для управления состоянием книги (чтение, вишлист, оценка)
///
/// Особенности реализации:
/// - Двухэтапная загрузка: сначала базовые данные, затем полная информация из API
/// - Адаптивный дизайн с кастомным AppBar и плавными анимациями
/// - Кэширование изображений для оптимизации производительности
/// - Обработка различных форматов данных от OpenLibrary API
///
/// Архитектура данных:
/// 1. Принимает базовый объект Book через конструктор
/// 2. Загружает дополнительные данные из OpenLibrary API
/// 3. Обновляет интерфейс по мере поступления информации
// ignore_for_file: avoid_print, deprecated_member_use

library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/book_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/control_panel.dart';
import 'home_page.dart';
import 'package:book_tracker_app/features/widgets/nav_item.dart';
import 'package:provider/provider.dart';
import 'wishlist_provider.dart';
import 'read_books_provider.dart';

class BookDetailsPage extends StatefulWidget {
  final Book book;

  const BookDetailsPage({super.key, required this.book});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  // Объект для отображения: сначала исходная книга, затем полная
  Book? _fullBookData;
  bool _isLoading = true;
  bool _isDescriptionExpanded = false;
  final NavItem _selectedNavItem = NavItem.search;
  double _userRating = 5.0;

  // Флаги состояния книги
  bool _isInWishlist = false;
  bool _isInReadBooks = false;

  // Вспомогательный getter, который всегда возвращает актуальные данные
  Book get displayBook => _fullBookData ?? widget.book;

  @override
  void initState() {
    super.initState();
    // Начинаем загрузку полных данных при инициализации
    _loadFullBookDetails();
  }

  // --- МЕТОД ЗАГРУЗКИ ПОЛНЫХ ДАННЫХ ---
  Future<void> _loadFullBookDetails() async {
    print('ЗАГРУЗКА: Начало загрузки полных деталей для ${widget.book.key}');

    try {
      // 1. Загружаем полные данные о работе (work) с повтором при ошибке 503
      Map<String, dynamic> workData = {};
      int maxRetries = 2; // Максимальное количество попыток
      for (int attempt = 0; attempt < maxRetries; attempt++) {
        try {
          final workResponse = await http
              .get(Uri.parse('https://openlibrary.org${widget.book.key}.json'))
              .timeout(const Duration(seconds: 20));

          if (workResponse.statusCode == 200) {
            workData = json.decode(workResponse.body);
            print('Данные работы загружены успешно (попытка ${attempt + 1})');
            break; // Выходим из цикла, если успешно
          } else if (workResponse.statusCode == 503 &&
              attempt < maxRetries - 1) {
            print(
                'Ошибка загрузки работы: ${workResponse.statusCode}. Повтор через 2 секунды.');
            await Future.delayed(const Duration(seconds: 2));
          } else {
            print('Ошибка загрузки работы: ${workResponse.statusCode}');
            // Если ошибка другая или последняя попытка - завершаем
            break;
          }
        } catch (e) {
          print('Ошибка при загрузке work (попытка ${attempt + 1}): $e');
          if (attempt < maxRetries - 1) {
            await Future.delayed(const Duration(seconds: 2));
          } else {
            // Если последняя попытка, то workData остается пустой, и переходим к Editions
          }
        }
      }

      // 2. Загружаем данные об изданиях (editions) для получения страниц и издательства
      int? totalPages;
      String? publisher;
      String? firstPublishDate;

      try {
        final editionsResponse = await http
            .get(Uri.parse(
                'https://openlibrary.org${widget.book.key}/editions.json'))
            .timeout(const Duration(seconds: 20));

        if (editionsResponse.statusCode == 200) {
          final editionsData = json.decode(editionsResponse.body);

          if (editionsData['entries'] != null &&
              editionsData['entries'].isNotEmpty) {
            // Ищем издание с количеством страниц
            for (var edition in editionsData['entries']) {
              if (edition['number_of_pages'] != null) {
                totalPages = edition['number_of_pages'];

                // Берем издательство из этого издания
                if (edition['publishers'] != null &&
                    edition['publishers'].isNotEmpty) {
                  publisher = edition['publishers'][0];
                }
                break;
              }
            }

            // Если не нашли страницы, берем данные из первого издания
            if (totalPages == null && editionsData['entries'].isNotEmpty) {
              final firstEdition = editionsData['entries'][0];
              totalPages = firstEdition['number_of_pages'];
              if (firstEdition['publishers'] != null &&
                  firstEdition['publishers'].isNotEmpty) {
                publisher = firstEdition['publishers'][0];
              }
            }
          }
          print('Данные изданий загружены. Страниц: $totalPages');
        }
      } catch (e) {
        print('Ошибка при загрузке editions: $e');
      }

      // 3. Парсим описание (может быть String или Map)
      String? description;
      if (workData['description'] != null) {
        if (workData['description'] is String) {
          description = workData['description'];
        } else if (workData['description'] is Map &&
            workData['description']['value'] != null) {
          description = workData['description']['value'];
        }
      }

      // 4. Парсим дату первой публикации
      firstPublishDate = workData['first_publish_date'] ?? firstPublishDate;

      // 5. Парсим subjects, subject_places, subject_times
      List<String>? subjects = _parseStringList(workData['subjects']);
      List<String>? subjectPlaces =
          _parseStringList(workData['subject_places']);
      List<String>? subjectTimes = _parseStringList(workData['subject_times']);

      // 6. Обновляем книгу с РЕАЛЬНЫМИ данными из API
      final Book loadedBook = widget.book.copyWith(
        description: description,
        firstPublishDate: firstPublishDate,
        subjects: subjects,
        subjectPlaces: subjectPlaces,
        subjectTimes: subjectTimes,
        totalPages: totalPages,
        publisher: publisher,
      );

      if (mounted) {
        setState(() {
          _fullBookData = loadedBook;
          _isLoading = false;
        });
        print('ЗАГРУЗКА: Реальные данные успешно загружены');
      }
    } catch (e) {
      print('Критическая ошибка загрузки: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Вспомогательный метод для парсинга списков
  List<String>? _parseStringList(dynamic data) {
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Отображаем индикатор загрузки, пока данные не придут
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color.fromRGBO(240, 230, 210, 1.0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  color: Color.fromRGBO(107, 79, 57, 1.0)),
              SizedBox(height: 16),
              Text('Загрузка полной информации о книге...',
                  style: TextStyle(color: Color(0xFFF4ECE1))),
            ],
          ),
        ),
      );
    }

    // После загрузки данных проверяем состояние книги
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBookState();
    });

    // 2. Отображаем содержимое, используя displayBook
    return Scaffold(
      backgroundColor: const Color(0xFF765745), // Белый фон для всей страницы
      body: Stack(
        children: [
          // 1. Основное содержимое страницы с прокруткой
          SingleChildScrollView(
            child: Column(
              children: [
                _buildTopSection(context, displayBook),
                _buildDetailsContent(context, displayBook),
              ],
            ),
          ),

          // 2. Нижняя Навигационная Панель (Bottom NavBar)
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  void _checkBookState() {
    final book = _fullBookData ?? widget.book;
    final wishlistProvider =
        Provider.of<WishlistProvider>(context, listen: false);
    final readBooksProvider =
        Provider.of<ReadBooksProvider>(context, listen: false);

    setState(() {
      _isInWishlist = wishlistProvider.isInWishlist(book);
      _isInReadBooks = readBooksProvider.isInReadBooks(book);
    });
  }

  void _toggleWishlist() {
    final book = _fullBookData ?? widget.book;
    final wishlistProvider =
        Provider.of<WishlistProvider>(context, listen: false);

    final wasInWishlist = _isInWishlist;

    setState(() {
      _isInWishlist = !_isInWishlist;
    });

    if (wasInWishlist) {
      wishlistProvider.removeFromWishlist(book);
    } else {
      wishlistProvider.addToWishlist(book);
    }

    // Показать уведомление
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasInWishlist
              ? 'Книга удалена из вишлиста'
              : 'Книга добавлена в вишлист!',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleReadBook() {
    final book = _fullBookData ?? widget.book;
    final readBooksProvider =
        Provider.of<ReadBooksProvider>(context, listen: false);

    final wasInReadBooks = _isInReadBooks;

    setState(() {
      _isInReadBooks = !_isInReadBooks;
    });

    if (wasInReadBooks) {
      readBooksProvider.removeFromReadBooks(book);
    } else {
      readBooksProvider.addToReadBooks(book);
    }

    // Показать уведомление
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasInReadBooks
              ? 'Книга удалена из прочитанного'
              : 'Книга добавлена в прочитанное!',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onNavItemTapped(NavItem item) {
    print('Навигация: Переход на главный экран с вкладкой ${item.name}');

    NavItem targetItem;
    switch (item) {
      case NavItem.home:
        targetItem = NavItem.home;
        break;
      case NavItem.search:
        targetItem = NavItem.search;
        break;
      case NavItem.completed:
        targetItem = NavItem.completed;
        break;
      case NavItem.wishlist:
        targetItem = NavItem.wishlist;
        break;
      case NavItem.notes:
        targetItem = NavItem.notes;
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(initialItem: targetItem),
      ),
    );
  }

  void _printCompleteBookData(Book book) {
    print('=== ПОЛНЫЕ ДАННЫЕ КНИГИ (ПОСЛЕ ЗАГРУЗКИ) ===');
    print('Название: ${book.title}');
    print('Автор: ${book.author}');
    print('Обложка: ${book.coverUrl}');
    // Проверка, что описание больше не null
    print('Описание: ${book.description?.substring(0, 50)}...');
    // Проверка, что дата больше не null
    print('Первая публикация: ${book.firstPublishDate}');
    // Проверка, что Subjects больше не null
    print('Subjects: ${book.subjects?.take(3).toList()}');
    // Проверка, что Subject Places больше не null
    print('Subject Places: ${book.subjectPlaces?.take(2).toList()}');
    // Проверка, что Subject Times больше не null
    print('Subject Times: ${book.subjectTimes?.take(2).toList()}');
    print('Key: ${book.key}');
    print('============================================');
  }

  // --- ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ДОЛЖНЫ ПРИНИМАТЬ КНИГУ КАК ПАРАМЕТР ---

  Widget _buildTopSection(BuildContext context, Book book) {
    const Color primaryBrown = Color(0xFF765745);
    const Color lightBeige = Color(0xFFF4ECE1);

    return Container(
      color: primaryBrown,
      child: Align(
        // Явное выравнивание по левому краю
        alignment: Alignment.centerLeft,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: const BoxDecoration(
            color: lightBeige,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Stack(
            children: [
              // СТРЕЛКА НАЗАД
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryBrown.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: primaryBrown,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // ОСНОВНОЙ КОНТЕНТ
              Padding(
                padding: const EdgeInsets.only(
                  top: 70,
                  left: 25,
                  right: 25,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // НАЗВАНИЕ КНИГИ
                    Container(
                      padding: const EdgeInsets.only(left: 40),
                      child: Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryBrown,
                          height: 1.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ОБЛОЖКА И ИНФОРМАЦИЯ
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBookCover(book),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBookDetailsCard(primaryBrown, book),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCover(Book book) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.0),
      child: Container(
        width: 100,
        height: 150,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: book.coverUrl != null
            ? CachedNetworkImage(
                imageUrl: book.coverUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) {
                  return const Icon(Icons.error, size: 40, color: Colors.red);
                },
              )
            : const Icon(Icons.book, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _buildBookDetailsCard(Color primaryBrown, Book book) {
    List<Widget> bookInfoWidgets = [];

    // 1. Автор
    if (book.author.isNotEmpty) {
      bookInfoWidgets.add(
        Text(
          book.author,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: primaryBrown),
        ),
      );
    }

    // 2. Год первой публикации
    if (book.firstPublishDate != null && book.firstPublishDate!.isNotEmpty) {
      bookInfoWidgets.addAll([
        const SizedBox(height: 4),
        Text(
          'Первая публикация: ${book.firstPublishDate}',
          style: TextStyle(fontSize: 11, color: primaryBrown.withOpacity(0.8)),
        ),
      ]);
    }

    // 3. Жанры из subjects
    if (book.subjects != null && book.subjects!.isNotEmpty) {
      final mainGenres = _extractMainGenres(book.subjects!);
      if (mainGenres.isNotEmpty) {
        bookInfoWidgets.addAll([
          const SizedBox(height: 4),
          Text(
            'Жанры: ${mainGenres.take(2).join(', ')}',
            style:
                TextStyle(fontSize: 11, color: primaryBrown.withOpacity(0.8)),
          ),
        ]);
      }
    }

    // 4. Исторический период из subject_times
    if (book.subjectTimes != null && book.subjectTimes!.isNotEmpty) {
      bookInfoWidgets.addAll([
        const SizedBox(height: 4),
        Text(
          'Период: ${book.subjectTimes!.first}',
          style: TextStyle(fontSize: 11, color: primaryBrown.withOpacity(0.8)),
        ),
      ]);
    }

    // 5. Места из subject_places
    if (book.subjectPlaces != null && book.subjectPlaces!.isNotEmpty) {
      bookInfoWidgets.addAll([
        const SizedBox(height: 4),
        Text(
          'Место: ${book.subjectPlaces!.first}',
          style: TextStyle(fontSize: 11, color: primaryBrown.withOpacity(0.8)),
        ),
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: bookInfoWidgets,
      ),
    );
  }

  List<String> _extractMainGenres(List<String> subjects) {
    final genreKeywords = [
      'Fiction',
      'Novel',
      'Classic',
      'Historical',
      'Romance',
      'Fantasy',
      'Science Fiction',
      'Mystery',
      'Thriller',
      'Biography',
      'History',
      'Poetry',
      'Drama',
      'Adventure',
      'Literature',
      'Classics',
      'Contemporary'
    ];
    final List<String> foundGenres = [];

    for (var subject in subjects) {
      for (var keyword in genreKeywords) {
        if (subject.toLowerCase().contains(keyword.toLowerCase())) {
          if (!foundGenres.contains(keyword)) {
            foundGenres.add(keyword);
          }
          break;
        }
      }
      if (foundGenres.length >= 3) break;
    }
    return foundGenres;
  }

  // --- 2. ОСНОВНОЕ СОДЕРЖИМОЕ СТРАНИЦЫ ---
  Widget _buildDetailsContent(BuildContext context, Book book) {
    const Color primaryBrown = Color(0xFF765745);

    return Container(
      color: primaryBrown,
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Кнопки "Оценить книгу" и "Количество страниц"
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 80),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showRatingDialog(context);
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: _buildRatingChip(_userRating),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.bookmark,
                    text: 'количество страниц',
                    subtext: '${book.totalPages ?? 'Н/Д'}',
                  ),
                ),
              ],
            ),
          ),

          // Раздел "Описание"
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Описание',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDescriptionExpanded = !_isDescriptionExpanded;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          _isDescriptionExpanded
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _isDescriptionExpanded
                    ? Text(
                        book.description ?? 'Описание отсутствует.',
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.white,
                        ),
                      )
                    : Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: Stack(
                          children: [
                            Text(
                              book.description ?? 'Описание отсутствует.',
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: Colors.white,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      const Color.fromRGBO(107, 79, 57, 1.0)
                                          .withOpacity(1.0),
                                      const Color.fromRGBO(107, 79, 57, 1.0)
                                          .withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Блок прогресса чтения
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: const Icon(
                Icons.timer,
                color: Color.fromRGBO(107, 79, 57, 1.0),
                size: 30,
              ),
              title: const Text(
                'Прочитано',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(107, 79, 57, 1.0),
                ),
                maxLines: 1,
              ),
              subtitle: Text(
                '0/${book.totalPages ?? 'Н/Д'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 129, 129, 129),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Container(
                margin: const EdgeInsets.only(right: 20),
                child: const SizedBox(
                  width: 80,
                  child: Text(
                    'Изменить\nстраницу',
                    style: TextStyle(
                      color: Color(0xFF765745),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              onTap: () {
                // Обработка нажатия "Изменить страницу"
              },
            ),
          ),
          const SizedBox(height: 16),

          // Две кнопки в одном ряду
          Row(
            children: [
              // Кнопка "В прочитанное"
              Expanded(
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: _isInReadBooks
                        ? const Color(0xFF4CAF50) // Зеленый если уже в прочитанном
                        : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _toggleReadBook(),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isInReadBooks
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: _isInReadBooks
                                ? Colors.white
                                : const Color.fromRGBO(107, 79, 57, 1.0),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isInReadBooks
                                  ? 'В прочитанном'
                                  : 'Добавить книгу в прочитанное',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _isInReadBooks
                                    ? Colors.white
                                    : const Color.fromRGBO(107, 79, 57, 1.0),
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Кнопка "В вишлист"
              Expanded(
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: _isInWishlist
                        ? const Color(0xFFE91E63) // Розовый если уже в вишлисте
                        : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _toggleWishlist(),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isInWishlist
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isInWishlist
                                ? Colors.white
                                : const Color.fromRGBO(107, 79, 57, 1.0),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _isInWishlist
                                  ? 'В вишлисте'
                                  : 'Добавить книгу в вишлист',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _isInWishlist
                                    ? Colors.white
                                    : const Color.fromRGBO(107, 79, 57, 1.0),
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Новый метод для создания интерактивной кнопки оценки
  Widget _buildRatingChip(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 18,
                color: Colors.grey.shade600, // Золотой цвет для звезды
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  'оценить книгу'.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          // Показываем текущий рейтинг
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(107, 79, 57, 1.0),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    double tempRating = _userRating;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color.fromRGBO(240, 230, 210, 1.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Оценить книгу',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(107, 79, 57, 1.0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ваша оценка: ${tempRating.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(107, 79, 57, 1.0),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            tempRating = (index + 1).toDouble();
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            index < tempRating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color.fromRGBO(107, 79, 57, 1.0),
                            size: 30,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 12),

                  // Слайдер
                  Slider(
                    value: tempRating,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: const Color.fromRGBO(107, 79, 57, 1.0),
                    inactiveColor: const Color.fromRGBO(107, 79, 57, 0.3),
                    onChanged: (value) {
                      setDialogState(() {
                        tempRating = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Отмена',
                          style: TextStyle(
                            color: Color.fromRGBO(107, 79, 57, 1.0),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(107, 79, 57, 1.0),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          setState(() {
                            _userRating = tempRating;
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Сохранить',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ ---

  Widget _buildInfoChip(
      {required IconData icon,
      required String text,
      required String subtext}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 2),
              Flexible(
                // Обернули в Flexible
                child: Text(
                  text.toUpperCase(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          // Основной текст
          Text(
            subtext,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(107, 79, 57, 1.0)),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ControlPanel(
      selectedItem: _selectedNavItem,
      onItemTapped: _onNavItemTapped,
    );
  }
}

// Custom Clipper для создания изгиба в нижней части AppBar
class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height * 0.4);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}