import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/supabase/supabase_providers.dart';
import '../../domain/repositories/class_repository.dart';
import '../repositories/class_repository_impl.dart';

final classRepositoryProvider = Provider<ClassRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ClassRepositoryImpl(client);
});
