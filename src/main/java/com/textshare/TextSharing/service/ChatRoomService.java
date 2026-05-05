package com.textshare.TextSharing.service;

import com.textshare.TextSharing.repo.ChatMessageRepo;
import com.textshare.TextSharing.repo.ChatRoomRepo;
import com.textshare.TextSharing.utility.ChatMessage;
import com.textshare.TextSharing.utility.ChatRoom;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.security.SecureRandom;
import java.util.List;
import java.util.Optional;

@Component
public class ChatRoomService {

    @Autowired
    private ChatRoomRepo chatRoomRepo;

    @Autowired
    private ChatMessageRepo chatMessageRepo;

    public List<?> getMessagesforRoom(String roomCode){
       ChatRoom chatRoom =  chatRoomRepo.findByChatCode(roomCode).orElse(null);
       return chatRoom.getMessages();
    }

    public ChatMessage addMessage(ChatMessage chatMessage){
        chatMessageRepo.save(chatMessage);

        Optional<ChatRoom> chatRoom = chatRoomRepo.findByChatCode(chatMessage.getChatCode());
        if(chatRoom.isPresent()){
            ChatRoom room = chatRoom.get();
            room.getMessages().add(chatMessage);
            chatRoomRepo.save(room);
        }
        return chatMessage;
    }

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
