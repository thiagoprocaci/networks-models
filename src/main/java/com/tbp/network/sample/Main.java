package com.tbp.network.sample;


import com.tbp.network.model.BarabasiModel;
import com.tbp.network.model.NetworkModel;
import com.tbp.network.model.RegenerateModel;
import com.tbp.network.performance.PerformanceTime;
import com.tbp.network.structure.CompleteStructuralDistance;
import com.tbp.network.structure.StructuralDistance;
import com.tbp.network.structure.ThirdQuStructuralDistance;
import com.tbp.network.structure.degreeseq.DegreeSequence;
import com.tbp.network.structure.dtw.DTW;
import com.tbp.network.structure.dtw.TraditionalDTW;
import com.tbp.network.structure.dtw.distance.OtherDistance;
import com.tbp.network.structure.model.StructuralDistanceDto;

import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


import java.util.Iterator;
import java.util.Map;


public class Main {

    private static final Logger LOGGER = LoggerFactory.getLogger(Main.class);

    PerformanceTime performanceTime;

    public Main() {
        performanceTime = new PerformanceTime();
        NetworkModel model = createNetwork();
        LOGGER.info(model.toString());
        LOGGER.info("Number of nodes = {} and edges =  {}", model.getGraph().getNodeCount(), model.getGraph().getEdgeCount());
        //iterateOverAllPairs(model.getGraph());
        Map<String, StructuralDistanceDto> dtoMap = structuralDistance(model);
        performanceTime.avgTime();
        recreateNetwork(dtoMap, model);
        model.getGraph().display();
    }

    private void iterateOverAllPairs(Graph g) {
        performanceTime.addStartTime("ALL_PAIRS");
        Iterator<? extends Node> node1Iterator = g.getEachNode().iterator();
        while(node1Iterator.hasNext()) {
            Node firstNode = node1Iterator.next();
            String node1 = firstNode.getId();
            Iterator<? extends Node> node2Iterator = g.getEachNode().iterator();
            while(node2Iterator.hasNext()) {
                Node secondNode = node2Iterator.next();
                String node2 = secondNode.getId();
                if(node1.equals(node2)) {
                    continue;
                }
            }
        }
        performanceTime.addTotalTime("ALL_PAIRS");
    }


    NetworkModel createNetwork() {
        LOGGER.info("Starting model creation");
        long startTime = System.currentTimeMillis();
        NetworkModel model =  new BarabasiModel(5000, performanceTime );
        long totalTime = System.currentTimeMillis() - startTime;
        LOGGER.info("Model creation took {} ms - {} s", totalTime, totalTime/1000);
        return model;
    }

    Map<String, StructuralDistanceDto>  structuralDistance(NetworkModel model) {
        LOGGER.info("Starting structural distance execution");
        long startTime = System.currentTimeMillis();
        DegreeSequence degreeSequence = new DegreeSequence();
        DTW dtw  = new TraditionalDTW(new OtherDistance()); //
        StructuralDistance structuralDistance =  new ThirdQuStructuralDistance(degreeSequence, dtw, performanceTime);

        //new CompleteStructuralDistance(degreeSequence, dtw, performanceTime);
        Map<String, StructuralDistanceDto> distanceDtoMap = structuralDistance.execute(model, 1);
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
