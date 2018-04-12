package com.tbp.database.service;


import com.tbp.database.model.GraphAnalysisContext;
import com.tbp.database.model.StructAnalysisContext;
import com.tbp.database.model.StructDistance;
import com.tbp.database.repository.GraphAnalysisContextRepository;
import com.tbp.database.repository.StructAnalysisContextRepository;
import com.tbp.database.repository.StructDistanceRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;

@Service
public class StructDistanceService {

    private static final Logger LOGGER = LoggerFactory.getLogger(StructDistanceService.class);

    @Autowired
    GraphAnalysisContextRepository graphAnalysisContextRepository;
    @Autowired
    StructAnalysisContextRepository structAnalysisContextRepository;
    @Autowired
    StructDistanceRepository structDistanceRepository;

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
