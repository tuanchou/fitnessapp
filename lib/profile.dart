import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum Gender {
  male,
  female,
}

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String _imageURL = "";
  final CollectionReference _user =
      FirebaseFirestore.instance.collection('user-info');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _dob;
  bool? gender;
  File? _pickedImage;
  final _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Lấy thông tin người dùng đã đăng nhập từ Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Sử dụng UserID từ Authentication để truy vấn Firestore
        final DocumentSnapshot userSnapshot = await _user.doc(user.uid).get();
        final userData = userSnapshot.data() as Map<String, dynamic>;

        if (userData != null) {
          setState(() {
            _nameController.text = userData['Name'] ?? '';
            _addressController.text = userData['Address'] ?? '';
            _emailController.text = userData['Email'] ?? '';
            if (userData['DoB'] != null) {
              _dob = DateTime.parse(userData['DoB']);
            }
            gender = userData['Gender'] ?? false;
            _imageURL = userData['Avatar'] ?? '';
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _updateUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final String newName = _nameController.text;
      final String newAddress = _addressController.text;
      final String newDoB = _dob?.toIso8601String() ?? '';

      try {
        String imageUrl = _imageURL;
        if (_imageFile != null) {
          Reference storageReference =
              _storage.ref().child('UserAvatar/${DateTime.now()}.jpg');
          await storageReference.putFile(File(_imageFile!.path));
          imageUrl = await storageReference.getDownloadURL();
        }

        await _user.doc(user.uid).update({
          'Name': newName,
          'Address': newAddress,
          'DoB': newDoB,
          'Gender': gender,
          'Avatar': imageUrl
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User data updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print('Error updating user data: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          title: Text("Profile"),
        ),
        body: Container(
            child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        _imageFile != null
                            ? Image.file(
                                File(_imageFile!.path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : _imageURL.isNotEmpty
                                ? Image.network(
                                    _imageURL,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.account_circle,
                                    size: 100, color: Colors.grey),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: Text('Change Avatar'),
                        ),
                      ])),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.account_circle),
                      // labelText: text,
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: AppColors.primaryColor1.withOpacity(0.3),
                      counterText: "",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                              color: Colors.indigo)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.indigo), // Customize border color
                        borderRadius:
                            BorderRadius.circular(30.0), // Add border radius
                      ),
                    ),
                    maxLength: 150,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your name";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      // labelText: text,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: AppColors.primaryColor1.withOpacity(0.3),
                      counterText: "",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                              color: Colors.indigo)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.indigo), // Customize border color
                        borderRadius:
                            BorderRadius.circular(30.0), // Add border radius
                      ),
                    ),
                    maxLength: 150,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your email";
                      }
                      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                          .hasMatch(value)) {
                        return "Invalid email format";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.location_on),
                      // labelText: text,
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: AppColors.primaryColor1.withOpacity(0.3),
                      counterText: "",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                              color: Colors.indigo)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.indigo), // Customize border color
                        borderRadius:
                            BorderRadius.circular(30.0), // Add border radius
                      ),
                    ),
                    maxLength: 150,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your address";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 5),
                  TextFormField(
                    readOnly: true, // Không cho phép chỉnh sửa trường văn bản
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: _dob ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            _dob = value;
                          });
                        }
                      });
                    },
                    controller: TextEditingController(
                      text: _dob != null
                          ? DateFormat('yyyy-MM-dd')
                              .format(_dob ?? DateTime.now())
                          : 'Not selected',
                    ),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today),

                      // labelText: text,
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: AppColors.primaryColor1.withOpacity(0.3),
                      counterText: "",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                              color: Colors.indigo)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.indigo), // Customize border color
                        borderRadius:
                            BorderRadius.circular(30.0), // Add border radius
                      ),
                    ),
                    maxLength: 150,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const Text(
                        "Gender: ",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Checkbox(
                        value: gender ?? false,
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                      Text("Male"),
                      Checkbox(
                        value: gender == false,
                        onChanged: (value) {
                          setState(() {
                            gender = !value!;
                          });
                        },
                      ),
                      Text("Female"),
                    ],
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: _updateUserData,
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          "Update",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )));
  }
}
