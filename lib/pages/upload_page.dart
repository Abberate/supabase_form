import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool isUploading = false;
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> uploadFile() async {
    var pickedFile = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);

    if (pickedFile != null) {
      setState(() {
        isUploading = true;
      });
    }
    try {
      File file = File(pickedFile!.files.first.path!);
      String fileName = pickedFile.files.first.name;
      String uploadedUrl = await supabase.storage
          .from("user-images")
          .upload("${supabase.auth.currentUser!.id}/$fileName", file);
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "File uploaded successfully",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      print("Error in uploading file: $e");
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error in uploading file"),
        ),
      );
    }
  }

  Future getMyFiles() async {
    List<Map<String, String>> myImages = [];

    List<FileObject> result = await supabase.storage
        .from("user-images")
        .list(path: supabase.auth.currentUser!.id);

    for (var image in result) {
      var getUrl = supabase.storage
          .from("user-images")
          .getPublicUrl("${supabase.auth.currentUser!.id}/${image.name}");
      myImages.add({
        "name": image.name,
        "url": getUrl,
      });
    }

    return myImages;
  }

  Future<void> deleteFile(String fileName) async {
    try {
      await supabase.storage
          .from("user-images")
          .remove(["${supabase.auth.currentUser!.id}/$fileName"]);
      setState(() {});
    } catch (e) {
      print("Error in deleting file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error in deleting file"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Page"),
      ),
      body: FutureBuilder(
          future: getMyFiles(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Center(
                  child: Text("No files found"),
                );
              }
              return ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  itemBuilder: (context, index) {
                    Map imageData = snapshot.data[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 200,
                          width: 300,
                          child: Image.network(
                            imageData["url"],
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              deleteFile(imageData["name"]);
                            },
                            icon: Icon(Icons.delete, color: Colors.red))
                      ],
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                        thickness: 2,
                        color: Colors.black,
                      ),
                  itemCount: snapshot.data.length);
            }
            return CircularProgressIndicator();
          }),
      floatingActionButton: isUploading
          ? CircularProgressIndicator()
          : FloatingActionButton(
              onPressed: uploadFile,
              child: Icon(Icons.add_a_photo),
            ),
    );
  }
}
