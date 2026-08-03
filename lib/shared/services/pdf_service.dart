import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/helpers/date_helper.dart';
import '../../features/billing/models/bill_model.dart';
import '../../features/opd/models/opd_visit_model.dart';
import '../../features/patients/models/patient_model.dart';

/// Generates and prints/shares PDF documents (bills, prescriptions,
/// patient ID cards) via the `printing` package's cross-platform
/// print dialog / share sheet.
class PdfService {
  PdfService._();

  static const PdfColor _headerColor = PdfColor.fromInt(0xFF00695C);

  static pw.Widget _clinicHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'AKS MediCare Pro',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _headerColor),
        ),
        pw.SizedBox(height: 2),
        pw.Text('Hospital & Clinic Management', style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 1),
      ],
    );
  }

  static pw.Widget _labelValue(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          ),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }

  // ============================
  // BILL / INVOICE
  // ============================

  static Future<void> printBill(BillModel bill) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _clinicHeader(),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('INVOICE', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('No: ${bill.invoiceNo}', style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 12),
              _labelValue('Patient Name', bill.patientName),
              _labelValue('UHID', bill.patientUhid),
              _labelValue('Bill Type', bill.billType),
              if (bill.referenceNo != null) _labelValue('Reference No', bill.referenceNo!),
              _labelValue('Bill Date', AppDateHelper.formatDate(bill.billDate)),
              _labelValue('Payment Mode', bill.paymentMode),
              _labelValue('Payment Status', bill.paymentStatus),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(4),
                  1: pw.FlexColumnWidth(1),
                  2: pw.FlexColumnWidth(1.5),
                  3: pw.FlexColumnWidth(1.5),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _cell('Description', bold: true),
                      _cell('Qty', bold: true),
                      _cell('Unit Price', bold: true),
                      _cell('Amount', bold: true),
                    ],
                  ),
                  ...bill.items.map(
                    (item) => pw.TableRow(
                      children: [
                        _cell(item.description),
                        _cell('${item.quantity}'),
                        _cell('Rs. ${item.unitPrice.toStringAsFixed(2)}'),
                        _cell('Rs. ${item.amount.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 220,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      _summaryRow('Subtotal', bill.subtotal),
                      _summaryRow('Discount', -bill.discount),
                      _summaryRow('Tax', bill.tax),
                      pw.Divider(),
                      _summaryRow('Total Amount', bill.totalAmount, bold: true),
                      _summaryRow('Paid Amount', bill.paidAmount),
                      _summaryRow('Balance', bill.balanceAmount, bold: true),
                    ],
                  ),
                ),
              ),
              if (bill.notes != null) ...[
                pw.SizedBox(height: 16),
                pw.Text('Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(bill.notes!, style: const pw.TextStyle(fontSize: 10)),
              ],
              pw.Spacer(),
              pw.Divider(),
              pw.Text(
                'Generated on ${AppDateHelper.formatDateTime(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }

  static pw.Widget _summaryRow(String label, double value, {bool bold = false}) {
    final style = pw.TextStyle(
      fontSize: bold ? 12 : 10,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text('Rs. ${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }

  // ============================
  // PRESCRIPTION
  // ============================

  static Future<void> printPrescription(OpdVisitModel visit) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _clinicHeader(),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('PRESCRIPTION', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Visit No: ${visit.visitNo}', style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
              pw.SizedBox(height: 12),
              _labelValue('Patient Name', visit.patientName),
              _labelValue('UHID', visit.patientUhid),
              _labelValue('Doctor', visit.doctorName),
              _labelValue('Visit Date', AppDateHelper.formatDate(visit.visitDate)),
              _labelValue('Visit Type', visit.visitType),
              pw.SizedBox(height: 16),
              if (visit.chiefComplaint != null) ...[
                pw.Text('Chief Complaint', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                pw.Text(visit.chiefComplaint!, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 10),
              ],
              if (visit.diagnosis != null) ...[
                pw.Text('Diagnosis', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                pw.Text(visit.diagnosis!, style: const pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: 10),
              ],
              pw.Text('Rx', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey400, width: 0.5)),
                child: pw.Text(
                  visit.prescription?.isNotEmpty == true ? visit.prescription! : '—',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ),
              if (visit.followUpDate != null) ...[
                pw.SizedBox(height: 16),
                _labelValue('Follow-up Date', AppDateHelper.formatDate(visit.followUpDate!)),
              ],
              pw.Spacer(),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Dr. ${visit.doctorName}', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Text(
                'Generated on ${AppDateHelper.formatDateTime(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  // ============================
  // PATIENT ID CARD
  // ============================

  static Future<void> printPatientIdCard(PatientModel patient) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _clinicHeader(),
              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.Container(
                  width: 320,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: _headerColor, width: 1.5),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PATIENT ID CARD',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _headerColor),
                      ),
                      pw.Divider(),
                      pw.Text(
                        patient.fullName,
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      _labelValue('UHID', patient.uhid),
                      _labelValue('Gender / Age', '${patient.gender}, ${patient.age} Y'),
                      _labelValue('Blood Group', patient.bloodGroup ?? '—'),
                      _labelValue('Mobile', patient.mobile),
                      if (patient.address != null) _labelValue('Address', patient.address!),
                    ],
                  ),
                ),
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Text(
                'Generated on ${AppDateHelper.formatDateTime(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }
}
