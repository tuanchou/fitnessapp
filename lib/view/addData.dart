import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitness/service/videoplayerwidget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data List'),
      ),
      body: DataList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddDataDialog();
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class DataList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Shoulder').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView(
          children: snapshot.data!.docs.map((document) {
            return ListTile(
              title: Text(document['title']),
              subtitle: Text(document['description']),
              leading: Videoplayerwidget(videoUrl: document['_videoUrl']),
            );
          }).toList(),
        );
      },
    );
  }
}

class AddDataDialog extends StatefulWidget {
  const AddDataDialog({Key? key}) : super(key: key);

  @override
  _AddDataDialogState createState() => _AddDataDialogState();
}

class _AddDataDialogState extends State<AddDataDialog> {
  File? _videoFile;
  final CollectionReference _dataAdd =
      FirebaseFirestore.instance.collection('Shoulder');
  final _storage = FirebaseStorage.instance;
  String _videoUrl = 'null';
  final picker = ImagePicker();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  Future pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    setState(() {
      _videoFile = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> _submitData() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _videoFile == null) {
      // Kiểm tra nếu có bất kỳ trường nào trống thì không thêm dữ liệu
      return;
    }

    try {
      Reference storageReference =
          _storage.ref().child('shoulderVideo/${DateTime.now()}.mp4');
      await storageReference.putFile(File(_videoFile!.path));
      String _videoUrl = await storageReference.getDownloadURL();
      // Lưu dữ liệu vào Firestore
      await _dataAdd.add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        '_videoUrl': _videoUrl
      });

      // Reset trạng thái sau khi thêm dữ liệu thành công
      setState(() {
        _titleController.clear();
        _descriptionController.clear();
        _videoFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Created Successfully"),
      ));

      Navigator.of(context).pop(); // Đóng dialog sau khi thêm thành công
    } catch (error) {
      // Xử lý lỗi nếu có
      print('Error adding data: $error');
      // Hiển thị thông báo lỗi cho người dùng
      // Ví dụ: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Data'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: pickVideo,
              child: Text('Select Video'),
            ),
            SizedBox(height: 20.0),
            _videoFile != null
                ? Text(
                    'Selected Video: ${_videoFile!.path.split('/').last}',
                    style: TextStyle(fontSize: 16.0),
                  )
                : Container(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog nếu hủy bỏ
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitData,
          child: Text('Submit'),
        ),
      ],
    );
  }
}
