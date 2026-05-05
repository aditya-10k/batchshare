package com.textshare.TextSharing.utility;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@Document("chatRooms")
public class ChatRoom {

    @Id
    @JsonSerialize(using = ToStringSerializer.class)
    private ObjectId id;

    @NonNull
    private String chatCode ;

    @DBRef
    private List<ChatMessage> messages = new ArrayList<>();

    private LocalDateTime createdTime = LocalDateTime.now();

    private LocalDateTime expiryDate = LocalDateTime.now().plusHours(1);

}
