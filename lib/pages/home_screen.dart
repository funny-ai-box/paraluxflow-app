import 'package:flutter/material.dart';
import 'package:lazyreader/pages/home/home_page.dart';
import 'package:lazyreader/pages/articles/articles_page.dart';
import 'package:lazyreader/pages/sources/sources_page.dart';
import 'package:lazyreader/pages/favorites/favorites_page.dart';
import 'package:lazyreader/pages/mine/index.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({Key? key}) : super(key: key);

  @override
  _HomeScreenPageState createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage>
    with SingleTickerProviderStateMixin {
  // 初始化所有页面
  final List<Widget> _pages = [
    HomePage(),           // 首页 - 静态欢迎页面
    ArticlesPage(),       // 文章列表页
    SourcesPage(),        // 订阅源页面
    FavoritesPage(),      // 收藏页面
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
      appBar: AppBar(
        title: _buildAppBarTitle(),
        actions: [
          if (_selectedIndex != 0) // 除了首页外，其他页面显示搜索按钮
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // 搜索功能
              },
            ),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MineMainPage()),
              );
            },
          ),
        ],
        elevation: 0,
      ),
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
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.article_outlined, _selectedIndex == 1),
            activeIcon: _buildIcon(Icons.article_rounded, _selectedIndex == 1),
            label: '文章',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.rss_feed_outlined, _selectedIndex == 2),
            activeIcon: _buildIcon(Icons.rss_feed_rounded, _selectedIndex == 2),
            label: '订阅源',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.star_outline_rounded, _selectedIndex == 3),
            activeIcon: _buildIcon(Icons.star_rounded, _selectedIndex == 3),
            label: '收藏',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // 根据当前选中的页面返回对应的标题
  Widget _buildAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return Text('LazyReader');
      case 1:
        return Text('所有文章');
      case 2:
        return Text('订阅源');
      case 3:
        return Text('我的收藏');
      default:
        return Text('LazyReader');
    }
  }
}