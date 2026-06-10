package com.batchshare.TextSharing.utility;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.Data;
import lombok.Generated;
import lombok.NoArgsConstructor;
import lombok.NonNull;
import org.bson.types.ObjectId;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.data.annotation.Id;


import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
public class ChatMessage {

    @Id
    private String id ;

    private String sentBy ;

    private String message ;

    private LocalDateTime sentDate = LocalDateTime.now();

    private messageType type ;

    private List<String> urls ;

    private List<String> publicId ;

}

