import 'package:flutter/widgets.dart';
import 'platform_image_stub.dart'
    if (dart.library.io) 'platform_image_io.dart'
    if (dart.library.html) 'platform_image_web.dart'
    if (dart.library.js_interop) 'platform_image_web.dart';

ImageProvider getPlatformImage(String path) => getPlatformFileImage(path);
