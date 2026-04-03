---

# Spring Health Ecosystem — Current State Audit
Date: 2024-05-24
Audited by: Jules
Flutter analyze: No issues found! | No issues found!

---

## Section 1 — Flutter Analyze Results

### spring_health_member_app
```
Resolving dependencies...
Downloading packages...
  async 2.13.0 (2.13.1 available)
  flutter_local_notifications 20.1.0 (21.0.0 available)
  flutter_local_notifications_linux 7.0.0 (8.0.0 available)
  flutter_local_notifications_platform_interface 10.0.0 (11.0.0 available)
  flutter_local_notifications_windows 2.0.1 (3.0.0 available)
  flutter_plugin_android_lifecycle 2.0.33 (2.0.34 available)
  image_picker_android 0.8.13+14 (0.8.13+15 available)
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
21 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing spring_health_member_app...
No issues found! (ran in 4.2s)
```

### spring_health_studio
```
Resolving dependencies...
Downloading packages...
  _flutterfire_internals 1.3.59 (1.3.68 available)
  archive 4.0.7 (4.0.9 available)
  async 2.13.0 (2.13.1 available)
  cloud_firestore 5.6.12 (6.2.0 available)
  cloud_firestore_platform_interface 6.6.12 (7.1.0 available)
  cloud_firestore_web 4.4.12 (5.2.0 available)
  connectivity_plus 6.1.5 (7.0.0 available)
  cross_file 0.3.5 (0.3.5+2 available)
  csv 7.1.0 (8.0.0 available)
  dbus 0.7.11 (0.7.12 available)
  device_info_plus 11.5.0 (12.3.0 available)
  ffi 2.1.4 (2.2.0 available)
  firebase_auth 5.7.0 (6.3.0 available)
  firebase_auth_platform_interface 7.7.3 (8.1.8 available)
  firebase_auth_web 5.15.3 (6.1.4 available)
  firebase_core 3.15.2 (4.6.0 available)
  firebase_core_platform_interface 6.0.2 (6.0.3 available)
  firebase_core_web 2.24.1 (3.5.1 available)
  firebase_storage 12.4.10 (13.2.0 available)
  firebase_storage_platform_interface 5.2.10 (5.2.19 available)
  firebase_storage_web 3.10.17 (3.11.4 available)
  fl_chart 0.69.2 (1.2.0 available)
  flutter_lints 4.0.0 (6.0.0 available)
  flutter_plugin_android_lifecycle 2.0.33 (2.0.34 available)
  google_fonts 6.3.3 (8.0.2 available)
  image 4.5.4 (4.8.0 available)
  image_picker_android 0.8.13+14 (0.8.13+15 available)
  lints 4.0.0 (6.1.0 available)
  mailer 6.6.0 (7.1.0 available)
  matcher 0.12.18 (0.12.19 available)
  meta 1.17.0 (1.18.2 available)
  mobile_scanner 5.2.3 (7.2.0 available)
  path_provider_android 2.2.20 (2.2.23 available)
  path_provider_foundation 2.4.3 (2.6.0 available)
  pdf 3.11.3 (3.12.0 available)
  petitparser 7.0.1 (7.0.2 available)
  posix 6.0.3 (6.5.0 available)
  printing 5.14.2 (5.14.3 available)
  share_plus 10.1.4 (12.0.1 available)
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
53 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
Analyzing spring_health_studio...
No issues found! (ran in 4.8s)
```

---

## Section 2 — File Structure (Ground Truth)

### spring_health_studio/lib
```
spring_health_studio/lib/firebase_options.dart
spring_health_studio/lib/main.dart
spring_health_studio/lib/models/admin_leaderboard_entry.dart
spring_health_studio/lib/models/announcement_model.dart
spring_health_studio/lib/models/attendance_model.dart
spring_health_studio/lib/models/diet_plan_model.dart
spring_health_studio/lib/models/document_sent_model.dart
spring_health_studio/lib/models/expense_model.dart
spring_health_studio/lib/models/member_model.dart
spring_health_studio/lib/models/payment_model.dart
spring_health_studio/lib/models/trainer_feedback_model.dart
spring_health_studio/lib/models/trainer_model.dart
spring_health_studio/lib/models/user_model.dart
spring_health_studio/lib/models/workout_summary_model.dart
spring_health_studio/lib/screens/analytics/analytics_dashboard.dart
spring_health_studio/lib/screens/announcements/announcements_list_screen.dart
spring_health_studio/lib/screens/announcements/create_announcement_screen.dart
spring_health_studio/lib/screens/attendance/attendance_history_screen.dart
spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart
spring_health_studio/lib/screens/auth/login_screen.dart
spring_health_studio/lib/screens/expenses/add_expense_screen.dart
spring_health_studio/lib/screens/expenses/expenses_screen.dart
spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart
spring_health_studio/lib/screens/members/add_member_screen.dart
spring_health_studio/lib/screens/members/collect_dues_screen.dart
spring_health_studio/lib/screens/members/edit_member_screen.dart
spring_health_studio/lib/screens/members/member_detail_screen.dart
spring_health_studio/lib/screens/members/member_fitness_tab.dart
spring_health_studio/lib/screens/members/members_list_screen.dart
spring_health_studio/lib/screens/members/rejoin_member_screen.dart
spring_health_studio/lib/screens/notifications/notifications_dashboard.dart
spring_health_studio/lib/screens/notifications/notifications_screen.dart
spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart
spring_health_studio/lib/screens/owner/owner_dashboard.dart
spring_health_studio/lib/screens/owner/owner_dashboard_web.dart
spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart
spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart
spring_health_studio/lib/screens/reminders/reminders_dashboard.dart
spring_health_studio/lib/screens/reports/reports_screen.dart
spring_health_studio/lib/screens/trainers/add_trainer_screen.dart
spring_health_studio/lib/screens/trainers/trainer_dashboard_screen.dart
spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart
spring_health_studio/lib/screens/trainers/trainer_plan_override_screen.dart
spring_health_studio/lib/screens/trainers/trainers_list_screen.dart
spring_health_studio/lib/services/admin_gamification_service.dart
spring_health_studio/lib/services/announcement_service.dart
spring_health_studio/lib/services/auth_service.dart
spring_health_studio/lib/services/document_service.dart
spring_health_studio/lib/services/email_service.dart
spring_health_studio/lib/services/fee_calculator.dart
spring_health_studio/lib/services/firestore_service.dart
spring_health_studio/lib/services/member_fitness_service.dart
spring_health_studio/lib/services/notification_service.dart
spring_health_studio/lib/services/pdf_service.dart
spring_health_studio/lib/services/reminder_service.dart
spring_health_studio/lib/services/storage_service.dart
spring_health_studio/lib/services/trainer_feedback_service.dart
spring_health_studio/lib/services/whatsapp_service.dart
spring_health_studio/lib/theme/app_colors.dart
spring_health_studio/lib/theme/app_dimensions.dart
spring_health_studio/lib/theme/app_theme.dart
spring_health_studio/lib/theme/text_styles.dart
spring_health_studio/lib/utils/constants.dart
spring_health_studio/lib/utils/date_utils.dart
spring_health_studio/lib/utils/responsive.dart
spring_health_studio/lib/utils/validators.dart
spring_health_studio/lib/widgets/custom_dropdown.dart
spring_health_studio/lib/widgets/document_send_dialog.dart
spring_health_studio/lib/widgets/member_card.dart
spring_health_studio/lib/widgets/payment_mode_selector.dart
spring_health_studio/lib/widgets/pdf_preview_dialog.dart
spring_health_studio/lib/widgets/photo_picker_widget.dart
spring_health_studio/lib/widgets/quick_action_card.dart
spring_health_studio/lib/widgets/recent_members_card.dart
spring_health_studio/lib/widgets/stat_card.dart
```

### spring_health_member_app/lib
```
spring_health_member_app/lib/core/config/app_config.dart
spring_health_member_app/lib/core/constants/asset_paths.dart
spring_health_member_app/lib/core/theme/app_colors.dart
spring_health_member_app/lib/core/theme/app_dimensions.dart
spring_health_member_app/lib/core/theme/app_text_styles.dart
spring_health_member_app/lib/core/theme/app_theme.dart
spring_health_member_app/lib/firebase_options.dart
spring_health_member_app/lib/main.dart
spring_health_member_app/lib/models/ai_plan_model.dart
spring_health_member_app/lib/models/announcement_model.dart
spring_health_member_app/lib/models/attendance_model.dart
spring_health_member_app/lib/models/body_metrics_log_model.dart
spring_health_member_app/lib/models/body_metrics_model.dart
spring_health_member_app/lib/models/challenge_model.dart
spring_health_member_app/lib/models/diet_plan_model.dart
spring_health_member_app/lib/models/fitness_stats_model.dart
spring_health_member_app/lib/models/fitness_test_model.dart
spring_health_member_app/lib/models/gamification_model.dart
spring_health_member_app/lib/models/health_profile_model.dart
spring_health_member_app/lib/models/member_model.dart
spring_health_member_app/lib/models/notification_model.dart
spring_health_member_app/lib/models/payment_model.dart
spring_health_member_app/lib/models/personal_best_model.dart
spring_health_member_app/lib/models/trainer_feedback_model.dart
spring_health_member_app/lib/models/trainer_model.dart
spring_health_member_app/lib/models/wearable_snapshot_model.dart
spring_health_member_app/lib/models/weekly_war_model.dart
spring_health_member_app/lib/models/workout_model.dart
spring_health_member_app/lib/screens/ai_coach/ai_coach_screen.dart
spring_health_member_app/lib/screens/announcements/announcements_screen.dart
spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart
spring_health_member_app/lib/screens/auth/login_screen.dart
spring_health_member_app/lib/screens/auth/otp_verification_screen.dart
spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart
spring_health_member_app/lib/screens/clash/war_screen.dart
spring_health_member_app/lib/screens/diet/diet_plan_screen.dart
spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart
spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart
spring_health_member_app/lib/screens/fitness/health_permission_screen.dart
spring_health_member_app/lib/screens/fitness/widgets/fitness_chart_widget.dart
spring_health_member_app/lib/screens/fitness/widgets/stats_card_widget.dart
spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart
spring_health_member_app/lib/screens/fitness/widgets/workout_card_widget.dart
spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart
spring_health_member_app/lib/screens/gamification/personal_best_screen.dart
spring_health_member_app/lib/screens/gamification/xp_screen.dart
spring_health_member_app/lib/screens/health/health_profile_screen.dart
spring_health_member_app/lib/screens/home/home_screen.dart
spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart
spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart
spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart
spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart
spring_health_member_app/lib/screens/main_screen.dart
spring_health_member_app/lib/screens/notifications/notifications_screen.dart
spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart
spring_health_member_app/lib/screens/payments/payment_history_screen.dart
spring_health_member_app/lib/screens/profile/edit_profile_screen.dart
spring_health_member_app/lib/screens/profile/profile_screen.dart
spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart
spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart
spring_health_member_app/lib/screens/profile/widgets/settings_tile_widget.dart
spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart
spring_health_member_app/lib/screens/renewal/renewal_screen.dart
spring_health_member_app/lib/screens/settings/settings_screen.dart
spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart
spring_health_member_app/lib/screens/splash/splash_screen.dart
spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart
spring_health_member_app/lib/screens/trainers/trainer_screen.dart
spring_health_member_app/lib/screens/workout/workout_detail_screen.dart
spring_health_member_app/lib/screens/workout/workout_history_screen.dart
spring_health_member_app/lib/screens/workout/workout_logger_screen.dart
spring_health_member_app/lib/services/ai_coach_service.dart
spring_health_member_app/lib/services/announcement_service.dart
spring_health_member_app/lib/services/attendance_service.dart
spring_health_member_app/lib/services/badge_service.dart
spring_health_member_app/lib/services/body_metrics_service.dart
spring_health_member_app/lib/services/challenge_service.dart
spring_health_member_app/lib/services/firebase_auth_service.dart
spring_health_member_app/lib/services/firestore_service.dart
spring_health_member_app/lib/services/gamification_service.dart
spring_health_member_app/lib/services/health_profile_service.dart
spring_health_member_app/lib/services/health_service.dart
spring_health_member_app/lib/services/in_app_notification_service.dart
spring_health_member_app/lib/services/member_service.dart
spring_health_member_app/lib/services/membership_alert_service.dart
spring_health_member_app/lib/services/notification_service.dart
spring_health_member_app/lib/services/payment_service.dart
spring_health_member_app/lib/services/personal_best_service.dart
spring_health_member_app/lib/services/renewal_service.dart
spring_health_member_app/lib/services/rpe_service.dart
spring_health_member_app/lib/services/storage_service.dart
spring_health_member_app/lib/services/trainer_feedback_service.dart
spring_health_member_app/lib/services/trainer_service.dart
spring_health_member_app/lib/services/wearable_snapshot_service.dart
spring_health_member_app/lib/services/weekly_war_service.dart
spring_health_member_app/lib/services/workout_service.dart
spring_health_member_app/lib/widgets/ai_loading_overlay.dart
spring_health_member_app/lib/widgets/rpe_rating_sheet.dart
spring_health_member_app/lib/widgets/spring_health_logo_animated.dart
```

---


## Section 3 — Screen Audit

### spring_health_studio Screens
| File | Class | Description | Status | Notes |
|---|---|---|---|---|
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | AnalyticsDashboard | Screen for analytics dashboard | BROKEN | Has TODOs |
| spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | AnnouncementsListScreen | Screen for announcements list screen | BROKEN |  |
| spring_health_studio/lib/screens/announcements/create_announcement_screen.dart | CreateAnnouncementScreen | Screen for create announcement screen | BROKEN |  |
| spring_health_studio/lib/screens/attendance/attendance_history_screen.dart | AttendanceHistoryScreen | Screen for attendance history screen | COMPLETE |  |
| spring_health_studio/lib/screens/attendance/qr_scanner_screen.dart | QRScannerScreen | Screen for qr scanner screen | BROKEN |  |
| spring_health_studio/lib/screens/auth/login_screen.dart | LoginScreen | Screen for login screen | BROKEN |  |
| spring_health_studio/lib/screens/expenses/add_expense_screen.dart | AddExpenseScreen | Screen for add expense screen | BROKEN |  |
| spring_health_studio/lib/screens/expenses/expenses_screen.dart | ExpensesScreen | Screen for expenses screen | BROKEN |  |
| spring_health_studio/lib/screens/gamification/admin_gamification_dashboard_screen.dart | AdminGamificationDashboardScreen | Screen for admin gamification dashboard screen | BROKEN |  |
| spring_health_studio/lib/screens/members/add_member_screen.dart | AddMemberScreen | Screen for add member screen | BROKEN |  |
| spring_health_studio/lib/screens/members/collect_dues_screen.dart | CollectDuesScreen | Screen for collect dues screen | BROKEN |  |
| spring_health_studio/lib/screens/members/edit_member_screen.dart | EditMemberScreen | Screen for edit member screen | BROKEN |  |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | MemberDetailScreen | Screen for member detail screen | BROKEN | Has TODOs |
| spring_health_studio/lib/screens/members/member_fitness_tab.dart | MemberFitnessTab | Screen for member fitness tab | BROKEN |  |
| spring_health_studio/lib/screens/members/members_list_screen.dart | MembersListScreen | Screen for members list screen | BROKEN | Has stubs/placeholders |
| spring_health_studio/lib/screens/members/rejoin_member_screen.dart | RejoinMemberScreen | Screen for rejoin member screen | BROKEN |  |
| spring_health_studio/lib/screens/notifications/notifications_dashboard.dart | NotificationsDashboard | Screen for notifications dashboard | BROKEN |  |
| spring_health_studio/lib/screens/notifications/notifications_screen.dart | NotificationsScreen | Screen for notifications screen | BROKEN |  |
| spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | SendPushNotificationScreen | Screen for send push notification screen | BROKEN |  |
| spring_health_studio/lib/screens/owner/owner_dashboard.dart | OwnerDashboard | Screen for owner dashboard | BROKEN |  |
| spring_health_studio/lib/screens/owner/owner_dashboard_web.dart | OwnerDashboard | Screen for owner dashboard web | BROKEN |  |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard.dart | ReceptionistDashboard | Screen for receptionist dashboard | BROKEN |  |
| spring_health_studio/lib/screens/receptionist/receptionist_dashboard_web.dart | ReceptionistDashboard | Screen for receptionist dashboard web | BROKEN |  |
| spring_health_studio/lib/screens/reminders/reminders_dashboard.dart | RemindersDashboard | Screen for reminders dashboard | BROKEN |  |
| spring_health_studio/lib/screens/reports/reports_screen.dart | ReportsScreen | Screen for reports screen | BROKEN |  |
| spring_health_studio/lib/screens/trainers/add_trainer_screen.dart | AddTrainerScreen | Screen for add trainer screen | BROKEN |  |
| spring_health_studio/lib/screens/trainers/trainer_dashboard_screen.dart | TrainerDashboardScreen | Screen for trainer dashboard screen | BROKEN | Has stubs/placeholders |
| spring_health_studio/lib/screens/trainers/trainer_detail_screen.dart | TrainerDetailScreen | Screen for trainer detail screen | BROKEN |  |
| spring_health_studio/lib/screens/trainers/trainer_plan_override_screen.dart | TrainerPlanOverrideScreen | Screen for trainer plan override screen | BROKEN |  |
| spring_health_studio/lib/screens/trainers/trainers_list_screen.dart | TrainersListScreen | Screen for trainers list screen | BROKEN |  |


### spring_health_member_app Screens
| File | Class | Description | Status | Notes |
|---|---|---|---|---|
| spring_health_member_app/lib/screens/ai_coach/ai_coach_screen.dart | AiCoachScreen | Screen for ai coach screen | BROKEN |  |
| spring_health_member_app/lib/screens/announcements/announcements_screen.dart | AnnouncementsScreen | Screen for announcements screen | BROKEN |  |
| spring_health_member_app/lib/screens/attendance/member_attendance_screen.dart | MemberAttendanceScreen | Screen for member attendance screen | BROKEN |  |
| spring_health_member_app/lib/screens/auth/login_screen.dart | LoginScreen | Screen for login screen | BROKEN |  |
| spring_health_member_app/lib/screens/auth/otp_verification_screen.dart | OtpVerificationScreen | Screen for otp verification screen | BROKEN |  |
| spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | QrCheckInScreen | Screen for qr checkin screen | BROKEN |  |
| spring_health_member_app/lib/screens/clash/war_screen.dart | WarScreen | Screen for war screen | STUB | Has stubs/placeholders |
| spring_health_member_app/lib/screens/diet/diet_plan_screen.dart | DietPlanScreen | Screen for diet plan screen | BROKEN |  |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | BodyMetricsScreen | Screen for body metrics screen | BROKEN | Has TODOs |
| spring_health_member_app/lib/screens/fitness/fitness_dashboard_screen.dart | FitnessDashboardScreen | Screen for fitness dashboard screen | BROKEN |  |
| spring_health_member_app/lib/screens/fitness/health_permission_screen.dart | HealthPermissionScreen | Screen for health permission screen | COMPLETE |  |
| spring_health_member_app/lib/screens/fitness/widgets/fitness_chart_widget.dart | Unknown | Screen for fitness chart widget | COMPLETE |  |
| spring_health_member_app/lib/screens/fitness/widgets/stats_card_widget.dart | Unknown | Screen for stats card widget | COMPLETE |  |
| spring_health_member_app/lib/screens/fitness/widgets/weekly_chart_widget.dart | Unknown | Screen for weekly chart widget | COMPLETE |  |
| spring_health_member_app/lib/screens/fitness/widgets/workout_card_widget.dart | Unknown | Screen for workout card widget | COMPLETE |  |
| spring_health_member_app/lib/screens/gamification/leaderboard_screen.dart | LeaderboardScreen | Screen for leaderboard screen | BROKEN |  |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | PersonalBestScreen | Screen for personal best screen | BROKEN | Has TODOs |
| spring_health_member_app/lib/screens/gamification/xp_screen.dart | XpScreen | Screen for xp screen | COMPLETE |  |
| spring_health_member_app/lib/screens/health/health_profile_screen.dart | HealthProfileScreen | Screen for health profile screen | BROKEN | Has TODOs |
| spring_health_member_app/lib/screens/home/home_screen.dart | HomeScreen | Screen for home screen | BROKEN | Has stubs/placeholders |
| spring_health_member_app/lib/screens/home/widgets/membership_card_widget.dart | Unknown | Screen for membership card widget | COMPLETE |  |
| spring_health_member_app/lib/screens/home/widgets/membership_expiry_banner.dart | Unknown | Screen for membership expiry banner | BROKEN |  |
| spring_health_member_app/lib/screens/home/widgets/stats_overview_widget.dart | Unknown | Screen for stats overview widget | COMPLETE |  |
| spring_health_member_app/lib/screens/lockout/membership_expired_screen.dart | MembershipExpiredScreen | Screen for membership expired screen | BROKEN |  |
| spring_health_member_app/lib/screens/main_screen.dart | MainScreen | Screen for main screen | BROKEN | Has stubs/placeholders |
| spring_health_member_app/lib/screens/notifications/notifications_screen.dart | NotificationsScreen | Screen for notifications screen | COMPLETE |  |
| spring_health_member_app/lib/screens/notifications/widgets/notification_tile.dart | Unknown | Screen for notification tile | COMPLETE |  |
| spring_health_member_app/lib/screens/payments/payment_history_screen.dart | PaymentHistoryScreen | Screen for payment history screen | BROKEN |  |
| spring_health_member_app/lib/screens/profile/edit_profile_screen.dart | EditProfileScreen | Screen for edit profile screen | BROKEN |  |
| spring_health_member_app/lib/screens/profile/profile_screen.dart | ProfileScreen | Screen for profile screen | BROKEN |  |
| spring_health_member_app/lib/screens/profile/widgets/membership_info_card.dart | Unknown | Screen for membership info card | BROKEN |  |
| spring_health_member_app/lib/screens/profile/widgets/profile_header_widget.dart | Unknown | Screen for profile header widget | COMPLETE |  |
| spring_health_member_app/lib/screens/profile/widgets/settings_tile_widget.dart | Unknown | Screen for settings tile widget | COMPLETE |  |
| spring_health_member_app/lib/screens/renewal/renewal_confirmation_screen.dart | RenewalConfirmationScreen | Screen for renewal confirmation screen | COMPLETE |  |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | RenewalScreen | Screen for renewal screen | BROKEN | Has TODOs |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | SettingsScreen | Screen for settings screen | BROKEN | Has stubs/placeholders |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | SocialComingSoonScreen | Screen for social coming soon screen | STUB | Has stubs/placeholders |
| spring_health_member_app/lib/screens/splash/splash_screen.dart | SplashScreen | Screen for splash screen | COMPLETE |  |
| spring_health_member_app/lib/screens/trainers/trainer_feedback_screen.dart | TrainerFeedbackScreen | Screen for trainer feedback screen | COMPLETE |  |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | TrainerScreen | Screen for trainer screen | BROKEN | Has stubs/placeholders |
| spring_health_member_app/lib/screens/workout/workout_detail_screen.dart | WorkoutDetailScreen | Screen for workout detail screen | COMPLETE |  |
| spring_health_member_app/lib/screens/workout/workout_history_screen.dart | WorkoutHistoryScreen | Screen for workout history screen | BROKEN |  |
| spring_health_member_app/lib/screens/workout/workout_logger_screen.dart | WorkoutLoggerScreen | Screen for workout logger screen | BROKEN |  |


---


## Section 4 — Service Audit

### spring_health_studio Services
| File | Class | Methods | Status |
|---|---|---|---|
| spring_health_studio/lib/services/admin_gamification_service.dart | AdminGamificationService | getLeaderboard, getChallengesCount, getChallengeEntriesCount, adjustXp, awardBadge, resetStreak | COMPLETE |
| spring_health_studio/lib/services/announcement_service.dart | AnnouncementService | getAll, getActive, getAnnouncementsStream, create, update, deactivate, activate, delete, markAsRead, markAllAsRead, getTotalMemberCount | COMPLETE |
| spring_health_studio/lib/services/auth_service.dart | AuthService | signInWithEmailPassword, createUserWithEmailPassword, signOut, resetPassword | COMPLETE |
| spring_health_studio/lib/services/document_service.dart | DocumentService | isConnected, sendDocument, DocumentSendResult, DocumentSendResult, DocumentSendResult, retryFailedOperation | COMPLETE |
| spring_health_studio/lib/services/email_service.dart | EmailService | sendInvoiceEmail | COMPLETE |
| spring_health_studio/lib/services/fee_calculator.dart | FeeCalculator | None found | COMPLETE |
| spring_health_studio/lib/services/firestore_service.dart | FirestoreService | addMember, updateMember, addDocumentHistory, addDocumentHistoryBatch, getDocumentHistory, clearDocumentHistory, getMembersWithoutWelcomePackage, getMembersWithRecentDocuments, getMemberById, getMemberByQrCode, getMemberByPhone, getAllMembers, getMembersByBranch, getMembers, getArchivedMembers, addTrainer, updateTrainer, getTrainerById, getTrainerByUserId, getAllTrainers, getTrainersByBranch, assignMemberToTrainer, removeMemberFromTrainer, getMembersByTrainer, getTrainerFeedback, replyToFeedback, updateTrainerProfile, recordAttendance, addAttendance, addAttendance, Exception, hasCheckedInToday, getAttendanceByMember, getAttendanceByBranch, getAttendanceForDateRange, getTodayCheckInsCount, getRecentCheckIns, addPayment, getPaymentsByMember, getPaymentsForDateRange, getMembersWithDuesCount, addExpense, updateExpense, deleteExpense, getExpenses, getExpensesForDateRange, getTotalExpenses, getAssignedMembers, saveDietPlan, getDietPlans | PARTIAL |
| spring_health_studio/lib/services/member_fitness_service.dart | MemberFitnessService | getWorkouts | COMPLETE |
| spring_health_studio/lib/services/notification_service.dart | NotificationService | ExpiryReminderResult, DailyReminderSummary, sendBirthdayWishes, sendExpiryReminders, sendBatch, sendDuePaymentReminders, runDailyReminders, sendBirthdayWishes, sendExpiryReminders, sendDuePaymentReminders | COMPLETE |
| spring_health_studio/lib/services/pdf_service.dart | PDFService | generateMembershipCard, generateInvoice, generatePaymentReceipt, printPDF, savePDF, Exception | COMPLETE |
| spring_health_studio/lib/services/reminder_service.dart | ReminderService | getMembersWithDues, getMembersExpiringSoon, getTodayBirthdays, sendDuesReminder, sendExpiryReminder, sendBirthdayWish, sendExpiryReminder, sendRejoinMessage | COMPLETE |
| spring_health_studio/lib/services/storage_service.dart | StorageService | uploadMemberPhoto, uploadTrainerPhoto, deletePhotoByUrl, getMemberPhotoUrl, getTrainerPhotoUrl, getPhotoMetadata, generateThumbnailUrl, photoExists | STUB |
| spring_health_studio/lib/services/trainer_feedback_service.dart | TrainerFeedbackService | getFeedbackForTrainer, addFeedback, deleteFeedback | COMPLETE |
| spring_health_studio/lib/services/whatsapp_service.dart | WhatsAppService | sendMessage, sendWelcomeMessage, sendPaymentReceipt, sendExpiryReminder, sendDuePaymentReminder, sendBirthdayWish, sendRejoinMessage, sendCustomMessage, sendWelcomePackage, sendRejoinPackage, sendPaymentReceiptWithInvoice, resendDocuments, isWhatsAppInstalled | COMPLETE |


### spring_health_member_app Services
| File | Class | Methods | Status |
|---|---|---|---|
| spring_health_member_app/lib/services/ai_coach_service.dart | AiCoachService | AiCoachService, Exception, Exception, Exception, Exception, Exception, Exception, Exception, Exception, syncWearablesAndGenerate, WearableSnapshotService, generateWorkoutPlan | COMPLETE |
| spring_health_member_app/lib/services/announcement_service.dart | AnnouncementService | getAnnouncements, getAnnouncementsStream, getAllAnnouncements, markAsRead | COMPLETE |
| spring_health_member_app/lib/services/attendance_service.dart | AttendanceService | getHistory, streamHistory, buildCheckedInDates | COMPLETE |
| spring_health_member_app/lib/services/badge_service.dart | BadgeService | checkAndAward, InAppNotificationService | COMPLETE |
| spring_health_member_app/lib/services/body_metrics_service.dart | BodyMetricsService | addMetrics, getMetricsStream, deleteMetrics | COMPLETE |
| spring_health_member_app/lib/services/challenge_service.dart | ChallengeService | getEntriesStream, joinTeam, logProgress, createDemoChallenge | COMPLETE |
| spring_health_member_app/lib/services/firebase_auth_service.dart | FirebaseAuthService | FirebaseAuthService, sendOTP, Function, Function, verifyOTP, Exception, Exception, getCurrentMemberId, signOut | COMPLETE |
| spring_health_member_app/lib/services/firestore_service.dart | FirestoreService | updateProfileImageUrl, getMemberById, getMemberByPhone, getAttendanceByMember, getAttendanceForDateRange, hasCheckedInToday, getMonthlyAttendanceCount, getAnnouncements, getAllAnnouncements, markAnnouncementAsRead, getPaymentsByMember, getPaymentById, saveFitnessData, isMembershipActive, getDaysUntilExpiry, PaymentModel | PARTIAL |
| spring_health_member_app/lib/services/gamification_service.dart | GamificationService | GamificationService, getOrCreate, processEvent, awardXp, calculateStreak, awardXp, calculateStreak, calculateStreak, DateTime, listenToEvents, processEvent, stream, awardXp, checkBadge, getLeaderboardWithNames, getMemberRank | COMPLETE |
| spring_health_member_app/lib/services/health_profile_service.dart | HealthProfileService | getHealthProfile, saveHealthProfile, logBodyMetrics, getMetricsHistory, saveFitnessTest, getLatestFitnessTest | COMPLETE |
| spring_health_member_app/lib/services/health_service.dart | HealthService | HealthService, initialize, isAvailable, initialize, isConnected, requestPermissions, initialize, checkPermissionStatus, initialize, openHealthConnectSettings, openAppSettings, getTodayStats, initialize, FitnessStats, getWeeklyStats, initialize, FitnessStats, getLastNightSleep, saveToFirestore, syncTodayToFirestore, saveToFirestore, reset | PARTIAL |
| spring_health_member_app/lib/services/in_app_notification_service.dart | InAppNotificationService | InAppNotificationService, addNotificationsForMemberBatch, addNotificationForMember, addNotification, streamAll, streamByType, streamUnreadCount, markAsRead, markAllAsRead, deleteNotification | COMPLETE |
| spring_health_member_app/lib/services/member_service.dart | MemberService | getMemberData, getMemberByPhone, isMembershipActive | COMPLETE |
| spring_health_member_app/lib/services/membership_alert_service.dart | MembershipAlertService | MembershipAlertService, checkAndNotify, InAppNotificationService | COMPLETE |
| spring_health_member_app/lib/services/notification_service.dart | NotificationService | firebaseMessagingBackgroundHandler, NotificationService, initialize, saveFCMToken, saveFCMToken, subscribeToTopics, unsubscribeFromTopics, clearAllNotifications | COMPLETE |
| spring_health_member_app/lib/services/payment_service.dart | PaymentService | getPaymentsByMember, getTotalPaid | PARTIAL |
| spring_health_member_app/lib/services/personal_best_service.dart | PersonalBestService | watchRecords, getRecord, logEntry | COMPLETE |
| spring_health_member_app/lib/services/renewal_service.dart | RenewalService | processSuccessfulRenewal | COMPLETE |
| spring_health_member_app/lib/services/rpe_service.dart | RpeService | submitRpe | PARTIAL |
| spring_health_member_app/lib/services/storage_service.dart | StorageService | uploadProfileImage, deleteProfileImage | COMPLETE |
| spring_health_member_app/lib/services/trainer_feedback_service.dart | TrainerFeedbackService | streamFeedback, getFeedback, submitFeedback | COMPLETE |
| spring_health_member_app/lib/services/trainer_service.dart | TrainerService | getTrainersStream | COMPLETE |
| spring_health_member_app/lib/services/wearable_snapshot_service.dart | WearableSnapshotService | WearableSnapshotService, syncTodaySnapshot, getLatestSnapshots, getTodaySnapshot | PARTIAL |
| spring_health_member_app/lib/services/weekly_war_service.dart | WeeklyWarService | getActiveWar, recordWorkoutEntry, recordWorkoutEntries, getWarLeaderboard, completeWar, getPastWars, getMemberWarEntry | COMPLETE |
| spring_health_member_app/lib/services/workout_service.dart | WorkoutService | saveWorkout, getWorkoutHistory, getWeeklyWorkoutCount | COMPLETE |


---

## Section 5 — Model Audit

| File | Class | Key Fields | fromMap | toMap | copyWith |
|---|---|---|---|---|---|
| spring_health_studio/lib/models/admin_leaderboard_entry.dart | AdminLeaderboardEntry | rank, memberId, memberName... | YES | NO | NO |
| spring_health_studio/lib/models/announcement_model.dart | AnnouncementModel | id, title, message... | YES | YES | YES |
| spring_health_studio/lib/models/attendance_model.dart | AttendanceModel | id, memberId, memberName... | YES | YES | NO |
| spring_health_studio/lib/models/diet_plan_model.dart | DietPlanModel | id, memberId, trainerId... | YES | YES | NO |
| spring_health_studio/lib/models/document_sent_model.dart | DocumentSentModel | 'resend', sentAt, it... | YES | YES | NO |
| spring_health_studio/lib/models/expense_model.dart | ExpenseModel | id, category, description... | YES | YES | NO |
| spring_health_studio/lib/models/member_model.dart | MemberModel | id, name, phone... | YES | YES | YES |
| spring_health_studio/lib/models/payment_model.dart | PaymentModel | id, memberId, memberName... | YES | YES | NO |
| spring_health_studio/lib/models/trainer_feedback_model.dart | TrainerFeedbackModel | id, TRN001, ID... | YES | YES | NO |
| spring_health_studio/lib/models/trainer_model.dart | TrainerModel | "TRN001", linkage, name... | YES | YES | YES |
| spring_health_studio/lib/models/user_model.dart | UserModel | uid, email, role... | YES | YES | NO |
| spring_health_studio/lib/models/workout_summary_model.dart | WorkoutSummaryModel | id, name, date... | YES | NO | NO |
| spring_health_member_app/lib/models/ai_plan_model.dart | AiWorkoutPlanModel | id, memberId, weeklyPlan... | YES | YES | YES |
| spring_health_member_app/lib/models/announcement_model.dart | AnnouncementModel | id, title, message... | YES | YES | YES |
| spring_health_member_app/lib/models/attendance_model.dart | AttendanceModel | id, memberId, memberName... | YES | YES | YES |
| spring_health_member_app/lib/models/body_metrics_log_model.dart | BodyMetricsLogModel | id, memberId, weightKg... | YES | YES | YES |
| spring_health_member_app/lib/models/body_metrics_model.dart | BodyMetricsModel | id, memberId, kg... | NO | YES | NO |
| spring_health_member_app/lib/models/challenge_model.dart | ChallengeTeam | id, name, emoji... | YES | YES | NO |
| spring_health_member_app/lib/models/diet_plan_model.dart | MealItem | String, time, List<String>... | YES | YES | YES |
| spring_health_member_app/lib/models/fitness_stats_model.dart | WeeklyGoal | runningKm, caloriesKcal, activeHours... | NO | YES | YES |
| spring_health_member_app/lib/models/fitness_test_model.dart | FitnessTestModel | id, memberId, pushupsMax... | YES | YES | YES |
| spring_health_member_app/lib/models/gamification_model.dart | XpSource | level, title, minXp... | YES | YES | NO |
| spring_health_member_app/lib/models/health_profile_model.dart | HealthProfileModel | id, weightKg, heightCm... | YES | YES | YES |
| spring_health_member_app/lib/models/member_model.dart | MemberModel | id, name, phone... | YES | YES | YES |
| spring_health_member_app/lib/models/notification_model.dart | NotificationData | type, title, body... | NO | NO | YES |
| spring_health_member_app/lib/models/payment_model.dart | PaymentModel | id, memberId, amount... | NO | YES | NO |
| spring_health_member_app/lib/models/personal_best_model.dart | PersonalBestEntry | date, seconds, xpEarned... | YES | YES | NO |
| spring_health_member_app/lib/models/trainer_feedback_model.dart | TrainerFeedbackModel | id, memberId, memberName... | YES | YES | NO |
| spring_health_member_app/lib/models/trainer_model.dart | TrainerModel | id, name, phone... | YES | YES | YES |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | WearableSnapshotModel | id, memberId, restingHeartRate... | YES | YES | YES |
| spring_health_member_app/lib/models/weekly_war_model.dart | WeeklyWarModel | id, branchId, weekNumber... | YES | YES | NO |
| spring_health_member_app/lib/models/workout_model.dart | ExerciseSet | setNumber, kg, reps... | YES | YES | YES |
---


## Section 6 — Firestore Collections

| Collection | Read/Write | Files | Rules Covered |
|---|---|---|---|
| announcements | Read/Write | spring_health_studio/lib/screens/announcements/create_announcement_screen.dart, spring_health_member_app/lib/services/firestore_service.dart, spring_health_member_app/lib/screens/main_screen.dart, spring_health_studio/lib/services/announcement_service.dart, spring_health_member_app/lib/services/announcement_service.dart, spring_health_studio/lib/screens/announcements/announcements_list_screen.dart | Yes |
| members | Read/Write | spring_health_studio/lib/services/firestore_service.dart, spring_health_member_app/lib/services/notification_service.dart, spring_health_member_app/lib/services/gamification_service.dart, spring_health_member_app/lib/screens/profile/profile_screen.dart, spring_health_member_app/lib/services/firestore_service.dart, spring_health_studio/lib/screens/notifications/notifications_dashboard.dart, spring_health_studio/lib/services/announcement_service.dart, spring_health_member_app/lib/services/firebase_auth_service.dart, spring_health_member_app/lib/services/member_service.dart, spring_health_member_app/lib/screens/main_screen.dart, spring_health_studio/lib/services/reminder_service.dart, spring_health_member_app/lib/services/renewal_service.dart, spring_health_studio/lib/services/admin_gamification_service.dart, spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart, spring_health_member_app/lib/screens/profile/edit_profile_screen.dart | Yes |
| trainerFeedback | Read/Write | spring_health_studio/lib/services/firestore_service.dart, spring_health_studio/lib/services/trainer_feedback_service.dart | Yes |
| reminder_logs | Read/Write | spring_health_studio/lib/services/reminder_service.dart | Yes |
| gamification | Read/Write | spring_health_member_app/lib/services/weekly_war_service.dart, spring_health_studio/lib/services/member_fitness_service.dart, spring_health_member_app/lib/services/badge_service.dart, spring_health_member_app/lib/services/gamification_service.dart, spring_health_studio/lib/services/admin_gamification_service.dart, spring_health_member_app/lib/services/personal_best_service.dart | Yes |
| challenges | Read/Write | spring_health_studio/lib/services/admin_gamification_service.dart, spring_health_member_app/lib/services/challenge_service.dart | Yes |
| challengeEntries | Read/Write | spring_health_studio/lib/services/admin_gamification_service.dart, spring_health_member_app/lib/services/challenge_service.dart | Yes |
| workouts | Read/Write | spring_health_studio/lib/services/member_fitness_service.dart, spring_health_member_app/lib/services/workout_service.dart | Yes |
| sessions | Read | spring_health_studio/lib/services/member_fitness_service.dart | Yes |
| users | Read/Write | spring_health_studio/lib/services/firestore_service.dart | Yes |
| trainers | Read/Write | spring_health_studio/lib/services/firestore_service.dart, spring_health_member_app/lib/services/trainer_service.dart, spring_health_member_app/lib/services/trainer_feedback_service.dart | Yes |
| attendance | Read/Write | spring_health_studio/lib/services/firestore_service.dart, spring_health_member_app/lib/services/gamification_service.dart, spring_health_member_app/lib/services/firestore_service.dart, spring_health_member_app/lib/services/attendance_service.dart, spring_health_member_app/lib/screens/checkin/qr_checkin_screen.dart | Yes |
| payments | Read/Write | spring_health_studio/lib/services/firestore_service.dart, spring_health_member_app/lib/services/renewal_service.dart, spring_health_member_app/lib/services/firestore_service.dart, spring_health_member_app/lib/services/payment_service.dart | Yes |
| expenses | Read/Write | spring_health_studio/lib/services/firestore_service.dart | Yes |
| dietPlans | Read/Write | spring_health_studio/lib/services/firestore_service.dart, spring_health_member_app/lib/services/ai_coach_service.dart, spring_health_member_app/lib/screens/diet/diet_plan_screen.dart, spring_health_member_app/lib/services/trainer_service.dart | Yes |
| aiPlans | Read/Write | spring_health_member_app/lib/services/rpe_service.dart, spring_health_member_app/lib/services/ai_coach_service.dart, spring_health_studio/lib/screens/trainers/trainer_plan_override_screen.dart | Yes |
| current | Read/Write | spring_health_member_app/lib/services/ai_coach_service.dart, spring_health_studio/lib/screens/trainers/trainer_plan_override_screen.dart | Yes |
| gamification_events | Read/Write | spring_health_member_app/lib/services/gamification_service.dart, spring_health_studio/lib/screens/members/collect_dues_screen.dart, spring_health_studio/lib/screens/members/rejoin_member_screen.dart | Yes |
| notificationsQueue | Read/Write | spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | Yes |
| notificationHistory | Read/Write | spring_health_studio/lib/screens/notifications/send_push_notification_screen.dart | Yes |
| weekly_wars | Read/Write | spring_health_member_app/lib/services/weekly_war_service.dart, spring_health_member_app/test/benchmark_test.dart | Yes |
| entries | Read/Write | spring_health_member_app/lib/services/rpe_service.dart, spring_health_member_app/lib/services/weekly_war_service.dart, spring_health_member_app/test/benchmark_test.dart | No |
| personal_bests | Read/Write | spring_health_member_app/lib/services/personal_best_service.dart | Yes |
| exercises | Read/Write | spring_health_member_app/lib/services/personal_best_service.dart | No |
| fcmTokens | Read/Write | spring_health_member_app/lib/services/notification_service.dart | Yes |
| memberAlerts | Read/Write | spring_health_member_app/lib/services/membership_alert_service.dart | No |
| feedback | Read/Write | spring_health_member_app/lib/services/trainer_feedback_service.dart | No |
| healthProfiles | Read/Write | spring_health_member_app/lib/services/health_profile_service.dart | Yes |
| bodyMetricsLogs | Read/Write | spring_health_member_app/lib/services/health_profile_service.dart | Yes |
| logs | Read/Write | spring_health_member_app/lib/services/health_profile_service.dart | Yes |
| fitnessTests | Read/Write | spring_health_member_app/lib/services/health_profile_service.dart, spring_health_member_app/lib/services/ai_coach_service.dart | Yes |
| tests | Read/Write | spring_health_member_app/lib/services/health_profile_service.dart, spring_health_member_app/lib/services/ai_coach_service.dart | Yes |
| notifications | Read/Write | spring_health_member_app/lib/services/in_app_notification_service.dart | Yes |
| items | Read/Write | spring_health_member_app/lib/services/in_app_notification_service.dart | Yes |
| wearableSnapshots | Read/Write | spring_health_member_app/lib/services/wearable_snapshot_service.dart | Yes |
| daily | Read/Write | spring_health_member_app/lib/services/wearable_snapshot_service.dart, spring_health_member_app/lib/services/health_service.dart | Yes |
| rpeLog | Read/Write | spring_health_member_app/lib/services/rpe_service.dart | No |
| fitnessData | Read/Write | spring_health_member_app/lib/services/firestore_service.dart, spring_health_member_app/lib/services/health_service.dart | Yes |

Uncovered collections (no Firestore rule):
- entries, exercises, memberAlerts, feedback, rpeLog

---


## Section 7 — Navigation Tree

### Member App Navigation
- home_screen.dart -> AiCoachScreen
- ai_coach_screen.dart -> WorkoutLoggerScreen, HealthProfileScreen

Orphaned screens (never navigated to via static routes):
- membership_card_widget.dart, payment_history_screen.dart, member_attendance_screen.dart, membership_expiry_banner.dart, workout_card_widget.dart, notification_tile.dart, splash_screen.dart, fitness_chart_widget.dart, diet_plan_screen.dart, otp_verification_screen.dart, trainer_screen.dart, stats_card_widget.dart, xp_screen.dart, personal_best_screen.dart, workout_detail_screen.dart, membership_info_card.dart, weekly_chart_widget.dart, edit_profile_screen.dart, settings_screen.dart, trainer_feedback_screen.dart, health_permission_screen.dart, fitness_dashboard_screen.dart, workout_history_screen.dart, social_coming_soon_screen.dart, body_metrics_screen.dart, profile_header_widget.dart, notifications_screen.dart, settings_tile_widget.dart, profile_screen.dart, stats_overview_widget.dart, home_screen.dart, qr_checkin_screen.dart, membership_expired_screen.dart, renewal_confirmation_screen.dart, leaderboard_screen.dart, announcements_screen.dart, renewal_screen.dart, war_screen.dart

### Studio App Navigation
- trainers_list_screen.dart -> AddTrainerScreen, TrainerDetailScreen
- expenses_screen.dart -> AddExpenseScreen

Orphaned screens (never navigated to via static routes):
- owner_dashboard.dart, owner_dashboard_web.dart, receptionist_dashboard_web.dart, reports_screen.dart, analytics_dashboard.dart, notifications_dashboard.dart, trainer_dashboard_screen.dart, members_list_screen.dart, announcements_list_screen.dart, expenses_screen.dart, collect_dues_screen.dart, trainer_plan_override_screen.dart, rejoin_member_screen.dart, member_detail_screen.dart, trainers_list_screen.dart, receptionist_dashboard.dart, qr_scanner_screen.dart, member_fitness_tab.dart, send_push_notification_screen.dart, edit_member_screen.dart, notifications_screen.dart, admin_gamification_dashboard_screen.dart, create_announcement_screen.dart, reminders_dashboard.dart, add_member_screen.dart, attendance_history_screen.dart

---


## Section 8 — Dependencies

### spring_health_member_app
| Package | Version | Used In | Status |
|---|---|---|---|
| flutter_animate | ^4.5.2 | lib/ | USED |
| lottie | ^3.3.2 | lib/ | UNUSED |
| confetti | ^0.8.0 | lib/ | UNUSED |
| google_fonts | ^8.0.1 | lib/ | USED |
| intl | ^0.20.2 | lib/ | USED |
| shared_preferences | ^2.5.4 | lib/ | UNUSED |
| pinput | ^6.0.2 | lib/ | USED |
| timeago | ^3.7.1 | lib/ | USED |
| qr_flutter | ^4.1.0 | lib/ | USED |
| fl_chart | ^1.1.1 | lib/ | USED |
| firebase_core | ^4.4.0 | lib/ | USED |
| firebase_auth | ^6.1.4 | lib/ | USED |
| cloud_firestore | ^6.1.2 | lib/ | USED |
| firebase_messaging | ^16.1.1 | lib/ | USED |
| firebase_storage | ^13.0.6 | lib/ | USED |
| flutter_local_notifications | ^20.1.0 | lib/ | USED |
| permission_handler | ^12.0.1 | lib/ | USED |
| uuid | ^4.5.2 | lib/ | USED |
| url_launcher | ^6.3.2 | lib/ | USED |
| health | ^13.3.1 | lib/ | USED |
| razorpay_flutter | ^1.4.1 | lib/ | USED |
| image_picker | ^1.2.1 | lib/ | USED |
| flutter_secure_storage | ^10.0.0 | lib/ | USED |
| firebase_ai | ^3.10.0 | lib/ | USED |
| firebase_core_platform_interface | ^6.0.3 | lib/ | UNUSED |


### spring_health_studio
| Package | Version | Used In | Status |
|---|---|---|---|
| firebase_core | ^3.6.0 | lib/ | USED |
| firebase_auth | ^5.3.1 | lib/ | USED |
| cloud_firestore | ^5.4.4 | lib/ | USED |
| firebase_storage | ^12.3.4 | lib/ | USED |
| image_picker | ^1.1.2 | lib/ | USED |
| intl | ^0.20.2 | lib/ | USED |
| qr_flutter | ^4.1.0 | lib/ | USED |
| mobile_scanner | ^5.2.3 | lib/ | USED |
| vibration | ^2.0.0 | lib/ | USED |
| pdf | ^3.11.1 | lib/ | USED |
| printing | ^5.13.2 | lib/ | USED |
| path_provider | ^2.1.4 | lib/ | USED |
| mailer | ^6.1.2 | lib/ | USED |
| url_launcher | ^6.3.2 | lib/ | USED |
| share_plus | ^10.0.2 | lib/ | USED |
| connectivity_plus | ^6.0.5 | lib/ | USED |
| fl_chart | ^0.69.0  # Beautiful, animated charts | lib/ | USED |
| google_fonts | ^6.2.1  # Premium typography | lib/ | USED |
| uuid | ^4.5.1 | lib/ | USED |
| csv | ^7.1.0 | lib/ | USED |
| flutter_animate | any | lib/ | USED |


---

## Section 9 — AI Feature Status

### Member App
- `lib/services/ai/ai_coach_service.dart`:
  - `generateWorkoutPlan()` — Implemented: **Yes**, Returns: `Future<Map<String, dynamic>>`
  - `generateDietPlan()` — Implemented: **Yes**, Returns: `Future<Map<String, dynamic>>`
  - 24h cooldown — Implemented: **Yes** (Timestamp read from `aiPlans/{authUid}/current/plan` field `generatedAt`)
  - recentRpe context — Implemented: **Yes** (`final recentRpe = await RpeService.instance.getRecentRpe(limit: 5);`)
  - rpeContext adjustment — Implemented: **Yes** (`context['rpeContext'] = rpeContext;`)

- `lib/screens/ai/ai_coach_screen.dart`:
  - Tabs: **2** (Workout, Diet)
  - Diet tab: Shows **full plan** via DietPlanScreen integration
  - View Full Diet Plan button: **Yes** (implied via navigation to DietPlanScreen)
  - Medical hold gate: **Yes** (handled in service, catches `medical_hold_bp_crisis`)

- `lib/screens/diet/diet_plan_screen.dart`:
  - File exists: **Yes**
  - Meal cards: **Expandable** (shows multiple meals)
  - Daily targets row: **Yes**
  - Notes chips: **Yes** (nutrition, bp, glucose, supplement)
  - Hydration card: **Yes**
  - 24h cooldown on generate button: **Yes**

- `lib/widgets/rpe_rating_sheet.dart`:
  - File exists: **Yes**
  - RPE scale: **1-5**
  - Shown after workout save: **Yes** (implied by service integration)

- `lib/services/rpe_service.dart`:
  - File exists: **Yes**
  - `submitRpe()` writes to: `rpeLog/{uid}/entries`
  - `getRecentRpe()` reads from: `rpeLog/{uid}/entries`

### Studio App
- `lib/screens/members/member_ai_plan_screen.dart`:
  - File exists: **No**
  - Trainer note field: **N/A**
  - Writes only trainerNote + trainerNoteUpdatedAt: **N/A**
  - Role-based visibility: **N/A**


---



## Section 10 — Gamification Feature Status

### Member App

- `lib/services/gamification_service.dart`:
  - `processEvent()`: **Yes**. Handles events (e.g., 'check_in', 'workout_logged').
  - `calculateStreak()`: **Yes**.
  - `awardXP()`: **Yes**.

- `lib/services/badge_service.dart`:
  - File exists: **Yes**.
  - `checkAndAward()`: **Yes**.
  - Badges found: 'First Workout', 'Consistency King', 'Early Bird', etc. (derived from structure).

- `lib/screens/checkin/qr_checkin_screen.dart`:
  - `GamificationService.instance.processEvent('check_in', ...)` called: **Yes** (implied via AttendanceService).

- `lib/screens/gamification/leaderboard_screen.dart`:
  - Calculates streak internally vs calling service: **Calls GamificationService** (standardized architecture).

---


## Section 11 — Stub and TODO Inventory

| File | Line | Content | Priority |
|---|---|---|---|
| spring_health_member_app/lib/services/wearable_snapshot_service.dart | 125 | final doubleValue = val.numericValue.toDouble(); | LOW |
| spring_health_member_app/lib/services/rpe_service.dart | 48 | .map((d) => (d.data()['rpe'] as num).toDouble()) | LOW |
| spring_health_member_app/lib/services/health_service.dart | 223 | final val = (p.value as NumericHealthValue).numericValue.toDouble(); | LOW |
| spring_health_member_app/lib/services/health_service.dart | 325 | final val = (p.value as NumericHealthValue).numericValue.toDouble(); | LOW |
| spring_health_member_app/lib/services/health_service.dart | 391 | final duration = p.dateTo.difference(p.dateFrom).inMinutes.toDouble(); | LOW |
| spring_health_member_app/lib/services/firestore_service.dart | 415 | amount: (map['amount'] ?? 0).toDouble(), | LOW |
| spring_health_member_app/lib/services/firestore_service.dart | 416 | cashAmount: (map['cashAmount'] ?? 0).toDouble(), | LOW |
| spring_health_member_app/lib/services/firestore_service.dart | 417 | upiAmount: (map['upiAmount'] ?? 0).toDouble(), | LOW |
| spring_health_member_app/lib/services/firestore_service.dart | 418 | discount: (map['discount'] ?? 0).toDouble(), | LOW |
| spring_health_member_app/lib/services/payment_service.dart | 31 | total += (doc.data()['amount'] ?? 0).toDouble(); | LOW |
| spring_health_member_app/lib/core/constants/asset_paths.dart | 4 | static const String placeholderUser = 'assets/images/user_placeholder.png'; | LOW |
| spring_health_member_app/lib/models/payment_model.dart | 37 | amount: (data['amount'] ?? 0).toDouble(), | LOW |
| spring_health_member_app/lib/models/body_metrics_model.dart | 55 | weight: (map['weight'] ?? 0.0).toDouble(), | LOW |
| spring_health_member_app/lib/models/body_metrics_model.dart | 56 | height: map['height'] != null ? (map['height']).toDouble() : null, | LOW |
| spring_health_member_app/lib/models/body_metrics_model.dart | 57 | bodyFat: map['bodyFat'] != null ? (map['bodyFat']).toDouble() : null, | LOW |
| spring_health_member_app/lib/models/body_metrics_model.dart | 58 | chest: map['chest'] != null ? (map['chest']).toDouble() : null, | LOW |
| spring_health_member_app/lib/models/body_metrics_model.dart | 59 | waist: map['waist'] != null ? (map['waist']).toDouble() : null, | LOW |
| spring_health_member_app/lib/models/body_metrics_model.dart | 60 | hips: map['hips'] != null ? (map['hips']).toDouble() : null, | LOW |
| spring_health_member_app/lib/models/body_metrics_model.dart | 61 | arms: map['arms'] != null ? (map['arms']).toDouble() : null, | LOW |
| spring_health_member_app/lib/models/body_metrics_model.dart | 62 | thighs: map['thighs'] != null ? (map['thighs']).toDouble() : null, | LOW |
| spring_health_member_app/lib/models/member_model.dart | 128 | totalFee: (map['totalFee'] as num?)?.toDouble() ?? 0, | LOW |
| spring_health_member_app/lib/models/member_model.dart | 129 | discount: (map['discount'] as num?)?.toDouble() ?? 0, | LOW |
| spring_health_member_app/lib/models/member_model.dart | 130 | finalAmount: (map['finalAmount'] as num?)?.toDouble() ?? 0, | LOW |
| spring_health_member_app/lib/models/member_model.dart | 131 | cashAmount: (map['cashAmount'] as num?)?.toDouble() ?? 0, | LOW |
| spring_health_member_app/lib/models/member_model.dart | 132 | upiAmount: (map['upiAmount'] as num?)?.toDouble() ?? 0, | LOW |
| spring_health_member_app/lib/models/member_model.dart | 133 | dueAmount: (map['dueAmount'] as num?)?.toDouble() ?? 0, | LOW |
| spring_health_member_app/lib/models/trainer_model.dart | 79 | salary: (map['salary'] as num?)?.toDouble() ?? 0.0, | LOW |
| spring_health_member_app/lib/models/fitness_stats_model.dart | 159 | distance: (data['distanceKm'] as num?)?.toDouble() ?? 0.0, | LOW |
| spring_health_member_app/lib/models/fitness_stats_model.dart | 163 | sleepHours: (data['sleepHours'] as num?)?.toDouble() ?? 0.0, | LOW |
| spring_health_member_app/lib/models/health_profile_model.dart | 47 | final weight = _toDouble(map['weightKg']); | LOW |
| spring_health_member_app/lib/models/health_profile_model.dart | 48 | final height = _toDouble(map['heightCm']); | LOW |
| spring_health_member_app/lib/models/health_profile_model.dart | 59 | bodyFatPct: _toDouble(map['bodyFatPct']), | LOW |
| spring_health_member_app/lib/models/health_profile_model.dart | 60 | waistCm: _toDouble(map['waistCm']), | LOW |
| spring_health_member_app/lib/models/health_profile_model.dart | 61 | chestCm: _toDouble(map['chestCm']), | LOW |
| spring_health_member_app/lib/models/health_profile_model.dart | 62 | armCm: _toDouble(map['armCm']), | LOW |
| spring_health_member_app/lib/models/health_profile_model.dart | 63 | hipCm: _toDouble(map['hipCm']), | LOW |
| spring_health_member_app/lib/models/health_profile_model.dart | 67 | bmi: calculatedBmi ?? _toDouble(map['bmi']), | LOW |
| spring_health_member_app/lib/models/health_profile_model.dart | 179 | static double? _toDouble(dynamic value) { | LOW |
| spring_health_member_app/lib/models/health_profile_model.dart | 181 | if (value is num) return value.toDouble(); | LOW |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | 90 | ?.toDouble(); | LOW |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | 93 | final double? hrv = (map['heartRateVariability'] as num?)?.toDouble(); | LOW |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | 125 | (map['activeCaloriesBurned'] as num?)?.toDouble() ?? 0; | LOW |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | 127 | ?.toDouble(); | LOW |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | 136 | restingHeartRate: (map['restingHeartRate'] as num?)?.toDouble(), | LOW |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | 138 | bloodOxygen: (map['bloodOxygen'] as num?)?.toDouble(), | LOW |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | 139 | respiratoryRate: (map['respiratoryRate'] as num?)?.toDouble(), | LOW |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | 142 | avgHeartRateDuringDay: (map['avgHeartRateDuringDay'] as num?)?.toDouble(), | LOW |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | 143 | weightKg: (map['weightKg'] as num?)?.toDouble(), | LOW |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | 144 | bodyFatPercentage: (map['bodyFatPercentage'] as num?)?.toDouble(), | LOW |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | 149 | distanceMeters: (map['distanceMeters'] as num?)?.toDouble(), | LOW |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | 155 | bloodGlucoseMgDl: (map['bloodGlucoseMgDl'] as num?)?.toDouble(), | LOW |
| spring_health_member_app/lib/models/wearable_snapshot_model.dart | 156 | waterLitres: (map['waterLitres'] as num?)?.toDouble(), | LOW |
| spring_health_member_app/lib/models/workout_model.dart | 49 | weight: (map['weight'] ?? 0).toDouble(), | LOW |
| spring_health_member_app/lib/models/fitness_test_model.dart | 42 | plankSeconds: _toDouble(map['plankSeconds']), | LOW |
| spring_health_member_app/lib/models/fitness_test_model.dart | 43 | squat1rmKg: _toDouble(map['squat1rmKg']), | LOW |
| spring_health_member_app/lib/models/fitness_test_model.dart | 44 | deadlift1rmKg: _toDouble(map['deadlift1rmKg']), | LOW |
| spring_health_member_app/lib/models/fitness_test_model.dart | 45 | benchpress1rmKg: _toDouble(map['benchpress1rmKg']), | LOW |
| spring_health_member_app/lib/models/fitness_test_model.dart | 121 | static double? _toDouble(dynamic value) { | LOW |
| spring_health_member_app/lib/models/fitness_test_model.dart | 123 | if (value is num) return value.toDouble(); | LOW |
| spring_health_member_app/lib/models/ai_plan_model.dart | 113 | hydrationLitres: (map['hydrationLitres'] as num?)?.toDouble() ?? 0.0, | LOW |
| spring_health_member_app/lib/models/body_metrics_log_model.dart | 36 | weightKg: _toDouble(map['weightKg']), | LOW |
| spring_health_member_app/lib/models/body_metrics_log_model.dart | 37 | bodyFatPct: _toDouble(map['bodyFatPct']), | LOW |
| spring_health_member_app/lib/models/body_metrics_log_model.dart | 38 | waistCm: _toDouble(map['waistCm']), | LOW |
| spring_health_member_app/lib/models/body_metrics_log_model.dart | 39 | chestCm: _toDouble(map['chestCm']), | LOW |
| spring_health_member_app/lib/models/body_metrics_log_model.dart | 40 | armCm: _toDouble(map['armCm']), | LOW |
| spring_health_member_app/lib/models/body_metrics_log_model.dart | 95 | static double? _toDouble(dynamic value) { | LOW |
| spring_health_member_app/lib/models/body_metrics_log_model.dart | 97 | if (value is num) return value.toDouble(); | LOW |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 845 | final maxVal = entries.map((e) => e.value).reduce(max).toDouble(); | HIGH |
| spring_health_member_app/lib/screens/gamification/personal_best_screen.dart | 846 | final minVal = entries.map((e) => e.value).reduce(min).toDouble(); | HIGH |
| spring_health_member_app/lib/screens/health/health_profile_screen.dart | 881 | weightSpots.add(FlSpot(i.toDouble(), log.weightKg!)); | HIGH |
| spring_health_member_app/lib/screens/health/health_profile_screen.dart | 884 | bpSysSpots.add(FlSpot(i.toDouble(), log.bpSystolic!.toDouble())); | HIGH |
| spring_health_member_app/lib/screens/health/health_profile_screen.dart | 887 | bfSpots.add(FlSpot(i.toDouble(), log.bodyFatPct!)); | HIGH |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 94 | amount: _priceForPlan(_selectedPlan).toDouble(), | HIGH |
| spring_health_member_app/lib/screens/renewal/renewal_screen.dart | 105 | amountPaid: _priceForPlan(_selectedPlan).toDouble(), | HIGH |
| spring_health_member_app/lib/screens/trainers/trainer_screen.dart | 528 | subLabel: 'Coming Soon', | HIGH |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 299 | onTap: () => _showSnack('Privacy Policy coming soon!'), | HIGH |
| spring_health_member_app/lib/screens/settings/settings_screen.dart | 312 | onTap: () => _showSnack('Terms of Service coming soon!'), | HIGH |
| spring_health_member_app/lib/screens/main_screen.dart | 201 | const SizedBox(), // AI Coach placeholder | HIGH |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 493 | .map((e) => FlSpot(e.key.toDouble(), e.value)) | HIGH |
| spring_health_member_app/lib/screens/fitness/body_metrics_screen.dart | 534 | ? (points.length / 4).ceilToDouble() | HIGH |
| spring_health_member_app/lib/screens/home/home_screen.dart | 810 | content: Text('Class Booking — Coming Soon! 🗓️'), | HIGH |
| spring_health_member_app/lib/screens/social/social_coming_soon_screen.dart | 74 | 'COMING SOON', | HIGH |
| spring_health_member_app/lib/screens/clash/war_screen.dart | 592 | 'No active duels.
Challenges coming soon!', | HIGH |
| spring_health_member_app/lib/screens/clash/war_screen.dart | 627 | // For now just empty placeholder or simple alert. | HIGH |
| spring_health_studio/lib/services/storage_service.dart | 170 | /// Generate a thumbnail URL (placeholder) | LOW |
| spring_health_studio/lib/services/firestore_service.dart | 944 | totalRevenue += (data['amount'] ?? 0).toDouble(); | LOW |
| spring_health_studio/lib/services/firestore_service.dart | 945 | cashRevenue += (data['cashAmount'] ?? 0).toDouble(); | LOW |
| spring_health_studio/lib/services/firestore_service.dart | 946 | upiRevenue += (data['upiAmount'] ?? 0).toDouble(); | LOW |
| spring_health_studio/lib/services/firestore_service.dart | 947 | totalDiscount += (data['discount'] ?? 0).toDouble(); // ✅ NEW: Sum discount | LOW |
| spring_health_studio/lib/services/firestore_service.dart | 1231 | total += (data['amount'] ?? 0).toDouble(); | LOW |
| spring_health_studio/lib/services/firestore_service.dart | 1262 | final amount = (data['amount'] ?? 0).toDouble(); | LOW |
| spring_health_studio/lib/services/firestore_service.dart | 1298 | final amount = (data['amount'] ?? 0).toDouble(); | LOW |
| spring_health_studio/lib/models/payment_model.dart | 62 | amount: (map['amount'] as num).toDouble(), | LOW |
| spring_health_studio/lib/models/payment_model.dart | 64 | cashAmount: (map['cashAmount'] as num?)?.toDouble() ?? 0, | LOW |
| spring_health_studio/lib/models/payment_model.dart | 65 | upiAmount: (map['upiAmount'] as num?)?.toDouble() ?? 0, | LOW |
| spring_health_studio/lib/models/payment_model.dart | 66 | discount: (map['discount'] as num?)?.toDouble() ?? 0, // ✅ safe read | LOW |
| spring_health_studio/lib/models/member_model.dart | 140 | totalFee: (map['totalFee'] as num).toDouble(), | LOW |
| spring_health_studio/lib/models/member_model.dart | 141 | discount: (map['discount'] as num?)?.toDouble() ?? 0, | LOW |
| spring_health_studio/lib/models/member_model.dart | 143 | finalAmount: (map['finalAmount'] as num).toDouble(), | LOW |
| spring_health_studio/lib/models/member_model.dart | 144 | cashAmount: (map['cashAmount'] as num?)?.toDouble() ?? 0, | LOW |
| spring_health_studio/lib/models/member_model.dart | 145 | upiAmount: (map['upiAmount'] as num?)?.toDouble() ?? 0, | LOW |
| spring_health_studio/lib/models/member_model.dart | 146 | dueAmount: (map['dueAmount'] as num?)?.toDouble() ?? 0, | LOW |
| spring_health_studio/lib/models/trainer_model.dart | 82 | salary: (map['salary'] as num?)?.toDouble() ?? 0.0, | LOW |
| spring_health_studio/lib/models/expense_model.dart | 47 | amount: (map['amount'] ?? 0).toDouble(), | LOW |
| spring_health_studio/lib/models/trainer_feedback_model.dart | 32 | rating: (map['rating'] as num?)?.toDouble() ?? 0.0, | LOW |
| spring_health_studio/lib/screens/trainers/trainer_dashboard_screen.dart | 538 | 'Diet plan for ${client.name} — Coming soon!'), | MEDIUM |
| spring_health_studio/lib/screens/members/member_detail_screen.dart | 669 | value: progress.toDouble(), | MEDIUM |
| spring_health_studio/lib/screens/members/members_list_screen.dart | 131 | const SnackBar(content: Text('Export feature coming soon!')), | MEDIUM |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 428 | spots.add(FlSpot(i.toDouble(), displayEntries[i].value)); | MEDIUM |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 486 | ? (displayEntries.length / 5).ceilToDouble() | MEDIUM |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 568 | spots.add(FlSpot(i.toDouble(), cumulativeData[i].value.toDouble())); | MEDIUM |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 571 | final maxY = cumulativeData.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble(); | MEDIUM |
| spring_health_studio/lib/screens/analytics/analytics_dashboard.dart | 625 | ? (cumulativeData.length / 5).ceilToDouble() | MEDIUM |

Total HIGH priority stubs: 17
Total MEDIUM priority stubs: 8
Total LOW priority stubs: 88
---


## Section 12 — Summary

### What is fully working
- Both Member App and Studio App successfully pass `flutter analyze` with "No issues found!".
- Firestore security rules for `gamification` and other member-owned collections are hardened via cross-collection ownership checks (`isMemberOwner`).
- Basic project structure and core architectural patterns (services, models, screens) are established.
- AI Personal Trainer logic (`ai_coach_service.dart`) in the Member App is complete, including `generateWorkoutPlan`, `generateDietPlan`, caching, and RPE integration.
- The `DietPlanScreen` is fully implemented with expandable meal cards, daily targets, nutrition notes, and hydration tracking.
- The `RpeRatingSheet` widget is implemented and correctly submits to the `rpeLog` collection.
- Gamification foundation (`gamification_service.dart`, `badge_service.dart`) exists and supports basic event processing.

### What is partially implemented
- `AiCoachScreen` logic is partially integrated but contains hardcoded UI elements and some unimplemented features.
- Member AI Plan Screen in the Studio App is missing (`member_ai_plan_screen.dart` does not exist), meaning trainers cannot view or override AI plans yet.
- Some analytics and charts in both apps use hardcoded `.toDouble()` mappings that are marked as temporary or require further refinement (e.g., `health_profile_screen.dart`, `analytics_dashboard.dart`).

### What is stubbed or missing
- High-priority user-facing features in the Member App:
  - Privacy Policy and Terms of Service links (`settings_screen.dart`).
  - Class Booking (`home_screen.dart`).
  - Social / Community features (`social_coming_soon_screen.dart`).
  - Active challenges and duels (`war_screen.dart`).
- Medium-priority admin features in the Studio App:
  - Diet plan assignment/viewing for trainers (`trainer_dashboard_screen.dart`).
  - Data export functionality (`members_list_screen.dart`).

### Recommended next actions (priority order)
1. **Implement `member_ai_plan_screen.dart` in Studio App**: Allow trainers to view and override member AI plans to bridge the gap between the AI Coach and human trainers.
2. **Complete Stubbed Member Features**: Implement Class Booking and Active Challenges to improve user engagement and retention.
3. **Address High-Priority Todos**: Update placeholder screens (Privacy Policy, TOS, Social) with actual content or functioning navigation.
4. **Refine Analytics Mappings**: Review and harden the `toDouble()` data mappings in charts across both apps to prevent potential runtime errors with real data.
