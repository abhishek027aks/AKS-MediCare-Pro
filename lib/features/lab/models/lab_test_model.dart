class LabTestModel {
  const LabTestModel({
    this.id,
    required this.testNo,
    required this.patientId,
    required this.patientName,
    required this.patientUhid,
    this.doctorId,
    required this.doctorName,
    required this.testName,
    required this.testCategory,
    required this.sampleType,
    required this.orderDate,
    required this.status,
    this.resultValue,
    this.normalRange,
    this.resultUnit,
    this.resultDate,
    required this.testFee,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String testNo;
  final int patientId;
  final String patientName;
  final String patientUhid;
  final int? doctorId;
  final String doctorName;
  final String testName;
  final String testCategory;
  final String sampleType;
  final DateTime orderDate;
  final String status;
  final String? resultValue;
  final String? normalRange;
  final String? resultUnit;
  final DateTime? resultDate;
  final double testFee;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  LabTestModel copyWith({
    int? id,
    String? testNo,
    int? patientId,
    String? patientName,
    String? patientUhid,
    int? doctorId,
    String? doctorName,
    String? testName,
    String? testCategory,
    String? sampleType,
    DateTime? orderDate,
    String? status,
    String? resultValue,
    String? normalRange,
    String? resultUnit,
    DateTime? resultDate,
    double? testFee,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LabTestModel(
      id: id ?? this.id,
      testNo: testNo ?? this.testNo,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientUhid: patientUhid ?? this.patientUhid,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      testName: testName ?? this.testName,
      testCategory: testCategory ?? this.testCategory,
      sampleType: sampleType ?? this.sampleType,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      resultValue: resultValue ?? this.resultValue,
      normalRange: normalRange ?? this.normalRange,
      resultUnit: resultUnit ?? this.resultUnit,
      resultDate: resultDate ?? this.resultDate,
      testFee: testFee ?? this.testFee,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'test_no': testNo,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_uhid': patientUhid,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'test_name': testName,
      'test_category': testCategory,
      'sample_type': sampleType,
      'order_date': orderDate.toIso8601String(),
      'status': status,
      'result_value': resultValue,
      'normal_range': normalRange,
      'result_unit': resultUnit,
      'result_date': resultDate?.toIso8601String(),
      'test_fee': testFee,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LabTestModel.fromMap(Map<String, dynamic> map) {
    return LabTestModel(
      id: map['id'] as int?,
      testNo: map['test_no'] as String,
      patientId: map['patient_id'] as int,
      patientName: map['patient_name'] as String,
      patientUhid: map['patient_uhid'] as String,
      doctorId: map['doctor_id'] as int?,
      doctorName: map['doctor_name'] as String,
      testName: map['test_name'] as String,
      testCategory: map['test_category'] as String,
      sampleType: map['sample_type'] as String,
      orderDate: DateTime.parse(map['order_date'] as String),
      status: map['status'] as String,
      resultValue: map['result_value'] as String?,
      normalRange: map['normal_range'] as String?,
      resultUnit: map['result_unit'] as String?,
      resultDate: map['result_date'] == null
          ? null
          : DateTime.parse(map['result_date'] as String),
      testFee: (map['test_fee'] as num).toDouble(),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory LabTestModel.fromJson(Map<String, dynamic> json) {
    return LabTestModel.fromMap(json);
  }

  @override
  String toString() {
    return '''
LabTestModel(
  id: $id,
  testNo: $testNo,
  patientName: $patientName,
  testName: $testName,
  status: $status
)
''';
  }
}
