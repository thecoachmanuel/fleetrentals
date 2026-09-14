import 'package:flutter/widgets.dart';

ImageProvider getPlatformFileImage(String path) {
  return NetworkImage(path);
}
