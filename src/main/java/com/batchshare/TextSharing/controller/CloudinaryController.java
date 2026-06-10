package com.batchshare.TextSharing.controller;

import com.batchshare.TextSharing.dto.ApiFormatter;
import com.batchshare.TextSharing.service.CloudinaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@RestController
@RequestMapping("/api/cloudinary")
@RequiredArgsConstructor
public class CloudinaryController {

    @Autowired
    private CloudinaryService cloudinaryService;

    @PostMapping("/upload")
    private ResponseEntity<ApiFormatter> upload(
            @RequestParam("file") MultipartFile file
    ) throws IOException {

        Map<String, String> url = cloudinaryService.uploadFile(file);

        return ResponseEntity.ok(new ApiFormatter(url.get("secure_url"), "url generated successfully"));
    }
}

