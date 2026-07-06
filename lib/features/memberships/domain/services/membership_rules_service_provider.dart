import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../members/data/providers/member_repository_provider.dart';
import '../../data/providers/membership_repository_provider.dart';
import 'membership_rules_service.dart';

final membershipRulesServiceProvider = Provider<MembershipRulesService>((ref) {
  final memberRepository = ref.watch(memberRepositoryProvider);
  final membershipRepository = ref.watch(membershipRepositoryProvider);
  return MembershipRulesService(memberRepository, membershipRepository);
});
