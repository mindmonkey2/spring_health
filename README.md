# Spring Health Ecosystem

## 1. Project Overview
The Spring Health Ecosystem is a dual-application platform designed to seamlessly connect gym administration, fitness professionals, and clients. Powered by a single unified backend, the platform consists of two distinct applications:
*   **Spring Health Studio (Admin App):** A comprehensive management dashboard built for Owner, Receptionist, and Trainer roles to oversee gym operations, financials, member attendance, and AI-assisted fitness programming.
*   **Spring Health Member App (Client App):** A dedicated, member-facing application enabling clients to track workouts, access personalized AI-generated fitness and diet plans, monitor their health metrics, and engage in gamified weekly challenges.

## 2. Architecture & Tech Stack
The ecosystem is built using Flutter for both applications, ensuring cross-platform compatibility and a native feel. Both apps communicate with a shared Firebase backend project (`spring-health-studio-f4930`), which handles database operations, authentication, cloud storage, and push notifications.

**Key Architectural Patterns:**
*   **Frontend Framework:** Flutter (Dart).
*   **Shared Backend:** Firebase (Firestore, Cloud Storage, Firebase Cloud Messaging).
*   **Authentication:**
    *   **Studio App:** Utilizes Email/Password authentication with strict role-based access control tied to a `users/{uid}` document.
    *   **Member App:** Employs Phone OTP authentication. Critical architectural note: Member identities live exclusively in the `members` collection. The app relies on a `members` collection lookup rather than creating or reading from a standard `users/{uid}` document.
*   **Generative AI Integration:** The platform integrates the Gemini 2.0 Flash model via the `firebase_ai` package. This powers the AI Personal Trainer Engine, capable of generating context-aware, 7-day workout and 5-meal diet plans directly from the client application, safeguarded by strict, rule-based medical hold checks (e.g., blocking AI API calls during a blood pressure crisis, cardiac event, or fever).

## 3. Core Features

### Spring Health Studio (Admin App)
*   **Role-Based Dashboards:** Specialized views tailored for Owner, Receptionist, and Trainer roles.
*   **Member Management & Attendance:** Robust tools for onboarding members, tracking subscription renewals, and an integrated QR scanner for duplicate-preventing attendance logging.
*   **Financial & Analytics Reports:** Tracking for payments (cash/UPI split), dues collection, expenses, and automated PDF/Excel export generation.
*   **Trainer Dashboard & AI Plan Management:** Trainer assignment, feedback tracking, and a dedicated interface for trainers to review and override AI-generated member workout plans.
*   **Communication Hub:** Integrated WhatsApp and email automated reminders for dues, expiries, and birthdays, alongside FCM push notifications and system announcements.

### Spring Health Member App (Client App)
*   **Fitness Dashboard & Workout Logging:** Live workout timers, set tracking, calorie estimates, and historical charts.
*   **AI Coach:** A fully integrated virtual trainer that parses daily wearable data (via Health Connect/HealthKit) to generate personalized workout and diet plans.
*   **Health & Body Metrics:** Comprehensive tracking of fitness test batteries, body composition, and vital signs (e.g., blood pressure, resting heart rate).
*   **Gamification & Weekly Wars:** XP tracking, loyalty milestone rewards, personal bests, and competitive leaderboards through active fitness duels and weekly challenges.
*   **Gym Engagement:** Digital membership cards, live attendance heatmaps, and in-app notification centers.

## 4. Developer Setup & Onboarding
To run the Spring Health ecosystem locally, follow these steps:

1.  **Prerequisites:** Ensure you have the Flutter SDK (supporting at least compileSdk/targetSdk 35 and minSdk 26 for Android) installed. The Android build requires AGP 8.9.1, Gradle 8.10.2, and Kotlin 2.1.0.
2.  **Clone the Repository:** Navigate to the project root directory.
3.  **Install Dependencies:** Run `flutter pub get` inside both the `spring_health_studio/` and `spring_health_member_app/` directories.
4.  **Run the Applications:**
    *   To run the Studio App: `cd spring_health_studio && flutter run`
    *   To run the Member App: `cd spring_health_member_app && flutter run`
5.  **Pre-Commit Requirement:** Before making any commits, you must run `flutter analyze` in both application directories. It is mandatory that exactly "No issues found!" is returned. Do not rely solely on analyzing individual modified files.

## 5. Documentation Guide
For deeper context, historical decision-making, and strict project rules, developers must refer to the following root-level documentation files:
*   **`Spring-Health-Memory.md`:** Contains critical architectural boundaries, known pitfalls, and strict rules that must not be regressed (e.g., Firestore role casing, exact authentication workflows, and UI theme constraints). Read this before modifying any core logic.
*   **`PROJECT_STATE.md`:** Provides a detailed, up-to-date audit of implemented features, active Firestore schemas, and pending/stubbed features across both applications.
*   **`current_state.md`:** Reflects the latest static analysis results, dependency lists, screen routing statuses, and an inventory of missing links or temporary stubs.
