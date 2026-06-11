import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:clipboard/clipboard.dart';
import 'package:batchshare/HomePage/Bloc/HomePageBloc.dart';

class UrlShortenerDialog extends StatefulWidget {
  const UrlShortenerDialog({super.key});

  @override
  State<UrlShortenerDialog> createState() => _UrlShortenerDialogState();
}

class _UrlShortenerDialogState extends State<UrlShortenerDialog> {
  final originalUrlController = TextEditingController();
  final customCodeController = TextEditingController();
  final expiryDaysController = TextEditingController();

  bool isGenerating = false;
  String? shortenedResult;
  String? expirationTime;

  @override
  void dispose() {
    originalUrlController.dispose();
    customCodeController.dispose();
    expiryDaysController.dispose();
    super.dispose();
  }

  Future<void> shortenUrl() async {
    String originalUrl = originalUrlController.text.trim();
    final customCode = customCodeController.text.trim();
    final expiryDaysStr = expiryDaysController.text.trim();

    if (expiryDaysStr.isNotEmpty) {
      final expiryDays = int.tryParse(expiryDaysStr);
      if (expiryDays == null || expiryDays > 30 || expiryDays < 1) {
        Get.snackbar(
          'Oops',
          'Expiry days must be between 1 and 30 days',
          colorText: Colors.white,
          backgroundColor: Colors.redAccent.withOpacity(0.7),
          maxWidth: 300,
        );
        return;
      }
    }

    if (originalUrl.isEmpty) {
      Get.snackbar(
        'Oops',
        'Original URL cannot be empty',
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.7),
        maxWidth: 300,
      );
      return;
    }

    // Prepend https:// if not present
    if (!originalUrl.startsWith('http://') && !originalUrl.startsWith('https://')) {
      originalUrl = 'https://$originalUrl';
    }

    setState(() {
      isGenerating = true;
      shortenedResult = null;
      expirationTime = null;
    });

    try {
      final dio = Dio();
      int? expiryDays = expiryDaysStr.isNotEmpty ? int.tryParse(expiryDaysStr) : null;

      final payload = {
        "originalUrl": originalUrl,
        if (customCode.isNotEmpty) "customCode": customCode,
        if (expiryDays != null) "expiryDays": expiryDays,
      };

      final response = await dio.post(
        '${HomePageBloc.baseUrl}/urlshortner/shorten',
        data: payload,
      );

      final responseData = HomePageBloc.parseResponseMap(response.data);

      final String backendUrl = responseData['shortenedUrl'] ?? '';
      final String? expiresAt = responseData['expiresAt'];

      if (backendUrl.isNotEmpty) {
        // Parse the code out from backend's URL. E.g. http://localhost:8080/xyz -> xyz
        final uri = Uri.parse(backendUrl);
        final code = uri.pathSegments.last;
        
        setState(() {
          if (kIsWeb) {
            shortenedResult = '${Uri.base.origin}/$code';
          } else {
            shortenedResult = 'https://batchsharenow.web.app/$code';
          }
          if (expiresAt != null) {
            // Format expiration date nicely if present
            // e.g. 2026-06-16T17:00:00 -> 2026-06-16
            if (expiresAt.contains('T')) {
              expirationTime = expiresAt.split('T').first;
            } else {
              expirationTime = expiresAt;
            }
          }
        });
      } else {
        throw Exception("Invalid response from server");
      }
    } catch (e) {
      print('Shorten URL error: $e');
      String errorMsg = 'Failed to shorten URL. Please try again.';
      if (e is DioException && e.response?.data != null) {
        if (e.response?.data is Map && e.response?.data['message'] != null) {
          errorMsg = e.response?.data['message'];
        } else if (e.response?.data.toString().contains("Alias already exists") == true) {
          errorMsg = "Alias already exists!";
        } else if (e.response?.data.toString().contains("Invalid custom code") == true) {
          errorMsg = "Invalid custom code! (3-30 chars, alphanumeric/_-)";
        }
      }
      Get.snackbar(
        'Error',
        errorMsg,
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.7),
        maxWidth: 350,
      );
    } finally {
      setState(() {
        isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;

    // Responsive styling variables
    final double paddingVal = isDesktop ? 28.0 : 18.0;
    final double titleFontSize = isDesktop ? 28.0 : 20.0;
    final double subtitleFontSize = isDesktop ? 14.0 : 12.0;
    final double labelFontSize = isDesktop ? 12.0 : 10.0;
    final double inputPaddingVal = isDesktop ? 16.0 : 12.0;
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    Widget buildCustomCodeInput() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CUSTOM CODE (OPTIONAL)',
            style: TextStyle(
              color: Colors.white70,
              fontSize: labelFontSize,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: customCodeController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. my-link',
              hintStyle: const TextStyle(
                color: Colors.white38,
                letterSpacing: 1.2,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: inputPaddingVal,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      );
    }

    Widget buildExpiryInput() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'EXPIRY DAYS (MAX 30)',
            style: TextStyle(
              color: Colors.white70,
              fontSize: labelFontSize,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: expiryDaysController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. 7 (default 30)',
              hintStyle: const TextStyle(
                color: Colors.white38,
                letterSpacing: 1.2,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: inputPaddingVal,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      );
    }

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: isDesktop ? size.width * 0.45 : size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: size.height * 0.85,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black.withOpacity(0.9), // Higher opacity for readability
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: paddingVal,
              right: paddingVal,
              top: paddingVal,
              bottom: paddingVal + bottomInset,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and close
                Row(
                  children: [
                    Text(
                      'SHORTEN URL',
                      style: TextStyle(
                        letterSpacing: 2,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Create custom, expiration-controlled short links instantly',
                  style: TextStyle(
                    letterSpacing: 1.5,
                    color: Colors.white70,
                    fontSize: subtitleFontSize,
                  ),
                ),
                const SizedBox(height: 25),

                // Original URL input
                Text(
                  'ORIGINAL URL',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: labelFontSize,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: originalUrlController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'https://example.com/very/long/url',
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      letterSpacing: 1.2,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: inputPaddingVal,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Expiry and Custom Code inputs (Side-by-side on desktop, stacked on mobile)
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: buildCustomCodeInput()),
                      const SizedBox(width: 20),
                      Expanded(child: buildExpiryInput()),
                    ],
                  )
                else ...[
                  buildCustomCodeInput(),
                  const SizedBox(height: 20),
                  buildExpiryInput(),
                ],
                const SizedBox(height: 30),

                // Shorten Button
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: isGenerating ? null : shortenUrl,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 28 : 20,
                        vertical: isDesktop ? 12 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'SHORTEN',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),

                // Shortened Link Result
                if (shortenedResult != null) ...[
                  const SizedBox(height: 25),
                  const Divider(color: Colors.white30, height: 1),
                  const SizedBox(height: 25),
                  Text(
                    'SHORTENED LINK',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: labelFontSize,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: inputPaddingVal,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: SelectableText(
                            shortenedResult!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          await FlutterClipboard.copy(shortenedResult!);
                          Get.snackbar(
                            'Success',
                            'Short link copied to clipboard!',
                            colorText: Colors.white,
                            backgroundColor: Colors.green.withOpacity(0.7),
                            maxWidth: 300,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(isDesktop ? 16 : 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (expirationTime != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Link expires on: $expirationTime',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
