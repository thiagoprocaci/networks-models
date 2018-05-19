package com.tbp.database.model;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "community")
public class Community {

    @Id
    Long id;

    public Long getId() {
        return id;
    }
}
