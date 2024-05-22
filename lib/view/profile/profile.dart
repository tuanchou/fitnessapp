import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness/service/app_colors.dart';
import 'package:fitness/service/round_button.dart';
import 'package:fitness/service/round_gradient_button.dart';
import 'package:fitness/service/round_textfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
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
            _heightController.text = userData['Height'] ?? '';
            _weightController.text = userData['Weight'] ?? '';
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
      final String newHeight = _heightController.text;
      final String newWeight = _weightController.text;
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
          'Avatar': imageUrl,
          'Weight': newWeight,
          'Height': newHeight,
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
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Column(
              children: [
                _imageFile != null
                    ? Image.file(
                        File(_imageFile!.path),
                        width: 50,
                        height: 50,
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
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: 90,
                  height: 30,
                  child: RoundButton(
                    title: "Change",
                    type: RoundButtonType.primaryBG,
                    onPressed: _pickImage,
                  ),
                ),
                SizedBox(height: 25),
                RoundTextField(
                  hintText: "Your Email",
                  icon: "icons/message_icon.png",
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                  readOnly: true,
                ),
                SizedBox(height: 15),
                RoundTextField(
                  hintText: "Your Name",
                  icon: "icons/user_icon.png",
                  textInputType: TextInputType.text,
                  textEditingController: _nameController,
                ),
                SizedBox(height: 15),
                RoundTextField(
                  hintText: "Date of Birth",
                  icon: "icons/calendar_icon.png",
                  textInputType: TextInputType.text,
                  onTapCallback: () {
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
                  textEditingController: TextEditingController(
                    text: _dob != null
                        ? DateFormat('yyyy-MM-dd')
                            .format(_dob ?? DateTime.now())
                        : 'Not selected',
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.lightGrayColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Image.asset(
                          "icons/gender_icon.png",
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          color: AppColors.grayColor,
                        ),
                      ),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: gender == true
                                ? "Male"
                                : "Female", // Map _gender to dropdown value
                            items: ["Male", "Female"]
                                .map((name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                            color: AppColors.grayColor,
                                            fontSize: 14),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                // Map dropdown value back to _gender
                                gender = value == "Male";
                              });
                            },
                            isExpanded: true,
                            hint: Text(
                              "Choose Gender",
                              style: const TextStyle(
                                  color: AppColors.grayColor, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      )
                    ],
                  ),
                ),
                SizedBox(height: 15),
                RoundTextField(
                  hintText: "Your Weight",
                  icon: "icons/weight_icon.png",
                  textInputType: TextInputType.text,
                  textEditingController: _weightController,
                ),
                SizedBox(height: 15),
                RoundTextField(
                  hintText: "Your Height",
                  icon: "icons/swap_icon.png",
                  textInputType: TextInputType.text,
                  textEditingController: _heightController,
                ),
                SizedBox(height: 15),
                RoundGradientButton(
                  title: "Update",
                  onPressed: _updateUserData,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
