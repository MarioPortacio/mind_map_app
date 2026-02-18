import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import '../../../core/models/mind_node.dart';
import '../state/mind_map_controller.dart';
import '../../../core/utils/font_utils.dart';







class NodeWidget extends StatefulWidget {
  final MindNode node;
  final VoidCallback onUpdate;
  final bool isSelected;
  final bool isTarget;
  final VoidCallback onTap;
  final MindMapController controller;
  

  const NodeWidget({
    super.key,
    required this.node,
    required this.isSelected,
    required this.onTap,
    required this.onUpdate,
    required this.controller,
    required this.isTarget,
  });

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  @override
  void initState() {
    super.initState();
    // escuchar cambios en el textController para actualizar el HTML
    widget.node.textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.node.textController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {}); // actualizar cuando cambie el texto
    }
  }



String _getHtmlContent() {
  final delta = widget.node.textController.document.toDelta();
  final List<Map<String, dynamic>> deltaJson = delta.toJson();

  for (var operation in deltaJson) {
    if (operation.containsKey('attributes')) {
      final attrs = operation['attributes'] as Map<String, dynamic>;

      // corregir Colores
      if (attrs.containsKey('color')) attrs['color'] = _fixColor(attrs['color']);
      if (attrs.containsKey('background')) attrs['background'] = _fixColor(attrs['background']);

      // FORZAR LA FUENTE: Si existe el atributo 'font', lo pasamos a 'font-family'
      if (attrs.containsKey('font')) {
        // Quill guarda 'lobster', 'montserrat', etc.
        String fontName = attrs['font'].toString();
        
        // normalizamos el nombre para el CSS (Primera letra mayuscula)
        String formattedFont = fontName[0].toUpperCase() + fontName.substring(1);
        
        attrs['font-family'] = formattedFont;
      } else {
        // si no hay fuente seleccionada, aseguramos que sea Roboto
        attrs['font-family'] = 'Roboto';
      }
    }
  }

  final converter = QuillDeltaToHtmlConverter(
    deltaJson,
    ConverterOptions(
      converterOptions: OpConverterOptions(inlineStylesFlag: true),
    ),
  );

  // debugPrint("Html: ${converter.convert()}");

  return converter.convert();
}




// funcion auxiliar para limpiar el formato de color de Quill (#FF000000 -> #000000)
String _fixColor(dynamic hex) {
  String colorStr = hex.toString();
  if (colorStr.startsWith('#') && colorStr.length == 9) {
    // Retorna el # seguido de los ultimos 6 caracteres (RRGGBB)
    return '#${colorStr.substring(3)}';
  }
  return colorStr;
}





  @override
  Widget build(BuildContext context) {
    final String contenidoHtml = _getHtmlContent();
    BorderRadius getBorderRadius() {
      switch (widget.node.shape) { 
        case MindNodeShape.circle:
          return BorderRadius.circular(widget.node.size.width);
        case MindNodeShape.pill:
          return BorderRadius.circular(16);
        case MindNodeShape.roundedRect:
          return BorderRadius.circular(2);
      }
    }

    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onDoubleTap: () {
        widget.controller.openStylePanel(widget.node);
        
      },
      onPanUpdate: (details) {
        widget.node.position += details.delta;
        widget.onUpdate();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: widget.node.size.width,
        height: widget.node.size.height,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.node.color,
          borderRadius: getBorderRadius(),
          border: widget.isSelected 
              ? Border.all(color: Colors.amber, width: 3) 
              : null,
          boxShadow: [
            if (widget.isTarget)
              BoxShadow(
                color: Colors.yellow.withValues(alpha: 0.9),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            if (widget.isSelected)
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.6),
                blurRadius: 16,
              ),
          ],
        ),
        child: SingleChildScrollView(

          child: ListenableBuilder(
            listenable: widget.node.textController, 
            builder: (context, _){
            Key(contenidoHtml.hashCode.toString());

             return html.Html(
            data: contenidoHtml,
            style: {
              "body": html.Style(
                margin: html.Margins.zero,
                padding: html.HtmlPaddings.zero,
                fontSize: html.FontSize(14),
                fontFamily: nodeFontStyle('Roboto', color: Colors.black, fontSize: 14).fontFamily,
              ),
           

            "Montserrat": html.Style(
              fontFamily: nodeFontStyle('Montserrat', color: Colors.black, fontSize: 14).fontFamily,
            ),
            "Lobster": html.Style(
              fontFamily: nodeFontStyle('Lobster', color: Colors.black, fontSize: 14).fontFamily,
            ),
            "FiraCode": html.Style(
              fontFamily: nodeFontStyle('FiraCode', color: Colors.black, fontSize: 14).fontFamily,
            ),

              "p": html.Style(
                margin: html.Margins.zero,
                padding: html.HtmlPaddings.zero,
              ),
              "span": html.Style(
              ),
              "strong": html.Style(
                fontWeight: FontWeight.bold,
              ),
              "em": html.Style(
                fontStyle: FontStyle.italic,
              ),
              "u": html.Style(
                textDecoration: TextDecoration.underline,
              ),
              
            },

           extensions: [
            html.TagExtension(
              tagsToExtend: {"span"},
              builder: (extensionContext) {
                final style = extensionContext.styledElement?.style;
                
                // extraemos los valores del estilo parseado por flutter_html
                final String family = style?.fontFamily ?? 'Roboto';
                final Color textColor = style?.color ?? Colors.black;
                final Color? bgColor = style?.backgroundColor; 
                final double size = style?.fontSize?.value ?? 14;

                return Text(
                  extensionContext.innerHtml,
                  style: nodeFontStyle(
                    family,
                    color: textColor,
                    fontSize: size,
                  ).copyWith(
                    backgroundColor: bgColor,
                  ),
                );
              },
            ),
          ],
          );



            }
            
            
            )
                    

        ),
      ),
    );
  }
}



