class BranchModel {
  const BranchModel({
    this.id,
    required this.name,
    this.address,
    this.phone,
    this.isActive = true,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final String? address;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;

  BranchModel copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory BranchModel.fromMap(Map<String, dynamic> map) {
    return BranchModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
