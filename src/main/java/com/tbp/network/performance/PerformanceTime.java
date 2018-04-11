package com.tbp.network.performance;


import org.apache.commons.math.stat.descriptive.DescriptiveStatistics;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

public class PerformanceTime {

    private static final Logger LOGGER = LoggerFactory.getLogger(PerformanceTime.class);
    Map<String, List<Long>> totalTimeMap = new HashMap<>();
    Map<String, Long> startTimeMap = new HashMap<>();

    public void addStartTime(String id) {
        startTimeMap.put(id, System.currentTimeMillis());
    }

    public void addTotalTime(String id) {
        Long startTime = startTimeMap.get(id);
        if(startTime != null) {
            if(totalTimeMap.get(id) == null) {
                totalTimeMap.put(id, new ArrayList<Long>());
            }
            totalTimeMap.get(id).add(System.currentTimeMillis() - startTime);
            startTimeMap.remove(id);
        } else {
            LOGGER.warn("Impossible to know the total time of {} since there is not start time", id);
        }
    }


    void avgTime(String id) {
        List<Long> longList = totalTimeMap.get(id);
        DescriptiveStatistics descriptiveStatistics = new DescriptiveStatistics();
        if(longList != null && !longList.isEmpty()) {
            for(Long time : longList) {
                descriptiveStatistics.addValue(time);
            }
            LOGGER.info(getStats(descriptiveStatistics, id));
        }
    }


    public void avgTime() {
        Set<String> strings = totalTimeMap.keySet();
        for(String id : strings) {
            avgTime(id);
        }
        totalTimeMap.clear();
    }


    String getStats(DescriptiveStatistics descriptiveStatistics, String id) {
        double min = descriptiveStatistics.getMin();
        double firstQu = descriptiveStatistics.getPercentile(25);
        double median = descriptiveStatistics.getPercentile(50);
        double mean = descriptiveStatistics.getMean();
        double thirdQu = descriptiveStatistics.getPercentile(75);
        double max = descriptiveStatistics.getMax();
        return id + " ms {" +
                "min=" + min +
                ", firstQu=" + firstQu +
                ", median=" + median +
                ", mean=" + mean +
                ", thirdQu=" + thirdQu +
                ", max=" + max +
                '}';
    }



}
