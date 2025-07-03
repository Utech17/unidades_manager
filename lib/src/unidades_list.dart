import 'package:flutter/material.dart';
import 'package:unidades_manager/core/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:unidades_manager/core/api_utils.dart';

class UnidadesList extends StatefulWidget {
  const UnidadesList({super.key});

  @override
  State<UnidadesList> createState() => _UnidadesListState();
}

class _UnidadesListState extends State<UnidadesList> {
  final List<Map<String, dynamic>> _unidades = [];
  final List<String> _modelos = [
    'WZZI3',
    'Mercedes Sprinter',
    'Ford Transit',
    'Nissan Civilian',
  ];
  final List<String> _tipos = ['Buseta', 'Por Puestos'];

  // Controladores para el formulario
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _modeloSeleccionado = 'WZZI3';
  final _puestosController = TextEditingController();
  String _tipoSeleccionado = 'Buseta';
  final _anioController = TextEditingController();
  final _descripcionModeloController = TextEditingController();

  int? _indiceEdicion;

  @override
  void dispose() {
    _placaController.dispose();
    _descripcionController.dispose();
    _puestosController.dispose();
    _anioController.dispose();
    _descripcionModeloController.dispose();
    super.dispose();
  }

  void _mostrarFormulario({
    Map<String, dynamic>? unidad,
    bool soloConsulta = false,
  }) {
    if (unidad != null) {
      _placaController.text = unidad['placa'];
      _descripcionController.text = unidad['descripcion'];
      _modeloSeleccionado = unidad['modelo'];
      _descripcionModeloController.text = unidad['descripcionModelo'] ?? '';
      _puestosController.text = unidad['puestos'].toString();
      _tipoSeleccionado = unidad['tipo'];
      _anioController.text = unidad['anio'].toString();
      _indiceEdicion = _unidades.indexOf(unidad);
    } else {
      _indiceEdicion = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    soloConsulta
                        ? 'Detalles de la Unidad'
                        : (unidad != null ? 'Editar Unidad' : 'Nueva Unidad'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _placaController,
                    decoration: const InputDecoration(
                      labelText: 'Placa',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: soloConsulta,
                    validator: (value) {
                      if (!soloConsulta && (value == null || value.isEmpty)) {
                        return 'Por favor ingrese la placa';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción General',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    readOnly: soloConsulta,
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _modeloSeleccionado,
                    items:
                        _modelos.map((modelo) {
                          return DropdownMenuItem(
                            value: modelo,
                            child: Text(modelo),
                          );
                        }).toList(),
                    onChanged:
                        soloConsulta
                            ? null
                            : (value) {
                              setState(() {
                                _modeloSeleccionado = value!;
                                _descripcionModeloController.clear();
                              });
                            },
                    decoration: const InputDecoration(
                      labelText: 'Modelo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _descripcionModeloController,
                    decoration: InputDecoration(
                      labelText: 'Descripción del Modelo',
                      border: const OutlineInputBorder(),
                      hintText:
                          soloConsulta
                              ? null
                              : 'Ingrese detalles específicos de este modelo',
                    ),
                    maxLines: 2,
                    readOnly: soloConsulta,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _puestosController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad de Puestos',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: soloConsulta,
                    validator: (value) {
                      if (!soloConsulta && (value == null || value.isEmpty)) {
                        return 'Por favor ingrese la cantidad';
                      }
                      if (!soloConsulta && int.tryParse(value!) == null) {
                        return 'Ingrese un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _tipoSeleccionado,
                    items:
                        _tipos.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          );
                        }).toList(),
                    onChanged:
                        soloConsulta
                            ? null
                            : (value) {
                              setState(() {
                                _tipoSeleccionado = value!;
                              });
                            },
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _anioController,
                    decoration: const InputDecoration(
                      labelText: 'Año',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    readOnly: soloConsulta,
                    validator: (value) {
                      if (!soloConsulta && (value == null || value.isEmpty)) {
                        return 'Por favor ingrese el año';
                      }
                      if (!soloConsulta && int.tryParse(value!) == null) {
                        return 'Ingrese un año válido';
                      }
                      return null;
                    },
                  ),
                  if (!soloConsulta) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: AppTextColors.inverseText),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (_indiceEdicion != null) {
                                _actualizarUnidad();
                              } else {
                                _agregarUnidad();
                              }
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Guardar',
                            style: TextStyle(color: AppTextColors.inverseText),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _agregarUnidad() {
    setState(() {
      _unidades.add({
        'placa': _placaController.text,
        'descripcion': _descripcionController.text,
        'modelo': _modeloSeleccionado,
        'descripcionModelo': _descripcionModeloController.text,
        'puestos': int.parse(_puestosController.text),
        'tipo': _tipoSeleccionado,
        'anio': int.parse(_anioController.text),
      });
    });

    // Limpiar los controladores
    _placaController.clear();
    _descripcionController.clear();
    _puestosController.clear();
    _anioController.clear();
    _descripcionModeloController.clear();
  }

  void _actualizarUnidad() async {
    if (_indiceEdicion != null) {
      final unidadEditada = {
        'plate': _placaController.text,
        'description': _descripcionController.text,
        'modelCode': _modeloSeleccionado,
        'seatCount': int.parse(_puestosController.text),
        'type': _tipoSeleccionado,
        'year': int.parse(_anioController.text),
      };
      final plate = _placaController.text;
      final baseUrl = await getBaseUrl();
      final url = Uri.parse('$baseUrl$plate');
      try {
        print(json.encode(unidadEditada));
        print(url.toString());
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(unidadEditada),
        );
        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');
        if (response.statusCode == 200 || response.statusCode == 204) {
          setState(() {
            _unidades[_indiceEdicion!] = {
              'placa': _placaController.text,
              'descripcion': _descripcionController.text,
              'modelo': _modeloSeleccionado,
              'descripcionModelo': _descripcionModeloController.text,
              'puestos': int.parse(_puestosController.text),
              'tipo': _tipoSeleccionado,
              'anio': int.parse(_anioController.text),
            };
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al actualizar en la API: ${response.statusCode}',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de red al actualizar: $e')),
        );
      }
    }
    // Limpiar los controladores
    _placaController.clear();
    _descripcionController.clear();
    _puestosController.clear();
    _anioController.clear();
    _descripcionModeloController.clear();
    _indiceEdicion = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Unidades'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppTextColors.inverseText,
      ),
      body:
          _unidades.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.directions_bus,
                      size: 60,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No hay unidades registradas',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTextColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Presione el botón + para agregar una nueva',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTextColors.disabledText,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _unidades.length,
                itemBuilder: (context, index) {
                  final unidad = _unidades[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: InkWell(
                      onTap: () {
                        _mostrarFormulario(unidad: unidad, soloConsulta: true);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.directions_bus,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    unidad['placa'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${unidad['modelo']} - ${unidad['tipo']}',
                                  ),
                                  if (unidad['descripcionModelo'] != null &&
                                      unidad['descripcionModelo'].isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        unidad['descripcionModelo'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text('${unidad['puestos']} puestos'),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem<String>(
                                    value: 'modificar',
                                    child: Text('Modificar'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'eliminar',
                                    child: Text('Eliminar'),
                                  ),
                                ];
                              },
                              onSelected: (String value) {
                                if (value == 'modificar') {
                                  _mostrarFormulario(unidad: unidad);
                                } else if (value == 'eliminar') {}
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormulario,
        backgroundColor: AppColors.primary,
        foregroundColor: AppTextColors.inverseText,
        child: const Icon(Icons.add),
      ),
    );
  }
}
