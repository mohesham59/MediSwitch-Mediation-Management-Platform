package com.mediation.web.model;

// ── Node ─────────────────────────────────────────────────────────
public class Node {
    private int id;
    private String name, nodeType, protocol, ip, username, passwordHash, remotePath, cdrFormat;
    private int port;
    private boolean active;

    public int getId()              { return id; }
    public String getName()         { return name; }
    public String getNodeType()     { return nodeType; }
    public String getProtocol()     { return protocol; }
    public String getIp()           { return ip; }
    public int getPort()            { return port; }
    public String getUsername()     { return username; }
    public String getPasswordHash() { return passwordHash; }
    public String getRemotePath()   { return remotePath; }
    public String getCdrFormat()    { return cdrFormat; }
    public boolean isActive()       { return active; }

    public void setId(int v)               { id = v; }
    public void setName(String v)          { name = v; }
    public void setNodeType(String v)      { nodeType = v; }
    public void setProtocol(String v)      { protocol = v; }
    public void setIp(String v)            { ip = v; }
    public void setPort(int v)             { port = v; }
    public void setUsername(String v)      { username = v; }
    public void setPasswordHash(String v)  { passwordHash = v; }
    public void setRemotePath(String v)    { remotePath = v; }
    public void setCdrFormat(String v)     { cdrFormat = v; }
    public void setActive(boolean v)       { active = v; }
}
