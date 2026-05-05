package com.textshare.TextSharing.controller;

import com.textshare.TextSharing.dto.ApiFormatter;
import com.textshare.TextSharing.service.ChatRoomService;
import com.textshare.TextSharing.utility.ChatMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@Controller
@RestController
public class ChatController {

    @Autowired
    private ChatRoomService chatRoomService;

    @MessageMapping("/sendMessage/{id}")
    @SendTo("/chats/newChats/{id}")
    public ChatMessage sendMessage(ChatMessage chatMessage, @PathVariable String id){

        chatRoomService.addMessage(chatMessage);
        return chatMessage;
    }

    @GetMapping("/createRoom")
    public ResponseEntity<ApiFormatter> createRoom(){
        String code =chatRoomService.createRoom();
        return ApiFormatter.created(code , "Room Created Successfully!");
    }


}
