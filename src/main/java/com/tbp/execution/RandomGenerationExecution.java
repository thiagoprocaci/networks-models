package com.tbp.execution;

import com.tbp.Main;
import com.tbp.execution.support.GraphIO;
import com.tbp.network.model.BarabasiModel;
import com.tbp.network.model.NetworkModel;
import com.tbp.network.model.regenerate.OldGraphBasedModel;
import com.tbp.network.performance.PerformanceTime;
import com.tbp.network.structure.CompleteStructuralDistance;
import com.tbp.network.structure.StructuralDistance;
import com.tbp.network.structure.degreeseq.DegreeSequence;
import com.tbp.network.structure.dtw.DTW;
import com.tbp.network.structure.dtw.TraditionalDTW;
import com.tbp.network.structure.dtw.distance.OtherDistance;
import com.tbp.network.structure.model.StructuralDistanceDto;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class RandomGenerationExecution {

    private static final Logger LOGGER = LoggerFactory.getLogger(Main.class);
    @Autowired
    GraphIO graphIO;
    public void execute() {
        PerformanceTime performanceTime = new PerformanceTime();
        NetworkModel model = createNetwork(performanceTime);
        LOGGER.info(model.toString());
        LOGGER.info("Number of nodes = {} and edges =  {}", model.getGraph().getNodeCount(), model.getGraph().getEdgeCount());
        Map<String, StructuralDistanceDto> dtoMap = structuralDistance(model, performanceTime);
        performanceTime.avgTime();
        recreateNetwork(dtoMap, model);
        graphIO.saveModel(model.getGraph());
       // model.getGraph().display();

    }

    NetworkModel createNetwork(PerformanceTime performanceTime ) {
        LOGGER.info("Starting model creation");
        long startTime = System.currentTimeMillis();
        NetworkModel model =  new BarabasiModel(1000, performanceTime );
        long totalTime = System.currentTimeMillis() - startTime;
        LOGGER.info("Model creation took {} ms - {} s", totalTime, totalTime/1000);
        return model;
    }

    Map<String, StructuralDistanceDto> structuralDistance(NetworkModel model,  PerformanceTime performanceTime ) {
        LOGGER.info("Starting structural distance execution");
        long startTime = System.currentTimeMillis();
        DegreeSequence degreeSequence = new DegreeSequence();
        DTW dtw  = new TraditionalDTW(new OtherDistance());
        StructuralDistance structuralDistance =  new CompleteStructuralDistance(degreeSequence, dtw, performanceTime);

        Map<String, StructuralDistanceDto> distanceDtoMap = structuralDistance.execute(model, 1);
        long totalTime = System.currentTimeMillis() - startTime;
        LOGGER.info("Structural distance execution took {} ms - {} s", totalTime, totalTime/1000);
        return  distanceDtoMap;
    }

    void recreateNetwork( Map<String, StructuralDistanceDto> distanceDtoMap, NetworkModel model) {
        LOGGER.info("Network recreation");
        long startTime = System.currentTimeMillis();
        OldGraphBasedModel regenerateModel = new OldGraphBasedModel(model.getGraph(), distanceDtoMap);
        long totalTime = System.currentTimeMillis() - startTime;
        LOGGER.info("Network recreation took {} ms - {} s", totalTime, totalTime/1000);
     //   regenerateModel.getGraph().display();
        graphIO.saveModel(regenerateModel.getGraph());
    }

}
