import '../../domain/entities/enrollment_details.dart';

class EnrollmentsState {
  final bool isLoading;
  final List<EnrollmentDetails> enrollments;
  final String? errorMessage;

  const EnrollmentsState({
    this.isLoading = false,
    this.enrollments = const [],
    this.errorMessage,
  });

  const EnrollmentsState.initial()
      : isLoading = false,
        enrollments = const [],
        errorMessage = null;

  /// Cantidad de inscritos en una clase dada, calculado sobre lo ya
  /// cargado (evita otra consulta a Supabase para pintar la UI).
  int countForClass(String classId) =>
      enrollments.where((e) => e.enrollment.classId == classId).length;

  EnrollmentsState copyWith({
    bool? isLoading,
    List<EnrollmentDetails>? enrollments,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EnrollmentsState(
      isLoading: isLoading ?? this.isLoading,
      enrollments: enrollments ?? this.enrollments,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
