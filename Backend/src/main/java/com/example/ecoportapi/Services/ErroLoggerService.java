package com.example.ecoportapi.Services;

import org.springframework.stereotype.Service;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.time.LocalDateTime;

@Service
public class ErroLoggerService {

    private final Path logFile = Path.of("logs/errors.log");

    public void registrarErro(Exception exception) {

        try {
            Files.createDirectories(logFile.getParent());

            StringWriter stackTrace = new StringWriter();
            exception.printStackTrace(new PrintWriter(stackTrace));

            String log = """
                    
                    ================================
                    Data: %s
                    Erro: %s
                    Mensagem: %s
                    
                    StackTrace:
                    %s
                    ================================
                    """.formatted(
                    LocalDateTime.now(),
                    exception.getClass().getName(),
                    exception.getMessage(),
                    stackTrace
            );

            Files.writeString(
                    logFile,
                    log,
                    StandardOpenOption.CREATE,
                    StandardOpenOption.APPEND
            );

        } catch (Exception e) {
            // Evita que uma falha no sistema de log derrube o tratamento original
            e.printStackTrace();
        }
    }
}