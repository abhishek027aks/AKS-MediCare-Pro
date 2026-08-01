import 'dart:convert';

import 'bill_item_model.dart';

class BillModel {
  const BillModel({
    this.id,
    required this.invoiceNo,
    required this.patientId,
    required this.patientName,
    required this.patientUhid,
    required this.billType,
    this.referenceNo,
    required this.billDate,
    required this.items,
    required this.discount,
    required this.tax,
    required this.paidAmount,
    required this.paymentMode,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String invoiceNo;
  final int patientId;
  final String patientName;
  final String patientUhid;
  final String billType;
  final String? referenceNo;
  final DateTime billDate;
  final List<BillItemModel> items;
  final double discount;
  final double tax;
  final double paidAmount;
  final String paymentMode;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get subtotal => items.fold(0, (sum, item) => sum + item.amount);

  double get totalAmount => (subtotal - discount + tax).clamp(0, double.infinity);

  double get balanceAmount => (totalAmount - paidAmount).clamp(0, double.infinity);

  String get paymentStatus {
    if (paidAmount <= 0) return 'Unpaid';
    if (balanceAmount <= 0) return 'Paid';
    return 'Partial';
  }

  BillModel copyWith({
    int? id,
    String? invoiceNo,
    int? patientId,
    String? patientName,
    String? patientUhid,
    String? billType,
    String? referenceNo,
    DateTime? billDate,
    List<BillItemModel>? items,
    double? discount,
    double? tax,
    double? paidAmount,
    String? paymentMode,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BillModel(
      id: id ?? this.id,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientUhid: patientUhid ?? this.patientUhid,
      billType: billType ?? this.billType,
      referenceNo: referenceNo ?? this.referenceNo,
      billDate: billDate ?? this.billDate,
      items: items ?? this.items,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_no': invoiceNo,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_uhid': patientUhid,
      'bill_type': billType,
      'reference_no': referenceNo,
      'bill_date': billDate.toIso8601String(),
      'items': jsonEncode(items.map((item) => item.toMap()).toList()),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'balance_amount': balanceAmount,
      'payment_mode': paymentMode,
      'payment_status': paymentStatus,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory BillModel.fromMap(Map<String, dynamic> map) {
    final rawItems = jsonDecode(map['items'] as String) as List<dynamic>;

    return BillModel(
      id: map['id'] as int?,
      invoiceNo: map['invoice_no'] as String,
      patientId: map['patient_id'] as int,
      patientName: map['patient_name'] as String,
      patientUhid: map['patient_uhid'] as String,
      billType: map['bill_type'] as String,
      referenceNo: map['reference_no'] as String?,
      billDate: DateTime.parse(map['bill_date'] as String),
      items: rawItems
          .map((item) => BillItemModel.fromMap(item as Map<String, dynamic>))
          .toList(),
      discount: (map['discount'] as num).toDouble(),
      tax: (map['tax'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num).toDouble(),
      paymentMode: map['payment_mode'] as String,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel.fromMap(json);

  @override
  String toString() {
    return '''
BillModel(
  id: $id,
  invoiceNo: $invoiceNo,
  patientName: $patientName,
  totalAmount: $totalAmount,
  paymentStatus: $paymentStatus
)
''';
  }
}
