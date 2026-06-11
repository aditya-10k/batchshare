import 'package:batchshare/Elements/MessageBubble.dart';
import 'package:batchshare/HomePage/Bloc/HomePageBloc.dart';
import 'package:batchshare/HomePage/Bloc/HomePageEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:batchshare/Elements/AppScaffold.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;

class MailPage extends StatefulWidget {
  const MailPage({super.key});

  @override
  State<MailPage> createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  final mailIdTextEditingController = TextEditingController();
  final mailContentTextEditingController = TextEditingController();
  final textEditingController = TextEditingController();
  List<String> mailContents = [];
  
  // Recipient Emails list for multiple mails feature
  List<String> recipientEmails = [];

  // File attachments state variables
  List<String> attachedUrls = [];
  List<String> attachedNames = [];
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 950; // Increased threshold for side-by-side to avoid cramped layouts

    Widget mailContentContainer() {
      return Container(
        height: isDesktop ? size.height * 0.80 : size.height * 0.68,
        width: isDesktop ? size.width * 0.6 : size.width * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 8),
                itemCount: mailContents.length,
                itemBuilder: (context, index) {
                  return MessageBubble(
                    fileType: 'msg',
                    url: '',
                    text: mailContents[index],
                    senderName: '',
                    sentAtIso: '',
                  );
                },
              ),
            ),
            // Horizontal list showing uploaded file attachment chips
            if (attachedNames.isNotEmpty)
              Container(
                height: 50,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: attachedNames.length,
                  itemBuilder: (context, idx) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.attach_file, color: Colors.blueAccent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            attachedNames[idx],
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                attachedUrls.removeAt(idx);
                                attachedNames.removeAt(idx);
                              });
                            },
                            child: const Icon(Icons.close, color: Colors.white70, size: 16),
                          ),
                        ],
                      ),
                    );
                  },
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
                      controller: mailContentTextEditingController,
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

                              final responseData = HomePageBloc.parseResponseMap(response.data);

                              final String secureUrl = responseData['data'];

                              setState(() {
                                attachedUrls.add(secureUrl);
                                attachedNames.add(fileInfo.name);
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
                        : const Icon(Icons.attach_file, color: Colors.white70),
                  ),
                  IconButton(
                    onPressed: () {
                      final text = mailContentTextEditingController.text.trim();
                      if (text.isNotEmpty) {
                        setState(() {
                          mailContents.add(text);
                          mailContentTextEditingController.clear();
                        });
                      }
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

    Widget mailIdCard() {
      return Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          minHeight: isDesktop ? 220 : 180,
          maxWidth: isDesktop ? 300 : size.width * 0.9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Enter recipient emails',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: mailIdTextEditingController,
                      decoration: const InputDecoration(
                        hintText: "email@example.com",
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      onSubmitted: (val) {
                        final email = val.trim();
                        if (email.isNotEmpty && email.contains('@')) {
                          if (!recipientEmails.contains(email)) {
                            setState(() {
                              recipientEmails.add(email);
                              mailIdTextEditingController.clear();
                            });
                          } else {
                            mailIdTextEditingController.clear();
                          }
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      final email = mailIdTextEditingController.text.trim();
                      if (email.isNotEmpty && email.contains('@')) {
                        if (!recipientEmails.contains(email)) {
                          setState(() {
                            recipientEmails.add(email);
                            mailIdTextEditingController.clear();
                          });
                        } else {
                          mailIdTextEditingController.clear();
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Wrap to display multiple email chips
            if (recipientEmails.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: recipientEmails.map((email) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              email,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                recipientEmails.remove(email);
                              });
                            },
                            child: const Icon(Icons.close, color: Colors.white70, size: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    context.read<HomePageBloc>().add(GoToHomePage());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black.withOpacity(0.6),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        "< Back",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    final currentInput = mailIdTextEditingController.text.trim();
                    List<String> allMails = List.from(recipientEmails);
                    if (currentInput.isNotEmpty && currentInput.contains('@') && !allMails.contains(currentInput)) {
                      allMails.add(currentInput);
                    }

                    if (allMails.isEmpty) {
                      Get.snackbar(
                        'Recipient Required',
                        'Please enter at least one valid recipient email address.',
                        backgroundColor: Colors.orangeAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    if (mailContents.isEmpty && attachedUrls.isEmpty) {
                      Get.snackbar(
                        'Empty Mail',
                        'Please add some messages or attach files before sending.',
                        backgroundColor: Colors.orangeAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    context.read<HomePageBloc>().add(
                          SendMail(
                            recipientEmails: allMails,
                            messages: mailContents,
                            urls: attachedUrls,
                            fileNames: attachedNames,
                          ),
                        );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black.withOpacity(0.6),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Text(
                      'Mail it !',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return AppScaffold(
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.start,
          spacing: 20,
          runSpacing: 20,
          children: [
            mailContentContainer(),
            mailIdCard(),
          ],
        ),
      ),
    );
  }
}
