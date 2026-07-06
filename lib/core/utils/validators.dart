/// Validadores para formularios. Se centralizan acá para que ningún
/// widget tenga su propia lógica de validación suelta, y para poder
/// reutilizarlos en todos los formularios de la app (Miembros,
/// Membresías, Clases, etc.).
class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
  static final _phoneRegex = RegExp(r'^[0-9+\-\s()]{6,20}$');

  static String? required(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  /// Válido si está vacío (campo opcional) o si tiene formato de email.
  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Ingresá un email válido';
    }
    return null;
  }

  /// Válido si está vacío (campo opcional) o si parece un teléfono.
  static String? optionalPhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Ingresá un teléfono válido';
    }
    return null;
  }

  static String? minLength(String? value, int min, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().length < min) {
      return '$fieldName debe tener al menos $min caracteres';
    }
    return null;
  }

  static String? positiveInteger(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return '$fieldName debe ser un número entero mayor a 0';
    }
    return null;
  }

  static String? positiveDecimal(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) {
      return '$fieldName debe ser un número mayor a 0';
    }
    return null;
  }
}
