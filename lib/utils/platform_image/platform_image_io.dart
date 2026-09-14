import 'dart:io';
import 'package:flutter/widgets.dart';

ImageProvider getPlatformFileImage(String path) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return NetworkImage(path);
  }
  return FileImage(File(path));
}
