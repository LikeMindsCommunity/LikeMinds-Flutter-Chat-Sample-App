import 'dart:convert';
import 'poll_option_model.dart';

class PollModel {
  final int id;
  final String question;
  final DateTime endDate;
  final List<PollOptionModel> options;

  PollModel({
    required this.id,
    required this.question,
    required this.endDate,
    required this.options,
  });

  PollModel copyWith({
    int? id,
    String? question,
    DateTime? endDate,
    List<PollOptionModel>? options,
  }) {
    return PollModel(
      id: id ?? this.id,
      question: question ?? this.question,
      endDate: endDate ?? this.endDate,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'endDate': endDate.millisecondsSinceEpoch,
      'options': options.map((x) => x.toMap()).toList(),
    };
  }

  factory PollModel.fromMap(Map<String, dynamic> map) {
    return PollModel(
      id: map['id']?.toInt() ?? 0,
      question: map['question'] ?? '',
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate']),
      options: List<PollOptionModel>.from(
          map['options']?.map((x) => PollOptionModel.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory PollModel.fromJson(String source) =>
      PollModel.fromMap(json.decode(source));
}
