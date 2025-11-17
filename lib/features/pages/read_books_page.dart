/// Страница архива прочитанных книг в приложении BookTracker
///
/// Этот экран предназначен для отображения и управления:
/// - Полным архивом книг, завершенных пользователем
/// - Статистики и аналитики по прочитанному
/// - Хронологии чтения и личных достижений
/// - Возможности повторного просмотра и оценки книг
library;

import 'package:flutter/material.dart';
import '../../models/Book.dart';

// --- Константы для цветов и стилей ---
const Color _primaryBrown = Color(0xFF765745);
const Color _secondaryCream = Color(0xFFF7F3EE);
const Color _lightCardColor = Color(0xFFE0D9D1);

class ReadBooksPage extends StatelessWidget {
  const ReadBooksPage({super.key});

  // Вместо поля - метод для получения демо-данных
  List<Book> _getDemoBooks() {
    return [
      Book(
        title: '1984',
        author: 'Джордж Оруэлл',
        coverUrl: 'https://covers.openlibrary.org/b/id/10614530-M.jpg',
      ),
      Book(
        title: 'Преступление и наказание',
        author: 'Фёдор Достоевский',
        coverUrl: 'https://covers.openlibrary.org/b/id/7975041-M.jpg',
      ),
      Book(
        title: 'Мастер и Маргарита',
        author: 'Михаил Булгаков',
        coverUrl: 'https://covers.openlibrary.org/b/id/10427437-M.jpg',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool hasBooks = _getDemoBooks()
        .isNotEmpty; // Можно переключить на false для пустого состояния

    return Scaffold(
      backgroundColor: _secondaryCream,
      body: Stack(
        children: [
          // 1. Коричневый фон (Wave Clip)
          Positioned.fill(child: _buildBackgroundShape(context)),

          // 2. Основное содержимое: AppBar и список
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CustomAppBar(),
                const SizedBox(height: 30.0),

                // Динамический контент в зависимости от наличия книг
                Expanded(
                  child: hasBooks ? _buildBooksList() : _buildEmptyState(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Список книг
  Widget _buildBooksList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 100),
      itemCount: _getDemoBooks().length,
      itemBuilder: (context, index) {
        final book = _getDemoBooks()[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: _BookCard(
            book: book,
            rating: 5, // Демо-рейтинг
          ),
        );
      },
    );
  }

  // Пустое состояние
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 80,
            color: _primaryBrown.withOpacity(0.5),
          ),
          const SizedBox(height: 20),
          Text(
            'Пока нет прочитанных книг',
            style: TextStyle(
              color: _primaryBrown.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Добавленные книги появятся здесь',
            style: TextStyle(
              color: _primaryBrown.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Создание фоновой изогнутой фигуры
  Widget _buildBackgroundShape(context) {
    return ClipPath(
      clipper: _CurveClipper(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.2,
        color: _primaryBrown.withOpacity(0.95),
      ),
    );
  }
}

// --- ВИДЖЕТЫ UI КОМПОНЕНТОВ ---

// Кастомный AppBar с заголовком и поиском
class _CustomAppBar extends StatelessWidget {
  const _CustomAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Прочитанное',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: _primaryBrown,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: _primaryBrown, size: 30),
            onPressed: () {
              // Действие поиска
            },
          ),
        ],
      ),
    );
  }
}

// Карточка одной книги (обновленная - обложка внутри контейнера)
class _BookCard extends StatelessWidget {
  final Book book;
  final int rating;

  const _BookCard({
    required this.book,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        // Основная карточка с текстом И ОБЛОЖКОЙ
        Container(
          margin: const EdgeInsets.only(top: 0),
          padding: const EdgeInsets.only(left: 20, top: 15, right: 20, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Обложка книги внутри контейнера
              Container(
                width: 80, // Немного уменьшили обложку
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: book.coverUrl != null
                      ? Image.network(
                          book.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderCover(),
                        )
                      : _buildPlaceholderCover(),
                ),
              ),
              const SizedBox(width: 16),
              // Текстовая информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Автор
                    Text(
                      book.author,
                      style: const TextStyle(
                        color: _lightCardColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Название
                    Text(
                      book.title,
                      style: const TextStyle(
                        color: _secondaryCream,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // Кнопка цитат и заметок
                    ElevatedButton(
                      onPressed: () {
                        // Навигация к цитатам и заметкам
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _lightCardColor,
                        foregroundColor: _primaryBrown,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'Посмотреть все цитаты и заметки по книге',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Рейтинг - ВЫНОСИМ ОТДЕЛЬНО И ПОДНИМАЕМ ВЫШЕ
        Positioned(
          top: -13,
          right: 25,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 55, 38, 22),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$rating/5',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.star, color: Color.fromARGB(255, 235, 239, 28), size: 19),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: Colors.grey,
      child: const Center(
        child: Icon(Icons.book, color: Colors.white, size: 40),
      ),
    );
  }
}

// Класс для создания изогнутой формы
class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.65);

    var controlPoint1 = Offset(size.width * 0.25, size.height * 0.15);
    var endPoint1 = Offset(size.width * 0.6, size.height * 0.15);

    path.quadraticBezierTo(
        controlPoint1.dx, controlPoint1.dy, endPoint1.dx, endPoint1.dy);

    var controlPoint2 = Offset(size.width * 0.85, size.height * 0.15);
    var endPoint2 = Offset(size.width, size.height * 0.25);

    path.quadraticBezierTo(
        controlPoint2.dx, controlPoint2.dy, endPoint2.dx, endPoint2.dy);

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
