/// Excepción de dominio para errores que ocurren en un repositorio.
///
/// Los repositorios (capa data) traducen las excepciones específicas
/// de Supabase (PostgrestException, etc.) a esta clase, con un
/// mensaje ya pensado para mostrarse al usuario. Así, el resto de la
/// app (controllers, widgets) no necesita saber nada sobre Supabase.
class RepositoryException implements Exception {
  final String message;

  const RepositoryException(this.message);

  @override
  String toString() => message;
}
