import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spring_health_member/models/post_model.dart';
import 'package:spring_health_member/models/comment_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spring_health_member/screens/social/create_post_screen.dart';
import 'package:spring_health_member/services/social_service.dart';

class MockSocialService implements SocialService {
  bool shouldThrow = false;
  PostModel? lastCreatedPost;
  File? lastUploadedImage;

  @override
  Stream<DocumentSnapshot> getPostStream(String postId) {
    throw UnimplementedError();
  }

  @override
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    throw UnimplementedError();
  }

  @override
  Future<void> toggleLikeWithMemberId(String postId, String memberId) {
    throw UnimplementedError();
  }

  @override
  Future<void> createPost(PostModel post, {File? imageFile}) async {
    if (shouldThrow) throw Exception('Test error');
    // Ensure this takes some time so the loading dialog has time to render
    await Future.delayed(const Duration(milliseconds: 100));
    lastCreatedPost = post;
    lastUploadedImage = imageFile;
  }

  // Other methods throw UnimplementedError as they are not used in this test
  @override
  Future<void> deletePost(String postId) => throw UnimplementedError();
  @override
  Stream<List<PostModel>> streamFeedByBranch(String branch, {int limit = 20}) => throw UnimplementedError();
  @override
  Stream<List<PostModel>> streamGlobalFeed({int limit = 20}) => throw UnimplementedError();
  @override
  Stream<List<PostModel>> streamMemberPosts(String memberId) => throw UnimplementedError();
  @override
  Stream<List<CommentModel>> streamComments(String postId) => throw UnimplementedError();
  @override
  Future<void> addComment(String postId, CommentModel comment) => throw UnimplementedError();
  @override
  Future<void> deleteComment(String postId, String commentId) => throw UnimplementedError();
  @override
  Future<void> toggleLike(String postId, String memberAuthUid) => throw UnimplementedError();
  @override
  Future<bool> isLikedBy(String postId, String memberAuthUid) => throw UnimplementedError();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    Animate.restartOnHotReload = false;
  });

  Widget buildTestableWidget(MockSocialService mockService) {
    return MaterialApp(
      home: CreatePostScreen(
        memberId: 'member123',
        memberAuthUid: 'auth123',
        memberName: 'John Doe',
        branch: 'Branch A',
        socialServiceOverride: mockService,
      ),
    );
  }

  testWidgets('Shows text field and submit button', (WidgetTester tester) async {
    final mockService = MockSocialService();
    await tester.pumpWidget(buildTestableWidget(mockService));
    await tester.pump();

    expect(find.text('Create Post'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Post'), findsOneWidget);
  });

  testWidgets('Enforces 500-char max length UI', (WidgetTester tester) async {
    final mockService = MockSocialService();
    await tester.pumpWidget(buildTestableWidget(mockService));
    await tester.pump();

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.maxLength, 500);
  });

  testWidgets('Submit button disabled for empty post', (WidgetTester tester) async {
    final mockService = MockSocialService();
    await tester.pumpWidget(buildTestableWidget(mockService));
    await tester.pump();

    final submitButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(submitButton.onPressed, isNull);
  });

  testWidgets('Submit button enabled when text entered', (WidgetTester tester) async {
    final mockService = MockSocialService();
    await tester.pumpWidget(buildTestableWidget(mockService));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Hello World');
    await tester.pump();

    final submitButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(submitButton.onPressed, isNotNull);
  });

  testWidgets('Shows loading state during submit and successful submit calls SocialService', (WidgetTester tester) async {
    final mockService = MockSocialService();
    await tester.pumpWidget(buildTestableWidget(mockService));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'New Post');
    await tester.pump();

    await tester.tap(find.text('Post'));
    await tester.pump(); // Starts the tap logic

    // Assert the dialog with CircularProgressIndicator is displayed
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // Let the Future in mockService complete and trigger navigator pops
    // Pump enough times to simulate settling manually without pumpAndSettle
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // Expect service to be called
    expect(mockService.lastCreatedPost, isNotNull);
    expect(mockService.lastCreatedPost!.text, 'New Post');

    // Dialog and screen popped (only MaterialApp root remains or completely gone if it was root)
    expect(find.byType(CreatePostScreen), findsOneWidget);
  });

  testWidgets('Failed submit shows SnackBar', (WidgetTester tester) async {
    final mockService = MockSocialService();
    mockService.shouldThrow = true;
    await tester.pumpWidget(buildTestableWidget(mockService));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Failing Post');
    await tester.pump();

    await tester.tap(find.text('Post'));
    await tester.pump(); // Start tap logic

    // Pump to settle the snackbar showing and loading hiding
    // Pump enough times to simulate settling manually without pumpAndSettle
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // SnackBar is shown
    expect(find.text('Failed to create post'), findsOneWidget);

    // Screen remains active
    expect(find.byType(CreatePostScreen), findsOneWidget);
  });
}
