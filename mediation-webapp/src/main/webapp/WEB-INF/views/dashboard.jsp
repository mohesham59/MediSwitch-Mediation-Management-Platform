<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<% request.setAttribute("pageTitle", "Dashboard"); %>
<%@ include file="layout.jsp" %>

<div class="page-header">
    <div class="page-header-left">
        <div class="breadcrumb">MEDIFLOW</div>
        <h1>System Overview</h1>
        <p>Real-time view of your mediation infrastructure</p>
    </div>
</div>

<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-error">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <%= request.getAttribute("error") %>
</div>
<% } %>

<!-- Stat cards -->
<div class="stat-grid">
    <div class="stat-card amber">
        <div class="stat-label">Upstream Nodes</div>
        <div class="stat-value"><%= request.getAttribute("upstreamCount") %></div>
        <div class="stat-sub">MSC · SMSC · PGW</div>
    </div>
    <div class="stat-card cyan">
        <div class="stat-label">Downstream Nodes</div>
        <div class="stat-value"><%= request.getAttribute("downstreamCount") %></div>
        <div class="stat-sub">Billing · Fraud</div>
    </div>
    <div class="stat-card green">
        <div class="stat-label">Active Rules</div>
        <div class="stat-value"><%= request.getAttribute("activeRules") %></div>
        <div class="stat-sub">Mediation pipelines</div>
    </div>
    <div class="stat-card red">
        <div class="stat-label">Blocked Numbers</div>
        <div class="stat-value"><%= request.getAttribute("blockedCount") %></div>
        <div class="stat-sub">Emergency &amp; short codes</div>
    </div>
    <div class="stat-card amber">
        <div class="stat-label">Admins</div>
        <div class="stat-value"><%= request.getAttribute("adminCount") %></div>
        <div class="stat-sub">Console users</div>
    </div>
</div>

<!-- Quick actions -->
<div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:28px;">
    <div class="card">
        <div class="card-header">
            <span class="card-title">Quick Actions</span>
        </div>
        <div class="card-body" style="display:flex;flex-direction:column;gap:10px;">
            <a href="<%= request.getContextPath() %>/nodes/new" class="btn btn-primary">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M12 1v4M12 19v4M4.22 4.22l2.83 2.83m9.9 9.9 2.83 2.83M1 12h4m14 0h4M4.22 19.78l2.83-2.83m9.9-9.9 2.83-2.83"/></svg>
                Add Node
            </a>
            <a href="<%= request.getContextPath() %>/rules/new" class="btn btn-outline">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
                Add Mediation Rule
            </a>
            <a href="<%= request.getContextPath() %>/blocked" class="btn btn-outline">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
                Manage Blocked Numbers
            </a>
        </div>
    </div>

    <div class="card">
        <div class="card-header">
            <span class="card-title">Data Flow</span>
        </div>
        <div class="card-body">
            <p style="font-size:12px;color:var(--text-dim);margin-bottom:16px;">CDR collection pipeline</p>
            <div style="display:flex;flex-direction:column;gap:10px;">
                <div style="display:flex;align-items:center;gap:10px;padding:10px;background:var(--bg3);border-radius:6px;border:1px solid var(--border);">
                    <span class="badge badge-amber">UPSTREAM</span>
                    <span style="font-family:var(--mono);font-size:11px;color:var(--text-dim);">MSC · SMSC · PGW</span>
                    <span style="font-family:var(--mono);font-size:14px;color:var(--amber);margin-left:auto;">→</span>
                </div>
                <div style="display:flex;align-items:center;gap:10px;padding:10px;background:rgba(245,158,11,0.05);border-radius:6px;border:1px solid rgba(245,158,11,0.2);">
                    <span class="badge badge-cyan">ENGINE</span>
                    <span style="font-family:var(--mono);font-size:11px;color:var(--text-dim);">Filter · Transform · Route</span>
                    <span style="font-family:var(--mono);font-size:14px;color:var(--amber);margin-left:auto;">→</span>
                </div>
                <div style="display:flex;align-items:center;gap:10px;padding:10px;background:var(--bg3);border-radius:6px;border:1px solid var(--border);">
                    <span class="badge badge-green">DOWNSTREAM</span>
                    <span style="font-family:var(--mono);font-size:11px;color:var(--text-dim);">Billing · Fraud</span>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Nodes table -->
<div class="card">
    <div class="card-header">
        <span class="card-title">All Nodes</span>
        <a href="<%= request.getContextPath() %>/nodes" class="btn btn-sm btn-outline">View All</a>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Protocol</th>
                    <th>Address</th>
                    <th>Format</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
            <%
            List<Node> recentNodes = (List<Node>) request.getAttribute("recentNodes");
            if (recentNodes != null && !recentNodes.isEmpty()) {
                for (Node node : recentNodes) {
            %>
                <tr>
                    <td><strong><%= node.getName() %></strong></td>
                    <td>
                        <span class="badge <%= node.getNodeType().equals("UPSTREAM") ? "badge-amber" : "badge-cyan" %>">
                            <%= node.getNodeType() %>
                        </span>
                    </td>
                    <td><span class="badge badge-gray"><%= node.getProtocol() %></span></td>
                    <td class="td-mono"><%= node.getIp() %>:<%= node.getPort() %></td>
                    <td>
                        <% if (node.getCdrFormat() != null) { %>
                        <span class="badge badge-green"><%= node.getCdrFormat() %></span>
                        <% } else { %><span class="text-dim">—</span><% } %>
                    </td>
                    <td>
                        <span class="badge <%= node.isActive() ? "badge-green" : "badge-red" %>">
                            <%= node.isActive() ? "ACTIVE" : "INACTIVE" %>
                        </span>
                    </td>
                </tr>
            <%  } } else { %>
                <tr><td colspan="6"><div class="empty-state"><p>No nodes configured yet.</p></div></td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<%@ include file="layout-end.jsp" %>
