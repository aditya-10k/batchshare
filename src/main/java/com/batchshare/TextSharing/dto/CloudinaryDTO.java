package com.batchshare.TextSharing.dto;

import lombok.Builder;

@Builder
public record CloudinaryDTO(
        String publicId ,
        String message ,
        String secureUrl
) {

}

