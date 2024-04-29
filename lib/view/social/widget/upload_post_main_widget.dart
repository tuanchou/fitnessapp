import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class UploadPostMainWidget extends StatefulWidget {
  const UploadPostMainWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<UploadPostMainWidget> createState() => _UploadPostMainWidgetState();
}

class _UploadPostMainWidgetState extends State<UploadPostMainWidget> {
  final ImagePicker _picker = ImagePicker();

  File? _image;
  TextEditingController _descriptionController = TextEditingController();
  bool _uploading = false;
  final CollectionReference _user =
      FirebaseFirestore.instance.collection('user-info');
  final _storage = FirebaseStorage.instance;
  final _userNameController = TextEditingController();
  String _imageURLAvatar = "";
  String _imageURLPost = "";

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final DocumentSnapshot userSnapshot = await _user.doc(user.uid).get();
        final userData = userSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _userNameController.text = userData['Name'];
          _imageURLAvatar = userData['Avatar'] ?? '';
        });
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future selectImage() async {
    try {
      XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print("no image has been selected");
        }
      });
    } catch (e) {
      print("some error occured $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _image == null
        ? _uploadPostWidget()
        : Scaffold(
            backgroundColor: AppColors.whiteColor,
            appBar: AppBar(
              backgroundColor: AppColors.whiteColor,
              leading: GestureDetector(
                  onTap: () {},
                  child: Icon(
                    Icons.close,
                    size: 28,
                  )),
              centerTitle: true,
              elevation: 0,
              title: const Text(
                "NewPost",
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                      onTap: _submitPost, child: Icon(Icons.arrow_forward)),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: _imageURLAvatar.isNotEmpty
                          ? Image.network(
                              _imageURLAvatar,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              "images/user.png",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  _userNameController.text.isNotEmpty
                      ? Text(
                          _userNameController.text,
                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        )
                      : Text(
                          "UserName",
                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  _uploading == true
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Uploading...",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            CircularProgressIndicator()
                          ],
                        )
                      : Container(
                          width: 0,
                          height: 0,
                        )
                ],
              ),
            ),
          );
  }

  _submitPost() async {
    setState(() {
      _uploading = true;
    });

    try {
      String imageUrl = _imageURLPost;
      if (_image != null) {
        Reference storageReference =
            _storage.ref().child('PostImage/${DateTime.now()}.jpg');
        await storageReference.putFile(_image!);
        imageUrl = await storageReference.getDownloadURL();
      }

      await _createSubmitPost(image: imageUrl);
    } catch (e) {
      print('Error submitting post: $e');
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  _createSubmitPost({required String image}) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance.collection('posts').add({
          'description': _descriptionController.text,
          'createAt': Timestamp.now(),
          'creatorUid': currentUser.uid,
          'likes': [],
          'postImageUrl': image,
          'totalComments': 0,
          'totalLikes': 0,
        });

        _clear();
      } catch (e) {
        print('Error creating post: $e');
      }
    }
  }

  _clear() {
    setState(() {
      _uploading = false;
      _descriptionController.clear();
      _image = null;
    });
  }

  _uploadPostWidget() {
    return Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            "Choose Image Upload",
            style: TextStyle(
                color: AppColors.blackColor,
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
        ),
        body: Center(
          child: GestureDetector(
            onTap: selectImage,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                  color: AppColors.grayColor, shape: BoxShape.circle),
              child: Center(
                child: Icon(
                  Icons.upload,
                  color: AppColors.lightGrayColor,
                  size: 40,
                ),
              ),
            ),
          ),
        ));
  }
}
