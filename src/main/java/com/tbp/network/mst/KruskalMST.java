package com.tbp.network.mst;



import com.tbp.network.mst.priorityqueues.MinPriorityQueue;
import com.tbp.network.mst.priorityqueues.PriorityQueue;
import com.tbp.network.mst.support.Queue;
import com.tbp.network.mst.unionfind.UnionFind;
import com.tbp.network.structure.model.StructuralDistanceDto;
import org.graphstream.graph.Graph;

import java.util.Map;

public abstract class KruskalMST {
    // MST = minimun spanning tree (arvore geradora minima)

    private double weight;  // weight of MST
    private Queue<StructuralDistanceDto> mst;  // edges in MST
    private UnionFind uf;   // selected union-find algorithm



    public void run(Map<String, StructuralDistanceDto> G, Graph oldGraph) {
        mst = new Queue<>();
        weight = 0d;
        // more efficient to build heap by passing array of edges
        PriorityQueue<StructuralDistanceDto> pq = new MinPriorityQueue<>();
        for (StructuralDistanceDto e : G.values()) {
            pq.insert(e);
        }
        uf = createUnionFindAlgorithm(oldGraph.getNodeCount());
        // run greedy algorithm
        while (!pq.isEmpty() && (mst.size() < oldGraph.getNodeCount() - 1)) {
            StructuralDistanceDto e = pq.delete();
            int v = Integer.parseInt(e.getNode1());
            int w = Integer.parseInt(e.getNode2());
            if (!uf.connected(v, w)) { // v-w does not create a cycle
                uf.union(v, w);  // merge v and w components
                mst.enqueue(e);  // add edge e to mst
                weight += e.getStructDistance();
            }
        }
    }

    public UnionFind getUf() {
        return uf;
    }

    public Iterable<StructuralDistanceDto> edges() {
        return mst;
    }

    public double weight() {
        return weight;
    }

    public abstract UnionFind createUnionFindAlgorithm(int numberOfNodes);
}
