package com.agri;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.agri.mapper")
public class SmartAgriApplication {
    public static void main(String[] args) {
        SpringApplication.run(SmartAgriApplication.class, args);
    }
}
