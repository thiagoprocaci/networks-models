package com.tbp.network.structure.degreeseq;


import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
public class DegreeSequence {


    public static final String LEVEL = "LEVEL";


    /**
     *
     * @param startNode
     * @param graph
     * @param  maxLevel of searching
     * @return map where the key is the distance from the startNode and
     * the value is the degree list of the nodes with distance key from startNode.
     */
    public Map<Integer, List<Integer>> execute(String startNode, Graph graph, Integer maxLevel) {
        Map<Integer, List<Integer>> map = new HashMap<>();
        Map<String, Boolean> visitedNodeMap = new HashMap<>();
        Node root = graph.getNode(startNode);
        visitedNodeMap.put(root.getId(), true);
        root.setAttribute(LEVEL, 0);
        Queue<Node> queue = new LinkedList<>();
        queue.add(root);
        while(!queue.isEmpty()) {
            Node node = queue.remove();
            Integer currentLevel = node.getAttribute(LEVEL, Integer.class);
            if(map.get(currentLevel) == null) {
                map.put(currentLevel, new ArrayList<Integer>());
            }
            map.get(currentLevel).add(node.getDegree());
            Node child;
            if(maxLevelCondition(maxLevel, currentLevel + 1)) {
                while((child = getUnvisitedChildNode(node, visitedNodeMap)) != null) {
                    visitedNodeMap.put(child.getId(), true);
                    child.setAttribute(LEVEL, node.getAttribute(LEVEL, Integer.class) + 1);
                    queue.add(child);
                }
            }
        }
        sortList(map);
        return map;
    }


    /**
     *
     * @param startNode
     * @param graph
     * @return map where the key is the distance from the startNode and
     * the value is the degree list of the nodes with distance key from startNode.
     */
    public Map<Integer, List<Integer>> execute(String startNode, Graph graph) {
        return execute(startNode, graph, null);
    }

    private boolean maxLevelCondition(Integer maxLevel, Integer currentLevel) {
        if(maxLevel == null) {
            return true;
        }
        if(currentLevel <= maxLevel) {
            return true;
        }
        return false;
    }

    private void sortList(Map<Integer, List<Integer>> map) {
        for(Integer key: map.keySet()) {
            List<Integer> list = map.get(key);
            Collections.sort(list);
            map.put(key, list);
        }
    }


    private Node getUnvisitedChildNode(Node node, Map<String, Boolean> visitedNodeMap) {
        Iterator<Node> neighborNodeIterator = node.getNeighborNodeIterator();
        while(neighborNodeIterator.hasNext()) {
            Node next = neighborNodeIterator.next();
            Boolean visited = visitedNodeMap.get(next.getId()); //next.getAttribute(VISITED, Boolean.class);
            if(visited == null || !visited) {
                return next;
            }
        }
        return null;
    }


}
