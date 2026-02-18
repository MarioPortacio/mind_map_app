import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../core/models/mind_node.dart';
import '../../../core/models/mind_edge.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

enum NodeActionMode {
  none,
  connecting,
}

class MindMapController extends ChangeNotifier {
  // =========================
  // DATA
  // =========================
  List<MindNode> nodes = [];
  List<MindEdge> edges = [];

  String? currentFilePath;

  bool _hasUnsavedChanges = false;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  // =========================
  // INTERACTION STATE
  // =========================
  MindNode? selectedNode;
  MindNode? hoveredTargetNode;
  Offset? previewPosition;

  NodeActionMode actionMode = NodeActionMode.none;

  // =========================
  // UI STATE
  // =========================
  MindNode? editingNode;

  bool _disposed = false;
  Color canvasBackgroundColor = const Color.fromARGB(255, 119, 218, 196);

  TransformationController transformationController = TransformationController();

  void updateCanvasColor(Color newColor) {
    canvasBackgroundColor = newColor;
    notifyListeners();
    _saveColorPreference(newColor); 
  }

  Future<void> _saveColorPreference(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('canvasBackgroundColor', color.toARGB32());
  }


  // Llama esto cada vez que el usuario haga algo (mover nodo, crear, etc.)
  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      _hasUnsavedChanges = true;
      notifyListeners();
    }
  }

 
  void forceMarkAsChanged() {
    _markAsChanged();
  }


  
  void resetUnsavedChanges() {
    _hasUnsavedChanges = false;
    notifyListeners();
  }



  void loadFromTemplate(Map<String, dynamic> data) {
    nodes.clear();
    edges.clear();

    // detectar si es una plantilla (no tiene cámara guardada)
    bool isTemplate = !data.containsKey('cameraTransform');
    
    // el centro del canvas de 8000x8000
    double offsetX = isTemplate ? 4000.0 : 0.0;
    double offsetY = isTemplate ? 4000.0 : 0.0;


    //cargar nodos 
    if (data['nodes'] != null) {
      var nodesList = data['nodes'] as List;
      for (var n in nodesList) {
        var node = MindNode.fromJson(Map<String, dynamic>.from(n));
        
        // si es plantilla, empuja el nodo al centro del canvas
        if (isTemplate) {
          node.position = Offset(
            node.position.dx + offsetX, 
            node.position.dy + offsetY
          );
        }
        nodes.add(node);
      }
    }


    

    // cargar conexiones
    if (data['edges'] != null) {
    var edgesList = data['edges'] as List;
    for (var e in edgesList) {
      var edge = MindEdge.fromJson(Map<String, dynamic>.from(e));
      // Si tus Edges guardan posiciones fijas (no solo IDs), 
      // también deben sumarse el offset.
      edges.add(edge);
    }
  }

    // posicionar la camara
    if (!isTemplate) {
      // si tiene camara guardada, usarla
      final list = List<double>.from(data['cameraTransform']);
      transformationController.value = Matrix4.fromList(list);
    } else {
    
      transformationController.value = Matrix4.identity(); 
      
    }


    // Después de cargar los nodos, añade el listener a cada uno:
    for (var node in nodes) {
      node.textController.addListener(() {
        _markAsChanged();
      });
    }
    _hasUnsavedChanges = false;
    notifyListeners();
  }



  // =========================
  // GETTERS
  // =========================
  bool get isConnecting => actionMode == NodeActionMode.connecting;
  bool get isStylePanelOpen => editingNode != null;

  bool get isEditingAnyNode => nodes.any((n) => n.isEditing);
  

  // =========================
  // LIFECYCLE SAFETY
  // =========================
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }



  @override
  void notifyListeners() {
  if (_disposed) return;
    super.notifyListeners();
  }

  // =========================
  // NODE CREATION
  // =========================
  void addNode(Offset position) {
    const size = Size(120, 48);

    final controller = QuillController.basic()
      ..document.insert(0, 'Nueva idea');

    controller.addListener(() {
      _markAsChanged();
    });

    nodes = [
      ...nodes,
      MindNode(
        id: _generateId(),
        position: position - Offset(size.width / 2, size.height / 2),
        color: const Color.fromARGB(255, 122, 93, 172),
        size: size,
        textController: controller,
      ),
    ];

    _markAsChanged();
    notifyListeners();
  }

  // =========================
  // SELECTION & CONNECTION
  // =========================
  void clearSelection() {
    selectedNode = null;
    hoveredTargetNode = null;
    previewPosition = null;
    actionMode = NodeActionMode.none;
    notifyListeners();
  }

  void startConnecting(MindNode node) {
    selectedNode = node;
    actionMode = NodeActionMode.connecting;
    notifyListeners();
  }

  void stopConnecting() {
    clearSelection();
  }

  void onNodeTap(MindNode node, {Offset? cursorPosition}) {

    if (isConnecting && selectedNode != null && selectedNode != node) {
      _toggleConnection(selectedNode!, node);
      clearSelection();
      return;
    }

  
    selectedNode = selectedNode == node ? null : node;
    notifyListeners();
  }

  void _toggleConnection(MindNode a, MindNode b) {
    final exists = areConnected(a, b);

    if (exists) {
      edges = edges.where(
        (e) =>
            !((e.fromId == a.id && e.toId == b.id) ||
              (e.fromId == b.id && e.toId == a.id)),
      ).toList();
    } else {
      edges = [...edges, MindEdge(fromId: a.id, toId: b.id)];
    }

    _markAsChanged();
    notifyListeners();
  }

  bool areConnected(MindNode a, MindNode b) {
    return edges.any(
      (e) =>
          (e.fromId == a.id && e.toId == b.id) ||
          (e.fromId == b.id && e.toId == a.id),
    );
  }

  // =========================
  // PREVIEW / HOVER
  // =========================
  void updatePreview(Offset worldPosition) {
    if (!isConnecting || selectedNode == null) return;

    previewPosition = worldPosition;
    hoveredTargetNode = _findTargetNode(worldPosition);
    notifyListeners();
  }

  void clearPreview() {
    previewPosition = null;
    hoveredTargetNode = null;
    notifyListeners();
  }

  MindNode? _findTargetNode(Offset pos) {
    const double snapRadius = 60;

    for (final node in nodes) {
      if (node == selectedNode) continue;

      if ((node.center - pos).distance <= snapRadius) {
        return node;
      }
    }
    return null;
  }

  // =========================
  // EDITING / STYLE PANEL
  // =========================
  void openStylePanel(MindNode node) {
    editingNode = node;
    notifyListeners();
  }



  void closeStylePanel() {
    editingNode = null;
    notifyListeners();
  }

  void startEditing(MindNode node) {
    for (final n in nodes) {
      if (n != node) {
        n.isEditing = false;
      }
    }
    node.isEditing = true;
    
  } 



  // =========================
  // NODE UPDATES
  // =========================
  void moveNode(MindNode node, Offset delta) {
    node.position += delta;
    _markAsChanged();
    notifyListeners();
  }

  void updateNodeColor(MindNode node, Color color) {
    if (node.color == color) return;
    node.color = color;
    _markAsChanged();
    notifyListeners();
  }

  void updateNodeSize(MindNode node, Size size) {
    if (node.size == size) return;
    node.size = size;
    _markAsChanged();
    notifyListeners();
  }

  void update() {
    _markAsChanged();
    notifyListeners();
  }

void updateNodeWidth (MindNode node, double width) {
    node.size = Size(width, node.size.height);
    _markAsChanged();
    notifyListeners();
  }

  void updateNodeHeight (MindNode node, double height) {
    node.size = Size(node.size.width, height);
    _markAsChanged();
    notifyListeners();
  }



void updateNodeShape(MindNode node, MindNodeShape shape) {
  if (node.shape == shape) return;
  node.shape = shape;
  _markAsChanged();
  notifyListeners();
}

void updateNodeLevel(MindNode node, int newLevel) {
  // aplica la restricción de min: 1, max: 99
  final clampedLevel = newLevel.clamp(1, 99);
  if (node.level == clampedLevel) return;
  node.level = clampedLevel;
  _markAsChanged();
  notifyListeners();
}

  // =========================
  // DELETE
  // =========================
  void deleteNode(MindNode node) {
    edges = edges.where(
      (e) => e.fromId != node.id && e.toId != node.id,
    ).toList();

    nodes = nodes.where((n) => n != node).toList();

    if (selectedNode == node) selectedNode = null;
    if (editingNode == node) editingNode = null;
    if (hoveredTargetNode == node) hoveredTargetNode = null;
    _markAsChanged();
    notifyListeners();
  }


  // =========================
  // TEXT HELPERS
  // =========================
  String getNodePlainText(MindNode node, {int? maxLength}) {
    final text = node.textController.document.toPlainText().trim();
    if (text.isEmpty) return '';

    if (maxLength != null && text.length > maxLength) {
      return '${text.substring(0, maxLength)}...';
    }
    return text;
  }

  // =========================
  // UTIL
  // =========================
  String _generateId() {
    return '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}';
  }




  // =========================
  // FILES
  // =========================


  Future<void> exportAsJson() async {
    // 1. Abrimos el selector para el nuevo nombre
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar como...',
      fileName: 'mapa_nuevo.mind',
      type: FileType.any,
    );

    if (outputPath != null) {
      // forzamos la extension
      if (!outputPath.toLowerCase().endsWith('.mind')) {
        outputPath = '$outputPath.mind';
      }

      // obtiene los datos que estnn en el canvas justo ahora
      final data = {
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'edges': edges.map((e) => e.toJson()).toList(),
        'backgroundColor': canvasBackgroundColor.toARGB32(),
        'cameraTransform': transformationController.value.storage.toList(),
      };

      final file = File(outputPath);
      
      await file.writeAsString(jsonEncode(data), flush: true);
      
      currentFilePath = outputPath; 
      
      debugPrint("Se ha creado una copia nueva en: $outputPath");
    }
  }


  Future<void> saveCurrentFile() async {
    if (currentFilePath == null) {
      await exportAsJson();
      return;
    }

    // LOG DE CONTROL 1: ¿Cuántos nodos hay en memoria antes de guardar?
    debugPrint("DEBUG: Intentando guardar. Nodos en memoria: ${nodes.length}");

    if (nodes.isEmpty) {
      debugPrint("ALERTA: Intentando guardar un mapa vacío. Operación cancelada para evitar pérdida de datos.");
      return; 
    }

    try {
      // Generamos el mapa de datos
      final data = {
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'edges': edges.map((e) => e.toJson()).toList(),
        'backgroundColor': canvasBackgroundColor.toARGB32(),
        'cameraTransform': transformationController.value.storage.toList(),
      };

      // LOG DE CONTROL 2: ¿Cómo se ve el JSON resultante?
      String jsonString = jsonEncode(data);
      debugPrint("DEBUG: JSON generado (primeros 100 caracteres): ${jsonString.substring(0, 100)}");

      final file = File(currentFilePath!);
      
      // Escribimos y forzamos el cierre total del archivo
      await file.writeAsString(jsonString, mode: FileMode.write, flush: true);
      debugPrint("DEBUG: Guardado exitoso en $currentFilePath");
      resetUnsavedChanges();
    } catch (e) {
      debugPrint("ERROR CRÍTICO AL GUARDAR: $e");
    }
  }

  
  Future<void> importFromJson() async {
    try {
      // abrimos el selector de archivos permitiendo "cualquier" tipo 
      // para que el sistema operativo no lo oculte.
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, 
      );

      if (result != null && result.files.single.path != null) {
        final String path = result.files.single.path!;
        debugPrint("Intentando abrir archivo en ruta: $path");

        final file = File(path);
        final jsonString = await file.readAsString();

        try {
          // Intentamos decodificarlo directamente. 
          final data = jsonDecode(jsonString);
          
          // Verificación de que el JSON tiene la estructura
          if (data is Map<String, dynamic> && data.containsKey('nodes')) {
            
            loadFromTemplate(data); 

            currentFilePath = path;
            notifyListeners();
            debugPrint("Archivo cargado con éxito (independiente de la extensión).");
          } else {
            debugPrint("Error: El archivo no parece ser un mapa mental válido.");
          }
        } catch (e) {
          debugPrint("Error: El contenido del archivo no es un JSON válido. $e");
        }
      }
    } catch (e) {
      debugPrint("Error crítico al importar: $e");
    }
}


}