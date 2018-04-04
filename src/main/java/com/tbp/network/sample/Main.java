package com.tbp.network.sample;


import com.tbp.network.model.BarabasiModel;
import com.tbp.network.model.NetworkModel;
import com.tbp.network.model.RegenerateModel;
import com.tbp.network.performance.PerformanceTime;
import com.tbp.network.structure.StructuralDistance;
import com.tbp.network.structure.degreeseq.DegreeSequence;
import com.tbp.network.structure.dtw.DTW;
import com.tbp.network.structure.dtw.distance.OtherDistance;
import com.tbp.network.structure.model.StructuralDistanceDto;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


import java.util.Map;


public class Main {

    private static final Logger LOGGER = LoggerFactory.getLogger(Main.class);

    PerformanceTime performanceTime;

    public Main() {
        performanceTime = new PerformanceTime();
        NetworkModel model = createNetwork();
        LOGGER.info(model.toString());
        LOGGER.info("Number of nodes = {} and edges =  {}", model.getGraph().getNodeCount(), model.getGraph().getEdgeCount());
        //  iterateOverAllPairs(model.getGraph());
        Map<String, StructuralDistanceDto> dtoMap = structuralDistance(model);
        performanceTime.avgTime();
        recreateNetwork(dtoMap, model);
        model.getGraph().display();
    }




    NetworkModel createNetwork() {
        LOGGER.info("Starting model creation");
        long startTime = System.currentTimeMillis();
        NetworkModel model =  new BarabasiModel(1000 * 1, performanceTime );
        long totalTime = System.currentTimeMillis() - startTime;
        LOGGER.info("Model creation took {} ms - {} s", totalTime, totalTime/1000);
        return model;
    }

    Map<String, StructuralDistanceDto>  structuralDistance(NetworkModel model) {
        LOGGER.info("Starting structural distance execution");
        long startTime = System.currentTimeMillis();
        DegreeSequence degreeSequence = new DegreeSequence();
        DTW dtw = new DTW(new OtherDistance());
        StructuralDistance structuralDistance = new StructuralDistance(degreeSequence, dtw, performanceTime);
        Map<String, StructuralDistanceDto> distanceDtoMap = structuralDistance.execute2(model.getGraph(), 1);
        long totalTime = System.currentTimeMillis() - startTime;
        LOGGER.info("Structural distance execution took {} ms - {} s", totalTime, totalTime/1000);
        return  distanceDtoMap;
    }

    void recreateNetwork( Map<String, StructuralDistanceDto> distanceDtoMap, NetworkModel model) {
        LOGGER.info("Network recreation");
        long startTime = System.currentTimeMillis();
        RegenerateModel regenerateModel = new RegenerateModel(model.getGraph(), distanceDtoMap);
        long totalTime = System.currentTimeMillis() - startTime;
        LOGGER.info("Network recreation took {} ms - {} s", totalTime, totalTime/1000);
        regenerateModel.getGraph().display();
    }


    public static void main(String args[]) {
       new Main();
    }


}
