import 'package:flutter/material.dart';
import 'package:lazyreader/pages/articles/favorite_list.dart';
import 'package:lazyreader/pages/home/index.dart';
import 'package:lazyreader/pages/articles/list.dart';
import 'package:lazyreader/pages/mine/index.dart';
import 'package:lazyreader/pages/rss/index.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({Key? key}) : super(key: key);

  @override
  _HomeScreenPageState createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  final List<Widget> _pages = [
    HomePage(),
    ArticleList(),
    RSS(),
    FavoritesRSSPage(),
    MineMainPage()
  ];
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildIcon(IconData icon, bool isSelected) {
    return Icon(
      icon,
      size: 28, // 图标尺寸从 24 增加到 28
      color:
          isSelected ? Theme.of(context).colorScheme.primary : Colors.black54,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.home_outlined, _selectedIndex == 0),
            activeIcon: _buildIcon(Icons.home, _selectedIndex == 0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.rss_feed_outlined, _selectedIndex == 1),
            activeIcon: _buildIcon(Icons.rss_feed, _selectedIndex == 1),
            label: 'Feeds',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.search_outlined, _selectedIndex == 2),
            activeIcon: _buildIcon(Icons.search_rounded, _selectedIndex == 2),
            label: 'Collections',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.bookmark_border, _selectedIndex == 3),
            activeIcon: _buildIcon(Icons.bookmark, _selectedIndex == 3),
            label: 'Collections',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.person_outline, _selectedIndex == 4),
            activeIcon: _buildIcon(Icons.person, _selectedIndex == 4),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
