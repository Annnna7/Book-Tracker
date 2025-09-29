import 'package:flutter/material.dart';

void main() {
  runApp(BookTrackerApp());
}

class BookTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookTracker',
      home: BookLibraryPage(),
    );
  }
}

class BookLibraryPage extends StatefulWidget {
  @override
  State<BookLibraryPage> createState() => _BookLibraryPageState();
}

class _BookLibraryPageState extends State<BookLibraryPage> {
  List<String> _books = [];

  void _addBook() {
    setState(() {
      _books.add('Книга ${_books.length + 1}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Моя библиотека'),
      ),
      body: _books.isEmpty
          ? Center(
        child: Text('Добавьте первую книгу'),
      )
          : ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_books[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        child: Icon(Icons.add),
      ),
    );
  }
}