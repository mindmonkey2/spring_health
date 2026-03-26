import 'package:flutter/material.dart';
import '../models/member_model.dart';
import '../models/payment_model.dart';
import '../services/whatsapp_service.dart';

class DocumentSendDialog extends StatelessWidget {
  final MemberModel member;
  final String documentType;
  final String title;
  final Widget content;
  final PaymentModel? payment;

  const DocumentSendDialog({
    super.key,
    required this.member,
    required this.documentType,
    required this.title,
    required this.content,
    this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: SingleChildScrollView(child: content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Skip'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context, true);

            try {
              switch (documentType) {
                case 'welcome':
                  await WhatsAppService.instance.sendWelcomePackage(member);
                  break;
                case 'rejoin':
                  await WhatsAppService.instance.sendRejoinPackage(member);
                  break;
                case 'receipt':
                  if (payment != null) {
                    // ✅ FIXED: Use payment! (non-null assertion)
                    await WhatsAppService.instance
                        .sendPaymentReceiptWithInvoice(member, payment!);
                  }
                  break;
                case 'resend':
                  await WhatsAppService.instance.resendDocuments(member);
                  break;
              }
            } catch (e) {
              debugPrint('Error sending document: $e');
            }
          },
          icon: const Icon(Icons.share),
          label: const Text('Send via WhatsApp'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
