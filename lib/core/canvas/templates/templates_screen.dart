import 'package:flutter/material.dart';
import '../../../features/mind_map/state/mind_map_controller.dart';
import '../../../features/mind_map/mind_map_page.dart';
import './template_manager.dart';
import './mind_map_preview.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});


 void _openTemplate(BuildContext context, MindMapTemplate t) {
    final controller = MindMapController();
    
    // enviamos un MAPA con las claves 'nodes' y 'edges'
    controller.loadFromTemplate({
      'nodes': t.nodes,
      'edges': t.edges,
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MindMapPage(initialController: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templates = TemplateManager.templates;

    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona una Plantilla')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // dos miniaturas por fila
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2,
        ),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final t = templates[index];
          return GestureDetector(
            onTap: () => _openTemplate(context, t),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LA MINIATURA
                  Expanded(
                    child: MindMapPreview(
                      nodesJson: t.nodes,
                      edgesJson: t.edges,
                    ),
                  ),
                  // EL TITULO
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      t.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}