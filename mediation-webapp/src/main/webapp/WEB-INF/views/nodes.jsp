<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<% request.setAttribute("pageTitle", "Nodes"); %>
<%@ include file="layout.jsp" %>

<div class="page-header">
    <div class="page-header-left">
        <div class="breadcrumb"><a href="<%= request.getContextPath() %>/dashboard">Dashboard</a> <span>/</span> Nodes</div>
        <h1>Network Nodes</h1>
        <p>Manage upstream (MSC, SMSC, PGW) and downstream (Billing, Fraud) nodes</p>
    </div>
    <a href="<%= request.getContextPath() %>/nodes/new" class="btn btn-primary">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        Add Node
    </a>
</div>

<% String success = request.getParameter("success"); if (success != null) { %>
<div class="alert alert-success">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
    Node <%= success.equals("created") ? "created" : success.equals("updated") ? "updated" : "deleted" %> successfully.
</div>
<% } %>
<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-error">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <%= request.getAttribute("error") %>
</div>
<% } %>

<div class="card">
    <div class="card-header">
        <span class="card-title">All Nodes</span>
        <span class="badge badge-gray">
            <% List<Node> nodes = (List<Node>) request.getAttribute("nodes");
               out.print(nodes != null ? nodes.size() : 0); %> total
        </span>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Protocol</th>
                    <th>Host</th>
                    <th>Remote Path</th>
                    <th>CDR Format</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <% if (nodes != null && !nodes.isEmpty()) {
                for (Node node : nodes) { %>
                <tr>
                    <td class="td-mono"><%= node.getId() %></td>
                    <td><strong><%= node.getName() %></strong></td>
                    <td>
                        <span class="badge <%= node.getNodeType().equals("UPSTREAM") ? "badge-amber" : "badge-cyan" %>">
                            <%= node.getNodeType() %>
                        </span>
                    </td>
                    <td><span class="badge badge-gray"><%= node.getProtocol() %></span></td>
                    <td class="td-mono"><%= node.getIp() %>:<%= node.getPort() %></td>
                    <td class="td-mono"><%= node.getRemotePath() %></td>
                    <td>
                        <% if (node.getCdrFormat() != null) { %>
                        <span class="badge badge-green"><%= node.getCdrFormat() %></span>
                        <% } else { %><span class="text-dim" style="font-family:var(--mono);font-size:11px;">—</span><% } %>
                    </td>
                    <td>
                        <span class="badge <%= node.isActive() ? "badge-green" : "badge-red" %>">
                            <%= node.isActive() ? "ACTIVE" : "INACTIVE" %>
                        </span>
                    </td>
                    <td>
                        <div class="flex gap-2">
                            <a href="<%= request.getContextPath() %>/nodes/edit/<%= node.getId() %>" class="btn-icon" title="Edit">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                            </a>
                            <a href="<%= request.getContextPath() %>/nodes/delete/<%= node.getId() %>"
                               class="btn-icon danger"
                               data-confirm="Delete node '<%= node.getName() %>'? This will also delete all related mediation rules."
                               title="Delete">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6M14 11v6"/><path d="M9 6V4h6v2"/></svg>
                            </a>
                        </div>
                    </td>
                </tr>
            <% } } else { %>
                <tr>
                    <td colspan="9">
                        <div class="empty-state">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="3"/><path d="M12 1v4M12 19v4M4.22 4.22l2.83 2.83m9.9 9.9 2.83 2.83M1 12h4m14 0h4M4.22 19.78l2.83-2.83m9.9-9.9 2.83-2.83"/></svg>
                            <p>No nodes configured yet. <a href="<%= request.getContextPath() %>/nodes/new" style="color:var(--amber)">Add one now.</a></p>
                        </div>
                    </td>
                </tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="layout-end.jsp" %>
