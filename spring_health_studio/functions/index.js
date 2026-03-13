// functions/index.js
// Spring Health Studio — Firebase Cloud Functions (v2)
// Project: spring-health-studio-f4930

const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {
  onDocumentCreated,
  onDocumentUpdated,
} = require("firebase-functions/v2/firestore");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const nodemailer = require("nodemailer");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ── Gmail SMTP ──────────────────────────────────────────────────────────────
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "springhealthstudio12@gmail.com",
    pass: "sqlj ipyx avpe kfag",
  },
});

// ═══════════════════════════════════════════════════════════════════════════
// 1. SEND INVOICE EMAIL
// ═══════════════════════════════════════════════════════════════════════════
exports.sendInvoiceEmail = onCall(async (request) => {
  try {
    const {
      recipientEmail,
      recipientName,
      memberId,
      invoicePdfBase64,
      membershipCardPdfBase64,
    } = request.data;

    const invoiceBuffer = Buffer.from(invoicePdfBase64, "base64");
    const cardBuffer = Buffer.from(membershipCardPdfBase64, "base64");

    const mailOptions = {
      from: "Spring Health Studio <springhealthstudio12@gmail.com>",
      to: recipientEmail,
      subject: "Welcome to Spring Health Studio - Membership Details",
      html: buildWelcomeEmailBody(recipientName, memberId),
      attachments: [
        {
          filename: `Invoice_${memberId}.pdf`,
          content: invoiceBuffer,
          contentType: "application/pdf",
        },
        {
          filename: `MembershipCard_${memberId}.pdf`,
          content: cardBuffer,
          contentType: "application/pdf",
        },
      ],
    };

    const info = await transporter.sendMail(mailOptions);
    console.log("Invoice email sent:", info.messageId);
    return {success: true, message: "Email sent successfully"};
  } catch (error) {
    console.error("Error sending invoice email:", error);
    throw new HttpsError("internal", error.message);
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// 2. SEND EXPIRY REMINDER EMAIL
// ═══════════════════════════════════════════════════════════════════════════
exports.sendExpiryReminderEmail = onCall(async (request) => {
  try {
    const {
      recipientEmail,
      recipientName,
      expiryDate,
      daysLeft,
      branch,
    } = request.data;

    const mailOptions = {
      from: "Spring Health Studio <springhealthstudio12@gmail.com>",
      to: recipientEmail,
      subject: `Your Membership Expires in ${daysLeft} Day${daysLeft !== 1 ? "s" : ""} — Spring Health Studio`,
      html: buildExpiryEmailBody(recipientName, expiryDate, daysLeft, branch),
    };

    await transporter.sendMail(mailOptions);
    return {success: true};
  } catch (error) {
    console.error("Error sending expiry email:", error);
    throw new HttpsError("internal", error.message);
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// 3. SEND PAYMENT RECEIPT EMAIL
// ═══════════════════════════════════════════════════════════════════════════
exports.sendPaymentReceiptEmail = onCall(async (request) => {
  try {
    const {
      recipientEmail,
      recipientName,
      memberId,
      amount,
      paymentMode,
      paymentType,
      branch,
      newExpiryDate,
      receiptPdfBase64,
    } = request.data;

    const attachments = [];
    if (receiptPdfBase64) {
      attachments.push({
        filename: `Receipt_${memberId}_${Date.now()}.pdf`,
        content: Buffer.from(receiptPdfBase64, "base64"),
        contentType: "application/pdf",
      });
    }

    const mailOptions = {
      from: "Spring Health Studio <springhealthstudio12@gmail.com>",
      to: recipientEmail,
      subject: "Payment Confirmed — Spring Health Studio",
      html: buildPaymentReceiptBody(
        recipientName,
        memberId,
        amount,
        paymentMode,
        paymentType,
        branch,
        newExpiryDate,
      ),
      attachments,
    };

    await transporter.sendMail(mailOptions);
    return {success: true};
  } catch (error) {
    console.error("Error sending receipt email:", error);
    throw new HttpsError("internal", error.message);
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// 4. SEND CUSTOM ADMIN EMAIL
// ═══════════════════════════════════════════════════════════════════════════
exports.sendAdminEmail = onCall(async (request) => {
  try {
    const {recipientEmail, recipientName, subject, htmlBody} = request.data;

    const mailOptions = {
      from: "Spring Health Studio <springhealthstudio12@gmail.com>",
      to: recipientEmail,
      subject: subject,
      html: wrapInBaseTemplate(recipientName, htmlBody),
    };

    await transporter.sendMail(mailOptions);
    return {success: true};
  } catch (error) {
    console.error("Error sending admin email:", error);
    throw new HttpsError("internal", error.message);
  }
});

// ═══════════════════════════════════════════════════════════════════════════
// 5. FCM PUSH NOTIFICATION SENDER
//    Firestore trigger: notificationsQueue/{docId}
// ═══════════════════════════════════════════════════════════════════════════
exports.sendPushNotification = onDocumentCreated(
  "notificationsQueue/{docId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return null;
    const data = snap.data();
    if (data.sent === true) return null;

    const {title, body, targetType, targetId, targetBranch, type} = data;

    try {
      let memberDocs = [];

      if (targetType === "all") {
        const result = await db
          .collection("members")
          .where("isActive", "==", true)
          .get();
        memberDocs = result.docs;
      } else if (targetType === "branch") {
        const result = await db
          .collection("members")
          .where("branch", "==", targetBranch)
          .where("isActive", "==", true)
          .get();
        memberDocs = result.docs;
      } else if (targetType === "member") {
        const doc = await db.collection("members").doc(targetId).get();
        if (doc.exists) memberDocs = [doc];
      }

      const validMembers = memberDocs.filter(
        (d) => d.data().fcmToken && d.data().fcmToken.length > 10,
      );

      if (validMembers.length === 0) {
        console.log("No valid FCM tokens for target:", targetType);
        await snap.ref.update({
          sent: true,
          sentAt: admin.firestore.FieldValue.serverTimestamp(),
          tokenCount: 0,
          successCount: 0,
          failureCount: 0,
        });
        return null;
      }

      const tokens = validMembers.map((d) => d.data().fcmToken);
      let successCount = 0;
      let failureCount = 0;
      const batchSize = 500;

      for (let i = 0; i < tokens.length; i += batchSize) {
        const batch = tokens.slice(i, i + batchSize);
        const response = await messaging.sendEachForMulticast({
          tokens: batch,
          notification: {title, body},
          data: {
            type: type != null ? type : "announcement",
            targetType: targetType != null ? targetType : "all",
            targetId: targetId != null ? targetId : "",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          android: {
            priority: "high",
            notification: {
              sound: "default",
              channelId: "high_importance_channel",
              color: "#10B981",
            },
          },
          apns: {
            payload: {aps: {sound: "default", badge: 1}},
          },
        });

        successCount += response.successCount;
        failureCount += response.failureCount;

        // Clean stale tokens
        response.responses.forEach((res, idx) => {
          if (
            !res.success &&
            (res.error.code === "messaging/invalid-registration-token" ||
              res.error.code === "messaging/registration-token-not-registered")
          ) {
            const staleToken = batch[idx];
            db.collection("members")
              .where("fcmToken", "==", staleToken)
              .get()
              .then((s) => {
                s.docs.forEach((d) =>
                  d.ref.update({
                    fcmToken: admin.firestore.FieldValue.delete(),
                  }),
                );
              });
          }
        });
      }

      // Write to in-app notifications feed for each member
      const firestoreBatch = db.batch();
      for (const memberDoc of validMembers) {
        const notifRef = db
          .collection("notifications")
          .doc(memberDoc.id)
          .collection("items")
          .doc();
        firestoreBatch.set(notifRef, {
          type: type != null ? type : "announcement",
          title,
          body,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          metadata: {sentByAdmin: true, targetType},
        });
      }
      await firestoreBatch.commit();

      await snap.ref.update({
        sent: true,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        successCount,
        failureCount,
        tokenCount: tokens.length,
      });

      await db.collection("notificationHistory").add({
        title,
        body,
        targetType,
        targetBranch: targetBranch != null ? targetBranch : null,
        targetId: targetId != null ? targetId : null,
        type: type != null ? type : "announcement",
        successCount,
        failureCount,
        tokenCount: tokens.length,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        sent: true,
        sentBy: data.sentBy != null ? data.sentBy : "admin",
      });

      console.log(`FCM: ${successCount} success, ${failureCount} failed`);
      return null;
    } catch (error) {
      console.error("FCM send error:", error);
      await snap.ref.update({
        sent: false,
        error: error.message,
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return null;
    }
  },
);

// ═══════════════════════════════════════════════════════════════════════════
// 6. SCHEDULED DAILY REMINDERS — 9:00 AM IST
// ═══════════════════════════════════════════════════════════════════════════
exports.scheduledDailyReminders = onSchedule(
  {schedule: "0 3 * * *", timeZone: "Asia/Kolkata"},
  async () => {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const results = {expiry_7d: 0, expiry_3d: 0, expiry_1d: 0, dues: 0, errors: 0};

    try {
      const membersSnap = await db
        .collection("members")
        .where("isActive", "==", true)
        .get();

      const fcmPayloads = [];

      for (const doc of membersSnap.docs) {
        const m = doc.data();
        if (!m.fcmToken) continue;

        const expiryDate = m.expiryDate && m.expiryDate.toDate
          ? m.expiryDate.toDate()
          : null;

        if (expiryDate) {
          const daysLeft = Math.ceil(
            (expiryDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24),
          );
          if ([7, 3, 1].includes(daysLeft)) {
            fcmPayloads.push({
              token: m.fcmToken,
              memberId: doc.id,
              title: `Membership expires in ${daysLeft} day${daysLeft !== 1 ? "s" : ""}`,
              body: `Hi ${m.name != null ? m.name : "there"}! Renew now to keep your streak alive.`,
              type: "reminder",
              key: `expiry_${daysLeft}d`,
            });
          }
        }

        const dueAmount = m.dueAmount != null ? m.dueAmount : 0;
        if (dueAmount > 0) {
          fcmPayloads.push({
            token: m.fcmToken,
            memberId: doc.id,
            title: "Pending Due Amount",
            body: `Hi ${m.name != null ? m.name : "there"}! You have Rs. ${dueAmount} pending.`,
            type: "reminder",
            key: "dues",
          });
        }
      }

      for (const p of fcmPayloads) {
        try {
          await messaging.send({
            token: p.token,
            notification: {title: p.title, body: p.body},
            data: {type: p.type, click_action: "FLUTTER_NOTIFICATION_CLICK"},
            android: {
              priority: "high",
              notification: {
                channelId: "high_importance_channel",
                color: "#10B981",
              },
            },
            apns: {payload: {aps: {sound: "default"}}},
          });

          await db
            .collection("notifications")
            .doc(p.memberId)
            .collection("items")
            .add({
              type: "gym",
              title: p.title,
              body: p.body,
              isRead: false,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
              metadata: {automated: true, reminderType: p.key},
            });

          results[p.key] = (results[p.key] != null ? results[p.key] : 0) + 1;
        } catch (err) {
          results.errors++;
          console.error(`Failed reminder for ${p.memberId}:`, err);
        }
      }

      await db.collection("scheduledReminderLogs").add({
        runAt: admin.firestore.FieldValue.serverTimestamp(),
        results,
        totalSent: fcmPayloads.length - results.errors,
      });

      console.log("Daily reminders sent:", results);
      return null;
    } catch (error) {
      console.error("Scheduled reminder error:", error);
      return null;
    }
  },
);

// ═══════════════════════════════════════════════════════════════════════════
// 7. ANNOUNCEMENT FCM BROADCAST
//    Firestore trigger: announcements/{announcementId}
// ═══════════════════════════════════════════════════════════════════════════
exports.onAnnouncementCreated = onDocumentCreated(
  "announcements/{announcementId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return null;
    const data = snap.data();
    if (!data || data.isActive === false) return null;

    const {title, message, targetBranches} = data;
    const body = message && message.length > 100
      ? message.substring(0, 97) + "..."
      : message;

    try {
      const topics = [];

      if (!targetBranches || targetBranches.includes("all") || targetBranches.length === 0) {
        topics.push("announcements_all");
      } else {
        for (const branch of targetBranches) {
          topics.push(`announcements_${branch.toLowerCase().replace(/\s+/g, "_")}`);
        }
      }

      for (const topic of topics) {
        await messaging.sendToTopic(topic, {
          notification: {title: `${title}`, body: body != null ? body : ""},
          data: {
            type: "announcement",
            announcementId: snap.id,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        });
        console.log(`Announcement FCM sent to topic: ${topic}`);
      }

      return null;
    } catch (error) {
      console.error("Announcement FCM error:", error);
      return null;
    }
  },
);

// ═══════════════════════════════════════════════════════════════════════════
// 8. XP AWARD NOTIFICATION
//    Firestore trigger: gamification/{memberId}
// ═══════════════════════════════════════════════════════════════════════════
exports.onXpAwarded = onDocumentUpdated(
  "gamification/{memberId}",
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    const memberId = event.params.memberId;

    const xpBefore = before.totalXp != null ? before.totalXp : 0;
    const xpAfter = after.totalXp != null ? after.totalXp : 0;
    const xpGained = xpAfter - xpBefore;

    if (xpGained < 10) return null;

    try {
      const memberDoc = await db.collection("members").doc(memberId).get();
      const memberData = memberDoc.data();
      if (!memberData || !memberData.fcmToken) return null;

      const levelBefore = Math.floor(xpBefore / 500) + 1;
      const levelAfter = Math.floor(xpAfter / 500) + 1;
      const leveledUp = levelAfter > levelBefore;

      const title = leveledUp
        ? `Level Up! You are now Level ${levelAfter}!`
        : `+${xpGained} XP Earned!`;
      const body = leveledUp
        ? `Congratulations ${memberData.name != null ? memberData.name : ""}! Keep crushing it!`
        : `Total XP: ${xpAfter}. Keep going to reach Level ${levelAfter}!`;

      await messaging.send({
        token: memberData.fcmToken,
        notification: {title, body},
        data: {
          type: "xp",
          xpGained: xpGained.toString(),
          totalXp: xpAfter.toString(),
          leveledUp: leveledUp.toString(),
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
          priority: "high",
          notification: {
            channelId: "high_importance_channel",
            color: "#CDFF00",
          },
        },
        apns: {payload: {aps: {sound: "default"}}},
      });

      await db
        .collection("notifications")
        .doc(memberId)
        .collection("items")
        .add({
          type: leveledUp ? "badge" : "xp",
          title,
          body,
          isRead: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          metadata: {
            xpGained,
            totalXp: xpAfter,
            leveledUp,
            newLevel: levelAfter,
          },
        });

      console.log(`XP notification sent to ${memberId}: +${xpGained} XP`);
      return null;
    } catch (error) {
      console.error("XP notification error:", error);
      return null;
    }
  },
);

// ═══════════════════════════════════════════════════════════════════════════
// EMAIL TEMPLATE BUILDERS
// ═══════════════════════════════════════════════════════════════════════════

function wrapInBaseTemplate(name, contentHtml) {
  return `<!DOCTYPE html>
<html>
<head><meta charset="UTF-8">
<style>
body{font-family:Arial,sans-serif;background:#f4f4f4;margin:0;padding:0}
.wrapper{max-width:600px;margin:30px auto;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,.08)}
.header{background:linear-gradient(135deg,#10B981 0%,#14B8A6 100%);padding:32px 30px;text-align:center}
.header h1{color:#fff;margin:0;font-size:26px;letter-spacing:1px}
.header p{color:rgba(255,255,255,.85);margin:8px 0 0;font-size:14px}
.body{padding:28px 30px;color:#333;line-height:1.7}
.footer{background:#f9f9f9;padding:18px 30px;text-align:center;font-size:12px;color:#999;border-top:1px solid #eee}
.info-box{background:#d1fae5;border-left:4px solid #10B981;border-radius:6px;padding:14px 18px;margin:16px 0}
.warning-box{background:#fef3c7;border-left:4px solid #F59E0B;border-radius:6px;padding:14px 18px;margin:16px 0}
.danger-box{background:#fee2e2;border-left:4px solid #EF4444;border-radius:6px;padding:14px 18px;margin:16px 0}
h2{color:#10B981;margin-top:0}
table{width:100%;border-collapse:collapse;margin:12px 0}
td,th{padding:10px 14px;border:1px solid #e5e7eb;font-size:14px}
th{background:#f0fdf4;color:#065f46;font-weight:bold}
</style>
</head>
<body>
<div class="wrapper">
<div class="header">
<h1>SPRING HEALTH STUDIO</h1>
<p>Hanamkonda &amp; Warangal Branches</p>
</div>
<div class="body">${contentHtml}</div>
<div class="footer">
<p>Spring Health Studio &middot; Hanamkonda &amp; Warangal</p>
<p>Contact your branch for queries</p>
</div>
</div>
</body>
</html>`;
}

function buildWelcomeEmailBody(name, memberId) {
  const content = `
    <h2>Welcome, ${name}!</h2>
    <p>Thank you for joining <strong>Spring Health Studio</strong>.</p>
    <div class="info-box"><strong>Member ID:</strong> ${memberId}</div>
    <p>Your invoice and membership card are attached. Please save them for your records.</p>
    <ul>
      <li>Download the <strong>Spring Health Member App</strong> to track workouts and attendance</li>
      <li>Use your QR code for quick check-ins at the gym</li>
      <li>Earn XP and badges by completing workouts and challenges</li>
    </ul>
    <p><strong>Let's achieve your fitness goals together!</strong></p>`;
  return wrapInBaseTemplate(name, content);
}

function buildExpiryEmailBody(name, expiryDate, daysLeft, branch) {
  const box = daysLeft <= 1 ? "danger-box" : daysLeft <= 3 ? "warning-box" : "info-box";
  const content = `
    <h2>Hi ${name}! Your membership is expiring soon.</h2>
    <div class="${box}">
      <strong>Your ${branch} membership expires in ${daysLeft} day${daysLeft !== 1 ? "s" : ""}</strong><br>
      Expiry Date: <strong>${expiryDate}</strong>
    </div>
    <p>Renew your membership today to keep your fitness streak going!</p>
    <p>Visit us at the <strong>${branch} branch</strong> to renew.</p>`;
  return wrapInBaseTemplate(name, content);
}

function buildPaymentReceiptBody(
  name, memberId, amount, paymentMode, paymentType, branch, newExpiryDate,
) {
  const label = {
    initial: "New Membership",
    renewal: "Membership Renewal",
    due: "Due Payment",
  }[paymentType] || paymentType;

  const content = `
    <h2>Payment Confirmed</h2>
    <p>Hi <strong>${name}</strong>, your payment has been recorded.</p>
    <table>
      <tr><th>Field</th><th>Details</th></tr>
      <tr><td>Member ID</td><td>${memberId}</td></tr>
      <tr><td>Payment Type</td><td>${label}</td></tr>
      <tr><td>Amount Paid</td><td>Rs. ${amount}</td></tr>
      <tr><td>Payment Mode</td><td>${paymentMode.toUpperCase()}</td></tr>
      <tr><td>Branch</td><td>${branch}</td></tr>
      ${newExpiryDate ? `<tr><td>New Expiry</td><td><strong>${newExpiryDate}</strong></td></tr>` : ""}
    </table>
    <div class="info-box">
      ${newExpiryDate ?
    `Membership active until <strong>${newExpiryDate}</strong>. Keep up the great work!` :
    "Your due payment has been cleared. Thank you!"}
    </div>`;
  return wrapInBaseTemplate(name, content);
}
