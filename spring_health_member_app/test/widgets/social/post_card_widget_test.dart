import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spring_health_member/models/post_model.dart';
import 'package:spring_health_member/widgets/social/post_card_widget.dart';

void main() {
  Widget createWidgetUnderTest({
    required PostModel post,
    required VoidCallback onTap,
    required VoidCallback onLikePressed,
    required VoidCallback onCommentPressed,
    required bool isLiked,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PostCardWidget(
          post: post,
          onTap: onTap,
          onLikePressed: onLikePressed,
          onCommentPressed: onCommentPressed,
          isLiked: isLiked,
        ),
      ),
    );
  }

  final defaultPost = PostModel(
    id: 'test_post_1',
    memberAuthUid: 'auth123',
    memberId: 'member123',
    memberName: 'John Doe',
    branch: 'Downtown',
    text: 'Just had a great workout!',
    tags: ['fitness', 'workout'],
    likeCount: 5,
    commentCount: 2,
    createdAt: Timestamp.now(),
  );

  testWidgets('1. Renders memberName, branch, text, likeCount, commentCount', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      post: defaultPost,
      onTap: () {},
      onLikePressed: () {},
      onCommentPressed: () {},
      isLiked: false,
    ));

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Downtown'), findsOneWidget);
    expect(find.text('Just had a great workout!'), findsOneWidget);
    expect(find.text('5'), findsOneWidget); // like count
    expect(find.text('2'), findsOneWidget); // comment count
  });

  testWidgets('2. Like button callback fires on tap', (WidgetTester tester) async {
    bool likePressed = false;
    await tester.pumpWidget(createWidgetUnderTest(
      post: defaultPost,
      onTap: () {},
      onLikePressed: () {
        likePressed = true;
      },
      onCommentPressed: () {},
      isLiked: false,
    ));

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    expect(likePressed, isTrue);
  });

  testWidgets('3. Comment button callback fires on tap', (WidgetTester tester) async {
    bool commentPressed = false;
    await tester.pumpWidget(createWidgetUnderTest(
      post: defaultPost,
      onTap: () {},
      onLikePressed: () {},
      onCommentPressed: () {
        commentPressed = true;
      },
      isLiked: false,
    ));

    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pump();

    expect(commentPressed, isTrue);
  });

  testWidgets('4. isLiked changes button appearance', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      post: defaultPost,
      onTap: () {},
      onLikePressed: () {},
      onCommentPressed: () {},
      isLiked: true,
    ));

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);

    await tester.pumpWidget(createWidgetUnderTest(
      post: defaultPost,
      onTap: () {},
      onLikePressed: () {},
      onCommentPressed: () {},
      isLiked: false,
    ));

    expect(find.byIcon(Icons.favorite), findsNothing);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('5. mediaUrl present shows a preview container', (WidgetTester tester) async {
    final postWithMedia = PostModel(
      id: 'test_post_2',
      memberAuthUid: 'auth123',
      memberId: 'member123',
      memberName: 'Jane Doe',
      branch: 'Uptown',
      text: 'Check out my new PR!',
      mediaUrl: 'https://example.com/image.jpg',
      tags: [],
      likeCount: 10,
      commentCount: 4,
      createdAt: Timestamp.now(),
    );

    // Disable network image loading for tests
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest(
        post: postWithMedia,
        onTap: () {},
        onLikePressed: () {},
        onCommentPressed: () {},
        isLiked: false,
      ));
    });

    // When we can't load the real image in tests, Image.network will often
    // trigger errorBuilder (if we have no mocked HTTP client), or we just
    // look for Image widget itself.
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('6. Widget can render with minimal required fields without crashing', (WidgetTester tester) async {
    final minimalPost = PostModel(
      id: 'min_post',
      memberAuthUid: '',
      memberId: '',
      memberName: 'Minimal',
      branch: '',
      text: 'Min Text',
      tags: [],
      likeCount: 0,
      commentCount: 0,
      createdAt: Timestamp(0, 0),
    );

    await tester.pumpWidget(createWidgetUnderTest(
      post: minimalPost,
      onTap: () {},
      onLikePressed: () {},
      onCommentPressed: () {},
      isLiked: false,
    ));

    expect(find.text('Minimal'), findsOneWidget);
    expect(find.text('Min Text'), findsOneWidget);
  });
}