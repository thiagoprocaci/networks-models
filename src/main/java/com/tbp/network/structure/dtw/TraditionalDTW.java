package com.tbp.network.structure.dtw;


import com.tbp.network.structure.dtw.distance.DistanceFunction;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * Dynamic time warping implementation.
 * Details at: https://en.wikipedia.org/wiki/Dynamic_time_warping
 */
@Component
public class TraditionalDTW implements DTW {

    private static final Logger LOGGER = LoggerFactory.getLogger(TraditionalDTW.class);
    DistanceFunction distanceFunction;

    public TraditionalDTW(DistanceFunction distanceFunction) {
         this.distanceFunction = distanceFunction;
    }

    public double execute(List<Integer> s, List<Integer> t) {

            double[][] dtw = new double[s.size()][t.size()];

            for(int i = 0; i < s.size(); i++) {
                for(int j = 0; j < t.size(); j++) {
                    double cost = distance(s.get(i), t.get(j));
                    double a = (i - 1 >= 0) ? dtw[i-1][j] : Double.MAX_VALUE;
                    double b = (j - 1 >= 0) ? dtw[i][j-1] : Double.MAX_VALUE;
                    double c = ((i - 1 >= 0) && (j - 1 >= 0)) ? dtw[i-1][ j-1] : Double.MAX_VALUE;
                    if(Double.MAX_VALUE == a && Double.MAX_VALUE == b && Double.MAX_VALUE == c) {
                        dtw[i][j] = cost;
                    } else {
                        dtw[i][j] = cost + minimum(a, b, c);
                    }
                }
            }
            return  dtw[s.size()-1][t.size() -1];

    }

    private double distance(double a, double b) {
        return distanceFunction.distance(a,b);
    }

    private double minimum(double a, double b, double c) {
        double minAb = Math.min(a,b);
        double min = Math.min(minAb, c) ;
        return min;
    }

}
