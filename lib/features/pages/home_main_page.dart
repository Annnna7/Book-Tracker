/// Главная страница приложения BookTracker
/// 
/// Этот экран служит стартовой точкой приложения и предоставляет:
/// - Обзор текущего состояния библиотеки пользователя
/// - Быстрый доступ к основным функциям приложения
/// - Визуальное представление прогресса чтения
/// - Навигацию к ключевым разделам приложения
/// 
library;

import 'package:flutter/material.dart';

class HomeMainPage extends StatelessWidget {
  const HomeMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'ГЛАВНАЯ СТРАНИЦА',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}