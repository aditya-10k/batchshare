package com.batchshare.TextSharing.controller;

import com.batchshare.TextSharing.dto.CreateUrlRequest;
import com.batchshare.TextSharing.dto.UrlDTO;
import com.batchshare.TextSharing.service.UrlService;
import com.batchshare.TextSharing.utility.UrlMapping;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/urlshortner")
public class UrlShortnerController {

    @Autowired
    private UrlService urlService ;

    @Value("${BASE_URL}")
    String baseUrl ;


    @PostMapping("/shorten")
    public ResponseEntity<UrlDTO> shorten(@RequestBody CreateUrlRequest request){

        UrlMapping url = urlService.createShortUrl(request);

        String shorturl = baseUrl + url.getShortCode() ;

       return ResponseEntity.ok(UrlDTO.builder()
                .originalUrl(url.getOriginalUrl())
                .shortenedUrl(shorturl)
                .expiresAt(url.getExpriresAt())
                .build());
    }

    @GetMapping("/exists/{code}")
    public ResponseEntity<Map<String,Boolean>> doesExist(@PathVariable String code){

       Boolean ans =  urlService.doesExist(code);

       return ResponseEntity.ok(Map.of("exists", ans));
    }

    @GetMapping("resolve/{code}")
    public ResponseEntity<Map<String, String>> resolve(@PathVariable String code){

        return ResponseEntity.ok(Map.of("original_url" , urlService.resolveUrl(code)));
    }
}

