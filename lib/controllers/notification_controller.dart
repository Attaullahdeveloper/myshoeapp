import 'package:get/get.dart';
import '../models/app_notification.dart';

class NotificationController extends GetxController {
  static NotificationController get to {
    if (Get.isRegistered<NotificationController>()) {
      return Get.find<NotificationController>();
    }
    return Get.put(NotificationController());
  }

  final RxList<AppNotification> notifications = <AppNotification>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockNotifications();
  }

  void _loadMockNotifications() {
    notifications.assignAll([
      // ── TODAY SECTION ──
      AppNotification(
        id: 'notif_1',
        title: 'We Have New Products With Offers',
        originalPrice: 364.95,
        discountedPrice: 260.00,
        timeAgo: '6 min ago',
        image: 'assets/images/shoe_nike_1.png',
        section: 'Today',
      ),
      AppNotification(
        id: 'notif_2',
        title: 'We Have New Products With Offers',
        originalPrice: 364.95,
        discountedPrice: 260.00,
        timeAgo: '26 min ago',
        image: 'assets/images/shoe_nike_2.png',
        section: 'Today',
      ),

      // ── YESTERDAY SECTION ──
      AppNotification(
        id: 'notif_3',
        title: 'We Have New Products With Offers',
        originalPrice: 364.95,
        discountedPrice: 260.00,
        timeAgo: '4 day ago',
        image: 'assets/images/shoe_nike_3.png',
        section: 'Yesterday',
      ),
      AppNotification(
        id: 'notif_4',
        title: 'We Have New Products With Offers',
        originalPrice: 364.95,
        discountedPrice: 260.00,
        timeAgo: '4 day ago',
        image: 'assets/images/shoe_nike_2.png',
        section: 'Yesterday',
      ),
    ]);
  }

  void clearAll() {
    notifications.clear();
  }

  void removeNotification(String id) {
    notifications.removeWhere((item) => item.id == id);
  }

  List<AppNotification> get todayNotifications =>
      notifications.where((n) => n.section == 'Today').toList();

  List<AppNotification> get yesterdayNotifications =>
      notifications.where((n) => n.section == 'Yesterday').toList();
}
