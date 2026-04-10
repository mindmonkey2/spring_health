# Spring Health System Health Report
Generated: 2026-04-10

## 1. Static Analysis
Member App: ✅ No issues / ❌ 0 issues
Studio App: ✅ No issues / ❌ 0 issues

## 2. Test Results
Member App: 34 passed, 4 failed
Studio App: 28 passed, 0 failed

- test/services/body_metrics_service_test.dart: PASS
- test/services/health_service_test.dart: PASS
- test/models/announcement_model_test.dart: PASS
- test/models/weekly_war_model_test.dart: FAIL
- test/models/fitness_stats_model_test.dart: PASS
- test/benchmark_test.dart: PASS
- test/services/fee_calculator_test.dart: PASS
- test/services/whatsapp_service_test.dart: PASS
- test/services/notification_service_performance_test.dart: PASS

Failed tests in Member App:
- test/models/weekly_war_model_test.dart: WeeklyWarModel.fromMap creates model correctly with full valid data and Timestamps
- test/models/weekly_war_model_test.dart: WeeklyWarModel.fromMap creates model correctly when dates are ISO-8601 Strings
- test/models/weekly_war_model_test.dart: WeeklyWarModel.fromMap creates model with default values when map fields are missing or null
- test/models/weekly_war_model_test.dart: WeeklyWarModel.fromMap handles prizePool safely when it is null

## 3. Feature Status

────────────────────────────────
MEMBER APP FEATURES
────────────────────────────────

AUTH
✅ OTP sign-in — verifyOTP() calls storeMemberIdFromUser after credential
✅ Auto-verify — verificationCompleted calls storeMemberIdFromUser
✅ Cold-start — getCurrentMemberId() has storage + phone fallback
✅ Sign-out — clears memberId from FlutterSecureStorage

HOME SCREEN
✅ listenForPendingLoyaltyEvents called on startup
✅ memberId resolved via getCurrentMemberId in initState
❌ FCM token registered via NotificationService.saveFCMToken

GAMIFICATION
⚠️ GamificationService.processEvent is single XP entry point (direct awardXP calls found in personal_best_service.dart)
✅ BadgeService.checkAndAward called after every processEvent
✅ Leaderboard screen loads and shows ranked members
✅ XP display working — gamification/{memberId} doc read

WEEKLY WARS
✅ WeeklyWarService exists and has all 6 methods
✅ WarScreen (war_screen.dart) exists with 3 tabs
✅ THIS WEEK tab — FutureBuilder loads active war
✅ THIS WEEK tab — countdown timer uses ValueNotifier (no setState)
✅ THIS WEEK tab — leaderboard StreamBuilder present
✅ HISTORY tab — getWarHistory wired
🔲 1v1 DUELS tab — placeholder present

CHECK-IN / QR
✅ QrCheckInScreen calls processEvent('checkin', memberId) after write
✅ AttendanceService has NO duplicate streak calculation

WORKOUT
✅ WorkoutLoggerScreen uses memberId (not auth.uid) for Firestore
✅ WorkoutService.checkAndUpdatePersonalBests called after save
✅ BadgeService.checkAndAward called after save
✅ WorkoutHistoryScreen uses GamificationService (not raw Firestore)

DIET / AI COACH
✅ DietPlanScreen uses memberId (not auth.uid) for aiPlans collection
❌ AiCoachService model string = gemini-2.5-flash-preview-04-17
❌ TrainerAjaxService model string = gemini-2.5-flash-preview-04-17

PROFILE
✅ ProfileScreen uses memberId (not auth.uid) for members update
✅ EditProfileScreen uses memberId (not auth.uid) for members update

HEALTH / WEARABLES
✅ HealthService has NO HealthDataType.DISTANCE_WALKING_RUNNING
✅ WearableSnapshotService uses memberId for Firestore path

PERSONAL BESTS
✅ PersonalBestsScreen uses PersonalBestService (not raw Firestore)

ANNOUNCEMENTS
✅ AnnouncementModel has targetBranches and createdByUid fields
✅ CreateAnnouncementScreen uses AnnouncementService (not raw Firestore)

────────────────────────────────
STUDIO APP FEATURES
────────────────────────────────

AUTH
✅ signInAndResolveUser queries trainers by 'authUid' (not 'userId')
✅ TrainerModel.fromMap reads map['authUid'] (not map['userId'])

GAMIFICATION DASHBOARD
✅ AdminGamificationDashboardScreen has Weekly Wars tile
✅ Weekly Wars tile navigates to WarAdminScreen

WAR ADMIN
✅ WarAdminScreen exists
✅ Start War uses warCount % 7 (NOT getWeekNumber % 7)
✅ getWeekNumber helper is DELETED (no longer in file)
✅ Complete War distributes XP via gamification_events collection

ANNOUNCEMENTS
✅ AnnouncementModel has targetBranches and createdByUid fields

LEADERBOARD
✅ AdminGamificationService.getLeaderboard uses whereIn batching
✅ Chunk size is 30

## 4. Identity Bug Scan
- SAFE: spring_health_member_app/lib/services/membership_alert_service.dart:22 (read-only checking)
- SAFE: spring_health_member_app/lib/services/storage_service.dart:13
- SAFE: spring_health_member_app/lib/services/in_app_notification_service.dart:18
- SAFE: spring_health_member_app/lib/services/firebase_auth_service.dart:347
- DANGER: spring_health_member_app/lib/services/rpe_service.dart:8 (used as UID key)
- DANGER: spring_health_member_app/lib/screens/profile/member_goal_screen.dart:30 (used as UID key)
- DANGER: spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart:41
- DANGER: spring_health_member_app/lib/screens/home/home_screen.dart:394

## 5. Junk Files
✅ No JUNK files found

## 6. Firestore Collections
KNOWN:
aiPlans
announcements
attendance
bodyMetricsLogs
expenses
fcmTokens
fitnessTests
gamification
gamification_events
healthProfiles
members
notifications
personalbests
sessions
trainers
users
wearableSnapshots
weeklywars
workouts

UNKNOWN:
challengeEntries
challenges
complete
current
daily
date
dietPlans
entries
exercises
expenseDate
feedback
fitnessData
gamificationEvents
gymEquipment
isActive
isArchived
items
logs
memberAlerts
memberGoals
memberId
memberIntelligence
notificationHistory
notificationsQueue
payments
personal_bests
reminder_logs
rpeLog
status
tests
trainerFeedback
trainerTeamBattles
trainingSessions

## 7. Firestore Rules Audit
✅ isMemberOwner(memberId) helper exists
✅ wearableSnapshots — allows isOwner || isTrainer || isMemberOwner
✅ healthProfiles — allows isOwner || isTrainer || isMemberOwner
✅ bodyMetricsLogs — allows isOwner || isTrainer || isMemberOwner
✅ fitnessTests — allows isOwner || isTrainer || isMemberOwner
✅ gamification — allows isOwner || isReceptionist write, isSignedIn + own memberId read
✅ gamification_events — isOwner || isReceptionist write, isSignedIn + own memberId read
✅ weeklywars — isOwner || isTrainer write, isSignedIn read
✅ members — no member can write another member's doc

## 8. Summary
CRITICAL issues (will cause bugs): 8
WARNING (anti-pattern/debt): 1
CLEAN items: 40
