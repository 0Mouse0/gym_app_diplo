import '../entities/member.dart';

/// Contrato del repositorio de miembros. La capa de presentación y los
/// futuros servicios de negocio dependen de esta interfaz, nunca de
/// Supabase directamente. Esto permite reemplazar la implementación
/// (o mockearla en tests) sin tocar el resto de la app.
abstract class MemberRepository {
  Future<List<Member>> getAll();

  Future<Member?> getById(String id);

  Future<Member> create(Member member);

  Future<Member> update(Member member);

  Future<void> delete(String id);
}
