class StockBatch {
  final String id;
  final String batchNumber;
  final double purchasePrice;
  final double salePrice;
  final int quantity;
  final DateTime entryDate;
  final String supplier;

  StockBatch({
    required this.id,
    required this.batchNumber,
    required this.purchasePrice,
    required this.salePrice,
    required this.quantity,
    required this.entryDate,
    this.supplier = 'Default Supplier',
  });

  StockBatch copyWith({
    String? id,
    String? batchNumber,
    double? purchasePrice,
    double? salePrice,
    int? quantity,
    DateTime? entryDate,
    String? supplier,
  }) {
    return StockBatch(
      id: id ?? this.id,
      batchNumber: batchNumber ?? this.batchNumber,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      quantity: quantity ?? this.quantity,
      entryDate: entryDate ?? this.entryDate,
      supplier: supplier ?? this.supplier,
    );
  }
}
