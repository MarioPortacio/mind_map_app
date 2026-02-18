# 🕸️ MindMapApp

Una solución para la creación de mapas mentales en Flutter. Organiza tus ideas en un canvas, personaliza cada detalle y exporta tus proyectos con facilidad.

![Home de la App](https://github.com/MarioPortacio/mind_map_app/blob/f67bf7b7c69f77d54122208dbda4051286b019ba/home_page.png)

![Plantillas de la App](https://github.com/MarioPortacio/mind_map_app/blob/f67bf7b7c69f77d54122208dbda4051286b019ba/templates_page.png)

![Panel de edición de la App](https://github.com/MarioPortacio/mind_map_app/blob/f67bf7b7c69f77d54122208dbda4051286b019ba/editing.png)

## 🎯 Características

* **Canvas ($8000 \times 8000$):** Espacio de trabajo masivo con soporte nativo para gestos de *pan* (desplazamiento) y *zoom* de alta precisión.
* **Edición de Texto Enriquecido:** Cada nodo integra un editor completo que soporta negritas, cursivas, alineación y listas.
* **Gestión de Relaciones:** Sistema dinámico para crear vínculos visuales entre ideas.
* **Panel de Estilo Avanzado:** Personalización en tiempo real de la geometría del nodo (forma, tamaño, color y nivel jerárquico).
* **Indicador de Integridad de Archivo:** Sistema de detección de cambios que muestra un asterisco (`*`) en el nombre del archivo si hay progreso sin guardar.
* **Seguridad de Datos:** Diálogos de confirmación inteligentes que protegen al usuario de perder cambios.
* **Exportación Multi-formato:** Salida directa a **PDF** (vectorial), **PNG** (rasterizado de alta calidad) y formato nativo `.mind` (JSON).



## 🛠️ Tecnologías Utilizadas

La aplicación aprovecha las capacidades del ecosistema Flutter para garantizar fluidez y estabilidad:

* **Flutter (Dart):** Framework principal para la interfaz de usuario y lógica de negocio.
* **Flutter Quill:** Motor de edición de texto enriquecido dentro de los nodos.
* **Vector Math:** Utilizado para las transformaciones de matrices necesarias en el zoom y la conversión de coordenadas pantalla-mundo.
* **Shared Preferences:** Persistencia local para guardar configuraciones del usuario, como el color del canvas y el estado de la ayuda.
* **Screenshot & PDF:** Librerías encargadas de procesar el renderizado del canvas para la generación de archivos externos.
* **File Picker:** Integración con el sistema de archivos nativo para la carga y guardado de proyectos.



## 🔧 Instalación

1. Clona este repositorio:
   ```bash
   git clone https://github.com/MarioPortacio/mind_map_app.git



2. Instala las dependencias necesarias:
   ```bash
   flutter pub get

3. Ejecuta la aplicación
   ```bash
   flutter run



## 📈 Posibles Mejoras Futuras

* **Colaboración en Tiempo Real:** Integración con Firebase o WebSockets para que varios usuarios editen el mismo mapa simultáneamente.
* **Nodos Multimedia:** Capacidad para insertar imágenes, videos o enlaces directos de YouTube dentro de los nodos.
* **Modo Presentación:** Herramienta para navegar entre nodos de forma secuencial, ideal para exposiciones.
* **Sincronización en la Nube:** Backup automático de proyectos en Google Drive o Dropbox.
* **Auto-Layout:** Algoritmos de ordenamiento automático para organizar mapas caóticos con un solo clic.
* **Más editabilidad:** Adición de herramientas para modificar visualmente los nodos y las conexiones entre estos, incluyendo implementación de multiple selección de nodos o conexiones.
