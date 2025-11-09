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
import '../../models/Book.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      // 1. Загружаем полные данные о работе (work)
      final workResponse = await http
          .get(Uri.parse('https://openlibrary.org${widget.book.key}.json'))
          .timeout(const Duration(seconds: 10));

      Map<String, dynamic> workData = {};
      if (workResponse.statusCode == 200) {
        workData = json.decode(workResponse.body);
        print('Данные работы загружены успешно');
      } else {
        print('Ошибка загрузки работы: ${workResponse.statusCode}');
      }

      // 2. Загружаем данные об изданиях (editions) для получения страниц и издательства
      int? totalPages;
      String? publisher;
      String? firstPublishDate;

      try {
        final editionsResponse = await http
            .get(Uri.parse(
                'https://openlibrary.org${widget.book.key}/editions.json'))
            .timeout(const Duration(seconds: 10));

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
    // 2. Отображаем индикатор загрузки, пока данные не придут
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
                  style: TextStyle(color: Color.fromRGBO(107, 79, 57, 1.0))),
            ],
          ),
        ),
      );
    }

    // Для отладки - выводим все данные книги
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _printCompleteBookData(displayBook); 
    });

    // 3. Отображаем содержимое, используя displayBook
    return Scaffold(
      body: Stack(
        children: [
          // 1. Основное содержимое страницы с прокруткой
          CustomScrollView(
            slivers: [
              _buildBackgroundAppBar(
                  context, displayBook), 
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildDetailsContent(
                        context, displayBook), 
                  ],
                ),
              ),
            ],
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

  SliverAppBar _buildBackgroundAppBar(BuildContext context, Book book) {
    const Color primaryBrown = Color.fromRGBO(107, 79, 57, 1.0);

    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      backgroundColor: primaryBrown,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(color: primaryBrown),
            Positioned(
              bottom: -50,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: CurvedClipper(),
                child: Container(
                  height: 60,
                  color: const Color.fromRGBO(240, 230, 210, 1.0),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBookCover(book), 
                  const SizedBox(width: 16),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 150,
                      ),
                      child: _buildBookDetailsCard(
                          primaryBrown, book), 
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    // 2. Год первой публикации 
    if (book.firstPublishDate != null && book.firstPublishDate!.isNotEmpty) {
      bookInfoWidgets.addAll([
        const SizedBox(height: 4),
        Text(
          'Первая публикация: ${book.firstPublishDate}',
          style: const TextStyle(fontSize: 11, color: Colors.white70),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
            style: const TextStyle(fontSize: 11, color: Colors.white70),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
          style: const TextStyle(fontSize: 11, color: Colors.white70),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ]);
    }

    // 5. Места из subject_places
    if (book.subjectPlaces != null && book.subjectPlaces!.isNotEmpty) {
      bookInfoWidgets.addAll([
        const SizedBox(height: 4),
        Text(
          'Место: ${book.subjectPlaces!.first}',
          style: const TextStyle(fontSize: 11, color: Colors.white70),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
    const Color lightBeige = Color.fromRGBO(240, 230, 210, 1.0);
    const Color primaryBrown = Color.fromRGBO(107, 79, 57, 1.0);

    return Container(
      color: lightBeige,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Кнопки "Тип книги" и "Количество страниц"
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 80,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.book,
                    text: 'тип книги',
                    subtext: 'твердая обложка',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.bookmark,
                    text: 'количество страниц',
                    subtext:
                        '${book.totalPages ?? 'Н/Д'}', 
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Раздел "Описание"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Описание',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBrown),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDescriptionExpanded = !_isDescriptionExpanded;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(
                    _isDescriptionExpanded
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: primaryBrown,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
// Условный виджет для описания
          _isDescriptionExpanded
              ? SingleChildScrollView(
                  // Развернуто - с прокруткой
                  child: Text(
                    book.description ?? 'Описание отсутствует.',
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                )
              : Container(
                  // Свернуто - без прокрутки с градиентным fade-эффектом
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: Stack(
                    children: [
                      Text(
                        book.description ?? 'Описание отсутствует.',
                        style: const TextStyle(fontSize: 14, height: 1.4),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Градиент для плавного скрытия текста
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
                                lightBeige.withOpacity(1.0),
                                lightBeige.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 16),

          // Кнопки действий (Прогресс, Прочитанные, Вишлист, Оценить)
          _buildActionButton(
            context,
            icon: Icons.access_time_filled,
            title: 'Прочитано',
            subtitle: '0/${book.totalPages ?? 'Н/Д'}',
            actionText: 'Изменить страницу',
            color: primaryBrown,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            context,
            icon: Icons.check_circle,
            title: 'Добавить книгу',
            actionText: 'в список прочитанных',
            color: primaryBrown,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.archive,
                  title: 'Добавить книгу',
                  actionText: 'в вишлист',
                  color: primaryBrown,
                  isSmall: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.list,
                  title: 'Оценить книгу',
                  actionText: '',
                  color: primaryBrown,
                  isSmall: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // --- ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ ---

  Widget _buildInfoChip(
      {required IconData icon, required String text, required String subtext}) {
    return Container(
      // Уменьшаем горизонтальный отступ
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              // Верхний текст ("тип книги", "количество страниц")
              Text(
                text.toUpperCase(),
                style: const TextStyle(fontSize: 9, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          const SizedBox(height: 2),
          // Основной текст ("твердая обложка", "320")
          Text(
            subtext,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String title,
      required String actionText,
      required Color color,
      String? subtitle,
      bool isSmall = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3))
        ],
      ),
      child: isSmall
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(height: 4),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: color)),
                ],
              ),
            )
          : ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(icon, color: color, size: 30),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  if (subtitle != null)
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey)),
                ],
              ),
              trailing: Text(actionText, style: TextStyle(color: color)),
              onTap: () {},
            ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              icon: const Icon(Icons.book, color: Colors.brown),
              onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Colors.brown, shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
          IconButton(
              icon: const Icon(Icons.check_box_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
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
