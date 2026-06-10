package com.batchshare.TextSharing.dto;

import com.batchshare.TextSharing.utility.ChatMessage;
import lombok.Builder;

import java.util.List;

@Builder
public record ChatMessagesDto(

     String roomCode ,

     List<ChatMessage> messages
     )
{}

