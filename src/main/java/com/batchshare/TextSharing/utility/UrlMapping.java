package com.batchshare.TextSharing.utility;

import lombok.Builder;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Data
@Document(collection = "urls")
@Builder
public class UrlMapping {

    @Id
    private String id ;

    private String originalUrl ;


    private String shortCode ;

    private Long clicks ;

    private LocalDateTime createdAt ;

    private LocalDateTime expriresAt ;
}

