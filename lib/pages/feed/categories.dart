import 'package:flutter/material.dart';
import 'package:lazyreader/pages/feed/list.dart';
import 'package:lazyreader/service/feed_service.dart';

class RssCategoryList extends StatefulWidget {
  @override
  _RssCategoryListState createState() => _RssCategoryListState();
}

class _RssCategoryListState extends State<RssCategoryList> {
  List<Map<String, dynamic>> categoryList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getRssCategory();
  }

  void getRssCategory() async {
    RssService rssService = RssService();
    try {
      var result = await rssService.getRssCategory();
      setState(() {
        categoryList = List<Map<String, dynamic>>.from(result['data']);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Category'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: categoryList.length,
              itemBuilder: (context, index) {
                return _buildCategoryTile(categoryList[index]);
              },
            ),
    );
  }

  Widget _buildCategoryTile(Map<String, dynamic> category) {
    return ListTile(
      title: Text(
        category['text'],
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
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
    );
  }
}
