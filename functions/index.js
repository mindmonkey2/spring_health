const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();

// Send notification when announcement is created
exports.sendAnnouncementNotification = onDocumentCreated(
  "announcements/{announcementId}",
  async (event) => {
    const announcement = event.data.data();
    const announcementId = event.params.announcementId;

    console.log("📢 New announcement created:", announcement.title);

    try {
      // Get target branches
      const targetBranches = announcement.targetBranches || ["all"];

      // Build notification payload
      const payload = {
        notification: {
          title: announcement.title || "New Announcement",
          body: announcement.message || "Tap to view details",
        },
        data: {
          announcementId: announcementId,
          type: "announcement",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
          priority: "high",
          notification: {
            channelId: "high_importance_channel",
            color: "#CDFF00",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      };

      // Send to topics based on target branches
      const promises = [];

      if (targetBranches.includes("all")) {
        // Send to all members
        console.log("📤 Sending to topic: announcements_all");
        promises.push(
          admin.messaging().sendToTopic("announcements_all", payload),
        );
      } else {
        // Send to specific branches
        for (const branch of targetBranches) {
          const topic = "announcements_" +
          branch.toLowerCase().replace(/\s+/g, "_");
          console.log("📤 Sending to topic:", topic);
          promises.push(
            admin.messaging().sendToTopic(topic, payload),
          );
        }
      }

      // Wait for all notifications to send
      const results = await Promise.all(promises);

      console.log("✅ Notifications sent successfully:", results.length);
      return results;
    } catch (error) {
      console.error("❌ Error sending notification:", error);
      return null;
    }
  },
);

// Optional: Send notification to specific member
exports.sendPersonalNotification = onCall(async (request) => {
  // 1. Authentication check
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "The function must be called while authenticated.");
  }

  // 2. Authorization check (Only staff can send personal notifications)
  const callerUid = request.auth.uid;
  const userDoc = await admin.firestore().collection("users").doc(callerUid).get();
  const userData = userDoc.data();
  const role = userData ? userData.role : null;

  if (role !== "owner" && role !== "receptionist") {
    throw new HttpsError("permission-denied", "Only staff members can send personal notifications.");
  }

  // 3. Input validation
  const memberId = request.data.memberId;
  const title = request.data.title;
  const body = request.data.body;

  if (!memberId || typeof memberId !== "string") {
    throw new HttpsError("invalid-argument", "The 'memberId' must be a non-empty string.");
  }
  if (!title || typeof title !== "string") {
    throw new HttpsError("invalid-argument", "The 'title' must be a non-empty string.");
  }
  if (!body || typeof body !== "string") {
    throw new HttpsError("invalid-argument", "The 'body' must be a non-empty string.");
  }

  try {
    // Get member's FCM token
    const memberDoc = await admin.firestore()
      .collection("members")
      .doc(memberId)
      .get();

    const memberData = memberDoc.data();
    const fcmToken = memberData ? memberData.fcmToken : null;

    if (!fcmToken) {
      throw new HttpsError("not-found", "Member does not have an FCM token.");
    }

    const message = {
      notification: {
        title: title,
        body: body,
      },
      token: fcmToken,
    };

    const response = await admin.messaging().send(message);
    console.log("✅ Personal notification sent:", response);
    return {success: true, messageId: response};
  } catch (error) {
    console.error("❌ Error sending personal notification:", error);
    if (error instanceof HttpsError) {
      throw error;
    }
    throw new HttpsError("internal", "An internal error occurred while sending the notification.");
  }
});

const crypto = require("crypto");
const express = require("express");
const { onRequest } = require("firebase-functions/v2/https");

const app = express();

app.use(express.raw({ type: "application/json" }));

app.post("/", async (req, res) => {
  try {
    const rawBody = req.body;
    const signature = req.headers["x-razorpay-signature"];
    const secret = process.env.RAZORPAY_WEBHOOK_SECRET;

    if (!secret) {
      console.error("Missing RAZORPAY_WEBHOOK_SECRET");
      return res.status(500).send("Configuration error");
    }

    if (!signature) {
      return res.status(400).send("Missing signature");
    }

    const expectedSignature = crypto
      .createHmac("sha256", secret)
      .update(rawBody)
      .digest("hex");

    if (
      !crypto.timingSafeEqual(
        Buffer.from(signature),
        Buffer.from(expectedSignature)
      )
    ) {
      return res.status(400).send("Invalid signature");
    }

    const event = JSON.parse(rawBody.toString());

    if (event.event !== "payment.captured") {
      return res.status(200).send("Event ignored");
    }

    const entity = event.payload.payment.entity;
    const razorpayPaymentId = entity.id;
    const memberId = entity.notes ? entity.notes.memberId : null;
    const planName = entity.notes ? entity.notes.planName : null;
    const amount = entity.amount / 100;
    const currency = entity.currency;

    if (!memberId) {
      return res.status(400).send("Missing memberId");
    }

    const db = admin.firestore();

    const paymentQuery = await db
      .collection("payments")
      .where("razorpayPaymentId", "==", razorpayPaymentId)
      .limit(1)
      .get();

    if (!paymentQuery.empty) {
      console.log("Duplicate webhook, skipping");
      return res.status(200).send("Already processed");
    }

    const memberRef = db.collection("members").doc(memberId);
    const memberDoc = await memberRef.get();

    if (!memberDoc.exists) {
      return res.status(400).send("Member not found");
    }

    const memberData = memberDoc.data();
    const currentExpiry = memberData.expiryDate ? memberData.expiryDate.toDate() : new Date();
    const now = new Date();

    const baseDate = currentExpiry < now ? now : currentExpiry;

    let planDays = 30;
    if (planName === "1 Month") planDays = 30;
    else if (planName === "3 Months") planDays = 90;
    else if (planName === "6 Months") planDays = 180;
    else if (planName === "12 Months") planDays = 365;
    else console.warn("Unrecognised planName, defaulting to 30 days:", planName);

    const newExpiry = new Date(baseDate.getTime() + planDays * 24 * 60 * 60 * 1000);

    const batch = db.batch();

    const paymentRef = db.collection("payments").doc();
    batch.set(paymentRef, {
      memberId: memberId,
      razorpayPaymentId: razorpayPaymentId,
      amount: amount,
      currency: currency,
      planName: planName || "",
      paymentMode: "razorpay_webhook",
      paymentSource: "webhook",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      branch: memberData.branch ?? "",
    });

    batch.update(memberRef, {
      expiryDate: admin.firestore.Timestamp.fromDate(newExpiry),
      isActive: true,
      lastPaymentDate: admin.firestore.FieldValue.serverTimestamp(),
      dueAmount: 0,
    });

    await batch.commit();

    return res.status(200).send("OK");
  } catch (error) {
    console.error("Webhook error:", error);
    return res.status(500).send("Error");
  }
});

app.all("*", (req, res) => {
  res.status(405).send("Method Not Allowed");
});

exports.razorpayWebhook = onRequest(
  { secrets: ["RAZORPAY_WEBHOOK_SECRET"] },
  app
);
