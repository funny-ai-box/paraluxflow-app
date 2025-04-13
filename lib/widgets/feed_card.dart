import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lazyreader/models/Subscription.dart';

class FeedCard extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onSettingsTap;

  const FeedCard({
    Key? key,
    required this.subscription,
    required this.onTap,
    this.onFavoriteTap,
    this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Feed图标
              _buildFeedLogo(),
              SizedBox(width: 16),
              
              // 订阅信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.displayTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    if (subscription.feed?.description != null)
                      Text(
                        subscription.feed!.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoItem(
                          context,
                          subscription.unreadCount.toString(),
                          '未读',
                          Icons.visibility_outlined,
                        ),
                        SizedBox(width: 16),
                        _buildInfoItem(
                          context,
                          subscription.readCount.toString(),
                          '已读',
                          Icons.check_circle_outline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 操作按钮
              Column(
                children: [
                  if (onFavoriteTap != null)
                    IconButton(
                      icon: Icon(
                        subscription.isFavorite
                            ? Icons.star
                            : Icons.star_border,
                        color: subscription.isFavorite
                            ? Colors.amber
                            : Colors.grey,
                        size: 24,
                      ),
                      onPressed: onFavoriteTap,
                    ),
                  if (onSettingsTap != null)
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                        size: 24,
                      ),
                      onPressed: onSettingsTap,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedLogo() {
    final String? logoUrl = subscription.feed?.logo;
    const double size = 50;
    final Color primaryColor = Colors.blue; // 使用固定颜色而不是Theme.of(context)

    if (logoUrl == null || logoUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            Icons.rss_feed,
            color: primaryColor,
            size: 24,
          ),
        ),
      );
    }

    if (logoUrl.endsWith('.svg')) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SvgPicture.network(
            logoUrl,
            placeholderBuilder: (context) => Container(
              color: Colors.grey[200],
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: logoUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.broken_image,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String count,
    String label,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(width: 4),
        Text(
          '$count $label',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}