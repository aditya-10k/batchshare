package com.batchshare.TextSharing.config;

import com.cloudinary.Cloudinary;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.HashMap;
import java.util.Map;

@Configuration
public class CloudinaryConfig {

    @Value("${CLOUDINARY_CLOUDNAME:}")
    private String cloudName;

    @Value("${CLOUDINARY_API_SECRET:}")
    private  String apiSecret ;

    @Value("${CLOUDINARY_API_KEY:}")
    private String apiKey ;

    @Bean
    public Cloudinary cloudinary(){
        System.out.println("[DEBUG] Cloudinary Initializing - CloudName: [" + cloudName + "], ApiKey length: " + (apiKey != null ? apiKey.length() : 0));

        Map<String, String> config = new HashMap<>();

        config.put("cloud_name", cloudName);
        config.put("api_key", apiKey);
        config.put("api_secret", apiSecret);

        return new Cloudinary(config);
    }
}

