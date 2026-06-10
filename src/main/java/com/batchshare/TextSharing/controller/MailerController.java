package com.batchshare.TextSharing.controller;

import com.batchshare.TextSharing.dto.ApiFormatter;
import com.batchshare.TextSharing.service.MailerService;
import jakarta.mail.MessagingException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/mailer")
public class MailerController {

    @Autowired
    private MailerService mailerService;

    @PostMapping("/send")
    public ResponseEntity<ApiFormatter> sendMail(
            @RequestBody Map<String, Object> body
    ) {
        List<String> messages = (List<String>) body.getOrDefault("messages", Collections.emptyList());
        List<String> urls = (List<String>) body.getOrDefault("urls", Collections.emptyList());
        List<String> mails = (List<String>) body.getOrDefault("mails", Collections.emptyList());
        List<String> fileName = (List<String>) body.getOrDefault("fileNames", Collections.emptyList());

        String name = (String) body.getOrDefault("name", "user");

        try {
            mailerService.sendSharedContentEmail(mails, name, messages, urls, fileName);
            return ApiFormatter.created(null, "Mail sent successfully!");
        } catch (MessagingException e) {
            return new ResponseEntity<>(new ApiFormatter(null, "Failed to send mail: " + e.getMessage()), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}

