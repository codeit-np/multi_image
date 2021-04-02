import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();

  List<Asset> images = List<Asset>();
  String _error;

  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView() {
    if (images != null)
      return GridView.count(
        crossAxisCount: 3,
        children: List.generate(images.length, (index) {
          Asset asset = images[index];
          return AssetThumb(
            asset: asset,
            width: 300,
            height: 300,
          );
        }),
      );
    else
      return Container(color: Colors.white);
  }

  Future<void> loadAssets() async {
    setState(() {
      images = List<Asset>();
    });

    List<Asset> resultList;
    String error;

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      if (error == null) _error = 'No Error Dectected';
    });
  }

  

  // Save Method
  Future save() async {
    final uri = Uri.parse('http://192.168.0.106:8000/api/ads');

    // create multipart request
    MultipartRequest request = http.MultipartRequest("POST", uri);

    List<int> imageData;
    for (var image in images) {
      ByteData byteData = await image.getByteData();
      imageData = byteData.buffer.asUint8List();
      MultipartFile multipartFile = MultipartFile.fromBytes(
        'images[]',
        imageData,
        filename: image.name,
      );

    // add file to multipart

      request.files.add(multipartFile);
    }

// send
    request.fields['name'] = name.text;
    var response = await request.send();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Center(child: Text('Error: $_error')),
              RaisedButton(
                child: Text("Pick images"),
                onPressed: loadAssets,
              ),
              TextFormField(
                controller: name,
                decoration: InputDecoration(
                  hintText: 'Ad Title',
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: buildGridView(),
              ),
              RaisedButton(
                onPressed: () {
                  save();
                },
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
