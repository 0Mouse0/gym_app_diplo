import '../../domain/entities/membership_type.dart';

class MembershipTypesState {
  final bool isLoading;
  final List<MembershipType> types;
  final String? errorMessage;

  const MembershipTypesState({
    this.isLoading = false,
    this.types = const [],
    this.errorMessage,
  });

  const MembershipTypesState.initial()
      : isLoading = false,
        types = const [],
        errorMessage = null;

  MembershipTypesState copyWith({
    bool? isLoading,
    List<MembershipType>? types,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MembershipTypesState(
      isLoading: isLoading ?? this.isLoading,
      types: types ?? this.types,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
