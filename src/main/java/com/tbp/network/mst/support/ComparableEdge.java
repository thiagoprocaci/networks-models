package com.tbp.network.mst.support;


public interface ComparableEdge<T> extends Comparable<T> {

    Integer getNode();

    Integer getOtherNode();

    double getDistance();

}
