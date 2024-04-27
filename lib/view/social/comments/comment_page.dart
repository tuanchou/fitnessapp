import 'package:fitness/view/social/comments/comment_main_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentPage extends StatelessWidget {
  final Map<String, dynamic> post;
  final String postId;

  const CommentPage({
    Key? key,
    required this.post,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommentMainWidget(post: post, postId: postId);
  }
}
