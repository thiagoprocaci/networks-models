package com.tbp.network.structure.dtw;

import com.dtw.TimeWarpInfo;
import com.timeseries.TimeSeries;
import com.util.DistanceFunction;
import com.util.DistanceFunctionFactory;

import java.util.List;

/**
 * Fast dtw implementation
 * @see https://github.com/rmaestre/FastDTW
 */
public class FastDtw implements DTW {
    @Override
    public double execute(List<Integer> s, List<Integer> t) {
        TimeSeries tsI = new TimeSeries(toDoubleArray(s));
        TimeSeries tsJ = new TimeSeries(toDoubleArray(t));
        final DistanceFunction distFn = DistanceFunctionFactory.getDistFnByName("EuclideanDistance");
        final TimeWarpInfo info = com.dtw.FastDTW.getWarpInfoBetween(tsI, tsJ, 3, distFn);
        return info.getDistance();
    }

    double[] toDoubleArray(List<Integer> list) {
        double[] array = new double[list.size()];
        for(int i = 0; i < list.size(); i++) {
            array[i] = list.get(i);
        }
        return array;
    }
}
