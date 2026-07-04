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

  /// Publishable (anon) key del proyecto. Acepta tanto la key legacy
  /// "anon key" como la nueva "sb_publishable_..." — ambas van en el
  /// mismo campo de Supabase.initialize().
  static String get supabasePublishableKey {
    final value = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];
    if (value == null || value.isEmpty) {
      throw StateError(
        'SUPABASE_PUBLISHABLE_KEY no está definido. Copiá .env.example a .env '
        'y completá tus credenciales de Supabase.',
      );
    }
    return value;
  }
}
