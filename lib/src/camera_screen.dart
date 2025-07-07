import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captura de Imagen')),
      body: const Center(
        child: Text('Funcionalidad de cámara retirada del proyecto.'),
      ),
    );
  }
}
