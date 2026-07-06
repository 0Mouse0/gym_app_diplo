import '../../domain/entities/membership_details.dart';

class MembershipsState {
  final bool isLoading;
  final List<MembershipDetails> memberships;
  final String? errorMessage;

  const MembershipsState({
    this.isLoading = false,
    this.memberships = const [],
    this.errorMessage,
  });

  const MembershipsState.initial()
      : isLoading = false,
        memberships = const [],
        errorMessage = null;

  MembershipsState copyWith({
    bool? isLoading,
    List<MembershipDetails>? memberships,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MembershipsState(
      isLoading: isLoading ?? this.isLoading,
      memberships: memberships ?? this.memberships,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
