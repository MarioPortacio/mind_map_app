class MindMapTemplate {
  final String name;
  final String description;
  final List<Map<String, dynamic>> nodes;
  final List<Map<String, dynamic>> edges;

  MindMapTemplate({
    required this.name,
    required this.description,
    required this.nodes,
    required this.edges,
  });
}

class TemplateManager {
  static List<MindMapTemplate> get templates => [
    MindMapTemplate(
      name: 'Relación simple',
      description: 'Nodo central con ramificaciones balanceadas.',
      nodes: [
        {
          'id': 'root',
          'position': {'dx': 500.0, 'dy': 400.0}, // Centro de la zona visible
          'color': 0xFF673AB7,
          'size': {'width': 150.0, 'height': 60.0},
          'shape': 2,
          'level': 1,
          'text': [{'insert': 'Idea Central\n'}]
        },
        {
          'id': 'sub1',
          'position': {'dx': 300.0, 'dy': 300.0}, // Desplazado respecto al centro
          'color': 0xFF2196F3,
          'size': {'width': 120.0, 'height': 50.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Subidea 1\n'}]
        },
      ],
      edges: [
        {'fromId': 'root', 'toId': 'sub1'},
      ],
    ),

    MindMapTemplate(
      name: 'Lluvia de ideas',
      description: 'Mapa radial complejo con 4 categorías y sub-nodos.',
      nodes: [
        // NODO CENTRAL (Nivel 1)
        {
          'id': 'b_root',
          'position': {'dx': 500.0, 'dy': 400.0},
          'color': 00000000,
          'size': {'width': 250.0, 'height': 70.0},
          'shape': 2, // Pill
          'level': 1,
          'text': [{'insert': 'PROYECTO X\n', 'attributes': {'bold': true, 'size': 'large'}}]
        },

        // RAMA 1: PRODUCTO (Arriba Izquierda - Azul)
        {
          'id': 'cat_prod',
          'position': {'dx': 250.0, 'dy': 250.0},
          'color': 0xFF2196F3,
          'size': {'width': 140.0, 'height': 50.0},
          'shape': 0, // Rectangle
          'level': 2,
          'text': [{'insert': 'Producto\n'}]
        },
        {
          'id': 'sub_prod_1',
          'position': {'dx': 100.0, 'dy': 180.0},
          'color': 0xFFBBDEFB,
          'size': {'width': 120.0, 'height': 40.0},
          'shape': 0,
          'level': 3,
          'text': [{'insert': 'Diseño UI\n'}]
        },

        // RAMA 2: MARKETING (Arriba Derecha - Naranja)
        {
          'id': 'cat_mkt',
          'position': {'dx': 750.0, 'dy': 250.0},
          'color': 0xFFFF9800,
          'size': {'width': 140.0, 'height': 50.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Marketing\n'}]
        },
        {
          'id': 'sub_mkt_1',
          'position': {'dx': 900.0, 'dy': 180.0},
          'color': 0xFFFFE0B2,
          'size': {'width': 120.0, 'height': 40.0},
          'shape': 0,
          'level': 3,
          'text': [{'insert': 'Redes Sociales\n'}]
        },

        // RAMA 3: FINANZAS (Abajo Izquierda - Verde)
        {
          'id': 'cat_fin',
          'position': {'dx': 250.0, 'dy': 550.0},
          'color': 0xFF4CAF50,
          'size': {'width': 140.0, 'height': 50.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Finanzas\n'}]
        },
        {
          'id': 'sub_fin_1',
          'position': {'dx': 100.0, 'dy': 620.0},
          'color': 0xFFC8E6C9,
          'size': {'width': 120.0, 'height': 40.0},
          'shape': 0,
          'level': 3,
          'text': [{'insert': 'Presupuesto\n'}]
        },

        // RAMA 4: EQUIPO (Abajo Derecha - Morado)
        {
          'id': 'cat_team',
          'position': {'dx': 750.0, 'dy': 550.0},
          'color': 0xFF9C27B0,
          'size': {'width': 140.0, 'height': 50.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Equipo\n'}]
        },
        {
          'id': 'sub_team_1',
          'position': {'dx': 900.0, 'dy': 620.0},
          'color': 0xFFE1BEE7,
          'size': {'width': 120.0, 'height': 40.0},
          'shape': 0,
          'level': 3,
          'text': [{'insert': 'Contratación\n'}]
        },
      ],
      edges: [
        // Conexiones principales
        {'fromId': 'b_root', 'toId': 'cat_prod'},
        {'fromId': 'b_root', 'toId': 'cat_mkt'},
        {'fromId': 'b_root', 'toId': 'cat_fin'},
        {'fromId': 'b_root', 'toId': 'cat_team'},
        // Conexiones de sub-nodos
        {'fromId': 'cat_prod', 'toId': 'sub_prod_1'},
        {'fromId': 'cat_mkt', 'toId': 'sub_mkt_1'},
        {'fromId': 'cat_fin', 'toId': 'sub_fin_1'},
        {'fromId': 'cat_team', 'toId': 'sub_team_1'},
      ],
    ),

    MindMapTemplate(
      name: 'Análisis FODA',
      description: 'Estructura estratégica centrada en pantalla.',
      nodes: [
        {
          'id': 'foda_root',
          'position': {'dx': 500.0, 'dy': 400.0},
          'color': 0xFFD8B4FE,
          'size': {'width': 120.0, 'height': 50.0},
          'shape': 2,
          'level': 1,
          'text': [{'insert': 'MI PROYECTO\n', 'attributes': {'bold': true}}]
        },
        {
          'id': 'f1',
          'position': {'dx': 300.0, 'dy': 250.0}, // Arriba Izquierda
          'color': 0xFF4CAF50,
          'size': {'width': 150.0, 'height': 50.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Fortalezas \n'}]
        },
        {
          'id': 'o1',
          'position': {'dx': 700.0, 'dy': 250.0}, // Arriba Derecha
          'color': 0xFF2196F3,
          'size': {'width': 150.0, 'height': 50.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Oportunidades \n'}]
        },
        {
          'id': 'd1',
          'position': {'dx': 300.0, 'dy': 550.0}, // Abajo Izquierda
          'color': 0xFFFF9800,
          'size': {'width': 150.0, 'height': 50.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Debilidades \n'}]
        },
        {
          'id': 'a1',
          'position': {'dx': 700.0, 'dy': 550.0}, // Abajo Derecha
          'color': 0xFFF44336,
          'size': {'width': 150.0, 'height': 50.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Amenazas \n'}]
        },
      ],
      edges: [
        {'fromId': 'foda_root', 'toId': 'f1'},
        {'fromId': 'foda_root', 'toId': 'o1'},
        {'fromId': 'foda_root', 'toId': 'd1'},
        {'fromId': 'foda_root', 'toId': 'a1'},
      ],
    ),

    MindMapTemplate(
      name: 'Mapa de Estudio',
      description: 'Estructura jerárquica para organizar conceptos académicos.',
      nodes: [
        {
          'id': 'estudio_root',
          'position': {'dx': 500.0, 'dy': 100.0}, // Arriba centro
          'color': 0xFF3F51B5, // Indigo
          'size': {'width': 180.0, 'height': 60.0},
          'shape': 2,
          'level': 1,
          'text': [{'insert': 'TEMA PRINCIPAL\n', 'attributes': {'bold': true}}]
        },
        {
          'id': 'con1',
          'position': {'dx': 300.0, 'dy': 250.0},
          'color': 0xFF00BCD4, // Cyan
          'size': {'width': 140.0, 'height': 50.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Concepto A\n'}]
        },
        {
          'id': 'con2',
          'position': {'dx': 700.0, 'dy': 250.0},
          'color': 0xFF00BCD4,
          'size': {'width': 140.0, 'height': 50.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Concepto B\n'}]
        },
        {
          'id': 'det1',
          'position': {'dx': 300.0, 'dy': 400.0},
          'color': 0xFFB2EBF2,
          'size': {'width': 120.0, 'height': 45.0},
          'shape': 0,
          'level': 3,
          'text': [{'insert': 'Detalle A.1\n'}]
        }
      ],
      edges: [
        {'fromId': 'estudio_root', 'toId': 'con1'},
        {'fromId': 'estudio_root', 'toId': 'con2'},
        {'fromId': 'con1', 'toId': 'det1'},
      ],
    ),


    MindMapTemplate(
      name: 'Flujo de Usuario',
      description: 'Diseña el camino que sigue un usuario en tu app.',
      nodes: [
        {
          'id': 'start',
          'position': {'dx': 100.0, 'dy': 400.0}, // Inicia a la izquierda
          'color': 0xFF4CAF50,
          'size': {'width': 130.0, 'height': 60.0},
          'shape': 2,
          'level': 1,
          'text': [{'insert': 'INICIO / LOGIN\n'}]
        },
        {
          'id': 'home',
          'position': {'dx': 350.0, 'dy': 400.0},
          'color': 0xFF2196F3,
          'size': {'width': 130.0, 'height': 60.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Pantalla Home\n'}]
        },
        {
          'id': 'action',
          'position': {'dx': 600.0, 'dy': 400.0},
          'color': 0xFFFFC107, // Amber (Decisión o Acción)
          'size': {'width': 130.0, 'height': 60.0},
          'shape': 1, // Diamond / Rhombus
          'level': 2,
          'text': [{'insert': '¿Compra?\n'}]
        },
        {
          'id': 'end',
          'position': {'dx': 850.0, 'dy': 400.0},
          'color': 0xFF9C27B0,
          'size': {'width': 130.0, 'height': 60.0},
          'shape': 2,
          'level': 3,
          'text': [{'insert': 'SUCCESS\n'}]
        }
      ],
      edges: [
        {'fromId': 'start', 'toId': 'home'},
        {'fromId': 'home', 'toId': 'action'},
        {'fromId': 'action', 'toId': 'end'},
      ],
    ),

    MindMapTemplate(
      name: 'Pequeño Modelo de Negocio',
      description: 'Propuesta de valor y segmentos de clientes.',
      nodes: [
        {
          'id': 'valor',
          'position': {'dx': 500.0, 'dy': 400.0},
          'color': 0xFFE91E63, // Pink
          'size': {'width': 180.0, 'height': 80.0},
          'shape': 0,
          'level': 1,
          'text': [{'insert': 'Propuesta de Valor\n', 'attributes': {'bold': true}}]
        },
        {
          'id': 'segmento',
          'position': {'dx': 800.0, 'dy': 400.0},
          'color': 0xFF009688, // Teal
          'size': {'width': 150.0, 'height': 70.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Segmentos de Clientes\n'}]
        },
        {
          'id': 'canales',
          'position': {'dx': 650.0, 'dy': 250.0},
          'color': 0xFFFF5722, // Deep Orange
          'size': {'width': 150.0, 'height': 60.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Canales\n'}]
        }
      ],
      edges: [
        {'fromId': 'valor', 'toId': 'segmento'},
        {'fromId': 'valor', 'toId': 'canales'},
      ],
    ),

    MindMapTemplate(
      name: 'Grande Modelo de Negocio',
      description: 'Estructura tipo Business Model Canvas con detalle estratégico.',
      nodes: [

        //  NODO CENTRAL
        {
          'id': 'modelo',
          'position': {'dx': 600.0, 'dy': 400.0},
          'color': 0xFF3F51B5,
          'size': {'width': 220.0, 'height': 90.0},
          'shape': 0,
          'level': 0,
          'text': [
            {'insert': 'MODELO DE NEGOCIO\n', 'attributes': {'bold': true}}
          ]
        },

        //  PROPUESTA DE VALOR
        {
          'id': 'valor',
          'position': {'dx': 600.0, 'dy': 250.0},
          'color': 0xFFE91E63,
          'size': {'width': 200.0, 'height': 80.0},
          'shape': 0,
          'level': 1,
          'text': [
            {'insert': 'Propuesta de Valor\n', 'attributes': {'bold': true}}
          ]
        },
        {
          'id': 'dolores',
          'position': {'dx': 450.0, 'dy': 180.0},
          'color': 0xFFF8BBD0,
          'size': {'width': 170.0, 'height': 60.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Solución de dolores\n'}]
        },
        {
          'id': 'beneficios',
          'position': {'dx': 750.0, 'dy': 180.0},
          'color': 0xFFF8BBD0,
          'size': {'width': 170.0, 'height': 60.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Generación de beneficios\n'}]
        },

        //  SEGMENTOS
        {
          'id': 'segmentos',
          'position': {'dx': 900.0, 'dy': 400.0},
          'color': 0xFF009688,
          'size': {'width': 200.0, 'height': 80.0},
          'shape': 0,
          'level': 1,
          'text': [
            {'insert': 'Segmentos de Clientes\n', 'attributes': {'bold': true}}
          ]
        },
        {
          'id': 'b2c',
          'position': {'dx': 1050.0, 'dy': 320.0},
          'color': 0xFFB2DFDB,
          'size': {'width': 150.0, 'height': 60.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'B2C\n'}]
        },
        {
          'id': 'b2b',
          'position': {'dx': 1050.0, 'dy': 480.0},
          'color': 0xFFB2DFDB,
          'size': {'width': 150.0, 'height': 60.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'B2B\n'}]
        },

        // CANALES
        {
          'id': 'canales',
          'position': {'dx': 350.0, 'dy': 400.0},
          'color': 0xFFFF9800,
          'size': {'width': 180.0, 'height': 70.0},
          'shape': 0,
          'level': 1,
          'text': [
            {'insert': 'Canales\n', 'attributes': {'bold': true}}
          ]
        },
        {
          'id': 'digital',
          'position': {'dx': 200.0, 'dy': 330.0},
          'color': 0xFFFFE0B2,
          'size': {'width': 150.0, 'height': 60.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Digital\n'}]
        },
        {
          'id': 'fisico',
          'position': {'dx': 200.0, 'dy': 470.0},
          'color': 0xFFFFE0B2,
          'size': {'width': 150.0, 'height': 60.0},
          'shape': 0,
          'level': 2,
          'text': [{'insert': 'Físico\n'}]
        },

        //  INGRESOS
        {
          'id': 'ingresos',
          'position': {'dx': 600.0, 'dy': 600.0},
          'color': 0xFF4CAF50,
          'size': {'width': 200.0, 'height': 80.0},
          'shape': 0,
          'level': 1,
          'text': [
            {'insert': 'Fuentes de Ingreso\n', 'attributes': {'bold': true}}
          ]
        },

        //  COSTOS
        {
          'id': 'costos',
          'position': {'dx': 350.0, 'dy': 600.0},
          'color': 0xFFF44336,
          'size': {'width': 200.0, 'height': 80.0},
          'shape': 0,
          'level': 1,
          'text': [
            {'insert': 'Estructura de Costos\n', 'attributes': {'bold': true}}
          ]
        },

        //  RECURSOS
        {
          'id': 'recursos',
          'position': {'dx': 900.0, 'dy': 600.0},
          'color': 0xFFFFC107,
          'size': {'width': 200.0, 'height': 80.0},
          'shape': 0,
          'level': 1,
          'text': [
            {'insert': 'Recursos Clave\n', 'attributes': {'bold': true}}
          ]
        },

      ],

      edges: [
        {'fromId': 'modelo', 'toId': 'valor'},
        {'fromId': 'modelo', 'toId': 'segmentos'},
        {'fromId': 'modelo', 'toId': 'canales'},
        {'fromId': 'modelo', 'toId': 'ingresos'},
        {'fromId': 'modelo', 'toId': 'costos'},
        {'fromId': 'modelo', 'toId': 'recursos'},

        {'fromId': 'valor', 'toId': 'dolores'},
        {'fromId': 'valor', 'toId': 'beneficios'},

        {'fromId': 'segmentos', 'toId': 'b2c'},
        {'fromId': 'segmentos', 'toId': 'b2b'},

        {'fromId': 'canales', 'toId': 'digital'},
        {'fromId': 'canales', 'toId': 'fisico'},
      ],
    ),

    
  ];
}