import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_providers.dart';
import '../../domain/repositories/membership_type_repository.dart';
import '../repositories/membership_type_repository_impl.dart';

final membershipTypeRepositoryProvider = Provider<MembershipTypeRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MembershipTypeRepositoryImpl(client);
});
