package com.batchshare.TextSharing.scheduler;

import com.batchshare.TextSharing.service.CloudinaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class RoomDeleteScheduler {

    @Autowired
    private CloudinaryService cloudinaryService ;

    @Scheduled(fixedRate = 3600000) // Runs every hour (3,600,000 ms)
    public void cleanUp() throws IOException {

        cloudinaryService.deleteFileAndRoom();
        System.out.println("Rooms cleaned");
    }
}

