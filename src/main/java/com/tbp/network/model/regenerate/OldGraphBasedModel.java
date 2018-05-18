package com.tbp.network.model.regenerate;

import com.tbp.network.mst.KruskalMST;
import com.tbp.network.mst.KruskalQuickFind;
import com.tbp.network.mst.support.ComparableEdge;
import com.tbp.network.structure.model.StructuralDistanceDto;
import org.apache.commons.math.stat.descriptive.DescriptiveStatistics;

import org.graphstream.graph.*;
import org.graphstream.graph.implementations.SingleGraph;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;


public class OldGraphBasedModel extends RegenerateModel {

    private static final Logger LOGGER = LoggerFactory.getLogger(OldGraphBasedModel.class);


    public OldGraphBasedModel(Graph oldGraph, Map<String, StructuralDistanceDto> nodesStrucDistMap) {
        this.graph = generate(oldGraph, nodesStrucDistMap);
        this.descriptiveStatistics = new DescriptiveStatistics();
        this.summaryPreviousDegree();
        this.setStyle();
    }


    Graph generate(Graph oldGraph, Map<String, StructuralDistanceDto> dtoMap) {
        KruskalMST kruskalMST = new KruskalQuickFind();
        kruskalMST.run(dtoMap, oldGraph);
        Graph g = new SingleGraph("Old-Graph-Based-Model-using-structural-distance");

        Iterable<? extends ComparableEdge> edges = kruskalMST.edges();
        Iterator<? extends ComparableEdge> iterator = edges.iterator();
        while(iterator.hasNext()) {
            StructuralDistanceDto next = (StructuralDistanceDto) iterator.next();
            if(g.getNode(next.getNode1()) == null) {
                Node newNode = g.addNode(next.getNode1());
                newNode.addAttribute(PREVIOUS_DEGREE, oldGraph.getNode(next.getNode1()).getDegree());
            }
            if(g.getNode(next.getNode2()) == null) {
                Node newNode = g.addNode(next.getNode2());
                newNode.addAttribute(PREVIOUS_DEGREE, oldGraph.getNode(next.getNode2()).getDegree());
            }
            try {
                g.addEdge(next.getNode1() + "_" + next.getNode2(), next.getNode1(), next.getNode2());
            } catch (IdAlreadyInUseException | EdgeRejectedException e) {
                // LOGGER.warn(e.getMessage());
            }
        }
        return g;
    }




}
