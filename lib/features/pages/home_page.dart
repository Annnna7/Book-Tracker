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
library;

import 'package:flutter/material.dart';
import '../widgets/control_panel.dart';
import 'home_main_page.dart';
import 'book_search_page.dart';
import 'wishlist_page.dart';
import 'read_books_page.dart';
import 'notes_page.dart';
import 'package:book_tracker_app/features/widgets/nav_item.dart';

class HomePage extends StatefulWidget {
  final NavItem? initialItem; 

  const HomePage({super.key, this.initialItem}); 

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late NavItem _selectedItem;

  final List<Widget> _pages = [
    const HomeMainPage(),   // 0: NavItem.home
    const WishlistPage(),   // 1: NavItem.wishlist
    const BookSearchPage(), // 2: NavItem.search
    const ReadBooksPage(),  // 3: NavItem.completed
    const NotesPage(),      // 4: NavItem.notes
  ];

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.initialItem ?? NavItem.home;
  }

  void _onItemTapped(NavItem item) {
    setState(() {
      _selectedItem = item;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedItem.index],
      
      bottomNavigationBar: ControlPanel(
        selectedItem: _selectedItem,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}