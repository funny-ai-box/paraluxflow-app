import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class ArticleCard extends StatelessWidget {
  final String title;
  final String feedTitle;
  final String? feedLogo;
  final String? summary;
  final String? thumbnailUrl;
  final DateTime publishedDate;
  final bool isRead;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const ArticleCard({
    Key? key,
    required this.title,
    required this.feedTitle,
    this.feedLogo,
    this.summary,
    this.thumbnailUrl,
    required this.publishedDate,
    required this.isRead,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 带缩略图的标题栏
            _buildHeader(context),
            
            // 文章摘要
            if (summary != null && summary!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  summary!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: isRead ? Colors.grey : Colors.black87,
                  ),
                ),
              ),
            
            // 底部信息栏
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文章主要内容区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    color: isRead ? Colors.grey : Colors.black,
                  ),
                ),
                
                // 来源信息
                SizedBox(height: 8),
                Row(
                  children: [
                    if (feedLogo != null)
                      Container(
                        width: 18,
                        height: 18,
                        margin: EdgeInsets.only(right: 8),
                        child: CachedNetworkImage(
                          imageUrl: feedLogo!,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.rss_feed,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        feedTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 缩略图
          if (thumbnailUrl != null)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CachedNetworkImage(
                    imageUrl: thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 发布时间
          Text(
            timeago.format(publishedDate, locale: 'zh_CN'),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          
          // 收藏按钮
          GestureDetector(
            onTap: onFavoriteTap,
            child: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              size: 20,
              color: isFavorite ? Colors.amber : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}