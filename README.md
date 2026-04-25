# Spring Health Ecosystem

## 1. Project Overview
Spring Health is a multi-branch gym management system composed of two mobile applications backed by Firebase. The ecosystem serves gym members, trainers, receptionists, and owners. The Member App provides members with tools to track workouts, view their health profile, receive AI coaching, and monitor attendance/gamification progress. The Studio App is the admin side, empowering staff to manage memberships, collect dues, monitor revenue, and oversee operations across different branches.

## 2. Architecture Diagram

```ascii
                      +-------------------+
                      |   Firebase Auth   |
                      +---------+---------+
                                |
          OTP Login             |      Email/Password
        +-----------------------+-----------------------+
        |                                               |
        v                                               v
+---------------+                               +---------------+
|               |        +-------------+        |               |
|  Member App   | <----> |  Firestore  | <----> |  Studio App   |
|               |        +-------------+        |               |
+---------------+                               +---------------+
        |                                               |
        v                                               |
+---------------+                                       |
|  Firebase AI  |                                       |
|   (Gemini)    |                                       v
+---------------+                               +---------------+
                                                |Cloud Functions|
                                                +-------+-------+
                                                        |
                                                        v
                                                +---------------+
                                                |      FCM      |
                                                +---------------+
```

## 3. App Breakdown

| Feature | Member App | Studio App |
|---------|------------|------------|
| **Tech Stack** | Flutter SDK (^3.10.4)<br>Firebase (Core, Auth, Firestore, Messaging, Storage)<br>Google Fonts, Lottie, FL Chart<br>Health Connect (`health`), Image Picker<br>Razorpay Flutter, Firebase AI | Flutter SDK (>=3.2.0 <4.0.0)<br>Firebase (Core, Auth, Firestore, Storage)<br>Google Fonts, FL Chart, PDF (`pdf`, `printing`)<br>QR Flutter, Mobile Scanner<br>Share Plus, Mailer, Firebase AI |
| **Key Screens** | Home, AI Coach, Fitness Dashboard,<br>QR Check-in, Diet Plan, Notifications,<br>Gamification (XP, Leaderboard), Wars | Owner/Receptionist/Trainer Dashboards,<br>Member Manager, Attendance Scanner,<br>Reports, Reminders, Clash Wars |
| **Key Services** | `FirebaseAuthService` (OTP), `AiCoachService`,<br>`GamificationService`, `WorkoutService`,<br>`HealthService`, `WeeklyWarService` | `AuthService` (Email), `FirestoreService`,<br>`PdfService`, `EmailService`,<br>`WhatsappService`, `AdminGamificationService` |

## 4. Firebase Services

| Service | Purpose | Used By |
|---------|---------|---------|
| **Authentication** | Secure login (Phone OTP for members, Email/Password for staff). | Both Apps |
| **Firestore** | Real-time NoSQL database for members, attendance, workouts, and more. | Both Apps |
| **Storage** | Object storage for member profile photos and other media. | Both Apps |
| **Cloud Messaging (FCM)** | Push notifications for announcements, reminders, and alerts. | Studio (Send) / Member (Receive) |
| **Firebase AI** | Integration with Gemini to generate workouts and coaching insights. | Both Apps |

## 5. Firestore Collections

| Collection | Owner App | Key Fields | Access Rule Summary |
|------------|-----------|------------|---------------------|
| `members` | Studio | `name`, `phone`, `branch`, `plan`, `expiryDate` | Admin/Trainer Read/Write. Members Read Own. |
| `users` | Studio | `role`, `email` | Owner Write. User Read Own. |
| `attendance` | Studio/Member | `branch`, `memberId`, `checkInTime` | Admin Read/Write. Member Read/Create. |
| `payments` | Studio | `branch`, `memberId`, `paymentDate`, `finalAmount` | Admin Read/Write. Member Read Own. |
| `workouts` | Member | `memberid`, `date`, `exercises` | Member Read/Write Own. Admin/Trainer Read. |
| `gamification` | Member | `branchId`, `totalXp`, `currentStreak` | Admin/Trainer Read/Write. Member Read/Write Own. |
| `aiPlans` | Member | `generatedAt`, `trainerNote` | Member Read/Write Own. Admin Read/Update. |

## 6. User Roles

| Role | App | Auth Method | Access Level |
|------|-----|-------------|--------------|
| **Owner** | Studio | Email/Password | Full system access across all branches. |
| **Receptionist** | Studio | Email/Password | Branch-specific member management and check-ins. |
| **Trainer** | Studio | Email/Password | Read-only assigned members, session management. |
| **Member** | Member | Phone OTP | Manage own fitness data, workouts, and profile. |

## 7. Local Development Setup

```bash
# Clone the repository
git clone <repository-url>
cd spring_health

# Setup Member App
cd spring_health_member_app
flutter pub get
# Ensure google-services.json (Android) and GoogleService-Info.plist (iOS) are configured.
flutter run

# Setup Studio App
cd ../spring_health_studio
flutter pub get
# Ensure google-services.json (Android) and GoogleService-Info.plist (iOS) are configured.
flutter run

# Deploy Firestore Rules (from project root)
firebase deploy --only firestore:rules
```

## 8. Key Engineering Decisions

* **Firestore Document IDs vs. Auth UIDs:** Members use phone OTP and have no `users` collection document. All member-related data is keyed to the `members` collection document ID (`memberId`), not the Firebase Auth UID.
* **Role Casing in Firestore:** Roles are stored in Title Case (`Owner`, `Receptionist`, `Trainer`, `Member`). Rules strictly enforce this casing.
* **Gamification Event Bridge:** Gamification events are fired by Studio into the `gamificationEvents` collection, which the Member App processes idempotently to update XP and streaks.
* **Model Factory Pattern:** All data models standardise on a `fromMap(map, id)` factory constructor pattern; `fromFirestore` is avoided.
* **Singleton Services:** Services like `FirebaseAuthService` are singletons (`.instance`) to preserve state (e.g. OTP `verificationId`).
* **Dual-Guard Auth Check:** To prevent false logouts on restart (due to brief Firebase `null` emission), auth logic verifies the cache synchronously before redirecting.

## 9. Security Notes

* **IDOR Prevention:** Always validate ownership on document creation using `allow create: if isSignedIn() && isOwnNewRecord();` to prevent identity spoofing in collections like `socialFeed`.
* **Rules Deployment Pitfall:** If the Firebase CLI skips upload, rules must be manually pasted into the Firebase Console and then synced locally to ensure deployment.
* **Index Preservation:** Never delete live Firestore indexes via CLI prompts; always add missing definitions to `firestore.indexes.json`.
* **Rule Logic for Members:** Rules for member-facing collections must use `isSignedIn() && isOwnRecord(resource.data)` rather than `isMember()`, as phone OTP users have no corresponding `users` document.
