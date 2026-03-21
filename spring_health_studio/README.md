---

# Spring Health — Studio App

> A Flutter-based gym administration app for owners, receptionists, and
> staff across Hanamkonda and Warangal branches.

## Overview
The Spring Health Studio App is a comprehensive management portal designed for the operational administration of the Spring Health gym network. It empowers owners and receptionists to efficiently track member registrations, manage finances, monitor attendance, coordinate trainers, and trigger gamification events, seamlessly updating the unified Spring Health Firebase ecosystem.

## Features
- **Authentication**: Role-based access (Owner, Receptionist, Trainer) authenticated via Email & Password.
- **Dashboards**: Specialized web and mobile dashboard views tailored to Owner and Receptionist roles.
- **Members Management**: Full lifecycle management—add, edit, detail view, rejoin members, and track fitness progress.
- **Dues & Payments**: Collect member dues and issue structured PDF receipts automatically.
- **Trainers Management**: Add new trainers, assign members, view dashboards, and monitor performance.
- **Financials**: Track expenditures via detailed expense logging and viewing capabilities.
- **Attendance**: Facilitate member check-ins with an integrated QR scanner and access full attendance history.
- **Communications**: Create announcements, manage automated reminders, and dispatch push notifications globally or branch-specifically.
- **Engagement (Admin Gamification)**: Manually intervene and inject gamification milestones or awards into the broader ecosystem.
- **Analytics**: Generate high-level branch reports and track core gym metrics via an analytics dashboard.

## Tech Stack
| Layer | Technology |
|---|---|
| Framework | Flutter (>=3.10.4) |
| Language | Dart |
| Backend | Firebase |
| Auth | Firebase Email/Password Authentication |
| Database | Cloud Firestore |
| Storage | Firebase Cloud Storage |
| Document Generation | Printing & PDF (with Google Fonts) |
| Communications | SMTP Mailer & WhatsApp Integration |
| Notifications | Firebase Cloud Messaging (FCM) |
| UI Theme | Wellness & Balance ('Professional Zen') |

## Project Structure
```text
lib/
├── models/
├── screens/
│   ├── analytics/
│   ├── announcements/
│   ├── attendance/
│   ├── auth/
│   ├── expenses/
│   ├── gamification/
│   ├── members/
│   ├── notifications/
│   ├── owner/
│   ├── receptionist/
│   ├── reminders/
│   ├── reports/
│   └── trainers/
├── services/
├── theme/
├── utils/
└── widgets/
```

## Firebase Collections Used
- `announcements`: Writes new announcements and updates existing ones for member broadcast.
- `attendance`: Writes manual check-in logs and reads aggregated branch attendance history.
- `expenses`: Writes and reads gym operational expenses.
- `fcmTokens`: Reads to dispatch push notifications to specific member segments.
- `gamification_events`: Writes gamification triggers and manual XP/badge awards for the member app to process.
- `members`: Full CRUD operations managing the core member profiles.
- `notifications`: Writes manual push/in-app notification records.
- `payments`: Writes successful transaction records from direct or physical dues collection.
- `reminder_logs`: Reads and writes automated task execution logs.
- `trainers`: Full CRUD operations for gym staff records.
- `users`: Reads role mapping documents to authorize features and dashboard views per admin identity.

## Getting Started

### Prerequisites
- Flutter SDK (>=3.10.4)
- Firebase project configured
- Web/Desktop build requirements (depending on execution target)
- google-services.json / GoogleService-Info.plist mapped correctly

### Setup
1. Clone the repository and navigate to `spring_health_studio/`.
2. Run `flutter pub get` to install dependencies.
3. Configure your Firebase project for the Studio targets.
4. Supply necessary backend secrets (e.g. SMTP credentials) via `--dart-define` at build time to `AppConfig`.
5. Run the app on an emulator, web browser, or physical device using `flutter run`.

## Architecture Notes
- Role-based UI components rely on a centralized `users/{uid}` role check.
- The default `widget_test.dart` might fail out-of-the-box due to requiring initialized Firebase connections; provide mocks or use targeted tests.
- Uses `FirebaseFirestore.instance.batch()` for atomic write operations.
- The `gamification_events` collection is used as a queue: the Studio writes to it, while the Member app processes it idempotently to update member state.

## Design System
- Theme: Wellness & Balance
- Elements: Glassmorphic cards (semi-transparent white with BackdropFilter)
- Colors/Spacing: Centralized in `lib/theme/` (AppColors, AppDimensions)

## Related Apps
| App | Description |
|-----|-------------|
| spring_health_member_app | Companion app for end-users and members |

## Last Updated
March 21, 2026

---
