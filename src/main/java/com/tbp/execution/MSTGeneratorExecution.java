package com.tbp.execution;

import com.tbp.database.model.*;
import com.tbp.database.model.view.BiologyStructDistanceCustomDtw1;
import com.tbp.database.repository.*;
import com.tbp.database.repository.view.BiologyStructDistanceCustomDtw1Repository;
import com.tbp.network.model.regenerate.DatabaseViewBasedModel;

import org.graphstream.graph.Edge;
import org.graphstream.graph.Graph;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
public class MSTGeneratorExecution {

    private static final Logger LOGGER = LoggerFactory.getLogger(MSTGeneratorExecution.class);
    @Autowired
    BiologyStructDistanceCustomDtw1Repository biologyStructDistanceCustomDtw1Repository;
    @Autowired
    UserRepository userRepository;
    @Autowired
    CommunityRepository communityRepository;
    @Autowired
    GraphNodeRepository graphNodeRepository;
    @Autowired
    GraphAnalysisContextRepository graphAnalysisContextRepository;
    @Autowired
    StructAnalysisContextRepository structAnalysisContextRepository;
    @Autowired
    MSTEdgeRepository mstEdgeRepository;
    @Autowired
    MSTRepository mstRepository;

    public void execute() {

        Graph graph = getMinSpanningTree();
        LOGGER.info("Start saving...");
        Iterator<Edge> edgeIterator = graph.getEdgeIterator();
        GraphAnalysisContext graphAnalysisContext = graphAnalysisContextRepository.getLatest("biology.stackexchange.com");
        Community community = communityRepository.findOne(graphAnalysisContext.getIdCommunity().longValue());
        StructAnalysisContext structAnalysisContext = structAnalysisContextRepository.findByGraphAnalysisContext(graphAnalysisContext);

        MST mst = new MST(community, structAnalysisContext, graphAnalysisContext, graph.getNodeCount(), graph.getEdgeCount());
        mstRepository.save(mst);
        List<MSTEdge> mstEdges = new ArrayList<>();
        while(edgeIterator.hasNext()) {
            Edge e = edgeIterator.next();
            Double weight = e.getAttribute("weight");
            GraphNode graphNodeSource = graphNodeRepository.findOne(Long.parseLong(e.getSourceNode().getId()));
            GraphNode graphNodeDest = graphNodeRepository.findOne(Long.parseLong(e.getTargetNode().getId()));

            User userSource = graphNodeSource.getUser();
            User userDest = graphNodeDest.getUser();

            MSTEdge mstEdge = new MSTEdge(graphNodeSource, graphNodeDest, userSource, userDest, community, structAnalysisContext, graphAnalysisContext, weight, mst);
            mstEdges.add(mstEdge);
        }
        mstEdgeRepository.save(mstEdges);
    }

    Graph getMinSpanningTree() {
        Set<Integer> nodeIDsSet = new HashSet<>();
        LOGGER.info("Getting node count");
        Integer nodeCount = biologyStructDistanceCustomDtw1Repository.getNodeCount();
        LOGGER.info("Found {} nodes", nodeCount);
        LOGGER.info("Getting min distance - custom dtw 1");
        Double minDistance = 0d;
        Double maxDistance = 1d;
        List<BiologyStructDistanceCustomDtw1> list = new ArrayList<>();
        while (nodeIDsSet.size() < nodeCount) {
            LOGGER.info("Getting pair of nodes with distance between {} and {}", minDistance, maxDistance);
            List<BiologyStructDistanceCustomDtw1>  aux = biologyStructDistanceCustomDtw1Repository.findWithDistanceCustomDtw1Between(minDistance, maxDistance);
            LOGGER.info("Found {} distance between nodes", aux.size());
            handleNodes(aux, nodeIDsSet);
            LOGGER.info("Found {} distinct nodes", nodeIDsSet.size());
            minDistance = maxDistance;
            maxDistance++;
            LOGGER.info("New min distance = {}", minDistance);
            LOGGER.info("New max distance = {}", maxDistance);
            list.addAll(aux);
        }
        LOGGER.info("Starting model generation");
        DatabaseViewBasedModel model = new DatabaseViewBasedModel(list, nodeCount);
        LOGGER.info("Number of nodes = {} and edges =  {}", model.getGraph().getNodeCount(), model.getGraph().getEdgeCount());
        return model.getGraph();
    }

    void handleNodes(List<BiologyStructDistanceCustomDtw1> list, Set<Integer> nodesIDs) {
        for(BiologyStructDistanceCustomDtw1 b: list) {
            nodesIDs.add(b.getNode());
            nodesIDs.add(b.getOtherNode());
        }
    }


}