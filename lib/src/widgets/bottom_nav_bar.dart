import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildNavBarItem(context, Icons.home, 'Home', 0, '/home'),
          _buildNavBarItem(
              context, Icons.history_edu_outlined, 'Loans', 1, '/loan/history'),
          const SizedBox(width: 40), // The space for the FAB
          _buildNavBarItem(
              context, Icons.help_outline_rounded, 'Help', 2, '/faq'),
          _buildNavBarItem(
              context, Icons.person_outline, 'Account', 3, '/profile'),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(BuildContext context, IconData icon, String label,
      int index, String path) {
    final isSelected = currentIndex == index;
    final color =
        isSelected ? Theme.of(context).colorScheme.primary : Colors.grey;

    return InkWell(
      onTap: () {
        // To avoid rebuilding the same page
        if (!isSelected) {
          context.go(path);
        }
      },
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
