package com.animalsSpeak.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.ServletComponentScan;
import org.mybatis.spring.annotation.MapperScan;

@SpringBootApplication
@MapperScan("com.animalsSpeak.backend.mapper") 
@ServletComponentScan
public class AnimalsSpeak {
	
	public static void main(String[] args) {
		SpringApplication.run(AnimalsSpeak.class, args);
	}
	
}
