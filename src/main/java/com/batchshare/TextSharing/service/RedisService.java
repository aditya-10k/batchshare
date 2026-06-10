package com.batchshare.TextSharing.service;

import lombok.NoArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

@Service
@NoArgsConstructor
public class RedisService {

    @Autowired

    private RedisTemplate<String , Object> redisTemplate ;

    public void save(String key , Object value , Duration time){

        redisTemplate.opsForValue().set(key , value , time);
    }

    public void delete(String key){

        redisTemplate.delete(key) ;
    }

    public Object get(String key){
        return redisTemplate.opsForValue().get(key);
    }
}

