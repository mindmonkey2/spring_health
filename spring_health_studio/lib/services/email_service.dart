import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/foundation.dart';

class EmailService {
  // Configure your SMTP settings here using String.fromEnvironment for security
  static const String _username = String.fromEnvironment('SMTP_USERNAME');
  static const String _password = String.fromEnvironment('SMTP_PASSWORD');

  Future<bool> sendInvoiceEmail({
    required String recipientEmail,
    required String recipientName,
    required String memberId,
    required File invoicePdf,
    required File membershipCardPdf,
  }) async {
    if (_username.isEmpty || _password.isEmpty) {
      if (kDebugMode) {
        debugPrint('❌ SMTP credentials not configured. Please build with --dart-define=SMTP_USERNAME=... and --dart-define=SMTP_PASSWORD=...');
      }
      return false;
    }

    try {
      // Configure SMTP server (Gmail)
      final smtpServer = gmail(_username, _password);

      // Create message
      final message = Message()
      ..from = const Address(_username, 'Spring Health Studio')
      ..recipients.add(recipientEmail)
      ..subject = 'Welcome to Spring Health Studio - Membership Details'
      ..html = _buildEmailBody(recipientName, memberId)
      ..attachments = [
        // ✅ FIXED: Proper way to set FileAttachment properties
        FileAttachment(invoicePdf)
        ..contentType = 'application/pdf'
        ..fileName = 'Invoice_$memberId.pdf',
        FileAttachment(membershipCardPdf)
        ..contentType = 'application/pdf'
        ..fileName = 'MembershipCard_$memberId.pdf',
      ];

      // Send email with timeout
      final sendReport = await send(message, smtpServer, timeout: const Duration(seconds: 30));

      if (kDebugMode) {
        debugPrint('✅ Email sent successfully to $recipientEmail');
        debugPrint('Send report: ${sendReport.toString()}');
      }

      return true;
    } on MailerException catch (e) {
      // Better error handling for mailer-specific exceptions
      if (kDebugMode) {
        debugPrint('❌ MailerException: ${e.toString()}');
        for (var p in e.problems) {
          debugPrint('Problem: ${p.code}: ${p.msg}');
        }
      }
      return false;
    } on SocketException catch (e) {
      // Network issues
      if (kDebugMode) {
        debugPrint('❌ Network error: ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error sending email: $e');
      }
      return false;
    }
  }

  String _buildEmailBody(String name, String memberId) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
    <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header {
    background: linear-gradient(135deg, #10B981 0%, #14B8A6 100%);
    color: white; padding: 30px; text-align: center; border-radius: 10px;
  }
  .content {
  padding: 20px; background: #f9f9f9; margin-top: 20px;
  border-radius: 10px; border-left: 4px solid #10B981;
  }
  .footer { text-align: center; margin-top: 20px; font-size: 12px; color: #666; }
  .info-box {
  background: #d1fae5;
  padding: 15px;
  border-radius: 8px;
  margin: 15px 0;
  border-left: 4px solid #10B981;
  }
  h1 { margin: 0; font-size: 28px; }
  h2 { color: #10B981; margin-top: 0; }
  ul { padding-left: 20px; }
  li { margin: 8px 0; }
  </style>
  </head>
  <body>
  <div class="container">
  <div class="header">
  <h1>🏋️ SPRING HEALTH STUDIO</h1>
  <p style="margin: 5px 0 0 0; font-size: 14px;">Your Wellness Journey Begins</p>
  </div>

  <div class="content">
  <h2>Welcome, $name! 🎉</h2>
  <p>Thank you for joining Spring Health Studio. We're excited to have you as part of our fitness family!</p>

  <div class="info-box">
  <p style="margin: 0;"><strong>📋 Your Membership ID:</strong> <span style="font-size: 18px; color: #10B981;">$memberId</span></p>
  </div>

  <p><strong>📎 Attached Documents:</strong></p>
  <ul>
  <li><strong>Invoice</strong> - Your payment receipt and membership details</li>
  <li><strong>Membership Card</strong> - Present this at the gym for check-in</li>
  </ul>

  <h3 style="color: #10B981;">📌 Important Notes:</h3>
  <ul>
  <li>Keep your membership card handy for QR code scanning at check-in</li>
  <li>You can print your membership card or show the digital version</li>
  <li>Contact your branch reception for any queries</li>
  <li>Arrive 10 minutes early for your first visit for a gym orientation</li>
  </ul>

  <p style="font-size: 16px; font-weight: bold; color: #10B981; margin-top: 20px;">
  💪 Let's achieve your fitness goals together!
  </p>
  </div>

  <div class="footer">
  <p style="font-weight: bold; color: #10B981;">Spring Health Studio</p>
  <p>Warangal & Hanamkonda Branches</p>
  <p style="font-size: 11px; color: #999;">This is an automated email. Please do not reply.</p>
  </div>
  </div>
  </body>
  </html>
  ''';
  }
}
