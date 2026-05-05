package com.textshare.TextSharing.utility;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import org.bson.types.ObjectId;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;
import java.util.List;

@Document(collection = "chats")
@Data
@NoArgsConstructor
public class ChatMessage {

    @Id
    @JsonSerialize(using = ToStringSerializer.class)
    private ObjectId id ;

    @NonNull
    private String chatCode ;

    private String sentBy ;

    private String message ;

    private LocalDateTime sentDate = LocalDateTime.now();

    private messageType type ;

    private List<String> urls ;

}
