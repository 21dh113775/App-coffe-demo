import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  BottomNavigation({required this.currentIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            _buildNavItem(Icons.home, 'Trang chủ', 0),
            _buildNavItem(Icons.local_drink, 'Đặt nước', 1),
            _buildNavItem(Icons.shopping_cart, 'Giỏ hàng', 2),
            _buildNavItem(Icons.card_giftcard, 'Ưu đãi', 3),
            _buildNavItem(Icons.person, 'Cá nhân', 4),
          ],
          currentIndex: currentIndex,
          selectedItemColor: Color.fromARGB(255, 255, 255, 255),
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 10,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: onItemTapped,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: _buildIcon(icon, currentIndex == index),
      label: label,
    );
  }

  Widget _buildIcon(IconData icon, bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.all(isActive ? 12 : 8),
      decoration: BoxDecoration(
        color: isActive ? Color.fromARGB(255, 7, 138, 3) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Color.fromARGB(255, 7, 138, 3).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: isActive ? 0.8 : 1, end: isActive ? 1 : 0.8),
        duration: Duration(milliseconds: 300),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Icon(
          icon,
          size: isActive ? 28 : 24,
          color: isActive ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }
}