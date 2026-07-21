<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<% request.setAttribute("pageTitle", "Blocked Numbers"); %>
<%@ include file="layout.jsp" %>

<div class="page-header">
    <div class="page-header-left">
        <div class="breadcrumb"><a href="<%= request.getContextPath() %>/dashboard">Dashboard</a> <span>/</span> Blocked Numbers</div>
        <h1>Blocked Numbers</h1>
        <p>Emergency and short-code numbers that are never forwarded to billing or fraud systems</p>
    </div>
</div>

<% String success = request.getParameter("success"); if (success != null) { %>
<div class="alert alert-success">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
    Number <%= success.equals("added") ? "added" : "deleted" %> successfully.
</div>
<% } %>
<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-error">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <%= request.getAttribute("error") %>
</div>
<% } %>

<div style="display:grid;grid-template-columns:1fr 340px;gap:20px;align-items:start;">

    <!-- List -->
    <div class="card">
        <div class="card-header">
            <span class="card-title">Blocked Number List</span>
            <% List<BlockedNumber> numbers = (List<BlockedNumber>) request.getAttribute("numbers"); %>
            <span class="badge badge-red"><%= numbers != null ? numbers.size() : 0 %> entries</span>
        </div>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Number</th>
                        <th>Description</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <% if (numbers != null && !numbers.isEmpty()) {
                    for (BlockedNumber bn : numbers) { %>
                    <tr>
                        <td class="td-mono"><%= bn.getId() %></td>
                        <td>
                            <div style="display:flex;align-items:center;gap:8px;">
                                <span style="font-family:var(--mono);font-size:15px;font-weight:700;color:var(--red)"><%= bn.getNumber() %></span>
                                <span class="badge badge-red">BLOCKED</span>
                            </div>
                        </td>
                        <td style="color:var(--text-dim);font-size:13px;"><%= bn.getDescription() != null ? bn.getDescription() : "—" %></td>
                        <td>
                            <a href="<%= request.getContextPath() %>/blocked/delete/<%= bn.getId() %>"
                               class="btn-icon danger"
                               data-confirm="Remove '<%= bn.getNumber() %>' from the blocked list?"
                               title="Remove">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6M14 11v6"/><path d="M9 6V4h6v2"/></svg>
                            </a>
                        </td>
                    </tr>
                <% } } else { %>
                    <tr><td colspan="4">
                        <div class="empty-state">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
                            <p>No blocked numbers configured.</p>
                        </div>
                    </td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Add form -->
    <div class="card">
        <div class="card-header"><span class="card-title">Add Blocked Number</span></div>
        <div class="card-body">
            <!-- <div class="alert alert-info" style="margin-bottom:16px;font-size:12px;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                Numbers in this list are checked by <strong>BLOCKED_NUMBER</strong> filtration rules.
            </div> -->
            <form method="POST" action="<%= request.getContextPath() %>/blocked">
                <div class="form-group" style="margin-bottom:14px;">
                    <label for="number">Phone Number *</label>
                    <input type="text" id="number" name="number" required
                           placeholder="e.g. 911, 112, 15">
                </div>
                <div class="form-group" style="margin-bottom:20px;">
                    <label for="description">Description</label>
                    <input type="text" id="description" name="description"
                           placeholder="e.g. Egypt police emergency">
                </div>
                <button type="submit" class="btn btn-primary" style="width:100%;">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
                    Add to Block List
                </button>
            </form>
        </div>
    </div>
</div>

<%@ include file="layout-end.jsp" %>
