package com.tbp.database.repository;


import com.tbp.database.model.GraphAnalysisContext;
import com.tbp.database.model.StructAnalysisContext;
import org.springframework.data.repository.CrudRepository;

public interface StructAnalysisContextRepository extends CrudRepository<StructAnalysisContext, Long> {

    StructAnalysisContext findByGraphAnalysisContext(GraphAnalysisContext graphAnalysisContext);

}
