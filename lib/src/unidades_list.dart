import 'package:flutter/material.dart';
import 'package:unidades_manager/core/app_colors.dart';

class UnidadesList extends StatefulWidget {
  const UnidadesList({super.key});

  @override
  State<UnidadesList> createState() => _UnidadesListState();
}

class _UnidadesListState extends State<UnidadesList> {
  final List<Map<String, dynamic>> _unidades = [];
  final List<String> _modelos = [
    'Toyota Coaster',
    'Mercedes Sprinter',
    'Ford Transit',
    'Nissan Civilian'
  ];
  final List<String> _tipos = ['Buseta', 'Por Puestos'];

  // Controladores para el formulario
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _modeloSeleccionado = 'Toyota Coaster';
  final _puestosController = TextEditingController();
  String _tipoSeleccionado = 'Buseta';
  final _anioController = TextEditingController();
  final _descripcionModeloController = TextEditingController();

  @override
  void dispose() {
    _placaController.dispose();
    _descripcionController.dispose();
    _puestosController.dispose();
    _anioController.dispose();
    _descripcionModeloController.dispose();
    super.dispose();
  }

  void _mostrarFormulario() {
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
                  const Text(
                    'Nueva Unidad',
                    style: TextStyle(
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
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
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _modeloSeleccionado,
                    items: _modelos.map((modelo) {
                      return DropdownMenuItem(
                        value: modelo,
                        child: Text(modelo),
                      );
                    }).toList(),
                    onChanged: (value) {
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
                      labelText: 'Descripción del modelo',
                      border: const OutlineInputBorder(),
                      hintText: 'Ingrese detalles específicos de este modelo',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _puestosController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad de Puestos',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la cantidad';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _tipoSeleccionado,
                    items: _tipos.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo),
                      );
                    }).toList(),
                    onChanged: (value) {
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el año';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingrese un año válido';
                      }
                      return null;
                    },
                  ),
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
                        child: const Text('Cancelar', style: TextStyle(color: AppTextColors.inverseText)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _agregarUnidad();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Guardar', style: TextStyle(color: AppTextColors.inverseText)),
                      ),
                    ],
                  ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Unidades'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppTextColors.inverseText,
      ),
      body: _unidades.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_bus, size: 60, color: AppColors.secondary),
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
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.directions_bus, color: AppColors.primary),
                    title: Text(unidad['placa'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${unidad['modelo']} - ${unidad['tipo']}'),
                        if (unidad['descripcionModelo'] != null && unidad['descripcionModelo'].isNotEmpty)
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
                    trailing: Text('${unidad['puestos']} puestos'),
                    onTap: () {
                    },
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