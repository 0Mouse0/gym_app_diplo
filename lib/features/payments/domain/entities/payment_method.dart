/// Métodos de pago aceptados. Enum en vez de String suelto, para que
/// el formulario no pueda mandar un valor que la base rechace por el
/// `check` de la columna `payment_method`.
enum PaymentMethod {
  cash('efectivo', 'Efectivo'),
  card('tarjeta', 'Tarjeta'),
  transfer('transferencia', 'Transferencia');

  final String dbValue;
  final String label;

  const PaymentMethod(this.dbValue, this.label);

  static PaymentMethod fromDb(String value) {
    return PaymentMethod.values.firstWhere(
      (m) => m.dbValue == value,
      orElse: () => throw ArgumentError('Método de pago desconocido: $value'),
    );
  }
}
