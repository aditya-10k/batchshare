package com.batchshare.TextSharing.scheduler;

import com.batchshare.TextSharing.repo.UrlRepo;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@RequiredArgsConstructor
public class ExpiredLinksCleanUpScheduler {

    private final UrlRepo urlRepo;

    @Scheduled(fixedRate = 86400000) // Runs every 24 hours (86,400,000 ms)
    public void cleanExpiredLinks() {
        LocalDateTime now = LocalDateTime.now();
        urlRepo.deleteByExpriresAtBefore(now);
        System.out.println("Expired links cleaned up");
    }
}
