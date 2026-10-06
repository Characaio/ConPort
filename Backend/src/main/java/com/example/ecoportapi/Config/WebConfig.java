package com.example.ecoportapi.Config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${file.upload-dir}")
    private String diretorioUpload;

    @Override
    public void addResourceHandlers(
            ResourceHandlerRegistry registry
    ) {
        registry.addResourceHandler(
                "/uploads/reports/**"
        ).addResourceLocations(
                "file:" + diretorioUpload + "/"
        );
    }
}
