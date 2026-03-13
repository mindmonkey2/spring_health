import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart' as material;
import '../models/member_model.dart';
import '../models/payment_model.dart';
import '../utils/date_utils.dart' as app_date_utils;

class PDFService {

  // ═══════════════════════════════════════════════════════════════
  // 1. MEMBERSHIP CARD (A6)
  // ═══════════════════════════════════════════════════════════════
  Future<Uint8List> generateMembershipCard(MemberModel member) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final qrBytes = await _generateQrImageBytes(member.qrCode);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.purple, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: const pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [PdfColors.purple, PdfColors.deepPurple],
                    ),
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'SPRING HEALTH STUDIO',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Membership Card',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),

                // Member Details + QR Code
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('ID: ${member.id}',
                              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 6),
                          pw.Text(member.name,
                              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 3),
                          pw.Text(member.phone, style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text(member.email,
                              style: const pw.TextStyle(fontSize: 8),
                              maxLines: 1,
                              overflow: pw.TextOverflow.clip),
                          pw.SizedBox(height: 6),
                          pw.Text('Category: ${member.category}',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 2),
                          pw.Text('Plan: ${member.plan}',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.SizedBox(height: 6),
                          pw.Text(
                              'Joining: ${app_date_utils.DateUtils.formatDate(member.joiningDate)}',
                              style: const pw.TextStyle(fontSize: 8)),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Expiry: ${app_date_utils.DateUtils.formatDate(member.expiryDate)}',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: member.isActive ? PdfColors.green : PdfColors.red,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text('Branch: ${member.branch}',
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    // QR Code
                    pw.Container(
                      width: 80,
                      height: 80,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey400),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Image(pw.MemoryImage(qrBytes),
                          fit: pw.BoxFit.contain),
                    ),
                  ],
                ),
                pw.Spacer(),

                // Status Badge
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: pw.BoxDecoration(
                      color: member.isActive ? PdfColors.green : PdfColors.red,
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(15)),
                    ),
                    child: pw.Text(
                      member.isActive ? 'ACTIVE' : 'EXPIRED',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. MEMBERSHIP INVOICE (A4) — for new joinings / renewals
  // ═══════════════════════════════════════════════════════════════
  Future<Uint8List> generateInvoice(MemberModel member) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: const pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [PdfColors.purple, PdfColors.deepPurple],
                  ),
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('SPRING HEALTH STUDIO',
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 22,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('Gym Management Pro',
                            style: const pw.TextStyle(
                                color: PdfColors.white, fontSize: 13)),
                        pw.SizedBox(height: 4),
                        pw.Text('Branch: ${member.branch}',
                            style: const pw.TextStyle(
                                color: PdfColors.white, fontSize: 11)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('INVOICE',
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 30,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text('# ${member.id}',
                            style: const pw.TextStyle(
                                color: PdfColors.white, fontSize: 11)),
                        pw.SizedBox(height: 4),
                        pw.Text(
                            'Date: ${app_date_utils.DateUtils.formatDate(member.joiningDate)}',
                            style: const pw.TextStyle(
                                color: PdfColors.white, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Bill To
              pw.Text('BILL TO:',
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700)),
              pw.SizedBox(height: 6),
              pw.Text(member.name,
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(member.phone,
                  style: const pw.TextStyle(fontSize: 12)),
              if (member.email.isNotEmpty)
                pw.Text(member.email,
                    style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 24),

              // Membership Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildTableCell('Description', isHeader: true),
                      _buildTableCell('Category', isHeader: true),
                      _buildTableCell('Plan', isHeader: true),
                      _buildTableCell('Amount', isHeader: true),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildTableCell('Gym Membership'),
                      _buildTableCell(member.category),
                      _buildTableCell(member.plan),
                      _buildTableCell(
                          'Rs.${member.totalFee.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Payment Breakdown (right-aligned)
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 260,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Column(
                    children: [
                      _buildAmountRow('Subtotal:', member.totalFee),
                      if (member.discount > 0) ...[
                        pw.SizedBox(height: 6),
                        _buildAmountRow('Discount:', -member.discount,
                            color: PdfColors.green),
                        if (member.discountDescription.isNotEmpty)
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(top: 3),
                            child: pw.Text(
                              '(${member.discountDescription})',
                              style: const pw.TextStyle(
                                  fontSize: 9, color: PdfColors.grey600),
                            ),
                          ),
                      ],
                      pw.Divider(thickness: 1),
                      _buildAmountRow('Total Amount:', member.finalAmount,
                          isBold: true),
                      pw.SizedBox(height: 6),
                      _buildAmountRow('Paid Amount:',
                          member.finalAmount - member.dueAmount,
                          color: PdfColors.blue700),
                      if (member.dueAmount > 0) ...[
                        pw.SizedBox(height: 6),
                        _buildAmountRow('Due Amount:', member.dueAmount,
                            color: PdfColors.red, isBold: true),
                      ],
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 16),

              // Payment Mode
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius:
                      pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Payment Details:',
                        style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pw.Text('Mode: ${member.paymentMode}',
                        style: const pw.TextStyle(fontSize: 11)),
                    if (member.paymentMode == 'Cash' ||
                        member.paymentMode == 'Mixed')
                      pw.Text(
                          'Cash: Rs.${member.cashAmount.toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 11)),
                    if (member.paymentMode == 'UPI' ||
                        member.paymentMode == 'Mixed')
                      pw.Text(
                          'UPI: Rs.${member.upiAmount.toStringAsFixed(2)}',
                          style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Membership Period
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius:
                      pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Membership Period',
                            style: pw.TextStyle(
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text(
                            'From: ${app_date_utils.DateUtils.formatDate(member.joiningDate)}',
                            style: const pw.TextStyle(fontSize: 11)),
                        pw.Text(
                            'To:   ${app_date_utils.DateUtils.formatDate(member.expiryDate)}',
                            style: const pw.TextStyle(fontSize: 11)),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: member.isActive
                            ? PdfColors.green
                            : PdfColors.red,
                        borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(20)),
                      ),
                      child: pw.Text(
                        member.isActive ? 'ACTIVE' : 'EXPIRED',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Thank you for choosing Spring Health Studio!',
                  style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.purple),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'For queries, contact your branch reception.',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. PAYMENT RECEIPT (A4) — for dues, renewals, individual payments
  // ═══════════════════════════════════════════════════════════════
  Future<Uint8List> generatePaymentReceipt({
    required MemberModel member,
    required PaymentModel payment,
  }) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final receiptNumber =
        'RCT-${payment.id.substring(0, 8).toUpperCase()}';
    final paymentTypeLabel = _getPaymentTypeLabel(payment.type);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: const pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [PdfColors.teal, PdfColors.teal700],
                  ),
                  borderRadius:
                      pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('SPRING HEALTH STUDIO',
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 22,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('Gym Management Pro',
                            style: const pw.TextStyle(
                                color: PdfColors.white, fontSize: 13)),
                        pw.SizedBox(height: 4),
                        pw.Text('Branch: ${member.branch}',
                            style: const pw.TextStyle(
                                color: PdfColors.white, fontSize: 11)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('RECEIPT',
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 30,
                                fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text(receiptNumber,
                            style: const pw.TextStyle(
                                color: PdfColors.white, fontSize: 11)),
                        pw.SizedBox(height: 4),
                        pw.Text(
                            'Date: ${app_date_utils.DateUtils.formatDate(payment.paymentDate)}',
                            style: const pw.TextStyle(
                                color: PdfColors.white, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Payment type badge
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: _getPaymentTypePdfColor(payment.type),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(20)),
                ),
                child: pw.Text(
                  paymentTypeLabel,
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 20),

              // Received From
              pw.Text('RECEIVED FROM:',
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700)),
              pw.SizedBox(height: 6),
              pw.Text(member.name,
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text(member.phone,
                  style: const pw.TextStyle(fontSize: 12)),
              if (member.email.isNotEmpty)
                pw.Text(member.email,
                    style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 6),
              pw.Text('Member ID: ${member.id}',
                  style: const pw.TextStyle(
                      fontSize: 11, color: PdfColors.grey700)),
              pw.SizedBox(height: 24),

              // Amount Box (big highlight)
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.teal50,
                  border: pw.Border.all(
                      color: PdfColors.teal, width: 2),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(12)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text('AMOUNT PAID',
                        style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.teal700)),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Rs.${payment.amount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.teal),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Payment Details Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(3),
                },
                children: [
                  _buildDetailRow('Payment Mode', payment.paymentMode,
                      isHeader: false),
                  if (payment.cashAmount > 0)
                    _buildDetailRow('Cash Amount',
                        'Rs.${payment.cashAmount.toStringAsFixed(2)}'),
                  if (payment.upiAmount > 0)
                    _buildDetailRow('UPI Amount',
                        'Rs.${payment.upiAmount.toStringAsFixed(2)}'),
                  _buildDetailRow('Payment Type', paymentTypeLabel),
                  _buildDetailRow(
                    'Membership Valid Till',
                    app_date_utils.DateUtils.formatDate(member.expiryDate),
                  ),
                  if (member.dueAmount > 0)
                    _buildDetailRow('Remaining Due',
                        'Rs.${member.dueAmount.toStringAsFixed(2)}',
                        valueColor: PdfColors.red),
                  if (member.dueAmount <= 0)
                    _buildDetailRow(
                        'Balance Due', 'NIL', valueColor: PdfColors.green),
                ],
              ),
              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Payment received. Thank you for your trust!',
                  style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.teal),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Spring Health Studio | ${member.branch} Branch',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ═══════════════════════════════════════════════════════════════
  // PRINT & SAVE UTILITIES
  // ═══════════════════════════════════════════════════════════════
  Future<void> printPDF(Uint8List pdfData) async {
    await Printing.layoutPdf(onLayout: (format) async => pdfData);
  }

  Future<File> savePDF(Uint8List pdfData, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.pdf');
    await file.writeAsBytes(pdfData);
    return file;
  }

  // ═══════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════
  Future<Uint8List> _generateQrImageBytes(String data) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    if (qrValidationResult.status != QrValidationStatus.valid) {
      throw Exception('QR code validation failed');
    }
    final qrCode = qrValidationResult.qrCode!;
    final painter = QrPainter.withQr(
      qr: qrCode,
      gapless: true,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: material.Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: material.Color(0xFF000000),
      ),
    );
    final picData = await painter.toImageData(300);
    return picData!.buffer.asUint8List();
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight:
              isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildAmountRow(String label, double amount,
      {bool isBold = false, PdfColor? color}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                fontSize: isBold ? 13 : 11,
                fontWeight:
                    isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: color)),
        pw.Text(
          'Rs.${amount.abs().toStringAsFixed(2)}',
          style: pw.TextStyle(
              fontSize: isBold ? 13 : 11,
              fontWeight:
                  isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color),
        ),
      ],
    );
  }

  pw.TableRow _buildDetailRow(String label, String value,
      {bool isHeader = false, PdfColor? valueColor}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label,
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 10,
                  color: valueColor,
                  fontWeight: valueColor != null
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal)),
        ),
      ],
    );
  }

  String _getPaymentTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'initial':
        return 'New Membership';
      case 'renewal':
        return 'Membership Renewal';
      case 'due':
        return 'Due Payment';
      default:
        return type;
    }
  }

  PdfColor _getPaymentTypePdfColor(String type) {
    switch (type.toLowerCase()) {
      case 'initial':
        return PdfColors.teal;
      case 'renewal':
        return PdfColors.blue700;
      case 'due':
        return PdfColors.orange;
      default:
        return PdfColors.grey600;
    }
  }
}
