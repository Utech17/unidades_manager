import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String? _savedUrl;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedUrl =
          prefs.getString('server_url') ??
          'https://api-unidades-manager.onrender.com/api/v1/';
      _controller.text = _savedUrl!;
    });
  }

  Future<void> _saveUrl() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_url', _controller.text);
      setState(() {
        _savedUrl = _controller.text;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dirección guardada correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configuración de Servidor')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Dirección base de la API:', style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Ej: https://api-unidades-manager.onrender.com/api/v1/',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la dirección de la API';
                  }
                  if (!value.endsWith('/')) {
                    return 'Debe terminar con /';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text('Guardar'),
                onPressed: _saveUrl,
              ),
              if (_savedUrl != null) ...[
                SizedBox(height: 24),
                Text(
                  'Actual: $_savedUrl',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
