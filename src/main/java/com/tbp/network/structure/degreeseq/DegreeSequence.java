package com.tbp.network.structure.degreeseq;


import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;

import java.util.*;

public class DegreeSequence {

    public static final String VISITED = "visited";
    public static final String LEVEL = "LEVEL";


    /**
     *
     * @param startNode
     * @param graph
     * @return map where the key is the distance from the startNode and
     * the value is the degree list of the nodes with distance key from startNode.
     */
    public Map<Integer, List<Integer>> execute(String startNode, Graph graph) {

        Map<Integer, List<Integer>> map = new HashMap<Integer, List<Integer>>();

        Node root = graph.getNode(startNode);
        root.setAttribute(VISITED, true);
        root.setAttribute(LEVEL, 0);
        Queue<Node> queue = new LinkedList<Node>();
        queue.add(root);
        while(!queue.isEmpty()) {
            Node node = queue.remove();
            Integer currentLevel = node.getAttribute(LEVEL, Integer.class);
            if(map.get(currentLevel) == null) {
                map.put(currentLevel, new ArrayList<Integer>());
            }
            map.get(currentLevel).add(node.getDegree());
            Node child;
            while((child = getUnvisitedChildNode(node)) != null) {
                child.setAttribute(VISITED, true);
                child.setAttribute(LEVEL, node.getAttribute(LEVEL, Integer.class) + 1);
                queue.add(child);
            }
        }
        cleanVisited(graph);
        sortList(map);
        return map;
    }

    private void sortList(Map<Integer, List<Integer>> map) {
        for(Integer key: map.keySet()) {
            List<Integer> list = map.get(key);
            Collections.sort(list);
            map.put(key, list);
        }
    }

    private void cleanVisited(Graph graph) {
        Iterable<? extends Node> eachNode = graph.getEachNode();
        for(Node n: eachNode) {
            n.setAttribute(VISITED, false);
        }
    }

    private Node getUnvisitedChildNode(Node node) {
        Iterator<Node> neighborNodeIterator = node.getNeighborNodeIterator();
        while(neighborNodeIterator.hasNext()) {
            Node next = neighborNodeIterator.next();
            Boolean visited = next.getAttribute(VISITED, Boolean.class);
            if(visited == null || !visited) {
                return next;
            }
        }
        return null;
    }


}
