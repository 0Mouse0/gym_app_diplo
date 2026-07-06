import '../../../../core/errors/repository_exception.dart';
import '../../../members/domain/repositories/member_repository.dart';
import '../repositories/membership_repository.dart';

/// Reglas de negocio para asignar una membresía a un miembro.
///
/// Vive acá (servicio de dominio) y no en el repositorio de
/// Membresías porque necesita datos de OTRA entidad (Member) además
/// de la propia — es un caso típico de regla que cruza dos
/// agregados, y por eso no pertenece a ningún widget ni a un único
/// repositorio.
class MembershipRulesService {
  final MemberRepository _memberRepository;
  final MembershipRepository _membershipRepository;

  MembershipRulesService(this._memberRepository, this._membershipRepository);

  /// Lanza [RepositoryException] si la asignación viola alguna regla:
  /// - El miembro no existe o está inactivo.
  /// - El miembro ya tiene otra membresía activa cuyas fechas se
  ///   superponen con la nueva (esto también cubre "ya tiene una
  ///   membresía activa" como caso particular de superposición).
  ///
  /// [excludingMembershipId] se usa al editar, para no comparar la
  /// membresía contra sí misma.
  Future<void> ensureCanAssign({
    required String memberId,
    required DateTime startDate,
    required DateTime endDate,
    String? excludingMembershipId,
  }) async {
    final member = await _memberRepository.getById(memberId);
    if (member == null) {
      throw const RepositoryException('El miembro seleccionado no existe.');
    }
    if (!member.isActive) {
      throw const RepositoryException(
        'No se puede asignar una membresía a un miembro inactivo. '
        'Activalo primero desde la ficha de Miembros.',
      );
    }

    final activeMemberships = await _membershipRepository.getActiveMembershipsForMember(memberId);

    for (final existing in activeMemberships) {
      if (excludingMembershipId != null && existing.id == excludingMembershipId) {
        continue;
      }
      final overlaps = !(endDate.isBefore(existing.startDate) || startDate.isAfter(existing.endDate));
      if (overlaps) {
        throw RepositoryException(
          'Este miembro ya tiene una membresía activa entre '
          '${_formatDate(existing.startDate)} y ${_formatDate(existing.endDate)}. '
          'Elige una fecha de inicio a partir de esa.',
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
