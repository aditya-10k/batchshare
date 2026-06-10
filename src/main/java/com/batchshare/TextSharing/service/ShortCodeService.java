package com.batchshare.TextSharing.service;

import org.springframework.stereotype.Component;

import java.security.SecureRandom;

@Component
public class ShortCodeService {

    private final String chars =
            "abcdefghijklmnopqrstuvwxyz1234567890";

    private static final int len = 7 ;

    private final SecureRandom secureRandom = new SecureRandom();

    public String generate(){

        StringBuilder shortCode = new StringBuilder(len);

        for (int i = 0 ; i < len ; i++){

            shortCode.append(
                    chars.charAt(secureRandom.nextInt(chars.length())
            ));
        }
        return shortCode.toString();
    }
}

