import 'package:flutter/material.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'СТРАНИЦА: Заметки ',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
      ),
    );
  }
}