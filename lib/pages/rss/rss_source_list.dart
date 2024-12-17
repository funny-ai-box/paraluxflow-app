import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lazyreader/pages/rss/rss_source_detail.dart';
import 'package:lazyreader/service/rss_service.dart';

class RssSourceList extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  RssSourceList({required this.categoryId, required this.categoryName});

  @override
  _RssSourceListState createState() => _RssSourceListState();
}

class _RssSourceListState extends State<RssSourceList> {
  List<Map<String, dynamic>> sourceList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getRssSources();
  }

  void getRssSources() async {
    RssService rssService = RssService();
    try {
      var result = await rssService.getRssSourcesByCategory(widget.categoryId);
      setState(() {
        sourceList = List<Map<String, dynamic>>.from(result['data']);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching sources: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : sourceList.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  itemCount: sourceList.length,
                  itemBuilder: (context, index) {
                    return _buildSourceItem(sourceList[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 30), // 增加了一些间距
          SvgPicture.asset(
            'assets/images/empty_rss_sources.svg',
            width: 150, // 稍微减小了宽度
            height: 150, // 稍微减小了高度
          ),
          SizedBox(height: 30), // 增加了一些间距
          Text(
            '该分类下暂无RSS源',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            '请稍后再来查看或尝试其他分类',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceItem(Map<String, dynamic> source) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100], // 非常浅的灰色背景
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RssSourceDetailPage(source: source),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  source['logo'] ?? 'https://via.placeholder.com/50',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return SvgPicture.asset(
                      'assets/images/default_rss_icon.svg',
                      width: 50,
                      height: 50,
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      source['title'] ?? 'Untitled',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      source['description'] ?? 'No description available',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
