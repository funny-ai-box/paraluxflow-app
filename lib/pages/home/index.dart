import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lazyreader/components/article_card.dart';
import 'package:lazyreader/service/ai_service.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<DailyNewsSummary> dailyNewsSummaries = [
    DailyNewsSummary(
      date: DateTime.now().subtract(Duration(days: 3)),
      summaries: [
        'Major tech company announces new product line',
        'International peace talks make progress',
        'Record-breaking heatwave affects multiple countries',
      ],
    ),
    DailyNewsSummary(
      date: DateTime.now().subtract(Duration(days: 2)),
      summaries: [
        'Global stock markets show signs of recovery',
        'Breakthrough in medical research announced',
        'Major sports event concludes with surprising results',
      ],
    ),
    DailyNewsSummary(
      date: DateTime.now().subtract(Duration(days: 1)),
      summaries: [
        'New legislation passed to address climate change',
        'Tech giant faces antitrust investigation',
        'International film festival announces award winners',
      ],
    ),
    DailyNewsSummary(
      date: DateTime.now(),
      summaries: [
        'Alexander wears modified helmet in road races',
        'New economic policy announced',
        'Breakthrough in renewable energy research',
      ],
    ),
  ];

  List<Map<String, dynamic>> recommendedArticles = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecommendedArticles();
  }

  Future<void> _loadRecommendedArticles() async {
    setState(() {
      isLoading = true;
    });
    AiService aiService = AiService();
    try {
      final Map<String, dynamic> articlesData =
          await aiService.getRecommendArticles();
      setState(() {
        if (articlesData.containsKey('data') && articlesData['data'] is List) {
          recommendedArticles =
              List<Map<String, dynamic>>.from(articlesData['data']);
        } else {
          recommendedArticles = [];
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error loading recommended articles: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadRecommendedArticles,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionHeader(context, 'Breaking News', 'View all'),
                  SizedBox(height: 20),
                  _buildBreakingNewsSlider(),
                  SizedBox(height: 20),
                  _buildSectionHeader(context, 'Recommendation', null),
                  SizedBox(height: 20),
                  if (isLoading)
                    Center(child: CircularProgressIndicator())
                  else if (recommendedArticles.isEmpty)
                    Text('No recommendations available')
                  else
                    ...recommendedArticles.map((article) => Column(
                          children: [
                            ArticleCard(article: article),
                            Divider(
                              height: 20,
                              color: Colors.grey[200],
                            ),
                            SizedBox(height: 10),
                          ],
                        )),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/bbc.png'),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, String? actionText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            actionText != null
                ? TextButton(
                    onPressed: () {
                      // Handle view all action
                    },
                    child: Text(actionText,
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                  )
                : SizedBox.shrink(),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            height: 4,
            width: 60,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakingNewsSlider() {
    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dailyNewsSummaries.length,
        itemBuilder: (context, index) {
          return BreakingNewsCard(dailyNewsSummary: dailyNewsSummaries[index]);
        },
      ),
    );
  }
}

class DailyNewsSummary {
  final DateTime date;
  final List<String> summaries;

  DailyNewsSummary({required this.date, required this.summaries});
}

class BreakingNewsCard extends StatelessWidget {
  final DailyNewsSummary dailyNewsSummary;

  const BreakingNewsCard({Key? key, required this.dailyNewsSummary})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMMM d, yyyy').format(dailyNewsSummary.date),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: dailyNewsSummary.summaries.length,
                  itemBuilder: (context, summaryIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87)),
                          Expanded(
                            child: Text(
                              dailyNewsSummary.summaries[summaryIndex],
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    // Handle 'See more' action
                  },
                  child: Text('See more',
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
