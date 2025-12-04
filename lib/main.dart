import 'package:flutter/material.dart';
import 'features/pages/home_page.dart'; 

import 'package:provider/provider.dart';
import 'features/pages/wishlist_provider.dart';
import 'features/pages/read_books_provider.dart';

Widget build(BuildContext context) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ChangeNotifierProvider(create: (_) => ReadBooksProvider()),
    ],
    child: MaterialApp(
      title: 'BookTracker',
      home: HomePage(),
    ),
  );
}

void main() {
  runApp(const BookTrackerApp());
}

class BookTrackerApp extends StatelessWidget {
  const BookTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'BookTracker',
      home: HomePage(), 
    );
  }
}

// старый main
// пусть будет навсякий, если не надо, удалите 

// import 'package:flutter/material.dart';
// import 'services/book_service.dart';

// void main() {
//   runApp(BookTrackerApp());
// }

// class BookTrackerApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'BookTracker',
//       home: BookSearchPage(),
//     );
//   }
// }

// class BookSearchPage extends StatefulWidget {
//   @override
//   _BookSearchPageState createState() => _BookSearchPageState();
// }

// class _BookSearchPageState extends State<BookSearchPage> {
//   final TextEditingController _controller = TextEditingController();
//   List<Book> _books = [];
//   bool _loading = false;

//   void _search() async {
//     if (_controller.text.isEmpty) return;

//     setState(() {
//       _loading = true;
//     });

//     final results = await BookService.searchBooks(_controller.text);

//     setState(() {
//       _books = results;
//       _loading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Поиск книг'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: InputDecoration(
//                       hintText: 'Название книги',
//                       border: OutlineInputBorder(),
//                     ),
//                     onSubmitted: (_) => _search(),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: _search,
//                   child: Text('Поиск'),
//                 ),
//               ],
//             ),
//           ),
//           _loading
//               ? Center(child: CircularProgressIndicator())
//               : Expanded(
//             child: ListView.builder(
//               itemCount: _books.length,
//               itemBuilder: (context, index) {
//                 final book = _books[index];
//                 return Card(
//                   margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                   child: ListTile(
//                     leading: book.coverUrl != null
//                         ? Image.network(
//                       book.coverUrl!,
//                       width: 50,
//                       height: 70,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Icon(Icons.book);
//                       },
//                     )
//                         : Icon(Icons.book),
//                     title: Text(book.title),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(book.author),
//                         if (book.description != null)
//                           Padding(
//                             padding: EdgeInsets.only(top: 4),
//                             child: Text(
//                               book.description!,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(fontSize: 12),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }