import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../domain/entities/enrollment_details.dart';
import '../../domain/repositories/enrollment_repository.dart';

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  static const _table = 'enrollments';

  // Select embebido: trae nombre de miembro y datos de la clase en
  // la misma consulta.
  static const _selectWithDetails =
      '*, member:members(first_name, last_name), class:classes(name, scheduled_at, capacity)';

  final SupabaseClient _client;

  EnrollmentRepositoryImpl(this._client);

  @override
  Future<List<EnrollmentDetails>> getAllWithDetails() async {
    try {
      final rows = await _client
          .from(_table)
          .select(_selectWithDetails)
          .order('enrolled_at', ascending: false);

      return (rows as List)
          .map((row) => EnrollmentDetails.fromMap(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo conectar con el servidor.');
    }
  }

  @override
  Future<int> getCountForClass(String classId) async {
    try {
      // Traemos solo el id: es más liviano que traer la fila
      // completa, y contamos en Dart (evita depender de la sintaxis
      // exacta de "count" de la versión del cliente de Supabase).
      final rows = await _client.from(_table).select('id').eq('class_id', classId);
      return (rows as List).length;
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo conectar con el servidor.');
    }
  }

  @override
  Future<Enrollment> create(Enrollment enrollment) async {
    try {
      final row = await _client
          .from(_table)
          .insert(enrollment.toInsertMap())
          .select()
          .single();
      return Enrollment.fromMap(row);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo registrar la inscripción.');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw RepositoryException(_translate(e));
    } catch (_) {
      throw const RepositoryException('No se pudo cancelar la inscripción.');
    }
  }

  String _translate(PostgrestException e) {
    switch (e.code) {
      case '23505':
        return 'Este miembro ya está inscrito en esta clase.';
      case '23503':
        return 'El miembro o la clase seleccionada no existe.';
      case '42501':
        return 'No tienes permiso para hacer esto. Inicia sesión nuevamente.';
      default:
        return 'Ocurrió un error al comunicarse con el servidor.';
    }
  }
}
