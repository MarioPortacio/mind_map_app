import 'package:flutter/material.dart';
import 'mind_map_page.dart';
import '../../core/canvas/templates/templates_screen.dart';
import './state/mind_map_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,   
          end: Alignment.bottomCenter, 
          colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade500],
        ),
      ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hub, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Mind Map App',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 50),
            _menuButton(
              context,
              'Crear nuevo mapa',
              Icons.add_circle_outline,
              () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const MindMapPage())
              ),
            ),
            _menuButton(
              context,
              'Plantillas',
              Icons.auto_awesome_motion,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TemplatesScreen()),
                );
              },
            ),
            _menuButton(
              context,
              'Importar mapa .mind',
              Icons.file_upload_outlined,
              () async {
                // creamos un controlador temporal para hacer la importación
                final tempController = MindMapController();
                
                // ejecutamos la importación
                await tempController.importFromJson();

                // verificamos si realmente se cargó un archivo (viendo si tiene nodos)
                if (tempController.nodes.isNotEmpty) {
                  if (!context.mounted) return; // verificación de seguridad para navegación

                  

                  // navega a la página del mapa pasando el controlador con los datos
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MindMapPage(initialController: tempController),
                    ),
                  );
                }
           

              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ignore: unused_element showtoast para el futuro
  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}