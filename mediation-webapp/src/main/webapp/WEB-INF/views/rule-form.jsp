<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<% request.setAttribute("pageTitle", "Add Mediation Rule"); %>
<%@ include file="layout.jsp" %>

<div class="page-header">
    <div class="page-header-left">
        <div class="breadcrumb">
            <a href="<%= request.getContextPath() %>/dashboard">Dashboard</a> <span>/</span>
            <a href="<%= request.getContextPath() %>/rules">Rules</a> <span>/</span> New
        </div>
        <h1>Add Mediation Rule</h1>
        <p>Link an upstream node to a downstream destination</p>
    </div>
    <a href="<%= request.getContextPath() %>/rules" class="btn btn-outline">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
        Back
    </a>
</div>

<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-error">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <%= request.getAttribute("error") %>
</div>
<% } %>

<div class="card" style="max-width:600px;">
    <div class="card-header"><span class="card-title">Route Configuration</span></div>
    <div class="card-body">
        <div class="alert alert-info" style="margin-bottom:20px;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
            CDRs from the upstream node will be filtered and forwarded to the destination. Add filtration rules after creation.
        </div>

        <form method="POST" action="<%= request.getContextPath() %>/rules/new">
            <div class="form-grid" style="margin-bottom:24px;">
                <div class="form-group">
                    <label for="sourceNodeId">Source Node (Upstream) *</label>
                    <select id="sourceNodeId" name="sourceNodeId" required>
                        <option value="">Select upstream node...</option>
                        <% List<Node> upstreamNodes = (List<Node>) request.getAttribute("upstreamNodes");
                           if (upstreamNodes != null) for (Node n : upstreamNodes) { %>
                        <option value="<%= n.getId() %>"><%= n.getName() %> (<%= n.getCdrFormat() %>)</option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="destinationNodeId">Destination Node (Downstream) *</label>
                    <select id="destinationNodeId" name="destinationNodeId" required>
                        <option value="">Select downstream node...</option>
                        <% List<Node> downstreamNodes = (List<Node>) request.getAttribute("downstreamNodes");
                           if (downstreamNodes != null) for (Node n : downstreamNodes) { %>
                        <option value="<%= n.getId() %>"><%= n.getName() %></option>
                        <% } %>
                    </select>
                </div>
            </div>

            <!-- Visual preview -->
            <div style="background:var(--bg);border:1px solid var(--border);border-radius:6px;padding:16px;margin-bottom:24px;display:flex;align-items:center;justify-content:center;gap:16px;">
                <div id="srcPreview" style="font-family:var(--mono);font-size:12px;color:var(--amber);padding:6px 12px;border:1px solid rgba(245,158,11,0.3);border-radius:4px;background:rgba(245,158,11,0.07);">
                    SELECT SOURCE
                </div>
                <div style="font-family:var(--mono);color:var(--amber);font-size:16px;">──────→</div>
                <div id="dstPreview" style="font-family:var(--mono);font-size:12px;color:var(--cyan);padding:6px 12px;border:1px solid rgba(6,182,212,0.3);border-radius:4px;background:rgba(6,182,212,0.07);">
                    SELECT DESTINATION
                </div>
            </div>

            <hr class="divider">
            <div class="flex gap-2">
                <button type="submit" class="btn btn-primary">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                    Create Rule
                </button>
                <a href="<%= request.getContextPath() %>/rules" class="btn btn-outline">Cancel</a>
            </div>
        </form>
    </div>
</div>

<script>
const srcSelect = document.getElementById('sourceNodeId');
const dstSelect = document.getElementById('destinationNodeId');
const srcPreview = document.getElementById('srcPreview');
const dstPreview = document.getElementById('dstPreview');

srcSelect.addEventListener('change', () => {
    const opt = srcSelect.options[srcSelect.selectedIndex];
    srcPreview.textContent = opt.value ? opt.text : 'SELECT SOURCE';
});
dstSelect.addEventListener('change', () => {
    const opt = dstSelect.options[dstSelect.selectedIndex];
    dstPreview.textContent = opt.value ? opt.text : 'SELECT DESTINATION';
});
</script>

<%@ include file="layout-end.jsp" %>
