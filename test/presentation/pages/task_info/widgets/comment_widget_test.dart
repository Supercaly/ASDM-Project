import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasky/application/bloc/auth_bloc.dart';
import 'package:tasky/core/ilist.dart';
import 'package:tasky/core/maybe.dart';
import 'package:tasky/domain/entities/comment.dart';
import 'package:tasky/domain/entities/user.dart';
import 'package:tasky/domain/values/task_values.dart';
import 'package:tasky/domain/values/unique_id.dart';
import 'package:tasky/domain/values/user_values.dart';
import 'package:tasky/presentation/pages/task_info/widgets/comment_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../mocks/mock_auth_bloc.dart';
import '../../../../widget_tester_extension.dart';

void main() async {
  EasyLocalization.logger.enableBuildModes = [];
  await EasyLocalization.ensureInitialized();

  group("LikeButton test", () {
    testWidgets("create button successfully", (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LikeButton(
              value: 123,
              icon: Icons.thumb_up,
              selected: false,
              onPressed: () => null,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      expect(find.text("123"), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LikeButton(
              value: 456,
              icon: Icons.thumb_down,
              selected: true,
              onPressed: () => null,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.thumb_down), findsOneWidget);
      expect(find.text("456"), findsOneWidget);
    });

    testWidgets("selecting button calls callback", (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LikeButton(
              value: 123,
              icon: Icons.thumb_up,
              selected: false,
              onPressed: () => pressed = !pressed,
            ),
          ),
        ),
      );

      expect(pressed, isFalse);
      await tester.tap(find.byIcon(Icons.thumb_up));
      expect(pressed, isTrue);
      await tester.tap(find.byIcon(Icons.thumb_up));
      expect(pressed, isFalse);
    });

    test("create with null parameters throws an exception", () {
      try {
        LikeButton(
          value: 123,
        );
        fail("This should throw an exception");
      } catch (e) {
        expect(e, isA<AssertionError>());
      }

      try {
        LikeButton(
          icon: Icons.thumb_down,
        );
        fail("This should throw an exception");
      } catch (e) {
        expect(e, isA<AssertionError>());
      }

      expect(LikeButton(icon: Icons.thumb_down, value: 123).selected, isFalse);
    });
  });

  group("AddCommentWidget test", () {
    testWidgets("create new comment with success", (tester) async {
      bool commentSent = false;
      CommentContent contentSent;

      await tester.pumpLocalizedWidget(
        AddCommentWidget(
          onNewComment: (comment) {
            commentSent = true;
            contentSent = comment;
          },
        ),
      );

      await tester.tap(find.byIcon(FeatherIcons.send));
      await tester.pumpAndSettle();
      expect(commentSent, isFalse);
      expect(contentSent, isNull);

      await tester.enterText(find.byType(TextField).first, "Mock Comment");
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FeatherIcons.send));
      await tester.pumpAndSettle();
      expect(commentSent, isTrue);
      expect(contentSent, equals(CommentContent("Mock Comment")));
    });
  });

  group("CommentWidget test", () {
    AuthBloc authBloc;

    setUpAll(() {
      authBloc = MockAuthBloc();
    });

    tearDownAll(() {
      authBloc.close();
      authBloc = null;
    });

    testWidgets("show comment of another user", (tester) async {
      when(authBloc)
          .calls(#state)
          .thenReturn(AuthState.initial(Maybe.nothing()));
      await tester.pumpLocalizedWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: CommentWidget(
            comment: Comment.test(
              id: UniqueId("comment_id"),
              content: CommentContent("Mock comment content"),
              author: User.test(
                id: UniqueId("user_id"),
                name: UserName("User 1"),
                email: EmailAddress("user@mock.com"),
              ),
              likes: IList.empty(),
              dislikes: IList.empty(),
              creationDate: CreationDate(DateTime.now()),
            ),
          ),
        ),
      );

      expect(find.text("Mock comment content"), findsOneWidget);
      expect(find.text("User 1"), findsOneWidget);
      expect(find.text("0"), findsNWidgets(2));
      expect(find.byIcon(Icons.more_vert), findsNothing);
    });

    testWidgets("show comment of this user", (tester) async {
      when(authBloc).calls(#state).thenReturn(AuthState.authenticated(
            Maybe.just(
              User.test(
                id: UniqueId("user_id"),
                name: UserName("User 1"),
                email: EmailAddress("user@mock.com"),
              ),
            ),
          ));
      await tester.pumpLocalizedWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: CommentWidget(
            comment: Comment.test(
              id: UniqueId("comment_id"),
              content: CommentContent("Mock comment content"),
              author: User.test(
                id: UniqueId("user_id"),
                name: UserName("User 1"),
                email: EmailAddress("user@mock.com"),
              ),
              likes: IList.empty(),
              dislikes: IList.empty(),
              creationDate: CreationDate(DateTime.now()),
            ),
          ),
        ),
      );

      expect(find.text("Mock comment content"), findsOneWidget);
      expect(find.text("User 1"), findsOneWidget);
      expect(find.text("0"), findsNWidgets(2));
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets("edit comment", (tester) async {
      CommentContent editedComment;
      when(authBloc).calls(#state).thenReturn(AuthState.authenticated(
            Maybe.just(
              User.test(
                id: UniqueId("user_id"),
                name: UserName("User 1"),
                email: EmailAddress("user@mock.com"),
              ),
            ),
          ));

      await tester.pumpLocalizedWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: CommentWidget(
            comment: Comment.test(
              id: UniqueId("comment_id"),
              content: CommentContent("Mock comment content"),
              author: User.test(
                id: UniqueId("user_id"),
                name: UserName("User 1"),
                email: EmailAddress("user@mock.com"),
              ),
              likes: IList.empty(),
              dislikes: IList.empty(),
              creationDate: CreationDate(DateTime.now()),
            ),
            onEdit: (comment) => editedComment = comment,
          ),
        ),
      );

      // Find initial state
      expect(find.text("Mock comment content"), findsOneWidget);
      expect(find.text("User 1"), findsOneWidget);
      expect(find.text("0"), findsNWidgets(2));
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      // Press more icon opens the menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text("Edit"), findsOneWidget);
      expect(find.text("Delete"), findsOneWidget);

      // Press on edit button
      await tester.tap(find.text("Edit"));
      await tester.pumpAndSettle();

      // The content widget changes
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(FeatherIcons.send), findsOneWidget);

      // Edit comment
      await tester.enterText(
        find.byType(TextField).first,
        "Mock comment content edited",
      );
      await tester.pumpAndSettle();
      expect(editedComment, isNull);
      await tester.tap(find.byIcon(FeatherIcons.send));
      await tester.pumpAndSettle();

      // Comment is updated
      expect(editedComment.value.getOrNull(),
          equals("Mock comment content edited"));
    });

    testWidgets("delete comment", (tester) async {
      bool deleteComment = false;
      when(authBloc).calls(#state).thenReturn(AuthState.authenticated(
            Maybe.just(
              User.test(
                id: UniqueId("user_id"),
                name: UserName("User 1"),
                email: EmailAddress("user@mock.com"),
              ),
            ),
          ));

      await tester.pumpLocalizedWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: CommentWidget(
            comment: Comment.test(
              id: UniqueId("comment_id"),
              content: CommentContent("Mock comment content"),
              author: User.test(
                id: UniqueId("user_id"),
                name: UserName("User 1"),
                email: EmailAddress("user@mock.com"),
              ),
              likes: IList.empty(),
              dislikes: IList.empty(),
              creationDate: CreationDate(DateTime.now()),
            ),
            onDelete: () => deleteComment = true,
          ),
        ),
      );

      // Find initial state
      expect(find.text("Mock comment content"), findsOneWidget);
      expect(find.text("User 1"), findsOneWidget);
      expect(find.text("0"), findsNWidgets(2));
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      // Press more icon opens the menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text("Edit"), findsOneWidget);
      expect(find.text("Delete"), findsOneWidget);

      // Press on edit button
      expect(deleteComment, isFalse);
      await tester.tap(find.text("Delete"));
      await tester.pumpAndSettle();

      // Comment is deleted
      expect(deleteComment, isTrue);
    });

    testWidgets("like comment", (tester) async {
      bool commentLiked = false;
      bool commentDisliked = false;

      await tester.pumpLocalizedWidget(
        BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: CommentWidget(
            comment: Comment.test(
              id: UniqueId("comment_id"),
              content: CommentContent("Mock comment content"),
              author: User.test(
                id: UniqueId("user_id"),
                name: UserName("User 1"),
                email: EmailAddress("user@mock.com"),
              ),
              likes: IList.empty(),
              dislikes: IList.empty(),
              creationDate: CreationDate(DateTime.now()),
            ),
            onLike: () {
              commentLiked = true;
              commentDisliked = false;
            },
            onDislike: () {
              commentLiked = false;
              commentDisliked = true;
            },
          ),
        ),
      );

      // Find initial state
      expect(find.text("Mock comment content"), findsOneWidget);
      expect(find.text("User 1"), findsOneWidget);
      expect(find.text("0"), findsNWidgets(2));
      expect(commentLiked, isFalse);
      expect(commentDisliked, isFalse);

      // Press like button
      await tester.tap(find.byIcon(FeatherIcons.thumbsUp));
      await tester.pumpAndSettle();
      expect(commentLiked, isTrue);
      expect(commentDisliked, isFalse);

      // Press like button
      await tester.tap(find.byIcon(FeatherIcons.thumbsDown));
      await tester.pumpAndSettle();
      expect(commentLiked, isFalse);
      expect(commentDisliked, isTrue);
    });
  });
}
