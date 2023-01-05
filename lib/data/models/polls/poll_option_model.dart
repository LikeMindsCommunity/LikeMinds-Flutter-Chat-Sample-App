import 'dart:convert';

class PollOptionModel {
  final int id;
  final String title;
  final int votes;

  PollOptionModel({
    required this.id,
    required this.title,
    required this.votes,
  });

  PollOptionModel copyWith({
    int? id,
    String? title,
    int? votes,
  }) {
    return PollOptionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      votes: votes ?? this.votes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'votes': votes,
    };
  }

  factory PollOptionModel.fromMap(Map<String, dynamic> map) {
    return PollOptionModel(
      id: map['id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      votes: map['votes']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory PollOptionModel.fromJson(String source) =>
      PollOptionModel.fromMap(json.decode(source));

  @override
  String toString() => 'PollOptionModel(id: $id, title: $title, votes: $votes)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PollOptionModel &&
        other.id == id &&
        other.title == title &&
        other.votes == votes;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ votes.hashCode;
}
