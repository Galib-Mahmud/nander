import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;


import '../../core/endpoint/api_endpoint.dart';
import '../../core/local_storage/user_info.dart';
import 'chat_models.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.put(ChatController(), permanent: true);

  IO.Socket? _socket;
  String? _myId;

  final RxBool isSocketConnected = false.obs;

  // ─── Conversations list ────────────────────────────────────────
  final RxList<ConversationModel> conversations = <ConversationModel>[].obs;
  final RxBool isLoadingConversations = false.obs;

  // ─── Active conversation ────────────────────────────────────────
  final RxString activePeerId = ''.obs;
  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initSocket();
  }

  // ──────────────────────────────────────────────────────────────────
  // SOCKET SETUP
  // ──────────────────────────────────────────────────────────────────
  Future<void> _initSocket() async {
    _myId = await UserInfo.getUserId();
    if (_myId == null || _myId!.isEmpty) return; // not logged in yet

    _socket = IO.io(
      ChatEndpoint.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      isSocketConnected.value = true;
      // Register this user as online + subscribe to their incoming messages
      _socket!.emit('userConnected', _myId);
      _socket!.emit('getMessage', _myId);
    });

    _socket!.onDisconnect((_) => isSocketConnected.value = false);

    // Incoming live message pushed by the server
    _socket!.on('getMessage', (data) {
      try {
        final payload = data is String ? jsonDecode(data) : data;
        if (payload is Map<String, dynamic>) {
          final incoming = ChatMessageModel.fromJson(payload);
          _handleIncomingMessage(incoming);
        }
      } catch (e) {
        debugPrint('❌ Parse incoming message error: $e');
      }
    });

    _socket!.onConnectError((e) => debugPrint('❌ Socket connect error: $e'));
    _socket!.onError((e) => debugPrint('❌ Socket error: $e'));
  }

  void _handleIncomingMessage(ChatMessageModel incoming) {
    final belongsToOpenChat = activePeerId.value.isNotEmpty &&
        (incoming.senderId == activePeerId.value || incoming.receiverId == activePeerId.value);

    if (belongsToOpenChat) {
      messages.add(incoming);
    }
    // Keep the conversation list preview/order fresh either way
    fetchConversations();
  }

  /// Call this again after login/logout since the user id may have changed.
  Future<void> reconnectSocket() async {
    _socket?.dispose();
    isSocketConnected.value = false;
    await _initSocket();
  }

  // ──────────────────────────────────────────────────────────────────
  // REST — CONVERSATIONS
  // ──────────────────────────────────────────────────────────────────
  Future<void> fetchConversations({String? search}) async {
    isLoadingConversations.value = true;
    try {
      final token = await UserInfo.getAccessToken();
      final uri = Uri.parse(ChatEndpoint.conversations).replace(
        queryParameters: (search != null && search.trim().isNotEmpty) ? {'search': search.trim()} : null,
      );
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final list = (decoded['data'] as List? ?? [])
            .map((e) => ConversationModel.fromJson(e))
            .toList();
        conversations.assignAll(list);
      } else {
        debugPrint('❌ Fetch conversations failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Fetch conversations error: $e');
    } finally {
      isLoadingConversations.value = false;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // REST — MESSAGE HISTORY
  // ──────────────────────────────────────────────────────────────────
  Future<void> openConversation(String peerId) async {
    activePeerId.value = peerId;
    messages.clear();
    isLoadingMessages.value = true;
    try {
      final token = await UserInfo.getAccessToken();
      final response = await http.get(
        Uri.parse(ChatEndpoint.messages(peerId)),
        headers: {
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final list = (decoded['data'] as List? ?? [])
            .map((e) => ChatMessageModel.fromJson(e))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        messages.assignAll(list);
      } else {
        debugPrint('❌ Fetch messages failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Fetch messages error: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  void closeConversation() {
    activePeerId.value = '';
    messages.clear();
  }

  // ──────────────────────────────────────────────────────────────────
  // SOCKET — SEND MESSAGE
  // ──────────────────────────────────────────────────────────────────
  Future<void> sendMessage(String receiverId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _myId == null) return;

    isSending.value = true;
    try {
      _socket?.emit('sendMessage', {
        'senderId'  : _myId,
        'receiverId': receiverId,
        'message'   : trimmed,
      });

      // Optimistic local append so the sender sees it instantly
      messages.add(ChatMessageModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        senderId: _myId!,
        receiverId: receiverId,
        message: trimmed,
        isRead: false,
        createdAt: DateTime.now(),
      ));
    } finally {
      isSending.value = false;
    }
  }

  String? get myId => _myId;

  @override
  void onClose() {
    _socket?.dispose();
    super.onClose();
  }
}