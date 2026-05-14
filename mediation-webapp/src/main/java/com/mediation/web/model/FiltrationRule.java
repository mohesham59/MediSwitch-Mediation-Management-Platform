package com.mediation.web.model;

public class FiltrationRule {
    private int id, mediationRuleId;
    private String ruleType, fieldName, value;
    private boolean active;

    public int getId()              { return id; }
    public int getMediationRuleId() { return mediationRuleId; }
    public String getRuleType()     { return ruleType; }
    public String getFieldName()    { return fieldName; }
    public String getValue()        { return value; }
    public boolean isActive()       { return active; }

    public void setId(int v)              { id = v; }
    public void setMediationRuleId(int v) { mediationRuleId = v; }
    public void setRuleType(String v)     { ruleType = v; }
    public void setFieldName(String v)    { fieldName = v; }
    public void setValue(String v)        { value = v; }
    public void setActive(boolean v)      { active = v; }
}
