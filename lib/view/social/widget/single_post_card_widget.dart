import 'package:fitness/view/social/comments/comment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class SinglePostCardWidget extends StatelessWidget {
  final Map<String, dynamic> wObj;
  final String postId;
  const SinglePostCardWidget({
    Key? key,
    required this.wObj,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('user-info')
                .doc(wObj['creatorUid'])
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Placeholder widget while loading
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              var userData = snapshot.data?.data() as Map<String, dynamic>?;
              String avatarUrl = userData?['Avatar'] ?? '';
              String userName = userData?['Name'] ?? '';

              return Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(avatarUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${wObj['createAt'] != null ? timeago.format(wObj['createAt'].toDate()) : ""}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 10),
          GestureDetector(
            onDoubleTap: () {
              // Like functionality can be implemented here
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.30,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(wObj['postImageUrl'] ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Like animation can be added here if needed
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              // Like button can be implemented here
              Icon(
                Icons.favorite,
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  // Điều hướng tới trang bình luận và truyền thông tin về bài viết hiện tại
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CommentPage(post: wObj, postId: postId),
                    ),
                  );
                },
                child: Icon(Icons.message),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '${wObj['totalLikes'] ?? 0} likes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            '${wObj['description'] ?? ''}',
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              // Navigate to comments pagez
            },
            child: Text(
              'View all ${wObj['totalComments'] ?? 0} comments',
            ),
          ),
        ],
      ),
    );
  }
}
