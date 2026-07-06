import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../domain/entities/gym_class.dart';
import '../../domain/repositories/class_repository.dart';

class ClassRepositoryImpl implements ClassRepository {
  static const _table = 'classes';

  final SupabaseClient _client;

  ClassRepositoryImpl(this._client);

  @override
  Future<List<GymClass>> getAll() async {
    try {
      final rows = await _client
          .from(_table)
          .select()
          .order('scheduled_at', ascending: true);

      return (rows as List)
          .map((row) => GymClass.fromMap(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo conectar con el servidor.');
    }
  }

  @override
  Future<GymClass> create(GymClass gymClass) async {
    try {
      final row = await _client
          .from(_table)
          .insert(gymClass.toInsertMap())
          .select()
          .single();
      return GymClass.fromMap(row);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo crear la clase.');
    }
  }

  @override
  Future<GymClass> update(GymClass gymClass) async {
    try {
      final row = await _client
          .from(_table)
          .update(gymClass.toInsertMap())
          .eq('id', gymClass.id)
          .select()
          .single();
      return GymClass.fromMap(row);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo actualizar la clase.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo eliminar la clase.');
    }
  }

  String _translate(PostgrestException e) {
    switch (e.code) {
      case '23505':
        return 'Ya existe una clase con ese nombre en ese horario.';
      case '23502':
        return 'Faltan datos obligatorios de la clase.';
      case '23514':
        return 'El cupo y la duración deben ser mayores a 0.';
      case '23503':
        return 'No se puede eliminar: hay inscripciones que dependen de esta clase.';
      default:
        return 'Ocurrió un error al comunicarse con el servidor.';
    }
  }
}
