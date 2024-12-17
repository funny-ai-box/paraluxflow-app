import 'package:flutter/material.dart';
import 'package:lazyreader/pages/rss/rss_category_list.dart';
import 'package:lazyreader/pages/rss/rss_source_list.dart';
import 'package:lazyreader/service/rss_service.dart';

class RSS extends StatefulWidget {
  @override
  _RssPageState createState() => _RssPageState();
}

class _RssPageState extends State<RSS> {
  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> specialSourcesList = [];

  @override
  void initState() {
    super.initState();
    getRssCategory();
    getSpecialSources();
  }

  void getRssCategory() async {
    RssService rssService = RssService();
    try {
      var result = await rssService.getRssCategory();
      setState(() {
        categoryList = List<Map<String, dynamic>>.from(result['data']);
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  void getSpecialSources() {
    // This would typically be an API call. For now, we'll use mock data.
    setState(() {
      specialSourcesList = [
        {"name": "Google News", "icon": Icons.article},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchBar(),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '重点订阅源精选',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RssCategoryList()),
                      );
                    },
                    child: Text('查看更多'),
                  ),
                ],
              ),
            ),
            _buildCategoryGrid(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '特殊订阅源',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildSpecialSourcesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      height: 36, // Smaller height
      child: Center(
        child: TextField(
          decoration: InputDecoration(
            hintText: '搜索网站和订阅源',
            hintStyle: TextStyle(fontSize: 14), // Smaller font size
            prefixIcon: Icon(Icons.search, size: 20), // Smaller icon
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30), // More rounded
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: categoryList.length > 6 ? 6 : categoryList.length,
      itemBuilder: (context, index) {
        return _buildCategoryTile(categoryList[index]);
      },
    );
  }

  Widget _buildCategoryTile(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RssSourceList(
              categoryId: category['id'].toString(),
              categoryName: category['text'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.primaries[category['id'] % Colors.primaries.length],
        ),
        child: Center(
          child: Text(
            category['text'],
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialSourcesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: specialSourcesList.length,
      itemBuilder: (context, index) {
        return _buildSpecialSourceTile(specialSourcesList[index]);
      },
    );
  }

  Widget _buildSpecialSourceTile(Map<String, dynamic> source) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(source['icon'], size: 40),
        SizedBox(height: 8),
        Text(source['name'], textAlign: TextAlign.center),
      ],
    );
  }
}
