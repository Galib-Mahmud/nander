import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../controller/chat_controller.dart';
import 'chat_screen.dart';
import 'my_teams_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatController controller = ChatController.to;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  static const bgColor = Color(0xFF050810);
  static const cardColor = Color(0xFF111827);
  static const borderColor = Color(0xFF1F2937);
  static const accent = Color(0xFF4D94FF);
  static const onlineColor = Color(0xFF4ADE80);
  static const textMuted = Color(0xFF8B95A5);

  @override
  void initState() {
    super.initState();
    controller.fetchConversations();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      controller.fetchConversations(search: value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    if (isToday) return '$h:$m $ampm';
    return '${dt.day}/${dt.month}/${dt.year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        titleSpacing: 8.w,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Chats',
          style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(() => Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Center(
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: controller.isSocketConnected.value ? onlineColor : Colors.white24,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    controller.isSocketConnected.value ? 'Online' : 'Offline',
                    style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                  ),
                ],
              ),
            ),
          )),
          GestureDetector(
            onTap: () => Get.to(() => const MyTeamsScreen()),
            child: Container(
              width: 40.w,
              height: 40.w,
              margin: EdgeInsets.only(right: 16.w),
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Icon(Icons.more_vert, color: Colors.white, size: 20.w),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Search bar ────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 12.h),
            child: Container(
              height: 46.h,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(23.r),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16.w),
                  Icon(Icons.search, color: textMuted, size: 20.w),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: _onSearchChanged,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'Search conversations',
                        hintStyle: TextStyle(color: textMuted, fontSize: 14.sp),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        searchController.clear();
                        controller.fetchConversations();
                        setState(() {});
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 12.w),
                        width: 22.w,
                        height: 22.w,
                        decoration: const BoxDecoration(color: Color(0xFF1F2937), shape: BoxShape.circle),
                        child: Icon(Icons.close, color: accent, size: 13.w),
                      ),
                    )
                  else
                    SizedBox(width: 16.w),
                ],
              ),
            ),
          ),

          // ─── List ─────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoadingConversations.value && controller.conversations.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: accent));
              }
              if (controller.conversations.isEmpty) {
                return _EmptyState(searchTerm: searchController.text);
              }
              return RefreshIndicator(
                color: accent,
                backgroundColor: cardColor,
                onRefresh: () => controller.fetchConversations(search: searchController.text),
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 4.h, bottom: 20.h),
                  itemCount: controller.conversations.length,
                  itemBuilder: (context, index) {
                    final convo = controller.conversations[index];
                    return _ConversationTile(
                      convo: convo,
                      timeLabel: _formatTime(convo.lastMessageTime),
                      onTap: () {
                        Get.to(() => ChatScreen(
                          peerId: convo.id,
                          peerName: convo.name,
                          peerAvatar: convo.profile,
                          isPeerOnline: convo.isOnline,
                        ));
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String searchTerm;
  const _EmptyState({required this.searchTerm});

  @override
  Widget build(BuildContext context) {
    final isSearching = searchTerm.trim().isNotEmpty;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF1F2937)),
              ),
              child: Icon(
                isSearching ? Icons.search_off : Icons.chat_bubble_outline,
                color: Colors.white24,
                size: 32.w,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              isSearching ? 'No results for "$searchTerm"' : 'No conversations yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6.h),
            Text(
              isSearching ? 'Try a different name' : 'Start a conversation from your team',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final dynamic convo;
  final String timeLabel;
  final VoidCallback onTap;

  const _ConversationTile({required this.convo, required this.timeLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ChatEndpoint.resolveImageUrl(convo.profile);
    final hasUnread = convo.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 54.w,
                  height: 54.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1F2937),
                    image: avatarUrl != null
                        ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: avatarUrl == null
                      ? Center(
                    child: Text(
                      (convo.name.isNotEmpty ? convo.name[0] : '?').toUpperCase(),
                      style: TextStyle(color: Colors.white70, fontSize: 20.sp, fontWeight: FontWeight.w600),
                    ),
                  )
                      : null,
                ),
                if (convo.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 13.w,
                      height: 13.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF050810), width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 14.w),

            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    convo.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5.sp,
                      fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    convo.lastMessage.isEmpty ? 'Say hello 👋' : convo.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasUnread ? Colors.white.withOpacity(0.85) : Colors.white.withOpacity(0.45),
                      fontSize: 13.5.sp,
                      fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),

            // Time + unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeLabel,
                  style: TextStyle(
                    color: hasUnread ? const Color(0xFF4D94FF) : Colors.white38,
                    fontSize: 11.5.sp,
                    fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                SizedBox(height: 8.h),
                if (hasUnread)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.5.w, vertical: 2.5.h),
                    constraints: BoxConstraints(minWidth: 20.w),
                    decoration: const BoxDecoration(color: Color(0xFF4D94FF), shape: BoxShape.circle),
                    child: Text(
                      '${convo.unreadCount}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700),
                    ),
                  )
                else
                  SizedBox(height: 20.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}