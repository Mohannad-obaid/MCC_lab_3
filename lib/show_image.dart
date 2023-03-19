import 'package:flutter/material.dart';

import 'firebase/storage_firebase.dart';

class PageImage extends StatelessWidget {
  const PageImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Images'),
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: FutureBuilder(
            future: FbStorageController().getImagesList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(snapshot.data![index]),
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        )
      ),
    );
  }
}
