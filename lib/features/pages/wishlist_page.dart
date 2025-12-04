import '../pages/book_details_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import 'wishlist_provider.dart';

// --- Константы для цветов и стилей ---
const Color _primaryBrown = Color(0xFF765745);
const Color _secondaryCream = Color(0xFFF7F3EE);
const Color _lightCardColor = Color(0xFFE0D9D1);
const Color _darkBrown = Color.fromARGB(255, 55, 38, 22);
const Color _deleteButtonColor = Color(0xFFD9D9D9);

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WishlistProvider(),
      child: Scaffold(
        backgroundColor: _secondaryCream,
        body: Stack(
          children: [
            // 1. Коричневый эллипс как раньше, но перевернутый
            Positioned(
              left: -MediaQuery.of(context).size.width * 0.4,
              top: -MediaQuery.of(context).size.height * 0.225, // Изменено на top (перевернуто)
              child: Container(
                width: MediaQuery.of(context).size.width * 1.4,
                height: MediaQuery.of(context).size.height * 1.0,
                decoration: BoxDecoration(
                  color: const Color(0xFF765745),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(MediaQuery.of(context).size.width * 0.7),
                    topRight: Radius.circular(MediaQuery.of(context).size.width * 0.7),
                    bottomLeft: Radius.circular(MediaQuery.of(context).size.width * 0.7),
                    bottomRight: Radius.circular(MediaQuery.of(context).size.width * 0.7),
                  ),
                ),
              ),
            ),

            // 2. Основное содержимое
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок (белый шрифт на коричневом фоне)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Книги, которые стоит прочитать позже',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 22, // Немного уменьшен для длинного текста
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Кнопка поиска (прозрачный коричневый)
                          IconButton(
                            icon: Icon(Icons.search, 
                                color: _primaryBrown.withOpacity(0.8), // Прозрачный коричневый
                                size: 30),
                            onPressed: () {
                              // Действие поиска
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10.0),


                    // Динамический контент
                    Expanded(
                      child: Consumer<WishlistProvider>(
                        builder: (context, wishlistProvider, _) {
                          final wishlistBooks = wishlistProvider.wishlistBooks;
                          final bool hasBooks = wishlistBooks.isNotEmpty;
                          
                          return hasBooks 
                              ? _buildBooksList(context, wishlistBooks) 
                              : _buildEmptyState();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Список книг с контекстом для навигации
  Widget _buildBooksList(BuildContext context, List<Book> books) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: _BookCard(
            book: book,
            onTap: () {
              _navigateToBookDetails(context, book);
            },
            onRemove: () {
              Provider.of<WishlistProvider>(context, listen: false)
                  .removeFromWishlist(book);
            },
          ),
        );
      },
    );
  }

  // Навигация на страницу деталей книги
  void _navigateToBookDetails(BuildContext context, Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsPage(book: book),
      ),
    );
  }

  // Пустое состояние с белым текстом
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.white.withOpacity(0.8), // Белая иконка
          ),
          const SizedBox(height: 20),
          Text(
            'Вишлист пуст',
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white, // Белый текст
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Добавляйте книги в вишлист, чтобы не забыть прочитать их позже',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white.withOpacity(0.9), // Полупрозрачный белый
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Карточка одной книги в вишлисте
class _BookCard extends StatefulWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BookCard({
    required this.book,
    required this.onTap,
    required this.onRemove,
  });

  @override
  State<_BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<_BookCard> {
  bool _isExpanded = false;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Основная карточка с текстом И ОБЛОЖКОЙ
          Container(
            margin: const EdgeInsets.only(top: 0),
            padding: const EdgeInsets.only(left: 20, top: 15, right: 20, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
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
                  width: 80,
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
                    child: widget.book.coverUrl != null
                        ? Image.network(
                            widget.book.coverUrl!,
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
                      // Автор (Montserrat шрифт)
                      Text(
                        widget.book.author,
                        style: const TextStyle(
                          fontFamily: 'Montserrat', // Добавлен Montserrat
                          color: _darkBrown,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Название (Montserrat шрифт)
                      Text(
                        widget.book.title,
                        style: const TextStyle(
                          fontFamily: 'Montserrat', // Добавлен Montserrat
                          color: _primaryBrown,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      
                      // Описание с возможностью развернуть/свернуть (Montserrat шрифт)
                      if (widget.book.description != null && widget.book.description!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Column(

                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.book.description!,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat', // Добавлен Montserrat
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: _isExpanded ? 20 : 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          _isExpanded ? 'Скрыть' : 'Подробнее',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat', // Добавлен Montserrat
                                            color: _primaryBrown,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Icon(
                                          _isExpanded 
                                              ? Icons.keyboard_arrow_up 
                                              : Icons.keyboard_arrow_down,
                                          color: _primaryBrown,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Иконка удаления в самом низу карточки
          Positioned(
            bottom: 5, // Еще ниже, внизу карточки
            right: 20, // Правее
            child: GestureDetector(
              onTap: widget.onRemove,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _deleteButtonColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.brown.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.15),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.brown,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      color: _lightCardColor,
      child: Center(
        child: Icon(
          Icons.book, 
          color: _primaryBrown, 
          size: 40,
        ),
      ),
    );
  }
}
