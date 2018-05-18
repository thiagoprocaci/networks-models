package com.tbp.execution;

import com.tbp.database.facade.StructDistanceFacade;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class CustomDtwDistanceOneExecution {

    @Autowired
    StructDistanceFacade structDistanceFacade;

    public void execute() {
        structDistanceFacade.structuralDistanceOne();
    }
}
