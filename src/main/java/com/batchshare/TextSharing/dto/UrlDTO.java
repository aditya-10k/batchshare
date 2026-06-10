package com.batchshare.TextSharing.dto;

import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record UrlDTO(
        String originalUrl ,
        String shortenedUrl ,
        LocalDateTime expiresAt
) {
}

