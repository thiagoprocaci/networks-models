package com.tbp.network.mst;



import com.tbp.network.mst.priorityqueues.MinPriorityQueue;
import com.tbp.network.mst.priorityqueues.PriorityQueue;
import com.tbp.network.mst.support.ComparableEdge;
import com.tbp.network.mst.support.Queue;
import com.tbp.network.mst.unionfind.UnionFind;
import com.tbp.network.structure.model.StructuralDistanceDto;
import org.graphstream.graph.Graph;

import java.util.Collection;
import java.util.List;
import java.util.Map;

public abstract class KruskalMST {
    // MST = minimun spanning tree (arvore geradora minima)

    private double weight;  // weight of MST
    private Queue<ComparableEdge> mst;  // edges in MST
    private UnionFind uf;   // selected union-find algorithm


    public void run(Collection<? extends  ComparableEdge> G, int nodeCount) {
        mst = new Queue<>();
        weight = 0d;
        // more efficient to build heap by passing array of edges
        PriorityQueue<ComparableEdge> pq = new MinPriorityQueue<>();
        for (ComparableEdge e : G) {
            pq.insert(e);
        }
        uf = createUnionFindAlgorithm(nodeCount);
        // run greedy algorithm
        while (!pq.isEmpty() && (mst.size() < nodeCount - 1)) {
            ComparableEdge e = pq.delete();
            int v = e.getNode();
            int w = e.getOtherNode();
            if (!uf.connected(v, w)) { // v-w does not create a cycle
                uf.union(v, w);  // merge v and w components
                mst.enqueue(e);  // add edge e to mst
                weight += e.getDistance();
            }
        }
    }

    public void run(Map<String, ? extends  ComparableEdge> G, Graph oldGraph) {
        run(G.values(), oldGraph.getNodeCount());
    }

    public UnionFind getUf() {
        return uf;
    }

    public Iterable<? extends ComparableEdge> edges() {
        return mst;
    }

    public double weight() {
        return weight;
    }

    public abstract UnionFind createUnionFindAlgorithm(int numberOfNodes);
}
