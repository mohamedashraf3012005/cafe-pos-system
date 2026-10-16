class ExpenseItemEntity {
  final int id;
  final double amount;
  final String reason;
  final DateTime createdAt;
  final bool isClosedShift;
  final int? shiftClosingId;

  const ExpenseItemEntity({
    required this.id,
    required this.amount,
    required this.reason,
    required this.createdAt,
    this.isClosedShift = false,
    this.shiftClosingId,
  });
}
