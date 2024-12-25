import 'package:flutter/material.dart';
import 'package:lazyreader/pages/feed/list.dart';
import 'package:lazyreader/service/feed_service.dart';

class RSS extends StatefulWidget {
  @override
  _RssPageState createState() => _RssPageState();
}

class _RssPageState extends State<RSS> {
  List<Map<String, dynamic>> categoryList = [];
  final RssService rssService = RssService();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      var result = await rssService.getRssCategory();
      setState(() {
        categoryList = List<Map<String, dynamic>>.from(result['data']);
      });
    } catch (e) {
      print('Error fetching categories: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取分类失败: $e')),
        );
      }
    }
  }

  IconData getCategoryIcon(String categoryName) {
    final Map<String, IconData> iconMap = {
      'World': Icons.public,
      'Politics': Icons.policy,
      'Business': Icons.business,
      'Technology': Icons.computer,
      'Health': Icons.health_and_safety,
      'Science & Environment': Icons.science,
      'Entertainment & Arts': Icons.theater_comedy,
      'Sports': Icons.sports_soccer,
      'Gaming': Icons.games,
      'Travel': Icons.flight_takeoff
    };
    return iconMap[categoryName] ?? Icons.rss_feed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
          onRefresh: _fetchCategories,
          child: categoryList.isEmpty
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: categoryList.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryItem(categoryList[index]);
                    },
                  ),
                )),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final IconData categoryIcon = getCategoryIcon(category['name']);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RssSourceList(
                  categoryId: category['id'].toString(),
                  categoryName: category['name'],
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    categoryIcon,
                    size: 28, // 增大图标
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: 18, // 增大分类名称字体
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tap to view sources', // 添加提示文本
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
