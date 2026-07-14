import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../domain/entities/membership_details.dart';
import '../../domain/repositories/membership_repository.dart';

class MembershipRepositoryImpl implements MembershipRepository {
  static const _table = 'memberships';

  // Select embebido: trae, en la misma consulta, el nombre del
  // miembro y los datos del tipo de membresía. Esto es lo que
  // permite que el listado muestre nombres en vez de UUIDs sin que
  // la UI tenga que hacer múltiples consultas ni cruces manuales.
  static const _selectWithDetails =
      '*, members(first_name, last_name), membership_types(name, price)';

  final SupabaseClient _client;

  MembershipRepositoryImpl(this._client);

  @override
  Future<List<MembershipDetails>> getAllWithDetails() async {
    try {
      await _syncExpiredMemberships();

      final rows = await _client
          .from(_table)
          .select(_selectWithDetails)
          .order('end_date', ascending: true);

      return (rows as List)
          .map((row) => MembershipDetails.fromMap(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo conectar con el servidor.');
    }
  }

  @override
  Future<List<Membership>> getActiveMembershipsForMember(String memberId) async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .eq('member_id', memberId)
          .eq('is_active', true);

      return (rows as List)
          .map((row) => Membership.fromMap(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo conectar con el servidor.');
    }
  }

  /// Apaga `is_active` de las membresías que ya vencieron por fecha.
  ///
  /// Es una sincronización "perezosa": corre cada vez que se lista,
  /// no hay un proceso corriendo en el servidor las 24hs (eso
  /// requeriría pg_cron). Si nadie abre la app, una fila puede quedar
  /// con is_active desactualizado hasta la próxima consulta — es una
  /// limitación conocida y aceptable para este proyecto.
  Future<void> _syncExpiredMemberships() async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day).toIso8601String().split('T').first;
    try {
      await _client
          .from(_table)
          .update({'is_active': false})
          .lt('end_date', todayOnly)
          .eq('is_active', true);
    } catch (_) {
      // No bloqueamos el listado si la sincronización falla puntualmente.
    }
  }

  @override
  Future<Membership> create(Membership membership) async {
    try {
      final row = await _client
          .from(_table)
          .insert(membership.toInsertMap())
          .select()
          .single();
      return Membership.fromMap(row);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo crear la membresía.');
    }
  }

  @override
  Future<Membership> update(Membership membership) async {
    try {
      final row = await _client
          .from(_table)
          .update(membership.toInsertMap())
          .eq('id', membership.id)
          .select()
          .single();
      return Membership.fromMap(row);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo actualizar la membresía.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo eliminar la membresía.');
    }
  }

  String _translate(PostgrestException e) {
    switch (e.code) {
      case '23503':
        return 'El miembro o el tipo de membresía seleccionado no existe.';
      case '23502':
        return 'Faltan datos obligatorios de la membresía.';
      case '42501':
        return 'No tienes permiso para hacer esto. Inicia sesión nuevamente.';
      default:
        return 'Ocurrió un error al comunicarse con el servidor.';
    }
  }
}
