class MedicineModel {
  const MedicineModel({
    this.id,
    required this.name,
    this.genericName,
    required this.category,
    this.manufacturer,
    required this.unit,
    required this.stockQuantity,
    required this.reorderLevel,
    required this.unitPrice,
    this.batchNumber,
    this.expiryDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String name;
  final String? genericName;
  final String category;
  final String? manufacturer;
  final String unit;
  final int stockQuantity;
  final int reorderLevel;
  final double unitPrice;
  final String? batchNumber;
  final DateTime? expiryDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLowStock => stockQuantity <= reorderLevel;

  bool get isExpiringSoon =>
      expiryDate != null && expiryDate!.difference(DateTime.now()).inDays <= 90;

  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());

  MedicineModel copyWith({
    int? id,
    String? name,
    String? genericName,
    String? category,
    String? manufacturer,
    String? unit,
    int? stockQuantity,
    int? reorderLevel,
    double? unitPrice,
    String? batchNumber,
    DateTime? expiryDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      category: category ?? this.category,
      manufacturer: manufacturer ?? this.manufacturer,
      unit: unit ?? this.unit,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      unitPrice: unitPrice ?? this.unitPrice,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'generic_name': genericName,
      'category': category,
      'manufacturer': manufacturer,
      'unit': unit,
      'stock_quantity': stockQuantity,
      'reorder_level': reorderLevel,
      'unit_price': unitPrice,
      'batch_number': batchNumber,
      'expiry_date': expiryDate?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      genericName: map['generic_name'] as String?,
      category: map['category'] as String,
      manufacturer: map['manufacturer'] as String?,
      unit: map['unit'] as String,
      stockQuantity: (map['stock_quantity'] as num).toInt(),
      reorderLevel: (map['reorder_level'] as num).toInt(),
      unitPrice: (map['unit_price'] as num).toDouble(),
      batchNumber: map['batch_number'] as String?,
      expiryDate: map['expiry_date'] == null
          ? null
          : DateTime.parse(map['expiry_date'] as String),
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel.fromMap(json);
  }

  @override
  String toString() {
    return '''
MedicineModel(
  id: $id,
  name: $name,
  stockQuantity: $stockQuantity,
  reorderLevel: $reorderLevel
)
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MedicineModel &&
            id == other.id &&
            name == other.name &&
            genericName == other.genericName &&
            category == other.category &&
            manufacturer == other.manufacturer &&
            unit == other.unit &&
            stockQuantity == other.stockQuantity &&
            reorderLevel == other.reorderLevel &&
            unitPrice == other.unitPrice &&
            batchNumber == other.batchNumber &&
            expiryDate == other.expiryDate &&
            isActive == other.isActive &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt;
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        genericName,
        category,
        manufacturer,
        unit,
        stockQuantity,
        reorderLevel,
        unitPrice,
        batchNumber,
        expiryDate,
        isActive,
        createdAt,
        updatedAt,
      ]);
}
