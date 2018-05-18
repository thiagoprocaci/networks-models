package com.tbp;

import com.tbp.execution.MSTGeneratorExecution;
import com.tbp.execution.RandomGenerationExecution;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Main implements CommandLineRunner {


    @Autowired
    RandomGenerationExecution randomGenerationExecution;
    @Autowired
    MSTGeneratorExecution mstGeneratorExecution;


    public static void main(String args[]) {
        //RandomGenerationExecution randomGenerationExecution = new RandomGenerationExecution();
        //randomGenerationExecution.execute();
        SpringApplication.run(Main.class, args);
    }



    @Override
    public void run(String... strings) throws Exception {
        //randomGenerationExecution.execute();
        mstGeneratorExecution.execute();
    }
}
