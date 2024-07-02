import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/person_model.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  List<Face> faces = [];
  Map<String, dynamic> facialFeatures = {};

  Future _pickImage() async {
    final selectedSource = await showAlertDialog(
      context: context,
      title: 'إختار مصدر الصورة',
      body: 'عايز تحمل الصوره منين ؟',
      actionsTextButtonOne: 'المعرض',
      actionsTextButtonTow: 'الكاميرا',
      icon: const Icon(Icons.info),
    );

    try {
      final image = await ImagePicker().pickImage(source: selectedSource!);
      if (image == null) return;
      {
        setState(() {
          _image = File(image.path);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<ImageSource?> showAlertDialog({
    required BuildContext context,
    required String title,
    required String body,
    required String actionsTextButtonOne,
    required String actionsTextButtonTow,
    required Icon icon,
  }) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Text(actionsTextButtonOne),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Text(actionsTextButtonTow),
          ),
        ],
        icon: icon,
      ),
    );
  }

  Future _detectFaces({required File img}) async {
    final options = FaceDetectorOptions();
    final faceDetector = FaceDetector(options: options);
    final inputImage = InputImage.fromFilePath(img.path);
    faces = await faceDetector.processImage(inputImage);
    if (faces.isEmpty) {
      print('error');
    } else {
      await _saveFace(img: img, faces: faces.length);
    }
    setState(() {});
    print(faces.length);
  }

  Future _saveFace({required File img, required int faces}) async {
    var uuid = const Uuid();
    var farmersBox = Hive.box<PersonModel>('face_detection');
    await farmersBox.add(
        PersonModel(id: uuid.v4(), image: img.readAsBytesSync(), faces: faces));
  }

  Future<List<PersonModel>> _getFaces() async {
    return Hive.box<PersonModel>('face_detection').values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detection'),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        children: [
          _image == null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () async {
                      await _pickImage().then((value) {
                        if (_image != null) {
                          _detectFaces(img: _image!);
                        } else {}
                      });
                    },
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 100,
                    ),
                  ),
                )
              : Container(
                  // width: 200,
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Image.file(_image!),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          color: Colors.black26,
                          child: InkWell(
                            onTap: () async {
                              await _pickImage().then((value) {
                                if (_image != null) {
                                  _detectFaces(img: _image!);
                                } else {}
                              });
                            },
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 90,
                                ),
                                Text(
                                  'عمليه جديده',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('عدد الأشخاص ${faces.length} في الصوره'),
          )),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Divider(
              color: Colors.black,
              height: 10,
            ),
          ),
          FutureBuilder(
            future: _getFaces(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('ss');
              } else {
                return Column(
                  children: [
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: MemoryImage(snapshot.data![index].image),
                                fit: BoxFit.cover,
                              ),
                            ),
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: [
                                  Positioned(
                                    bottom: 0,
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                          child: Row(
                                            children: [
                                              Container(
                                                constraints:
                                                    const BoxConstraints(
                                                  maxWidth: 105,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: Text(
                                                      'تم إكتشاف ${snapshot.data![index].faces} وجه في الصوره'),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  snapshot.data![index]
                                                      .delete();
                                                  setState(() {});
                                                },
                                                icon: const Icon(
                                                  Icons.delete,
                                                ),
                                                color: Colors.red,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: snapshot.data!.length,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
