import '../../../../core/errors/repository_exception.dart';
import '../../../classes/domain/repositories/class_repository.dart';
import '../../../members/domain/repositories/member_repository.dart';
import '../../../memberships/domain/repositories/membership_repository.dart';
import '../repositories/enrollment_repository.dart';

/// Reglas de negocio para inscribir a un miembro a una clase.
///
/// Este es el servicio que junta las dos validaciones centrales de
/// la rúbrica:
/// 1. No inscribir si la clase ya alcanzó su cupo.
/// 2. No inscribir si la membresía del miembro está vencida o inactiva.
///
/// Cruza cuatro repositorios (Miembros, Membresías, Clases,
/// Inscripciones) — exactamente el caso de "regla que no pertenece a
/// ningún repositorio individual" que amerita un servicio aparte.
class EnrollmentRulesService {
  final MemberRepository _memberRepository;
  final MembershipRepository _membershipRepository;
  final ClassRepository _classRepository;
  final EnrollmentRepository _enrollmentRepository;

  EnrollmentRulesService(
    this._memberRepository,
    this._membershipRepository,
    this._classRepository,
    this._enrollmentRepository,
  );

  /// Lanza [RepositoryException] con un mensaje claro si la
  /// inscripción viola alguna regla. Si no lanza nada, es segura de
  /// crear.
  Future<void> ensureCanEnroll({
    required String memberId,
    required String classId,
  }) async {
    final member = await _memberRepository.getById(memberId);
    if (member == null) {
      throw const RepositoryException('El miembro seleccionado no existe.');
    }
    // No es parte literal del enunciado, pero es la misma lógica que
    // ya usamos para asignar membresías: un miembro inactivo no
    // debería poder hacer nada nuevo en el gimnasio.
    if (!member.isActive) {
      throw const RepositoryException(
        'El miembro está inactivo y no puede inscribirse a clases.',
      );
    }

    final gymClass = await _classRepository.getById(classId);
    if (gymClass == null) {
      throw const RepositoryException('La clase seleccionada no existe.');
    }
    if (gymClass.isPast) {
      throw const RepositoryException('No se puede inscribir a una clase que ya pasó.');
    }

    final activeMemberships = await _membershipRepository.getActiveMembershipsForMember(memberId);
    final hasValidMembership = activeMemberships.any((m) => m.isCurrentlyValid);
    if (!hasValidMembership) {
      throw const RepositoryException(
        'El miembro no tiene una membresía vigente (vencida, inactiva o inexistente). '
        'No se puede inscribir a la clase.',
      );
    }

    final currentCount = await _enrollmentRepository.getCountForClass(classId);
    if (currentCount >= gymClass.capacity) {
      throw RepositoryException(
        'La clase "${gymClass.name}" ya alcanzó su cupo máximo (${gymClass.capacity}).',
      );
    }
  }
}
