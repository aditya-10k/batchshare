import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:textshare/Elements/MessageBubble.dart';
import 'package:textshare/HomePage/Bloc/HomePageBloc.dart';
import 'package:textshare/HomePage/Bloc/HomePageEvent.dart';
import 'package:textshare/HomePage/Bloc/HomePageState.dart';

class ChatPage extends StatefulWidget {
  final HomePageState state;
  const ChatPage({super.key, required this.state});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final textEditingController = TextEditingController();
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
    final size = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: size.height * 0.70,
          width: size.width * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withOpacity(0.08),
            border: BoxBorder.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.white.withOpacity(0.02),
            //     blurRadius: 18,
            //     offset: const Offset(0, 10),
            //   ),
            // ],
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
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount:
                        (widget.state as ConnectionEstablished).message.length,
                    itemBuilder: (context, index) {
                      final msg = (widget.state as ConnectionEstablished)
                          .message[index];
                      final url = (msg['url'] ?? '') as String;
                      final type = url.isNotEmpty
                          ? detectCloudinaryFileType(url)
                          : 'unknown';
                      final text = (msg['message'] ?? '') as String;

                      return MessageBubble(
                        fileType: type,
                        url: url,
                        text: text, senderName: msg['sentBy'], sentAtIso: msg['sentDate'],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 5),
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
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter Text",
                          hintStyle: const TextStyle(color: Colors.white60),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        // TODO: open file picker
                      },
                      icon: const Icon(
                        Icons.attach_file,
                        color: Colors.white70,
                      ),
                    ),

                    IconButton(
                      onPressed: () async{
                        final prefs = await SharedPreferences.getInstance();
                        String name = prefs.getString("Name") ?? 'BOT';
                        String code =
                            (widget.state as ConnectionEstablished).code ?? '';
                        
                        context.read<HomePageBloc>().add(
                          SendChatMessage(
                            'text',
                            '',
                            message: textEditingController.text,
                            chatCode: code,
                            sentBy: name,
                          ),
                        );
                        textEditingController.clear();
                      },
                      icon: const Icon(Icons.send, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                await FlutterClipboard.copy(
                  (widget.state as ConnectionEstablished).code ?? '0000',
                );
                Get.snackbar('Success', 'Code copied to clipboard');
              },
              child: Container(
                height: 150,
                width: 300,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.08),
                  border: BoxBorder.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withOpacity(0.5),
                  //     blurRadius: 18,
                  //     offset: const Offset(0, 10),
                  //   ),
                  // ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Room Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    buildSixDigitCode(
                      (widget.state as ConnectionEstablished).code ?? '000000',
                    ),
                    Spacer(),
                    Text(
                      'This room will remain active for one hour',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            InkWell(
              onTap: () {
                context.read<HomePageBloc>().add(GoToHomePage());
              },
              child: Container(
                height: 50,
                width: 100,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.08),
                  border: BoxBorder.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    "< Back",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
