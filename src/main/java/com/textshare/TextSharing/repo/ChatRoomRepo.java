package com.textshare.TextSharing.repo;

import com.textshare.TextSharing.utility.ChatRoom;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ChatRoomRepo extends MongoRepository<ChatRoom, ObjectId> {

    Optional<ChatRoom> findByChatCode(String chatCode);
}
