import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/nav_item.dart';

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
    const Color backgroundColor = Color(0xFFF4ECE1);

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            item: NavItem.home,
            iconPath: 'assets/icons/home.svg',
            activeColor: primaryBrown,
            isSelected: selectedItem == NavItem.home,
          ),
          _buildNavItem(
            item: NavItem.wishlist,
            iconPath: 'assets/icons/wishlist.svg',
            activeColor: primaryBrown,
            isSelected: selectedItem == NavItem.wishlist,
          ),
          _buildNavItem(
            item: NavItem.search,
            iconPath: 'assets/icons/search.svg',
            activeColor: primaryBrown,
            isSelected: selectedItem == NavItem.search,
          ),
          _buildNavItem(
            item: NavItem.completed,
            iconPath: 'assets/icons/completed.svg',
            activeColor: primaryBrown,
            isSelected: selectedItem == NavItem.completed,
          ),
          _buildNavItem(
            item: NavItem.notes,
            iconPath: 'assets/icons/notes.svg',
            activeColor: primaryBrown,
            isSelected: selectedItem == NavItem.notes,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required NavItem item,
    required String iconPath,
    required Color activeColor,
    required bool isSelected,
  }) {
    if (isSelected) {
      // Активная кнопка - белая иконка на коричневом фоне
      return InkWell(
        onTap: () => onItemTapped(item),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: activeColor,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            iconPath,
            width: 28,
            height: 28,
          ),
        ),
      );
    } else {
      // Неактивная кнопка - оригинальный цвет иконки (черный)
      return IconButton(
        icon: SvgPicture.asset(
          iconPath,
          width: 24,
          height: 24,
        ),
        onPressed: () => onItemTapped(item),
      );
    }
  }
}