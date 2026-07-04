/// Nombrado "App..." a propósito: Flutter ya define un `ConnectionState`
/// propio (el que se usa con StreamBuilder/FutureBuilder/AsyncSnapshot,
/// exportado desde material.dart). Si lo llamábamos igual, cualquier
/// archivo que importe material.dart y este provider a la vez tiene un
/// import ambiguo y no compila.
enum AppConnectionState { checking, connected, error }

/// Estado inmutable que representa el resultado de probar la
/// conexión con Supabase.
class ConnectionStatus {
  final AppConnectionState state;
  final String message;

  const ConnectionStatus({required this.state, required this.message});

  const ConnectionStatus.checking()
      : state = AppConnectionState.checking,
        message = 'Verificando conexión con Supabase...';

  const ConnectionStatus.connected(String detail)
      : state = AppConnectionState.connected,
        message = detail;

  const ConnectionStatus.error(String detail)
      : state = AppConnectionState.error,
        message = detail;
}
