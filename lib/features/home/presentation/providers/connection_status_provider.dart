import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_providers.dart';
import 'connection_status.dart';

/// Prueba la conexión contra el proyecto de Supabase.
///
/// No depende de que exista ninguna tabla todavía: si el servidor
/// responde (aunque sea con un error de "la tabla no existe"),
/// significa que la URL y la ANON KEY son correctas. Si en cambio
/// falla la resolución de red, las credenciales están mal.
class ConnectionStatusNotifier extends StateNotifier<ConnectionStatus> {
  final SupabaseClient _client;

  ConnectionStatusNotifier(this._client) : super(const ConnectionStatus.checking()) {
    checkConnection();
  }

  Future<void> checkConnection() async {
    state = const ConnectionStatus.checking();
    try {
      await _client.from('_conexion_probe').select().limit(1);
      state = const ConnectionStatus.connected(
        'Conectado a Supabase correctamente.',
      );
    } on PostgrestException catch (e) {
      // El servidor respondió con un error estructurado (p. ej. tabla
      // inexistente): la conexión y las credenciales son válidas.
      state = ConnectionStatus.connected(
        'Conectado a Supabase (respuesta del servidor: ${e.code ?? 'ok'}).',
      );
    } catch (_) {
      state = const ConnectionStatus.error(
        'No se pudo conectar. Revisá SUPABASE_URL y SUPABASE_ANON_KEY en tu .env',
      );
    }
  }
}

final connectionStatusProvider =
    StateNotifierProvider<ConnectionStatusNotifier, ConnectionStatus>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ConnectionStatusNotifier(client);
});
