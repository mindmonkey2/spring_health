import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spring_health_member/models/post_model.dart';
import 'package:spring_health_member/screens/social/member_wall_screen.dart';
import 'package:spring_health_member/services/social_service.dart';

@GenerateNiceMocks([MockSpec<SocialService>()])
import 'member_wall_screen_test.mocks.dart';

// Since we can't easily mock FirebaseFirestore directly in the widget test
// without extensive setup, we will override the Firebase initialization or
// rely on the error state to verify the stream renders.
// For the profile header, since it calls FirebaseFirestore.instance, we can
// either inject a member or just let it fail gracefully and check the stream.

void main() {
  late MockSocialService mockSocialService;

  setUp(() {
    mockSocialService = MockSocialService();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MemberWallScreen(
        memberId: 'target-123',
        currentMemberId: 'current-456',
        socialServiceOverride: mockSocialService,
      ),
    );
  }

  testWidgets('MemberWallScreen renders loading state initially', (tester) async {
    final streamController = StreamController<List<PostModel>>();
    when(mockSocialService.streamMemberPosts('target-123')).thenAnswer((_) => streamController.stream);

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsWidgets);

    streamController.close();
  });

  testWidgets('MemberWallScreen renders empty wall state when no posts exist', (tester) async {
    final streamController = StreamController<List<PostModel>>();
    when(mockSocialService.streamMemberPosts('target-123')).thenAnswer((_) => streamController.stream);

    await tester.pumpWidget(createWidgetUnderTest());
    streamController.add([]);
    await tester.pumpAndSettle();

    expect(find.text('No posts yet.'), findsOneWidget);

    streamController.close();
  });

  testWidgets('MemberWallScreen renders streamed posts', (tester) async {
    final streamController = StreamController<List<PostModel>>();
    when(mockSocialService.streamMemberPosts('target-123')).thenAnswer((_) => streamController.stream);

    await tester.pumpWidget(createWidgetUnderTest());
    streamController.add([
      PostModel(
        id: 'post-1',
        memberAuthUid: 'auth-123',
        memberId: 'target-123',
        memberName: 'John Doe',
        branch: 'HQ',
        text: 'This is my post',
        tags: [],
        likeCount: 0,
        commentCount: 0,
        createdAt: Timestamp.now(),
        likedBy: [],
      ),
    ]);

    // Give time for stream and animations
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('This is my post'), findsOneWidget);
    expect(find.text('John Doe'), findsWidgets); // Header and post

    streamController.close();
  });
}
