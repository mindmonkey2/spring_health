import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../services/pdf_service.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/member_model.dart';
import '../models/payment_model.dart';
import '../utils/date_utils.dart' as app_date_utils;

class WhatsAppService {
  static final WhatsAppService instance = WhatsAppService._internal();

  WhatsAppService();

  WhatsAppService._internal();

  // ═══════════════════════════════════════════════════════════════
  // CORE MESSAGING (Text Only)
  // ═══════════════════════════════════════════════════════════════

  // Format phone number for WhatsApp (remove spaces, dashes, add country code)
  @visibleForTesting
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // If doesn't start with +, assume India (+91)
    if (!cleaned.startsWith('+')) {
      // Remove leading 0 if present
      if (cleaned.startsWith('0')) {
        cleaned = cleaned.substring(1);
      }
      cleaned = '+91$cleaned';
    }

    return cleaned;
  }

  // Send WhatsApp message
  Future<bool> sendMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final formattedPhone = formatPhoneNumber(phoneNumber);
      final encodedMessage = Uri.encodeComponent(message);

      // WhatsApp API URL
      final whatsappUrl = Uri.parse(
        'https://wa.me/$formattedPhone?text=$encodedMessage',
      );

      if (await canLaunchUrl(whatsappUrl)) {
        return await launchUrl(
          whatsappUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('Could not launch WhatsApp');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending WhatsApp message: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // TEXT-ONLY REMINDERS (No PDFs)
  // ═══════════════════════════════════════════════════════════════

  // Send Welcome Message to New Member (Text only)
  Future<bool> sendWelcomeMessage(MemberModel member) async {
    final message = '''
     *Welcome to Spring Health Studio!*

    Hi ${member.name}!

    Thank you for joining us! We're excited to have you as part of our fitness family.

    *Your Membership Details:*
     Member ID: ${member.id}
     Start Date: ${app_date_utils.DateUtils.formatDate(member.joiningDate)}
     Valid Till: ${app_date_utils.DateUtils.formatDate(member.expiryDate)}
     Plan: ${member.plan} - ${member.category}
    *Branch:* ${member.branch}

    *What's Next?*
    Check Visit us during gym hours
    Check Show your QR code at reception
    Check Start your fitness journey!

    Need help? Just reply to this message!

    Stay fit, stay healthy!

    *Spring Health Studio Team*
    ''';

    return await sendMessage(
      phoneNumber: member.phone,
      message: message,
    );
  }

  // Send Payment Receipt (Text only)
  Future<bool> sendPaymentReceipt({
    required MemberModel member,
    required PaymentModel payment,
  }) async {
    final message = '''
     *Payment Receipt*

    Hi ${member.name}!

    Thank you for your payment! Money

    *Payment Details:*
     Amount Paid: ₹${payment.amount.toStringAsFixed(2)}
     Date: ${app_date_utils.DateUtils.formatDate(payment.paymentDate)}
     Mode: ${payment.paymentMode}
    ${payment.cashAmount > 0 ? ' Cash: ₹${payment.cashAmount.toStringAsFixed(0)}\n' : ''}${payment.upiAmount > 0 ? 'Phone UPI: ₹${payment.upiAmount.toStringAsFixed(0)}\n' : ''}

    *Member Details:*
     ID: ${member.id}
     Valid Till: ${app_date_utils.DateUtils.formatDate(member.expiryDate)}
    ${member.dueAmount > 0 ? ' Pending Due: ₹${member.dueAmount.toStringAsFixed(0)}\n' : 'Check No Pending Dues\n'}

    Thank you for choosing Spring Health Studio!

    *${member.branch} Branch*
    ''';

    return await sendMessage(
      phoneNumber: member.phone,
      message: message,
    );
  }

  // Send Expiry Reminder (Text only)
  Future<bool> sendExpiryReminder(MemberModel member, int daysLeft) async {
    String emoji = daysLeft <= 1 ? 'Alert' : daysLeft <= 3 ? '' : 'Date';

    final message = '''
    $emoji *Membership Expiring Soon!* $emoji

    Hi ${member.name}!

    Your membership at *Spring Health Studio* is expiring soon!

    *Current Membership:*
     Valid Till: ${app_date_utils.DateUtils.formatDate(member.expiryDate)}
     Days Remaining: $daysLeft day${daysLeft > 1 ? 's' : ''}

    *Don't Miss Out!*
    Check Renew now to continue your fitness journey
    Check Contact us to renew your membership
    Check Visit our ${member.branch} branch

    Stay consistent, stay fit!

    *Spring Health Studio*
    ${member.branch} Branch
    ''';

    return await sendMessage(
      phoneNumber: member.phone,
      message: message,
    );
  }

  // Send Due Payment Reminder (Text only)
  Future<bool> sendDuePaymentReminder(MemberModel member) async {
    final message = '''
    Money *Payment Reminder* Money

    Hi ${member.name}!

    You have a pending payment at *Spring Health Studio*.

    *Payment Details:*
     Due Amount: ₹${member.dueAmount.toStringAsFixed(0)}
     Membership: ${app_date_utils.DateUtils.formatDate(member.joiningDate)} to ${app_date_utils.DateUtils.formatDate(member.expiryDate)}

    *Please clear your dues at the earliest.*

    Visit our ${member.branch} branch or contact us to make the payment.

    Thank you!

    *Spring Health Studio*
    ${member.branch} Branch
    ''';

    return await sendMessage(
      phoneNumber: member.phone,
      message: message,
    );
  }

  // Send Birthday Wish (Text only)
  Future<bool> sendBirthdayWish(MemberModel member) async {
    final message = '''
     *HAPPY BIRTHDAY!*

    Dear ${member.name}!

    Wishing you a fantastic birthday filled with joy, health, and happiness!

    May this year bring you:
     Stronger muscles
     Better stamina
     Great health
     Achieved fitness goals

    Thank you for being a valued member of our fitness family!

    Enjoy your special day!

    *Spring Health Studio Team*
    ${member.branch} Branch

    *PS:* Visit us today and get a special birthday surprise!
    ''';

    return await sendMessage(
      phoneNumber: member.phone,
      message: message,
    );
  }

  // Send Rejoin Message to Expired Members (Witty & Fun!)
  Future<bool> sendRejoinMessage(MemberModel member) async {
    // Calculate days since expiry
    final daysExpired = DateTime.now().difference(member.expiryDate).inDays;

    // Choose message based on how long expired
    String message;

    if (daysExpired <= 7) {
      // Recently expired (0-7 days)
      message = '''
       Hey ${member.name}!

      We noticed you're taking a little "break" from fitness...

      Your membership expired $daysExpired day${daysExpired > 1 ? 's' : ''} ago.

      *Don't let your gains become losses!*

       Your dumbbells miss you
       Your fitness goals are calling
       Your muscles are asking "Where is ${member.name}?"

      *Come back and let's continue your journey!*

      *Renew today at Spring Health Studio*
      ${member.branch} Branch

      PS: The treadmill asked about you yesterday. True story!
      ''';
    } else if (daysExpired <= 30) {
      // Expired 1-4 weeks
      message = '''
       ALERT: ${member.name} has gone missing!

      Last seen at Spring Health Studio: ${DateFormat('dd MMM yyyy').format(member.expiryDate)}

      *Missing Person Report:*
       Membership Status: Expired $daysExpired days ago
       Fitness Level: Probably watching Netflix
       Muscles: Getting smaller by the day

      *REWARDS FOR REJOINING:*
      Check Your favorite equipment is waiting
      Check Your workout playlist still works
      Check We promise not to judge your fitness level
      Check First week back = No one will ask "why so tired?"

      *Rejoin today and let's get you back on track!*

      *Spring Health Studio*
      ${member.branch} Branch

      PS: Your gym buddies are asking about you!
      ''';
    } else if (daysExpired <= 90) {
      // Expired 1-3 months
      final months = (daysExpired / 30).floor();
      message = '''
       Dear ${member.name},

      Remember us? *Spring Health Studio?*

      We used to hang out together... You'd lift weights, we'd cheer you on... Good times!

      *It's been $months month${months > 1 ? 's' : ''} since you left!*

      We get it, life happens:
      -  Coffee breaks became longer
      - Phone Netflix released new shows
      -  Your couch got more comfortable

      But guess what?
       *Your body still needs you!*
       *Your goals are still valid!*
       *We're still here, waiting!*

      *Special Comeback Offer:*
      Rejoin this week and get:
       Motivational high-five from receptionist (free!)
       "Welcome Back" celebratory nod from trainer
       Zero judgment, 100% support

      *Come back home to Spring Health Studio!*
      ${member.branch} Branch

      PS: We kept your favorite spot warm!
      ''';
    } else {
      // Expired more than 3 months
      final months = (daysExpired / 30).floor();
      message = '''
       A Letter to ${member.name}...

      Dear Long-Lost Gym Friend,

      It's been $months months. We're not mad, just disappointed...

      *Things that happened since you left:*
      - Your muscles went on vacation
      - Your gym clothes wondered if they're retired
      - The treadmill made new friends
      - We cried (okay, maybe not, but still!)

      *But here's the thing:*
       It's NEVER too late to come back!
       Fitness has no expiry date
       Every day is a fresh start
       We genuinely miss having you around!

      *Why Rejoin Spring Health Studio?*
      - Modern equipment (we upgraded! )
      - Friendly community (same warm vibes! )
      - Professional trainers (they remember you! )
      - Your branch, Your choice (${member.branch} is calling! Location)

      *Ready for your comeback story?*

      Visit us or call to renew your membership!

      *Spring Health Studio Team*
      ${member.branch} Branch

      PS: Seriously, ${member.name}, let's do this! Your future self will thank you!
      ''';
    }

    return await sendMessage(
      phoneNumber: member.phone,
      message: message,
    );
  }

  // Send Custom Message
  Future<bool> sendCustomMessage({
    required String phoneNumber,
    required String memberName,
    required String customMessage,
    String? branch,
  }) async {
    final message = '''
    Hi $memberName!

    $customMessage

    *Spring Health Studio*
    ${branch ?? 'Team'}
    ''';

    return await sendMessage(
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PDF ATTACHMENT METHODS (Transaction Documents Only)
  // ═══════════════════════════════════════════════════════════════

  /// Send Welcome Package with Invoice + Membership Card (For New Members)
  Future<bool> sendWelcomePackage(MemberModel member) async {
    try {
      final pdfService = PDFService();

      // Generate both PDFs
      final invoiceBytes = await pdfService.generateInvoice(member);
      final cardBytes = await pdfService.generateMembershipCard(member);

      final tempDir = await getTemporaryDirectory();
      final invoiceFile = File('${tempDir.path}/Invoice_${member.id}.pdf');
      final cardFile = File('${tempDir.path}/Membership_Card_${member.id}.pdf');

      await invoiceFile.writeAsBytes(invoiceBytes);
      await cardFile.writeAsBytes(cardBytes);

      final message = '''
       *Welcome to Spring Health Studio!*

      Hi ${member.name}!

      Thank you for joining us! We're excited to have you as part of our fitness family.

       *Your Membership Details:*
      • Member ID: ${member.id}
      • Start Date: ${app_date_utils.DateUtils.formatDate(member.joiningDate)}
      • Valid Till: ${app_date_utils.DateUtils.formatDate(member.expiryDate)}
      • Plan: ${member.plan} - ${member.category}
      • Branch: ${member.branch}

      Attachment *Documents Attached:*
      1⃣ Payment Invoice
      2⃣ Digital Membership Card

       *What's Next?*
      Check Visit us during gym hours
      Check Show your QR code at reception
      Check Start your fitness journey!

      Need help? Just reply to this message!

      Stay fit, stay healthy!

      *Spring Health Studio Team*
      ${member.branch} Branch
      ''';

      await Share.shareXFiles(
        [XFile(invoiceFile.path), XFile(cardFile.path)],
        text: message,
        subject: 'Welcome to Spring Health Studio',
      );

      return true;
    } catch (e) {
      debugPrint('Error sending welcome package: $e');
      return false;
    }
  }

  /// Send Rejoin Package with Invoice + Membership Card
  Future<bool> sendRejoinPackage(MemberModel member) async {
    try {
      final pdfService = PDFService();

      // Generate both PDFs
      final invoiceBytes = await pdfService.generateInvoice(member);
      final cardBytes = await pdfService.generateMembershipCard(member);

      final tempDir = await getTemporaryDirectory();
      final invoiceFile = File('${tempDir.path}/Rejoin_Invoice_${member.id}.pdf');
      final cardFile = File('${tempDir.path}/Rejoin_Card_${member.id}.pdf');

      await invoiceFile.writeAsBytes(invoiceBytes);
      await cardFile.writeAsBytes(cardBytes);

      final message = '''
       *Welcome Back to Spring Health Studio!*

      Hi ${member.name}!

      We're thrilled to have you back! Your fitness journey continues!

       *Renewed Membership Details:*
      • Member ID: ${member.id}
      • Renewal Date: ${app_date_utils.DateUtils.formatDate(member.joiningDate)}
      • Valid Till: ${app_date_utils.DateUtils.formatDate(member.expiryDate)}
      • Plan: ${member.plan} - ${member.category}
      • Branch: ${member.branch}

      Attachment *Documents Attached:*
      1⃣ Payment Invoice
      2⃣ Updated Membership Card

       *Ready to Get Back in Shape?*
      Check Visit us anytime during gym hours
      Check Show your QR code at reception
      Check Let's achieve your goals together!

      Your comeback story starts now!

      *Spring Health Studio Team*
      ${member.branch} Branch
      ''';

      await Share.shareXFiles(
        [XFile(invoiceFile.path), XFile(cardFile.path)],
        text: message,
        subject: 'Welcome Back - Membership Renewed',
      );

      return true;
    } catch (e) {
      debugPrint('Error sending rejoin package: $e');
      return false;
    }
  }

  /// Send Payment Receipt with Invoice PDF (After Due Payment)
  Future<bool> sendPaymentReceiptWithInvoice(
    MemberModel member,
    PaymentModel payment,
  ) async {
    try {
      final pdfService = PDFService();

      // Generate invoice PDF
      final invoiceBytes = await pdfService.generateInvoice(member);
      final tempDir = await getTemporaryDirectory();
      final invoiceFile = File('${tempDir.path}/Payment_Receipt_${payment.id}.pdf');
      await invoiceFile.writeAsBytes(invoiceBytes);

      final message = '''
      Check *Payment Receipt*

      Hi ${member.name}!

      Thank you for your payment!

      Money *Payment Details:*
      • Amount Paid: ₹${payment.amount.toStringAsFixed(0)}
      • Date: ${app_date_utils.DateUtils.formatDate(payment.paymentDate)}
      • Mode: ${payment.paymentMode}
      ${payment.paymentMode == 'Mixed' ? '  • Cash: ₹${payment.cashAmount.toStringAsFixed(0)}\n  • UPI: ₹${payment.upiAmount.toStringAsFixed(0)}' : ''}

       *Member Details:*
      • ID: ${member.id}
      • Valid Till: ${app_date_utils.DateUtils.formatDate(member.expiryDate)}
      ${member.dueAmount > 0 ? '• Remaining Due: ₹${member.dueAmount.toStringAsFixed(0)}' : '• Check No Pending Dues'}

      Attachment *Invoice Attached*

      Thank you for choosing Spring Health Studio!

      *Spring Health Studio*
      ${member.branch} Branch
      ''';

      await Share.shareXFiles(
        [XFile(invoiceFile.path)],
        text: message,
        subject: 'Payment Receipt',
      );

      return true;
    } catch (e) {
      debugPrint('Error sending payment receipt with invoice: $e');
      return false;
    }
  }

  /// Resend Documents (Manual from Member Detail Screen)
  Future<bool> resendDocuments(MemberModel member) async {
    try {
      final pdfService = PDFService();

      // Generate both PDFs
      final invoiceBytes = await pdfService.generateInvoice(member);
      final cardBytes = await pdfService.generateMembershipCard(member);

      final tempDir = await getTemporaryDirectory();
      final invoiceFile = File('${tempDir.path}/Invoice_${member.id}.pdf');
      final cardFile = File('${tempDir.path}/Membership_Card_${member.id}.pdf');

      await invoiceFile.writeAsBytes(invoiceBytes);
      await cardFile.writeAsBytes(cardBytes);

      final message = '''
       *Membership Documents*

      Hi ${member.name}!

      As requested, here are your membership documents from *Spring Health Studio*.

       *Current Membership:*
      • Member ID: ${member.id}
      • Valid Till: ${app_date_utils.DateUtils.formatDate(member.expiryDate)}
      • Plan: ${member.plan} - ${member.category}
      • Status: ${member.isActive ? 'Check Active' : ' Expired'}
      • Branch: ${member.branch}

      Attachment *Documents Attached:*
      1⃣ Invoice
      2⃣ Membership Card

      If you need any assistance, feel free to contact us!

      *Spring Health Studio*
      ${member.branch} Branch
      ''';

      await Share.shareXFiles(
        [XFile(invoiceFile.path), XFile(cardFile.path)],
        text: message,
        subject: 'Membership Documents',
      );

      return true;
    } catch (e) {
      debugPrint('Error resending documents: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILITIES
  // ═══════════════════════════════════════════════════════════════

  // Check if WhatsApp is installed
  Future<bool> isWhatsAppInstalled() async {
    try {
      final whatsappUrl = Uri.parse('https://wa.me/');
      return await canLaunchUrl(whatsappUrl);
    } catch (e) {
      return false;
    }
  }
}
