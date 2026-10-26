/// Model representing a Poll Option in a Community Post Poll
class PollOptionModel {
  final String id;
  final String text;
  final int voteCount;
  final double percentage;

  const PollOptionModel({
    required this.id,
    required this.text,
    this.voteCount = 0,
    this.percentage = 0.0,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'voteCount': voteCount,
      'percentage': percentage,
    };
  }
}

/// Model representing Poll Details and Results in a Community Post
class PollModel {
  final String pollId;
  final String question;
  final DateTime? expiresAt;
  final bool isExpired;
  final bool hasVoted;
  final String? votedOptionId;
  final int? totalVotes;
  final List<PollOptionModel> options;

  const PollModel({
    required this.pollId,
    required this.question,
    this.expiresAt,
    this.isExpired = false,
    this.hasVoted = false,
    this.votedOptionId,
    this.totalVotes,
    this.options = const [],
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    return PollModel(
      pollId: json['pollId'] as String? ?? json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      isExpired: json['isExpired'] as bool? ?? false,
      hasVoted: json['hasVoted'] as bool? ?? false,
      votedOptionId: json['votedOptionId'] as String?,
      totalVotes: (json['totalVotes'] as num?)?.toInt(),
      options: rawOptions
          .map((opt) => PollOptionModel.fromJson(opt as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pollId': pollId,
      'question': question,
      'expiresAt': expiresAt?.toIso8601String(),
      'isExpired': isExpired,
      'hasVoted': hasVoted,
      'votedOptionId': votedOptionId,
      'totalVotes': totalVotes,
      'options': options.map((opt) => opt.toJson()).toList(),
    };
  }
}
