import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import 'wishlist_provider.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WishlistProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4ECE1),
        body: SafeArea(
          child: Stack(
            children: [
              // Эллипс
              Positioned(
                left: -MediaQuery.of(context).size.width * 0.4,
                bottom: -MediaQuery.of(context).size.height * 0.225,
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
              // Контент
              const WishlistContent(),
            ],
          ),
        ),
      ),
    );
  }
}

class WishlistContent extends StatelessWidget {
  const WishlistContent({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final wishlistBooks = wishlistProvider.wishlistBooks;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок страницы
          const Padding(
            padding: EdgeInsets.only(top: 10.0, bottom: 30.0, left: 16.0),
            child: Text(
              'Книги, которые стоит прочитать позже',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Список книг или сообщение о пустом вишлисте
          Expanded(
            child: wishlistBooks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Вишлист пуст',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.0),
                          child: Text(
                            'Добавляйте книги в вишлист, чтобы не забыть прочитать их позже',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: wishlistBooks.length,
                    itemBuilder: (context, index) {
                      final book = wishlistBooks[index];
                      return _buildBookCard(context, book, index + 1);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book, int position) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Номер в списке
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF765745),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$position',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Обложка книги
          Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
              image: book.coverUrl != null 
                  ? DecorationImage(
                      image: NetworkImage(book.coverUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: book.coverUrl == null
                ? const Icon(Icons.book, color: Colors.grey, size: 20)
                : null,
          ),
          
          const SizedBox(width: 12),
          
          // Информация о книге
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название книги
                Text(
                  book.title,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),
                
                // Автор
                Text(
                  book.author,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 6),
                
                // Описание книги
                if (book.description != null)
                  Text(
                    book.description!,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87.withOpacity(0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          
          // Кнопка удаления
          IconButton(
            onPressed: () {
              Provider.of<WishlistProvider>(context, listen: false)
                  .removeFromWishlist(book);
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }
}