package com.tbp.network.performance;


import com.tbp.network.sample.Main;
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
        if(longList != null && !longList.isEmpty()) {
            double sum = 0;
            for(Long time : longList) {
                sum = sum + time;
            }
            double avgTime = sum/longList.size();
            avgTime = Math.floor(avgTime * 100) / 100;
            LOGGER.info("Avg. time of {} equals to {} ms - {} s.", id, avgTime, avgTime/1000);
        }
    }


    public void avgTime() {
        Set<String> strings = totalTimeMap.keySet();
        for(String id : strings) {
            avgTime(id);
        }
        totalTimeMap.clear();
    }




}
