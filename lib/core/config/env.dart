import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Único punto de acceso a variables de entorno / credenciales.
/// Nada fuera de esta clase debe leer `dotenv.env[...]` directamente.
class Env {
  Env._();

  static String get supabaseUrl {
    final value = dotenv.env['SUPABASE_URL'];
    if (value == null || value.isEmpty) {
      throw StateError(
        'SUPABASE_URL no está definido. Copiá .env.example a .env '
        'y completá tus credenciales de Supabase.',
      );
    }
    return value;
  }

  static String get supabaseAnonKey {
    final value = dotenv.env['SUPABASE_ANON_KEY'];
    if (value == null || value.isEmpty) {
      throw StateError(
        'SUPABASE_ANON_KEY no está definido. Copiá .env.example a .env '
        'y completá tus credenciales de Supabase.',
      );
    }
    return value;
  }
}
