import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../../services/api/chat_service.dart';
import '../../services/chat_socket_service.dart';
import '../../services/local/storage_service.dart';
import '../../models/notification_model.dart';
import '../../services/awesome_notification_service.dart';

/// ChatViewModel manages state for both the Conversation List and Active Chat Detail.
/// Implements MVVM with real-time reactivity via WebSocket and REST APIs.
class ChatViewModel extends ChangeNotifier {
  final ChatApiService? _chatApiService;
  final ChatSocketService? _chatSocketService;
  final StorageService? _storageService;

  ChatViewModel({
    ChatApiService? chatApiService,
    ChatSocketService? chatSocketService,
    StorageService? storageService,
  }) : _chatApiService = chatApiService,
       _chatSocketService = chatSocketService,
       _storageService = storageService {
    _initSocketListeners();
    initSocket();
    fetchUnreadCount();
  }

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static bool isValidUuid(String? id) {
    if (id == null || id.isEmpty) return false;
    return _uuidRegex.hasMatch(id.trim());
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Conversation List State & Controllers
  // ──────────────────────────────────────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();
  bool _chatViewInitialized = false;

  void initChatView() {
    if (_chatViewInitialized) return;
    _chatViewInitialized = true;
    fetchConversations();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Active Chat Detail State & Controllers
  // ──────────────────────────────────────────────────────────────────────────
  final TextEditingController messageController = TextEditingController();
  final ScrollController chatScrollController = ScrollController();
  int _lastMessageCount = 0;
  bool _detailScrollInitialized = false;

  void initDetailView(ChatConversationModel conversation) {
    if (_activeConversationId != conversation.id) {
      enterConversation(conversation);
    }
    initDetailScroll();
    scrollToBottom(animated: false);
  }

  void initDetailScroll() {
    if (_detailScrollInitialized) return;
    _detailScrollInitialized = true;
    chatScrollController.addListener(_onDetailScroll);
  }

  void _onDetailScroll() {
    if (chatScrollController.hasClients &&
        chatScrollController.position.pixels <=
            chatScrollController.position.minScrollExtent + 40) {
      if (!_isLoadingMore && !_isLoadingMessages) {
        loadMoreActiveMessages();
      }
    }
  }

  void scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatScrollController.hasClients) {
        if (animated) {
          chatScrollController.animateTo(
            chatScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        } else {
          chatScrollController.jumpTo(
            chatScrollController.position.maxScrollExtent,
          );
        }
      }
    });
  }

  void checkAutoScroll(int currentCount) {
    if (currentCount != _lastMessageCount) {
      _lastMessageCount = currentCount;
      scrollToBottom();
    }
  }

  Future<void> handleSendMessage() async {
    final text = messageController.text;
    if (text.trim().isEmpty) return;
    messageController.clear();
    await sendActiveTextMessage(text);
    scrollToBottom();
  }

  String _selectedTab = 'All'; // 'All', 'Unread', 'Groups', 'Archived'
  String get selectedTab => _selectedTab;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMessages = false;
  bool get isLoadingMessages => _isLoadingMessages;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  int _totalUnreadCount = 0;
  int get totalUnreadCount => _totalUnreadCount;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ChatConversationModel> _conversations = [];

  // Messages per conversation (conversationId -> List of ChatMessageModel)
  final Map<String, List<ChatMessageModel>> _messagesMap = {};
  final Map<String, String?> _nextCursorMap = {};
  final Map<String, bool> _hasMoreMap = {};
  final Map<String, bool> _isTypingMap = {};
  final Set<String> _onlineUsers = {};
  Timer? _typingDebounceTimer;

  // In-App Notification Toast Popup State
  ChatMessageModel? _incomingNotificationMessage;
  ChatMessageModel? get incomingNotificationMessage =>
      _incomingNotificationMessage;

  // ──────────────────────────────────────────────────────────────────────────
  // Active Conversation State (for Chat Detail View)
  // ──────────────────────────────────────────────────────────────────────────
  String? _activeConversationId;
  String? _activeParticipantId;
  ChatConversationModel? _activeConversationInitial;

  String? get activeConversationId => _activeConversationId;
  String? get activeParticipantId => _activeParticipantId;

  /// Returns the current active conversation model with live updates
  ChatConversationModel? get activeConversation {
    if (_activeConversationId != null && _activeConversationId!.isNotEmpty) {
      final found = _conversations.firstWhere(
        (c) => c.id == _activeConversationId,
        orElse: () =>
            _activeConversationInitial ??
            ChatConversationModel(
              id: _activeConversationId!,
              otherParticipant: ChatParticipantModel(
                id: _activeParticipantId ?? '',
                firstName: '',
                lastName: '',
              ),
              updatedAt: DateTime.now(),
              createdAt: DateTime.now(),
            ),
      );
      return found;
    }
    if (_activeParticipantId != null && _activeParticipantId!.isNotEmpty) {
      final found = _conversations.firstWhere(
        (c) => c.otherParticipant.id == _activeParticipantId,
        orElse: () =>
            _activeConversationInitial ??
            ChatConversationModel(
              id: '',
              otherParticipant: ChatParticipantModel(
                id: _activeParticipantId!,
                firstName: '',
                lastName: '',
              ),
              updatedAt: DateTime.now(),
              createdAt: DateTime.now(),
            ),
      );
      return found;
    }
    return _activeConversationInitial;
  }

  /// Returns messages for the active conversation sorted chronologically
  List<ChatMessageModel> get activeMessages {
    final effectiveId = _activeConversationId ?? '';
    final participantId = _activeParticipantId ?? '';
    final raw = getMessagesForConversation(
      effectiveId,
      participantId: participantId,
    );
    final sorted = List<ChatMessageModel>.from(raw)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  /// Check if the active conversation participant is currently typing
  bool get isActiveUserTyping {
    if (_activeConversationId != null && _activeConversationId!.isNotEmpty) {
      if (_isTypingMap[_activeConversationId!] == true) return true;
    }
    if (_activeParticipantId != null && _activeParticipantId!.isNotEmpty) {
      if (_isTypingMap[_activeParticipantId!] == true) return true;
    }
    return false;
  }

  /// Check if the active conversation participant is currently online
  bool get isActiveUserOnline {
    final participantId =
        _activeParticipantId ?? activeConversation?.otherParticipant.id ?? '';
    if (participantId.isNotEmpty) {
      return isUserOnline(participantId) ||
          (activeConversation?.isOnline ?? false);
    }
    return activeConversation?.isOnline ?? false;
  }

  /// Check if the other participant of a specific conversation is online
  bool isRecipientOnlineForConversation(String conversationId) {
    if (conversationId.isNotEmpty) {
      for (final c in _conversations) {
        if (c.id == conversationId) {
          return c.isOnline || isUserOnline(c.otherParticipant.id);
        }
      }
    }
    return isActiveUserOnline;
  }

  /// Filtered conversations based on search and active tab
  List<ChatConversationModel> get conversations {
    final filtered = _conversations.where((chat) {
      // 1. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final matchesName = chat.userName.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final matchesMessage = (chat.lastMessage?.content ?? '')
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        if (!matchesName && !matchesMessage) return false;
      }

      // 2. Tab Filter
      if (_selectedTab == 'Unread') {
        return chat.unreadCount > 0;
      } else if (_selectedTab == 'Groups') {
        return chat.isGroup;
      } else if (_selectedTab == 'Archived') {
        return chat.isArchived;
      }
      return !chat.isArchived; // 'All' tab
    }).toList();

    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered;
  }

  String get _currentUserId {
    final user = _storageService?.getUser();
    return user?.id ?? '';
  }

  List<ChatMessageModel> getMessagesForConversation(
    String conversationId, {
    String? participantId,
  }) {
    if (conversationId.isNotEmpty &&
        (_messagesMap[conversationId]?.isNotEmpty ?? false)) {
      return _messagesMap[conversationId] ?? [];
    }
    if (participantId != null && participantId.isNotEmpty) {
      final conv = _conversations.firstWhere(
        (c) => c.otherParticipant.id == participantId,
        orElse: () => ChatConversationModel(
          id: '',
          otherParticipant: ChatParticipantModel(
            id: '',
            firstName: '',
            lastName: '',
          ),
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );
      if (conv.id.isNotEmpty && (_messagesMap[conv.id]?.isNotEmpty ?? false)) {
        return _messagesMap[conv.id] ?? [];
      }
    }
    if (_messagesMap['']?.isNotEmpty ?? false) {
      return _messagesMap[''] ?? [];
    }
    return _messagesMap[conversationId] ?? [];
  }

  bool hasMoreMessages(String conversationId) {
    return _hasMoreMap[conversationId] ?? false;
  }

  bool isUserTyping(String conversationId) {
    return _isTypingMap[conversationId] ?? false;
  }

  bool isUserOnline(String participantId) {
    return _onlineUsers.contains(participantId);
  }

  void clearIncomingNotification() {
    _incomingNotificationMessage = null;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // WebSocket Connection & Event Callbacks
  // ──────────────────────────────────────────────────────────────────────────
  void initSocket() {
    final token = _storageService?.getToken();
    if (token != null && token.isNotEmpty && _chatSocketService != null) {
      _chatSocketService.connect(token, currentUserId: _currentUserId);
    }
  }

  void _initSocketListeners() {
    if (_chatSocketService == null) return;

    _chatSocketService.onNewMessage = (message, conversationId) {
      developer.log(
        'Socket event handler [onNewMessage] for conv: $conversationId',
        name: 'ChatViewModel',
      );
      _handleIncomingMessage(message, conversationId);
    };

    _chatSocketService.onMessagesRead = (conversationId, readBy) {
      developer.log(
        'Socket event handler [onMessagesRead] for conv: $conversationId by $readBy',
        name: 'ChatViewModel',
      );
      _handleMessagesReadEvent(conversationId, readBy);
    };

    _chatSocketService.onUserTyping = (conversationId, userId) {
      if (userId != _currentUserId) {
        if (conversationId.isNotEmpty) _isTypingMap[conversationId] = true;
        if (userId.isNotEmpty) {
          _isTypingMap[userId] = true;
          _onlineUsers.add(userId);
          _updateConversationOnlineStatus(userId, true);
        }
        notifyListeners();
      }
    };

    _chatSocketService.onUserStopTyping = (conversationId, userId) {
      if (userId != _currentUserId) {
        if (conversationId.isNotEmpty) _isTypingMap[conversationId] = false;
        if (userId.isNotEmpty) _isTypingMap[userId] = false;
        notifyListeners();
      }
    };

    _chatSocketService.onMessageDeleted = (messageId, conversationId) {
      _handleMessageDeletedEvent(messageId, conversationId);
    };

    _chatSocketService.onUserOnline = (userId) {
      developer.log(
        'Socket event handler [onUserOnline] userId: $userId',
        name: 'ChatViewModel',
      );
      _onlineUsers.add(userId);
      _updateConversationOnlineStatus(userId, true);
    };

    _chatSocketService.onUserOffline = (userId) {
      developer.log(
        'Socket event handler [onUserOffline] userId: $userId',
        name: 'ChatViewModel',
      );
      _onlineUsers.remove(userId);
      _updateConversationOnlineStatus(userId, false);
    };

    _chatSocketService.onError = (errorMsg) {
      _errorMessage = errorMsg;
      notifyListeners();
    };
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Active Conversation Lifecycle (Detail Screen)
  // ──────────────────────────────────────────────────────────────────────────

  /// Called when user opens a chat screen
  Future<void> enterConversation(ChatConversationModel conversation) async {
    _activeConversationInitial = conversation;
    _activeParticipantId = conversation.otherParticipant.id.isNotEmpty
        ? conversation.otherParticipant.id
        : null;

    final initialId = conversation.id.trim();
    if (isValidUuid(initialId)) {
      _activeConversationId = initialId;
    } else {
      _activeConversationId = null;
    }

    initSocket();
    notifyListeners();

    // Fetch latest conversations to get up-to-date IDs
    await fetchConversations();

    // Try finding an existing conversation if initialId was not a valid UUID
    String? convId = _activeConversationId;
    if (convId == null && _activeParticipantId != null) {
      final existing = _conversations.firstWhere(
        (c) => c.otherParticipant.id == _activeParticipantId,
        orElse: () => ChatConversationModel(
          id: '',
          otherParticipant: ChatParticipantModel(
            id: '',
            firstName: '',
            lastName: '',
          ),
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );
      if (isValidUuid(existing.id)) {
        convId = existing.id;
        _activeConversationId = convId;
      }
    }

    if (convId != null && isValidUuid(convId)) {
      await fetchMessages(convId);
      await markAsRead(convId);
    }
  }

  /// Called when user leaves the chat screen
  void leaveConversation() {
    if (_activeConversationId != null && _activeParticipantId != null) {
      sendStopTyping(_activeConversationId!, _activeParticipantId!);
    }
    _activeConversationId = null;
    _activeParticipantId = null;
    _activeConversationInitial = null;
    _typingDebounceTimer?.cancel();
    messageController.clear();
    _lastMessageCount = 0;
    notifyListeners();
  }

  /// Alias for leaveConversation
  void clearActiveConversation() {
    leaveConversation();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // REST & SOCKET API ACTIONS
  // ──────────────────────────────────────────────────────────────────────────

  /// Fetch all conversations from REST API
  Future<void> fetchConversations() async {
    final token = _storageService?.getToken();
    if (token == null || token.isEmpty) {
      _conversations = [];
      _isLoading = false;
      notifyListeners();
      return;
    }
    initSocket();
    if (_chatApiService == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await _chatApiService.getConversations(
        currentUserId: _currentUserId,
      );
      _conversations = list;

      // Seed online users from API response
      for (final conv in list) {
        if (conv.isOnline && conv.otherParticipant.id.isNotEmpty) {
          _onlineUsers.add(conv.otherParticipant.id);
        }
      }

      await fetchUnreadCount();
    } catch (e) {
      developer.log(
        'Error fetching conversations: $e',
        name: 'ChatViewModel',
        error: e,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch paginated messages for a conversation
  Future<void> fetchMessages(
    String conversationId, {
    bool loadMore = false,
  }) async {
    if (_chatApiService == null || !isValidUuid(conversationId)) return;

    if (loadMore) {
      if (!(_hasMoreMap[conversationId] ?? false)) return;
      _isLoadingMore = true;
    } else {
      _isLoadingMessages = true;
    }
    notifyListeners();

    try {
      final cursor = loadMore ? _nextCursorMap[conversationId] : null;
      final response = await _chatApiService.getMessages(
        conversationId,
        cursor: cursor,
        limit: 30,
        currentUserId: _currentUserId,
      );

      final currentMsgs = _messagesMap[conversationId] ?? [];
      if (loadMore) {
        // Prepend older messages cleanly without duplicates
        final existingIds = currentMsgs.map((m) => m.id).toSet();
        final newFiltered = response.messages
            .where((m) => !existingIds.contains(m.id))
            .toList();
        _messagesMap[conversationId] = [...newFiltered, ...currentMsgs];
      } else {
        if (response.messages.isNotEmpty) {
          // Merge local pending messages with fetched messages
          final fetchedIds = response.messages.map((m) => m.id).toSet();
          final pendingLocal = currentMsgs
              .where(
                (m) => m.id.startsWith('local_') && !fetchedIds.contains(m.id),
              )
              .toList();
          _messagesMap[conversationId] = [
            ...response.messages,
            ...pendingLocal,
          ];
        } else if (currentMsgs.isEmpty) {
          _messagesMap[conversationId] = [];
        }
      }

      _hasMoreMap[conversationId] = response.hasMore;
      _nextCursorMap[conversationId] = response.nextCursor;
    } catch (e) {
      developer.log(
        'Error fetching messages: $e',
        name: 'ChatViewModel',
        error: e,
      );
    } finally {
      _isLoadingMessages = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load more older messages for the currently active conversation
  Future<void> loadMoreActiveMessages() async {
    final effId = _activeConversationId ?? activeConversation?.id ?? '';
    if (effId.isNotEmpty && hasMoreMessages(effId) && !_isLoadingMore) {
      await fetchMessages(effId, loadMore: true);
    }
  }

  /// Send Text Message for active or specified conversation
  Future<void> sendMessage(
    String conversationId,
    String receiverId,
    String text,
  ) async {
    if (text.trim().isEmpty) return;
    final trimmedText = text.trim();

    String targetConvId = isValidUuid(conversationId) ? conversationId : '';
    if (targetConvId.isEmpty && receiverId.isNotEmpty) {
      final existing = _conversations.firstWhere(
        (c) => c.otherParticipant.id == receiverId,
        orElse: () => ChatConversationModel(
          id: '',
          otherParticipant: ChatParticipantModel(
            id: '',
            firstName: '',
            lastName: '',
          ),
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );
      if (isValidUuid(existing.id)) {
        targetConvId = existing.id;
        _activeConversationId = targetConvId;
      }
    }

    final eff = activeConversation;
    final otherId = receiverId.isNotEmpty
        ? receiverId
        : (_activeParticipantId ?? eff?.otherParticipant.id ?? '');
    final bool isRecipientOnline = isUserOnline(otherId) ||
        (eff?.isOnline ?? false) ||
        isActiveUserOnline;

    final initialStatus = isRecipientOnline
        ? MessageStatus.DELIVERED
        : MessageStatus.SENT;

    final tempId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final localMsg = ChatMessageModel(
      id: tempId,
      conversationId: targetConvId,
      senderId: _currentUserId.isNotEmpty ? _currentUserId : 'me',
      content: trimmedText,
      status: initialStatus,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isMe: true,
    );
    _addMessageToConversation(targetConvId, localMsg);

    // Stop typing state
    if (targetConvId.isNotEmpty && receiverId.isNotEmpty) {
      sendStopTyping(targetConvId, receiverId);
    }

    // 1. WebSocket emit
    if (_chatSocketService != null && _chatSocketService.isConnected) {
      final sentMsg = await _chatSocketService.sendMessage(
        receiverId,
        trimmedText,
        currentUserId: _currentUserId,
      );
      if (sentMsg != null) {
        final finalConvId = sentMsg.conversationId.isNotEmpty
            ? sentMsg.conversationId
            : targetConvId;
        if (_activeConversationId == null || _activeConversationId!.isEmpty) {
          _activeConversationId = finalConvId;
        }
        final finalStatus = isRecipientOnline
            ? MessageStatus.DELIVERED
            : MessageStatus.SENT;
        final confirmedMsg = sentMsg.copyWith(
          status: finalStatus,
          isMe: true,
        );
        _addMessageToConversation(finalConvId, confirmedMsg);
        return;
      }
    }
  }

  /// High-level method to send a text message in active conversation
  Future<void> sendActiveTextMessage(String text) async {
    final eff = activeConversation;
    final convId = _activeConversationId ?? eff?.id ?? '';
    final receiverId = _activeParticipantId ?? eff?.otherParticipant.id ?? '';
    if (receiverId.isEmpty && convId.isEmpty) return;

    await sendMessage(convId, receiverId, text);
  }


  /// Accept Offer Action
  Future<void> acceptOffer(ChatMessageModel offerMessage) async {
    await sendActiveTextMessage("Offer Accepted");
  }

  /// Reject Offer Action
  Future<void> rejectOffer(ChatMessageModel offerMessage) async {
    await sendActiveTextMessage("Offer Rejected");
  }

  /// Mark Conversation as Read
  Future<void> markAsRead(String conversationId) async {
    if (!isValidUuid(conversationId)) return;

    // 1. Emit via socket
    _chatSocketService?.markAsRead(conversationId);

    // 2. Call REST endpoint
    if (_chatApiService != null) {
      try {
        await _chatApiService.markAsReadRest(conversationId);
      } catch (_) {}
    }

    // 3. Local State Update
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      final currentUnread = _conversations[idx].unreadCount;
      _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);
      _totalUnreadCount = (_totalUnreadCount - currentUnread).clamp(0, 999);
      notifyListeners();
    }
  }

  /// Handle typing debounce when user types in message input
  void onInputTextChanged(String text) {
    final eff = activeConversation;
    final convId = _activeConversationId ?? eff?.id ?? '';
    final receiverId = _activeParticipantId ?? eff?.otherParticipant.id ?? '';
    if (convId.isEmpty && receiverId.isEmpty) return;

    if (text.trim().isNotEmpty) {
      sendTyping(convId, receiverId);
    } else {
      sendStopTyping(convId, receiverId);
    }
  }

  /// Emit Typing Status
  void sendTyping(String conversationId, String receiverId) {
    _chatSocketService?.emitTyping(conversationId, receiverId);

    _typingDebounceTimer?.cancel();
    _typingDebounceTimer = Timer(const Duration(seconds: 3), () {
      sendStopTyping(conversationId, receiverId);
    });
  }

  /// Emit Stop Typing Status
  void sendStopTyping(String conversationId, String receiverId) {
    _typingDebounceTimer?.cancel();
    _chatSocketService?.emitStopTyping(conversationId, receiverId);
  }

  /// Delete Specific Message (FOR_ME or FOR_EVERYONE) with instantaneous optimistic update
  Future<bool> deleteMessage(
    String conversationId,
    String messageId,
    DeleteScope scope,
  ) async {
    // 1. Instant optimistic local mutation across ALL cached message lists
    for (final key in _messagesMap.keys) {
      final msgs = _messagesMap[key];
      if (msgs != null) {
        if (scope == DeleteScope.FOR_EVERYONE) {
          _messagesMap[key] = msgs.map((m) {
            if (m.id == messageId) {
              return m.copyWith(
                content: 'This message was deleted',
                isDeleted: true,
                deletedAt: DateTime.now(),
              );
            }
            return m;
          }).toList();
        } else {
          // FOR_ME: remove from local list
          _messagesMap[key] = msgs.where((m) => m.id != messageId).toList();
        }
      }
    }

    // 2. Update lastMessage preview in conversations list if matching
    for (int i = 0; i < _conversations.length; i++) {
      if (_conversations[i].lastMessage?.id == messageId) {
        if (scope == DeleteScope.FOR_EVERYONE) {
          _conversations[i] = _conversations[i].copyWith(
            lastMessage: _conversations[i].lastMessage!.copyWith(
              content: 'This message was deleted',
              isDeleted: true,
              deletedAt: DateTime.now(),
            ),
          );
        } else {
          final convMsgs = _messagesMap[_conversations[i].id] ?? [];
          final last = convMsgs.isNotEmpty ? convMsgs.last : null;
          _conversations[i] = _conversations[i].copyWith(lastMessage: last);
        }
      }
    }
    notifyListeners();

    // 3. Emit via WebSocket with timeout safety
    bool success = false;
    if (_chatSocketService != null && _chatSocketService.isConnected) {
      try {
        success = await _chatSocketService.deleteMessage(messageId, scope);
      } catch (_) {
        success = true;
      }
    } else {
      success = true;
    }

    return success;
  }

  /// Soft Delete Conversation
  Future<bool> deleteConversation(String conversationId) async {
    bool success = true;
    if (_chatApiService != null) {
      try {
        success = await _chatApiService.deleteConversation(conversationId);
      } catch (e) {
        developer.log(
          'Error deleting conversation: $e',
          name: 'ChatViewModel',
          error: e,
        );
        success = true; // allow local remove
      }
    }

    if (success) {
      _conversations.removeWhere((c) => c.id == conversationId);
      _messagesMap.remove(conversationId);
      notifyListeners();
    }
    return success;
  }

  /// Fetch total unread count
  Future<void> fetchUnreadCount() async {
    final token = _storageService?.getToken();
    if (token == null || token.isEmpty) {
      _totalUnreadCount = 0;
      notifyListeners();
      return;
    }
    if (_chatApiService != null) {
      final count = await _chatApiService.getUnreadCount();
      _totalUnreadCount = count;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helper & Internal Sync Methods
  // ──────────────────────────────────────────────────────────────────────────

  void _addMessageToConversation(
    String conversationId,
    ChatMessageModel message,
  ) {
    final targetId = message.conversationId.isNotEmpty
        ? message.conversationId
        : conversationId;

    final keysToUpdate = <String>{
      if (targetId.isNotEmpty) targetId,
      if (conversationId.isNotEmpty) conversationId,
    };

    if (keysToUpdate.isEmpty) {
      keysToUpdate.add('');
    }

    for (final key in keysToUpdate) {
      final list = List<ChatMessageModel>.from(_messagesMap[key] ?? []);
      final existingIdx = list.indexWhere(
        (m) =>
            (m.id.isNotEmpty && m.id == message.id) ||
            (message.id.startsWith('local_') &&
                m.content == message.content &&
                m.isMe) ||
            (!message.id.startsWith('local_') &&
                m.id.startsWith('local_') &&
                m.content == message.content &&
                m.isMe),
      );
      if (existingIdx != -1) {
        list[existingIdx] = message;
      } else {
        list.add(message);
      }
      _messagesMap[key] = list;
    }

    if (targetId.isNotEmpty &&
        _messagesMap.containsKey('') &&
        (_messagesMap['']?.isNotEmpty ?? false)) {
      final orphanList = _messagesMap['']!;
      final currentTargetList = List<ChatMessageModel>.from(
        _messagesMap[targetId] ?? [],
      );
      for (final orphan in orphanList) {
        if (!currentTargetList.any(
          (m) => m.id == orphan.id || (m.content == orphan.content && m.isMe),
        )) {
          currentTargetList.add(orphan);
        }
      }
      _messagesMap[targetId] = currentTargetList;
    }

    final idx = _conversations.indexWhere(
      (c) =>
          (targetId.isNotEmpty && c.id == targetId) ||
          (conversationId.isNotEmpty && c.id == conversationId) ||
          (message.senderId.isNotEmpty &&
              c.otherParticipant.id == message.senderId),
    );

    if (idx != -1) {
      final chat = _conversations.removeAt(idx);
      final updatedChat = chat.copyWith(
        id: targetId.isNotEmpty ? targetId : chat.id,
        lastMessage: message,
        updatedAt: message.createdAt,
      );
      _conversations.insert(0, updatedChat);
    } else if (targetId.isNotEmpty && message.sender != null) {
      _conversations.insert(
        0,
        ChatConversationModel(
          id: targetId,
          otherParticipant: message.sender!,
          lastMessage: message,
          updatedAt: message.createdAt,
          createdAt: message.createdAt,
        ),
      );
    }
    notifyListeners();
  }

  void _handleIncomingMessage(ChatMessageModel message, String conversationId) {
    _addMessageToConversation(conversationId, message);

    final effId = message.conversationId.isNotEmpty
        ? message.conversationId
        : conversationId;
    final isCurrentActive =
        (_activeConversationId != null && _activeConversationId == effId) ||
        (_activeParticipantId != null &&
            _activeParticipantId == message.senderId);

    // Mark sender as online since they just sent a message
    if (message.senderId.isNotEmpty) {
      _onlineUsers.add(message.senderId);
      _updateConversationOnlineStatus(message.senderId, true);
    }

    if (isCurrentActive) {
      // User is currently viewing this conversation -> automatically mark as read
      markAsRead(effId);
    } else {
      final idx = _conversations.indexWhere(
        (c) =>
            (effId.isNotEmpty && c.id == effId) ||
            (message.senderId.isNotEmpty &&
                c.otherParticipant.id == message.senderId),
      );
      if (!message.isMe) {
        if (idx != -1) {
          final currentUnread = _conversations[idx].unreadCount;
          _conversations[idx] = _conversations[idx].copyWith(
            unreadCount: currentUnread + 1,
          );
        }
        _totalUnreadCount += 1;
        fetchUnreadCount().catchError((_) {});
      }
      // Trigger in-app notification popup if outside this detail screen
      if (!message.isMe) {
        _incomingNotificationMessage = message;
        // Trigger OS notification banner with sound and vibration
        final sender = message.sender;
        final senderName = (sender != null && sender.fullName.trim().isNotEmpty)
            ? sender.fullName.trim()
            : 'New Message';
        final notif = NotificationModel(
          id: message.id,
          type: NotificationType.chatMessage,
          title: senderName,
          body: message.content.isNotEmpty ? message.content : 'Sent an attachment',
          createdAt: message.createdAt,
          isRead: false,
          actorId: message.senderId,
          actor: sender,
          data: {
            'conversationId': effId,
            'chatId': effId,
          },
        );
        AwesomeNotificationService.instance.showNotification(notif);
      }
      notifyListeners();
    }
  }

  void _handleMessagesReadEvent(String conversationId, String readBy) {
    for (final key in _messagesMap.keys) {
      final list = _messagesMap[key];
      if (list != null) {
        _messagesMap[key] = list.map((m) {
          if (m.isMe) {
            return m.copyWith(status: MessageStatus.READ);
          }
          return m;
        }).toList();
      }
    }
    if (readBy.isNotEmpty) {
      _onlineUsers.add(readBy);
      _updateConversationOnlineStatus(readBy, true);
    }
    fetchUnreadCount().catchError((_) {});
    notifyListeners();
  }

  void _handleMessageDeletedEvent(String messageId, String conversationId) {
    for (final key in _messagesMap.keys) {
      final list = _messagesMap[key];
      if (list != null) {
        _messagesMap[key] = list.map((m) {
          if (m.id == messageId) {
            return m.copyWith(
              content: 'This message was deleted',
              isDeleted: true,
              deletedAt: DateTime.now(),
            );
          }
          return m;
        }).toList();
      }
    }
    for (int i = 0; i < _conversations.length; i++) {
      if (_conversations[i].lastMessage?.id == messageId) {
        _conversations[i] = _conversations[i].copyWith(
          lastMessage: _conversations[i].lastMessage!.copyWith(
            content: 'This message was deleted',
            isDeleted: true,
            deletedAt: DateTime.now(),
          ),
        );
      }
    }
    notifyListeners();
  }

  void setSelectedTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void refreshChats() {
    fetchConversations();
  }

  void _updateConversationOnlineStatus(String userId, bool isOnline) {
    bool changed = false;
    for (int i = 0; i < _conversations.length; i++) {
      if (_conversations[i].otherParticipant.id == userId) {
        _conversations[i] = _conversations[i].copyWith(isOnline: isOnline);
        changed = true;
      }
    }
    if (isOnline) {
      for (final key in _messagesMap.keys) {
        final list = _messagesMap[key];
        if (list != null) {
          _messagesMap[key] = list.map((m) {
            if (m.isMe && m.status == MessageStatus.SENT) {
              changed = true;
              return m.copyWith(status: MessageStatus.DELIVERED);
            }
            return m;
          }).toList();
        }
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    messageController.dispose();
    chatScrollController.dispose();
    _typingDebounceTimer?.cancel();
    super.dispose();
  }
}
