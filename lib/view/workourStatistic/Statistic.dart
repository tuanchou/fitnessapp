import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:fitness/service/round_gradient_button.dart';
import 'package:fitness/service/workout_row.dart';
import 'package:fitness/view/home_screen.dart';
import 'package:flutter/material.dart';

class Statistic extends StatefulWidget {
  const Statistic({Key? key}) : super(key: key);

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
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
          "Progress",
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
              return CircularProgressIndicator(); // Placeholder widget while loading
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
            return ListView.builder(
              itemCount: 1, // Chỉ có một tài liệu nên itemCount là 1
              itemBuilder: (context, index) {
                return WorkoutRow(wObj: wObj);
              },
            );
          },
        ),
      ),
    );
  }
}
