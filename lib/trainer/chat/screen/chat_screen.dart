import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/endpoint/api_endpoint.dart';
import '../../core/local_storage/user_info.dart';
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
  final ImagePicker _picker = ImagePicker();

  // WhatsApp Dark Theme Colors
  static const Color waBgColor = Color(0xFF0B141B);
  static const Color waAppBarColor = Color(0xFF1F2C34);
  static const Color waSentBubble = Color(0xFF005C4B);
  static const Color waReceivedBubble = Color(0xFF1F2C34);
  static const Color waTealAccent = Color(0xFF00A884);
  static const Color waBlueTick = Color(0xFF53BDEB);
  static const Color waDatePillBg = Color(0xFF182229);
  static const Color waInputBg = Color(0xFF1F2C34);
  static const Color waTextMuted = Color(0xFF8696A0);

  String _currentUserId = '';
  String _peerRole = 'Trainer';

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    _currentUserId = (await UserInfo.getUserId() ?? '').trim();
    final myRole = await UserInfo.getUserRole();
    if (mounted) {
      setState(() {
        if (myRole == 'CLUB_ADMIN') {
          _peerRole = 'Trainer';
        } else if (myRole == 'TRAINER') {
          _peerRole = 'Club Admin';
        } else {
          _peerRole = 'Member';
        }
      });
    }

    await controller.openConversation(widget.peerId);

    // Refresh current user id if it was initialized later
    if (_currentUserId.isEmpty && controller.myId != null) {
      _currentUserId = controller.myId!.trim();
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.closeConversation();
    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _send([String? customText]) {
    final text = (customText ?? messageController.text).trim();
    if (text.isEmpty) return;

    controller.sendMessage(widget.peerId, text);

    if (customText == null) {
      messageController.clear();
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
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
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Determines if the message was sent by the logged in user (Right Side)
  /// or received from the other person (Left Side).
  bool _isMine(ChatMessageModel msg) {
    final peer = widget.peerId.trim();

    // 1. If senderId is explicitly the peer -> DEFINITELY PEER'S MESSAGE -> LEFT SIDE!
    if (msg.senderId.isNotEmpty && msg.senderId == peer) {
      return false;
    }

    // 2. If receiverId is explicitly ME -> DEFINITELY PEER'S MESSAGE -> LEFT SIDE!
    if (_currentUserId.isNotEmpty && msg.receiverId == _currentUserId) {
      return false;
    }

    // 3. If senderId is explicitly ME -> DEFINITELY MY MESSAGE -> RIGHT SIDE!
    if (_currentUserId.isNotEmpty && msg.senderId == _currentUserId) {
      return true;
    }

    // 4. If receiverId is explicitly the peer -> DEFINITELY MY MESSAGE -> RIGHT SIDE!
    if (msg.receiverId.isNotEmpty && msg.receiverId == peer) {
      return true;
    }

    // 5. Check with controller.myId
    final ctrlId = controller.myId?.trim();
    if (ctrlId != null && ctrlId.isNotEmpty) {
      if (msg.senderId == ctrlId) return true;
      if (msg.receiverId == ctrlId) return false;
    }

    // 6. Default fallback: if sender is NOT peer, it is mine (right side)
    return msg.senderId != peer;
  }

  void _pickAndSendImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file != null) {
        _send('📷 [Image: ${file.name}]');
      }
    } catch (e) {
      debugPrint('❌ Pick image error: $e');
    }
  }

  void _showAttachmentModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: waAppBarColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAttachmentTile(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              color: const Color(0xFFD3396D),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.camera);
              },
            ),
            _buildAttachmentTile(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              color: const Color(0xFFAC44CF),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 26.w,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 24.w),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(ChatMessageModel msg, bool isMine) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: waAppBarColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: Colors.white70),
              title: const Text('Copy text', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: msg.message));
                Get.snackbar(
                  'Copied',
                  'Message copied to clipboard',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: waAppBarColor,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
            ),
            if (isMine)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                title: const Text('Delete for me', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  controller.deleteMessageLocally(msg.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: waAppBarColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Clear Chat', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to clear messages from this screen?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.clearChatLocally();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = ChatEndpoint.resolveImageUrl(widget.peerAvatar);

    return Scaffold(
      backgroundColor: waBgColor,
      appBar: AppBar(
        backgroundColor: waAppBarColor,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 19.w,
                  backgroundColor: const Color(0xFF111B21),
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? Text(
                          (widget.peerName.isNotEmpty ? widget.peerName[0] : '?').toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                if (widget.isPeerOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366),
                        shape: BoxShape.circle,
                        border: Border.all(color: waAppBarColor, width: 2),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$_peerRole • ${widget.isPeerOnline ? "Online" : "Offline"}',
                    style: TextStyle(
                      color: widget.isPeerOnline ? waTealAccent : waTextMuted,
                      fontSize: 11.5.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            color: waAppBarColor,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            onSelected: (value) {
              if (value == 'clear') {
                _confirmClearChat();
              } else if (value == 'refresh') {
                controller.openConversation(widget.peerId);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Text('Refresh chat', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear chat', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Messages List ──────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMessages.value && controller.messages.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: waTealAccent),
                );
              }

              if (controller.messages.isEmpty) {
                return _buildEmptyState();
              }

              final msgs = controller.messages;
              final totalCount = msgs.length;

              // Reversed ListView: index 0 is at the bottom (newest message)
              return ListView.builder(
                controller: scrollController,
                reverse: true,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                itemCount: totalCount,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (context, index) {
                  // In a reversed list, calculate chronological index:
                  final chronologicalIndex = totalCount - 1 - index;
                  final msg = msgs[chronologicalIndex];
                  final isMine = _isMine(msg);

                  final showDateHeader = chronologicalIndex == 0 ||
                      !_isSameDay(
                        msgs[chronologicalIndex - 1].createdAt,
                        msg.createdAt,
                      );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showDateHeader)
                        _buildDateSeparator(_formatDateLabel(msg.createdAt)),
                      GestureDetector(
                        onLongPress: () => _showMessageOptions(msg, isMine),
                        child: _MessageBubble(
                          message: msg,
                          isMine: isMine,
                          bubbleColor: isMine ? waSentBubble : waReceivedBubble,
                          blueTickColor: waBlueTick,
                          formattedTime: _formatTime(msg.createdAt),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ),

          // ─── Input Bar (Pure Text & Send, NO audio/video call) ───────
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(String label) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: waDatePillBg,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: waTextMuted,
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final avatarUrl = ChatEndpoint.resolveImageUrl(widget.peerAvatar);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36.w,
              backgroundColor: waAppBarColor,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(
                      widget.peerName.isNotEmpty ? widget.peerName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            SizedBox(height: 12.h),
            Text(
              widget.peerName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'No previous messages. Start a conversation with this $_peerRole!',
              textAlign: TextAlign.center,
              style: TextStyle(color: waTextMuted, fontSize: 13.sp),
            ),
            SizedBox(height: 20.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickChip('👋 Hello!'),
                _buildQuickChip('Are you available for training?'),
                _buildQuickChip('Please check the update.'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String text) {
    return ActionChip(
      backgroundColor: waAppBarColor,
      side: const BorderSide(color: Color(0xFF2A3942)),
      label: Text(text, style: TextStyle(color: Colors.white, fontSize: 12.5.sp)),
      onPressed: () => _send(text),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 8.h),
        decoration: const BoxDecoration(
          color: waAppBarColor,
          border: Border(top: BorderSide(color: Color(0xFF2A3942), width: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text Field Container
            Expanded(
              child: Container(
                constraints: BoxConstraints(minHeight: 46.h, maxHeight: 120.h),
                decoration: BoxDecoration(
                  color: waInputBg,
                  borderRadius: BorderRadius.circular(23.r),
                  border: Border.all(color: const Color(0xFF2A3942)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file_rounded, color: waTextMuted, size: 22),
                      onPressed: _showAttachmentModal,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: TextField(
                          controller: messageController,
                          focusNode: focusNode,
                          style: TextStyle(color: Colors.white, fontSize: 15.sp),
                          minLines: 1,
                          maxLines: 5,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: waTextMuted, fontSize: 14.5.sp),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_rounded, color: waTextMuted, size: 22),
                      onPressed: () => _pickAndSendImage(ImageSource.camera),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // Pure Send Button (NO audio or video call)
            Obx(() => GestureDetector(
                  onTap: controller.isSending.value ? null : () => _send(),
                  child: Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: const BoxDecoration(
                      color: waTealAccent,
                      shape: BoxShape.circle,
                    ),
                    child: controller.isSending.value
                        ? Padding(
                            padding: EdgeInsets.all(13.w),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MESSAGE BUBBLE WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMine;
  final Color bubbleColor;
  final Color blueTickColor;
  final String formattedTime;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.bubbleColor,
    required this.blueTickColor,
    required this.formattedTime,
  });

  @override
  Widget build(BuildContext context) {
    const textMuted = Color(0xFF8696A0);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        // Sent by logged-in user: RIGHT SIDE (end)
        // Received from the other person: LEFT SIDE (start)
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 290.w,
              minWidth: 70.w,
            ),
            child: Container(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 6.h),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14.r),
                  topRight: Radius.circular(14.r),
                  bottomLeft: Radius.circular(isMine ? 14.r : 3.r),
                  bottomRight: Radius.circular(isMine ? 3.r : 14.r),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5.sp,
                      height: 1.32,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 10.5,
                        ),
                      ),
                      if (isMine) ...[
                        SizedBox(width: 4.w),
                        Icon(
                          message.isRead
                              ? Icons.done_all_rounded
                              : Icons.done_all_rounded,
                          size: 15.w,
                          color: message.isRead ? blueTickColor : textMuted,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
