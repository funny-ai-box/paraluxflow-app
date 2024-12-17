import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Article {
  final String imageUrl;
  final String title;
  final String description;

  Article({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

class FavoritesRSSPage extends StatefulWidget {
  @override
  _FavoritesRSSPageState createState() => _FavoritesRSSPageState();
}

class _FavoritesRSSPageState extends State<FavoritesRSSPage> {
  List<Article> articles = [
    Article(
      imageUrl: 'https://picsum.photos/200',
      title: 'Flutter 2.0 Released',
      description:
          'Exciting new features in Flutter 2.0 including web and desktop support.',
    ),
    Article(
      imageUrl: 'https://picsum.photos/201',
      title: 'Dart 2.12 Introduces Null Safety',
      description:
          'Learn about the new null safety feature in Dart 2.12 and how it improves code quality.',
    ),
    Article(
      imageUrl: 'https://picsum.photos/202',
      title: 'Building Responsive UIs in Flutter',
      description:
          'Tips and tricks for creating responsive user interfaces that work across different screen sizes.',
    ),
    Article(
      imageUrl: 'https://picsum.photos/203',
      title: 'State Management in Flutter',
      description:
          'Comparing different state management solutions for Flutter applications.',
    ),
  ];

  void _removeArticle(int index) {
    setState(() {
      articles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          return Slidable(
            key: ValueKey(articles[index]),
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              dismissible:
                  DismissiblePane(onDismissed: () => _removeArticle(index)),
              children: [
                SlidableAction(
                  onPressed: (context) => _removeArticle(index),
                  backgroundColor: Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: '删除',
                ),
              ],
            ),
            child: ListTile(
              leading: Image.network(articles[index].imageUrl),
              title: Text(articles[index].title),
              subtitle: Text(articles[index].description),
            ),
          );
        },
      ),
    ));
  }
}
