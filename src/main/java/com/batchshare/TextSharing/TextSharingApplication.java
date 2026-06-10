package com.batchshare.TextSharing;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

@SpringBootApplication
@EnableScheduling
public class TextSharingApplication {

	public static void main(String[] args) {
		String[] envPaths = {".env", "TextSharing/.env"};
		boolean loaded = false;

		for (String path : envPaths) {
			java.nio.file.Path envPath = Paths.get(path);
			if (Files.exists(envPath)) {
				try {
					Files.lines(envPath)
						.map(String::trim)
						.filter(line -> !line.isEmpty() && !line.startsWith("#"))
						.forEach(line -> {
							String[] parts = line.split("=", 2);
							if (parts.length == 2) {
								System.setProperty(parts[0].trim(), parts[1].trim());
							}
						});
					System.out.println("Loaded environment variables from: " + envPath.toAbsolutePath());
					loaded = true;
					break;
				} catch (IOException e) {
					System.out.println("Failed to read environment file at " + path + ": " + e.getMessage());
				}
			}
		}

		if (!loaded) {
			System.out.println("No local .env file found in expected paths. Relying on system environment variables.");
		}

		SpringApplication.run(TextSharingApplication.class, args);
	}

}

