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
    if (iso == null || iso.isEmpty) return "";
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "";
    }
  }

  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final filename = uri.pathSegments.last;
      return Uri.decodeComponent(filename);
    } catch (_) {
      return 'Attachment';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBubbleWidth = screenWidth > 700 ? screenWidth * 0.35 : screenWidth * 0.75;

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
                    if (senderName.isNotEmpty || _formatDate(sentAtIso).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          [
                            if (senderName.isNotEmpty) senderName,
                            if (_formatDate(sentAtIso).isNotEmpty) _formatDate(sentAtIso)
                          ].join(" • "),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ),
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
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 160,
                                  maxWidth: 240,
                                ),
                                child: InkWell(
                                  onTap: () => launchUrl(Uri.parse(url)),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const SizedBox(
                                        height: 120,
                                        width: 160,
                                        child: Center(
                                          child: CircularProgressIndicator(color: Colors.blueAccent),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            if (text.trim().isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ] else if (fileType == 'file' && url.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: InkWell(
                                onTap: () => launchUrl(Uri.parse(url)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.insert_drive_file,
                                        size: 24,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getFileNameFromUrl(url),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${url.split('.').last.toUpperCase()} Document',
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.open_in_new,
                                      size: 18,
                                      color: Colors.white54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (text.trim().isNotEmpty && text != _getFileNameFromUrl(url)) ...[
                              const SizedBox(height: 8),
                              Text(
                                text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ] else ...[
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
