import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReplyCommentWidget extends StatefulWidget {
  final Map<String, dynamic>? commentData;
  final String? postId;
  final String? commentId;

  const ReplyCommentWidget(
      {Key? key, this.commentData, this.postId, this.commentId})
      : super(key: key);

  @override
  State<ReplyCommentWidget> createState() => _ReplyCommentWidgetState();
}

class _ReplyCommentWidgetState extends State<ReplyCommentWidget> {
  final TextEditingController _replyDescriptionController =
      TextEditingController();
  @override
  void dispose() {
    _replyDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Reply Comments",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị thông tin về bài viết
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('user-info')
                      .doc(widget.commentData?['username'])
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Placeholder widget while loading
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    var userData =
                        snapshot.data?.data() as Map<String, dynamic>?;
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
                            // Text(
                            //   '${timeago.format(wObj['createAt'].toDate())}',
                            //   style: TextStyle(
                            //     color: Colors.grey,
                            //     fontSize: 12,
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 10),
                Text(
                  "${widget.commentData?['description']}",
                  style: TextStyle(color: AppColors.blackColor),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Divider(color: AppColors.blackColor),
          SizedBox(height: 10),
          // Hiển thị danh sách các bình luận
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .doc(widget.commentId)
                  .collection('replies')
                  .orderBy('createAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Kiểm tra nếu danh sách bình luận trống
                if (snapshot.data?.docs.isEmpty ?? true) {
                  return Center(
                    child: Text(
                      'Be the first to comment on this post',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // Hiển thị danh sách bình luận
                return ListView.builder(
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (context, index) {
                    var replyData = snapshot.data?.docs[index].data();
                    String? replyId = snapshot.data?.docs[index].id;
                    String idUser = replyData?['username'] ?? '';
                    ''; // Lấy iduser từ dữ liệu comment

                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('user-info')
                          .doc(idUser)
                          .snapshots(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return ListTile(
                            title: Text('Loading...'),
                          );
                        }
                        if (userSnapshot.hasError) {
                          return ListTile(
                            title: Text('Error: ${userSnapshot.error}'),
                          );
                        }

                        // Lấy dữ liệu người dùng từ snapshot
                        var userData = userSnapshot.data?.data();
                        String authorLabel = '';

                        // Kiểm tra xem người tạo bài viết có trong danh sách người bình luận không
                        bool _isReplyLiked =
                            (replyData?['likes'] ?? []).contains(idUser);

                        return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${userData?['Name']} ${authorLabel.isNotEmpty ? '($authorLabel)' : ''}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: authorLabel.isNotEmpty
                                                ? Colors.blue
                                                : Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          replyData?['description'] ?? '',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Row(
                              //   children: [
                              //     GestureDetector(
                              //       onTap: () =>
                              //           _toggleCommentLike(replyId!, replyData),
                              //       child: Icon(
                              //         Icons.thumb_up,
                              //         color: _isReplyLiked
                              //             ? Colors.blue
                              //             : Colors.black,
                              //       ),
                              //     ),
                              //     SizedBox(width: 10),
                              //     GestureDetector(
                              //       onTap: () {},
                              //       child: Icon(Icons.reply),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(userData?['Avatar'] ?? ''),
                          ),
                          subtitle: Text(
                            replyData?['createAt'] != null
                                ? timeago
                                    .format(replyData?['createAt']!.toDate())
                                : "",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 10),
          _commentSection(),
        ],
      ),
    );
  }

  Widget _commentSection() {
    User? user = FirebaseAuth.instance.currentUser;
    return Container(
      width: double.infinity,
      height: 55,
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('user-info')
                  .doc(user?.uid)
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
                return Container(
                  width: 40,
                  height: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                        avatarUrl), // Sử dụng ảnh từ thông tin bài viết
                  ),
                );
              },
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _replyDescriptionController,
                style: TextStyle(color: AppColors.blackColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Post your comment...",
                  hintStyle: TextStyle(color: AppColors.grayColor),
                ),
              ),
            ),
            GestureDetector(
              onTap: _createReply,
              child: Icon(
                Icons.send,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createReply() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(widget.commentId)
        .collection('replies')
        .add({
      'description': _replyDescriptionController.text,
      'createAt': Timestamp.now(),
      'username': currentUser?.uid,
    }).then((_) {
      _replyDescriptionController.clear();
    }).catchError((error) {
      print('Error adding reply: $error');
    });
  }

  // void _createComment() {
  //   User? currentUser = FirebaseAuth.instance.currentUser;

  //   // Thêm bình luận vào collection 'comments' của bài viết
  //   FirebaseFirestore.instance
  //       .collection('posts')
  //       .doc(widget.postId)
  //       .collection('comments')
  //       .add({
  //     'description': _replyDescriptionController.text,
  //     'createAt': Timestamp.now(),
  //     'totalReplays': 0,
  //     'likes': [],
  //     'username': currentUser?.uid,
  //   }).then((_) {
  //     // Sau khi thêm bình luận thành công, cập nhật số lượng bình luận trong tài liệu 'post'
  //     FirebaseFirestore.instance
  //         .collection('posts')
  //         .doc(widget.postId)
  //         .collection('comments')
  //         .get()
  //         .then((comments) {
  //       // Đếm số lượng bình luận
  //       int totalComments = comments.docs.length;

  //       // Cập nhật giá trị totalComments trong tài liệu post
  //       FirebaseFirestore.instance
  //           .collection('posts')
  //           .doc(widget.postId)
  //           .update({'totalComments': totalComments}).then((_) {
  //         // Xóa nội dung trong ô nhập bình luận sau khi đã thêm bình luận thành công và cập nhật totalComments
  //         _replyDescriptionController.clear();
  //       }).catchError((error) {
  //         print('Error updating post document: $error');
  //       });
  //     }).catchError((error) {
  //       print('Error getting comments: $error');
  //     });
  //   }).catchError((error) {
  //     print('Error adding comment: $error');
  //   });
  // }

  void _toggleCommentLike(String commentId, Map<String, dynamic>? commentData) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || commentData == null) return;

    List<dynamic> likes = commentData['likes'] ?? [];
    if (likes.contains(currentUser.uid)) {
      likes.remove(currentUser.uid);
    } else {
      likes.add(currentUser.uid);
    }

    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId)
        .update({'likes': likes}).then((_) {
      setState(() {});
    }).catchError((error) {
      print('Error updating likes: $error');
    });
  }
}
