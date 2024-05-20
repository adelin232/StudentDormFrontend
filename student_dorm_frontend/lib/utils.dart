import 'package:flutter/foundation.dart';

String getBackendUrl() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    return '192.168.100.118:8080';
  } else {
    return 'localhost:8080';
  }
}
