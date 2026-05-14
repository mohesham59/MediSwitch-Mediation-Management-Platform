<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<% request.setAttribute("pageTitle", "Admins"); %>
<%@ include file="layout.jsp" %>

<div class="page-header">
    <div class="page-header-left">
        <div class="breadcrumb"><a href="<%= request.getContextPath() %>/dashboard">Dashboard</a> <span>/</span> Admins</div>
        <h1>Admin Users</h1>
        <p>Manage console access accounts</p>
    </div>
</div>

<% String success = request.getParameter("success"); if (success != null) { %>
<div class="alert alert-success">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
    Admin <%= success.equals("created") ? "created" : "deleted" %> successfully.
</div>
<% } %>
<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-error">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <%= request.getAttribute("error") %>
</div>
<% } %>

<div style="display:grid;grid-template-columns:1fr 340px;gap:20px;align-items:start;">

    <!-- Admin list -->
    <div class="card">
        <div class="card-header">
            <span class="card-title">Admin Accounts</span>
            <% List<Admin> admins = (List<Admin>) request.getAttribute("admins"); %>
            <span class="badge badge-gray"><%= admins != null ? admins.size() : 0 %></span>
        </div>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Username</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <% String currentAdmin = (String) session.getAttribute("admin");
                   if (admins != null && !admins.isEmpty()) {
                    for (Admin admin : admins) {
                        boolean isSelf = admin.getUsername().equals(currentAdmin); %>
                    <tr>
                        <td class="td-mono"><%= admin.getId() %></td>
                        <td>
                            <div style="display:flex;align-items:center;gap:10px;">
                                <div style="width:32px;height:32px;background:var(--amber-dim);border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:var(--mono);font-size:12px;font-weight:700;color:var(--amber);flex-shrink:0;">
                                    <%= admin.getUsername().substring(0,1).toUpperCase() %>
                                </div>
                                <div>
                                    <div style="font-weight:600;"><%= admin.getUsername() %><% if (isSelf) { %> <span class="badge badge-amber" style="font-size:9px;">YOU</span><% } %></div>
                                    <div style="font-family:var(--mono);font-size:10px;color:var(--text-dim);">Administrator</div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span class="badge <%= admin.isActive() ? "badge-green" : "badge-red" %>">
                                <%= admin.isActive() ? "ACTIVE" : "INACTIVE" %>
                            </span>
                        </td>
                        <td>
                            <div class="flex gap-2">
                                <% if (!isSelf) { %>
                                <a href="<%= request.getContextPath() %>/admins/toggle/<%= admin.getId() %>"
                                   class="btn-icon" title="<%= admin.isActive() ? "Deactivate" : "Activate" %>">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <% if (admin.isActive()) { %>
                                        <rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/>
                                        <% } else { %>
                                        <polygon points="5 3 19 12 5 21 5 3"/>
                                        <% } %>
                                    </svg>
                                </a>
                                <a href="<%= request.getContextPath() %>/admins/delete/<%= admin.getId() %>"
                                   class="btn-icon danger"
                                   data-confirm="Delete admin '<%= admin.getUsername() %>'?"
                                   title="Delete">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6M14 11v6"/><path d="M9 6V4h6v2"/></svg>
                                </a>
                                <% } else { %>
                                <span style="font-family:var(--mono);font-size:10px;color:var(--text-muted);padding:6px;">current session</span>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                <% } } else { %>
                    <tr><td colspan="4">
                        <div class="empty-state"><p>No admins found.</p></div>
                    </td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Add admin form -->
    <div class="card">
        <div class="card-header"><span class="card-title">Add Admin</span></div>
        <div class="card-body">
            <form method="POST" action="<%= request.getContextPath() %>/admins">
                <div class="form-group" style="margin-bottom:14px;">
                    <label for="username">Username *</label>
                    <input type="text" id="username" name="username" required
                           placeholder="e.g. john_doe" autocomplete="off">
                </div>
                <div class="form-group" style="margin-bottom:20px;">
                    <label for="password">Password *</label>
                    <input type="password" id="password" name="password" required
                           placeholder="Minimum 8 characters" minlength="8" autocomplete="new-password">
                    <div class="form-hint">Password will be hashed with BCrypt before storage</div>
                </div>
                <button type="submit" class="btn btn-primary" style="width:100%;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Create Admin
                </button>
            </form>

            <hr class="divider">
            <div style="font-family:var(--mono);font-size:11px;color:var(--text-muted);line-height:1.8;">
                <div style="color:var(--amber);margin-bottom:6px;">⚠ Security Note</div>
                Passwords are hashed using BCrypt (cost 12). The plaintext password is never stored.
                You cannot recover a lost password — create a new account instead.
            </div>
        </div>
    </div>
</div>

<%@ include file="layout-end.jsp" %>
