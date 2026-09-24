import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/notification_controller.dart';
import '../controller/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController controller = NotificationController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1A),
        foregroundColor: Colors.white,
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Obx(() => Stack(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2236),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2A3550)),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Colors.white.withOpacity(0.7),
                  size: 22.w,
                ),
              ),
              if (controller.unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: const BoxDecoration(color: Color(0xFFFF5252), shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '${controller.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                ),
            ],
          )),
          SizedBox(width: 12.w),
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2236),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2A3550)),
            ),
            child: Icon(Icons.more_vert, color: Colors.white, size: 22.w),
          ),
          SizedBox(width: 20.w),
        ],
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Keep up with your rewards and rankings.',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15.sp),
            ),
          ),
          SizedBox(height: 20.h),

          // Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Obx(() => Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2236),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF2A3550)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.setTab(false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !controller.showUnreadOnly.value ? const Color(0xFF0A0E1A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          border: !controller.showUnreadOnly.value ? Border.all(color: const Color(0xFF2A3550)) : null,
                        ),
                        child: Center(
                          child: Text(
                            'All',
                            style: TextStyle(
                              color: !controller.showUnreadOnly.value ? Colors.white : Colors.white.withOpacity(0.5),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.setTab(true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: controller.showUnreadOnly.value ? const Color(0xFF0A0E1A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          border: controller.showUnreadOnly.value ? Border.all(color: const Color(0xFF2A3550)) : null,
                        ),
                        child: Center(
                          child: Text(
                            'Unread',
                            style: TextStyle(
                              color: controller.showUnreadOnly.value ? Colors.white : Colors.white.withOpacity(0.5),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ),
          SizedBox(height: 20.h),

          // Notification List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF4D94FF)));
              }
              if (controller.notifications.isEmpty) {
                return Center(
                  child: Text(
                    controller.showUnreadOnly.value ? 'No unread notifications' : 'No notifications yet',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14.sp),
                  ),
                );
              }
              return RefreshIndicator(
                color: const Color(0xFF4D94FF),
                backgroundColor: const Color(0xFF1A2236),
                onRefresh: controller.fetchNotifications,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: controller.notifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationItem(controller.notifications[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    // ✅ Logic: Show actions only if type matches AND action is not done yet
    final showActions = notification.type == 'TRAINER_REQUEST_TO_CLUB_ADMIN' && !notification.isActionDone;

    // ✅ Logic: Read হলে হালকা রঙ (Opacity 0.5), Unread হলে সাদা/উজ্জ্বল (Opacity 1.0)
    final titleColor = notification.isRead ? Colors.white.withOpacity(0.5) : Colors.white;
    final messageColor = notification.isRead ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.7);
    final borderColor = notification.isRead
        ? const Color(0xFF2A3550)
        : const Color(0xFF4D94FF).withOpacity(0.5);

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) controller.markAsRead(notification.id);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2236),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    notification.title.isNotEmpty ? notification.title : 'Notification',
                    style: TextStyle(
                        color: titleColor,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                Text(
                  controller.timeAgo(notification.createdAt),
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13.sp),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              notification.message,
              style: TextStyle(color: messageColor, fontSize: 14.sp),
            ),
            if (showActions) ...[
              SizedBox(height: 14.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => controller.handleNotificationAction(
                      notificationId: notification.id,
                      referenceId: notification.referenceId ?? '',
                      status: "ACTIVE",
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D94FF),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text('Approve', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => controller.handleNotificationAction(
                      notificationId: notification.id,
                      referenceId: notification.referenceId ?? '',
                      status: "REJECTED",
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFF2A3550)),
                      ),
                      child: Text('Decline', style: TextStyle(color: Colors.white70, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}