import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider único del SupabaseClient.
///
/// Regla del proyecto: ningún repositorio llama a
/// `Supabase.instance.client` directamente. Todos dependen de este
/// provider, así el acceso remoto queda desacoplado y es fácil de
/// reemplazar/mockear en tests.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
