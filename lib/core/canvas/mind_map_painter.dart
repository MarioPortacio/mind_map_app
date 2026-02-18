import 'package:flutter/material.dart';
import 'package:mind_map_app/features/mind_map/state/mind_map_controller.dart';
import '../models/mind_node.dart';
import '../models/mind_edge.dart';
import '../../features/mind_map/ui/dialog_helper.dart';

class MindMapPainter extends CustomPainter {
  final List<MindNode> nodes;
  final List<MindEdge> edges;
  final MindNode? selectedNode;
  final Offset? previewPosition;
  final bool isConnecting;
  final Color backgroundColor;

  final double scale;
  final Offset offset;

  MindMapPainter(
    this.nodes, 
    this.edges, {
    required this.selectedNode,
    this.previewPosition,
    this.isConnecting = false,
    required this.backgroundColor,
    this.scale = 1.0,           
    this.offset = Offset.zero,  
    });


  @override
  bool shouldRepaint(covariant MindMapPainter oldDelegate) {
    return  oldDelegate.nodes != nodes ||
            oldDelegate.edges != edges ||
            oldDelegate.selectedNode != selectedNode ||
            oldDelegate.previewPosition != previewPosition ||
            oldDelegate.isConnecting != isConnecting ||
            oldDelegate.scale != scale ||
            oldDelegate.offset != offset ||
            oldDelegate.backgroundColor != backgroundColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    
    
    // centrar el mapa en la miniatura
    canvas.translate(offset.dx, offset.dy);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // guardamos el estado del canvas para aplicar escala y traslación
    canvas.save();
    
    // si estamos en modo previsualización, la escala será pequeña
    // si estamos en el editor, la escala será 1.0 
    canvas.scale(scale);

    // --- GRID DE PUNTOS ---
    const double spacing = 80;
    final dotPaint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Dibujamos un área grande de puntos
    for (double x = 0; x < 8000; x += spacing) {
      for (double y = 0; y < 8000; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
    }

    // --- CONEXIONES ---
    final edgePaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final edge in edges) {
      try {
        final from = nodes.firstWhere((n) => n.id == edge.fromId);
        final to = nodes.firstWhere((n) => n.id == edge.toId);

        final start = from.connectionPointToward(to.center);
        final end = to.connectionPointToward(from.center);

        final dx = end.dx - start.dx;
        final dy = end.dy - start.dy;

        final control1 = start + Offset(dx * 0.25, dy * 0.0);
        final control2 = start + Offset(dx * 0.75, dy * 1.0);

        final path = Path()
          ..moveTo(start.dx, start.dy)
          ..cubicTo(
            control1.dx, control1.dy,
            control2.dx, control2.dy,
            end.dx, end.dy,
          );

        canvas.drawPath(path, edgePaint);
      } catch (e) {
        // evita que la app truene si un nodo de la arista no existe
        continue;
      }
    }

    // --- LINEA DE PREVISUALIZACION (Solo en el editor) ---
    if (selectedNode != null && previewPosition != null && isConnecting) {
      final previewpaint = Paint()
        ..color = Colors.amber.withValues(alpha: 0.7)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      
      final start = selectedNode!.connectionPointToward(previewPosition!);
      canvas.drawLine(start, previewPosition!, previewpaint);
    }


    // --- DIBUJAR NODOS ---
    for (final node in nodes) {
      final paint = Paint()
        ..color = node.color
        ..style = PaintingStyle.fill;

      final rect = Rect.fromLTWH(node.position.dx, node.position.dy, node.size.width, node.size.height);

      // ESTO ES LO QUE PERMITE CAMBIAR LA FORMA:
      switch (node.shape) {
        case MindNodeShape.roundedRect:
          canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paint);
          break;
        case MindNodeShape.pill:
          canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(16)), paint);
          break;
        case MindNodeShape.circle:
          canvas.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(node.position.dx, node.position.dy, node.size.width, node.size.height),
          Radius.circular(node.size.width),),paint);        
          break;
      }
    }
    // restauramos el canvas al finalizar el dibujo de los elementos escalados
    canvas.restore();
  }

}


class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}


class NodeActionButtons extends StatelessWidget {
  final MindNode node;
  final MindMapController controller;

  const NodeActionButtons({
    super.key,
    required this.node,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.link,
            tooltip: 'Conectar',
            onTap: () => controller.startConnecting(node),
          ),
          const SizedBox(width: 6),
          _ActionButton(
            icon: Icons.edit,
            tooltip: 'Editar',
            onTap: () => controller.openStylePanel(node),
          ),
          const SizedBox(width: 6),
          _ActionButton(
            icon: Icons.delete,
            tooltip: 'Eliminar',
            color: Colors.red,
            onTap: () async {
              final confirm = await DialogHelper.showConfirmDialog(
                context: context,
                title: '¿Eliminar nodo?',
                content: 'Esta acción borrará el nodo y todas sus conexiones de forma permanente.',
              );
              if (confirm) {
                controller.deleteNode(node);
              }
            },
          ),
        ],
      ),
    );
  }
}


RRect getShape(MindNode node) {
  switch (node.shape) {
    case MindNodeShape.circle:
      return RRect.fromRectAndRadius(
        Rect.fromLTWH(node.position.dx, node.position.dy, node.size.width, node.size.height),
        Radius.circular(node.size.width),
      );
    case MindNodeShape.pill:
      return RRect.fromRectAndRadius(
        Rect.fromLTWH(node.position.dx, node.position.dy, node.size.width, node.size.height),
        Radius.circular(16),
      );
    case MindNodeShape.roundedRect:
      return RRect.fromRectAndRadius(
        Rect.fromLTWH(node.position.dx, node.position.dy, node.size.width, node.size.height),
        const Radius.circular(8),
      );
  }
}


