package com.tbp.database.repository;


import com.tbp.database.model.GraphAnalysisContext;
import com.tbp.database.model.GraphEdge;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface GraphEdgeRepository extends CrudRepository<GraphEdge, Long> {

    List<GraphEdge> findByGraphAnalysisContext(GraphAnalysisContext graphAnalysisContext);

}
