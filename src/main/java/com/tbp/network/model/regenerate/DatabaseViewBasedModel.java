package com.tbp.network.model.regenerate;


import com.tbp.database.model.view.ViewStructDistance;
import com.tbp.network.mst.KruskalMST;
import com.tbp.network.mst.KruskalQuickFind;
import com.tbp.network.mst.support.ComparableEdge;

import org.apache.commons.math.stat.descriptive.DescriptiveStatistics;
import org.graphstream.graph.*;
import org.graphstream.graph.implementations.SingleGraph;


import java.io.Serializable;
import java.util.Iterator;
import java.util.List;


public class DatabaseViewBasedModel extends RegenerateModel implements Serializable {

    public DatabaseViewBasedModel(List<? extends ViewStructDistance> list, int nodeCount) {
        this.graph = generate(list, nodeCount);
        this.descriptiveStatistics = new DescriptiveStatistics();
        this.summaryPreviousDegree();
        this.setStyle();
    }

    Graph generate(List<? extends ViewStructDistance> list, int nodeCount) {
        KruskalMST kruskalMST = new KruskalQuickFind();
        kruskalMST.run(list, nodeCount);
        Graph g = new SingleGraph("Regenerated model based on structural distance");

        Iterable<? extends ComparableEdge> edges = kruskalMST.edges();
        Iterator<? extends ComparableEdge> iterator = edges.iterator();
        while(iterator.hasNext()) {
            ViewStructDistance next =  (ViewStructDistance) iterator.next();
            if(g.getNode(next.getNode1().toString()) == null) {
                Node newNode = g.addNode(next.getNode1().toString());
                newNode.addAttribute(PREVIOUS_DEGREE, next.getDegreeNode1());
            }
            if(g.getNode(next.getNode2().toString()) == null) {
                Node newNode = g.addNode(next.getNode2().toString());
                newNode.addAttribute(PREVIOUS_DEGREE, next.getDegreeNode2());
            }
            try {
                Edge edge = g.addEdge(next.getNode1() + "_" + next.getNode2(), next.getNode1().toString(), next.getNode2().toString());
                edge.addAttribute("weight", next.getDistance());
            } catch (IdAlreadyInUseException | EdgeRejectedException e) {
                // LOGGER.warn(e.getMessage());
            }
        }
        return g;
    }

}
