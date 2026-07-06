import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../classes/data/providers/class_repository_provider.dart';
import '../../../members/data/providers/member_repository_provider.dart';
import '../../../memberships/data/providers/membership_repository_provider.dart';
import '../../data/providers/enrollment_repository_provider.dart';
import 'enrollment_rules_service.dart';

final enrollmentRulesServiceProvider = Provider<EnrollmentRulesService>((ref) {
  final memberRepository = ref.watch(memberRepositoryProvider);
  final membershipRepository = ref.watch(membershipRepositoryProvider);
  final classRepository = ref.watch(classRepositoryProvider);
  final enrollmentRepository = ref.watch(enrollmentRepositoryProvider);
  return EnrollmentRulesService(
    memberRepository,
    membershipRepository,
    classRepository,
    enrollmentRepository,
  );
});
