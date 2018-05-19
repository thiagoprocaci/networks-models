package com.tbp.database.model;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "comm_user")
public class User {

    @Id
    Long id;

    public Long getId() {
        return id;
    }
}
