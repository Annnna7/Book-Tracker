import 'package:flutter/material.dart';
import '../../services/book_service.dart';
import 'book_details_page.dart';
import '../../models/book_model.dart';

class BookSearchPage extends StatefulWidget {
  const BookSearchPage({super.key});

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

/// Страница поиска книг в приложении BookTracker
///
/// Этот экран предоставляет функциональность:
/// - Поиск книг по названию через OpenLibrary API
/// - Отображение результатов поиска в виде списка
/// - Навигацию на страницу детальной информации о книге
/// - Двухэтапную загрузку данных: сначала базовые, затем полные
///
/// Архитектура поиска:
/// 1. Пользователь вводит запрос в текстовое поле
/// 2. Выполняется асинхронный запрос к BookService
/// 3. Отображаются базовые результаты (название, автор, обложка)
/// 4. При выборе книги загружаются дополнительные данные
/// 5. Происходит переход на страницу деталей с полной информацией
///
/// Особенности UX:
/// - Индикатор загрузки во время поиска
/// - Автопоиск при нажатии Enter
/// - Визуальная обратная связь при взаимодействии
/// - Адаптивный дизайн под разные размеры экрана

class _BookSearchPageState extends State<BookSearchPage> {
  final TextEditingController _controller = TextEditingController();
  List<Book> _books = [];
  bool _loading = false;

  static const Color primaryBrown = Color(0xFF765745);
  static const Color lightBeige = Color(0xFFF4ECE1);

  /// Выполняет поиск книг по введенному запросу
  ///
  /// Процесс поиска:
  /// 1. Проверяет что поле поиска не пустое
  /// 2. Устанавливает флаг загрузки и очищает предыдущие результаты
  /// 3. Вызывает BookService для выполнения API запроса
  /// 4. Обновляет состояние с полученными результатами
  ///
  /// @throws Exception при ошибках сетевого запроса или парсинга

  void _search() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _loading = true;
      _books = [];
    });

    final results = await BookService.searchBooks(_controller.text);

    setState(() {
      _books = results;
      _loading = false;
    });
  }

  void _openBookDetails(Book partialBook) async {
    // Проверяем, есть ли у книги ключ для запроса (OLID)
    if (partialBook.key == null || partialBook.key!.isEmpty) {
      // Если ключа нет, переходим с тем, что есть.
      _navigateToDetails(partialBook);
      return;
    }

    // 2. Делаем запрос на получение полной информации
    final details = await BookService.fetchBookDetails(partialBook.key!);

    // 3. Создаем финальный объект, обновляя старый
    final finalBook = details != null
        ? partialBook.copyWith(
            description: details.description,
            totalPages: details.numberOfPages,
          )
        : partialBook;

    // 4. Переходим на страницу деталей с полным объектом
    _navigateToDetails(finalBook);
  }

// Отдельный метод для навигации
  void _navigateToDetails(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 15,
            ),
            color: primaryBrown,
            child: const Center(
              child: Text(
                'Найдите книгу!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Поле поиска под коричневой областью
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            color: lightBeige,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Введите название книги',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ),

          // Тело с результатами поиска
          Expanded(
            child: Container(
              color: lightBeige,
              child: _buildBodyContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: primaryBrown));
    }

    return ListView.builder(
      itemCount: _books.length,
      padding: const EdgeInsets.only(top: 16),
      itemBuilder: (context, index) {
        final book = _books[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            onTap: () => _openBookDetails(book), // Переход на страницу деталей
            leading: book.coverUrl != null
                ? Image.network(
                    book.coverUrl!,
                    width: 50,
                    height: 70,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.book),
            title: Text(book.title),
            subtitle: Text(book.author),
          ),
        );
      },
    );
  }
}
