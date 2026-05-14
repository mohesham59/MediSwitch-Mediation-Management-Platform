package com.mediation.web.model;

public class BlockedNumber {
    private int id;
    private String number, description;

    public int getId()             { return id; }
    public String getNumber()      { return number; }
    public String getDescription() { return description; }

    public void setId(int v)             { id = v; }
    public void setNumber(String v)      { number = v; }
    public void setDescription(String v) { description = v; }
}
