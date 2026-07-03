enum SupabaseConnectionState { checking, connected, error }

/// Estado inmutable que representa el resultado de probar la
/// conexión con Supabase.
class ConnectionStatus {
  final SupabaseConnectionState state;
  final String message;

  const ConnectionStatus({required this.state, required this.message});

  const ConnectionStatus.checking()
      : state = SupabaseConnectionState.checking,
        message = 'Verificando conexión con Supabase...';

  const ConnectionStatus.connected(String detail)
      : state = SupabaseConnectionState.connected,
        message = detail;

  const ConnectionStatus.error(String detail)
      : state = SupabaseConnectionState.error,
        message = detail;
}
