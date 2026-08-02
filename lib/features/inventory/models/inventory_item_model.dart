class InventoryItemModel {
  const InventoryItemModel({
    this.id,
    required this.itemName,
    required this.category,
    required this.department,
    required this.quantity,
    required this.unit,
    this.purchaseDate,
    this.purchasePrice,
    this.supplier,
    required this.condition,
    this.warrantyExpiry,
    this.serialNumber,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String itemName;
  final String category;
  final String department;
  final int quantity;
  final String unit;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String? supplier;
  final String condition;
  final DateTime? warrantyExpiry;
  final String? serialNumber;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isUnderWarranty =>
      warrantyExpiry != null && warrantyExpiry!.isAfter(DateTime.now());

  InventoryItemModel copyWith({
    int? id,
    String? itemName,
    String? category,
    String? department,
    int? quantity,
    String? unit,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? supplier,
    String? condition,
    DateTime? warrantyExpiry,
    String? serialNumber,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      department: department ?? this.department,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      supplier: supplier ?? this.supplier,
      condition: condition ?? this.condition,
      warrantyExpiry: warrantyExpiry ?? this.warrantyExpiry,
      serialNumber: serialNumber ?? this.serialNumber,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'category': category,
      'department': department,
      'quantity': quantity,
      'unit': unit,
      'purchase_date': purchaseDate?.toIso8601String(),
      'purchase_price': purchasePrice,
      'supplier': supplier,
      'condition_status': condition,
      'warranty_expiry': warrantyExpiry?.toIso8601String(),
      'serial_number': serialNumber,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory InventoryItemModel.fromMap(Map<String, dynamic> map) {
    return InventoryItemModel(
      id: map['id'] as int?,
      itemName: map['item_name'] as String,
      category: map['category'] as String,
      department: map['department'] as String,
      quantity: (map['quantity'] as num).toInt(),
      unit: map['unit'] as String,
      purchaseDate: map['purchase_date'] == null
          ? null
          : DateTime.parse(map['purchase_date'] as String),
      purchasePrice: (map['purchase_price'] as num?)?.toDouble(),
      supplier: map['supplier'] as String?,
      condition: map['condition_status'] as String,
      warrantyExpiry: map['warranty_expiry'] == null
          ? null
          : DateTime.parse(map['warranty_expiry'] as String),
      serialNumber: map['serial_number'] as String?,
      notes: map['notes'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel.fromMap(json);
  }

  @override
  String toString() {
    return '''
InventoryItemModel(
  id: $id,
  itemName: $itemName,
  category: $category,
  quantity: $quantity
)
''';
  }
}
