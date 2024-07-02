import 'dart:io';
import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'person_model.g.dart';

@HiveType(typeId: 0)
class PersonModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final Uint8List image;
  @HiveField(2)
  final int faces;
  PersonModel({
    required this.id,
    required this.image,
    required this.faces,
  });
}