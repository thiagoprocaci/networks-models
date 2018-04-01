package com.tbp.network.mst;


import com.tbp.network.mst.unionfind.QuickFind;
import com.tbp.network.mst.unionfind.UnionFind;

public class KruskalQuickFind extends KruskalMST {

    @Override
    public UnionFind createUnionFindAlgorithm(int numberOfNodes) {
        return new QuickFind(numberOfNodes);
    }
}
