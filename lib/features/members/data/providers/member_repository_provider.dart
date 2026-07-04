import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_providers.dart';
import '../../domain/repositories/member_repository.dart';
import '../repositories/member_repository_impl.dart';

/// Expone el repositorio a través de su interfaz (MemberRepository),
/// no de su implementación concreta. La presentación y los futuros
/// servicios de negocio dependen de este provider, nunca de
/// MemberRepositoryImpl directamente.
final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MemberRepositoryImpl(client);
});
