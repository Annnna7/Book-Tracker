/// Главный навигационный экран приложения BookTracker
/// 
/// Этот виджет отвечает за:
/// - Управление навигацией между основными разделами приложения
/// - Отображение соответствующей страницы при выборе вкладки
/// - Координацию работы нижней панели навигации (ControlPanel)
/// 
/// Структура навигации:
/// - HomeMainPage: Главная страница с обзором
/// - WishlistPage: Список желаемых книг
/// - BookSearchPage: Поиск и добавление книг
/// - ReadBooksPage: Архив прочитанных книг
/// - NotesPage: Заметки и профиль пользователя
/// 
/// Принцип работы:
/// 1. Хранит текущее состояние выбранной вкладки в _selectedItem
/// 2. Содержит список всех страниц _pages в соответствующем порядке
/// 3. При нажатии на кнопку в ControlPanel обновляет состояние и отображает нужную страницу

import 'package:flutter/material.dart';
import '../widgets/control_panel.dart';
import 'home_main_page.dart';
import 'book_search_page.dart';
import 'wishlist_page.dart';
import 'read_books_page.dart';
import 'notes_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NavItem _selectedItem = NavItem.home;

  // Создаем список страниц сразу, без initState
  final List<Widget> _pages = [
    const HomeMainPage(),   // 0: NavItem.home
    const WishlistPage(),   // 1: NavItem.wishlist
    const BookSearchPage(), // 2: NavItem.search
    const ReadBooksPage(),  // 3: NavItem.completed
    const NotesPage(),      // 4: NavItem.notes
  ];

  void _onItemTapped(NavItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  String _getTitle() {
    switch (_selectedItem) {
      case NavItem.home:
        return 'Главная';
      case NavItem.wishlist:
        return 'Список Желаемого';
      case NavItem.search:
        return 'Поиск Книг';
      case NavItem.completed:
        return 'Прочитанное';
      case NavItem.notes:
        return 'Заметки';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Добавляем проверку на валидность индекса
      body: _pages[_selectedItem.index],
      
      bottomNavigationBar: ControlPanel(
        selectedItem: _selectedItem,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}