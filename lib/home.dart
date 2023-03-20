// ignore_for_file: avoid_print

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mcc_lab_3/utils/helpers.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with Helpers {
  XFile? _pickedFile;
  double? _indicatorValue = 0;
  ImagePicker imagePicker = ImagePicker();
  final storageRef = FirebaseStorage.instance.ref().child('images/');
  String? _imageUrl;
  File? file;

  @override
  initState() {
    super.initState();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Got a new connectivity status!
    });
  }

// Be sure to cancel subscription after you are done
  @override
  dispose() {
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {})
        .cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text('Upload Image'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: _pickedFile == null
                          ? const Icon(
                              Icons.person,
                              size: 100,
                            )
                          : Image.file(
                              File(_pickedFile!.path),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: IconButton(
                        onPressed: () {
                          pickImage();
                        },
                        icon: const Icon(Icons.camera_alt),
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black.withOpacity(0.3),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize:
                      Size(MediaQuery.of(context).size.width * 0.8, 50),
                ),
                onPressed: () async {
                  final connectivityResult =
                      await (Connectivity().checkConnectivity());
                  if (connectivityResult == ConnectivityResult.mobile ||
                      connectivityResult == ConnectivityResult.wifi) {
                    uoloadImage();
                  } else {
                    showSnackBar(
                        context: context,
                        content: 'No internet connection',
                        error: true);
                  }
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),


              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize:
                  Size(MediaQuery.of(context).size.width * 0.8, 50),
                ),
                onPressed: () async {
                  final connectivityResult =
                  await (Connectivity().checkConnectivity());
                  if (connectivityResult == ConnectivityResult.mobile ||
                      connectivityResult == ConnectivityResult.wifi) {
                    uoloadFile();
                  } else {
                    showSnackBar(
                        context: context,
                        content: 'No internet connection',
                        error: true);
                  }
                },
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),

            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/showImage');
          },
          child: const Icon(Icons.image),
        )
    );
  }

  Future<bool> pickImage() async {
    try {
      _pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
      if (_pickedFile != null) {
        setState(() {
          _pickedFile = _pickedFile;
        });
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          file = File(result.files.single.path!);
        });
      }else{
        showSnackBar(
            context: context,
            content: 'No internet connection',
            error: true);



      }

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void uploadImage(
      {required File file,
      required void Function(bool state, TaskState status, String message)
          eventHandler}) {
    try {
      UploadTask uploadTask =
          storageRef.child("image_${DateTime.now()}").putFile(file);
      _imageUrl = uploadTask.snapshot.ref.getDownloadURL().toString();
      setState(() {
        _imageUrl = _imageUrl;
      });
      uploadTask.snapshotEvents.listen((event) {
        if (event.state == TaskState.running) {
          print('running');
          eventHandler(false, event.state, '');
        } else if (event.state == TaskState.success) {
          print('success');
          eventHandler(true, event.state, 'Upload Image Successfully');
        } else if (event.state == TaskState.error) {
          print('error');
          eventHandler(false, event.state, 'Upload Image Failed');
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void uoloadImage() async {
    if (_indicatorValue != null) {
      // await  pickImage();
      try {
        uploadImage(
            file: File(_pickedFile!.path),
            eventHandler: (status, TaskState state, message) {
              if (status) {
                //upload successfully
                changeIndicatorValue(1);
                showSnackBar(context: context, content: message, error: false);
              } else if (state == TaskState.running) {
                //uploading
              } else {
                changeIndicatorValue(0);
                showSnackBar(context: context, content: message, error: true);
              }
            });
      } catch (e) {
        showSnackBar(
            context: context, content: 'Pick image to uploada!', error: true);
      }
    } else {
      showSnackBar(
          context: context, content: 'Pick image to uploada!', error: true);
    }
  }


  void uoloadFile() async {
    if (_indicatorValue != null) {
      // await  pickImage();
      try {
        uploadImage(
            file: file!,
            eventHandler: (status, TaskState state, message) {
              if (status) {
                //upload successfully
                changeIndicatorValue(1);
                showSnackBar(context: context, content: message, error: false);
              } else if (state == TaskState.running) {
                //uploading
              } else {
                changeIndicatorValue(0);
                showSnackBar(context: context, content: message, error: true);
              }
            });
      } catch (e) {
        showSnackBar(
            context: context, content: 'Pick image to uploada!', error: true);
      }
    } else {
      showSnackBar(
          context: context, content: 'Pick image to uploada!', error: true);
    }
  }

  void changeIndicatorValue(double? value) {
    setState(() {
      _indicatorValue = value;
    });
  }
}


