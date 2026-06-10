package com.batchshare.TextSharing.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class healthcheck {

    @GetMapping("/healthcheck")
    private String healthcheck(){
        return "okay";
    }
}

