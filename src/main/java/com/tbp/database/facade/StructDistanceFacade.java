package com.tbp.database.facade;


import com.tbp.database.service.StructDistanceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class StructDistanceFacade {

    @Autowired
    StructDistanceService structDistanceService;


    public void prepareContext() {
        structDistanceService.prepareContext("biology.stackexchange.com");
        structDistanceService.prepareContext("chemistry.stackexchange.com");
    }

    public void structuralDistanceOne() {
        structDistanceService.structuralDistanceOne("biology.stackexchange.com");
    }


}
