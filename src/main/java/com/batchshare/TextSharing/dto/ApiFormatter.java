package com.batchshare.TextSharing.dto;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

public class ApiFormatter {

    private String message;
    private Object data ;

    public ApiFormatter(Object data , String message ){
        this.data = data;
        this.message = message;
    }

    public Object getData() {
        return data;
    }

    public String getMessage() {
        return message;
    }

    public ResponseEntity<ApiFormatter> success(Object data , String message){
        ApiFormatter response = new ApiFormatter(data , message);
        return new  ResponseEntity<>(response ,HttpStatus.OK);
    }

    public static ResponseEntity<ApiFormatter> created(Object data, String message){
        ApiFormatter response = new ApiFormatter(data ,message);
        return new ResponseEntity<>(response , HttpStatus.CREATED);
    }

    public ResponseEntity<ApiFormatter> notFound(Object data , String message){
        ApiFormatter response = new ApiFormatter(data ,message);
        return new ResponseEntity<>(response , HttpStatus.NOT_FOUND);
    }
}

