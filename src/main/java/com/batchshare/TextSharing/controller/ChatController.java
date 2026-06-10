package com.batchshare.TextSharing.controller;

import com.batchshare.TextSharing.dto.ApiFormatter;
import com.batchshare.TextSharing.dto.ChatMessagesDto;
import com.batchshare.TextSharing.repo.ChatRoomRepo;
import com.batchshare.TextSharing.service.ChatRoomService;
import com.batchshare.TextSharing.utility.ChatMessage;
import com.batchshare.TextSharing.utility.ChatRoom;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Controller
@RestController
public class ChatController {

    @Autowired
    private ChatRoomService chatRoomService;

    @Autowired
    private  SimpMessagingTemplate simpMessagingTemplate ;

    @Autowired
    private ChatRoomRepo chatRoomRepo ;

    @MessageMapping("/sendMessage/{chatRoomId}")
    public void sendMessage(@DestinationVariable String chatRoomId , ChatMessage chatMessage){

        ChatMessage savedChatMessage = chatRoomService.addChatMessage(chatRoomId ,chatMessage );

        simpMessagingTemplate.convertAndSend(
                "/chats/newChats/" + chatRoomId , savedChatMessage
        );
    }

    @GetMapping("/createRoom")
    public ResponseEntity<ApiFormatter> createRoom(){
        String code =chatRoomService.createRoom();
        return ApiFormatter.created(code , "Room Created Successfully!");
    }

    @GetMapping("/all-messages/{chatCode}")
    public ResponseEntity<ChatMessagesDto> fetchAllMessages(@PathVariable String chatCode){

        List<ChatMessage> messages = chatRoomService.getAllMessagesforRoom(chatCode);

        return ResponseEntity.ok(ChatMessagesDto.builder().roomCode(chatCode).messages(messages).build());
    }

    @GetMapping("/expiry")
    public List<ChatRoom> expiry(){

        return chatRoomRepo.findByExpiryDateBefore(LocalDateTime.now());

    }


}

