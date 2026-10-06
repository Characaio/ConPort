package com.example.ecoportapi.Security;

import io.jsonwebtoken.security.Keys;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import io.jsonwebtoken.Jwts;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.sql.Date;
import java.time.Instant;
import java.time.LocalDateTime;

@Service
public class JwtService {
    private final String SECRET_KEY = "MUDAR-ISSO-DEPOIS-PARA-UMA-VARIAVEL-DE-AMBIENTE-AAAAAAAA";

    public String GenerateToken(UserDetails userDetails){


        Long MILISEGUNDOS = 1000L;
        Long SEGUNDOS = 60L;
        Long MINUTOS = 60L;
        Long HORAS = 24L;
        return Jwts.builder()
                .subject(userDetails.getUsername())
                .issuedAt(Date.from(Instant.now()))
                .expiration(
                        new Date(System.currentTimeMillis() +
                                MILISEGUNDOS * SEGUNDOS * MINUTOS * HORAS)
                )
                .signWith(getSignInKey())
                .compact();
    }

    private SecretKey getSignInKey(){
        return Keys.hmacShaKeyFor(
                SECRET_KEY.getBytes(StandardCharsets.UTF_8)
        );
    }

    public String extractUsername(String token) {
        return Jwts
                .parser()
                .verifyWith(getSignInKey())
                .build()
                .parseSignedClaims(token)
                .getPayload()
                .getSubject();
    }

}
