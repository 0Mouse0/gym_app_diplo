import '../../memberships/domain/entities/membership_details.dart';

/// Lógica del reporte "membresías por vencer". Es una función pura
/// (sin Supabase, sin widgets): toma la lista ya cargada por
/// `MembershipsController` y la filtra/ordena. Vive acá, no en la
/// pantalla, para que el widget se limite a mostrar la lista que le
/// llega.
class ExpiringMembershipsReport {
  ExpiringMembershipsReport._();

  /// Membresías vigentes hoy que vencen dentro de [withinDays] días
  /// (incluye el día de hoy, excluye las ya vencidas), ordenadas por
  /// fecha de vencimiento más próxima primero.
  static List<MembershipDetails> filter(List<MembershipDetails> all, int withinDays) {
    final filtered = all.where((d) {
      final m = d.membership;
      return m.isCurrentlyValid && m.daysUntilExpiration >= 0 && m.daysUntilExpiration <= withinDays;
    }).toList();

    filtered.sort((a, b) => a.membership.endDate.compareTo(b.membership.endDate));
    return filtered;
  }
}
