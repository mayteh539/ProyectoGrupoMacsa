class Validators {
  Validators._();

  static String? required(String? value, [String field = 'Este campo']) {
    if (value == null || value.trim().isEmpty) return '$field es obligatorio';
    return null;
  }

  static String? minLength(String? value, int length, [String field = 'Este campo']) {
    if (value == null || value.trim().length < length) {
      return '$field debe tener al menos $length caracteres';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!regex.hasMatch(value.trim())) return 'Correo invalido';
    return null;
  }
}
