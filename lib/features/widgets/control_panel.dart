import 'package:flutter/material.dart';

enum NavItem {
  home,        // Главная
  wishlist,    // Вишлист
  search,      // Поиск
  completed,   // Прочитанное
  notes,       // Заметки
}

/// Кастомная нижняя панель навигации для приложения BookTracker
/// 
/// Этот виджет предоставляет:
/// - Интуитивную навигацию между основными разделами приложения
/// - Визуальную индикацию текущего раздела через выделение активной кнопки
/// - Единый стиль с брендовыми цветами приложения
/// - Плавные переходы между состояниями кнопок
/// 
/// Особенности дизайна:
/// - Активная кнопка отображается как коричневый кружок с белой иконкой
/// - Неактивные кнопки - серые иконки без фона
/// - Тень для создания эффекта "парящей" панели
/// - Фиксированная высота 70px для оптимального UX
/// 
/// Принцип работы:
/// - Получает текущее состояние через параметр selectedItem
/// - Передает пользовательские взаимодействия через callback onItemTapped
/// - Автоматически перерисовывается при изменении состояния

class ControlPanel extends StatelessWidget {
  final NavItem selectedItem;
  final ValueChanged<NavItem> onItemTapped;

  const ControlPanel({
    Key? key,
    required this.selectedItem,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryBrown = Color.fromRGBO(107, 79, 57, 1.0);
    const Color inactiveColor = Colors.grey;

    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Кнопка 1: Главная
          _buildNavItem(
            item: NavItem.home,
            icon: Icons.home_outlined,
            activeColor: primaryBrown,
            inactiveColor: inactiveColor,
            isSelected: selectedItem == NavItem.home,
          ),
          // Кнопка 2: Вишлист
          _buildNavItem(
            item: NavItem.wishlist,
            icon: Icons.favorite_border,
            activeColor: primaryBrown,
            inactiveColor: inactiveColor,
            isSelected: selectedItem == NavItem.wishlist,
          ),
          // Кнопка 3: Поиск
          _buildNavItem(
            item: NavItem.search,
            icon: Icons.search,
            activeColor: primaryBrown,
            inactiveColor: inactiveColor,
            isSelected: selectedItem == NavItem.search,
          ),
          // Кнопка 4: Прочитанное
          _buildNavItem(
            item: NavItem.completed,
            icon: Icons.check_box_outlined,
            activeColor: primaryBrown,
            inactiveColor: inactiveColor,
            isSelected: selectedItem == NavItem.completed,
          ),
          // Кнопка 5: Заметки
          _buildNavItem(
            item: NavItem.notes,
            icon: Icons.notes_outlined,
            activeColor: primaryBrown,
            inactiveColor: inactiveColor,
            isSelected: selectedItem == NavItem.notes,
          ),
        ],
      ),
    );
  }

    /// Создает отдельный элемент навигации с учетом его состояния
  /// 
  /// @param item - идентификатор пункта навигации
  /// @param icon - иконка Material Icons для отображения
  /// @param activeColor - цвет для активного состояния
  /// @param inactiveColor - цвет для неактивного состояния
  /// @param isSelected - флаг указывающий является ли элемент текущим
  /// 
  /// @return Widget - кнопка навигации в соответствующем состоянии:
  /// - Активная: кружок с цветом activeColor и белой иконкой
  /// - Неактивная: простая иконка цвета inactiveColor

  Widget _buildNavItem({
    required NavItem item,
    required IconData icon,
    required Color activeColor,
    required Color inactiveColor,
    required bool isSelected,
  }) {
    if (isSelected) {
      // Активная кнопка с кружком (для всех кнопок)
      return InkWell(
        onTap: () => onItemTapped(item),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: activeColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    } else {
      // Неактивная кнопка (простая иконка)
      return IconButton(
        icon: Icon(icon, color: inactiveColor, size: 24),
        onPressed: () => onItemTapped(item),
      );
    }
  }
}