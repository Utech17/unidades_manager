import 'package:flutter/material.dart';
import 'package:unidades_manager/core/app_colors.dart';

class UnidadesList extends StatefulWidget {
  const UnidadesList({super.key});

  @override
  State<UnidadesList> createState() => _UnidadesListState();
}

class _UnidadesListState extends State<UnidadesList> {
  List<Map<String, dynamic>> _unidades = [];
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

  // Variables para controlar edición
  int? _unidadEditandoIndex;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarUnidadesIniciales();
  }

  // Simular carga inicial de datos (reemplazar con API luego)
  void _cargarUnidadesIniciales() async {
    setState(() => _cargando = true);
    // TODO: Reemplazar con llamada a API
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _unidades = [
        {
          'placa': 'ABC123',
          'descripcion': 'Unidad de transporte escolar',
          'modelo': 'Toyota Coaster',
          'descripcionModelo': 'Modelo 2020, color blanco',
          'puestos': 24,
          'tipo': 'Buseta',
          'anio': 2020,
        },
        {
          'placa': 'XYZ789',
          'descripcion': 'Transporte ejecutivo',
          'modelo': 'Mercedes Sprinter',
          'descripcionModelo': 'Asientos de cuero, WiFi',
          'puestos': 12,
          'tipo': 'Por Puestos',
          'anio': 2021,
        }
      ];
      _cargando = false;
    });
  }

  @override
  void dispose() {
    _placaController.dispose();
    _descripcionController.dispose();
    _puestosController.dispose();
    _anioController.dispose();
    _descripcionModeloController.dispose();
    super.dispose();
  }

  void _mostrarFormulario({Map<String, dynamic>? unidad, bool soloConsulta = false, int? index}) {
    if (unidad != null) {
      _placaController.text = unidad['placa'];
      _descripcionController.text = unidad['descripcion'];
      _modeloSeleccionado = unidad['modelo'];
      _descripcionModeloController.text = unidad['descripcionModelo'] ?? '';
      _puestosController.text = unidad['puestos'].toString();
      _tipoSeleccionado = unidad['tipo'];
      _anioController.text = unidad['anio'].toString();
      _unidadEditandoIndex = index;
    } else {
      _unidadEditandoIndex = null;
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
                      : _unidadEditandoIndex != null 
                        ? 'Editar Unidad' 
                        : 'Nueva Unidad',
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
                    items: _modelos.map((modelo) {
                      return DropdownMenuItem(
                        value: modelo,
                        child: Text(modelo),
                      );
                    }).toList(),
                    onChanged: soloConsulta
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
                      labelText: 'Descripción del ${_modeloSeleccionado}',
                      border: const OutlineInputBorder(),
                      hintText: soloConsulta
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
                    items: _tipos.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo),
                      );
                    }).toList(),
                    onChanged: soloConsulta ? null : (value) {
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
                          child: const Text('Cancelar', 
                              style: TextStyle(color: AppTextColors.inverseText)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _guardarUnidad();
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            _unidadEditandoIndex != null ? 'Actualizar' : 'Guardar',
                            style: const TextStyle(color: AppTextColors.inverseText),
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

  Future<void> _guardarUnidad() async {
    final nuevaUnidad = {
      'placa': _placaController.text,
      'descripcion': _descripcionController.text,
      'modelo': _modeloSeleccionado,
      'descripcionModelo': _descripcionModeloController.text,
      'puestos': int.parse(_puestosController.text),
      'tipo': _tipoSeleccionado,
      'anio': int.parse(_anioController.text),
    };

    setState(() => _cargando = true);
    
    try {
      if (_unidadEditandoIndex != null) {
        // Actualizar unidad existente
        // TODO: Reemplazar con llamada a API
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _unidades[_unidadEditandoIndex!] = nuevaUnidad;
        });
      } else {
        // Agregar nueva unidad
        // TODO: Reemplazar con llamada a API
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _unidades.add(nuevaUnidad);
        });
      }
    } catch (e) {
      // TODO: Manejar errores de API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _cargando = false);
      _limpiarFormulario();
    }
  }

  Future<void> _eliminarUnidad(int index) async {
    final unidad = _unidades[index];
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro que desea eliminar la unidad ${unidad['placa']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      setState(() => _cargando = true);
      try {
        // TODO: Reemplazar con llamada a API
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _unidades.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unidad eliminada correctamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      } finally {
        setState(() => _cargando = false);
      }
    }
  }

  void _limpiarFormulario() {
    _placaController.clear();
    _descripcionController.clear();
    _puestosController.clear();
    _anioController.clear();
    _descripcionModeloController.clear();
    _unidadEditandoIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Unidades'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppTextColors.inverseText,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _unidades.isEmpty
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
                      child: InkWell(
                        onTap: () {
                          _mostrarFormulario(unidad: unidad, soloConsulta: true, index: index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.directions_bus, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(unidad['placa'], 
                                        style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('${unidad['modelo']} - ${unidad['tipo']}'),
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
                                      child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    ),
                                  ];
                                },
                                onSelected: (String value) {
                                  if (value == 'modificar') {
                                    _mostrarFormulario(unidad: unidad, index: index);
                                  } else if (value == 'eliminar') {
                                    _eliminarUnidad(index);
                                  }
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
        onPressed: () => _mostrarFormulario(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppTextColors.inverseText,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// TODO: Implementar estas funciones cuando tengas la API
/*
Future<List<Map<String, dynamic>>> _obtenerUnidadesDeAPI() async {
  // Implementar llamada a API para obtener unidades
}

Future<Map<String, dynamic>> _crearUnidadEnAPI(Map<String, dynamic> unidad) async {
  // Implementar llamada a API para crear
}

Future<Map<String, dynamic>> _actualizarUnidadEnAPI(Map<String, dynamic> unidad) async {
  // Implementar llamada a API para actualizar
}

Future<bool> _eliminarUnidadEnAPI(String id) async {
  // Implementar llamada a API para eliminar
}
*/