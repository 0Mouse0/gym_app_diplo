import '../../domain/entities/gym_class.dart';

class ClassesState {
  final bool isLoading;
  final List<GymClass> classes;
  final String? errorMessage;

  const ClassesState({
    this.isLoading = false,
    this.classes = const [],
    this.errorMessage,
  });

  const ClassesState.initial()
      : isLoading = false,
        classes = const [],
        errorMessage = null;

  ClassesState copyWith({
    bool? isLoading,
    List<GymClass>? classes,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ClassesState(
      isLoading: isLoading ?? this.isLoading,
      classes: classes ?? this.classes,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
