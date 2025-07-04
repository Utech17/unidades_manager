// Validador para el campo de placa: solo letras y números
String? validatePlaca(String? value, {bool soloConsulta = false}) {
  if (!soloConsulta && (value == null || value.isEmpty)) {
    return 'Por favor ingrese la placa';
  }
  if (!soloConsulta && !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value!)) {
    return 'La placa solo debe contener letras y números';
  }
  return null;
}

// Validador para el campo de modelo seleccionado
String? validateModeloSeleccionado(String? value) {
  if (value == null || value.isEmpty) {
    return 'Debe seleccionar un modelo';
  }
  return null;
}

// Validador para el campo de puestos (máximo 100)
String? validatePuestos(String? value, {bool soloConsulta = false}) {
  if (!soloConsulta && (value == null || value.isEmpty)) {
    return 'Por favor ingrese la cantidad';
  }
  if (!soloConsulta) {
    final n = int.tryParse(value!);
    if (n == null) {
      return 'Ingrese un número válido';
    }
    if (n > 100) {
      return 'La cantidad no puede ser mayor a 100';
    }
    if (n < 1) {
      return 'La cantidad debe ser mayor a 0';
    }
  }
  return null;
}

// Validador para el campo de año (entre 1900 y el año actual)
String? validateAnio(String? value, {bool soloConsulta = false}) {
  if (!soloConsulta && (value == null || value.isEmpty)) {
    return 'Por favor ingrese el año';
  }
  if (!soloConsulta) {
    final n = int.tryParse(value!);
    final currentYear = DateTime.now().year;
    if (n == null) {
      return 'Ingrese un año válido';
    }
    if (n < 1900) {
      return 'El año no puede ser menor a 1900';
    }
    if (n > currentYear) {
      return 'El año no puede ser mayor al año actual ($currentYear)';
    }
  }
  return null;
}
