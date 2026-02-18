class MindEdge {
  final String fromId;
  final String toId;

  MindEdge({
    required this.fromId,
    required this.toId,
  });

  Map<String, dynamic> toJson() => {
    'fromId': fromId,
    'toId': toId,
  };

  factory MindEdge.fromJson(Map<String, dynamic> json) => MindEdge(
    fromId: json['fromId'],
    toId: json['toId'],
  );
}
