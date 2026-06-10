package com.batchshare.TextSharing.service;

import com.batchshare.TextSharing.dto.CreateUrlRequest;
import com.batchshare.TextSharing.repo.UrlRepo;
import com.batchshare.TextSharing.utility.UrlMapping;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.Period;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class UrlService {

    private final UrlRepo urlRepo;
    private final ShortCodeService shortCodeService;
    private final RedisService redisService;

    private static final Set<String> DISALLOWED =
            Set.of("api", "health", "mailer", "metrics");

    public UrlMapping createShortUrl(CreateUrlRequest request) {

        if (request.getOriginalUrl() == null
                || request.getOriginalUrl().isBlank()) {

            throw new RuntimeException("Original URL is required");
        }

        String shortCode;

        if (request.getCustomCode() != null
                && !request.getCustomCode().isBlank()) {

            shortCode = request.getCustomCode()
                    .trim()
                    .toLowerCase();

            validateCustomCode(shortCode);

        } else {

            do {
                shortCode = shortCodeService.generate()
                        .trim()
                        .toLowerCase();

            } while (urlRepo.existsByShortCode(shortCode));
        }

        int expiryDays = 30;
        if (request.getExpiryDays() != null) {
            if (request.getExpiryDays() > 30 || request.getExpiryDays() < 1) {
                throw new RuntimeException("Validity must be between 1 and 30 days");
            }
            expiryDays = request.getExpiryDays();
        }

        UrlMapping urlMapping = UrlMapping.builder()
                .originalUrl(request.getOriginalUrl())
                .shortCode(shortCode)
                .clicks(0L)
                .createdAt(LocalDateTime.now())
                .expriresAt(LocalDateTime.now().plusDays(expiryDays))
                .build();

        urlRepo.save(urlMapping);

        return urlMapping ;
    }

    public boolean doesExist(String shortCode){

        return urlRepo.existsByShortCode(shortCode);
    }

    private void validateCustomCode(String shortCode) {

        if (!shortCode.matches("^[a-zA-Z0-9_-]{3,30}$")) {

            throw new RuntimeException(
                    "Invalid custom code"
            );
        }

        if (DISALLOWED.contains(shortCode)) {

            throw new RuntimeException(
                    "Reserved alias"
            );
        }

        if (urlRepo.existsByShortCode(shortCode)) {

            throw new RuntimeException(
                    "Alias already exists"
            );
        }
    }

    public String resolveUrl(String shortCode){

        String key = "url:" + shortCode ;

        Object cached = redisService.get(key);

        if(cached != null){

            return cached.toString();
        }

        UrlMapping url = urlRepo.findByShortCode(shortCode)
                .orElseThrow(() ->new RuntimeException("Invalid Code"));

        if(url.getExpriresAt() != null && LocalDateTime.now().isAfter(url.getExpriresAt())){
            urlRepo.deleteByShortCode(shortCode);
            throw new  RuntimeException("CODE EXPIRED");
        }

        redisService.save(
                key ,url.getOriginalUrl() ,
                Duration.ofHours(24)
        );

        return url.getOriginalUrl() ;
    }
}

