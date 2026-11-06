import 'dart:typed_data';

/// Archivo listo para enviarse en un formulario multipart.
class UploadFile {
  const UploadFile({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}
