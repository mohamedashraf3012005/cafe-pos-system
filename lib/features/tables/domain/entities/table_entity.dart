class TableEntity {
  final int id;
  final int tableNumber;
  final String status;

  TableEntity({
    required this.id,
    required this.tableNumber,
    required this.status,
  });

  bool get isFree => status == 'free';
}
