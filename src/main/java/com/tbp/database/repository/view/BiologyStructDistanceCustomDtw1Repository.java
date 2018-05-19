package com.tbp.database.repository.view;

import com.tbp.database.model.view.BiologyStructDistanceCustomDtw1;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

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

    @Query(value = "select min(distance_custom_dtw_1) from biology_struct_distance_custom_dtw_1", nativeQuery = true)
    Double getMinDistanceCustomDtw1();

    @Query(value = "select * from biology_struct_distance_custom_dtw_1  where distance_custom_dtw_1 >= :distance1 and distance_custom_dtw_1 < :distance2", nativeQuery = true)
    List<BiologyStructDistanceCustomDtw1> findWithDistanceCustomDtw1Between(@Param("distance1") Double distance1, @Param("distance2") Double distance2);


}
