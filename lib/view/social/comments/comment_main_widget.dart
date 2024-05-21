import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentMainWidget extends StatefulWidget {
  final Map<String, dynamic> post;
  final String postId;

  const CommentMainWidget({
    Key? key,
    required this.post,
    required this.postId,
  }) : super(key: key);

  @override
  State<CommentMainWidget> createState() => _CommentMainWidgetState();
}

class _CommentMainWidgetState extends State<CommentMainWidget> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
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
          "Comments",
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
                      .doc(widget.post['creatorUid'])
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
                  "${widget.post['description']}",
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
                    var commentData = snapshot.data?.docs[index].data();
                    String idUser = commentData?['username'] ??
                        ''; // Lấy iduser từ dữ liệu comment

                    // Thực hiện truy vấn để lấy thông tin của người dùng từ collection 'user-info'
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
                        if (commentData?['username'] ==
                            widget.post['creatorUid']) {
                          authorLabel = 'Author';
                        }
                        // Hiển thị ListTile với thông tin của bình luận và người dùng
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
                                          commentData?['description'] ?? '',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Xử lý khi người dùng nhấn vào biểu tượng "like"
                                      // Thực hiện các hành động liên quan đến like bình luận
                                    },
                                    child: Icon(Icons.thumb_up),
                                  ),
                                  SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      // Xử lý khi người dùng nhấn vào biểu tượng "reply"
                                      // Thực hiện các hành động liên quan đến reply bình luận
                                    },
                                    child: Icon(Icons.reply),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(userData?['Avatar'] ?? ''),
                          ),
                          subtitle: Text(
                            commentData?['createAt'] != null
                                ? timeago
                                    .format(commentData?['createAt']!.toDate())
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
                controller: _descriptionController,
                style: TextStyle(color: AppColors.blackColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Post your comment...",
                  hintStyle: TextStyle(color: AppColors.grayColor),
                ),
              ),
            ),
            GestureDetector(
              onTap: _createComment,
              child: Icon(
                Icons.send,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createComment() {
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Thêm bình luận vào collection 'comments' của bài viết
    FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'description': _descriptionController.text,
      'createAt': Timestamp.now(),
      'totalReplays': 0,
      'likes': [],
      'username': currentUser?.uid,
    }).then((_) {
      // Sau khi thêm bình luận thành công, cập nhật số lượng bình luận trong tài liệu 'post'
      FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .get()
          .then((comments) {
        // Đếm số lượng bình luận
        int totalComments = comments.docs.length;

        // Cập nhật giá trị totalComments trong tài liệu post
        FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .update({'totalComments': totalComments}).then((_) {
          // Xóa nội dung trong ô nhập bình luận sau khi đã thêm bình luận thành công và cập nhật totalComments
          _descriptionController.clear();
        }).catchError((error) {
          print('Error updating post document: $error');
        });
      }).catchError((error) {
        print('Error getting comments: $error');
      });
    }).catchError((error) {
      print('Error adding comment: $error');
    });
  }
}
