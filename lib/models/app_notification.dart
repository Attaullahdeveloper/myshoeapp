class AppNotification {
  final String id;
  final String title;
  final double originalPrice;
  final double discountedPrice;
  final String timeAgo;
  final String image;
  final String section; // 'Today' or 'Yesterday'
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.originalPrice,
    required this.discountedPrice,
    required this.timeAgo,
    required this.image,
    required this.section,
    this.isRead = false,
  });
}
