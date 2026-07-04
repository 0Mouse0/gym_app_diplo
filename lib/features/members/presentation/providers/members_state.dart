import '../../domain/entities/member.dart';

class MembersState {
  final bool isLoading;
  final List<Member> members;
  final String? errorMessage;

  const MembersState({
    this.isLoading = false,
    this.members = const [],
    this.errorMessage,
  });

  const MembersState.initial()
      : isLoading = false,
        members = const [],
        errorMessage = null;

  MembersState copyWith({
    bool? isLoading,
    List<Member>? members,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MembersState(
      isLoading: isLoading ?? this.isLoading,
      members: members ?? this.members,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
