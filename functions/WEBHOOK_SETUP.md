---
# Razorpay Webhook Setup

## Step 1 — Set the webhook secret in Firebase
firebase functions:secrets:set RAZORPAY_WEBHOOK_SECRET
Enter the webhook secret from your Razorpay dashboard when prompted.

## Step 2 — Deploy the function
firebase deploy --only functions

## Step 3 — Configure the webhook URL in Razorpay Dashboard
1. Go to Razorpay Dashboard → Settings → Webhooks
2. Add webhook URL:
   https://us-central1-spring-health-studio-f4930.cloudfunctions.net/razorpayWebhook
3. Select event: payment.captured
4. Enter the same secret used in Step 1
5. Save

## Step 4 — Verify in Firebase Console
After a test payment, check:
- Firestore → payments collection for a new doc with paymentSource: 'webhook'
- Cloud Functions logs for 'Webhook processed successfully'
---
