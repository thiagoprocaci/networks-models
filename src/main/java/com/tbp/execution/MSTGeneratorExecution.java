package com.tbp.execution;

import com.tbp.database.model.view.BiologyStructDistanceCustomDtw1;
import com.tbp.database.repository.view.BiologyStructDistanceCustomDtw1Repository;
import com.tbp.execution.support.GraphIO;
import com.tbp.network.model.regenerate.DatabaseViewBasedModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigInteger;
import java.util.*;

@Component
public class MSTGeneratorExecution {

    private static final Logger LOGGER = LoggerFactory.getLogger(MSTGeneratorExecution.class);
    @Autowired
    BiologyStructDistanceCustomDtw1Repository biologyStructDistanceCustomDtw1Repository;
    @Autowired
    GraphIO graphIO;

    @Transactional
    public void execute() {
        LOGGER.info("Getting node count");
        Integer nodeCount = biologyStructDistanceCustomDtw1Repository.getNodeCount();
        LOGGER.info("Found {} nodes", nodeCount);
        LOGGER.info("Getting distances ...");
        List<BiologyStructDistanceCustomDtw1> list = biologyStructDistanceCustomDtw1Repository.findClosestDistance();



        LOGGER.info("Starting model generation");
        DatabaseViewBasedModel model = new DatabaseViewBasedModel(list, nodeCount);
        LOGGER.info("Number of nodes = {} and edges =  {}", model.getGraph().getNodeCount(), model.getGraph().getEdgeCount());
        graphIO.saveModel(model.getGraph());

    }


}
