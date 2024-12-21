import 'package:flutter/material.dart';

class RssSourceDetailPage extends StatefulWidget {
  final Map<String, dynamic> source;

  RssSourceDetailPage({required this.source});

  @override
  _RssSourceDetailPageState createState() => _RssSourceDetailPageState();
}

class _RssSourceDetailPageState extends State<RssSourceDetailPage> {
  bool isSubscribed = false;
  List<Map<String, dynamic>> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // TODO: Implement actual data loading logic
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      isSubscribed = false; // TODO: Check actual subscription status
      articles = List.generate(
          5,
          (index) => {
                'title': 'Article ${index + 1}',
                'subtitle':
                    'This is a sample subtitle for article ${index + 1}',
                'source': 'Financial Times: Commodities',
                'time': '${index + 1}h',
                'imageUrl': 'https://via.placeholder.com/100',
              });
      isLoading = false;
    });
  }

  void _toggleSubscription() {
    // TODO: Implement actual subscription logic
    setState(() {
      isSubscribed = !isSubscribed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildSourceInfo(),
                  _buildArticlesList(),
                  _buildSubscribeButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildSourceInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            child: Text(
              'FT',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          SizedBox(height: 16),
          Text(
            widget.source['title'] ?? 'Financial Times: Commodities',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            widget.source['category'] ?? 'Commodities',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            '${widget.source['followers'] ?? '2K'} 关注者 · ${widget.source['articlesPerWeek'] ?? '27'} 文章/星期',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: articles.length,
      separatorBuilder: (context, index) => Divider(height: 1),
      itemBuilder: (context, index) {
        final article = articles[index];
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              article['imageUrl'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            article['title'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(article['subtitle']),
              SizedBox(height: 4),
              Text(
                '${article['source']} / ${article['time']}',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          onTap: () {
            // TODO: Implement article detail page navigation
          },
        );
      },
    );
  }

  Widget _buildSubscribeButton() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _toggleSubscription,
          child: Text(isSubscribed ? '取消订阅' : '关注'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: isSubscribed ? Colors.grey : Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 16),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
