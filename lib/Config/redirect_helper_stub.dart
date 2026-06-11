// redirect_helper_stub.dart
import 'package:flutter/foundation.dart';

Future<bool> checkRedirectImpl() async {
  return false;
}

String getBaseUrlImpl() {
  if (kDebugMode) {
    return 'http://10.0.2.2:8080';
  }
  return 'https://adityx10-batchshare.hf.space';
}
