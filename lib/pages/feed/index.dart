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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('RSS Categories',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _fetchCategories,
        child: categoryList.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: (categoryList.length / 2).ceil(),
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildCategoryTile(categoryList[index * 2]),
                      ),
                      SizedBox(width: 12),
                      if (index * 2 + 1 < categoryList.length)
                        Expanded(
                          child:
                              _buildCategoryTile(categoryList[index * 2 + 1]),
                        ),
                      if (index * 2 + 1 >= categoryList.length) Spacer(),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildCategoryTile(Map<String, dynamic> category) {
    final IconData categoryIcon = getCategoryIcon(category['name']);
    final Color iconColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
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
          child: Container(
            height: 80, // 固定高度
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    categoryIcon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
