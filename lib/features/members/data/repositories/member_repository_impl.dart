import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../domain/entities/member.dart';
import '../../domain/repositories/member_repository.dart';

class MemberRepositoryImpl implements MemberRepository {
  static const _table = 'members';

  final SupabaseClient _client;

  MemberRepositoryImpl(this._client);

  @override
  Future<List<Member>> getAll() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('last_name', ascending: true)
          .order('first_name', ascending: true);

      return (rows as List)
          .map((row) => Member.fromMap(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo conectar con el servidor.');
    }
  }

  @override
  Future<Member?> getById(String id) async {
    try {
      final row = await _client
          .from(_table)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (row == null) return null;
      return Member.fromMap(row);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo conectar con el servidor.');
    }
  }

  @override
  Future<Member> create(Member member) async {
    try {
      final row = await _client
          .from(_table)
          .insert(member.toInsertMap())
          .select()
          .single();

      return Member.fromMap(row);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo crear el miembro.');
    }
  }

  @override
  Future<Member> update(Member member) async {
    try {
      final row = await _client
          .from(_table)
          .update(member.toInsertMap())
          .eq('id', member.id)
          .select()
          .single();

      return Member.fromMap(row);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo actualizar el miembro.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo eliminar el miembro.');
    }
  }

  /// Traduce errores conocidos de Postgres/Supabase a mensajes que un
  /// usuario final puede entender. Cualquier código no contemplado
  /// cae en un mensaje genérico.
  String _translate(PostgrestException e) {
    switch (e.code) {
      case '23505': // unique_violation
        return 'Ya existe un miembro con ese número de documento.';
      case '23502': // not_null_violation
        return 'Faltan datos obligatorios del miembro.';
      default:
        return 'Ocurrió un error al comunicarse con el servidor.';
    }
  }
}
