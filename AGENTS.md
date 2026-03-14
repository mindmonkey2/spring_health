# Spring Health Ecosystem - AI Agent Directives

## 1. System Overview
This repository contains a unified digital ecosystem for Spring Health Studio (fitness centers based in Warangal and Hanamkonda). It operates as a monorepo containing two distinct Flutter applications sharing a single, centralized Firebase BaaS.
* **`spring_health_studio_app`:** Administrative suite for Owners and Receptionists.
* **`spring_health_member_app`:** Client-facing retention, fitness tracking, and community app.

## 2. Infrastructure & Environment
* **Build Toolchain:** Android Gradle Plugin (AGP) 8.9.1, Gradle 8.11.1, Kotlin 2.1.0, compileSdk 35. Do NOT downgrade these versions to resolve dependency conflicts.
* **Core Packages:** `flutter_animate`, `health` (requires explicit OS permissions), `fl_chart`, `razorpay_flutter`, `printing` (PDF generation).

## 3. Strict Code Generation Rules (Zero-Tolerance)
* **Linting:** Code MUST pass `flutter analyze` with 0 errors and 0 warnings.
* **Constructors:** Use `const` constructors aggressively across all widget trees.
* **Logging:** `print()` is strictly prohibited. Use `debugPrint()`.
* **Deprecations:** Never use deprecated Flutter or Dart APIs.
* **Completeness:** When modifying a file, output the *entire* file content. Do not use `// ... rest of code` placeholders.

## 4. State Management & Performance Invariants
* **No Root `setState`:** You are strictly forbidden from calling `setState()` at the root of complex widget trees, especially those containing `flutter_animate` sequences (e.g., the Clash Module timer). 
* **Granular Updates:** High-frequency temporal state or micro-interactions MUST be isolated using `ValueNotifier` and `ValueListenableBuilder` to maintain 60fps and prevent animation flickering.

## 5. Backend & Data Modeling (Firebase)
* **Atomic Transactions:** Any logical workflow that updates multiple documents, relies on sequential increments (like XP or Streaks), or handles financial data MUST utilize Firestore `Transaction` or `WriteBatch`. Never perform sequential, independent `await .set()` or `.update()` calls for related data.
* **Schema & Security Rules:**
    * The database utilizes root-level normalized collections linked via foreign keys (e.g., `memberId`).
    * **Branch Isolation:** Staff actions are strictly sandboxed. The system enforces `isSameBranch(branch)` logic. Do not attempt to bypass branch parameters in administrative queries unless operating under the `Owner` global role.
* **Specific Document Nuances:**
    * **Announcements:** Read states are tracked via a `readBy` array (List<String> of UUIDs), NOT a boolean `isRead`. Use `isReadBy(String memberId)` to evaluate.
    * **Financial Ledgers:** Payments are immutable. Split payments enforce strict mathematical validation: `cashAmount + upiAmount = finalAmount`. Pending balances are stored explicitly in `dueAmount`.

## 6. App-Specific UI/UX Paradigms

### A. Spring Health Studio (Admin App)
* **Theme:** "Wellness & Balance" Material Design.
* **Palette:** Primary is Sage Green (`AppColors.primary`), dark accent is Teal (`AppColors.primaryDark`).
* **Artifacts:** PDF generation utilizes `pdf` and `printing`. You MUST use `PdfGoogleFonts` to asynchronously fetch Unicode-compliant fonts (like Roboto) to ensure regional currency symbols (₹/Rs) render correctly on the canvas.

### B. Spring Health Member App (Client App)
* **Theme:** "Neon Dark" Cyber-Aesthetic. Heavily utilizes glassmorphism.
* **Palette:** Deep obsidian (`AppColors.backgroundBlack`), Neon Lime (`#D4FF00`), Neon Teal (`#00FFD1`), Neon Orange (`#FF6B35`).
* **Notification Center:** Operates on a dual-layer persistence model. Transient FCM messages are synchronously written to the local subcollection `notifications/{uid}/items/{notifId}`. Swiping to dismiss triggers a Firestore database deletion.

## 7. Execution Mandate
Before writing code, analyze the existing file structures to infer exact paths. When implementing new features (e.g., Razorpay Renewal, Social Flex Zone, Trainer Feedback), ensure they integrate seamlessly with the existing service architectures and RBAC rules defined above.
