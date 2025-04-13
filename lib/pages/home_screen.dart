import 'package:flutter/material.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({Key? key}) : super(key: key);

  @override
  _HomeScreenPageState createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage>
    with SingleTickerProviderStateMixin {
  final List<Widget> _pages = [
  
  ];

  int _selectedIndex = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      _controller.reset();
      _controller.forward();
    });
  }

  Widget _buildIcon(IconData icon, bool isSelected) {
    return Icon(
      icon,
      size: 24,
      color:
          isSelected ? Theme.of(context).colorScheme.primary : Colors.black45,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 8,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        iconSize: 24,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.black45,
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.home_outlined, _selectedIndex == 0),
            activeIcon: _buildIcon(Icons.home_rounded, _selectedIndex == 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.article_outlined, _selectedIndex == 1),
            activeIcon: _buildIcon(Icons.article_rounded, _selectedIndex == 1),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.stream_outlined, _selectedIndex == 2),
            activeIcon: _buildIcon(Icons.stream_rounded, _selectedIndex == 2),
            label: 'Sources',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.star_outline_rounded, _selectedIndex == 3),
            activeIcon: _buildIcon(Icons.star_rounded, _selectedIndex == 3),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
