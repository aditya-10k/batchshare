// redirect_helper_web.dart
import 'dart:html' as html;
import 'package:dio/dio.dart';
import 'package:batchshare/HomePage/Bloc/HomePageBloc.dart';

Future<bool> checkRedirectImpl() async {
  try {
    String? code;

    // 1. Get the path segments from window location
    final path = html.window.location.pathname ?? '';
    final pathSegments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (pathSegments.isNotEmpty) {
      final firstSegment = pathSegments.first;
      if (firstSegment != 'index.html') {
        code = firstSegment;
      }
    }

    // 2. If not in path, check in fragment (hash routing)
    if (code == null) {
      var hash = html.window.location.hash; // e.g. #/ggl or #ggl
      if (hash.startsWith('#')) {
        hash = hash.substring(1);
      }
      if (hash.startsWith('/')) {
        hash = hash.substring(1);
      }
      final hashSegments = hash.split('/').where((s) => s.isNotEmpty).toList();
      if (hashSegments.isNotEmpty) {
        final firstSegment = hashSegments.first;
        code = firstSegment;
      }
    }

    if (code != null && code.isNotEmpty) {
      final dio = Dio();
      
      // Call exists check
      final existsResponse = await dio.get('${HomePageBloc.baseUrl}/urlshortner/exists/$code');
      final exists = existsResponse.data['exists'] == true;

      if (exists) {
        final resolveResponse = await dio.get('${HomePageBloc.baseUrl}/urlshortner/resolve/$code');
        final originalUrl = resolveResponse.data['original_url'];
        if (originalUrl != null && originalUrl.isNotEmpty) {
          html.window.location.replace(originalUrl);
          // Keep it blocked/waiting so Flutter doesn't start booting
          await Future.delayed(const Duration(seconds: 5));
          return true;
        }
      }
    }
  } catch (e) {
    print('Web redirect helper failed: $e');
  }
  return false;
}

String getBaseUrlImpl() {
  final origin = html.window.location.origin;
  if (origin.contains('localhost') || origin.contains('127.0.0.1')) {
    return 'http://localhost:8080';
  }
  return 'https://adityx10-batchshare.hf.space';
}
