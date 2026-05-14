package com.mediation.web.model;

import java.util.ArrayList;
import java.util.List;

public class MediationRule {
    private int id, sourceNodeId, destinationNodeId;
    private String sourceName, destinationName, sourceType, destinationType;
    private boolean active;
    private List<FiltrationRule> filtrationRules = new ArrayList<>();

    public int getId()                               { return id; }
    public int getSourceNodeId()                     { return sourceNodeId; }
    public int getDestinationNodeId()                { return destinationNodeId; }
    public String getSourceName()                    { return sourceName; }
    public String getDestinationName()               { return destinationName; }
    public String getSourceType()                    { return sourceType; }
    public String getDestinationType()               { return destinationType; }
    public boolean isActive()                        { return active; }
    public List<FiltrationRule> getFiltrationRules() { return filtrationRules; }

    public void setId(int v)                                   { id = v; }
    public void setSourceNodeId(int v)                         { sourceNodeId = v; }
    public void setDestinationNodeId(int v)                    { destinationNodeId = v; }
    public void setSourceName(String v)                        { sourceName = v; }
    public void setDestinationName(String v)                   { destinationName = v; }
    public void setSourceType(String v)                        { sourceType = v; }
    public void setDestinationType(String v)                   { destinationType = v; }
    public void setActive(boolean v)                           { active = v; }
    public void setFiltrationRules(List<FiltrationRule> rules) { filtrationRules = rules; }
}
