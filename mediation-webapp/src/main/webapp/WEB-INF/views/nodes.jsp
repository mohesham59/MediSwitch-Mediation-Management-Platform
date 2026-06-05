<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<% request.setAttribute("pageTitle", "Network Nodes"); %>
<%@ include file="layout.jsp" %>

<%
    List<Node> nodes = (List<Node>) request.getAttribute("nodes");
    String ctx = request.getContextPath();
    long upCount = 0, downCount = 0, activeCount = 0;
    if (nodes != null) {
        for (Node n : nodes) {
            if ("UPSTREAM".equals(n.getNodeType())) upCount++;
            else downCount++;
            if (n.isActive()) activeCount++;
        }
    }
    int totalNodes = nodes != null ? nodes.size() : 0;
%>

<div class="page-header fade-in">
    <div class="page-header-left">
        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a>
            <span class="sep">›</span> Nodes
        </div>
        <div class="page-eyebrow">Infrastructure</div>
        <h1>Network Nodes</h1>
        <p>Upstream (MSC, SMSC, PGW) and downstream (Billing, Fraud, Charging) nodes</p>
    </div>
    <a href="<%= ctx %>/nodes/new" class="btn btn-primary">
        <i class="fas fa-plus"></i> Add Node
    </a>
</div>

<% String success = request.getParameter("success"); if (success != null) { %>
<div class="alert alert-success fade-in">
    <i class="fas fa-check-circle"></i>
    Node <%= "created".equals(success) ? "created" : "updated".equals(success) ? "updated" : "deleted" %> successfully.
</div>
<% } %>
<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-error fade-in">
    <i class="fas fa-exclamation-circle"></i>
    <%= request.getAttribute("error") %>
</div>
<% } %>

<!-- Summary strip -->
<div class="nodes-summary fade-in-2">
    <div class="nsm-card">
        <div class="nsm-icon nsm-amber"><i class="fas fa-arrow-up"></i></div>
        <div><div class="nsm-label">Upstream</div><div class="nsm-value" style="color:var(--amber);"><%= upCount %></div></div>
    </div>
    <div class="nsm-card">
        <div class="nsm-icon nsm-green"><i class="fas fa-arrow-down"></i></div>
        <div><div class="nsm-label">Downstream</div><div class="nsm-value" style="color:var(--green);"><%= downCount %></div></div>
    </div>
    <div class="nsm-card">
        <div class="nsm-icon nsm-blue"><i class="fas fa-circle-check"></i></div>
        <div><div class="nsm-label">Active</div><div class="nsm-value" style="color:var(--blue);"><%= activeCount %></div></div>
    </div>
    <div class="nsm-card">
        <div class="nsm-icon nsm-gray"><i class="fas fa-layer-group"></i></div>
        <div><div class="nsm-label">Total</div><div class="nsm-value"><%= totalNodes %></div></div>
    </div>
</div>

<div class="card fade-in-3">
    <div class="card-header">
        <span class="card-title"><i class="fas fa-server"></i> All Nodes</span>
        <span class="badge badge-gray"><%= totalNodes %> total</span>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>#</th><th>Node</th><th>Type</th><th>Protocol</th>
                    <th>Address</th><th>Remote Path</th><th>CDR Format</th>
                    <th>Status</th><th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% if (nodes != null && !nodes.isEmpty()) {
                for (Node node : nodes) {
                    boolean isUp = "UPSTREAM".equals(node.getNodeType());
                    String fmt   = node.getCdrFormat();
            %>
            <tr>
                <td class="td-mono"><%= node.getId() %></td>
                <td>
                    <div style="display:flex;align-items:center;gap:10px;">
                        <div class="node-type-icon <%= isUp ? "nti-amber" : "nti-green" %>">
                            <i class="fas <%= isUp ? "fa-arrow-up" : "fa-arrow-down" %>"></i>
                        </div>
                        <div>
                            <div class="td-name"><%= node.getName() %></div>
                            <div class="td-mono" style="font-size:9px;">id:<%= node.getId() %></div>
                        </div>
                    </div>
                </td>
                <td>
                    <span class="badge <%= isUp ? "badge-amber" : "badge-green" %>">
                        <%= node.getNodeType() %>
                    </span>
                </td>
                <td><span class="badge badge-gray"><%= node.getProtocol() %></span></td>
                <td class="td-mono"><%= node.getIp() %>:<%= node.getPort() %></td>
                <td class="td-mono" style="max-width:140px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="<%= node.getRemotePath() %>">
                    <%= node.getRemotePath() %>
                </td>
                <td>
                    <% if (fmt != null && !fmt.isEmpty()) { %>
                    <span class="badge badge-violet"><%= fmt %></span>
                    <% } else { %>
                    <span style="color:var(--text-placeholder);font-family:var(--font-mono);font-size:10px;">—</span>
                    <% } %>
                </td>
                <td>
                    <span class="badge <%= node.isActive() ? "badge-green badge-active-pulse" : "badge-red" %>">
                        <%= node.isActive() ? "Active" : "Offline" %>
                    </span>
                </td>
                <td>
                    <div class="flex gap-2">
                        <a href="<%= ctx %>/nodes/edit/<%= node.getId() %>" class="btn-icon" title="Edit">
                            <i class="fas fa-pencil"></i>
                        </a>
                        <a href="<%= ctx %>/nodes/delete/<%= node.getId() %>"
                           class="btn-icon danger"
                           data-confirm="Delete node '<%= node.getName() %>'? All related mediation rules will also be deleted."
                           title="Delete">
                            <i class="fas fa-trash"></i>
                        </a>
                    </div>
                </td>
            </tr>
            <% } } else { %>
            <tr><td colspan="9">
                <div class="empty-state">
                    <i class="fas fa-server"></i>
                    <div class="empty-title">No Nodes Configured</div>
                    <p>Add your first upstream or downstream node to start mediating CDRs.</p>
                    <a href="<%= ctx %>/nodes/new" style="color:var(--blue);margin-top:10px;display:inline-flex;align-items:center;gap:5px;font-size:13px;">
                        <i class="fas fa-plus"></i> Add First Node
                    </a>
                </div>
            </td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<style>
.nodes-summary { display:grid; grid-template-columns:repeat(4,1fr); gap:14px; margin-bottom:20px; }
@media(max-width:700px){ .nodes-summary{grid-template-columns:repeat(2,1fr);} }
.nsm-card { display:flex; align-items:center; gap:12px; padding:14px 16px; background:white; border:1px solid var(--border-soft); border-radius:10px; box-shadow:var(--shadow-xs); }
.nsm-icon { width:34px;height:34px;border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0; }
.nsm-amber { background:rgba(217,119,6,0.08); color:var(--amber); border:1px solid rgba(217,119,6,0.22); }
.nsm-green { background:var(--green-subtle);  color:var(--green);  border:1px solid var(--green-border); }
.nsm-blue  { background:var(--blue-subtle);   color:var(--blue);   border:1px solid var(--blue-border); }
.nsm-gray  { background:var(--bg-muted);      color:var(--text-muted); border:1px solid var(--border-base); }
.nsm-label { font-family:var(--font-mono);font-size:9px;color:var(--text-faint);text-transform:uppercase;letter-spacing:.10em;font-weight:500; }
.nsm-value { font-family:var(--font-display);font-size:26px;font-weight:800;color:var(--text-primary);letter-spacing:-.02em;line-height:1.1; }
.node-type-icon { width:28px;height:28px;border-radius:5px;display:flex;align-items:center;justify-content:center;font-size:11px;flex-shrink:0; }
.nti-amber { background:rgba(217,119,6,0.08); color:var(--amber); border:1px solid rgba(217,119,6,0.22); }
.nti-green { background:var(--green-subtle);  color:var(--green);  border:1px solid var(--green-border); }
</style>

<%@ include file="layout-end.jsp" %>
