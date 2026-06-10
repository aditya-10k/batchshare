package com.batchshare.TextSharing.dto;

import lombok.Data;

@Data
public class CreateUrlRequest {

    private String originalUrl ;

    private String customCode ;

    private Integer expiryDays ;
}

