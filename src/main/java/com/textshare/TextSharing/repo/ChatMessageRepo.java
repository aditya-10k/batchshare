package com.textshare.TextSharing.repo;

import com.textshare.TextSharing.utility.ChatMessage;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface ChatMessageRepo extends MongoRepository<ChatMessage , ObjectId> {
}
