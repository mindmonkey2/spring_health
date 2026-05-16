# T16-1: Razorpay Integration Audit & Plan

## A. Existing files involved

**Spring Health Studio (Admin/Reception)**
- `lib/models/payment_model.dart`: Defines `PaymentModel`, fields like `amount`, `paymentMode`, `type` (initial, renewal, due), etc.
- `lib/services/firestore_service.dart`: Handles `addPayment(PaymentModel)` writes to Firestore.
- `lib/screens/members/add_member_screen.dart`: Flow to add member & collect initial payment.
- `lib/screens/members/rejoin_member_screen.dart`: Flow for inactive members returning, creates `type: 'renewal'` payment.
- `lib/screens/members/edit_member_screen.dart`: Alternate flow that can create `type: 'renewal'` payment.
- `lib/screens/members/collect_dues_screen.dart`: Collects pending balances (`type: 'due'`).
- `lib/screens/members/member_detail_screen.dart`: Shows payment history & handles due payment reminders via WhatsApp.
- `lib/screens/reports/reports_screen.dart`: Renders payment collections by staff for daily accounting.

**Spring Health Member App (Client)**
- `lib/models/payment_model.dart`: Differing schema from Studio (`planName`, `status`, `membershipStartDate`, etc. but missing `discount`, `type`).
- `lib/services/payment_service.dart`: Fetches payment history from `/payments` where `memberId` matches.
- `lib/services/renewal_service.dart`: Existing `processSuccessfulRenewal` function handling Razorpay success callback and writing batch updates to `/payments` and `/members`.
- `lib/screens/renewal/renewal_screen.dart`: Existing Razorpay UI integration (`_openRazorpay`, `_onPaymentSuccess`) already capturing plan prices, emitting `razorpayPaymentId`.
- `lib/screens/payments/payment_history_screen.dart`: Renders `PaymentModel` objects for members.
- `lib/screens/home/widgets/membership_expiry_banner.dart`: Triggers a bottom sheet showing manual renewal steps.
- `lib/screens/lockout/membership_expired_screen.dart`: Lockout screen showing manual renewal steps.

## B. Current flow

**Manual renewal in Studio today:**
1. A receptionist uses `rejoin_member_screen.dart` (or `edit_member_screen.dart` if extending) to find an expired or expiring member.
2. They enter new dates, total fee, discount, cash/UPI amounts.
3. Upon save, `_firestoreService.updateMember()` is called to update `expiryDate`, `isActive`, etc., and `_firestoreService.addPayment()` writes a new `PaymentModel` (type: 'renewal') to the `payments` collection.

**Member payment history in Member App:**
1. The app queries the global `payments` collection filtering by `memberId`.
2. It parses documents using the Member App's `PaymentModel` which expects fields like `planName`, `status`, `membershipStartDate`, etc. (Note: These often don't align with Studio's `PaymentModel`).

**Membership dates extension:**
1. Only the Studio modifies `expiryDate` on the `/members/{memberId}` document directly during manual renewal workflows.
2. The Member App *has* a `processSuccessfulRenewal` function in `renewal_service.dart` that optimistically writes an extended `expiryDate` to `/members/{memberId}` directly from the client.

## C. Razorpay insertion points

**Studio initiation:**
- Currently, there is no UI to initiate a remote payment link from the Studio. It relies on in-person cash/UPI.
- A "Generate Payment Link" button could be added to `member_detail_screen.dart` and `collect_dues_screen.dart` to push a pending payment intent or send a direct link via WhatsApp.

**Member App UI:**
- `renewal_screen.dart` already contains functional Razorpay SDK bindings (`_openRazorpay`, `_onPaymentSuccess`).
- Entry points: Update `membership_expiry_banner.dart` and `membership_expired_screen.dart` to navigate to `RenewalScreen` instead of showing instructions for manual, in-person renewal.

**Verification / Renewal writeback:**
- *Current:* Member App writes directly to `/payments` and `/members` in `_onPaymentSuccess` inside `renewal_screen.dart` / `renewal_service.dart`.
- *Required:* A cloud-based verification layer (Firebase Cloud Function) must intercept a webhook from Razorpay, verify the signature, and perform the authoritative database writes to `/members` and `/payments`. The Member App should only *initiate* the payment and await verification.

## D. Proposed T16 task split

1. **T16-1: Audit** (Complete - This document)
2. **T16-2: Data Model Unification:** Align `PaymentModel` between Studio and Member App to prevent parsing errors and ensure all necessary fields (e.g., `razorpayPaymentId`, `status`, `type`) exist in both projects.
3. **T16-3: Member App UI Activation:** Connect the existing `RenewalScreen` to `MembershipExpiryBanner` and `MembershipExpiredScreen`. Remove manual step bottom sheets. Test UI flow (mocking success).
4. **T16-4: Backend Verification (Functions):** Implement Razorpay webhook handler in Firebase Cloud Functions (or a secure server-side equivalent) to perform the authoritative `expiryDate` extension and `payment` creation.
5. **T16-5: Client Trust Removal:** Modify Member App's `RenewalService` to stop performing optimistic writes to `/members` and `/payments`. It should only verify the webhook has processed the payment.
6. **T16-6: Studio Initiation (Optional but recommended):** Add "Send Payment Link" functionality in Studio for receptionists to remotely request dues or renewals.
7. **T16-7: Testing & Documentation:** End-to-end testing of full Razorpay flow, handling failures/rollbacks, update living docs.

## E. Risks / blockers

- **Client-Side Trust Issue (Critical):** `spring_health_member_app/lib/services/renewal_service.dart` currently performs direct writes to `members` and `payments` collections based on a client-side Razorpay success callback. This is insecure and can be bypassed by a malicious client. Must transition to server-side webhook verification.
- **Model Desync:** The `PaymentModel` in Studio is significantly different from the one in the Member App. The Member App expects fields (`membershipStartDate`, `status`, `planName`) that Studio doesn't reliably write, and Studio uses fields (`discount`, `type`) the Member App ignores. This causes rendering issues or data loss.
- **`memberId` vs `auth.uid`:** Any server-side webhook logic MUST carefully distinguish between the `auth.uid` of the user and their admin-assigned `memberId` to ensure the correct document is updated.
- **Duplicate Payment Writes:** If both the client app optimistically writes a payment *and* the server-side webhook writes a payment, duplicates will appear. The client write must be removed.
- **Rollback / Failed Handling:** The client must gracefully handle scenarios where Razorpay succeeds on the device, but network connectivity fails before the webhook is processed or verified. It must poll or rely on a real-time listener on the member document to unlock the UI.
