/// Страница архива прочитанных книг в приложении BookTracker
/// 
/// Этот экран предназначен для отображения и управления:
/// - Полным архивом книг, завершенных пользователем
/// - Статистики и аналитики по прочитанному
/// - Хронологии чтения и личных достижений
/// - Возможности повторного просмотра и оценки книг
library;

import 'package:flutter/material.dart';

class ReadBooksPage extends StatelessWidget {
  const ReadBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'СТРАНИЦА: Прочитанные Книги',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }
}