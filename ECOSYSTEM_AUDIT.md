<<<<<<< HEAD
---

# Spring Health Ecosystem — Function & Dependency Audit
Generated: 2026-04-04 12:14:31
flutter analyze: memberapp [0 issues] | studio [0 issues]

---

## 1. MEMBER APP — Service Inventory

### PersonalBestService
File: spring_health_member_app/lib/services/personal_best_service.dart
Singleton: no
Firestore collections: read (exercises, gamification), write (personal_bests)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| watchRecords | dynamic watchRecords(String uid) | None |
| getRecord | dynamic getRecord(String uid,     CoreExercise exercise,) | None |
| logEntry | dynamic logEntry({     required String uid,     required CoreExercise exercise,     required int value,   }) | None |

⚠️ ISSUES:

### ChallengeService
File: spring_health_member_app/lib/services/challenge_service.dart
Singleton: no
Firestore collections: read (challengeEntries, challenges), write (challengeEntries, challenges)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getActiveChallengeStream | dynamic getActiveChallengeStream() | war_screen.dart, war_screen.dart |
| getEntriesStream | dynamic getEntriesStream(String challengeId) | None |
| joinTeam | dynamic joinTeam({     required String challengeId,     required String memberId,     required String memberName,     required String teamId,   }) | None |
| logProgress | dynamic logProgress({     required String challengeId,     required String memberId,     required String memberName,     required String teamId,     required int newScore,     required int previousScore,   }) | None |
| createDemoChallenge | dynamic createDemoChallenge() | war_screen.dart, war_screen.dart, war_screen.dart |

⚠️ ISSUES:

### TrainerService
File: spring_health_member_app/lib/services/trainer_service.dart
Singleton: yes
Firestore collections: read (dietPlans, trainers), write (dietPlans, trainers)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getMyTrainerStream | dynamic getMyTrainerStream(String memberId) | trainer_screen.dart |
| getTrainersStream | dynamic getTrainersStream(String branch) | trainer_screen.dart |
| getDietPlanStream | dynamic getDietPlanStream(String memberId) | trainer_screen.dart |

⚠️ ISSUES:

### RenewalService
File: spring_health_member_app/lib/services/renewal_service.dart
Singleton: no
Firestore collections: read (payments), write (members, payments)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| processSuccessfulRenewal | dynamic processSuccessfulRenewal({     required String memberId,     required String memberPhone,     required String branch,     required String plan,     required int planDays,     required double amount,     required String razorpayPaymentId,     required DateTime currentExpiry,   }) | renewal_screen.dart |

⚠️ ISSUES:

### AnnouncementService
File: spring_health_member_app/lib/services/announcement_service.dart
Singleton: no
Firestore collections: read (announcements), write (announcements)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getAnnouncements | dynamic getAnnouncements(String branch) | None |
| getAnnouncementsStream | dynamic getAnnouncementsStream(String branch) | announcements_screen.dart |
| getAllAnnouncements | dynamic getAllAnnouncements() | None |
| markAsRead | dynamic markAsRead(String announcementId, String memberId) | announcements_screen.dart, announcements_screen.dart, announcements_screen.dart |

⚠️ ISSUES:

### NotificationService
File: spring_health_member_app/lib/services/notification_service.dart
Singleton: yes
Firestore collections: read (members), write (fcmTokens)
Secure storage keys:
Firebase Auth: currentUser, dart
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| firebaseMessagingBackgroundHandler | dynamic firebaseMessagingBackgroundHandler(RemoteMessage message) | None |
| initialize | dynamic initialize() | main.dart |
| saveFCMToken | dynamic saveFCMToken() | None |
| subscribeToTopics | dynamic subscribeToTopics(String branch) | announcements_screen.dart |
| unsubscribeFromTopics | dynamic unsubscribeFromTopics(String branch) | None |
| clearAllNotifications | dynamic clearAllNotifications() | None |

⚠️ ISSUES:

### MembershipAlertService
File: spring_health_member_app/lib/services/membership_alert_service.dart
Singleton: yes
Firestore collections: read (), write (memberAlerts)
Secure storage keys:
Firebase Auth: currentUser, dart
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| checkAndNotify | dynamic checkAndNotify(MemberModel member) | main_screen.dart |

⚠️ ISSUES:

### TrainerFeedbackService
File: spring_health_member_app/lib/services/trainer_feedback_service.dart
Singleton: no
Firestore collections: read (feedback), write (trainers)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| streamFeedback | dynamic streamFeedback(String trainerId) | None |
| getFeedback | dynamic getFeedback(String trainerId) | None |
| submitFeedback | dynamic submitFeedback({     required String trainerId,     required String memberId,     required String memberName,     required String memberPhone,     required String workoutType,     required String message,     required int rating,   }) | trainer_feedback_screen.dart |

⚠️ ISSUES:

### BodyMetricsService
File: spring_health_member_app/lib/services/body_metrics_service.dart
Singleton: no
Firestore collections: read (), write ()
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| addMetrics | dynamic addMetrics(BodyMetricsModel metrics) | body_metrics_screen.dart |
| getMetricsStream | dynamic getMetricsStream(String memberId) | body_metrics_screen.dart |
| deleteMetrics | dynamic deleteMetrics(String id) | body_metrics_screen.dart |

⚠️ ISSUES:

### StorageService
File: spring_health_member_app/lib/services/storage_service.dart
Singleton: no
Firestore collections: read (), write ()
Secure storage keys:
Firebase Auth: currentUser, dart
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| uploadProfileImage | dynamic uploadProfileImage(String memberId, File imageFile) | None |
| deleteProfileImage | dynamic deleteProfileImage(String authUid) | None |

⚠️ ISSUES:

### HealthProfileService
File: spring_health_member_app/lib/services/health_profile_service.dart
Singleton: no
Firestore collections: read (bodyMetricsLogs, fitnessTests, healthProfiles, logs, tests), write (bodyMetricsLogs, fitnessTests, healthProfiles)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getHealthProfile | dynamic getHealthProfile(String memberId) | health_profile_screen.dart |
| saveHealthProfile | dynamic saveHealthProfile(HealthProfileModel profile) | health_profile_screen.dart |
| logBodyMetrics | dynamic logBodyMetrics(String memberId, BodyMetricsLogModel log) | health_profile_screen.dart |
| getMetricsHistory | dynamic getMetricsHistory(String memberId, {     int limit = 30,   }) | health_profile_screen.dart |
| saveFitnessTest | dynamic saveFitnessTest(FitnessTestModel test) | health_profile_screen.dart |
| getLatestFitnessTest | dynamic getLatestFitnessTest(String memberId) | health_profile_screen.dart |
| watchHealthProfile | dynamic watchHealthProfile(String memberId) | None |

⚠️ ISSUES:

### InAppNotificationService
File: spring_health_member_app/lib/services/in_app_notification_service.dart
Singleton: yes
Firestore collections: read (items), write (notifications)
Secure storage keys:
Firebase Auth: currentUser, dart
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| addNotificationsForMemberBatch | dynamic addNotificationsForMemberBatch({     required String uid,     required List<NotificationData> notifications,   }) | None |
| addNotificationForMember | dynamic addNotificationForMember({     required String uid,     required NotificationType type,     required String title,     required String body,     Map<String, dynamic>? metadata,   }) | None |
| addNotification | dynamic addNotification({     required NotificationType type,     required String title,     required String body,     Map<String, dynamic>? metadata,   }) | None |
| streamAll | dynamic streamAll() | notifications_screen.dart |
| streamByType | dynamic streamByType(NotificationType type) | notifications_screen.dart, notifications_screen.dart, notifications_screen.dart |
| streamUnreadCount | dynamic streamUnreadCount() | notifications_screen.dart |
| markAsRead | dynamic markAsRead(String id) | notification_tile.dart |
| markAllAsRead | dynamic markAllAsRead() | notifications_screen.dart |
| deleteNotification | dynamic deleteNotification(String id) | notification_tile.dart |

⚠️ ISSUES:

### WorkoutService
File: spring_health_member_app/lib/services/workout_service.dart
Singleton: no
Firestore collections: read (workouts), write (gamification_events, personalbests, workouts)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| saveWorkout | dynamic saveWorkout(WorkoutLog workout) | workout_history_screen.dart, workout_logger_screen.dart |
| checkAndUpdatePersonalBests | dynamic checkAndUpdatePersonalBests(String memberId,     String sessionId,     List<WorkoutExercise> exercises,) | None |
| getWorkoutHistory | dynamic getWorkoutHistory(String memberId) | workout_history_screen.dart |
| getWeeklyWorkoutCount | dynamic getWeeklyWorkoutCount(String memberId) | None |

⚠️ ISSUES:

### BadgeService
File: spring_health_member_app/lib/services/badge_service.dart
Singleton: yes
Firestore collections: read (gamification), write (gamification)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| checkAndAward | dynamic checkAndAward(String memberId) | None |

⚠️ ISSUES:

### GamificationService
File: spring_health_member_app/lib/services/gamification_service.dart
Singleton: yes
Firestore collections: read (attendance, gamification, gamification_events, members), write (gamification, gamification_events, members)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getOrCreate | dynamic getOrCreate(String memberId) | home_screen.dart, member_attendance_screen.dart |
| processEvent | dynamic processEvent(String event,     String memberId, {     int? customXP,   }) | qr_checkin_screen.dart |
| calculateStreak | dynamic calculateStreak(String memberId) | None |
| listenToEvents | dynamic listenToEvents(String memberId) | home_screen.dart |
| stream | dynamic stream(String memberId) | xp_screen.dart, qr_checkin_screen.dart |
| awardXp | dynamic awardXp(String memberId,     String reason,     int xp, {     bool isCheckIn = false,     bool isWorkout = false,     int workoutVolumeKg = 0,   }) | home_screen.dart, workout_history_screen.dart, workout_logger_screen.dart |
| checkBadge | dynamic checkBadge(String id) | None |
| getLeaderboardWithNames | dynamic getLeaderboardWithNames({     String sortBy = 'totalXp',     int limit = 20,   }) | leaderboard_screen.dart |
| getMemberRank | dynamic getMemberRank(String memberId, {     String sortBy = 'totalXp',   }) | leaderboard_screen.dart |

⚠️ ISSUES:

### WearableSnapshotService
File: spring_health_member_app/lib/services/wearable_snapshot_service.dart
Singleton: yes
Firestore collections: read (daily, wearableSnapshots), write (wearableSnapshots)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| syncTodaySnapshot | dynamic syncTodaySnapshot(String memberId) | main_screen.dart, ai_coach_screen.dart |
| getLatestSnapshots | dynamic getLatestSnapshots(String memberId, {     int days = 7,   }) | None |
| getTodaySnapshot | dynamic getTodaySnapshot(String memberId) | home_screen.dart, ai_coach_screen.dart |

⚠️ ISSUES:

### FirebaseAuthService
File: spring_health_member_app/lib/services/firebase_auth_service.dart
Singleton: yes
Firestore collections: read (members), write (members)
Secure storage keys:
Firebase Auth: authStateChanges, currentUser, dart, signInWithCredential, signOut, verifyPhoneNumber
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| verifyOTP | dynamic verifyOTP(String otp, {       String? verificationId,     }) | otp_verification_screen.dart |
| getCurrentMemberId | dynamic getCurrentMemberId() | main_screen.dart, main_screen.dart, home_screen.dart, announcements_screen.dart, announcements_screen.dart |
| signOut | dynamic signOut() | settings_screen.dart, profile_screen.dart, membership_expired_screen.dart |

⚠️ ISSUES:

### RpeService
File: spring_health_member_app/lib/services/rpe_service.dart
Singleton: yes
Firestore collections: read (aiPlans, entries, rpeLog), write (aiPlans, rpeLog)
Secure storage keys:
Firebase Auth: currentUser, dart
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| submitRpe | dynamic submitRpe({     required int rpe,     required String label,     required String sessionId,     required List<String> muscleGroups,   }) | rpe_rating_sheet.dart |

⚠️ ISSUES:

### MemberService
File: spring_health_member_app/lib/services/member_service.dart
Singleton: no
Firestore collections: read (members), write (members)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getMemberData | dynamic getMemberData(String memberId) | main_screen.dart, main_screen.dart, home_screen.dart, workout_logger_screen.dart, announcements_screen.dart, announcements_screen.dart, war_screen.dart |
| getMemberByPhone | dynamic getMemberByPhone(String phone) | None |
| isMembershipActive | dynamic isMembershipActive(String memberId) | None |
| getMemberStream | dynamic getMemberStream(String memberId) | None |

⚠️ ISSUES:

### HealthService
File: spring_health_member_app/lib/services/health_service.dart
Singleton: yes
Firestore collections: read (daily), write (fitnessData)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| initialize | dynamic initialize() | None |
| isAvailable | dynamic isAvailable() | None |
| isConnected | dynamic isConnected() | None |
| requestPermissions | dynamic requestPermissions() | health_permission_screen.dart, stats_overview_widget.dart |
| checkPermissionStatus | dynamic checkPermissionStatus() | fitness_dashboard_screen.dart, stats_overview_widget.dart |
| openHealthConnectSettings | dynamic openHealthConnectSettings() | stats_overview_widget.dart, stats_overview_widget.dart |
| getTodayStats | dynamic getTodayStats() | fitness_dashboard_screen.dart, stats_overview_widget.dart |
| getWeeklyStats | dynamic getWeeklyStats() | fitness_dashboard_screen.dart |
| getLastNightSleep | dynamic getLastNightSleep() | None |
| saveToFirestore | dynamic saveToFirestore(String memberId, FitnessStats stats) | fitness_dashboard_screen.dart |
| syncTodayToFirestore | dynamic syncTodayToFirestore(String memberId) | stats_overview_widget.dart |
| reset | dynamic reset() | None |

⚠️ ISSUES:

### AttendanceService
File: spring_health_member_app/lib/services/attendance_service.dart
Singleton: no
Firestore collections: read (attendance), write (attendance)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getHistory | dynamic getHistory(String memberId) | member_attendance_screen.dart |
| streamHistory | dynamic streamHistory(String memberId) | None |
| buildCheckedInDates | dynamic buildCheckedInDates(List<AttendanceModel> records) | member_attendance_screen.dart |

⚠️ ISSUES:

### FirestoreService
File: spring_health_member_app/lib/services/firestore_service.dart
Singleton: no
Firestore collections: read (announcements, attendance, fitnessData, members, payments), write (announcements, attendance, fitnessData, members, payments)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| updateProfileImageUrl | dynamic updateProfileImageUrl(String memberId, String imageUrl) | None |
| getMemberById | dynamic getMemberById(String id) | None |
| getMemberByPhone | dynamic getMemberByPhone(String phone) | None |
| getMemberStream | dynamic getMemberStream(String memberId) | None |
| getAttendanceByMember | dynamic getAttendanceByMember(String memberId) | None |
| getAttendanceForDateRange | dynamic getAttendanceForDateRange(String memberId,     DateTime startDate,     DateTime endDate,) | None |
| hasCheckedInToday | dynamic hasCheckedInToday(String memberId) | None |
| getMonthlyAttendanceCount | dynamic getMonthlyAttendanceCount(String memberId) | None |
| getAnnouncements | dynamic getAnnouncements(String branch) | None |
| getAllAnnouncements | dynamic getAllAnnouncements() | None |
| markAnnouncementAsRead | dynamic markAnnouncementAsRead(String announcementId,     String memberId,) | None |
| getPaymentsByMember | dynamic getPaymentsByMember(String memberId) | None |
| getPaymentById | dynamic getPaymentById(String paymentId) | None |
| saveFitnessData | dynamic saveFitnessData(String memberId,     Map<String, dynamic> fitnessData,) | None |
| isMembershipActive | dynamic isMembershipActive(String memberId) | None |
| getDaysUntilExpiry | dynamic getDaysUntilExpiry(String memberId) | None |
| toMap | dynamic toMap() | None |

⚠️ ISSUES:

### AiCoachService
File: spring_health_member_app/lib/services/ai_coach_service.dart
Singleton: yes
Firestore collections: read (aiPlans, current, dietPlans, fitnessTests, tests), write (aiPlans, dietPlans, fitnessTests)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| syncWearablesAndGenerate | dynamic syncWearablesAndGenerate(String memberId) | None |

⚠️ ISSUES:

### WeeklyWarService
File: spring_health_member_app/lib/services/weekly_war_service.dart
Singleton: yes
Firestore collections: read (entries, weekly_wars), write (gamification, weekly_wars)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getActiveWar | dynamic getActiveWar(String branchId) | war_screen.dart |
| recordWorkoutEntry | dynamic recordWorkoutEntry(String memberId,     String branchId,     String exercise,     int reps,) | benchmark_test.dart, benchmark_test.dart |
| recordWorkoutEntries | dynamic recordWorkoutEntries(String memberId,     String branchId,     Map<String, int> exerciseReps,) | benchmark_test.dart, benchmark_test.dart, workout_logger_screen.dart |
| getWarLeaderboard | dynamic getWarLeaderboard(String warId) | war_screen.dart, war_screen.dart |
| completeWar | dynamic completeWar(String warId) | None |
| getPastWars | dynamic getPastWars(String branchId) | war_screen.dart |
| getMemberWarEntry | dynamic getMemberWarEntry(String warId,     String memberId,) | war_screen.dart |

⚠️ ISSUES:

### PaymentService
File: spring_health_member_app/lib/services/payment_service.dart
Singleton: no
Firestore collections: read (payments), write (payments)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getPaymentsByMember | dynamic getPaymentsByMember(String memberId) | payment_history_screen.dart |
| getTotalPaid | dynamic getTotalPaid(String memberId) | None |

⚠️ ISSUES:

---

## 2. ADMIN APP (Spring Health Studio) — Service Inventory

### EmailService
File: spring_health_studio/lib/services/email_service.dart
Singleton: no
Firestore collections: read (), write ()
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| sendInvoiceEmail | dynamic sendInvoiceEmail({     required String recipientEmail,     required String recipientName,     required String memberId,     required File invoicePdf,     required File membershipCardPdf,   }) | None |

⚠️ ISSUES:

### TeamBattleService
File: spring_health_studio/lib/services/team_battle_service.dart
Singleton: yes
Firestore collections: read (attendance, trainerTeamBattles, workouts), write (trainerTeamBattles)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| createBattle | dynamic createBattle({     required String organizerTrainerId,     required String organizerName,     required String team1Name,     required List<String> team1MemberIds,     required String team2TrainerId,     required String team2Name,     required List<String> team2MemberIds,     required String metric,     required String title,     required int durationDays,   }) | trainer_team_battle_screen.dart |
| getActiveBattlesForTrainer | dynamic getActiveBattlesForTrainer(String trainerId) | trainer_team_battle_screen.dart |
| computeAndUpdateScores | dynamic computeAndUpdateScores(String battleId) | trainer_team_battle_screen.dart |

⚠️ ISSUES:

### SessionService
File: spring_health_studio/lib/services/session_service.dart
Singleton: yes
Firestore collections: read (sessions), write (sessions)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| createSession | dynamic createSession({     required String memberId,     required String memberAuthUid,     required String trainerId,     required String trainerUid,     required String trainerName,     required String branch,   }) | trainer_scan_screen.dart |
| updateStatus | dynamic updateStatus(String sessionId, String status) | trainer_warmup_screen.dart, trainer_warmup_screen.dart, trainer_readiness_screen.dart |
| writeWarmup | dynamic writeWarmup(String sessionId,     List<Map<String, dynamic>> warmupExercises,) | trainer_readiness_screen.dart, trainer_readiness_screen.dart |
| writeExercises | dynamic writeExercises(String sessionId,     List<Map<String, dynamic>> exercises,) | None |
| markSetComplete | dynamic markSetComplete(String sessionId, int exerciseIndex) | None |
| writeStretching | dynamic writeStretching(String sessionId,     List<Map<String, dynamic>> stretchList,     List<String> musclesWorked,) | None |
| getActiveSessionForMember | dynamic getActiveSessionForMember(String memberAuthUid) | None |
| getSessionsForTrainer | dynamic getSessionsForTrainer(String trainerUid) | None |

⚠️ ISSUES:

### AnnouncementService
File: spring_health_studio/lib/services/announcement_service.dart
Singleton: no
Firestore collections: read (announcements, members), write ()
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getAll | dynamic getAll() | None |
| getActive | dynamic getActive({String? branch}) | None |
| getAnnouncementsStream | dynamic getAnnouncementsStream(String branch) | None |
| create | dynamic create(AnnouncementModel announcement) | None |
| update | dynamic update(AnnouncementModel announcement) | None |
| deactivate | dynamic deactivate(String id) | None |
| activate | dynamic activate(String id) | None |
| delete | dynamic delete(String id) | None |
| markAsRead | dynamic markAsRead(String announcementId, String memberId) | None |
| markAllAsRead | dynamic markAllAsRead(List<String> announcementIds, String memberId) | None |
| getTotalMemberCount | dynamic getTotalMemberCount(String branch) | None |

⚠️ ISSUES:

### NotificationService
File: spring_health_studio/lib/services/notification_service.dart
Singleton: yes
Firestore collections: read (), write ()
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| sendBirthdayWishes | dynamic sendBirthdayWishes({     String? branch,     List<MemberModel>? membersList,   }) | notifications_screen.dart |
| sendExpiryReminders | dynamic sendExpiryReminders({     String? branch,     List<MemberModel>? membersList,   }) | notifications_screen.dart |
| sendBatch | dynamic sendBatch(List<MemberModel> batch, int days) | None |
| sendDuePaymentReminders | dynamic sendDuePaymentReminders({     String? branch,     List<MemberModel>? membersList,   }) | notifications_screen.dart |
| runDailyReminders | dynamic runDailyReminders({String? branch}) | None |

⚠️ ISSUES:

### TrainerFeedbackService
File: spring_health_studio/lib/services/trainer_feedback_service.dart
Singleton: no
Firestore collections: read (trainerFeedback), write ()
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getFeedbackForTrainer | dynamic getFeedbackForTrainer(String trainerId) | trainer_detail_screen.dart |
| addFeedback | dynamic addFeedback(TrainerFeedbackModel feedback) | None |
| deleteFeedback | dynamic deleteFeedback(String id) | None |

⚠️ ISSUES:

### ReminderService
File: spring_health_studio/lib/services/reminder_service.dart
Singleton: no
Firestore collections: read (members, reminder_logs), write (reminder_logs)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getMembersWithDues | dynamic getMembersWithDues({String? branch}) | notifications_dashboard.dart, reminders_dashboard.dart |
| getMembersExpiringSoon | dynamic getMembersExpiringSoon({     required int days,     String? branch,   }) | notifications_dashboard.dart, reminders_dashboard.dart |
| getTodayBirthdays | dynamic getTodayBirthdays({String? branch}) | notifications_dashboard.dart, reminders_dashboard.dart |
| sendDuesReminder | dynamic sendDuesReminder(MemberModel member) | reminders_dashboard.dart |
| sendExpiryReminder | dynamic sendExpiryReminder(MemberModel member, {required int daysLeft}) | notifications_dashboard.dart, reminders_dashboard.dart |
| sendBirthdayWish | dynamic sendBirthdayWish(MemberModel member) | notifications_dashboard.dart, reminders_dashboard.dart |
| getMessageTemplates | dynamic getMessageTemplates() | reminders_dashboard.dart |
| sendRejoinMessage | dynamic sendRejoinMessage(MemberModel member) | notifications_dashboard.dart |

⚠️ ISSUES:

### FeeCalculator
File: spring_health_studio/lib/services/fee_calculator.dart
Singleton: no
Firestore collections: read (), write ()
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|

⚠️ ISSUES:

### AdminGamificationService
File: spring_health_studio/lib/services/admin_gamification_service.dart
Singleton: no
Firestore collections: read (challengeEntries, challenges, gamification, members), write (gamification, members)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getLeaderboard | dynamic getLeaderboard({     required String sortBy,     int limit = 50,     String? branch,   }) | admin_gamification_dashboard_screen.dart |
| getChallengesCount | dynamic getChallengesCount() | admin_gamification_dashboard_screen.dart |
| getChallengeEntriesCount | dynamic getChallengeEntriesCount() | admin_gamification_dashboard_screen.dart |
| adjustXp | dynamic adjustXp({     required String memberId,     required int delta,     required String reason,   }) | admin_gamification_dashboard_screen.dart |
| awardBadge | dynamic awardBadge({     required String memberId,     required String badgeId,   }) | admin_gamification_dashboard_screen.dart |
| resetStreak | dynamic resetStreak({required String memberId}) | admin_gamification_dashboard_screen.dart |

⚠️ ISSUES:

### StorageService
File: spring_health_studio/lib/services/storage_service.dart
Singleton: no
Firestore collections: read (), write ()
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| uploadMemberPhoto | dynamic uploadMemberPhoto({     required String memberId,     required File imageFile,     String? oldPhotoUrl,     ValueChanged<double>? onProgress,   }) | None |
| uploadTrainerPhoto | dynamic uploadTrainerPhoto({     required String trainerId,     required File imageFile,     String? oldPhotoUrl,     ValueChanged<double>? onProgress,   }) | None |
| deletePhotoByUrl | dynamic deletePhotoByUrl(String photoUrl) | None |
| getMemberPhotoUrl | dynamic getMemberPhotoUrl(String memberId) | None |
| getTrainerPhotoUrl | dynamic getTrainerPhotoUrl(String trainerId) | None |
| getPhotoMetadata | dynamic getPhotoMetadata(String photoUrl) | None |
| generateThumbnailUrl | dynamic generateThumbnailUrl(String photoUrl,       {int width = 100, int height = 100}) | None |
| photoExists | dynamic photoExists(String photoUrl) | None |

⚠️ ISSUES:

### DocumentService
File: spring_health_studio/lib/services/document_service.dart
Singleton: no
Firestore collections: read (), write ()
Secure storage keys:
Firebase Auth: currentUser, dart
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| isConnected | dynamic isConnected() | None |
| sendDocument | dynamic sendDocument({     required BuildContext context,     required MemberModel member,     required String documentType,     required String method, // 'whatsapp', 'email', 'both'   PaymentModel? payment,   int retryCount = 0,   }) | None |
| retryFailedOperation | dynamic retryFailedOperation(BuildContext context,     MemberModel member,     String documentType,     String method,     PaymentModel? payment,     int previousRetryCount,) | None |

⚠️ ISSUES:

### MemberFitnessService
File: spring_health_studio/lib/services/member_fitness_service.dart
Singleton: no
Firestore collections: read (gamification, sessions, workouts), write (gamification, workouts)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| getWorkouts | dynamic getWorkouts(String memberId, {       int limit = 20,     }) | member_fitness_tab.dart, member_fitness_tab.dart |

⚠️ ISSUES:

### AuthService
File: spring_health_studio/lib/services/auth_service.dart
Singleton: no
Firestore collections: read (trainers, users), write (users)
Secure storage keys:
Firebase Auth: authStateChanges, createUserWithEmailAndPassword, currentUser, dart, sendPasswordResetEmail, signInWithEmailAndPassword, signOut
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| signInWithEmailPassword | dynamic signInWithEmailPassword(String email, String password) | None |
| signInAndResolveUser | dynamic signInAndResolveUser(String email, String password) | login_screen.dart |
| createUserWithEmailPassword | dynamic createUserWithEmailPassword(String email, String password) | None |
| signOut | dynamic signOut() | trainer_dashboard_screen.dart, login_screen.dart |
| resetPassword | dynamic resetPassword(String email) | None |

⚠️ ISSUES:

### WhatsAppService
File: spring_health_studio/lib/services/whatsapp_service.dart
Singleton: yes
Firestore collections: read (), write ()
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| sendMessage | dynamic sendMessage({     required String phoneNumber,     required String message,   }) | None |
| sendWelcomeMessage | dynamic sendWelcomeMessage(MemberModel member) | member_detail_screen.dart |
| sendPaymentReceipt | dynamic sendPaymentReceipt({     required MemberModel member,     required PaymentModel payment,   }) | member_detail_screen.dart |
| sendExpiryReminder | dynamic sendExpiryReminder(MemberModel member, int daysLeft) | member_detail_screen.dart, notifications_dashboard.dart |
| sendDuePaymentReminder | dynamic sendDuePaymentReminder(MemberModel member) | member_detail_screen.dart, notifications_dashboard.dart |
| sendBirthdayWish | dynamic sendBirthdayWish(MemberModel member) | notifications_dashboard.dart |
| sendRejoinMessage | dynamic sendRejoinMessage(MemberModel member) | notifications_dashboard.dart |
| sendCustomMessage | dynamic sendCustomMessage({     required String phoneNumber,     required String memberName,     required String customMessage,     String? branch,   }) | member_detail_screen.dart |
| sendWelcomePackage | dynamic sendWelcomePackage(MemberModel member) | document_send_dialog.dart |
| sendRejoinPackage | dynamic sendRejoinPackage(MemberModel member) | document_send_dialog.dart, rejoin_member_screen.dart |
| sendPaymentReceiptWithInvoice | dynamic sendPaymentReceiptWithInvoice(MemberModel member,     PaymentModel payment,) | document_send_dialog.dart |
| resendDocuments | dynamic resendDocuments(MemberModel member) | document_send_dialog.dart |
| isWhatsAppInstalled | dynamic isWhatsAppInstalled() | None |

⚠️ ISSUES:

### FirestoreService
File: spring_health_studio/lib/services/firestore_service.dart
Singleton: yes
Firestore collections: read (attendance, dietPlans, expenses, members, payments, trainerFeedback, trainers, users), write (attendance, dietPlans, expenses, members, payments, trainerFeedback, trainers, users)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| addMember | dynamic addMember(MemberModel member) | add_member_screen.dart |
| updateMember | dynamic updateMember(MemberModel member) | collect_dues_screen.dart, rejoin_member_screen.dart, member_detail_screen.dart, edit_member_screen.dart |
| addDocumentHistory | dynamic addDocumentHistory(String memberId, DocumentSentModel document) | None |
| addDocumentHistoryBatch | dynamic addDocumentHistoryBatch(String memberId, List<DocumentSentModel> documents) | None |
| getDocumentHistory | dynamic getDocumentHistory(String memberId) | None |
| clearDocumentHistory | dynamic clearDocumentHistory(String memberId) | None |
| getMembersWithoutWelcomePackage | dynamic getMembersWithoutWelcomePackage(String? branch) | None |
| getMembersWithRecentDocuments | dynamic getMembersWithRecentDocuments(int days, String? branch) | None |
| getMemberById | dynamic getMemberById(String id) | member_detail_screen.dart, qr_scanner_screen.dart, trainer_scan_screen.dart |
| getMemberByQrCode | dynamic getMemberByQrCode(String qrCode) | None |
| getMemberByPhone | dynamic getMemberByPhone(String phone) | add_member_screen.dart |
| getAllMembers | dynamic getAllMembers({bool includeArchived = false}) | reports_screen.dart, trainer_detail_screen.dart |
| getMembersByBranch | dynamic getMembersByBranch(String branch,     {bool includeArchived = false}) | reports_screen.dart |
| getMembers | dynamic getMembers({String? branch}) | members_list_screen.dart, owner_dashboard.dart |
| getArchivedMembers | dynamic getArchivedMembers({String? branch}) | members_list_screen.dart |
| addTrainer | dynamic addTrainer(TrainerModel trainer) | add_trainer_screen.dart |
| updateTrainer | dynamic updateTrainer(TrainerModel trainer) | trainer_detail_screen.dart, add_trainer_screen.dart |
| getTrainerById | dynamic getTrainerById(String id) | trainer_detail_screen.dart, trainer_dashboard_screen.dart |
| getTrainerByUserId | dynamic getTrainerByUserId(String authUid) | None |
| getAllTrainers | dynamic getAllTrainers({String? branch}) | trainers_list_screen.dart |
| getTrainersByBranch | dynamic getTrainersByBranch(String branch) | trainers_list_screen.dart |
| assignMemberToTrainer | dynamic assignMemberToTrainer(String trainerId, String memberId) | trainer_detail_screen.dart |
| removeMemberFromTrainer | dynamic removeMemberFromTrainer(String trainerId, String memberId) | trainer_detail_screen.dart |
| getMembersByTrainer | dynamic getMembersByTrainer(String trainerId) | trainer_detail_screen.dart, trainer_detail_screen.dart, trainer_dashboard_screen.dart, trainer_dashboard_screen.dart, trainer_dashboard_screen.dart, trainer_dashboard_screen.dart, trainer_dashboard_screen.dart, trainer_dashboard_screen.dart, trainer_dashboard_screen.dart |
| getTrainerFeedback | dynamic getTrainerFeedback(String trainerId) | trainer_dashboard_screen.dart |
| replyToFeedback | dynamic replyToFeedback(String trainerId, String feedbackId, String reply) | trainer_dashboard_screen.dart |
| updateTrainerProfile | dynamic updateTrainerProfile(String trainerId, Map<String, dynamic> updates) | None |
| recordAttendance | dynamic recordAttendance(AttendanceModel attendance) | qr_scanner_screen.dart, trainer_scan_screen.dart |
| addAttendance | dynamic addAttendance(AttendanceModel attendance) | None |
| hasCheckedInToday | dynamic hasCheckedInToday(String memberId, String branch) | qr_scanner_screen.dart, trainer_scan_screen.dart |
| getAttendanceByMember | dynamic getAttendanceByMember(String memberId, {String? branch}) | member_detail_screen.dart |
| getAttendanceByBranch | dynamic getAttendanceByBranch(String branch, DateTime date) | attendance_history_screen.dart |
| getAttendanceForDateRange | dynamic getAttendanceForDateRange(String? branch,     DateTime startDate,     DateTime endDate,) | reports_screen.dart, attendance_history_screen.dart |
| getTodayCheckInsCount | dynamic getTodayCheckInsCount(String branch) | receptionist_dashboard_web.dart, receptionist_dashboard.dart |
| getRecentCheckIns | dynamic getRecentCheckIns(String? branch, {int limit = 10}) | None |
| addPayment | dynamic addPayment(PaymentModel payment) | collect_dues_screen.dart, rejoin_member_screen.dart, add_member_screen.dart, edit_member_screen.dart |
| getPaymentsByMember | dynamic getPaymentsByMember(String memberId, {String? branch}) | member_detail_screen.dart, member_detail_screen.dart |
| getPaymentsForDateRange | dynamic getPaymentsForDateRange(String? branch,     DateTime startDate,     DateTime endDate,) | reports_screen.dart |
| getMembersWithDuesCount | dynamic getMembersWithDuesCount(String? branch) | None |
| addExpense | dynamic addExpense(ExpenseModel expense) | add_expense_screen.dart |
| updateExpense | dynamic updateExpense(ExpenseModel expense) | None |
| deleteExpense | dynamic deleteExpense(String id) | None |
| getExpenses | dynamic getExpenses(String? branch) | None |
| getExpensesForDateRange | dynamic getExpensesForDateRange(String? branch,     DateTime startDate,     DateTime endDate,) | expenses_screen.dart |
| getTotalExpenses | dynamic getTotalExpenses(String? branch, DateTime startDate, DateTime endDate) | None |
| getAssignedMembers | dynamic getAssignedMembers(String branch, List<String> assignedIds) | None |
| saveDietPlan | dynamic saveDietPlan(DietPlanModel dietPlan) | None |
| getDietPlans | dynamic getDietPlans(String memberId) | None |

⚠️ ISSUES:

### PDFService
File: spring_health_studio/lib/services/pdf_service.dart
Singleton: no
Firestore collections: read (), write ()
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|
| generateMembershipCard | dynamic generateMembershipCard(MemberModel member) | member_detail_screen.dart |
| generateInvoice | dynamic generateInvoice(MemberModel member) | member_detail_screen.dart |
| generatePaymentReceipt | dynamic generatePaymentReceipt({     required MemberModel member,     required PaymentModel payment,   }) | member_detail_screen.dart |
| printPDF | dynamic printPDF(Uint8List pdfData) | member_detail_screen.dart |
| savePDF | dynamic savePDF(Uint8List pdfData, String fileName) | member_detail_screen.dart, member_detail_screen.dart |

⚠️ ISSUES:

### TrainerAjaxService
File: spring_health_studio/lib/services/trainer_ajax_service.dart
Singleton: no
Firestore collections: read (aiPlans, current, daily, healthProfiles, items, members, personalbests, sessions, workouts), write (gamificationEvents, notifications, personalbests, sessions, wearableSnapshots, workouts)
Secure storage keys:
Firebase Auth:
Firebase Storage paths:

| Method | Signature | Called By |
|--------|-----------|-----------|

⚠️ ISSUES:

---

## 3. MEMBER APP — Screen → Service Dependency Map

| Screen File | Services Used | Methods Called |
|-------------|---------------|----------------|
| web_plugin_registrant.dart |  |  |
| dart_plugin_registrant.dart |  |  |
| app_config.dart |  |  |
| asset_paths.dart |  |  |
| app_colors.dart |  |  |
| app_dimensions.dart |  |  |
| app_text_styles.dart |  |  |
| app_theme.dart |  |  |
| firebase_options.dart |  |  |
| main.dart | NotificationService | initialize |
| ai_coach_screen.dart | WearableSnapshotService, AiCoachService | syncTodaySnapshot, getTodaySnapshot |
| announcements_screen.dart | AnnouncementService, NotificationService, FirebaseAuthService, MemberService | subscribeToTopics, markAsRead, getCurrentMemberId, getMemberData, getAnnouncementsStream |
| member_attendance_screen.dart | GamificationService, AttendanceService | buildCheckedInDates, getHistory, getOrCreate |
| login_screen.dart | FirebaseAuthService |  |
| otp_verification_screen.dart | FirebaseAuthService | verifyOTP |
| qr_checkin_screen.dart | GamificationService | processEvent, stream |
| war_screen.dart | ChallengeService, MemberService, WeeklyWarService | getPastWars, getMemberWarEntry, getActiveWar, getWarLeaderboard, getActiveChallengeStream, createDemoChallenge, getMemberData |
| war_screen_test.dart |  |  |
| war_screen_test_patch.dart |  |  |
| diet_plan_screen.dart | AiCoachService |  |
| body_metrics_screen.dart | BodyMetricsService | deleteMetrics, addMetrics, getMetricsStream |
| fitness_dashboard_screen.dart | HealthService | getTodayStats, getWeeklyStats, checkPermissionStatus, saveToFirestore |
| health_permission_screen.dart | HealthService | requestPermissions |
| live_session_screen.dart |  |  |
| personal_bests_screen.dart |  |  |
| fitness_chart_widget.dart |  |  |
| stats_card_widget.dart |  |  |
| weekly_chart_widget.dart |  |  |
| workout_card_widget.dart |  |  |
| leaderboard_screen.dart | GamificationService | getLeaderboardWithNames, getMemberRank |
| xp_screen.dart | GamificationService | stream |
| health_profile_screen.dart | HealthProfileService | saveHealthProfile, saveFitnessTest, getLatestFitnessTest, logBodyMetrics, getMetricsHistory, getHealthProfile |
| home_screen.dart | GamificationService, WearableSnapshotService, FirebaseAuthService, MemberService, AiCoachService | getTodaySnapshot, getOrCreate, awardXp, getCurrentMemberId, listenToEvents, getMemberData |
| membership_card_widget.dart |  |  |
| membership_expiry_banner.dart |  |  |
| stats_overview_widget.dart | HealthService | syncTodayToFirestore, requestPermissions, openHealthConnectSettings, getTodayStats, checkPermissionStatus |
| membership_expired_screen.dart | FirebaseAuthService | signOut |
| main_screen.dart | MembershipAlertService, WearableSnapshotService, FirebaseAuthService, MemberService | checkAndNotify, getCurrentMemberId, getMemberData, syncTodaySnapshot |
| notifications_screen.dart | NotificationService, InAppNotificationService | streamAll, streamByType, markAllAsRead, streamUnreadCount |
| notification_tile.dart | NotificationService, InAppNotificationService | markAsRead, deleteNotification |
| payment_history_screen.dart | PaymentService | getPaymentsByMember |
| edit_profile_screen.dart |  |  |
| member_goal_screen.dart |  |  |
| profile_screen.dart | FirebaseAuthService | signOut |
| membership_info_card.dart |  |  |
| profile_header_widget.dart |  |  |
| settings_tile_widget.dart |  |  |
| renewal_confirmation_screen.dart |  |  |
| renewal_screen.dart | RenewalService | processSuccessfulRenewal |
| settings_screen.dart | FirebaseAuthService | signOut |
| social_coming_soon_screen.dart |  |  |
| splash_screen.dart | FirebaseAuthService |  |
| trainer_feedback_screen.dart | TrainerFeedbackService | submitFeedback |
| trainer_screen.dart | TrainerService | getDietPlanStream, getTrainersStream, getMyTrainerStream |
| member_session_screen.dart |  |  |
| workout_detail_screen.dart |  |  |
| workout_history_screen.dart | WorkoutService, GamificationService | getWorkoutHistory, awardXp, saveWorkout |
| workout_logger_screen.dart | WorkoutService, GamificationService, MemberService, WeeklyWarService | getMemberData, awardXp, saveWorkout, recordWorkoutEntries |
| ai_loading_overlay.dart |  |  |
| goal_set_sheet.dart |  |  |
| rpe_rating_sheet.dart | RpeService | submitRpe |
| spring_health_logo_animated.dart |  |  |
| benchmark_test.dart | WeeklyWarService | recordWorkoutEntry, recordWorkoutEntries |

---

## 4. ADMIN APP — Screen → Service Dependency Map

| Screen File | Services Used | Methods Called |
|-------------|---------------|----------------|
| firebase_options.dart |  |  |
| main.dart | FirestoreService |  |
| analytics_dashboard.dart | FirestoreService |  |
| announcements_list_screen.dart |  |  |
| create_announcement_screen.dart |  |  |
| attendance_history_screen.dart | FirestoreService | getAttendanceForDateRange, getAttendanceByBranch |
| qr_scanner_screen.dart | FirestoreService | hasCheckedInToday, recordAttendance, getMemberById |
| login_screen.dart | AuthService, FirestoreService | signInAndResolveUser, signOut |
| equipment_manager_screen.dart | AuthService |  |
| add_expense_screen.dart | FirestoreService | addExpense |
| expenses_screen.dart | FirestoreService | getExpensesForDateRange |
| admin_gamification_dashboard_screen.dart | AdminGamificationService | getChallengeEntriesCount, getLeaderboard, getChallengesCount, adjustXp, awardBadge, resetStreak |
| add_member_screen.dart | FirestoreService | addMember, addPayment, getMemberByPhone |
| collect_dues_screen.dart | FirestoreService | updateMember, addPayment |
| edit_member_screen.dart | FeeCalculator, FirestoreService | updateMember, addPayment |
| member_ai_plan_screen.dart |  |  |
| member_detail_screen.dart | WhatsAppService, FirestoreService, PDFService | updateMember, sendPaymentReceipt, generateMembershipCard, sendWelcomeMessage, sendExpiryReminder, sendCustomMessage, sendDuePaymentReminder, generatePaymentReceipt, generateInvoice, savePDF, getMemberById, getAttendanceByMember, printPDF, getPaymentsByMember |
| member_fitness_tab.dart | MemberFitnessService | getWorkouts |
| members_list_screen.dart | FirestoreService | getMembers, getArchivedMembers |
| rejoin_member_screen.dart | WhatsAppService, FirestoreService | updateMember, sendRejoinPackage, addPayment |
| notifications_dashboard.dart | ReminderService, WhatsAppService | sendExpiryReminder, sendDuePaymentReminder, sendBirthdayWish, sendRejoinMessage, getMembersWithDues, getMembersExpiringSoon, getTodayBirthdays |
| notifications_screen.dart | NotificationService | sendDuePaymentReminders, sendBirthdayWishes, sendExpiryReminders |
| send_push_notification_screen.dart |  |  |
| owner_dashboard.dart | FirestoreService | getMembers |
| owner_dashboard_web.dart | FirestoreService |  |
| receptionist_dashboard.dart | FirestoreService | getTodayCheckInsCount |
| receptionist_dashboard_web.dart | FirestoreService | getTodayCheckInsCount |
| reminders_dashboard.dart | ReminderService | getMessageTemplates, sendExpiryReminder, sendBirthdayWish, getMembersWithDues, getMembersExpiringSoon, getTodayBirthdays, sendDuesReminder |
| reports_screen.dart | FirestoreService | getPaymentsForDateRange, getAttendanceForDateRange, getAllMembers, getMembersByBranch |
| add_trainer_screen.dart | FirestoreService | addTrainer, updateTrainer |
| flexibility_assessment_screen.dart |  |  |
| trainer_dashboard_screen.dart | AuthService, FirestoreService | getTrainerById, getMembersByTrainer, getTrainerFeedback, signOut, replyToFeedback |
| trainer_detail_screen.dart | TrainerFeedbackService, FirestoreService | removeMemberFromTrainer, getAllMembers, getTrainerById, getMembersByTrainer, assignMemberToTrainer, getFeedbackForTrainer, updateTrainer |
| trainer_member_detail_screen.dart |  |  |
| trainer_plan_override_screen.dart |  |  |
| trainer_readiness_screen.dart | SessionService | writeWarmup, updateStatus |
| trainer_scan_screen.dart | SessionService, FirestoreService | hasCheckedInToday, recordAttendance, getMemberById, createSession |
| trainer_session_screen.dart |  |  |
| trainer_stretching_screen.dart | TrainerAjaxService |  |
| trainer_team_battle_screen.dart | TeamBattleService | computeAndUpdateScores, createBattle, getActiveBattlesForTrainer |
| trainer_warmup_screen.dart | SessionService, TrainerAjaxService | updateStatus |
| trainers_list_screen.dart | FirestoreService | getTrainersByBranch, getAllTrainers |
| app_colors.dart |  |  |
| app_dimensions.dart |  |  |
| app_theme.dart |  |  |
| text_styles.dart |  |  |
| constants.dart |  |  |
| date_utils.dart |  |  |
| responsive.dart |  |  |
| validators.dart |  |  |
| custom_dropdown.dart |  |  |
| document_send_dialog.dart | WhatsAppService | resendDocuments, sendPaymentReceiptWithInvoice, sendRejoinPackage, sendWelcomePackage |
| goal_set_sheet.dart |  |  |
| member_card.dart |  |  |
| payment_mode_selector.dart |  |  |
| pdf_preview_dialog.dart |  |  |
| photo_picker_widget.dart | StorageService |  |
| quick_action_card.dart |  |  |
| recent_members_card.dart |  |  |
| stat_card.dart |  |  |

---

## 5. RAW FIRESTORE ACCESS OUTSIDE SERVICES (Anti-Pattern)

| File | Line | Raw Query | Should Use Instead |
|------|------|-----------|-------------------|
| benchmark_test.dart | 2 | `import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';` | Service call |
| benchmark_test.dart | 3 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| goal_set_sheet.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| goal_set_sheet.dart | 182 | `await FirebaseFirestore.instance` | Service call |
| main_screen.dart | 7 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| main_screen.dart | 151 | `_memberSub = FirebaseFirestore.instance` | Service call |
| main_screen.dart | 181 | `_announcementSub = FirebaseFirestore.instance` | Service call |
| profile_screen.dart | 3 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| profile_screen.dart | 157 | `await FirebaseFirestore.instance` | Service call |
| profile_screen.dart | 162 | `await FirebaseFirestore.instance.collection('members').doc(uid).update({` | Service call |
| edit_profile_screen.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| edit_profile_screen.dart | 144 | `await FirebaseFirestore.instance.collection('members').doc(uid).update({` | Service call |
| edit_profile_screen.dart | 179 | `await FirebaseFirestore.instance` | Service call |
| live_session_screen.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| live_session_screen.dart | 18 | `stream: FirebaseFirestore.instance` | Service call |
| fitness_dashboard_screen.dart | 5 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| fitness_dashboard_screen.dart | 43 | `_sessionStream = FirebaseFirestore.instance` | Service call |
| personal_bests_screen.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| personal_bests_screen.dart | 27 | `stream: FirebaseFirestore.instance` | Service call |
| diet_plan_screen.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| diet_plan_screen.dart | 48 | `final planDoc = await FirebaseFirestore.instance` | Service call |
| home_screen.dart | 23 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| home_screen.dart | 397 | `stream: FirebaseFirestore.instance.collection('memberGoals').doc(uid).snapshots(),` | Service call |
| member_session_screen.dart | 3 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| member_session_screen.dart | 79 | `stream: FirebaseFirestore.instance` | Service call |
| workout_history_screen.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| workout_history_screen.dart | 669 | `await FirebaseFirestore.instance.collection('gamification_events').add({` | Service call |
| ai_coach_screen.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| qr_checkin_screen.dart | 5 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| qr_checkin_screen.dart | 68 | `_attendanceSub = FirebaseFirestore.instance` | Service call |
| goal_set_sheet.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| goal_set_sheet.dart | 182 | `await FirebaseFirestore.instance` | Service call |
| collect_dues_screen.dart | 8 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| collect_dues_screen.dart | 129 | `await FirebaseFirestore.instance.collection('gamification_events').add({` | Service call |
| rejoin_member_screen.dart | 9 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| rejoin_member_screen.dart | 249 | `await FirebaseFirestore.instance.collection('gamification_events').add({` | Service call |
| member_detail_screen.dart | 21 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| member_detail_screen.dart | 634 | `stream: FirebaseFirestore.instance.collection('memberGoals').doc(currentMember!.id).snapshots(),` | Service call |
| member_ai_plan_screen.dart | 1 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| member_ai_plan_screen.dart | 47 | `final doc = await FirebaseFirestore.instance` | Service call |
| member_ai_plan_screen.dart | 84 | `await FirebaseFirestore.instance` | Service call |
| member_ai_plan_screen.dart | 187 | `stream: FirebaseFirestore.instance` | Service call |
| notifications_dashboard.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| notifications_dashboard.dart | 82 | `final snapshot = await FirebaseFirestore.instance` | Service call |
| send_push_notification_screen.dart | 4 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| send_push_notification_screen.dart | 44 | `final _db = FirebaseFirestore.instance;` | Service call |
| create_announcement_screen.dart | 4 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| create_announcement_screen.dart | 76 | `await FirebaseFirestore.instance.collection('announcements').add({` | Service call |
| announcements_list_screen.dart | 4 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| announcements_list_screen.dart | 39 | `return FirebaseFirestore.instance` | Service call |
| announcements_list_screen.dart | 491 | `await FirebaseFirestore.instance` | Service call |
| announcements_list_screen.dart | 534 | `await FirebaseFirestore.instance` | Service call |
| equipment_manager_screen.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| equipment_manager_screen.dart | 229 | `await FirebaseFirestore.instance` | Service call |
| equipment_manager_screen.dart | 288 | `await FirebaseFirestore.instance` | Service call |
| equipment_manager_screen.dart | 381 | `stream: FirebaseFirestore.instance` | Service call |
| equipment_manager_screen.dart | 499 | `stream: FirebaseFirestore.instance` | Service call |
| trainer_warmup_screen.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| trainer_warmup_screen.dart | 128 | `stream: FirebaseFirestore.instance` | Service call |
| trainer_warmup_screen.dart | 256 | `final snap = await FirebaseFirestore.instance` | Service call |
| trainer_warmup_screen.dart | 265 | `await FirebaseFirestore.instance` | Service call |
| flexibility_assessment_screen.dart | 1 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| flexibility_assessment_screen.dart | 113 | `final db = FirebaseFirestore.instance;` | Service call |
| trainer_plan_override_screen.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| trainer_plan_override_screen.dart | 20 | `final FirebaseFirestore _firestore = FirebaseFirestore.instance;` | Service call |
| trainer_scan_screen.dart | 4 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| trainer_scan_screen.dart | 112 | `final memberDoc = await FirebaseFirestore.instance.collection('members').doc(member.id).get();` | Service call |
| trainer_scan_screen.dart | 132 | `final trainerDoc = await FirebaseFirestore.instance.collection('users').doc(trainerUid).get();` | Service call |
| trainer_scan_screen.dart | 176 | `final intelligenceDoc = await FirebaseFirestore.instance.collection('memberIntelligence').doc(memberUid).get();` | Service call |
| trainer_scan_screen.dart | 187 | `FirebaseFirestore.instance.collection('wearableSnapshots').doc(memberUid).collection('daily').doc(yesterdayStr).get(),` | Service call |
| trainer_scan_screen.dart | 188 | `FirebaseFirestore.instance.collection('aiPlans').doc(memberUid).collection('current').doc('current').get(),` | Service call |
| trainer_scan_screen.dart | 189 | `FirebaseFirestore.instance.collection('trainingSessions').where('memberId', isEqualTo: member.id).where('status', isEqualTo: 'complete').orderBy('date', descending: true).limit(1).get(),` | Service call |
| trainer_scan_screen.dart | 190 | `FirebaseFirestore.instance.collection('healthProfiles').doc(memberUid).get(),` | Service call |
| trainer_scan_screen.dart | 191 | `FirebaseFirestore.instance.collection('bodyMetricsLogs').doc(memberUid).collection('logs').orderBy('date', descending: true).limit(4).get(),` | Service call |
| trainer_scan_screen.dart | 192 | `FirebaseFirestore.instance.collection('memberGoals').doc(memberUid).get(),` | Service call |
| trainer_scan_screen.dart | 194 | `FirebaseFirestore.instance.collection('gymEquipment').doc(member.branch).get(),` | Service call |
| trainer_stretching_screen.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| trainer_stretching_screen.dart | 51 | `await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).set({` | Service call |
| trainer_stretching_screen.dart | 92 | `await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).set({` | Service call |
| trainer_member_detail_screen.dart | 1 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| trainer_member_detail_screen.dart | 51 | `final doc = await FirebaseFirestore.instance` | Service call |
| trainer_member_detail_screen.dart | 200 | `future: FirebaseFirestore.instance` | Service call |
| trainer_member_detail_screen.dart | 303 | `future: FirebaseFirestore.instance` | Service call |
| trainer_member_detail_screen.dart | 381 | `future: FirebaseFirestore.instance` | Service call |
| trainer_member_detail_screen.dart | 448 | `future: FirebaseFirestore.instance` | Service call |
| trainer_member_detail_screen.dart | 544 | `stream: FirebaseFirestore.instance` | Service call |
| trainer_dashboard_screen.dart | 13 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| trainer_dashboard_screen.dart | 488 | `future: FirebaseFirestore.instance.collection('memberGoals').doc(client.id).get(),` | Service call |
| trainer_dashboard_screen.dart | 985 | `stream: FirebaseFirestore.instance` | Service call |
| trainer_dashboard_screen.dart | 1001 | `stream: FirebaseFirestore.instance` | Service call |
| trainer_dashboard_screen.dart | 1249 | `stream: FirebaseFirestore.instance` | Service call |
| trainer_dashboard_screen.dart | 1280 | `stream: FirebaseFirestore.instance` | Service call |
| trainer_dashboard_screen.dart | 1388 | `stream: FirebaseFirestore.instance` | Service call |
| trainer_dashboard_screen.dart | 1416 | `stream: FirebaseFirestore.instance` | Service call |
| trainer_dashboard_screen.dart | 1518 | `await FirebaseFirestore.instance` | Service call |
| trainer_session_screen.dart | 3 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| trainer_session_screen.dart | 80 | `final docRef = FirebaseFirestore.instance` | Service call |
| trainer_session_screen.dart | 84 | `await FirebaseFirestore.instance` | Service call |
| trainer_session_screen.dart | 119 | `final docRef = FirebaseFirestore.instance` | Service call |
| trainer_session_screen.dart | 123 | `await FirebaseFirestore.instance` | Service call |
| trainer_session_screen.dart | 168 | `stream: FirebaseFirestore.instance` | Service call |
| trainer_session_screen.dart | 224 | `stream: FirebaseFirestore.instance` | Service call |
| trainer_session_screen.dart | 253 | `await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).set({` | Service call |
| trainer_readiness_screen.dart | 2 | `import 'package:cloud_firestore/cloud_firestore.dart';` | Service call |
| trainer_readiness_screen.dart | 45 | `final memberDoc = await FirebaseFirestore.instance.collection('members').doc(widget.member.id).get();` | Service call |
| trainer_readiness_screen.dart | 48 | `final sessionQuery = await FirebaseFirestore.instance` | Service call |
| trainer_readiness_screen.dart | 60 | `final aiPlanDoc = await FirebaseFirestore.instance` | Service call |
| trainer_readiness_screen.dart | 71 | `final healthProfileDoc = await FirebaseFirestore.instance` | Service call |
| trainer_readiness_screen.dart | 112 | `await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).update({` | Service call |

---

## 6. RAW FIREBASE AUTH ACCESS OUTSIDE SERVICES (Anti-Pattern)

| File | Line | Raw Call | Should Use Instead |
|------|------|----------|-------------------|
| member_goal_screen.dart | 2 | `import 'package:firebase_auth/firebase_auth.dart';` | Service call |
| member_goal_screen.dart | 30 | `final authUid = FirebaseAuth.instance.currentUser?.uid;` | Service call |
| profile_screen.dart | 4 | `import 'package:firebase_auth/firebase_auth.dart';` | Service call |
| profile_screen.dart | 143 | `final uid = FirebaseAuth.instance.currentUser!.uid;` | Service call |
| edit_profile_screen.dart | 3 | `import 'package:firebase_auth/firebase_auth.dart';` | Service call |
| edit_profile_screen.dart | 134 | `final uid = FirebaseAuth.instance.currentUser!.uid;` | Service call |
| fitness_dashboard_screen.dart | 6 | `import 'package:firebase_auth/firebase_auth.dart';` | Service call |
| fitness_dashboard_screen.dart | 41 | `final uid = FirebaseAuth.instance.currentUser?.uid;` | Service call |
| diet_plan_screen.dart | 3 | `import 'package:firebase_auth/firebase_auth.dart';` | Service call |
| diet_plan_screen.dart | 40 | `String get _authUid => FirebaseAuth.instance.currentUser!.uid;` | Service call |
| main.dart | 3 | `import 'package:firebase_auth/firebase_auth.dart';` | Service call |
| main.dart | 70 | `///   FirebaseAuth.instance.currentUser synchronously — if a cached user exists` | Service call |
| main.dart | 140 | `await FirebaseAuth.instance.signOut();` | Service call |
| main.dart | 191 | `await FirebaseAuth.instance.signOut();` | Service call |
| main.dart | 246 | `await FirebaseAuth.instance.signOut();` | Service call |
| main.dart | 264 | `stream: FirebaseAuth.instance.authStateChanges(),` | Service call |
| main.dart | 277 | `final cachedUser = FirebaseAuth.instance.currentUser;` | Service call |
| add_member_screen.dart | 3 | `import 'package:firebase_auth/firebase_auth.dart';` | Service call |
| receptionist_dashboard_web.dart | 2 | `import 'package:firebase_auth/firebase_auth.dart';` | Service call |
| receptionist_dashboard_web.dart | 41 | `final user = FirebaseAuth.instance.currentUser;` | Service call |
| receptionist_dashboard_web.dart | 117 | `await FirebaseAuth.instance.signOut();` | Service call |
| receptionist_dashboard.dart | 2 | `import 'package:firebase_auth/firebase_auth.dart';` | Service call |
| receptionist_dashboard.dart | 43 | `final user = FirebaseAuth.instance.currentUser;` | Service call |
| receptionist_dashboard.dart | 111 | `await FirebaseAuth.instance.signOut();` | Service call |
| add_expense_screen.dart | 3 | `import 'package:firebase_auth/firebase_auth.dart';` | Service call |
| add_expense_screen.dart | 92 | `final user = FirebaseAuth.instance.currentUser;` | Service call |
| send_push_notification_screen.dart | 5 | `import 'package:firebase_auth/firebase_auth.dart';` | Service call |
| send_push_notification_screen.dart | 72 | `final user = FirebaseAuth.instance.currentUser;` | Service call |
| create_announcement_screen.dart | 5 | `import 'package:firebase_auth/firebase_auth.dart';` | Service call |
| create_announcement_screen.dart | 74 | `final user = FirebaseAuth.instance.currentUser;` | Service call |
| trainer_scan_screen.dart | 5 | `import 'package:firebase_auth/firebase_auth.dart';` | Service call |
| trainer_scan_screen.dart | 123 | `final trainerUid = FirebaseAuth.instance.currentUser?.uid;` | Service call |

---

## 7. ORPHANED FUNCTIONS (Defined but never called anywhere)

| Service | Method | Defined In | Last Known Purpose |
|---------|--------|------------|-------------------|
| PersonalBestService | watchRecords | personal_best_service.dart | Unknown |
| PersonalBestService | getRecord | personal_best_service.dart | Unknown |
| PersonalBestService | logEntry | personal_best_service.dart | Unknown |
| ChallengeService | getEntriesStream | challenge_service.dart | Unknown |
| ChallengeService | joinTeam | challenge_service.dart | Unknown |
| ChallengeService | logProgress | challenge_service.dart | Unknown |
| AnnouncementService | getAnnouncements | announcement_service.dart | Unknown |
| AnnouncementService | getAllAnnouncements | announcement_service.dart | Unknown |
| NotificationService | firebaseMessagingBackgroundHandler | notification_service.dart | Unknown |
| NotificationService | saveFCMToken | notification_service.dart | Unknown |
| NotificationService | unsubscribeFromTopics | notification_service.dart | Unknown |
| NotificationService | clearAllNotifications | notification_service.dart | Unknown |
| TrainerFeedbackService | streamFeedback | trainer_feedback_service.dart | Unknown |
| TrainerFeedbackService | getFeedback | trainer_feedback_service.dart | Unknown |
| StorageService | uploadProfileImage | storage_service.dart | Unknown |
| StorageService | deleteProfileImage | storage_service.dart | Unknown |
| HealthProfileService | watchHealthProfile | health_profile_service.dart | Unknown |
| InAppNotificationService | addNotificationsForMemberBatch | in_app_notification_service.dart | Unknown |
| InAppNotificationService | addNotificationForMember | in_app_notification_service.dart | Unknown |
| InAppNotificationService | addNotification | in_app_notification_service.dart | Unknown |
| WorkoutService | checkAndUpdatePersonalBests | workout_service.dart | Unknown |
| WorkoutService | getWeeklyWorkoutCount | workout_service.dart | Unknown |
| BadgeService | checkAndAward | badge_service.dart | Unknown |
| GamificationService | calculateStreak | gamification_service.dart | Unknown |
| GamificationService | checkBadge | gamification_service.dart | Unknown |
| WearableSnapshotService | getLatestSnapshots | wearable_snapshot_service.dart | Unknown |
| MemberService | getMemberByPhone | member_service.dart | Unknown |
| MemberService | isMembershipActive | member_service.dart | Unknown |
| MemberService | getMemberStream | member_service.dart | Unknown |
| HealthService | initialize | health_service.dart | Unknown |
| HealthService | isAvailable | health_service.dart | Unknown |
| HealthService | isConnected | health_service.dart | Unknown |
| HealthService | getLastNightSleep | health_service.dart | Unknown |
| HealthService | reset | health_service.dart | Unknown |
| AttendanceService | streamHistory | attendance_service.dart | Unknown |
| FirestoreService | updateProfileImageUrl | firestore_service.dart | Unknown |
| FirestoreService | getMemberById | firestore_service.dart | Unknown |
| FirestoreService | getMemberByPhone | firestore_service.dart | Unknown |
| FirestoreService | getMemberStream | firestore_service.dart | Unknown |
| FirestoreService | getAttendanceByMember | firestore_service.dart | Unknown |
| FirestoreService | getAttendanceForDateRange | firestore_service.dart | Unknown |
| FirestoreService | hasCheckedInToday | firestore_service.dart | Unknown |
| FirestoreService | getMonthlyAttendanceCount | firestore_service.dart | Unknown |
| FirestoreService | getAnnouncements | firestore_service.dart | Unknown |
| FirestoreService | getAllAnnouncements | firestore_service.dart | Unknown |
| FirestoreService | markAnnouncementAsRead | firestore_service.dart | Unknown |
| FirestoreService | getPaymentsByMember | firestore_service.dart | Unknown |
| FirestoreService | getPaymentById | firestore_service.dart | Unknown |
| FirestoreService | saveFitnessData | firestore_service.dart | Unknown |
| FirestoreService | isMembershipActive | firestore_service.dart | Unknown |
| FirestoreService | getDaysUntilExpiry | firestore_service.dart | Unknown |
| FirestoreService | toMap | firestore_service.dart | Unknown |
| AiCoachService | syncWearablesAndGenerate | ai_coach_service.dart | Unknown |
| WeeklyWarService | completeWar | weekly_war_service.dart | Unknown |
| PaymentService | getTotalPaid | payment_service.dart | Unknown |
| EmailService | sendInvoiceEmail | email_service.dart | Unknown |
| SessionService | writeExercises | session_service.dart | Unknown |
| SessionService | markSetComplete | session_service.dart | Unknown |
| SessionService | writeStretching | session_service.dart | Unknown |
| SessionService | getActiveSessionForMember | session_service.dart | Unknown |
| SessionService | getSessionsForTrainer | session_service.dart | Unknown |
| AnnouncementService | getAll | announcement_service.dart | Unknown |
| AnnouncementService | getActive | announcement_service.dart | Unknown |
| AnnouncementService | getAnnouncementsStream | announcement_service.dart | Unknown |
| AnnouncementService | create | announcement_service.dart | Unknown |
| AnnouncementService | update | announcement_service.dart | Unknown |
| AnnouncementService | deactivate | announcement_service.dart | Unknown |
| AnnouncementService | activate | announcement_service.dart | Unknown |
| AnnouncementService | delete | announcement_service.dart | Unknown |
| AnnouncementService | markAsRead | announcement_service.dart | Unknown |
| AnnouncementService | markAllAsRead | announcement_service.dart | Unknown |
| AnnouncementService | getTotalMemberCount | announcement_service.dart | Unknown |
| NotificationService | sendBatch | notification_service.dart | Unknown |
| NotificationService | runDailyReminders | notification_service.dart | Unknown |
| TrainerFeedbackService | addFeedback | trainer_feedback_service.dart | Unknown |
| TrainerFeedbackService | deleteFeedback | trainer_feedback_service.dart | Unknown |
| StorageService | uploadMemberPhoto | storage_service.dart | Unknown |
| StorageService | uploadTrainerPhoto | storage_service.dart | Unknown |
| StorageService | deletePhotoByUrl | storage_service.dart | Unknown |
| StorageService | getMemberPhotoUrl | storage_service.dart | Unknown |
| StorageService | getTrainerPhotoUrl | storage_service.dart | Unknown |
| StorageService | getPhotoMetadata | storage_service.dart | Unknown |
| StorageService | generateThumbnailUrl | storage_service.dart | Unknown |
| StorageService | photoExists | storage_service.dart | Unknown |
| DocumentService | isConnected | document_service.dart | Unknown |
| DocumentService | sendDocument | document_service.dart | Unknown |
| DocumentService | retryFailedOperation | document_service.dart | Unknown |
| AuthService | signInWithEmailPassword | auth_service.dart | Unknown |
| AuthService | createUserWithEmailPassword | auth_service.dart | Unknown |
| AuthService | resetPassword | auth_service.dart | Unknown |
| WhatsAppService | sendMessage | whatsapp_service.dart | Unknown |
| WhatsAppService | isWhatsAppInstalled | whatsapp_service.dart | Unknown |
| FirestoreService | addDocumentHistory | firestore_service.dart | Unknown |
| FirestoreService | addDocumentHistoryBatch | firestore_service.dart | Unknown |
| FirestoreService | getDocumentHistory | firestore_service.dart | Unknown |
| FirestoreService | clearDocumentHistory | firestore_service.dart | Unknown |
| FirestoreService | getMembersWithoutWelcomePackage | firestore_service.dart | Unknown |
| FirestoreService | getMembersWithRecentDocuments | firestore_service.dart | Unknown |
| FirestoreService | getMemberByQrCode | firestore_service.dart | Unknown |
| FirestoreService | getTrainerByUserId | firestore_service.dart | Unknown |
| FirestoreService | updateTrainerProfile | firestore_service.dart | Unknown |
| FirestoreService | addAttendance | firestore_service.dart | Unknown |
| FirestoreService | getRecentCheckIns | firestore_service.dart | Unknown |
| FirestoreService | getMembersWithDuesCount | firestore_service.dart | Unknown |
| FirestoreService | updateExpense | firestore_service.dart | Unknown |
| FirestoreService | deleteExpense | firestore_service.dart | Unknown |
| FirestoreService | getExpenses | firestore_service.dart | Unknown |
| FirestoreService | getTotalExpenses | firestore_service.dart | Unknown |
| FirestoreService | getAssignedMembers | firestore_service.dart | Unknown |
| FirestoreService | saveDietPlan | firestore_service.dart | Unknown |
| FirestoreService | getDietPlans | firestore_service.dart | Unknown |

---

## 8. MISSING CALLS (Screens that should call a function but don't)

| Screen | Missing Call | Why It Matters |
|--------|-------------|----------------|
| N/A | Heuristics not fully implemented | Static analysis limits |
| benchmark_test.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| xp_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| leaderboard_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| health_profile_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| renewal_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| trainer_feedback_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| trainer_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| payment_history_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| fitness_dashboard_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| personal_bests_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| body_metrics_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| stats_overview_widget.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| workout_history_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| workout_logger_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| member_attendance_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| war_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| ai_coach_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |
| qr_checkin_screen.dart | FirebaseAuthService.getCurrentMemberId | Hardcoded or passed memberId might be risky |

---

## 9. memberId vs auth.uid CONFUSION MAP

| File | Line | Uses | Should Use | Risk |
|------|------|------|------------|------|
| ✅ No clear uid confusion found. | | | | |

---

## 10. SECURE STORAGE KEY USAGE MAP

| File | Operation | Key | Should Only Be In |
|------|-----------|-----|------------------|
| settings_screen.dart | read | pref_expiry | ⚠️ should be in service |
| settings_screen.dart | read | pref_push | ⚠️ should be in service |
| settings_screen.dart | read | pref_haptic | ⚠️ should be in service |
| settings_screen.dart | read | pref_announcements | ⚠️ should be in service |
| settings_screen.dart | read | pref_promo | ⚠️ should be in service |
| settings_screen.dart | read | pref_checkin | ⚠️ should be in service |

---

## 11. FIRESTORE COLLECTION ACCESS MAP

| Collection | File | Operation | Via Service? |
|------------|------|-----------|--------------|
| aiPlans | ai_coach_service.dart | read | Yes |
| aiPlans | ai_coach_service.dart | write | Yes |
| aiPlans | rpe_service.dart | read | Yes |
| aiPlans | rpe_service.dart | write | Yes |
| aiPlans | trainer_scan_screen.dart | raw access | No |
| aiPlans | trainer_ajax_service.dart | read | Yes |
| announcements | announcement_service.dart | read | Yes |
| announcements | announcement_service.dart | write | Yes |
| announcements | firestore_service.dart | read | Yes |
| announcements | firestore_service.dart | write | Yes |
| announcements | create_announcement_screen.dart | raw access | No |
| announcements | announcement_service.dart | read | Yes |
| attendance | attendance_service.dart | read | Yes |
| attendance | attendance_service.dart | write | Yes |
| attendance | firestore_service.dart | read | Yes |
| attendance | firestore_service.dart | write | Yes |
| attendance | gamification_service.dart | read | Yes |
| attendance | firestore_service.dart | read | Yes |
| attendance | firestore_service.dart | write | Yes |
| attendance | team_battle_service.dart | read | Yes |
| bodyMetricsLogs | health_profile_service.dart | read | Yes |
| bodyMetricsLogs | health_profile_service.dart | write | Yes |
| bodyMetricsLogs | trainer_scan_screen.dart | raw access | No |
| challengeEntries | challenge_service.dart | read | Yes |
| challengeEntries | challenge_service.dart | write | Yes |
| challengeEntries | admin_gamification_service.dart | read | Yes |
| challenges | challenge_service.dart | read | Yes |
| challenges | challenge_service.dart | write | Yes |
| challenges | admin_gamification_service.dart | read | Yes |
| current | ai_coach_service.dart | read | Yes |
| current | trainer_ajax_service.dart | read | Yes |
| daily | health_service.dart | read | Yes |
| daily | wearable_snapshot_service.dart | read | Yes |
| daily | trainer_ajax_service.dart | read | Yes |
| dietPlans | ai_coach_service.dart | read | Yes |
| dietPlans | ai_coach_service.dart | write | Yes |
| dietPlans | trainer_service.dart | read | Yes |
| dietPlans | trainer_service.dart | write | Yes |
| dietPlans | firestore_service.dart | read | Yes |
| dietPlans | firestore_service.dart | write | Yes |
| entries | rpe_service.dart | read | Yes |
| entries | weekly_war_service.dart | read | Yes |
| exercises | personal_best_service.dart | read | Yes |
| expenses | firestore_service.dart | read | Yes |
| expenses | firestore_service.dart | write | Yes |
| fcmTokens | notification_service.dart | write | Yes |
| feedback | trainer_feedback_service.dart | read | Yes |
| fitnessData | firestore_service.dart | read | Yes |
| fitnessData | firestore_service.dart | write | Yes |
| fitnessData | health_service.dart | write | Yes |
| fitnessTests | ai_coach_service.dart | read | Yes |
| fitnessTests | ai_coach_service.dart | write | Yes |
| fitnessTests | health_profile_service.dart | read | Yes |
| fitnessTests | health_profile_service.dart | write | Yes |
| gamification | badge_service.dart | read | Yes |
| gamification | badge_service.dart | write | Yes |
| gamification | gamification_service.dart | read | Yes |
| gamification | gamification_service.dart | write | Yes |
| gamification | personal_best_service.dart | read | Yes |
| gamification | weekly_war_service.dart | write | Yes |
| gamification | admin_gamification_service.dart | read | Yes |
| gamification | admin_gamification_service.dart | write | Yes |
| gamification | member_fitness_service.dart | read | Yes |
| gamification | member_fitness_service.dart | write | Yes |
| gamificationEvents | trainer_ajax_service.dart | write | Yes |
| gamification_events | workout_history_screen.dart | raw access | No |
| gamification_events | gamification_service.dart | read | Yes |
| gamification_events | gamification_service.dart | write | Yes |
| gamification_events | workout_service.dart | write | Yes |
| gamification_events | collect_dues_screen.dart | raw access | No |
| gamification_events | rejoin_member_screen.dart | raw access | No |
| gymEquipment | trainer_scan_screen.dart | raw access | No |
| healthProfiles | health_profile_service.dart | read | Yes |
| healthProfiles | health_profile_service.dart | write | Yes |
| healthProfiles | trainer_scan_screen.dart | raw access | No |
| healthProfiles | trainer_ajax_service.dart | read | Yes |
| items | in_app_notification_service.dart | read | Yes |
| items | trainer_ajax_service.dart | read | Yes |
| logs | health_profile_service.dart | read | Yes |
| memberAlerts | membership_alert_service.dart | write | Yes |
| memberGoals | home_screen.dart | raw access | No |
| memberGoals | member_detail_screen.dart | raw access | No |
| memberGoals | trainer_dashboard_screen.dart | raw access | No |
| memberGoals | trainer_scan_screen.dart | raw access | No |
| memberIntelligence | trainer_scan_screen.dart | raw access | No |
| members | edit_profile_screen.dart | raw access | No |
| members | profile_screen.dart | raw access | No |
| members | firebase_auth_service.dart | read | Yes |
| members | firebase_auth_service.dart | write | Yes |
| members | firestore_service.dart | read | Yes |
| members | firestore_service.dart | write | Yes |
| members | gamification_service.dart | read | Yes |
| members | gamification_service.dart | write | Yes |
| members | member_service.dart | read | Yes |
| members | member_service.dart | write | Yes |
| members | notification_service.dart | read | Yes |
| members | renewal_service.dart | write | Yes |
| members | trainer_readiness_screen.dart | raw access | No |
| members | trainer_scan_screen.dart | raw access | No |
| members | admin_gamification_service.dart | read | Yes |
| members | admin_gamification_service.dart | write | Yes |
| members | announcement_service.dart | read | Yes |
| members | firestore_service.dart | read | Yes |
| members | firestore_service.dart | write | Yes |
| members | reminder_service.dart | read | Yes |
| members | trainer_ajax_service.dart | read | Yes |
| notifications | in_app_notification_service.dart | write | Yes |
| notifications | trainer_ajax_service.dart | write | Yes |
| payments | firestore_service.dart | read | Yes |
| payments | firestore_service.dart | write | Yes |
| payments | payment_service.dart | read | Yes |
| payments | payment_service.dart | write | Yes |
| payments | renewal_service.dart | read | Yes |
| payments | renewal_service.dart | write | Yes |
| payments | firestore_service.dart | read | Yes |
| payments | firestore_service.dart | write | Yes |
| personal_bests | personal_best_service.dart | write | Yes |
| personalbests | workout_service.dart | write | Yes |
| personalbests | trainer_ajax_service.dart | read | Yes |
| personalbests | trainer_ajax_service.dart | write | Yes |
| reminder_logs | reminder_service.dart | read | Yes |
| reminder_logs | reminder_service.dart | write | Yes |
| rpeLog | rpe_service.dart | read | Yes |
| rpeLog | rpe_service.dart | write | Yes |
| sessions | trainer_readiness_screen.dart | raw access | No |
| sessions | trainer_session_screen.dart | raw access | No |
| sessions | trainer_stretching_screen.dart | raw access | No |
| sessions | member_fitness_service.dart | read | Yes |
| sessions | session_service.dart | read | Yes |
| sessions | session_service.dart | write | Yes |
| sessions | trainer_ajax_service.dart | read | Yes |
| sessions | trainer_ajax_service.dart | write | Yes |
| tests | ai_coach_service.dart | read | Yes |
| tests | health_profile_service.dart | read | Yes |
| trainerFeedback | firestore_service.dart | read | Yes |
| trainerFeedback | firestore_service.dart | write | Yes |
| trainerFeedback | trainer_feedback_service.dart | read | Yes |
| trainerTeamBattles | team_battle_service.dart | read | Yes |
| trainerTeamBattles | team_battle_service.dart | write | Yes |
| trainers | trainer_feedback_service.dart | write | Yes |
| trainers | trainer_service.dart | read | Yes |
| trainers | trainer_service.dart | write | Yes |
| trainers | auth_service.dart | read | Yes |
| trainers | firestore_service.dart | read | Yes |
| trainers | firestore_service.dart | write | Yes |
| trainingSessions | trainer_scan_screen.dart | raw access | No |
| users | trainer_scan_screen.dart | raw access | No |
| users | auth_service.dart | read | Yes |
| users | auth_service.dart | write | Yes |
| users | firestore_service.dart | read | Yes |
| users | firestore_service.dart | write | Yes |
| wearableSnapshots | wearable_snapshot_service.dart | read | Yes |
| wearableSnapshots | wearable_snapshot_service.dart | write | Yes |
| wearableSnapshots | trainer_scan_screen.dart | raw access | No |
| wearableSnapshots | trainer_ajax_service.dart | write | Yes |
| weekly_wars | weekly_war_service.dart | read | Yes |
| weekly_wars | weekly_war_service.dart | write | Yes |
| workouts | workout_service.dart | read | Yes |
| workouts | workout_service.dart | write | Yes |
| workouts | member_fitness_service.dart | read | Yes |
| workouts | member_fitness_service.dart | write | Yes |
| workouts | team_battle_service.dart | read | Yes |
| workouts | trainer_ajax_service.dart | read | Yes |
| workouts | trainer_ajax_service.dart | write | Yes |

---

## 12. SUMMARY — Issues by Severity

### 🔴 CRITICAL (will cause bugs or crashes)
- Raw Firestore access found in screens

### 🟡 WARNING (anti-pattern, tech debt)
- Raw Auth access found outside services
- Direct collection access bypassing services

### 🟢 INFO (orphaned code, cleanup candidates)
- 111 potentially orphaned functions identified

---

## 13. flutter analyze Output

Member App:
```
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 93.0.0 (98.0.0 available)
  analyzer 10.0.1 (12.0.0 available)
  async 2.13.0 (2.13.1 available)
  dart_style 3.1.7 (3.1.8 available)
  device_info_plus 12.3.0 (12.4.0 available)
  flutter_local_notifications 20.1.0 (21.0.0 available)
  flutter_local_notifications_linux 7.0.0 (8.0.0 available)
  flutter_local_notifications_platform_interface 10.0.0 (11.0.0 available)
  flutter_local_notifications_windows 2.0.1 (3.0.0 available)
  flutter_plugin_android_lifecycle 2.0.33 (2.0.34 available)
  image_picker_android 0.8.13+14 (0.8.13+16 available)
  matcher 0.12.18 (0.12.19 available)
  meta 1.17.0 (1.18.2 available)
  path_provider_android 2.2.22 (2.2.23 available)
  razorpay_flutter 1.4.1 (1.4.3 available)
  rx 0.4.0 (0.5.0 available)
  shared_preferences 2.5.4 (2.5.5 available)
  shared_preferences_android 2.4.21 (2.4.23 available)
  shared_preferences_platform_interface 2.4.1 (2.4.2 available)
  test_api 0.7.9 (0.7.11 available)
  timezone 0.10.1 (0.11.0 available)
  url_launcher_android 6.3.28 (6.3.29 available)
  vector_math 2.2.0 (2.3.0 available)
  win32 5.15.0 (6.0.0 available)
  win32_registry 2.1.0 (3.0.2 available)
Got dependencies!
25 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing spring_health_member_app...
No issues found! (ran in 3.3s)

```

Admin App:
```
Resolving dependencies...
Downloading packages...
  _flutterfire_internals 1.3.57 (1.3.68 available)
  archive 4.0.7 (4.0.9 available)
  async 2.13.0 (2.13.1 available)
  cloud_firestore 5.6.10 (6.2.0 available)
  cloud_firestore_platform_interface 6.6.10 (7.1.0 available)
  cloud_firestore_web 4.4.10 (5.2.0 available)
  connectivity_plus 6.1.5 (7.1.0 available)
  connectivity_plus_platform_interface 2.0.1 (2.1.0 available)
  cross_file 0.3.5 (0.3.5+2 available)
  csv 7.1.0 (8.0.0 available)
  dbus 0.7.11 (0.7.12 available)
  device_info_plus 11.5.0 (12.4.0 available)
  ffi 2.1.4 (2.2.0 available)
  firebase_ai 2.2.0 (3.10.0 available)
  firebase_app_check 0.3.2+8 (0.4.2 available)
  firebase_app_check_platform_interface 0.1.1+8 (0.2.2 available)
  firebase_app_check_web 0.2.0+12 (0.2.3 available)
  firebase_auth 5.6.1 (6.3.0 available)
  firebase_auth_platform_interface 7.7.1 (8.1.8 available)
  firebase_auth_web 5.15.1 (6.1.4 available)
  firebase_core 3.15.0 (4.6.0 available)
  fire
...[truncated]...
11.3 (3.12.0 available)
  petitparser 7.0.1 (7.0.2 available)
  posix 6.0.3 (6.5.0 available)
  printing 5.14.2 (5.14.3 available)
  share_plus 10.1.4 (12.0.2 available)
  share_plus_platform_interface 5.0.2 (6.1.0 available)
  source_span 1.10.1 (1.10.2 available)
  test_api 0.7.9 (0.7.11 available)
  url_launcher_android 6.3.28 (6.3.29 available)
  url_launcher_ios 6.3.6 (6.4.1 available)
  url_launcher_linux 3.2.1 (3.2.2 available)
  url_launcher_web 2.4.1 (2.4.2 available)
  url_launcher_windows 3.1.4 (3.1.5 available)
  uuid 4.5.2 (4.5.3 available)
  vector_math 2.2.0 (2.3.0 available)
  vibration 2.1.0 (3.1.8 available)
  vibration_platform_interface 0.0.3 (0.1.1 available)
  win32 5.15.0 (6.0.0 available)
  win32_registry 2.1.0 (3.0.2 available)
Got dependencies!
58 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing spring_health_studio...
No issues found! (ran in 5.1s)

```
=======
# Spring Health Ecosystem Audit

## 1. Executive Summary
- **What this ecosystem is**: A unified digital ecosystem for Spring Health Studio fitness centers with two Flutter apps sharing a centralized Firebase backend
- **Which apps exist**: 
  - `spring_health_studio`: Administrative suite for Owners and Receptionists
  - `spring_health_member_app`: Client-facing retention, fitness tracking, and community app
- **Current maturity level**: Mature with extensive feature implementation, but with some inconsistencies between apps and potential runtime issues
- **Biggest technical risks**: 
  - Role-based access inconsistencies between Firestore rules and code
  - Missing null safety in some model conversions
  - Potential blank screens due to permission-denied errors from role mismatches
  - Inconsistent field naming (memberId vs userid vs uid)

## 2. Repo Structure
```
spring_health/
├── spring_health_studio/          # Admin/studio app
├── spring_health_member_app/      # Member-facing app
├── firestore.rules                # Shared Firebase security rules
├── firestore.indexes.json         # Shared Firestore indexes
├── firebase.json                  # Firebase configuration
├── AGENTS.md                      # AI agent directives
└── current_state.md               # Project status documentation
```

**Purpose of each major app/folder**:
- `spring_health_studio`: Multi-branch gym management system with role-based access (Owner, Receptionist, Trainer)
- `spring_health_member_app`: Member-facing app for fitness tracking, AI coaching, payments, and community features

## 3. Product Overview

### 3.1 Studio App
- **Purpose**: Administrative suite for gym management
- **Key Users**: Owners, Receptionists, Trainers
- **Core Functions**: Member management, attendance tracking, payments, reports, announcements, trainer management
- **Tech Stack**: Flutter with Firebase backend, PDF generation, Razorpay payments (inferred from member app)

### 3.2 Member App
- **Purpose**: Client-facing retention, fitness tracking, and community app
- **Key Users**: Gym Members
- **Core Functions**: Workout tracking, AI coach, diet plans, payments, announcements, gamification, social features
- **Tech Stack**: Flutter with Firebase backend, Health kit integration, Razorpay payments, Neon dark theme

### 3.3 Shared Firebase Backend
- **Database**: Firestore with normalized collections
- **Authentication**: Firebase Auth with custom role claims
- **Storage**: Firebase Storage for profile images, documents
- **Messaging**: Firebase Cloud Messaging for notifications
- **AI**: Firebase AI integration for workout/diet plan generation

## 4. Role Model

| Role | Studio App Access | Member App Access | Verification |
|------|-------------------|-------------------|--------------|
| Owner | Full access to all admin features | Read-only profile/view | ✅ Confirmed in Firestore rules |
| Receptionist | Member management, attendance, basic reports | Read-only profile/view | ✅ Confirmed in Firestore rules |
| Trainer | Session management, workout creation, member fitness tracking | View own profile, limited admin features | ✅ Confirmed in Firestore rules |
| Member | No access | Full member app features | ✅ Confirmed in Firestore rules |

**Mismatches between code and rules**: None detected in basic role definitions, but Firestore rules show some inconsistencies in field usage (e.g., memberId vs userid vs uid).

## 5. App Architecture

### 5.1 Studio app entry, navigation, dashboards
- **Entry Point**: `lib/main.dart` with AuthWrapper handling Firebase session persistence
- **Authentication Flow**: 
  - Checks Firebase auth state changes
  - Uses cached UID to prevent false logouts on restart
  - Fetches user role from Firestore with caching
- **Navigation**: Named routes defined in main.dart:
  - `/`: AuthWrapper (redirects based on role)
  - `/login`: LoginScreen
  - `/owner-dashboard`: OwnerDashboard
  - `/receptionist-dashboard`: ReceptionistDashboard
  - `/add-member`: AddMemberScreen
- **Dashboards**:
  - Owner Dashboard: Full system access
  - Receptionist Dashboard: Member and attendance management
  - Trainer Dashboard: Session and workout management

### 5.2 Member app entry, navigation, main tabs
- **Entry Point**: `lib/main.dart` with splash screen initialization
- **Authentication Flow**: 
  - Firebase initialization
  - Notification service setup
  - System UI overlay styling for neon dark theme
- **Navigation**: Bottom navigation bar with tabs (inferred from screen structure):
  - Home
  - Fitness
  - Diet
  - Trainers
  - Social
  - Clash
  - Gamification
  - Profile
  - Settings

### 5.3 Theme systems
- **Studio App**: 
  - "Wellness & Balance" Material Design
  - Primary: Sage Green (`AppColors.primary`)
  - Dark Accent: Teal (`AppColors.primaryDark`)
  - Uses `PdfGoogleFonts` for Unicode-compliant font rendering in PDFs
- **Member App**: 
  - "Neon Dark" Cyber-Aesthetic with glassmorphism
  - Background: Deep obsidian (`#09090B`)
  - Accents: Neon Lime (`#D0FD3E`), Neon Teal (`#2DD4BF`), Neon Orange (`#FF6B35`)

### 5.4 State management approach actually used
- **Studio App**: 
  - Uses `FutureBuilder` and `StreamBuilder` for async data
  - Role caching in `AuthWrapper` to prevent refetching
  - No evidence of external state management libraries (Provider, Riverpod, Bloc)
  - Heavy reliance on direct Firestore service calls
- **Member App**:
  - Similar approach with `FutureBuilder`/`StreamBuilder`
  - Uses `ValueNotifier` and `ValueListenableBuilder` for high-frequency updates (per AGENTS.md directive)
  - Notification service with singleton pattern

## 6. Feature Inventory

| Area | Studio | Member | Status | Key files |
|------|--------|--------|--------|-----------|
| **Auth** | ✅ Email/password login | ✅ Email/password login | Complete | studio: `lib/screens/auth/login_screen.dart`, member: `lib/screens/auth/` |
| **Members** | ✅ CRUD operations | ❌ View only | Partial | studio: `lib/screens/members/*`, member: N/A |
| **Payments** | ✅ Expense tracking | ✅ Razorpay integration | Partial | studio: `lib/screens/expenses/*`, member: `lib/screens/payments/*`, `lib/models/payment_model.dart` |
| **Attendance** | ✅ QR scanner & history | ✅ Check-in/check-out | Complete | studio: `lib/screens/attendance/*`, member: `lib/screens/attendance/*` |
| **Reports** | ✅ Analytics dashboard | ❌ Limited | Partial | studio: `lib/screens/analytics/analytics_dashboard.dart` |
| **Announcements** | ✅ CRUD | ✅ Read with readBy tracking | Complete | studio: `lib/screens/announcements/*`, member: `lib/screens/announcements/*` |
| **Reminders** | ✅ Service layer | ❌ UI pending | Partial | studio: `services/reminder_service.dart` |
| **Trainers** | ✅ Profile management | ✅ Browse trainers | Complete | studio: `lib/screens/trainer/*`, member: `lib/screens/trainers/*` |
| **Workouts** | ❌ Basic tracking only | ✅ Full workout logging | Partial | member: `lib/screens/workout/*`, `lib/models/workout_model.dart` |
| **AI Coach** | ❌ Admin view only | ✅ Plan generation | Partial | studio: `lib/screens/members/member_ai_plan_screen.dart`, member: `lib/screens/ai_coach/*` |
| **Sessions** | ✅ Session service | ✅ Live session tracking | Complete | studio: `services/session_service.dart`, member: `lib/screens/clash/*` (live sessions) |
| **Stretching/Live Sessions** | ❌ Not found | ✅ Clash system | Partial | member: `lib/screens/clash/*` |
| **Gamification** | ✅ Admin service | ✅ Full system | Complete | studio: `services/admin_gamification_service.dart`, member: `lib/screens/gamification/*` |
| **PB System** | ❌ Not found | ✅ Personal Best tracking | Partial | member: `lib/screens/fitness/*`, `lib/models/personal_best_model.dart` |
| **Team Battles** | ✅ Service & model | ✅ UI components | Complete | studio: `services/team_battle_service.dart`, `lib/models/team_battle_model.dart`, member: `lib/screens/social/*` |
| **Clashes/Wars** | ❌ Not found | ✅ Weekly war system | Partial | member: `lib/screens/clash/*`, `lib/models/weekly_war_model.dart` |
| **Profile/Settings** | ❌ Limited | ✅ Full profile | Partial | member: `lib/screens/profile/*`, `lib/screens/settings/*` |
| **Notifications** | ✅ Service layer | ✅ FCM + local notifications | Complete | studio: `services/notification_service.dart`, member: `services/notification_service.dart` |
| **Diet Plans** | ❌ Admin view only | ✅ Full diet planning | Partial | studio: `lib/screens/members/*` (inferred), member: `lib/screens/diet/*`, `lib/models/diet_plan_model.dart` |

## 7. Firebase Architecture

### 7.1 Auth patterns
- Firebase Auth with email/password providers
- Role-based access control via Firestore `users` collection
- No custom auth claims detected - roles stored in Firestore document
- Session persistence handled in AuthWrapper with caching mechanism

### 7.2 Firestore collections
Confirmed collections from rules and indexes:

| Collection | Purpose | Document ID | Key Fields | Verification |
|------------|---------|-------------|------------|--------------|
| **users** | App user accounts | Auth UID | role, branch, name, email | ✅ Rules lines 49-52 |
| **members** | Gym member profiles | Firestore auto-ID | name, phone, branch, expiryDate, dueAmount, isArchived | ✅ Rules lines 57-62 |
| **attendance** | Check-in records | Firestore auto-ID | memberId, branch, checkInTime, checkOutTime | ✅ Rules lines 70-76 |
| **payments** | Financial transactions | Firestore auto-ID | memberId, amount, paymentDate, cashAmount, upiAmount, finalAmount | ✅ Rules lines 79-84 |
| **announcements** | Gym notifications | Firestore auto-ID | title, content, targetBranches, isGlobal, readBy (array), createdAt | ✅ Rules lines 87-93 |
| **trainers** | Trainer profiles | Firestore auto-ID | name, specialization, branch, isActive | ✅ Rules lines 96-101 |
| **sessions** | Workout sessions | Firestore auto-ID | memberId, trainerId, sessionType, startTime, endTime, exercises | ✅ Rules lines 214-218 |
| **gamification** | Member XP/stats | Firestore member doc ID | totalXp, currentStreak, workoutCount, level, rank | ✅ Rules lines 178-183 |
| **gamificationEvents** | XP award events | Firestore auto-ID | memberId, xpAmount, reason, timestamp, processed | ✅ Rules lines 150-162, 164-175 |
| **workouts** | Workout logs | Firestore auto-ID | memberId, date, exercises, duration, calories | ✅ Rules lines 199-203 |
| **personalbests** | Personal records | Firestore auto-ID | memberId, exercise, weight, reps, recordedAt | ✅ Rules lines 205-211 |
| **bodyMetrics** | Body measurements | Firestore auto-ID | memberId, weight, height, bodyFat, muscleMass, recordedAt | ✅ Rules lines 227-231 |
| **healthProfiles** | AI health data | Firestore member doc ID | fitnessLevel, goals, medicalConditions, preferences | ✅ Rules lines 295-298 |
| **aiPlans** | AI-generated plans | Firestore member doc ID | workoutPlan, dietPlan, trainerNote, createdAt | ✅ Rules lines 324-335 |
| **wearableSnapshots** | Health device data | Firestore member doc ID | daily/{date} subcollection with steps, heartRate, calories | ✅ Rules lines 316-322 |
| **trainerFeedback** | Trainer evaluations | Firestore auto-ID | trainerId, memberId, rating, comments, createdAt | ✅ Rules lines 104-112 |
| **challenges** | Fitness challenges | Firestore auto-ID | name, description, startDate, endDate, targetMetric | ✅ Rules lines 136-140 |
| **challengeEntries** | Challenge participants | Firestore auto-ID | memberId, challengeId, score, submittedAt | ✅ Rules lines 143-148 |
| **weeklyWars** | Weekly team battles | Firestore auto-ID | name, startDate, endDate, teamA, teamB, winner | ✅ Rules lines 186-196 |
| **trainingSessions** | Structured workout plans | Firestore auto-ID | trainerId, memberAuthUid, exercises, activeExerciseIndex, sessionRpe | ✅ Rules lines 349-364 |
| **memberIntelligence** | AI member insights | Firestore member auth UID | insights, recommendations, lastUpdated | ✅ Rules lines 366-370 |

### 7.3 Storage usage
- Profile images for members/trainers
- Document storage for PDFs (reports, plans)
- AI-generated content storage
- Verified via: `firebase_storage` dependency in both pubspecs and `storage_service.dart`

### 7.4 FCM / notifications
- FCM tokens stored in `/fcmTokens/{tokenId}` collection
- Notification history in `/notificationHistory/{historyId}`
- Real-time notifications via Firestore listeners
- Local notifications for reminders and alerts
- Verified via: `firebase_messaging` and `flutter_local_notifications` dependencies

### 7.5 Rules and indexes
- **Rules**: Complex role-based access with specific field requirements
- **Indexes**: 27 composite indexes covering common query patterns
- **Notable Rule Inconsistencies**:
  - Some rules use `memberId` field, others expect it to equal document ID
  - `gamification` collection uses memberId as doc ID but rules reference `branchId` field
  - Mixed use of `uid`, `memberId`, and `userid` fields for user identification

## 8. Model Layer

### Common Model Conventions
- **fromMap(map, id)**: Standard factory constructor for Firestore deserialization
- **copyWith()**: Immutable update pattern present in most models
- **timestamp patterns**: Use of `DateTime` fields with server timestamp handling
- **nullable patterns**: Mixed approach - some fields nullable, others required

### Important Models
- **Member Model** (`member_model.dart`): 
  - 5000+ line file with extensive member data
  - Contains embedded workout/fitness data
  - Uses `fromMap` and `copyWith` patterns
- **Workout Model** (`workout_model.dart` in member app):
  - Exercise arrays, sets/reps tracking
  - Duration and calorie calculations
- **AI Plan Model** (`ai_plan_model.dart`):
  - Workout and diet plan structures
  - Trainer note fields for customization
- **Session Model** (`session_model.dart`):
  - Exercise progression tracking
  - RPE (Rate of Perceived Exertion) scoring
- **Gamification Model** (`gamification_model.dart`):
  - XP, levels, streaks, achievements
  - Branch-based leaderboard support

### Model Issues Found
- Inconsistent field naming: `memberId` vs `userid` vs `uid` across models
- Some models lack proper null safety checks in `fromMap` methods
- Timestamp handling inconsistent - some use raw timestamps, others use server timestamps

## 9. Service Layer

### Studio App Services
- **FirestoreService** (`firestore_service.dart`): 42K line central service
  - Handles all Firestore operations
  - Singleton pattern via service instantiation
  - Mix of query and mutation methods
- **SessionService** (`session_service.dart`): Manages workout sessions
- **TrainerAjaxService** (`trainer_ajax_service.dart`): 14K line AI/trainer communication
- **NotificationService** (`notification_service.dart`): Handles FCM and local notifications
- **PDFService** (`pdf_service.dart`): 32K line document generation
- **EmailService** (`email_service.dart`): Handles email communications
- **WhatsAppService** (`whatsapp_service.dart`): 19K line WhatsApp integration
- **ReminderService** (`reminder_service.dart`): Manages scheduled reminders
- **TeamBattleService** (`team_battle_service.dart`): Handles team battle logic
- **AdminGamificationService** (`admin_gamification_service.dart`): XP and award management

### Member App Services
- **NotificationService** (`services/notification_service.dart`): FCM initialization and handling
- **Health Services**: Inferred from `health` dependency usage
- **Payment Services**: Razorpay integration inferred from `razorpay_flutter` dependency

### Service Patterns
- Most services instantiated as needed rather than singleton
- FirestoreService is the central data access layer
- Services that write to Firestore: FirestoreService, SessionService, TrainerAjaxService
- Display-only services: Limited - most services have both read/write capabilities

## 10. AI and Health Stack

### Wearable Snapshots
- **Model**: `wearable_snapshot_model.dart` (member app)
- **Structure**: Daily snapshots with steps, heart rate, calories burned
- **Storage**: `/wearableSnapshots/{memberId}/daily/{date}` subcollection
- **Permissions**: Read/write by signed-in users (rules lines 316-322)

### Health Profiles
- **Model**: `health_profile_model.dart` (member app)
- **Fields**: Fitness level, goals, medical conditions, preferences
- **Storage**: `/healthProfiles/{memberId}`
- **Usage**: AI plan generation input

### AI Plans
- **Model**: `ai_plan_model.dart` (both apps)
- **Structure**: Workout plan (exercises, sets, reps) + diet plan (meals, macros)
- **Storage**: `/aiPlans/{memberId}/current/{docId}`
- **Trainer Customization**: Trainers can update `trainerNote` and `trainerNoteUpdatedAt` (rules lines 327-334)
- **Generation**: Likely via Firebase AI extension (firebase_ai dependency)

### Safety Gates
- **Medical Hold Logic**: Not explicitly found in code review
- **Plan Validation**: No visible safety checks for exercise contraindications
- **Age/Gating**: Age-based restrictions not evident in model fields

### Trainer Ajax/AI Services
- **TrainerAjaxService**: 14K line service in studio app
  - Likely handles AI plan generation requests
  - Trainer-member communication
  - Plan approval/modification workflow
- **Firebase AI**: Explicit dependency in both pubspecs (`firebase_ai`)

### Session Generation Flow
- **Training Sessions Model**: `training_session_model.dart`
- **Flow**: Trainer creates structured workout → Member follows → Progress tracked
- **Storage**: `/trainingSessions/{sessionId}`
- **Updates**: Limited to exercise index and RPE during active session (rules lines 358-364)

## 11. Session Flow

### Confirmed Session Flow Elements
Based on code inspection of `training_session_model.dart` and session service:

1. **Readiness**: Not explicitly modeled - inferred from session start
2. **Warmup**: Part of exercise array in training session
3. **Active Session**: 
   - Tracks `activeExerciseIndex` 
   - Updates `sessionRpe` during workout
   - Allows exercise substitution/modification
4. **Stretching**: Included as exercise type in arrays
5. **Finalize**: Session completion sets end time and finalizes metrics
6. **Member Live Session**: 
   - Clash system in member app (`lib/screens/clash/*`)
   - Real-time workout participation
   - Post-session analytics
7. **Post-Session Flow**: 
   - Session data copied to `/sessions/{sessionId}` for historical tracking
   - Gamification events generated for XP awards
   - Fitness stats updated in member profile

### Session Architecture
- **Training Sessions**: Template/workout plans (`/trainingSessions`)
- **Actual Sessions**: Completed workouts (`/sessions`)
- **Separation**: Allows reusing templates while preserving historical data
- **Verification**: Rules lines 349-364 show training session permissions
- **Session Conversion**: Likely handled in `SessionService.copyTrainingSessionToSession()` (inferred)

### Missing Session Flow Elements
- No explicit warmup/cooldown tracking separate from main exercises
- No heart rate zone tracking during sessions
- No automated rest timer between sets
- No exercise substitution rules (e.g., injury accommodations)

## 12. Gamification Architecture

### Core Systems
- **XP System**: 
  - Stored in `gamification.totalXp`
  - Earned via `gamificationEvents`
  - Controls level progression
- **Levels/Ranks**: 
  - Calculated from XP thresholds
  - Visual ranks (SSS, SS, S, A, B, C, D, E) with specific colors
  - Defined in member app `AppColors` (rankSSS, rankSS, etc.)
- **Streaks**: 
  - `currentStreak` in gamification model
  - Based on workout frequency
  - Reset on missed days
- **Leaderboards**: 
  - Branch-based filtering
  - Sorted by totalXp descending
  - Indexed for performance (indexes lines 178-192)

### Event Bridge
- **GamificationEvents Collection**: 
  - Awards XP for various actions
  - `processed` flag prevents double-awarding
  - Indexed for efficient queries (indexes lines 202-208)
- **Event Types** (inferred from code):
  - Workout completion
  - Personal best achievement
  - Challenge participation
  - Streak milestones
  - Attendance consistency

### PB System
- **Model**: `personal_best_model.dart` (member app)
- **Storage**: `/personalbests/{docId}` with memberId field
- **Tracking**: Exercise-specific max weight/reps
- **Updating**: Compares new lift against existing record
- **Rules**: Lines 205-211 allow signed-in users to create/update/delete

### Challenge/Clash/War Systems
- **Challenges**: 
  - Time-bound fitness competitions
  - Individual or team-based
  - Points-based scoring
  - Model: `challenge_model.dart` (member app)
- **Clashes**: 
  - Live head-to-head competitions
  - Real-time scoring
  - Screen: `lib/screens/clash/*` (member app)
- **Weekly Wars**: 
  - Team-based weekly competitions
  - Model: `weekly_war_model.dart` (member app)
  - Rules: Lines 186-196 for weeklyWars collections
- **Team Battles**: 
  - Studio app feature
  - Model: `team_battle_model.dart` (studio app)
  - Service: `team_battle_service.dart` (studio app)
  - Likely longer-term team competitions

### Integration Points
- XP awards flow through `AdminGamificationService`
- Events trigger via Firestore triggers or service calls
- Leaderboards update based on gamification document changes
- PB achievements trigger special XP bonuses

## 13. Current Completion Snapshot

### Confirmed Complete
- Authentication system with role-based routing
- Member CRUD operations (studio app)
- Attendance tracking with QR scanner
- Payment processing infrastructure
- Announcement system with read receipts
- Basic trainer profile management
- Notification system (FCM + local)
- Exercise library management
- Expense tracking (studio app)
- Gym equipment inventory

### In Progress / Partial
- AI workout/diet plan generation (basic structure present)
- Live session/clash system (UI present, backend incomplete)
- Comprehensive reporting analytics
- Advanced diet planning (UI present, limited backend)
- Social features framework (schemas present, UI minimal)
- Member profile completion (basic fields present)
- Payment confirmation flows (basic Razorpay integration)
- Session template system (trainingSessions present)

### Missing / Stubbed
- Medical hold/safety validation systems
- Advanced AI personalization beyond basic plan generation
- Comprehensive social feed implementation
- Offline data synchronization
- Multi-language support (i18n present but incomplete)
- Advanced gym equipment maintenance tracking
- Comprehensive financial reporting (beyond basic expense tracking)
- Member referral system
- Integrated calendar/scheduling system
- Wearable device automatic sync (manual snapshot only)
- Advanced injury tracking and workout modification

## 14. Known Pitfalls

- **Auth Role Casing**: Firestore rules expect Title Case roles ('Owner', 'Receptionist', 'Trainer') but no enforcement seen in code
- **Member Lookup Rules**: Rules allow member creation/update by signed-in users but rely on phone lookup before UID linking - potential for orphaned member records
- **Rules Deployment Pitfalls**: Complex rules with field-specific permissions; incorrect field names cause silent failures
- **Index Deletion Pitfalls**: Composite indexes require exact field matching; missing indexes cause query failures
- **Session Collection Naming**: Both `/sessions` and `/trainingSessions` exist - potential confusion in service layer
- **Field Naming Inconsistencies**: 
  - `memberId` used in most collections
  - `userid` used in some (e.g., memberGoals collection)
  - `uid` used for auth-linked documents
  - Inconsistent usage causes query failures
- **Dead Code / Old Architecture**: 
  - `_web.dart` files suggest abandoned web responsiveness attempts
  - Duplicate screen files (e.g., owner/dashboard and owner/dashboard_web)
  - Test files in main directories (test_challenge_method.dart, test_firestore.dart)
- **Likely Runtime Crash Points**: 
  - Null reference errors when accessing nested map values in `fromMap` methods
  - Type casting errors when Firestore returns unexpected data types
  - Permission denied errors when role-based rules don't match Firestore data

## 15. Known Runtime Risks

- **Blank Screen Due to Permission-Denied**: 
  - If user role in Firestore doesn't match expected values, AuthWrapper shows error screen
  - Risk: Role string mismatches (e.g., 'owner' vs 'Owner') cause infinite login loops
- **Member Lookup Failures**: 
  - When memberId field doesn't match Firestore document ID
  - Risk: Attendance/payment queries return no results despite valid data
- **Rules Mismatch Between Auth Models**: 
  - Studio and member apps may have different role expectations
  - Risk: Users can login to one app but not the other
- **Old Collection Names Still Referenced**: 
  - Risk: References to deprecated collections cause missing data
- **Missing Screens Wired in Docs but Absent in Code**: 
  - Risk: Navigation to undefined routes causes app crashes
- **Timestamp Handling Issues**: 
  - Risk: Mix of timestamp types causes sorting/comparison failures
- **Null Safety Gaps**: 
  - Risk: Unexpected null values in Firestore documents cause crashes
- **Large Model Serialization**: 
  - Risk: 5000+ line member_model causes performance issues on low-end devices

## 16. Recommended Next Actions

### P0 (Critical - Fix Immediate Risks)
1. **Standardize Role Strings**: Create role constants and enforce consistent casing across Firestore, rules, and code
2. **Fix Field Naming Consistency**: Establish and enforce single source of truth for user identification (memberId vs userid vs uid)
3. **Add Null Safety Guards**: Implement proper null checks in all model `fromMap` methods
4. **Validate Index Coverage**: Test all major queries against firestore.indexes.json to prevent runtime failures

### P1 (High - Improve Stability)
1. **Implement Medical Hold System**: Add safety gates for AI plan generation based on health profiles
2. **Complete Social Features**: Implement springSocial and socialFeed collections with proper UI
3. **Enhance Session Tracking**: Add heart rate zones, rest timers, and exercise substitution rules
4. **Standardize Timestamp Usage**: Choose single timestamp approach (server timestamps) and migrate existing data

### P2 (Medium - Enhance Features)
1. **Improve Offline Support**: Add local Firestore persistence for intermittent connectivity
2. **Enhance AI Personalization**: Use wearable snapshots and health profiles for better plan generation
3. **Implement Referral System**: Add member referral tracking and rewards
4. **Add Advanced Reporting**: Create comprehensive analytics dashboard for studio owners
5. **Create Wearable Auto-Sync**: Implement background health data collection from device APIs

## 17. File Map Appendix

### Critical Onboarding Files

#### Studio App
- `lib/main.dart` - App entry and authentication flow
- `lib/services/firestore_service.dart` - Central data access layer (42K lines)
- `lib/services/session_service.dart` - Workout session management
- `lib/services/trainer_ajax_service.dart` - AI and trainer communication (14K lines)
- `lib/models/member_model.dart` - Core member data structure (5K lines)
- `lib/models/ai_plan_model.dart` - AI-generated plans
- `lib/screens/auth/login_screen.dart` - Authentication entry point
- `lib/screens/owner/owner_dashboard.dart` - Owner interface
- `lib/screens/receptionist/receptionist_dashboard.dart` - Receptionist interface
- `lib/screens/trainer/trainer_dashboard_screen.dart` - Trainer interface

#### Member App
- `lib/main.dart` - App entry and initialization
- `lib/services/notification_service.dart` - FCM and local notifications
- `lib/models/workout_model.dart` - Exercise tracking structure
- `lib/models/gamification_model.dart` - XP, levels, streaks system
- `lib/models/personal_best_model.dart` - Personal record tracking
- `lib/models/health_profile_model.dart` - AI plan inputs
- `lib/models/ai_plan_model.dart` - Generated workout/diet plans
- `lib/models/wearable_snapshot_model.dart` - Health device data
- `lib/screens/auth/` - Authentication screens
- `lib/screens/home/` - Main dashboard
- `lib/screens/workout/` - Exercise logging
- `lib/screens/diet/` - Nutrition planning
- `lib/screens/clash/` - Live session system
- `lib/screens/gamification/` - XP and rewards
- `lib/screens/profile/` - Member profile management
- `lib/screens/settings/` - App configuration

#### Shared Infrastructure
- `firestore.rules` - Security rules defining access controls
- `firestore.indexes.json` - Performance indexes for queries
- `firebase.json` - Firebase project configuration
- `AGENTS.md` - Development guidelines and constraints
- `current_state.md` - Project status documentation
>>>>>>> 87fd93f (fix: restore clean analytics_dashboard, remove orphan test file)
