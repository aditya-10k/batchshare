import 'package:batchshare/Elements/MessageBubble.dart';
import 'package:batchshare/HomePage/Bloc/HomePageBloc.dart';
import 'package:batchshare/HomePage/Bloc/HomePageEvent.dart';
import 'package:batchshare/HomePage/Bloc/HomePageState.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:batchshare/Elements/AppScaffold.dart';


class ChatPage extends StatefulWidget {
  final HomePageState state;
  const ChatPage({super.key, required this.state});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final textEditingController = TextEditingController();
  String? attachedFileUrl;
  String? attachedFileName;
  bool isUploading = false;

  String detectCloudinaryFileType(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();
    if (path.contains('.')) {
      final ext = path.split('.').last;

      if (["jpg", "jpeg", "png", "gif", "webp", "bmp"].contains(ext)) {
        return "image";
      }

      if (["mp4", "mov", "avi", "mkv", "webm"].contains(ext)) {
        return "file";
      }

      if ([
        "pdf",
        "doc",
        "docx",
        "ppt",
        "pptx",
        "xls",
        "xlsx",
        "txt",
        "zip",
        "rar",
      ].contains(ext)) {
        return "file";
      }
    }

    if (path.contains("/image/")) return "image";
    if (path.contains("/video/")) return "file";
    if (path.contains("/raw/")) return "file";

    return "unknown";
  }

  Widget buildSixDigitCode(String? code) {
    final safeCode = code ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final char = i < safeCode.length ? safeCode[i] : '';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 40,
          width: 35,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              char,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePageBloc, HomePageState>(
      builder: (context, state) {
        final currentState = state is ConnectionEstablished
            ? state
            : (widget.state as ConnectionEstablished);

        final size = MediaQuery.of(context).size;
        final isDesktop = size.width > 700;

        Widget chatContainer() {
          return Container(
            height: isDesktop ? size.height * 0.80 : size.height * 0.68,
            width: isDesktop ? size.width * 0.6 : size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.08),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    child: ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: currentState.message.length,
                      itemBuilder: (context, index) {
                        final messagesList = currentState.message;
                        final msg = messagesList[messagesList.length - 1 - index];
                        
                        String url = '';
                        if (msg['url'] != null && (msg['url'] as String).isNotEmpty) {
                          url = msg['url'];
                        } else if (msg['urls'] != null && (msg['urls'] as List).isNotEmpty) {
                          url = msg['urls'][0] as String;
                        }

                        final type = url.isNotEmpty
                            ? detectCloudinaryFileType(url)
                            : 'unknown';
                        final text = (msg['message'] ?? '') as String;

                        return MessageBubble(
                          fileType: type,
                          url: url,
                          text: text,
                          senderName: msg['sentBy'],
                          sentAtIso: msg['sentDate'] ?? '',
                        );
                      },
                    ),
                  ),
                ),
                if (attachedFileName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file, color: Colors.blueAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Attached: $attachedFileName',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                          onPressed: () {
                            setState(() {
                              attachedFileUrl = null;
                              attachedFileName = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: textEditingController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Enter Text",
                            hintStyle: TextStyle(color: Colors.white60),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: isUploading
                            ? null
                            : () async {
                                try {
                                  final result = await FilePicker.platform.pickFiles();
                                  if (result == null || result.files.isEmpty) return;

                                  final fileInfo = result.files.first;
                                  if (fileInfo.size > 10 * 1024 * 1024) {
                                    Get.snackbar(
                                      'File Too Large',
                                      'Please select a file smaller than 10 MB.',
                                      backgroundColor: Colors.redAccent,
                                      colorText: Colors.white,
                                      maxWidth: 400,
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isUploading = true;
                                  });
                                  MultipartFile file;

                                  if (fileInfo.bytes != null) {
                                    file = MultipartFile.fromBytes(fileInfo.bytes!, filename: fileInfo.name);
                                  } else if (fileInfo.path != null) {
                                    file = await MultipartFile.fromFile(fileInfo.path!, filename: fileInfo.name);
                                  } else {
                                    throw Exception("Unable to read file contents");
                                  }

                                  final formData = FormData.fromMap({
                                    "file": file,
                                  });

                                  final response = await Dio().post(
                                    '${HomePageBloc.baseUrl}/api/cloudinary/upload',
                                    data: formData,
                                  );

                                  setState(() {
                                    attachedFileUrl = response.data['data'];
                                    attachedFileName = fileInfo.name;
                                    isUploading = false;
                                  });

                                  Get.snackbar(
                                    'Success',
                                    'File attached: ${fileInfo.name}',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                } catch (e) {
                                  setState(() {
                                    isUploading = false;
                                  });
                                  print(e);
                                  Get.snackbar(
                                    'Error',
                                    'File upload failed: $e',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                        icon: isUploading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.blueAccent,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.attach_file,
                                color: Colors.white70,
                              ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          String name = prefs.getString("Name") ?? 'BOT';
                          String code = currentState.code ?? '';

                          if (attachedFileUrl != null) {
                            context.read<HomePageBloc>().add(
                                  SendChatMessage(
                                    'FILE',
                                    attachedFileUrl!,
                                    message: textEditingController.text.isNotEmpty
                                        ? textEditingController.text
                                        : attachedFileName!,
                                    chatCode: code,
                                    sentBy: name,
                                  ),
                                );
                            setState(() {
                              attachedFileUrl = null;
                              attachedFileName = null;
                            });
                          } else {
                            if (textEditingController.text.trim().isEmpty) return;
                            context.read<HomePageBloc>().add(
                                  SendChatMessage(
                                    'text',
                                    '',
                                    message: textEditingController.text,
                                    chatCode: code,
                                    sentBy: name,
                                  ),
                                );
                          }
                          textEditingController.clear();
                        },
                        icon: const Icon(Icons.send, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        Widget roomCodeCard() {
          return GestureDetector(
            onTap: () async {
              await FlutterClipboard.copy(
                currentState.code ?? '0000',
              );
              Get.snackbar('Success', 'Code copied to clipboard');
            },
            child: Container(
              height: isDesktop ? 150 : 120,
              width: isDesktop ? 300 : size.width * 0.9,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Room Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  buildSixDigitCode(
                    currentState.code ?? '000000',
                  ),
                  const Spacer(),
                  Text(
                    'This room will remain active for one hour',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          );
        }

        Widget backButton() {
          return InkWell(
            onTap: () {
              context.read<HomePageBloc>().add(GoToHomePage());
            },
            child: Container(
              height: 45,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Text(
                  "< Back",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          );
        }

        return AppScaffold(
          showBackButton: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: isDesktop
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      chatContainer(),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          roomCodeCard(),
                        ],
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      roomCodeCard(),
                      const SizedBox(height: 15),
                      chatContainer(),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
