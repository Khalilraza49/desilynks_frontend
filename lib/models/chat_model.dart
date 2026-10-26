// ignore_for_file: constant_identifier_names

import '../services/api/api_endpoints.dart';
import '../core/utils/chat_date_utils.dart';

Map<String, dynamic> _toMap(dynamic obj) {
  if (obj == null) return {};
  if (obj is Map<String, dynamic>) return obj;
  if (obj is Map) {
    final Map<String, dynamic> res = {};
    obj.forEach((key, value) {
      res[key.toString()] = value;
    });
    return res;
  }
  return {};
}

enum MessageStatus {
  SENT,
  DELIVERED,
  READ;

  static MessageStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'DELIVERED':
        return MessageStatus.DELIVERED;
      case 'READ':
        return MessageStatus.READ;
      case 'SENT':
      default:
        return MessageStatus.SENT;
    }
  }

  String toJson() => name;
}

enum DeleteScope {
  FOR_ME,
  FOR_EVERYONE;

  String toJson() => name;
}

class ChatParticipantModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePhotoUrl;

  ChatParticipantModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePhotoUrl,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'User' : name;
  }

  factory ChatParticipantModel.fromJson(Map<String, dynamic> rawJson) {
    final json = _toMap(rawJson);
    String? photo;
    final profilePhotoMap = _toMap(json['profilePhoto']);
    if (profilePhotoMap['url'] != null) {
      photo = profilePhotoMap['url'] as String?;
    } else if (json['avatarUrl'] is String) {
      photo = json['avatarUrl'] as String?;
    } else if (json['profilePhotoUrl'] is String) {
      photo = json['profilePhotoUrl'] as String?;
    }

    if (photo != null && photo.isNotEmpty && !photo.startsWith('http')) {
      final base = ApiEndpoints.baseUrl.endsWith('/')
          ? ApiEndpoints.baseUrl.substring(0, ApiEndpoints.baseUrl.length - 1)
          : ApiEndpoints.baseUrl;
      final path = photo.startsWith('/') ? photo : '/$photo';
      photo = '$base$path';
    }

    final idVal =
        json['id']?.toString() ??
        json['_id']?.toString() ??
        json['userId']?.toString() ??
        '';

    final firstNameVal =
        json['firstName']?.toString() ??
        json['name']?.toString() ??
        json['username']?.toString() ??
        '';

    return ChatParticipantModel(
      id: idVal,
      firstName: firstNameVal,
      lastName: json['lastName']?.toString() ?? '',
      profilePhotoUrl: photo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'profilePhoto': profilePhotoUrl != null ? {'url': profilePhotoUrl} : null,
    };
  }
}

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageStatus status;
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ChatParticipantModel? sender;
  final bool isMe;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.status = MessageStatus.SENT,
    this.isDeleted = false,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.sender,
    this.isMe = false,
  });

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> rawJson, {
    String? currentUserId,
  }) {
    final json = _toMap(rawJson);
    final idVal = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    final convMap = _toMap(json['conversation']);
    final convIdVal =
        json['conversationId']?.toString() ??
        (convMap['id']?.toString() ?? convMap['_id']?.toString()) ??
        json['conversation']?.toString() ??
        '';

    String senderIdVal = json['senderId']?.toString() ?? '';
    ChatParticipantModel? participant;
    final senderObj = json['sender'];
    if (senderObj != null && senderObj is Map) {
      final senderMap = _toMap(senderObj);
      if (senderMap.isNotEmpty) {
        participant = ChatParticipantModel.fromJson(senderMap);
        if (senderIdVal.isEmpty) {
          senderIdVal = participant.id;
        }
      }
    } else if (senderObj is String) {
      senderIdVal = senderObj;
    }

    bool isMeVal = false;
    if (json['isMe'] == true || json['isSender'] == true) {
      isMeVal = true;
    } else if (currentUserId != null && currentUserId.isNotEmpty) {
      isMeVal = (senderIdVal == currentUserId);
    }

    String contentVal = '';
    if (json['isDeleted'] == true) {
      contentVal = 'This message was deleted';
    } else {
      contentVal =
          json['content']?.toString() ??
          json['text']?.toString() ??
          json['message']?.toString() ??
          '';
    }

    DateTime parsedCreated;
    try {
      if (json['createdAt'] != null) {
        final dt = DateTime.tryParse(json['createdAt'].toString());
        parsedCreated = dt != null ? dt.toLocal() : DateTime.now();
      } else {
        parsedCreated = DateTime.now();
      }
    } catch (_) {
      parsedCreated = DateTime.now();
    }

    DateTime? parsedDeleted;
    if (json['deletedAt'] != null) {
      try {
        final dt = DateTime.tryParse(json['deletedAt'].toString());
        parsedDeleted = dt?.toLocal();
      } catch (_) {}
    }

    DateTime parsedUpdated;
    try {
      if (json['updatedAt'] != null) {
        final dt = DateTime.tryParse(json['updatedAt'].toString());
        parsedUpdated = dt != null ? dt.toLocal() : parsedCreated;
      } else {
        parsedUpdated = parsedCreated;
      }
    } catch (_) {
      parsedUpdated = parsedCreated;
    }

    return ChatMessageModel(
      id: idVal,
      conversationId: convIdVal,
      senderId: senderIdVal,
      content: contentVal,
      status: MessageStatus.fromString(json['status']?.toString()),
      isDeleted: json['isDeleted'] == true,
      deletedAt: parsedDeleted,
      createdAt: parsedCreated,
      updatedAt: parsedUpdated,
      sender: participant,
      isMe: isMeVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'status': status.toJson(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'sender': sender?.toJson(),
    };
  }

  ChatMessageModel copyWith({
    String? content,
    MessageStatus? status,
    bool? isDeleted,
    DateTime? deletedAt,
    bool? isMe,
  }) {
    return ChatMessageModel(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      content: content ?? this.content,
      status: status ?? this.status,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      sender: sender,
      isMe: isMe ?? this.isMe,
    );
  }

  bool get isOfferMessage =>
      content.toLowerCase().contains('sent an offer') ||
      content.toLowerCase().contains('offer of');
}

class ChatConversationModel {
  final String id;
  final ChatParticipantModel otherParticipant;
  final ChatMessageModel? lastMessage;
  final DateTime updatedAt;
  final DateTime createdAt;
  final int unreadCount;
  final bool isOnline;
  final bool isGroup;
  final bool isArchived;
  final List<ChatMessageModel> messages;

  ChatConversationModel({
    required this.id,
    required this.otherParticipant,
    this.lastMessage,
    required this.updatedAt,
    required this.createdAt,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isGroup = false,
    this.isArchived = false,
    this.messages = const [],
  });

  String get userName => otherParticipant.fullName;
  String get avatarUrl =>
      otherParticipant.profilePhotoUrl ??
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=0D8ABC&color=fff';

  String get formattedTime {
    if (lastMessage == null) return '';
    return ChatDateUtils.formatConversationTime(lastMessage!.createdAt);
  }

  factory ChatConversationModel.fromJson(
    Map<String, dynamic> rawJson, {
    String? currentUserId,
  }) {
    final json = _toMap(rawJson);

    ChatParticipantModel other;
    final otherParticipantMap = _toMap(json['otherParticipant']);
    final participantMap = _toMap(json['participant']);
    final userMap = _toMap(json['user']);

    if (otherParticipantMap.isNotEmpty) {
      other = ChatParticipantModel.fromJson(otherParticipantMap);
    } else if (participantMap.isNotEmpty) {
      other = ChatParticipantModel.fromJson(participantMap);
    } else if (userMap.isNotEmpty) {
      other = ChatParticipantModel.fromJson(userMap);
    } else if (json['participants'] is List &&
        (json['participants'] as List).isNotEmpty) {
      final list = json['participants'] as List;
      final otherRaw = list.firstWhere((p) {
        final pMap = _toMap(p);
        if (pMap.isNotEmpty) {
          final pId = pMap['id']?.toString() ?? pMap['_id']?.toString() ?? '';
          return currentUserId != null && currentUserId.isNotEmpty
              ? pId != currentUserId
              : true;
        }
        return true;
      }, orElse: () => list.first);
      final otherParsed = _toMap(otherRaw);
      other = otherParsed.isNotEmpty
          ? ChatParticipantModel.fromJson(otherParsed)
          : ChatParticipantModel(id: '', firstName: 'User', lastName: '');
    } else {
      other = ChatParticipantModel(
        id:
            json['otherUserId']?.toString() ??
            json['participantId']?.toString() ??
            '',
        firstName:
            json['userName']?.toString() ?? json['name']?.toString() ?? 'User',
        lastName: '',
        profilePhotoUrl: json['avatarUrl']?.toString(),
      );
    }

    ChatMessageModel? lastMsg;
    final lastMsgMap = _toMap(json['lastMessage']);
    if (lastMsgMap.isNotEmpty) {
      lastMsg = ChatMessageModel.fromJson(
        lastMsgMap,
        currentUserId: currentUserId,
      );
    }

    DateTime parseDt(dynamic val) {
      if (val != null) {
        final parsed = DateTime.tryParse(val.toString());
        if (parsed != null) return parsed.toLocal();
      }
      return DateTime.now();
    }

    final convId = json['id']?.toString() ?? json['_id']?.toString() ?? '';

    return ChatConversationModel(
      id: convId,
      otherParticipant: other,
      lastMessage: lastMsg,
      updatedAt: parseDt(json['updatedAt']),
      createdAt: parseDt(json['createdAt']),
      unreadCount: (json['unreadCount'] is num)
          ? (json['unreadCount'] as num).toInt()
          : 0,
      isOnline: json['isOnline'] == true,
      isGroup: json['isGroup'] == true,
      isArchived: json['isArchived'] == true,
      messages: (json['messages'] is List)
          ? (json['messages'] as List)
                .map(
                  (m) => ChatMessageModel.fromJson(
                    _toMap(m),
                    currentUserId: currentUserId,
                  ),
                )
                .toList()
          : [],
    );
  }

  ChatConversationModel copyWith({
    String? id,
    ChatMessageModel? lastMessage,
    int? unreadCount,
    bool? isOnline,
    bool? isArchived,
    List<ChatMessageModel>? messages,
    DateTime? updatedAt,
  }) {
    return ChatConversationModel(
      id: id ?? this.id,
      otherParticipant: otherParticipant,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
      isGroup: isGroup,
      isArchived: isArchived ?? this.isArchived,
      messages: messages ?? this.messages,
    );
  }
}
