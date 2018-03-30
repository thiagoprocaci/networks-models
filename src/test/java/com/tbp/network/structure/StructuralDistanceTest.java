package com.tbp.network.structure;


import com.tbp.network.structure.distance.OtherDistance;
import org.graphstream.graph.Graph;
import org.graphstream.graph.implementations.SingleGraph;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.assertEquals;

public class StructuralDistanceTest {

    Graph g;
    DegreeSequence degreeSequence;
    DTW dtw;

    @Before
    public void before() {
        g = new SingleGraph("Graph");
        g.addNode("A");
        g.addNode("B");
        g.addNode("C");
        g.addNode("U");
        g.addNode("V");
        g.addNode("D");
        g.addNode("E");
        g.addNode("F");
        g.addNode("G");
        g.addEdge("A_B", "A", "B");
        g.addEdge("A_C", "A", "C");
        g.addEdge("C_B", "C", "B");
        g.addEdge("B_V", "B", "V");
        g.addEdge("B_U", "B", "U");
        g.addEdge("U_V", "U", "V");
        g.addEdge("U_E", "U", "E");
        g.addEdge("U_D", "U", "D");
        g.addEdge("V_D", "V", "D");
        g.addEdge("D_F", "D", "F");
        g.addEdge("D_G", "D", "G");
        g.addEdge("F_G", "F", "G");

        degreeSequence = new DegreeSequence();
        dtw = new DTW(new OtherDistance());
    }

    @Test
    public void structuralDistanceMaxZero() {
        StructuralDistance structuralDistance = new StructuralDistance(degreeSequence, dtw);
        double distance = structuralDistance.execute(g, "U", "V", 0);
        assertEquals(0.33, Math.floor(distance * 100) / 100, 0.001);
    }

    @Test
    public void structuralDistanceMaxOne() {
        StructuralDistance structuralDistance = new StructuralDistance(degreeSequence, dtw);
        double distance = structuralDistance.execute(g, "U", "V", 1);
        assertEquals(3.66, Math.floor(distance * 100) / 100, 0.001);
    }

    @Test
    public void structuralDistanceMaxTwo() {
        StructuralDistance structuralDistance = new StructuralDistance(degreeSequence, dtw);
        double distance = structuralDistance.execute(g, "U", "V", 2);
        assertEquals(4.66, Math.floor(distance * 100) / 100, 0.001);
    }

    @Test
    public void structuralDistanceSameNode() {
        StructuralDistance structuralDistance = new StructuralDistance(degreeSequence, dtw);
        double distance = structuralDistance.execute(g, "U", "U", 2);
        assertEquals(0, distance, 0.001);
    }

}
