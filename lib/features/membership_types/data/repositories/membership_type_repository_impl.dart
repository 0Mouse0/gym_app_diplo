import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../domain/entities/membership_type.dart';
import '../../domain/repositories/membership_type_repository.dart';

class MembershipTypeRepositoryImpl implements MembershipTypeRepository {
  static const _table = 'membership_types';

  final SupabaseClient _client;

  MembershipTypeRepositoryImpl(this._client);

  @override
  Future<List<MembershipType>> getAll() async {
    try {
      final rows = await _client.from(_table).select().order('name', ascending: true);
      return (rows as List)
          .map((row) => MembershipType.fromMap(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo conectar con el servidor.');
    }
  }

  @override
  Future<MembershipType> create(MembershipType type) async {
    try {
      final row = await _client.from(_table).insert(type.toInsertMap()).select().single();
      return MembershipType.fromMap(row);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo crear el tipo de membresía.');
    }
  }

  @override
  Future<MembershipType> update(MembershipType type) async {
    try {
      final row = await _client
          .from(_table)
          .update(type.toInsertMap())
          .eq('id', type.id)
          .select()
          .single();
      return MembershipType.fromMap(row);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo actualizar el tipo de membresía.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo eliminar el tipo de membresía.');
    }
  }

  String _translate(PostgrestException e) {
    switch (e.code) {
      case '23505':
        return 'Ya existe un tipo de membresía con ese nombre.';
      case '23503':
        return 'No se puede eliminar: hay membresías que usan este tipo.';
      default:
        return 'Ocurrió un error al comunicarse con el servidor.';
    }
  }
}
