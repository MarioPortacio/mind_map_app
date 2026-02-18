import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:vector_math/vector_math_64.dart' as vmath;

import 'package:shared_preferences/shared_preferences.dart';

import './state/mind_map_controller.dart';
import './ui/node_widget.dart';
import './ui/node_style_panel.dart';
import '../../../core/canvas/mind_map_painter.dart';
import '../../../core/models/mind_node.dart'; 

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MindMapPage extends StatefulWidget {
  final MindMapController? initialController;
  const MindMapPage({super.key, this.initialController});

  @override
  State<MindMapPage> createState() => _MindMapPageState();
}

class _MindMapPageState extends State<MindMapPage> {
  final TransformationController _transformController = TransformationController();
  bool _showHint = true;

  bool _isDisposed = false;
  Offset? _doubleTapPosition;
  Offset? _lastCursorWorldPosition;

  bool _showMenuButtons = false;


  late final MindMapController controller;

  

  final ScreenshotController screenshotController = ScreenshotController();

  /// Convierte posición de pantalla a mundo (respeta zoom/pan)
  Offset _toWorld(Offset screenPosition) {
    final matrix = controller.transformationController.value; 
    final inverse = Matrix4.inverted(matrix);
    final point = inverse.transform3(
      vmath.Vector3(screenPosition.dx, screenPosition.dy, 0),
    );
    return Offset(point.x, point.y);
  }





  @override
  void initState() {
    super.initState();

    controller = widget.initialController ?? MindMapController();
     _loadPreferences(); // Cargar al iniciar

    WidgetsBinding.instance.addPostFrameCallback((_) {

       if (controller.nodes.isEmpty) {
        // Calculamos el centro para un canvas de 8000x8000
        final size = MediaQuery.of(context).size;
        final double centerX = 4000.0;
        final double centerY = 4000.0;

        controller.transformationController.value = Matrix4.identity()
          ..setTranslationRaw(
            (size.width / 2) - centerX,
            (size.height / 2) - centerY,
            0,
          );
      } else {
        centerMap();
      }

    });
   
  }

  // Exporta el mapa mental como una imagen PNG
  Future<void> _exportToImage() async {
    try {
      // capturar la imagen
      final Uint8List? imageBytes = await screenshotController.capture(
        pixelRatio: 2.0, // Ajustado para evitar errores de memoria en áreas grandes
      );

      if (imageBytes == null) return;

      // seleccionar destino forzando .png
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Exportar como PNG',
        fileName: 'mi_mapa_mental.png', // Nombre por defecto con extensión
        type: FileType.image, // filtra automaticamente para imagenes
      );

      if (outputPath != null) {
        // asegurar que termine en .png si el usuario lo borra manualmente
        if (!outputPath.toLowerCase().endsWith('.png')) {
          outputPath = '$outputPath.png';
        }

        final file = File(outputPath);
        await file.writeAsBytes(imageBytes);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen PNG guardada con éxito')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error al exportar imagen: $e");
    }
  }

  // exporta el mapa mental como un documento PDF
  Future<void> _exportToPDF() async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture(pixelRatio: 1.5);
      if (imageBytes == null) return;

      final pdf = pw.Document();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image, fit: pw.BoxFit.contain),
            );
          },
        ),
      );

      // seleccionar destino forzando .pdf
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Exportar como PDF',
        fileName: 'mi_mapa_mental.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'], // restringe a archivos PDF
      );

      if (outputPath != null) {
        if (!outputPath.toLowerCase().endsWith('.pdf')) {
          outputPath = '$outputPath.pdf';
        }

        final file = File(outputPath);
        await file.writeAsBytes(await pdf.save());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documento PDF guardado con éxito')),
          );
        }
      }
    } catch (e) {
      debugPrint("Error al exportar PDF: $e");
    }
  }


  void _showExportMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Exportar/Importar', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.file_upload, color: Colors.green),
              title: const Text('Importar archivo .mind'),
              onTap: () {
                Navigator.pop(context);
                controller.importFromJson();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Colors.orange),
              title: const Text('Exportar como Imagen (PNG)'),
              onTap: () {
                Navigator.pop(context);
                _exportToImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Exportar como PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportToPDF();
              },
            ),
          ],
        ),
      ),
    );
  }


  void centerMap() {
  if (controller.nodes.isEmpty) return;

  // calculamos el centro del grupo de nodos
  double minX = double.infinity, maxX = double.negativeInfinity;
  double minY = double.infinity, maxY = double.negativeInfinity;

  for (var node in controller.nodes) {
      if (node.position.dx < minX) minX = node.position.dx;
      if (node.position.dx > maxX) maxX = node.position.dx;
      if (node.position.dy < minY) minY = node.position.dy;
      if (node.position.dy > maxY) maxY = node.position.dy;
    }

  final mapCenterX = (minX + maxX) / 2;
  final mapCenterY = (minY + maxY) / 2;

  final size = MediaQuery.of(context).size;

  // movemos la camara para que el centro del mapa coincida con el centro de la pantalla
  controller.transformationController.value = Matrix4.identity()
    ..setTranslationRaw(
      (size.width / 2) - mapCenterX,
      (size.height / 2) - mapCenterY,
      0,
    );
}


  void _showFileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Guardar Archivo', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.code, color: Colors.blue),
              title: const Text('Guardar como archivo .mind'),
              subtitle: const Text('Guardar como'),
              onTap: () {
                Navigator.pop(context);
                controller.exportAsJson();
              },
            ),
            ListTile(
              leading: const Icon(Icons.save, color: Colors.blue),
              title: const Text('Guardar Progreso Actual'),
              subtitle: const Text('Guardar'),
              onTap: () {
                Navigator.pop(context);
                controller.saveCurrentFile(); 
              },
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!mounted) return;

      setState(() {
        // cargar estado del Hint (si es null por ser la 1ra vez, ponemos true)
        _showHint = prefs.getBool('showHint') ?? true;
        
        // cargar color de fondo
        final int? colorInt = prefs.getInt('canvasBackgroundColor');
        if (colorInt != null) {
          // accedemos al controlador para actualizar el color guardado
          controller.canvasBackgroundColor = Color(colorInt);
        }
      });
  }

  // metodo para guardar el estado del hint cuando el usuario lo cierra
  Future<void> _saveHintPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showHint', value);
  }
  


  @override
  void dispose() {
    _isDisposed = true;
    controller.dispose();
    _transformController.dispose();
    super.dispose();
  }


 void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 160,
        child: Column(
          children: [
            const Text('Cambiar color de fondo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Color(0xFF77DAC4), 
                Colors.white,
                const Color(0xFFF5F5DC), 
                const Color(0xFF2D2D2D),
              ].map((color) => GestureDetector(
                onTap: () {
                  controller.updateCanvasColor(color);
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 22,
                  child: controller.canvasBackgroundColor == color 
                    ? const Icon(Icons.check, color: Colors.blue) 
                    : null,
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // verificacion de seguridad rápida
    // con el initState correcto esto no debería fallar
    try {
      controller; 
    } catch (e) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          Listener(
            onPointerDown: (details) {
              if (_isDisposed) return;
              _lastCursorWorldPosition = _toWorld(details.localPosition);
              controller.updatePreview(_lastCursorWorldPosition!);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                controller.clearSelection();
                controller.stopConnecting();
                controller.clearPreview();
                controller.closeStylePanel();
              },
              onDoubleTapDown: (details) {
                _doubleTapPosition = _toWorld(details.localPosition);
              },
              onDoubleTap: () {
                if (controller.isEditingAnyNode) return;
                if (_doubleTapPosition == null) return;

                controller.addNode(_doubleTapPosition!);
              },
              child: MouseRegion(
                onHover: (details) {
                  if (_isDisposed) return;
                  _lastCursorWorldPosition = _toWorld(details.localPosition);
                  controller.updatePreview(_lastCursorWorldPosition!);
                },
                onExit: (_) {
                  _lastCursorWorldPosition = null;
                  controller.clearPreview();
                },
                child: Screenshot(
                  controller: screenshotController,
                    child: InteractiveViewer(
                    constrained: false,
                    transformationController: controller.transformationController,
                    minScale: 0.1,
                    maxScale: 2.5,
                    boundaryMargin: const EdgeInsets.all(4000),
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (_, _) {
                          final sortedNodes = List<MindNode>.from(controller.nodes)
                            ..sort((a, b) => a.level.compareTo(b.level));
                        return Stack(
                          children: [
                            // Conexiones y preview
                            CustomPaint(
                              size: const Size(8000, 8000),
                              painter: MindMapPainter(
                                controller.nodes,
                                controller.edges,
                                backgroundColor: controller.canvasBackgroundColor,
                                selectedNode: controller.selectedNode,
                                previewPosition: controller.previewPosition,
                                isConnecting: controller.isConnecting,
                                scale: 1.0,
                                offset: Offset.zero,
                              ),
                            ),

                            // Nodos
                            ...sortedNodes.map(
                              (node) => Positioned(
                                left: node.position.dx,
                                top: node.position.dy,
                                key: ValueKey(node.id),
                                child: NodeWidget(
                                  node: node,
                                  controller: controller,
                                  isSelected: controller.selectedNode == node,
                                  isTarget: controller.hoveredTargetNode == node,
                                  onTap: () => controller.onNodeTap(
                                    node,
                                    cursorPosition: _lastCursorWorldPosition,
                                  ),
                                  onUpdate: controller.update,
                                ),
                              ),
                            ),

                            //UBICACION DE LOS BOTONES DE ACCION
                            if (controller.selectedNode != null)
                              Positioned(
                                // usamos coordenadas mundo(dx, dy) directamente
                                // centramos horizontalmente respecto al nodo
                                left: controller.selectedNode!.position.dx + (controller.selectedNode!.size.width / 2) - 54,
                                // los ponemos justo arriba del nodo
                                top: controller.selectedNode!.position.dy - 50, 
                                child: NodeActionButtons(
                                  node: controller.selectedNode!,
                                  controller: controller,
                                ),
                              ),
                            ],
                          );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Botones de acción y panel de estilo
          AnimatedBuilder(
            animation: controller,
            builder: (_, _) {
              return Stack(
                children: [

                  // estado de archivo guardado
                  Positioned(
                    // top: 0,
                    left: 0,
                    right: 0, // Esto lo centra horizontalmente
                    bottom: 50,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              controller.hasUnsavedChanges ? Icons.description : Icons.assignment_turned_in,
                              color: controller.hasUnsavedChanges ? Colors.orangeAccent : Colors.greenAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              // mostramos el nombre del archivo o "Sin guardar"
                              "${controller.currentFilePath != null 
                                  ? controller.currentFilePath!.split(Platform.pathSeparator).last 
                                  : 'Sin guardar'}"
                              "${controller.hasUnsavedChanges ? '*' : ''}", // asterisco si hay cambios
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                 

                  if (controller.isStylePanelOpen)
                    NodeStylePanel(
                      controller: controller,
                      node: controller.editingNode!,
                    ),

                Positioned(
                  top: 40,
                  left: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // =========================
                      // BOTON TUERCA (TOGGLE)
                      // =========================
                      Tooltip(
                        message: _showMenuButtons
                            ? "Cerrar opciones"
                            : "Mostrar opciones",
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showMenuButtons = !_showMenuButtons;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _showMenuButtons
                                  ? Colors.deepPurple
                                  : const Color.fromARGB(255, 255, 255, 255),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6)
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) =>
                                  RotationTransition(turns: animation, child: child),
                              child: Icon(
                                _showMenuButtons ? Icons.close : Icons.settings,
                                key: ValueKey(_showMenuButtons),
                                color: _showMenuButtons
                                    ? Colors.white
                                    : Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // =========================
                      // BOTONES DESPLEGABLES
                      // =========================
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: _showMenuButtons
                            ? Row(
                                children: [

                                  const SizedBox(width: 8),

                                  //  VOLVER
                                  Tooltip(
                                    message: "Volver",
                                    waitDuration: const Duration(milliseconds: 400),
                                    textStyle: const TextStyle(color: Colors.white),
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: () async{
                                        if (controller.hasUnsavedChanges){
                                          bool? exit = await showDialog(
                                            context: context,
                                             builder: (context) => AlertDialog(
                                              title: const Text("Cambios sin guardar"),
                                              content: const Text("¿Seguro que quieres salir? Se perderán los cambios."),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
                                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Sí, salir")),
                                              ],
                                             ),
                                            );
                                            if (exit == true && context.mounted){
                                                Navigator.pop(context); 
                                            }
                                        }else {
                                          Navigator.pop(context);
                                        }
                                      },
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            Colors.deepPurple.shade100,
                                        foregroundColor: Colors.deepPurple,
                                        padding: const EdgeInsets.all(12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),


                                   //  HINT
                                    
                                     _Hint(
                                      isVisible: _showHint,
                                      onToggle: () {
                                        if (mounted) {
                                          setState(() {
                                            _showHint = !_showHint;
                                          });
                                        }
                                        _saveHintPreference(_showHint);
                                      },
                                    ),
                                 

                                  const SizedBox(width: 8),


                                  //Cambiar color de fondo
                                  Tooltip(
                                    message: "Cambiar color de fondo",
                                    waitDuration: const Duration(milliseconds: 400),
                                    textStyle: const TextStyle(color: Colors.white),
                                    child: IconButton(
                                      icon: const Icon(Icons.palette_outlined),
                                      onPressed: () => _showColorPicker(context),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.orange.shade100,
                                        foregroundColor: Colors.orange.shade800,
                                        padding: const EdgeInsets.all(12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // GUARDAR
                                  Tooltip(
                                    message: "Guardar archivo",
                                    textStyle: const TextStyle(color: Colors.white),
                                    waitDuration: const Duration(milliseconds: 400),
                                    child: IconButton(
                                      icon: const Icon(
                                          Icons.sd_storage_outlined),
                                      onPressed: () =>
                                          _showFileMenu(context),
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            Colors.green.shade100,
                                        foregroundColor:
                                            Colors.green.shade800,
                                        padding:
                                            const EdgeInsets.all(12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // EXPORTAR
                                  Tooltip(
                                    message: "Exportar/Importar",
                                    waitDuration: const Duration(milliseconds: 400),
                                    textStyle: const TextStyle(color: Colors.white),
                                    child: IconButton(
                                      icon:
                                          const Icon(Icons.ios_share),
                                      onPressed: () =>
                                          _showExportMenu(context),
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            Colors.blue.shade100,
                                        foregroundColor:
                                            Colors.blue.shade800,
                                        padding:
                                            const EdgeInsets.all(12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),



                
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}



class _Hint extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onToggle;

  const _Hint({
    required this.isVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Tooltip(
          message: isVisible ? "Cerrar ayuda" : "Mostrar ayuda",
          child: IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            iconSize: 22,
            padding: const EdgeInsets.all(12),
            onPressed: onToggle,
            style: IconButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.deepPurple.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        Positioned(
          top: 56,
          left: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: isVisible
                ? Material(
                    key: const ValueKey('hintPanel'),
                    color: Colors.transparent,
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Colors.deepPurple.shade200),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// HEADER
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ayuda',
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(color: Color.fromARGB(60, 0, 0, 0)),
                          const Text(
                            '• Doble clic para crear nodo\n'
                            '• Doble clic en nodo para editar\n'
                            '• Clic en nodo para acciones\n'
                            '• Arrastrar para mover\n'
                            '• Revise bien el panel de edición\n'
                            '• Revise las plantillas\n'
                            '• Clic afuera para deseleccionar',
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}










