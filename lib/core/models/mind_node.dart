import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

enum MindNodeShape {
  roundedRect,
  circle,
  pill,
}

class MindNode {
  final String id;
  Offset position;
  Color color;
  Size size;
  MindNodeShape shape;
  int level;
  
  final ValueNotifier<bool> isEditingNotifier;
  
  String? emoji;
  final QuillController textController;

  MindNode({
    required this.id,
    required this.position,
    required this.color,
    this.size = const Size(120, 48),
    this.shape = MindNodeShape.pill,
    this.level = 1,
    bool isEditing = false,
    QuillController? textController,
  })  : textController = textController ?? QuillController.basic(),
        isEditingNotifier = ValueNotifier<bool>(isEditing);

  bool get isEditing => isEditingNotifier.value;
  set isEditing(bool value) => isEditingNotifier.value = value;

  Offset get center => position + Offset(size.width / 2, size.height / 2);

  MindNode copyWith({
    Offset? position,
    Color? color,
    Size? size,
    MindNodeShape? shape,
    int? level,
    bool? isEditing,
    String? emoji,
  }) {
    return MindNode(
      id: id,
      position: position ?? this.position,
      color: color ?? this.color,
      size: size ?? this.size,
      shape: shape ?? this.shape,
      level: level ?? this.level,
      isEditing: isEditing ?? this.isEditing,
      textController: textController,
    );
  }

  Offset connectionPointToward(Offset target) {
    final c = center;
    final dx = target.dx - c.dx;
    final dy = target.dy - c.dy;

    final halfW = size.width / 2;
    final halfH = size.height / 2;

    if (dx == 0 && dy == 0) return c;

    final scaleX = halfW / dx.abs();
    final scaleY = halfH / dy.abs();
    final scale = scaleX < scaleY ? scaleX : scaleY;

    return Offset(c.dx + dx * scale, c.dy + dy * scale);
  }

  String get text => textController.document.toPlainText();

  void dispose() {
    textController.dispose();
    isEditingNotifier.dispose();
  }





  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': {'dx': position.dx, 'dy': position.dy},
      'color': color.toARGB32(),
      'size': {'width': size.width, 'height': size.height},
      'shape': shape.index, // Guardamos el índice del enum
      'level': level,
      'emoji': emoji,
      // Guardamos el contenido de Quill como una lista de operaciones (JSON)
      'text': textController.document.toDelta().toJson(),
    };
  }

  factory MindNode.fromJson(Map<String, dynamic> json) {
    final node = MindNode(
      id: json['id'],
      position: Offset(json['position']['dx'], json['position']['dy']),
      color: Color(json['color']),
      size: Size(json['size']['width'], json['size']['height']),
      shape: MindNodeShape.values[json['shape'] ?? 0],
      level: json['level'] ?? 1,
      textController: QuillController(
        document: Document.fromJson(json['text']),
        selection: const TextSelection.collapsed(offset: 0),
      ),
    );
    return node;
  }





}