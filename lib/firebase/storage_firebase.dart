import 'dart:core';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

BuildContext context = BuildContext as BuildContext;

class FbStorageController  {
  final storageRef = FirebaseStorage.instance.ref().child('images/');


  Future<List> getImagesList() async {
    List<String> imageUrls = [];
    var result = await storageRef.listAll();
    for (var item in result.items) {
      var url = await item.getDownloadURL();
      imageUrls.add(url);
    }
    return imageUrls;
  }

}
