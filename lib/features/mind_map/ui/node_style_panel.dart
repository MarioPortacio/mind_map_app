import 'package:flutter/material.dart';
import '../state/mind_map_controller.dart';
import '../../../core/models/mind_node.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../../../core/utils/font_utils.dart';
import './dialog_helper.dart';

class NodeStylePanel extends StatefulWidget {
  final MindMapController controller;
  final MindNode node;

  const NodeStylePanel({
    super.key,
    required this.controller,
    required this.node,
  });

  @override
  State<NodeStylePanel> createState() => _NodeStylePanelState();
}

class _NodeStylePanelState extends State<NodeStylePanel> {
  late FocusNode _focusNode;
  late ScrollController _scrollController;

 @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
  }


  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _levelButton(IconData icon, VoidCallback onPressed) {
  return IconButton(
    onPressed: () {
      onPressed();
      if (mounted) {
        setState(() {}); // forzamos el redibujado del panel para ver el cambio
     }
    },
    icon: Icon(icon),
    style: IconButton.styleFrom(
      backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(8),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final node = widget.node;
    final maxHeight = MediaQuery.of(context).size.height * 0.90; //90% de la pantalla

    return Positioned(
      bottom: 100,
      right: 24,
      top: 100,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 240,
          constraints: BoxConstraints(
            maxHeight: maxHeight, // Máximo 90% de la pantalla
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panel de edición de nodo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Título:\n${controller.getNodePlainText(node, maxLength: 20)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Quill Toolbar + Editor ---
                  QuillSimpleToolbar(
                    controller: node.textController,
                    config: const QuillSimpleToolbarConfig( 
                      showBoldButton: true,
                      showItalicButton: true,
                      showUnderLineButton: true,
                      showListBullets: true,
                      showListNumbers: true,
                      showColorButton: true,
                      showBackgroundColorButton: true,
                      showAlignmentButtons: true,
                      showCodeBlock: true,
                      showFontFamily: true,
                      buttonOptions: QuillSimpleToolbarButtonOptions(
                        fontFamily: QuillToolbarFontFamilyButtonOptions(
                          items: {
                            'Roboto': 'Roboto',
                            'Lobster': 'Lobster',
                            'Montserrat': 'Montserrat',
                            'FiraCode': 'FiraCode',
                          },


                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QuillEditor.basic(
                      controller: node.textController,
                      config: QuillEditorConfig(
                        customStyles: DefaultStyles(
                          paragraph: DefaultListBlockStyle(
                            nodeFontStyle(
                              'Roboto', 
                              color: Colors.black, 
                              fontSize: 14,
                            ),
                            const HorizontalSpacing(0, 0),
                            
                            const VerticalSpacing(0, 0), 
                            const VerticalSpacing(0, 0), 
                            const BoxDecoration(),
                            null, 
                        
                          ),
                        ),

                       customStyleBuilder: (attribute) {
                        if (attribute.key == Attribute.font.key) {
                          final String fontName = attribute.value.toString();
                          
                          final googleStyle = nodeFontStyle(fontName, color: Colors.black, fontSize: 14);
                          
                          return TextStyle(fontFamily: googleStyle.fontFamily);
                        }
                        return const TextStyle();
                      },

                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- SECCIÓN DE FORMA ---
                  const Text('Forma del nodo', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SegmentedButton<MindNodeShape>(
                    showSelectedIcon: false,
                    segments: const [ //crop_7_5 cuadrado, 16_9 ES PILL??
                      ButtonSegment(tooltip: "Cuadrado", value: MindNodeShape.roundedRect, icon: Icon(Icons.crop_7_5_sharp)),
                      ButtonSegment(tooltip: "Circular", value: MindNodeShape.circle, icon: Icon(Icons.circle_outlined)),
                      ButtonSegment(tooltip: "Pildora", value: MindNodeShape.pill, icon: Icon(Icons.crop_5_4_rounded)),
                    ],
                    selected: {node.shape},
                    onSelectionChanged: (newSelection) {
                      widget.controller.updateNodeShape(node, newSelection.first);
                      if (mounted) {
                        setState(() {});
                       }
                    },
                  ),

                  const SizedBox(height: 20),

                  // --- SECCIÓN DE NIVEL ---
                  const Text('Nivel de Jerarquía (Z-Index)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _levelButton(Icons.remove, () => widget.controller.updateNodeLevel(node, node.level - 1)),
                      Expanded(
                        child: Text(
                          '${node.level}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _levelButton(Icons.add, () => widget.controller.updateNodeLevel(node, node.level + 1)),
                    ],
                  ),
                  const Text(
                    'Rango: 1 - 99',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                   /// ---------- TAMAÑO NODO ----------
                  const SizedBox(height: 16),
                  const Text('Ancho'),
                  Slider(
                    min: 80,
                    max: 600, //300
                    value: node.size.width,
                    onChanged: (value) {
                      widget.controller.updateNodeWidth(node, value);
                      if (mounted) {
                        setState(() {});
                       }
                    },
                  ),

                  const Text('Alto'),
                  Slider(
                    min: 40,
                    max: 600, //200
                    value: node.size.height,
                    onChanged: (value) {
                      widget.controller.updateNodeHeight(node, value);
                      if (mounted) {
                        setState(() {});
                       }  
                    },
                  ),

                  // --- Color de fondo ---
                  const Text(
                    'Color del nodo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Colors.white,
                      Colors.black,
                      Colors.yellow,
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.deepPurple,
                      Colors.orange,
                      Colors.pinkAccent,
                      Colors.brown,
                      Colors.grey,
                      Colors.lime,
                      Colors.redAccent,
                      Colors.teal,
                      Colors.tealAccent,
                      Colors.transparent,
                    ].map((color) {
                      return _ColorDot(
                        color: color,
                        isSelected: node.color == color,
                        onTap: () {
                          controller.updateNodeColor(node, color);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 46),

                  // --- Botón eliminar nodo ---
                  TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Eliminar nodo',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () async {
                    final confirm = await DialogHelper.showConfirmDialog(
                      context: context,
                      title: '¿Eliminar nodo?',
                      content: 'Esta acción borrará el nodo y todas sus conexiones de forma permanente.',
                    );
                    
                    if (confirm) {
                      widget.controller.deleteNode(node);
                    }
                  },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;
  final bool isSelected;

  const _ColorDot({
    required this.color,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color == Colors.transparent
              ? Colors.grey.withValues(alpha: 0.5)
              : color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.grey,
            width: 2,
          ),
        ),
        child: color == Colors.transparent
            ? const Icon(Icons.block, size: 16)
            : null,
      ),
    );
  }
}
