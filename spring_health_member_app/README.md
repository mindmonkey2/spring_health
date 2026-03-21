---

# Spring Health — Member App

> A Flutter-based gym companion app for Spring Health Studio members
> across Hanamkonda and Warangal branches.

## Overview
The Spring Health Member App serves as the primary mobile companion for gym members, allowing them to track their fitness journey, manage their membership, and engage with the gym's community. It seamlessly integrates with the Spring Health Studio backend, offering real-time updates on attendance, workouts, and gamification rewards.

## Features
- **Authentication**: Secure login via OTP verification.
- **Dashboard**: Centralized home screen with membership status and quick stats.
- **Profile Management**: View personal details and membership info.
- **Fitness & Tracking**: Monitor body metrics, health data (via Health Connect), and log detailed workouts.
- **Engagement**: Gamification system with XP, leaderboards, personal bests, and weekly clashes.
- **Trainers**: Browse available trainers and submit feedback.
- **Check-in/Attendance**: Seamless QR code check-in and attendance history tracking.
- **Payments & Lockout**: View payment history, handle renewals via Razorpay, and manage membership lockouts when expired.
- **Communications**: Receive gym announcements and push/in-app notifications.

## Tech Stack
| Layer | Technology |
|---|---|
| Framework | Flutter (>=3.10.4) |
| Language | Dart |
| Backend | Firebase |
| Auth | Firebase Phone Authentication |
| Database | Cloud Firestore |
| Storage | Firebase Cloud Storage |
| Notifications | Firebase Cloud Messaging (FCM) |
| Payments | Razorpay |
| Health Data | Health Connect |
| UI Theme | Neon Dark ('Cyber-Organic') |

## Project Structure
```text
lib/
├── core/
│   ├── config/
│   ├── constants/
│   └── theme/
├── models/
├── screens/
│   ├── announcements/
│   ├── attendance/
│   ├── auth/
│   ├── checkin/
│   ├── clash/
│   ├── fitness/
│   │   └── widgets/
│   ├── gamification/
│   ├── home/
│   │   └── widgets/
│   ├── lockout/
│   ├── notifications/
│   │   └── widgets/
│   ├── payments/
│   ├── profile/
│   │   └── widgets/
│   ├── renewal/
│   ├── settings/
│   ├── social/
│   ├── splash/
│   ├── trainers/
│   └── workout/
├── services/
└── widgets/
```

## Firebase Collections Used
- `announcements`: Reads current branch and global gym announcements.
- `attendance`: Writes check-in events and reads member attendance logs.
- `body_metrics` / `fitnessData`: Reads and writes member health metrics.
- `challenges`: Reads available gym challenges and participation criteria.
- `fcmTokens`: Writes member device tokens for push notifications.
- `gamification`: Reads and updates member XP, level, and rewards data.
- `gamification_events`: Reads events written by Studio to process rewards idempotently.
- `memberAlerts`: Reads active alerts to trigger lockouts or warnings.
- `members`: Reads member profile and status information.
- `notifications`: Reads specific in-app notifications targeting the member.
- `payments`: Reads historical payment records and logs new transactions.
- `trainerFeedback`: Writes reviews and ratings for gym trainers.
- `trainers`: Reads list of active trainers.
- `workouts`: Reads and writes user-logged workout details.

## Getting Started

### Prerequisites
- Flutter SDK (>=3.10.4)
- Firebase project configured
- Android minSdkVersion 26 (required for Health Connect)
- google-services.json placed in android/app/

### Setup
1. Clone the repository and navigate to `spring_health_member_app/`.
2. Run `flutter pub get` to install dependencies.
3. Configure your Firebase project by placing `google-services.json` in the appropriate directory.
4. Set up environment variables via `--dart-define` for secrets.
5. Run the app using `flutter run`.

## Architecture Notes
- FirebaseAuthService is a singleton. Always use FirebaseAuthService.instance.
- Gamification state lives exclusively in gamification/{memberId} — never on MemberModel.
- Studio fires events to gamification_events collection. GamificationService in this app is the sole processor.
- All XP award calls are idempotent — checked before write.

## Design System
- Theme: Neon Dark
- Primary accent: Neon Lime (#C6F135)
- Background: #0A0A0A
- Surface: #1A1A1A
- Font: Google Fonts (as per app_text_styles.dart)

## Related Apps
| App | Description |
|-----|-------------|
| spring_health_studio | Admin app for owners and receptionists |

## Last Updated
March 21, 2026

---
