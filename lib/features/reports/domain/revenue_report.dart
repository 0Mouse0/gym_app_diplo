import '../../payments/domain/entities/payment_details.dart';

/// Total de ingresos de un mes calendario puntual.
class MonthlyRevenue {
  final int year;
  final int month;
  final double total;
  final int paymentCount;

  const MonthlyRevenue({
    required this.year,
    required this.month,
    required this.total,
    required this.paymentCount,
  });

  static const _monthNames = [
    '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];

  String get label => '${_monthNames[month]} $year';
}

/// Lógica pura del reporte de ingresos. Toma la lista ya cargada por
/// `PaymentsController` y la agrupa/filtra — nada de esto toca
/// Supabase ni widgets.
class RevenueReport {
  RevenueReport._();

  /// Agrupa los pagos por mes calendario, más reciente primero.
  static List<MonthlyRevenue> groupByMonth(List<PaymentDetails> payments) {
    final Map<String, MonthlyRevenue> byMonth = {};

    for (final details in payments) {
      final date = details.payment.paymentDate;
      final key = '${date.year}-${date.month}';
      final existing = byMonth[key];
      byMonth[key] = MonthlyRevenue(
        year: date.year,
        month: date.month,
        total: (existing?.total ?? 0) + details.payment.amount,
        paymentCount: (existing?.paymentCount ?? 0) + 1,
      );
    }

    final list = byMonth.values.toList();
    list.sort((a, b) {
      final aKey = a.year * 12 + a.month;
      final bKey = b.year * 12 + b.month;
      return bKey.compareTo(aKey); // más reciente primero
    });
    return list;
  }

  /// Suma de todos los pagos cuya fecha cae entre [start] y [end]
  /// (ambos inclusive). Para el filtro de "período personalizado".
  static double totalForRange(List<PaymentDetails> payments, DateTime start, DateTime end) {
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);

    return payments.where((details) {
      final d = details.payment.paymentDate;
      final dateOnly = DateTime(d.year, d.month, d.day);
      return !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
    }).fold(0.0, (sum, details) => sum + details.payment.amount);
  }
}
