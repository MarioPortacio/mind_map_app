import 'package:flutter/material.dart';
import '../../models/mind_edge.dart';
import '../../models/mind_node.dart';
import '../mind_map_painter.dart'; 

class MindMapPreview extends StatelessWidget {
  final List<Map<String, dynamic>> nodesJson;
  final List<Map<String, dynamic>> edgesJson;

  const MindMapPreview({super.key, required this.nodesJson, required this.edgesJson});


  @override
  Widget build(BuildContext context) {
    final nodes = nodesJson.map((n) => MindNode.fromJson(n)).toList();
    final edges = edgesJson.map((e) => MindEdge.fromJson(e)).toList();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: FittedBox(
          fit: BoxFit.contain, 
          child: SizedBox(
            width: 1000,
            height: 800,
            child: CustomPaint(
              painter: MindMapPainter(
                nodes,
                edges,
                scale: 1.0, 
                offset: Offset.zero,
                backgroundColor: Colors.transparent,
                selectedNode: null,
              ),
            ),
          ),
        ),
      ),
    );
  }


  
}