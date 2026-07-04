import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/member.dart';
import '../../domain/repositories/member_repository.dart';

class MemberRepositoryImpl implements MemberRepository {
  static const _table = 'members';

  final SupabaseClient _client;

  MemberRepositoryImpl(this._client);

  @override
  Future<List<Member>> getAll() async {
    final rows = await _client
        .from(_table)
        .select()
        .order('full_name', ascending: true);

    return (rows as List)
        .map((row) => Member.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Member?> getById(String id) async {
    final row = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (row == null) return null;
    return Member.fromMap(row);
  }

  @override
  Future<Member> create(Member member) async {
    final row = await _client
        .from(_table)
        .insert(member.toInsertMap())
        .select()
        .single();

    return Member.fromMap(row);
  }

  @override
  Future<Member> update(Member member) async {
    final row = await _client
        .from(_table)
        .update(member.toInsertMap())
        .eq('id', member.id)
        .select()
        .single();

    return Member.fromMap(row);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
