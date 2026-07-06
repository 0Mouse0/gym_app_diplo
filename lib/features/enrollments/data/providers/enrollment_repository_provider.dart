import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_providers.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../repositories/enrollment_repository_impl.dart';

final enrollmentRepositoryProvider = Provider<EnrollmentRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return EnrollmentRepositoryImpl(client);
});
