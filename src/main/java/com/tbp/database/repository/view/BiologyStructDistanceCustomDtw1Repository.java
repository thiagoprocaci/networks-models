package com.tbp.database.repository.view;

import com.tbp.database.model.view.BiologyStructDistanceCustomDtw1;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

import java.math.BigInteger;
import java.util.List;


public interface BiologyStructDistanceCustomDtw1Repository extends CrudRepository<BiologyStructDistanceCustomDtw1, BigInteger> {

    @Query(value = "with QUERY_1 as (\n" +
            "select * from biology_struct_distance_custom_dtw_1 order by distance_custom_dtw_1\n" +
            "), \n" +
            " QUERY_2 as (\n" +
            "select * from QUERY_1\n" +
            "limit (\n" +
            "10000000" +
            ")\n" +
            ")\n" +
            "select * from QUERY_2 ", nativeQuery = true)
    List<BiologyStructDistanceCustomDtw1> findClosestDistance();


    @Query(value = "select nodes from last_graph_analysis_context('biology.stackexchange.com')", nativeQuery = true)
    Integer getNodeCount();


}
