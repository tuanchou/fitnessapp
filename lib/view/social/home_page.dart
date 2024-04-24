import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:fitness/view/social/widget/single_post_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "New Feed",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('posts').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Placeholder widget while loading
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            // If there's no data, show "No Posts Yet" widget
            if (snapshot.data!.docs.isEmpty) {
              return _noPostsYetWidget();
            }

            // If there's data, create a list of SinglePostCardWidgets
            List<SinglePostCardWidget> postWidgets =
                snapshot.data!.docs.map((document) {
              // Convert each document data to a Map<String, dynamic>
              Map<String, dynamic> wObj =
                  document.data() as Map<String, dynamic>;
              // Return a SinglePostCardWidget with corresponding data
              return SinglePostCardWidget(wObj: wObj);
            }).toList();

            // Sort postWidgets based on 'createAt' timestamp in descending order
            postWidgets.sort((a, b) {
              DateTime timeA = a.wObj['createAt'].toDate();
              DateTime timeB = b.wObj['createAt'].toDate();
              return timeB.compareTo(timeA);
            });

            // Return a ListView of SinglePostCardWidgets
            return ListView(
              children: postWidgets,
            );
          },
        ),
      ),
    );
  }

  // Widget for displaying "No Posts Yet" message
  Widget _noPostsYetWidget() {
    return Center(
      child: Text(
        "No Posts Yet",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
