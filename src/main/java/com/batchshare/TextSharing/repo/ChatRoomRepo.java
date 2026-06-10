package com.batchshare.TextSharing.repo;

import com.batchshare.TextSharing.utility.ChatRoom;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ChatRoomRepo extends MongoRepository<ChatRoom, ObjectId> {

    Optional<ChatRoom> findByChatCode(String chatCode);

    List<ChatRoom> findByExpiryDateBefore(LocalDateTime expiryDate);
}

