import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:fitness/service/round_button.dart';
import 'package:fitness/service/round_gradient_button.dart';
import 'package:fitness/service/workout_row.dart';
import 'package:fitness/view/social/widget/upload_post_main_widget.dart';
import 'package:flutter/material.dart';

class Social extends StatefulWidget {
  const Social({Key? key}) : super(key: key);

  @override
  _SocialState createState() => _SocialState();
}

class _SocialState extends State<Social> {
  List<String> userPostImageUrls = [];
  Map<String, List<String>> imagesByMonth = {};

  @override
  void initState() {
    super.initState();
    _getUserPosts();
  }

  Future<void> _getUserPosts() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot userPostsSnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .where('creatorUid', isEqualTo: user.uid)
            .get();

        imagesByMonth = _classifyImagesByMonth(userPostsSnapshot);

        setState(() {});
      }
    } catch (e) {
      print('Error fetching user posts: $e');
    }
  }

  Map<String, List<String>> _classifyImagesByMonth(QuerySnapshot snapshot) {
    Map<String, List<String>> classifiedImages = {};

    snapshot.docs.forEach((postDoc) {
      Timestamp timestamp = postDoc['createAt'];
      DateTime dateTime = timestamp.toDate();
      String monthYear = '${dateTime.month}/${dateTime.year}';

      if (!classifiedImages.containsKey(monthYear)) {
        classifiedImages[monthYear] = [];
      }
      classifiedImages[monthYear]!.add(postDoc['postImageUrl']);
    });

    return classifiedImages;
  }

  List photoArr = [
    {
      "time": "2 June",
      "photo": [
        "images/pp_1.png",
        "images/pp_2.png",
        "images/pp_3.png",
        "images/pp_4.png",
      ]
    },
    {
      "time": "5 May",
      "photo": [
        "images/pp_5.png",
        "images/pp_6.png",
        "images/pp_7.png",
        "images/pp_8.png",
      ]
    }
  ];
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "My Activity",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('userProgress')
              .doc(user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                      CircularProgressIndicator()); // Placeholder widget while loading
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "It looks like you haven't done any exercises.",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Let's start practicing",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: RoundGradientButton(
                        title: "Start",
                        onPressed: () {
                          Navigator.pushNamed(context, 'dashboard');
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            // Here you can access your Firestore data
            var wObj = snapshot.data!.data() as Map<String, dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Progess",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: WorkoutRow(wObj: wObj),
                ),
                SizedBox(
                    height:
                        20), // Adding some space between WorkoutRow and photoArr
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Gallery",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: imagesByMonth.length,
                    itemBuilder: (context, index) {
                      String monthYear = imagesByMonth.keys.toList()[index];
                      List<String> images = imagesByMonth[monthYear] ?? [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              monthYear,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: images
                                  .map((imageUrl) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.network(
                                          imageUrl,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
