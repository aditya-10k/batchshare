package com.batchshare.TextSharing.service;

import com.batchshare.TextSharing.repo.ChatRoomRepo;
import com.batchshare.TextSharing.utility.ChatMessage;
import com.batchshare.TextSharing.utility.ChatRoom;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.List;

@Component
public class ChatRoomService {

    @Autowired
    private ChatRoomRepo chatRoomRepo;


    public ChatMessage addChatMessage(String chatCode , ChatMessage chatMessage){

        ChatRoom chatRoom = chatRoomRepo.findByChatCode(chatCode)
                .orElseThrow();

        chatRoom.getMessages().add(chatMessage);

        chatRoomRepo.save(chatRoom);

        return chatMessage ;
    }

    public List<ChatMessage> getAllMessagesforRoom(String roomCode){
       ChatRoom chatRoom =  chatRoomRepo.findByChatCode(roomCode).orElse(null);
       if (chatRoom == null) {
           return new ArrayList<>();
       }
       return chatRoom.getMessages();
    }

//    public ChatMessage addMessage(ChatMessage chatMessage){
//        chatMessageRepo.save(chatMessage);
//
//        Optional<ChatRoom> chatRoom = chatRoomRepo.findByChatCode(chatMessage.getChatCode());
//        if(chatRoom.isPresent()){
//            ChatRoom room = chatRoom.get();
//            room.getMessages().add(chatMessage);
//            chatRoomRepo.save(room);
//        }
//        return chatMessage;
//    }

    private static final SecureRandom secureRandom = new SecureRandom();
    private static final  String permittedNos = "1234567890";

    public String generateRoomCode(){
        StringBuilder sb = new StringBuilder();

        do {
            for (int i = 0; i <=5; i++) {
                sb.append(permittedNos.charAt(secureRandom.nextInt(permittedNos.length())));
            }
        }while (chatRoomRepo.findByChatCode(sb.toString()).isPresent());
        return sb.toString();
    }

    public String createRoom(){
      ChatRoom chatRoom = new ChatRoom();
      String roomCode =generateRoomCode();
      chatRoom.setChatCode(roomCode);
      chatRoomRepo.save(chatRoom);
      return roomCode;
    }
}

