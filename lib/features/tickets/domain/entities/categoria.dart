class Categoria {
  const Categoria({
    required this.idCategoria,
    required this.nombreCategoria,
    required this.activo,
    this.descripcion,
  });

  final int idCategoria;
  final String nombreCategoria;
  final String? descripcion;
  final bool activo;
}
