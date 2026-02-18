import 'package:flutter/material.dart';

class DialogHelper {
  // muestra un dialogo de confirmacion generico
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'ELIMINAR',
    String cancelText = 'CANCELAR',
    Color confirmColor = Colors.redAccent,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: confirmColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}