import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/member_model.dart';
import '../models/payment_model.dart';
import '../models/document_sent_model.dart';
import 'whatsapp_service.dart';
import 'email_service.dart';
import 'pdf_service.dart';
import 'firestore_service.dart';

class DocumentService {
  final PDFService _pdfService = PDFService();
  final EmailService _emailService = EmailService();
  final FirestoreService _firestoreService = FirestoreService();

  // Check network connectivity
  Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile) ||
      connectivityResult.contains(ConnectivityResult.wifi);
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      return true; // Assume connected if check fails
    }
  }

  // Send document with retry mechanism
  Future<DocumentSendResult> sendDocument({
    required BuildContext context,
    required MemberModel member,
    required String documentType,
    required String method, // 'whatsapp', 'email', 'both'
  PaymentModel? payment,
  int retryCount = 0,
  }) async {
    // Check connectivity
    if (!await isConnected()) {
      return DocumentSendResult(
        success: false,
        error: 'No internet connection. Please check your network and try again.',
        shouldRetry: true,
      );
    }

    try {
      bool whatsappSent = false;
      bool emailSent = false;
      String? error;

      // Send via WhatsApp
      if (method == 'whatsapp' || method == 'both') {
        try {
          whatsappSent = await _sendViaWhatsApp(member, documentType, payment);
        } catch (e) {
          error = 'WhatsApp error: $e';
          debugPrint(error);
        }
      }

      // Send via Email
      if (method == 'email' || method == 'both') {
        if (member.email.isEmpty) {
          error = error == null
          ? 'Email address not available'
          : '$error\nEmail address not available';
        } else {
          try {
            emailSent = await _sendViaEmail(member, documentType, payment);
          } catch (e) {
            final emailError = 'Email error: $e';
            error = error == null ? emailError : '$error\n$emailError';
            debugPrint(emailError);
          }
        }
      }

      final success = (method == 'whatsapp' && whatsappSent) ||
      (method == 'email' && emailSent) ||
      (method == 'both' && (whatsappSent || emailSent));

      // Log document send history
      if (success) {
        await _logDocumentHistory(member, documentType, method);
      }

      return DocumentSendResult(
        success: success,
        whatsappSent: whatsappSent,
        emailSent: emailSent,
        error: error,
        shouldRetry: !success && retryCount < 3,
      );
    } catch (e) {
      debugPrint('Document send error: $e');
      return DocumentSendResult(
        success: false,
        error: 'Unexpected error: $e',
        shouldRetry: retryCount < 3,
      );
    }
  }

  // Send via WhatsApp
  Future<bool> _sendViaWhatsApp(
    MemberModel member,
    String documentType,
    PaymentModel? payment,
  ) async {
    try {
      switch (documentType) {
        case 'welcome':
          return await WhatsAppService.instance.sendWelcomePackage(member);
        case 'rejoin':
          return await WhatsAppService.instance.sendRejoinPackage(member);
        case 'receipt':
          if (payment != null) {
            return await WhatsAppService.instance
                .sendPaymentReceiptWithInvoice(member, payment);
          }
          return false;
        case 'resend':
          return await WhatsAppService.instance.resendDocuments(member);
        default:
          return false;
      }
    } catch (e) {
      debugPrint('WhatsApp send error: $e');
      return false;
    }
  }

  // Send via Email
  Future<bool> _sendViaEmail(
    MemberModel member,
    String documentType,
    PaymentModel? payment,
  ) async {
    try {
      final invoicePdf = await _pdfService.generateInvoice(member);
      final cardPdf = await _pdfService.generateMembershipCard(member);
      final invoiceFile = await _pdfService.savePDF(invoicePdf, 'invoice_${member.id}');
      final cardFile = await _pdfService.savePDF(cardPdf, 'card_${member.id}');

      return await _emailService.sendInvoiceEmail(
        recipientEmail: member.email,
        recipientName: member.name,
        memberId: member.id,
        invoicePdf: invoiceFile,
        membershipCardPdf: cardFile,
      );
    } catch (e) {
      debugPrint('Email sending error: $e');
      return false;
    }
  }

  // Log document history
  Future<void> _logDocumentHistory(
    MemberModel member,
    String documentType,
    String method,
  ) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final sentBy = currentUser?.email ?? 'System';

      final document = DocumentSentModel(
        type: documentType,
        sentAt: DateTime.now(),
        sentBy: sentBy,
        method: method,
        success: true,
      );

      final updatedHistory = [...member.documentHistory, document];
      final updatedMember = member.copyWith(documentHistory: updatedHistory);

      await _firestoreService.updateMember(updatedMember);
    } catch (e) {
      debugPrint('Error logging document history: $e');
      // Don't fail the whole operation if logging fails
    }
  }

  // Retry failed operation
  Future<DocumentSendResult> retryFailedOperation(
    BuildContext context,
    MemberModel member,
    String documentType,
    String method,
    PaymentModel? payment,
    int previousRetryCount,
  ) async {
    return await sendDocument(
      context: context,
      member: member,
      documentType: documentType,
      method: method,
      payment: payment,
      retryCount: previousRetryCount + 1,
    );
  }
}

// Result class
class DocumentSendResult {
  final bool success;
  final bool whatsappSent;
  final bool emailSent;
  final String? error;
  final bool shouldRetry;

  DocumentSendResult({
    required this.success,
    this.whatsappSent = false,
    this.emailSent = false,
    this.error,
    this.shouldRetry = false,
  });

  String get message {
    if (success) {
      String msg = 'Documents sent successfully! ';
      if (whatsappSent) msg += '📱 WhatsApp ';
      if (emailSent) msg += '📧 Email';
      return msg;
    } else {
      return error ?? 'Failed to send documents';
    }
  }
}
