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
