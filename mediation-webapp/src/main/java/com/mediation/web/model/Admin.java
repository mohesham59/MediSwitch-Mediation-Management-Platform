package com.mediation.web.model;

public class Admin {
    private int id;
    private String username, passwordHash;
    private boolean active;

    public int getId()              { return id; }
    public String getUsername()     { return username; }
    public String getPasswordHash() { return passwordHash; }
    public boolean isActive()       { return active; }

    public void setId(int v)             { id = v; }
    public void setUsername(String v)    { username = v; }
    public void setPasswordHash(String v){ passwordHash = v; }
    public void setActive(boolean v)     { active = v; }
}
