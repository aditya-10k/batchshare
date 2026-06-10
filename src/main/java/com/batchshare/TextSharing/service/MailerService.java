package com.batchshare.TextSharing.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MailerService {

    @Autowired
    private JavaMailSender mailSender;

    @Value("${BREVO_EMAIL_FROM}")
    private String fromEmail;

    public void sendSharedContentEmail(List<String> toEmails, String senderName, List<String> textContent,
                                       List<String> fileUrls, List<String> fileNames) throws MessagingException {

        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

        helper.setFrom(fromEmail);
        helper.setTo(toEmails.toArray(new String[0]));
        helper.setSubject("📭 delivery for you");

        // Building message items HTML dynamically with Flutter-matching styling
        StringBuilder messagesBuilder = new StringBuilder();
        if (textContent != null && !textContent.isEmpty()) {
            messagesBuilder.append("""
                      <div style="margin-bottom: 24px;">
                        <p style="color: rgba(255, 255, 255, 0.6); font-size: 12px; font-weight: bold; text-transform: uppercase; margin: 0 0 12px 0; letter-spacing: 1px;">Messages</p>
            """);
            for (String msg : textContent) {
                if (msg == null || msg.trim().isEmpty()) continue;
                messagesBuilder.append(String.format("""
                        <div style="background-color: rgba(255, 255, 255, 0.08); border: 1px solid rgba(255, 255, 255, 0.3); border-radius: 20px; padding: 14px 16px; margin-bottom: 10px;">
                          <p style="color: #ffffff; font-size: 14px; line-height: 1.5; margin: 0; white-space: pre-wrap; -webkit-user-select: all; user-select: all;">%s</p>
                        </div>
                """, msg));
            }
            messagesBuilder.append("          </div>");
        }

        // Building attachment items HTML dynamically with Flutter-matching styling
        StringBuilder attachmentsBuilder = new StringBuilder();
        if (fileUrls != null && !fileUrls.isEmpty()) {
            attachmentsBuilder.append("""
                      <div>
                        <p style="color: rgba(255, 255, 255, 0.6); font-size: 12px; font-weight: bold; text-transform: uppercase; margin: 0 0 12px 0; letter-spacing: 1px;">Shared Attachments</p>
            """);
            for (int i = 0; i < fileUrls.size(); i++) {
                String url = fileUrls.get(i);
                String fileName = (fileNames != null && i < fileNames.size()) ? fileNames.get(i) : "Attachment_" + (i + 1);
                attachmentsBuilder.append(String.format("""
                        <div style="background-color: rgba(255, 255, 255, 0.08); border: 1px solid rgba(255, 255, 255, 0.3); border-radius: 20px; padding: 16px; margin-bottom: 12px; display: table; width: 100%%; box-sizing: border-box;">
                          <div style="display: table-cell; vertical-align: middle;">
                            <p style="color: #ffffff; font-size: 14px; font-weight: 600; margin: 0; word-break: break-all;">%s</p>
                          </div>
                          <div style="display: table-cell; vertical-align: middle; text-align: right; width: 120px;">
                            <a href="%s" target="_blank" style="display: inline-block; background-color: rgba(0, 0, 0, 0.6); border: 2px solid #000000; border-radius: 20px; color: #ffffff; font-size: 12px; font-weight: bold; padding: 8px 16px; text-decoration: none; text-align: center;">Download</a>
                          </div>
                        </div>
                """, fileName, url));
            }
            attachmentsBuilder.append("          </div>");
        }

        // High-fidelity background image mimicking the Flutter background asset
        String htmlTemplate = String.format("""
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style="margin: 0; padding: 0; background-color: #101010; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
          <div style="background-color: #101010; background-image: url('https://res.cloudinary.com/ddhzcanud/image/upload/v1780772372/vpbzimjggoxo6xis973w.png'); background-size: cover; background-position: center; background-repeat: no-repeat; padding: 48px 16px; min-height: 100%%; text-align: center; box-sizing: border-box;">
            <div style="margin-bottom: 32px;">
              <h1 style="color: #ffffff; font-size: 26px; font-weight: bold; letter-spacing: 8px; margin: 0; text-transform: uppercase; text-shadow: 0 2px 4px rgba(0,0,0,0.5);">Batch Share</h1>
            </div>
            <div style="max-width: 550px; margin: 0 auto; background-color: rgba(255, 255, 255, 0.08); border: 1px solid rgba(255, 255, 255, 0.3); border-radius: 24px; padding: 32px; text-align: left; box-sizing: border-box; box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.37); backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);">
              <p style="color: #ffffff; font-size: 16px; margin-top: 0; margin-bottom: 24px; text-shadow: 0 1px 2px rgba(0,0,0,0.3);">
                <strong>%s</strong> has shared contents with you:
              </p>
              %s
              %s
            </div>
            <div style="margin-top: 32px;">
              <p style="color: rgba(255, 255, 255, 0.4); font-size: 11px; margin: 0; text-shadow: 0 1px 1px rgba(0,0,0,0.5);">This email was sent securely via batchshare. Links are powered by Cloudinary.</p>
            </div>
          </div>
        </body>
        </html>
        """, senderName, messagesBuilder.toString(), attachmentsBuilder.toString());

        helper.setText(htmlTemplate, true);
        mailSender.send(message);
    }
}
