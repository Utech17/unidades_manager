import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String? _ruta;
  String? _image64;
  String? _mensajeServer = 'En espera...';
  bool _loadingImage = false;
  bool _uploading = false;
  String? _serverUrl;

  @override
  void initState() {
    super.initState();
    _loadServerUrl();
  }

  Future<void> _loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverUrl = prefs.getString('server_url') ?? 'http://localhost:3000/api/v1/';
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() { _loadingImage = true; });
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source);
    setState(() { _loadingImage = false; });
    if (photo != null) {
      List<int> imageBytes = await File(photo.path).readAsBytes();
      String imageB64 = base64Encode(imageBytes);
      setState(() {
        _ruta = photo.path;
        _image64 = imageB64;
      });
    }
  }

  Future<void> _enviarImagen() async {
    if (_image64 == null || _serverUrl == null) return;
    setState(() { _uploading = true; _mensajeServer = 'Enviando...'; });
    try {
      final uri = Uri.parse('${_serverUrl}upload/base64');
      var data = {'imagen': _image64};
      var respuestaServer = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      setState(() {
        _mensajeServer = 'Respuesta: ${respuestaServer.body}';
      });
    } catch (e) {
      setState(() {
        _mensajeServer = 'Error al enviar: $e';
      });
    } finally {
      setState(() { _uploading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Captura de Imagen')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (_ruta == null)
                ? const Text('Ninguna Imagen Seleccionada...')
                : Image.file(File(_ruta!), height: 200),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  child: const Text("CÁMARA"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  child: const Text("GALERÍA"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            ElevatedButton(
              child: const Text("ENVIAR AL SERVIDOR"),
              onPressed: _uploading ? null : _enviarImagen,
            ),
            if (_loadingImage || _uploading)
              Container(
                child: CircularProgressIndicator(strokeWidth: 4.0),
                margin: EdgeInsets.symmetric(vertical: 10),
              ),
            Text(_mensajeServer ?? ''),
            Text('Uso Cámara/Galería, Flutter Julio 2025'),
          ],
        ),
      ),
    );
  }
}
