import 'package:fitness/view/social/comments/comment_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_auth/firebase_auth.dart';

class SinglePostCardWidget extends StatefulWidget {
  final Map<String, dynamic> wObj;
  final String postId;

  const SinglePostCardWidget({
    Key? key,
    required this.wObj,
    required this.postId,
  }) : super(key: key);

  @override
  _SinglePostCardWidgetState createState() => _SinglePostCardWidgetState();
}

class _SinglePostCardWidgetState extends State<SinglePostCardWidget> {
  bool _isLiked = false;
  int _totalLikes = 0;
  @override
  void initState() {
    super.initState();
    _totalLikes = widget.wObj['totalLikes'] ?? 0;
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();
      if (snapshot.exists) {
        List likes = snapshot['likes'] ?? [];
        setState(() {
          _isLiked = likes.contains(user.uid);
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(postRef);
        if (!snapshot.exists) {
          throw Exception("Post does not exist!");
        }

        List likes = snapshot['likes'] ?? [];
        int totalLikes = snapshot['totalLikes'] ?? 0;

        if (_isLiked) {
          likes.remove(user.uid);
          totalLikes--;
        } else {
          likes.add(user.uid);
          totalLikes++;
        }

        transaction.update(postRef, {
          'likes': likes,
          'totalLikes': totalLikes,
        });

        setState(() {
          _isLiked = !_isLiked;
          _totalLikes = totalLikes;
        });
      });
    }
  }

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
                .doc(widget.wObj['creatorUid'])
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
                        '${widget.wObj['createAt'] != null ? timeago.format(widget.wObj['createAt'].toDate()) : ""}',
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
            onDoubleTap: _toggleLike,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.30,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.wObj['postImageUrl'] ?? ''),
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
              GestureDetector(
                onTap: _toggleLike,
                child: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.black,
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CommentPage(post: widget.wObj, postId: widget.postId),
                    ),
                  );
                },
                child: Icon(Icons.message),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '${widget.wObj['totalLikes'] ?? 0} likes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            '${widget.wObj['description'] ?? ''}',
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CommentPage(post: widget.wObj, postId: widget.postId),
                ),
              );
            },
            child: Text(
              'View all ${widget.wObj['totalComments'] ?? 0} comments',
            ),
          ),
        ],
      ),
    );
  }
}
