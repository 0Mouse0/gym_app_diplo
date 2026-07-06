import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_providers.dart';
import '../../domain/repositories/membership_repository.dart';
import '../repositories/membership_repository_impl.dart';

final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return MembershipRepositoryImpl(client);
});
