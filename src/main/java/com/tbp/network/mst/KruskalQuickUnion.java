package com.tbp.network.mst;


import com.tbp.network.mst.unionfind.QuickUnion;
import com.tbp.network.mst.unionfind.UnionFind;

public class KruskalQuickUnion extends KruskalMST {

    @Override
    public UnionFind createUnionFindAlgorithm(int numberOfNodes) {
        return new QuickUnion(numberOfNodes);
    }
}
