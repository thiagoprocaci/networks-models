package com.tbp.network.structure;


import com.tbp.network.model.ErdosRenyi;
import com.tbp.network.performance.PerformanceTime;
import com.tbp.network.structure.degreeseq.DegreeSequence;
import com.tbp.network.structure.dtw.distance.OtherDistance;
import com.tbp.network.structure.dtw.DTW;
import com.tbp.network.structure.model.StructuralDistanceDto;
import org.graphstream.graph.Graph;

import org.graphstream.graph.implementations.SingleGraph;
import org.junit.Before;
import org.junit.Test;


import java.math.BigInteger;

import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

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
        StructuralDistance structuralDistance = new StructuralDistance(degreeSequence, dtw, new PerformanceTime());
        double distance = structuralDistance.execute(g, "U", "V", 0);
        assertEquals(0.33, Math.floor(distance * 100) / 100, 0.001);
    }

    @Test
    public void structuralDistanceMaxOne() {
        StructuralDistance structuralDistance = new StructuralDistance(degreeSequence, dtw, new PerformanceTime());
        double distance = structuralDistance.execute(g, "U", "V", 1);
        assertEquals(3.66, Math.floor(distance * 100) / 100, 0.001);
    }

    @Test
    public void structuralDistanceMaxTwo() {
        StructuralDistance structuralDistance = new StructuralDistance(degreeSequence, dtw, new PerformanceTime());
        double distance = structuralDistance.execute(g, "U", "V", 2);
        assertEquals(4.66, Math.floor(distance * 100) / 100, 0.001);

        double distance2 = structuralDistance.execute(g, "V", "U", 2);
        assertEquals(4.66, Math.floor(distance2 * 100) / 100, 0.001);
    }

    @Test
    public void structuralDistanceSameNode() {
        StructuralDistance structuralDistance = new StructuralDistance(degreeSequence, dtw, new PerformanceTime());
        double distance = structuralDistance.execute(g, "U", "U", 2);
        assertEquals(0, distance, 0.001);
    }

    @Test
    public void generalTest() {
        ErdosRenyi erdosRenyi = new ErdosRenyi(200, new PerformanceTime());
        Graph graph = erdosRenyi.getGraph();

        StructuralDistance structuralDistance = new StructuralDistance(degreeSequence, dtw, new PerformanceTime());
        Map<String, StructuralDistanceDto> strucDistMap = structuralDistance.execute(graph, 2);
        assertNotNull(strucDistMap);
        BigInteger totalElements = factorial(graph.getNodeCount()).divide((factorial(2).multiply(factorial(graph.getNodeCount() - 2))));
        assertTrue(totalElements.equals(BigInteger.valueOf(strucDistMap.size())));

        for(String id: strucDistMap.keySet()) {
            assertNotNull(id);
            StructuralDistanceDto nodesStrucDist = strucDistMap.get(id);
            assertNotNull(nodesStrucDist);
            assertEquals(StructuralDistanceDto.generateId(nodesStrucDist.getNode2(), nodesStrucDist.getNode1()), id);
            assertEquals(StructuralDistanceDto.generateId(nodesStrucDist.getNode1(), nodesStrucDist.getNode2()), id);
            assertNotNull(nodesStrucDist.getStructDistance());
        }
    }

    public BigInteger factorial(int number) {
        BigInteger result = BigInteger.valueOf(1);
        for (long factor = 2; factor <= BigInteger.valueOf(number).longValue(); factor++) {
            result = result.multiply(BigInteger.valueOf(factor));
        }
        return result;
    }


}
