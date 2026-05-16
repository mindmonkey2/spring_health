# Spring Health Project Current State and Development Plan
Last Updated: 2026-05-15

## 1. Purpose of this document

This document is the living delivery-state and roadmap for the Spring Health ecosystem. It outlines where the project currently stands, what work was recently completed, and prioritizes the pending tasks. It serves as the primary operational document for deciding the next engineering task and must be kept up-to-date with every major change.

## 2. Current verified state

The Spring Health ecosystem is largely feature-complete for core operations, with ongoing work focused on advanced features and remaining integrations.

- **Studio app:** ~97% complete. Core management, attendance, reporting, and announcements are fully functional. Pending integration of Razorpay for online payments, trainer chat, and email-based summary reports.
- **Member app:** ~95% complete. Core workout tracking, AI coaching, gamification, and attendance are fully functional. Pending Razorpay integration, body measurements, class booking, and completion of the social roadmap.
- **Social:** Basic infrastructure (collections, IDOR rules) is implemented. Advanced features like 1v1 duels are deferred.
- **AI:** Phase 4 UI (AiCoachScreen) is implemented in the Member App, featuring Today/Week/Diet tabs, medical hold logic, and Gemini integration.
- **Gamification:** Core XP, streaks, badges, and Clash/Weekly Wars are fully operational. Single entry point (`processEvent`) enforced.
- **Security/rules:** Significant hardening completed, including Title Case role enforcement, `isSignedIn()` usage for members, IDOR prevention on creation, and dual-guard auth checks.
- **Trainer flow / future scope:** Trainer App is currently 0% complete (Roadmap). In-app trainer communication and commission tracking within the existing apps remain pending.

## 3. Recently completed work

- **May 13, 2026 (T15-PRE Regression Fix):**
  - Restored Firebase project configuration for member app Android.
  - Corrected `warwinner` XP from 500 to 200.
  - Corrected Gemini model string to `gemini-2.5-flash-preview-04-17`.
  - Fixed 32 auth test failures by modifying `pumpAndSettle` to `pump` and disabling animations/runtime font fetching during tests.
  - Resolved Node.js 20 CI deprecation by setting `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` in GitHub workflows.
  - Ensured both apps pass `flutter analyze` with 0 issues.
- **April 19, 2026 (Security Hardening):**
  - Implemented IDOR prevention on `socialFeed`, `socialChallenges`, `gamificationEvents`, `trainerFeedback`, and `feedback` by requiring `allow create: if isSignedIn() && isOwnNewRecord();`.
- **April 2026 (Auth Bug Fix):**
  - Eliminated the false-logout-on-restart bug via a dual-guard auth check in both apps.
- **Thread 15 (Social Work):**
  - Set up core social collections and enforced the `processEvent` gamification rule.
  - [COMPLETED] Personal Best achievement visibility via deterministic auto-post hooks.
  - [BLOCKED] Weekly War auto-post hooks blocked on member side pending Studio-side implementation.
  - [DEFERRED] 1v1 Duels.
  - [PENDING] Notifications for social interactions and remaining UI polish.

## 4. Pending roadmap by priority

### Immediate next tasks
- **[PENDING] Razorpay online payment integration:** Enable members to renew memberships online and allow receptionists to initiate payment links.
  - *Dependency:* Shared backend payment verification functions.
  - *Notes:* Critical for revenue operations.

### Near-term tasks
- **[PENDING] Body measurements & progress photos:** Allow members to log and visualize physical changes over time.
  - *Notes:* Requires Storage setup for photos.
- **[IN PROGRESS] Social Feed completion:** Finish UI implementation for liking and commenting on the social feed.
  - *Dependency:* Existing social collections.

### Medium-term backlog
- **[PENDING] Class booking & scheduling:** Members can view timetables and book spots in classes.
- **[PENDING] Trainer in-app communication:** Direct messaging and workout feedback between trainers and assigned members.
- **[PENDING] Automated email summary reports:** Scheduled reports for branch owners.

### Deferred / blocked items
- **[DEFERRED] 1v1 Social Duels:** Deferred to a dedicated "Spring Social sprint".
- **[PLANNED] Dedicated Trainer App:** Full standalone application for trainers.

## 5. Social development plan

1. **Merged:** Core Firestore collections (`socialFeed`, `socialChallenges`, `posts`, `comments`, `likes`), IDOR prevention rules, and optimistic UI state patterns (`ValueNotifier`).
2. **Next:** Complete the Social Feed UI in the Member App, ensuring robust pagination and comment rendering.
3. **After:** Implement notifications for social interactions (likes, comments).
4. **Deferred (Do not start):** 1v1 Duels. This requires significant architectural planning and is sequenced for a later sprint.

## 6. Cross-app pending features

- **[PENDING] Razorpay online payments:** Studio (payment links) / Member (in-app renewal).
- **[PENDING] Trainer communication & feedback:** Studio (Trainer view) / Member (Feedback viewer).
- **[PENDING] Class booking & scheduling:** Studio (Schedule creation) / Member (Booking UI).
- **[PENDING] Body measurements & progress photos:** Member App feature.
- **[PENDING] Analytics enhancements (Email reports):** Studio / Backend Cloud Functions.
- **[PLANNED] Trainer App roadmap:** Standalone app development.

## 7. Execution rules for future threads

- **One task at a time:** Do not attempt to implement multiple major features in a single thread.
- **Stop and review:** After completing a task, pause for review before proceeding to the next item on the roadmap.
- **Baseline test count:** Measure the current test pass count before starting changes; do not assume all tests pass initially if there is environmental drift.
- **0 analyze issues:** Both apps must be clean (`flutter analyze --no-pub`) before any commit.
- **No forbidden files:** Do not create throwaway planning or script files (`.py`, `.sh`, `.patch`, `plan.md`, `plan.txt`).
- **Preserve architecture:** Adhere strictly to the rules defined in `Spring-Health-Memory.md` (e.g., `memberId` usage, `fromMap` pattern, IDOR rules).

## 8. Recommended task order

1. Implement Razorpay online payment integration (critical revenue feature).
2. Complete the Social Feed UI (finish in-progress Thread 15 work).
3. Implement body measurements & progress photos (high member value).
4. Implement Trainer in-app communication (closes the loop between apps).
5. Implement Class booking & scheduling.

## 9. Document maintenance rules

This file **must be updated** whenever:
- A task is successfully merged.
- The recommended task order changes based on business priorities.
- A feature is deferred or blocked.
- Architectural decisions are made that affect the roadmap or implementation strategy.
- The project state meaningfully changes (e.g., test pass counts shift due to major refactoring).
