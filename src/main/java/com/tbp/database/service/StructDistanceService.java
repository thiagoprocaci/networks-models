package com.tbp.database.service;


import com.tbp.database.model.GraphAnalysisContext;
import com.tbp.database.model.StructAnalysisContext;
import com.tbp.database.model.StructDistance;
import com.tbp.database.repository.GraphAnalysisContextRepository;
import com.tbp.database.repository.StructAnalysisContextRepository;
import com.tbp.database.repository.StructDistanceRepository;
import com.tbp.network.structure.StructuralDistanceSupport;
import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;

@Service
public class StructDistanceService {

    private static final Logger LOGGER = LoggerFactory.getLogger(StructDistanceService.class);
    private static final String UPDATE_DISTANCE_1 = "update struct_distance set distance_custom_dtw_1 = %s where id = %s";


    @Autowired
    GraphAnalysisContextRepository graphAnalysisContextRepository;
    @Autowired
    StructAnalysisContextRepository structAnalysisContextRepository;
    @Autowired
    StructDistanceRepository structDistanceRepository;
    @Autowired
    GraphService graphService;
    @Autowired
    StructuralDistanceSupport structuralDistanceSupport;
    @Autowired
    JdbcTemplate jdbcTemplate;


    String[] generateUpdateDistance1(List<StructDistance> list) {
        String[] sqlList = new String[list.size()];
        int i = 0;
        for(StructDistance s: list) {
            String sql = String.format(UPDATE_DISTANCE_1, s.getDistance1(), s.getId());
            sqlList[i] = sql;
            i++;
        }
        return sqlList;
    }

    public void structuralDistanceOne(String communityName) {
        int maxDistance = 1;
        GraphAnalysisContext latest = graphAnalysisContextRepository.getLatest(communityName);
        StructAnalysisContext structAnalysisContext = structAnalysisContextRepository.findByGraphAnalysisContext(latest);
        List<StructDistance> list = structDistanceRepository.findWithDistance1Null(structAnalysisContext.getId());
        LOGGER.info("Retrieved {} edges of {} to calculate structural distance (max hop-count = {})", list.size(), communityName, maxDistance);
        Graph oldGraph = graphService.loadFromDatabase(communityName);
        int index = 0;
        while(!list.isEmpty()) {
            StructDistance structDistance = list.get(index);
            Node node1 = oldGraph.getNode(structDistance.getNode1().toString());
            Node node2 = oldGraph.getNode(structDistance.getNode2().toString());
            double distance = structuralDistanceSupport.dtwBetweenNodes(oldGraph, node1.getId(), node2.getId(), maxDistance);
            structDistance.setDistance1(distance);
            index++;
            if(index == list.size()) {
                index = 0;
                jdbcTemplate.batchUpdate(generateUpdateDistance1(list));
                LOGGER.info("Saved {} pair of nodes with their structural distance (max hop-count = {})", list.size(), maxDistance);
                list = structDistanceRepository.findWithDistance1Null(structAnalysisContext.getId());
                LOGGER.info("Retrieved {} edges of {} to calculate structural distance (max hop-count = {})", list.size(), communityName, maxDistance);
            }
        }
    }


    public void prepareContext(String communityName) {
        GraphAnalysisContext latest = graphAnalysisContextRepository.getLatest(communityName);
        List<BigInteger> nodeIdList = graphAnalysisContextRepository.findNodeIdList(latest.getId());

        if(nodeIdList != null && !nodeIdList.isEmpty()) {
            StructAnalysisContext structAnalysisContext = new StructAnalysisContext(latest, "Structural distance test in " + communityName);
            structAnalysisContext = structAnalysisContextRepository.save(structAnalysisContext);
            LOGGER.info("Total of {} nodes to be analysed", nodeIdList.size());

            BigInteger totalCombinations = factorial(nodeIdList.size()).divide(factorial(2).multiply(factorial(nodeIdList.size() - 2)));
            List<StructDistance> structDistanceList = new ArrayList<>();
            long count = 0;
            for(int i = 0; i < nodeIdList.size(); i++) {
                for(int j = (i + 1); j < nodeIdList.size(); j++) {
                    count++;
                    StructDistance structDistance = new StructDistance(nodeIdList.get(i), nodeIdList.get(j), structAnalysisContext);
                    structDistanceList.add(structDistance);
                    if(structDistanceList.size() == 100000) {
                        saveStructDistanceList(structDistanceList, totalCombinations, count);
                    }
                }
            }
            if(!structDistanceList.isEmpty()) {
                saveStructDistanceList(structDistanceList, totalCombinations, count);
            }
        }
        LOGGER.info("Finishing {}", communityName);
    }

    void saveStructDistanceList(List<StructDistance> structDistanceList, BigInteger totalCombinations, long count) {
        long startTime = System.currentTimeMillis();
        structDistanceRepository.save(structDistanceList);
        structDistanceList.clear();
        long totalTime = System.currentTimeMillis() - startTime;
        LOGGER.info("Saved {} StructDistance objects of {} - Takes {} s", count, totalCombinations, totalTime/1000);
    }


    BigInteger factorial(Integer number) {
        BigInteger result = BigInteger.valueOf(1);
        for (long factor = 2; factor <= number.longValue(); factor++) {
            result = result.multiply(BigInteger.valueOf(factor));
        }
        return result;
    }

}
