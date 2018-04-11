package com.tbp.database.repository;


import com.tbp.database.model.GraphAnalysisContext;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

import java.math.BigInteger;
import java.util.List;

public interface GraphAnalysisContextRepository extends CrudRepository<GraphAnalysisContext, Long> {


    @Query(value = "select * from last_graph_analysis_context(:communityName)", nativeQuery = true)
    GraphAnalysisContext getLatest(@Param("communityName") String communityName);

    @Query(value = "select distinct id from graph_node node \n" +
            "where node.id_graph_analysis_context in (\n" +
            ":idGraphAnalysisContext \n" +
            ") order by id", nativeQuery = true)
    List<BigInteger> findNodeIdList(@Param("idGraphAnalysisContext") Long idGraphAnalysisContext);


}
