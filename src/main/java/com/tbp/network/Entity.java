package com.tbp.network;


public abstract class Entity<E> {


    public abstract E getId();

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Entity node = (Entity) o;

        return getId() != null ? getId().equals(node.getId()) : node.getId() == null;

    }

    @Override
    public int hashCode() {
        return getId() != null ? getId().hashCode() : 0;
    }

}
