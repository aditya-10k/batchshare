package com.batchshare.TextSharing.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.batchshare.TextSharing.repo.ChatRoomRepo;
import com.batchshare.TextSharing.utility.ChatMessage;
import com.batchshare.TextSharing.utility.ChatRoom;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CloudinaryService {

    @Autowired
    private Cloudinary cloudinary;

    @Autowired
    private ChatRoomRepo chatRoomRepo;

    public void deleteFileAndRoom() throws IOException {

        List<ChatRoom> chatRooms = chatRoomRepo.findByExpiryDateBefore(LocalDateTime.now());

        if(chatRooms.isEmpty()) return;

        for(ChatRoom chatRoom : chatRooms){

            List<ChatMessage> messages = chatRoom.getMessages();

            for (ChatMessage message : messages){

                List<String> publicIds = message.getPublicId();
                List<String> urls = message.getUrls();

                if(publicIds == null ||
                        publicIds.isEmpty()) {
                    continue;
                }

                for(int i = 0; i < publicIds.size(); i++){
                    String publicId = publicIds.get(i);
                    String resourceType = "raw";
                    if (urls != null && i < urls.size()) {
                        resourceType = extractResourceType(urls.get(i));
                    }
                    cloudinary.uploader().destroy(publicId, ObjectUtils.asMap("resource_type", resourceType));
                    System.out.println("[CLOUDINARY] Deleted resource during room cleanup: " + publicId + " (" + resourceType + ")");
                }

            }

            chatRoomRepo.delete(chatRoom);
            System.out.println("[CLEANUP] Deleted expired ChatRoom from DB: " + chatRoom.getChatCode());
        }
    }

    public Map<String , String> uploadFile(MultipartFile file) throws IOException {
        String originalFilename = file.getOriginalFilename();
        
        java.util.Map<String, Object> params = new java.util.HashMap<>();
        
        String resourceType = "raw";
        if (originalFilename != null) {
            String lowercase = originalFilename.toLowerCase();
            if (lowercase.endsWith(".jpg") || lowercase.endsWith(".jpeg") || 
                lowercase.endsWith(".png") || lowercase.endsWith(".gif") || 
                lowercase.endsWith(".webp") || lowercase.endsWith(".bmp")) {
                resourceType = "image";
            } else if (lowercase.endsWith(".mp4") || lowercase.endsWith(".avi") || 
                       lowercase.endsWith(".mkv") || lowercase.endsWith(".mov") ||
                       lowercase.endsWith(".webm") || lowercase.endsWith(".mp3") || 
                       lowercase.endsWith(".wav")) {
                resourceType = "video";
            }
        }
        
        params.put("resource_type", resourceType);
        if (originalFilename != null) {
            String extension = "";
            int dotIndex = originalFilename.lastIndexOf('.');
            if (dotIndex >= 0) {
                extension = originalFilename.substring(dotIndex);
            }
            String baseName = originalFilename;
            if (dotIndex > 0) {
                baseName = originalFilename.substring(0, dotIndex);
            }
            baseName = baseName.replaceAll("[^a-zA-Z0-9-_]", "_");
            String uniquePublicId = baseName + "_" + java.util.UUID.randomUUID().toString().substring(0, 8);

            if (resourceType.equals("raw")) {
                params.put("public_id", uniquePublicId + extension);
            } else {
                params.put("public_id", uniquePublicId);
            }
        }

        Map<?, ?> uploadResult = cloudinary.uploader().upload(file.getBytes(), params);

        return Map.of( "secure_url",uploadResult.get("secure_url").toString() , "public_id" , uploadResult.get("public_id").toString());
    }

    public void deleteFile(String url) {
        try {
            String publicId = extractPublicId(url);
            String resourceType = extractResourceType(url);
            if (publicId != null) {
                cloudinary.uploader().destroy(publicId, com.cloudinary.utils.ObjectUtils.asMap("resource_type", resourceType));
                System.out.println("[CLOUDINARY] Deleted resource: " + publicId + " (" + resourceType + ")");
            }
        } catch (Exception e) {
            System.err.println("[CLOUDINARY] Failed to delete resource: " + url + " - " + e.getMessage());
        }
    }

    private String extractPublicId(String url) {
        if (url == null || !url.contains("/upload/")) return null;
        String afterUpload = url.substring(url.indexOf("/upload/") + 8);
        if (afterUpload.contains("/")) {
            String segment = afterUpload.substring(0, afterUpload.indexOf("/"));
            if (segment.startsWith("v")) {
                afterUpload = afterUpload.substring(afterUpload.indexOf("/") + 1);
            }
        }
        return afterUpload;
    }

    private String extractResourceType(String url) {
        if (url == null) return "raw";
        if (url.contains("/image/upload/")) return "image";
        if (url.contains("/video/upload/")) return "video";
        return "raw";
    }
}

