package com.tbp.database.repository;


import com.tbp.database.model.StructDistance;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface StructDistanceRepository extends CrudRepository<StructDistance, Long> {

    @Query(value = "select * from struct_distance  where id_struct_analysis_context = :idStructContext and distance_0 is null limit 10000", nativeQuery = true)
    List<StructDistance> findWithDistance0Null(@Param("idStructContext") Long idStructContext);

    @Query(value = "select * from struct_distance  where id_struct_analysis_context = :idStructContext and distance_1 is null limit 10000", nativeQuery = true)
    List<StructDistance> findWithDistance1Null(@Param("idStructContext") Long idStructContext);


    @Query(value = "select * from struct_distance  where id_struct_analysis_context = :idStructContext and distance_2 is null limit 10000", nativeQuery = true)
    List<StructDistance> findWithDistance2Null(@Param("idStructContext") Long idStructContext);



}
