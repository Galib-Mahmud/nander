import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../core/endpoint/api_client.dart';
import '../../core/endpoint/api_endpoint.dart';
import '../../core/local_storage/user_info.dart';
import 'chat_models.dart';

class ChatController extends GetxController {
  static ChatController get to => Get.put(ChatController(), permanent: true);

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);
  io.Socket? _socket;
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
    await _ensureMyId();
    if (_myId == null || _myId!.isEmpty) {
      debugPrint('⚠️ Socket init deferred: myId not found yet.');
      return;
    }

    try {
      _socket?.dispose();

      _socket = io.io(
        ChatEndpoint.baseUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionAttempts(10)
            .build(),
      );

      _socket!.connect();

      _socket!.onConnect((_) {
        isSocketConnected.value = true;
        debugPrint('🟢 Socket connected! MyId: $_myId');
        if (_myId != null && _myId!.isNotEmpty) {
          _socket!.emit('userConnected', _myId);
          _socket!.emit('getMessage', _myId);
        }
      });

      _socket!.onDisconnect((_) {
        isSocketConnected.value = false;
        debugPrint('🔴 Socket disconnected');
      });

      void handleSocketData(dynamic data) {
        try {
          debugPrint('📩 Socket message received: $data');
          final payload = data is String ? jsonDecode(data) : data;
          if (payload is Map<String, dynamic>) {
            final incoming = ChatMessageModel.fromJson(payload);
            _handleIncomingMessage(incoming);
          } else if (payload is List) {
            for (final item in payload) {
              if (item is Map<String, dynamic>) {
                _handleIncomingMessage(ChatMessageModel.fromJson(item));
              }
            }
          }
        } catch (e) {
          debugPrint('❌ Parse incoming socket message error: $e');
        }
      }

      _socket!.on('getMessage', handleSocketData);
      _socket!.on('newMessage', handleSocketData);
      _socket!.on('message', handleSocketData);
      _socket!.on('receiveMessage', handleSocketData);

      _socket!.onConnectError((e) => debugPrint('❌ Socket connect error: $e'));
      _socket!.onError((e) => debugPrint('❌ Socket error: $e'));
    } catch (e) {
      debugPrint('❌ Socket initialization error: $e');
    }
  }

  Future<void> _ensureMyId() async {
    final freshId = await UserInfo.getUserId();
    if (freshId != null && freshId.trim().isNotEmpty) {
      final trimmed = freshId.trim();
      if (_myId != trimmed) {
        debugPrint('🔄 User ID updated from $_myId to $trimmed');
        _myId = trimmed;
      }
      return;
    }

    final token = await UserInfo.getAccessToken();
    if (token != null && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length >= 2) {
          final normalized = base64Url.normalize(parts[1]);
          final payload = utf8.decode(base64Url.decode(normalized));
          final map = jsonDecode(payload);
          if (map is Map<String, dynamic>) {
            final extracted = map['id']?.toString() ??
                map['_id']?.toString() ??
                map['userId']?.toString() ??
                map['user']?['id']?.toString() ??
                map['user']?['_id']?.toString();
            if (extracted != null && extracted.isNotEmpty) {
              _myId = extracted.trim();
              await UserInfo.setUser(
                id: _myId!,
                email: map['email']?.toString() ?? '',
                name: map['name']?.toString() ?? '',
                role: map['role']?.toString() ?? '',
              );
              debugPrint('🔑 Extracted and saved myId from JWT: $_myId');
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error decoding JWT for userId: $e');
      }
    }
  }

  void _handleIncomingMessage(ChatMessageModel incoming) {
    final belongsToOpenChat = activePeerId.value.isNotEmpty &&
        (incoming.senderId == activePeerId.value ||
            incoming.receiverId == activePeerId.value ||
            (incoming.senderId == _myId && incoming.receiverId == activePeerId.value));

    if (belongsToOpenChat) {
      final index = messages.indexWhere((m) =>
          (m.id.isNotEmpty && m.id == incoming.id) ||
          (m.senderId == incoming.senderId &&
              m.message == incoming.message &&
              m.createdAt.difference(incoming.createdAt).inSeconds.abs() < 5));

      if (index >= 0) {
        messages[index] = incoming;
      } else {
        messages.add(incoming);
      }
    }
    fetchConversations();
  }

  Future<void> reconnectSocket() async {
    _socket?.dispose();
    _socket = null;
    isSocketConnected.value = false;
    _myId = null;
    await _initSocket();
  }

  // ──────────────────────────────────────────────────────────────────
  // REST — CONVERSATIONS
  // ──────────────────────────────────────────────────────────────────
  Future<void> fetchConversations({String? search}) async {
    isLoadingConversations.value = true;
    try {
      final endpoint = (search != null && search.trim().isNotEmpty)
          ? '/chat/conversations?search=${Uri.encodeComponent(search.trim())}'
          : '/chat/conversations';

      final response = await _apiClient.get(endpoint, requiresAuth: true);
      final rawList = (response?['data'] as List?) ?? [];

      final list = <ConversationModel>[];
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          try {
            list.add(ConversationModel.fromJson(item));
          } catch (e) {
            debugPrint('⚠️ Error parsing single conversation: $e');
          }
        }
      }
      conversations.assignAll(list);
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

    await _ensureMyId();
    if (_socket == null || !isSocketConnected.value) {
      _initSocket();
    }

    try {
      final endpoint = '/chat/messages/$peerId';
      debugPrint('📡 Fetching messages from: ${ApiEndpoint.baseUrl}$endpoint');

      final response = await _apiClient.get(endpoint, requiresAuth: true);
      debugPrint('📩 Chat messages response: $response');

      final rawList = (response?['data'] as List?) ?? [];
      final list = <ChatMessageModel>[];

      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          try {
            list.add(ChatMessageModel.fromJson(item));
          } catch (e) {
            debugPrint('⚠️ Single message parse error: $e on $item');
          }
        }
      }

      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      messages.assignAll(list);
      debugPrint('✅ Loaded ${messages.length} messages successfully for peer $peerId');
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
    if (trimmed.isEmpty) return;

    await _ensureMyId();
    final senderId = _myId ?? '';

    isSending.value = true;
    try {
      final tempId = 'temp_${DateTime.now().microsecondsSinceEpoch}';
      final newMsg = ChatMessageModel(
        id: tempId,
        senderId: senderId,
        receiverId: receiverId,
        message: trimmed,
        isRead: false,
        createdAt: DateTime.now(),
      );

      // Optimistic local append so the sender sees it immediately on the right side
      messages.add(newMsg);

      final payload = {
        'senderId': senderId,
        'receiverId': receiverId,
        'message': trimmed,
      };

      debugPrint('📤 Sending message via socket: $payload');
      _socket?.emit('sendMessage', payload);
      _socket?.emit('newMessage', payload);
      _socket?.emit('message', payload);

      if (_socket == null || !isSocketConnected.value) {
        _socket?.connect();
      }
    } finally {
      isSending.value = false;
    }
  }

  void deleteMessageLocally(String messageId) {
    messages.removeWhere((m) => m.id == messageId);
  }

  void clearChatLocally() {
    messages.clear();
  }

  String? get myId => _myId;

  @override
  void onClose() {
    _socket?.dispose();
    super.onClose();
  }
}
