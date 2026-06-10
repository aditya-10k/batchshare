package com.batchshare.TextSharing.repo;

import com.batchshare.TextSharing.utility.UrlMapping;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

import java.time.LocalDateTime;

public interface UrlRepo extends MongoRepository<UrlMapping, String> {

    Optional<UrlMapping> findByShortCode(String shortCode);
    boolean existsByShortCode(String shortCode);
    void deleteByShortCode(String shortCode);
    void deleteByExpriresAtBefore(LocalDateTime dateTime);
}

