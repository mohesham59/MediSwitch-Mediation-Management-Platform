<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<% request.setAttribute("pageTitle", "Mediation Rules"); %>
<%@ include file="layout.jsp" %>

<div class="page-header">
    <div class="page-header-left">
        <div class="breadcrumb"><a href="<%= request.getContextPath() %>/dashboard">Dashboard</a> <span>/</span> Rules</div>
        <h1>Mediation Rules</h1>
        <p>Configure CDR routing from upstream nodes to downstream systems</p>
    </div>
    <a href="<%= request.getContextPath() %>/rules/new" class="btn btn-primary">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        Add Rule
    </a>
</div>

<% String success = request.getParameter("success"); if (success != null) { %>
<div class="alert alert-success">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
    Rule <%= success.equals("created") ? "created" : "deleted" %> successfully.
</div>
<% } %>
<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-error">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <%= request.getAttribute("error") %>
</div>
<% } %>

<%
    List<MediationRule> rules = (List<MediationRule>) request.getAttribute("rules");
%>

<% if (rules != null && !rules.isEmpty()) {
    for (MediationRule rule : rules) { %>

<div class="card" style="margin-bottom:16px;">
    <div class="card-header">
        <div class="flow">
            <span class="badge badge-amber"><%= rule.getSourceName() %></span>
            <span class="flow-arrow">──→</span>
            <span class="badge badge-cyan"><%= rule.getDestinationName() %></span>
            <span style="margin-left:8px;" class="badge <%= rule.isActive() ? "badge-green" : "badge-red" %>">
                <%= rule.isActive() ? "ACTIVE" : "INACTIVE" %>
            </span>
            <span class="badge badge-gray" style="margin-left:4px;">Rule #<%= rule.getId() %></span>
        </div>
        <div class="flex gap-2">
            <a href="<%= request.getContextPath() %>/rules/view/<%= rule.getId() %>" class="btn btn-sm btn-outline">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                Manage Filters
            </a>
            <a href="<%= request.getContextPath() %>/rules/toggle/<%= rule.getId() %>" class="btn-icon <%= rule.isActive() ? "" : "success" %>" title="<%= rule.isActive() ? "Deactivate" : "Activate" %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <% if (rule.isActive()) { %>
                    <rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/>
                    <% } else { %>
                    <polygon points="5 3 19 12 5 21 5 3"/>
                    <% } %>
                </svg>
            </a>
            <a href="<%= request.getContextPath() %>/rules/delete/<%= rule.getId() %>"
               class="btn-icon danger"
               data-confirm="Delete rule #<%= rule.getId() %> (<%= rule.getSourceName() %> → <%= rule.getDestinationName() %>)? All filtration rules will also be deleted."
               title="Delete">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6M14 11v6"/><path d="M9 6V4h6v2"/></svg>
            </a>
        </div>
    </div>

    <div style="padding:14px 20px;display:flex;align-items:center;gap:24px;flex-wrap:wrap;">
        <div>
            <div class="stat-label" style="font-family:var(--mono);font-size:10px;color:var(--text-muted);text-transform:uppercase;letter-spacing:.1em;margin-bottom:3px;">Source</div>
            <div style="font-size:13px;color:var(--text);font-weight:600;"><%= rule.getSourceName() %></div>
            <div style="font-family:var(--mono);font-size:10px;color:var(--text-dim);"><%= rule.getSourceType() %></div>
        </div>
        <div style="font-family:var(--mono);font-size:18px;color:var(--amber);">──────→</div>
        <div>
            <div class="stat-label" style="font-family:var(--mono);font-size:10px;color:var(--text-muted);text-transform:uppercase;letter-spacing:.1em;margin-bottom:3px;">Destination</div>
            <div style="font-size:13px;color:var(--text);font-weight:600;"><%= rule.getDestinationName() %></div>
            <div style="font-family:var(--mono);font-size:10px;color:var(--text-dim);"><%= rule.getDestinationType() %></div>
        </div>
        <div style="margin-left:auto;">
            <div class="stat-label" style="font-family:var(--mono);font-size:10px;color:var(--text-muted);text-transform:uppercase;letter-spacing:.1em;margin-bottom:3px;">Filter Rules</div>
            <div style="font-size:22px;font-weight:800;color:<%= rule.getFiltrationRules().isEmpty() ? "var(--text-dim)" : "var(--amber)" %>;">
                <%= rule.getFiltrationRules().size() %>
            </div>
        </div>
    </div>

    <% if (!rule.getFiltrationRules().isEmpty()) { %>
    <div style="padding:0 20px 14px;">
        <div class="tag-row">
        <% for (FiltrationRule fr : rule.getFiltrationRules()) { %>
            <span class="tag" style="<%= !fr.isActive() ? "opacity:0.4;" : "" %>">
                <%= fr.getRuleType() %> · <%= fr.getFieldName() %><% if (fr.getValue() != null) { %> = <em><%= fr.getValue() %></em><% } %>
            </span>
        <% } %>
        </div>
    </div>
    <% } %>
</div>

<% } } else { %>
<div class="card">
    <div class="empty-state">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M22 12h-4l-3 9L9 3l-3 9H2"/></svg>
        <p>No mediation rules yet. <a href="<%= request.getContextPath() %>/rules/new" style="color:var(--amber)">Create one now.</a></p>
    </div>
</div>
<% } %>

<%@ include file="layout-end.jsp" %>
