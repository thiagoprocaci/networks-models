package com.tbp.network.structure.dtw.distance;


public class SimpleDistance implements DistanceFunction {
    @Override
    public double distance(double a, double b) {
        double diff = a - b;
        return Math.abs(diff);
    }
}
