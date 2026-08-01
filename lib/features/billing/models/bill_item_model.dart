class BillItemModel {
  const BillItemModel({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  final String description;
  final int quantity;
  final double unitPrice;

  double get amount => quantity * unitPrice;

  BillItemModel copyWith({
    String? description,
    int? quantity,
    double? unitPrice,
  }) {
    return BillItemModel(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  factory BillItemModel.fromMap(Map<String, dynamic> map) {
    return BillItemModel(
      description: map['description'] as String,
      quantity: (map['quantity'] as num).toInt(),
      unitPrice: (map['unit_price'] as num).toDouble(),
    );
  }
}
