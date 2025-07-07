import 'package:flutter/material.dart';
import 'package:unidades_manager/core/app_colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unidades_manager/core/validators.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UnidadesList extends StatefulWidget {
  const UnidadesList({super.key});

  @override
  State<UnidadesList> createState() => _UnidadesListState();
}

class _UnidadesListState extends State<UnidadesList> {
  final List<Map<String, dynamic>> _unidades = [];
  final List<String> _tipos = ['Buseta', 'Por Puestos'];

  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _puestosController = TextEditingController();
  String _tipoSeleccionado = 'Buseta';
  final _anioController = TextEditingController();
  final _descripcionModeloController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _unidadesFiltradas = [];

  int? _indiceEdicion;
  String? _serverUrl;
  bool _cargando = false;

  // Lista de modelos obtenidos de la API
  List<Map<String, dynamic>> _modelosApi = [];
  String? _modeloSeleccionadoApi; // modelCode seleccionado
  String _descripcionModeloSeleccionado = '';

  File? _imagenSeleccionada;
  String? _imagenActualUrl;

  @override
  void initState() {
    super.initState();
    _inicializarPantalla();
  }

  Future<void> _inicializarPantalla() async {
    setState(() => _cargando = true);
    await _loadServerUrl();
    await _fetchModelosApi();
    await _fetchUnidades();
    setState(() => _cargando = false);
  }

  Future<void> _loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString('server_url');
  }

  Future<void> _fetchUnidades() async {
    if (_serverUrl == null) return;
    try {
      final url = Uri.parse(
        '$_serverUrl'
        'units',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Set<String> modelosApi = {};
        final Map<String, String> descripcionesModelosApi = {};
        setState(() {
          _unidades.clear();
          for (var unidad in data) {
            final modelCode = unidad['modelCode'] ?? '';
            final modelDesc =
                unidad['model'] != null
                    ? unidad['model']['description'] ?? ''
                    : '';
            _unidades.add({
              'placa': unidad['plate'] ?? '',
              'descripcion': unidad['description'] ?? '',
              'modelo': modelCode,
              'descripcionModelo': modelDesc,
              'puestos': unidad['seatCount'] ?? 0,
              'tipo': unidad['type'] ?? '',
              'anio': unidad['year'] ?? 0,
              'image': unidad['image'], // <-- Asegura que el campo image esté presente
            });
            if (modelCode.isNotEmpty) {
              modelosApi.add(modelCode);
              descripcionesModelosApi[modelCode] = modelDesc;
            }
          }
          _unidadesFiltradas = List.from(_unidades); // Inicializa filtradas
        });
      } else {
        developer.log(
          'Error al obtener unidades: \\${response.statusCode}',
          name: 'api_error',
        );
      }
    } catch (e) {
      developer.log('Error de red al obtener unidades: $e', name: 'api_error');
    }
  }

  void _filtrarUnidades(String query) {
    setState(() {
      _unidadesFiltradas =
          _unidades.where((unidad) {
            final placa = unidad['placa']?.toLowerCase() ?? '';
            final modelo = unidad['modelo']?.toLowerCase() ?? '';
            final descModelo = unidad['descripcionModelo']?.toLowerCase() ?? '';
            final filtro = query.toLowerCase();
            return placa.contains(filtro) ||
                modelo.contains(filtro) ||
                descModelo.contains(filtro);
          }).toList();
    });
  }

  Future<void> _fetchModelosApi() async {
    if (_serverUrl == null) return;
    try {
      // Asegurar que la URL termine con /
      String baseUrl = _serverUrl!;
      if (!baseUrl.endsWith('/')) baseUrl += '/';
      final url = Uri.parse('${baseUrl}models');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _modelosApi =
              data
                  .map<Map<String, dynamic>>(
                    (m) => {
                      'modelCode': m['modelCode'] ?? '',
                      'description': m['description'] ?? '',
                    },
                  )
                  .toList();
        });
      }
    } catch (e, stack) {
      developer.log('Error en _fetchModelosApi: $e\n$stack', name: 'api_error');
    }
  }

Future<void> _eliminarUnidadApi(String plate, int index) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar eliminación'),
      content: Text(
        '¿Está seguro que desea eliminar la unidad $plate?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Eliminar',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  if (confirmado != true) return;
  
  if (_serverUrl == null) return;
  
  setState(() => _cargando = true);
  try {
    final cleanPlate = plate.trim();
    final url = Uri.parse(
      '$_serverUrl'
      'units/$cleanPlate',
    );
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200 || response.statusCode == 204) {
      await _fetchUnidades();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unidad eliminada correctamente.')),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: \\${response.statusCode}'),
        ),
      );
    }
  } catch (e, stack) {
    developer.log(
      'Error en _eliminarUnidadApi: $e\n$stack',
      name: 'api_error',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de red al eliminar: $e')));
  } finally {
    if (mounted) {
      setState(() => _cargando = false);
    }
  }
}
  @override
  void dispose() {
    _placaController.dispose();
    _descripcionController.dispose();
    _puestosController.dispose();
    _anioController.dispose();
    _descripcionModeloController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _mostrarFormulario({
    Map<String, dynamic>? unidad,
    bool soloConsulta = false,
  }) async {
    // Cargar modelos ANTES de abrir el modal
    await _fetchModelosApi();

    // Configurar valores después de cargar
    if (_modelosApi.isNotEmpty) {
      if (unidad != null) {
        // usar el modelo que ya está registrado
        _modeloSeleccionadoApi = unidad['modelo'];
      } else {
        // dejar nulo para que muestre 'Seleccione un modelo'
        _modeloSeleccionadoApi = null;
      }
      // Obtener la descripción del modelo seleccionado
      _descripcionModeloSeleccionado =
          _modelosApi.firstWhere(
            (m) => m['modelCode'] == _modeloSeleccionadoApi,
            orElse: () => {'description': ''},
          )['description'] ??
          '';
      _descripcionModeloController.text = _descripcionModeloSeleccionado;
    }

    // Configurar controladores
    if (unidad != null) {
      _placaController.text = unidad['placa'];
      _descripcionController.text = unidad['descripcion'];
      _puestosController.text = unidad['puestos'].toString();
      _tipoSeleccionado =
          _tipos.contains(unidad['tipo']) ? unidad['tipo'] : _tipos.first;
      _anioController.text = unidad['anio'].toString();
      _indiceEdicion = _unidades.indexOf(unidad);
    } else {
      _indiceEdicion = null;
      _placaController.clear();
      _descripcionController.clear();
      _puestosController.clear();
      _anioController.clear();
    }

    // Imagen actual
    if (unidad != null && unidad['image'] != null && (unidad['image'] as String).isNotEmpty) {
      _imagenActualUrl = '${_serverUrl != null ? (_serverUrl!.endsWith('/') ? _serverUrl : '${_serverUrl!}/') : ''}images/${unidad['image']}';
    } else {
      _imagenActualUrl = null;
    }
    _imagenSeleccionada = null;

    // Verificar si el widget sigue montado antes de usar context
    if (!mounted) return;

    // abrir el modal
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
                    readOnly: soloConsulta || _indiceEdicion != null,
                    validator:
                        (value) =>
                            validatePlaca(value, soloConsulta: soloConsulta),
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
                    value: _modeloSeleccionadoApi,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Seleccione un modelo'),
                      ),
                      ..._modelosApi.map<DropdownMenuItem<String>>((modelo) {
                        return DropdownMenuItem<String>(
                          value: modelo['modelCode'] as String,
                          child: Text(
                            '${modelo['modelCode']} - ${modelo['description']}',
                          ),
                        );
                      }),
                    ],
                    onChanged:
                        (soloConsulta || _indiceEdicion != null)
                            ? null
                            : (value) {
                              setState(() {
                                _modeloSeleccionadoApi = value;
                                _descripcionModeloSeleccionado =
                                    _modelosApi.firstWhere(
                                      (m) => m['modelCode'] == value,
                                      orElse: () => {'description': ''},
                                    )['description'] ??
                                    '';
                                _descripcionModeloController.text =
                                    _descripcionModeloSeleccionado;
                              });
                            },
                    decoration: const InputDecoration(
                      labelText: 'Modelo',
                      border: OutlineInputBorder(),
                    ),
                    validator: validateModeloSeleccionado,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _descripcionModeloController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción del modelo',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debe seleccionar un modelo para ver la descripción';
                      }
                      return null;
                    },
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
                    validator:
                        (value) =>
                            validatePuestos(value, soloConsulta: soloConsulta),
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
                    validator:
                        (value) =>
                            validateAnio(value, soloConsulta: soloConsulta),
                  ),
                  // Imagen actual o seleccionada
                  if (_imagenSeleccionada != null)
                    Column(
                      children: [
                        Image.file(_imagenSeleccionada!, height: 120),
                        const SizedBox(height: 8),
                        if (!soloConsulta)
                          TextButton.icon(
                            icon: const Icon(Icons.delete),
                            label: const Text('Quitar imagen'),
                            onPressed: () {
                              setState(() {
                                _imagenSeleccionada = null;
                              });
                            },
                          ),
                      ],
                    )
                  else if (_imagenActualUrl != null)
                    Image.network(_imagenActualUrl!, height: 120)
                  else
                    const Icon(Icons.directions_bus, size: 80, color: AppColors.primary),
                  if (!soloConsulta) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Cámara'),
                          onPressed: _tomarFoto,
                        ),
                        const SizedBox(width: 10),
                        TextButton.icon(
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galería'),
                          onPressed: _seleccionarImagen,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 15),
                  // ...resto de los campos del formulario
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

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  void _agregarUnidad() async {
    if (_serverUrl == null) return;
    String? imageBase64;
    if (_imagenSeleccionada != null) {
      final bytes = await _imagenSeleccionada!.readAsBytes();
      imageBase64 = base64Encode(bytes);
    }
    final nuevaUnidad = {
      'plate': _placaController.text,
      'description': _descripcionController.text,
      'modelCode': _modeloSeleccionadoApi,
      'seatCount': int.parse(_puestosController.text),
      'type': _tipoSeleccionado,
      'year': int.parse(_anioController.text),
      if (imageBase64 != null) 'imageBase64': imageBase64,
    };
    final url = Uri.parse(
      '$_serverUrl'
      'units',
    );
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(nuevaUnidad),
      );
      developer.log('POST URL: $url', name: 'api_post');
      developer.log(
        'JSON enviado: \\${json.encode(nuevaUnidad)}',
        name: 'api_post',
      );
      developer.log('Status: \\${response.statusCode}', name: 'api_post');
      developer.log('Respuesta: \\${response.body}', name: 'api_post');
      if (response.statusCode == 201 || response.statusCode == 200) {
        await _fetchUnidades();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unidad agregada correctamente.')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar: \\${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de red al agregar: $e')));
    }
    _placaController.clear();
    _descripcionController.clear();
    _puestosController.clear();
    _anioController.clear();
    _imagenSeleccionada = null;
  }

  void _actualizarUnidad() async {
    if (_indiceEdicion != null) {
      String? imageBase64;
      if (_imagenSeleccionada != null) {
        final bytes = await _imagenSeleccionada!.readAsBytes();
        imageBase64 = base64Encode(bytes);
      }
      final unidadEditada = {
        'plate': _placaController.text,
        'description': _descripcionController.text,
        'modelCode': _modeloSeleccionadoApi,
        'seatCount': int.parse(_puestosController.text),
        'type': _tipoSeleccionado,
        'year': int.parse(_anioController.text),
        if (imageBase64 != null) 'imageBase64': imageBase64,
      };
      final plate = _placaController.text;
      final url = Uri.parse(
        '$_serverUrl'
        'units/$plate',
      );
      try {
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(unidadEditada),
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          await _fetchUnidades();
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al actualizar en la API: \\${response.statusCode}',
              ),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de red al actualizar: $e')),
        );
      }
    }
    _placaController.clear();
    _descripcionController.clear();
    _puestosController.clear();
    _anioController.clear();
    _indiceEdicion = null;
    _imagenSeleccionada = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Unidades'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppTextColors.inverseText,
      ),
      body:
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filtrarUnidades,
                      decoration: const InputDecoration(
                        labelText: 'Buscar por placa o modelo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        _unidadesFiltradas.isEmpty
                            ? Center(
                              child:
                                  _unidades.isEmpty
                                      ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                              color:
                                                  AppTextColors.secondaryText,
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
                                      )
                                      : Text(
                                        'No hay resultados',
                                        style: TextStyle(
                                          color: AppTextColors.disabledText,
                                        ),
                                      ),
                            )
                            : ListView.builder(
                              itemCount: _unidadesFiltradas.length,
                              itemBuilder: (context, index) {
                                final unidad = _unidadesFiltradas[index];
                                final descripcionModelo =
                                    _modelosApi.firstWhere(
                                      (m) => m['modelCode'] == unidad['modelo'],
                                      orElse: () => {'description': ''},
                                    )['description'] ??
                                    '';
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      _mostrarFormulario(
                                        unidad: unidad,
                                        soloConsulta: true,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          // Mostrar imagen si existe, si no el ícono por defecto
                                          (unidad['image'] != null && (unidad['image'] as String).isNotEmpty)
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  '${_serverUrl != null ? (_serverUrl!.endsWith('/') ? _serverUrl : '${_serverUrl!}/') : ''}images/${unidad['image']}',
                                                  width: 48,
                                                  height: 48,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                                    Icons.directions_bus,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              )
                                            : const Icon(
                                                Icons.directions_bus,
                                                color: AppColors.primary,
                                              ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                                if (descripcionModelo
                                                    .isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 4.0,
                                                        ),
                                                    child: Text(
                                                      descripcionModelo,
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
                                            itemBuilder: (
                                              BuildContext context,
                                            ) {
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
                                                _mostrarFormulario(
                                                  unidad: unidad,
                                                );
                                              } else if (value == 'eliminar') {
                                                _eliminarUnidadApi(
                                                  unidad['placa'],
                                                  index,
                                                );
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
                  ),
                ],
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
