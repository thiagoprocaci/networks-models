package com.tbp.network.structure.distance;


public class OtherDistance implements DistanceFunction {
    public double distance(double a, double b) {
        return (Math.max(a,b)/Math.min(a,b) ) - 1;
    }
}
