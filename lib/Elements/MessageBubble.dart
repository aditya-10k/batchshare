import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  final String fileType;
  final String url;
  final String text;
  final String senderName;
  final String sentAtIso;

  const MessageBubble({
    super.key,
    required this.fileType,
    required this.url,
    required this.text,
    required this.senderName,
    required this.sentAtIso,
  });

  Future<String?> _getMyName() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString("Name");
  }

  String _formatDate(String iso) {
    final dt = DateTime.parse(iso).toLocal();
    return "${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.3;

    return FutureBuilder<String?>(
      future: _getMyName(),
      builder: (context, snapshot) {
        final myName = snapshot.data ?? '';
        final isMe = myName == senderName || senderName.isEmpty;

        final bubbleColor =
            isMe ? const Color(0xFF1E88E5) : const Color(0xFF262626);

        final alignment =
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start;

        final crossAlign =
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: alignment,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                child: Column(
                  crossAxisAlignment: crossAlign,
                  children: [
                    Text(
                      "$senderName • ${_formatDate(sentAtIso)}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isMe ? 18 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: crossAlign,
                        children: [
                          if (fileType == 'image' && url.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () => launchUrl(Uri.parse(url)),
                                child: Image.network(
                                  url,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (text.trim().isNotEmpty)
                              const SizedBox(height: 8),
                          ] else if (fileType == 'file' && url.isNotEmpty) ...[
                            InkWell(
                              onTap: () => launchUrl(Uri.parse(url)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.attach_file,
                                      size: 18, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'Open file',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (text.trim().isNotEmpty)
                              const SizedBox(height: 8),
                          ],
                          if (text.trim().isNotEmpty)
                            Text(
                              text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
