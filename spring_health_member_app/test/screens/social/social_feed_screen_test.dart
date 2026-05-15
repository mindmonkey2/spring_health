import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_member/screens/social/social_feed_screen.dart';
import 'package:spring_health_member/models/post_model.dart';
import 'package:spring_health_member/services/social_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FakeSocialService implements SocialService {
  final StreamController<List<PostModel>> branchFeedController = StreamController<List<PostModel>>.broadcast();
  final StreamController<List<PostModel>> globalFeedController = StreamController<List<PostModel>>.broadcast();

  @override
  Stream<List<PostModel>> streamFeedByBranch(String branch, {int limit = 20}) => branchFeedController.stream;

  @override
  Stream<List<PostModel>> streamGlobalFeed({int limit = 20}) => globalFeedController.stream;

  @override
  Future<bool> isLikedBy(String postId, String memberAuthUid) async => false;

  @override
  Future<void> toggleLike(String postId, String memberAuthUid) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeSocialService fakeService;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    Animate.restartOnHotReload = false;
  });

  setUp(() {
    fakeService = FakeSocialService();
  });

  tearDown(() {
    fakeService.branchFeedController.close();
    fakeService.globalFeedController.close();
  });

  Widget createTestWidget() {
    return MaterialApp(
      routes: {
        '/social/create': (context) => const Scaffold(body: Text('Create Post Route')),
      },
      home: SocialFeedScreen(
        memberId: 'member123',
        memberAuthUid: 'auth123',
        memberName: 'Test Member',
        branch: 'Branch A',
        socialServiceOverride: fakeService,
      ),
    );
  }

  testWidgets('Shows loading indicator while stream is pending', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Shows No posts yet when stream emits empty list', (tester) async {
    await tester.pumpWidget(createTestWidget());
    fakeService.branchFeedController.add([]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('No posts yet. Be the first!'), findsOneWidget);
  });

  testWidgets('Shows post card when stream emits one post', (tester) async {
    await tester.pumpWidget(createTestWidget());

    final post = PostModel(
      id: 'post1',
      memberId: 'member123',
      memberAuthUid: 'auth123',
      memberName: 'Test Member',
      branch: 'Branch A',
      text: 'Hello World',
      tags: [],
      likeCount: 0,
      commentCount: 0,
      createdAt: Timestamp.now(),
    );

    fakeService.branchFeedController.add([post]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Hello World'), findsOneWidget);
    expect(find.text('Test Member'), findsOneWidget);
  });

  testWidgets('FAB is present and tappable', (tester) async {
    await tester.pumpWidget(createTestWidget());
    fakeService.branchFeedController.add([]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);

    await tester.tap(fab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Create Post Route'), findsOneWidget);
  });

  testWidgets('Branch/Global toggle switches stream source', (tester) async {
    await tester.pumpWidget(createTestWidget());

    final localPost = PostModel(
      id: 'post1',
      memberId: 'member123',
      memberAuthUid: 'auth123',
      memberName: 'Test Member',
      branch: 'Branch A',
      text: 'Local Post',
      tags: [],
      likeCount: 0,
      commentCount: 0,
      createdAt: Timestamp.now(),
    );

    final globalPost = PostModel(
      id: 'post2',
      memberId: 'member456',
      memberAuthUid: 'auth456',
      memberName: 'Other Member',
      branch: 'Branch B',
      text: 'Global Post',
      tags: [],
      likeCount: 0,
      commentCount: 0,
      createdAt: Timestamp.now(),
    );

    await tester.pump();

    // emit branch data
    fakeService.branchFeedController.add([localPost]);
    await tester.pump();
    await tester.pump();
    expect(find.text('Local Post'), findsOneWidget);

    // tap toggle
    await tester.tap(find.byType(Switch));

    // pump cycles per instructions
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // emit global data
    fakeService.globalFeedController.add([localPost, globalPost]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Global Post'), findsOneWidget);
    expect(find.text('Local Post'), findsOneWidget);
  });
}
