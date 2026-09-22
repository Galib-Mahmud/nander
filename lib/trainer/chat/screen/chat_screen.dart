import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../controller/chat_controller.dart';
import '../controller/chat_models.dart';


class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String? peerAvatar;
  final bool isPeerOnline;

  const ChatScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    this.peerAvatar,
    this.isPeerOnline = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController controller = ChatController.to;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  static const bgColor = Color(0xFF050810);
  static const bubbleReceived = Color(0xFF111827);
  static const bubbleSent = Color(0xFF2A4D8F);
  static const borderColor = Color(0xFF1F2937);
  static const accent = Color(0xFF4D94FF);

  @override
  void initState() {
    super.initState();
    controller.openConversation(widget.peerId);
  }

  @override
  void dispose() {
    controller.closeConversation();
    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = messageController.text;
    if (text.trim().isEmpty) return;
    controller.sendMessage(widget.peerId, text);
    messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  String _formatDateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(msgDate).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ChatEndpoint.resolveImageUrl(widget.peerAvatar);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
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
                      (widget.peerName.isNotEmpty ? widget.peerName[0] : '?').toUpperCase(),
                      style: TextStyle(color: Colors.white70, fontSize: 15.sp, fontWeight: FontWeight.w600),
                    ),
                  )
                      : null,
                ),
                if (widget.isPeerOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 11.w,
                      height: 11.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                        border: Border.all(color: bgColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.peerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    widget.isPeerOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: widget.isPeerOnline ? const Color(0xFF4ADE80) : Colors.white38,
                      fontSize: 11.5.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMessages.value && controller.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: accent));
              }
              if (controller.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('👋', style: TextStyle(fontSize: 40.sp)),
                      SizedBox(height: 10.h),
                      Text(
                        'Say hello to ${widget.peerName}',
                        style: TextStyle(color: Colors.white38, fontSize: 14.sp),
                      ),
                    ],
                  ),
                );
              }

              _scrollToBottom();

              return ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isMine = msg.senderId == controller.myId;
                  final showDateLabel = index == 0 ||
                      !_isSameDay(controller.messages[index - 1].createdAt, msg.createdAt);
                  final isLastOfGroup = index == controller.messages.length - 1 ||
                      controller.messages[index + 1].senderId != msg.senderId;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showDateLabel) _DateSeparator(label: _formatDateLabel(msg.createdAt)),
                      _MessageBubble(
                        message: msg,
                        isMine: isMine,
                        showTime: isLastOfGroup,
                        timeLabel: _formatTime(msg.createdAt),
                      ),
                    ],
                  );
                },
              );
            }),
          ),

          // ─── Input bar ─────────────────────────────────────────
          SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
              decoration: const BoxDecoration(
                color: bgColor,
                border: Border(top: BorderSide(color: borderColor, width: 1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(minHeight: 46.h, maxHeight: 120.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(23.r),
                        border: Border.all(color: borderColor),
                      ),
                      child: TextField(
                        controller: messageController,
                        focusNode: focusNode,
                        style: TextStyle(color: Colors.white, fontSize: 14.5.sp),
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 14.sp),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Obx(() => GestureDetector(
                    onTap: controller.isSending.value ? null : _send,
                    child: Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: accent.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: controller.isSending.value
                          ? Padding(
                        padding: EdgeInsets.all(13.w),
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 21),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFF1F2937)),
          ),
          child: Text(
            label,
            style: TextStyle(color: Colors.white54, fontSize: 11.5.sp, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMine;
  final bool showTime;
  final String timeLabel;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.showTime,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? const Color(0xFF2A4D8F) : const Color(0xFF111827);
    final bubbleBorder = isMine ? const Color(0xFF3A5FA8) : const Color(0xFF1F2937);

    return Padding(
      padding: EdgeInsets.only(bottom: showTime ? 4.h : 2.h),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 280.w),
            child: Column(
              crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    border: Border.all(color: bubbleBorder),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(isMine ? 16.r : 4.r),
                      bottomRight: Radius.circular(isMine ? 4.r : 16.r),
                    ),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(color: Colors.white, fontSize: 14.5.sp, height: 1.35),
                  ),
                ),
                if (showTime) ...[
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeLabel,
                        style: TextStyle(color: Colors.white38, fontSize: 10.5.sp),
                      ),
                      if (isMine) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                          size: 13.w,
                          color: message.isRead ? const Color(0xFF4D94FF) : Colors.white38,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}