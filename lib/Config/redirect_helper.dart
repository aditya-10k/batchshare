// redirect_helper.dart
import 'redirect_helper_stub.dart'
    if (dart.library.html) 'redirect_helper_web.dart';

Future<bool> checkAndRedirect() async {
  return await checkRedirectImpl();
}

String getBaseUrl() {
  return getBaseUrlImpl();
}
