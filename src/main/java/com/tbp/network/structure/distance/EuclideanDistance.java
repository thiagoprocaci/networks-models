package com.tbp.network.structure.distance;


public class EuclideanDistance implements DistanceFunction {
    public double distance(double a, double b) {
        double diff = a - b;
        return Math.abs(diff);
    }
}
