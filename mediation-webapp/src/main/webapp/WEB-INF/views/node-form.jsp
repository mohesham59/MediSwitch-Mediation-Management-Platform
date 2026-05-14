<%@ page contentType="text/html;charset=UTF-8" import="com.mediation.web.model.*" %>
<%
    Node node = (Node) request.getAttribute("node");
    boolean isEdit = node != null;
    request.setAttribute("pageTitle", isEdit ? "Edit Node" : "Add Node");
    String ctx = request.getContextPath();
    String action = isEdit ? ctx + "/nodes/edit/" + node.getId() : ctx + "/nodes/new";
%>
<%@ include file="layout.jsp" %>

<div class="page-header">
    <div class="page-header-left">
        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a> <span>/</span>
            <a href="<%= ctx %>/nodes">Nodes</a> <span>/</span>
            <%= isEdit ? "Edit" : "New" %>
        </div>
        <h1><%= isEdit ? "Edit " + node.getName() : "Add Node" %></h1>
        <p><%= isEdit ? "Update node connection details" : "Register a new upstream or downstream node" %></p>
    </div>
    <a href="<%= ctx %>/nodes" class="btn btn-outline">
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

<div class="card" style="max-width:700px;">
    <div class="card-header">
        <span class="card-title"><%= isEdit ? "Edit Node" : "Node Details" %></span>
    </div>
    <div class="card-body">
        <form method="POST" action="<%= action %>">

            <div class="form-grid" style="margin-bottom:16px;">
                <div class="form-group">
                    <label for="name">Node Name *</label>
                    <input type="text" id="name" name="name" required
                           placeholder="e.g. MSC-1"
                           value="<%= isEdit ? node.getName() : "" %>">
                </div>
                <div class="form-group">
                    <label for="nodeType">Node Type *</label>
                    <select id="nodeType" name="nodeType" required onchange="toggleFormatField()">
                        <option value="">Select type...</option>
                        <option value="UPSTREAM"   <%= isEdit && "UPSTREAM".equals(node.getNodeType())   ? "selected" : "" %>>UPSTREAM (MSC, SMSC, PGW)</option>
                        <option value="DOWNSTREAM" <%= isEdit && "DOWNSTREAM".equals(node.getNodeType()) ? "selected" : "" %>>DOWNSTREAM (Billing, Fraud)</option>
                    </select>
                </div>
            </div>

            <div class="form-grid" style="margin-bottom:16px;">
                <div class="form-group">
                    <label for="protocol">Protocol *</label>
                    <select id="protocol" name="protocol" required>
                        <option value="">Select protocol...</option>
                        <option value="SFTP"  <%= isEdit && "SFTP".equals(node.getProtocol())  ? "selected" : "" %>>SFTP</option>
                        <option value="FTP"   <%= isEdit && "FTP".equals(node.getProtocol())   ? "selected" : "" %>>FTP</option>
                        <option value="SCP"   <%= isEdit && "SCP".equals(node.getProtocol())   ? "selected" : "" %>>SCP</option>
                        <option value="HTTP"  <%= isEdit && "HTTP".equals(node.getProtocol())  ? "selected" : "" %>>HTTP</option>
                        <option value="HTTPS" <%= isEdit && "HTTPS".equals(node.getProtocol()) ? "selected" : "" %>>HTTPS</option>
                    </select>
                </div>
                <div class="form-group" id="formatGroup">
                    <label for="cdrFormat">CDR Format</label>
                    <select id="cdrFormat" name="cdrFormat">
                        <option value="">None (downstream)</option>
                        <option value="voice" <%= isEdit && "voice".equals(node.getCdrFormat()) ? "selected" : "" %>>Voice (MSC)</option>
                        <option value="sms"   <%= isEdit && "sms".equals(node.getCdrFormat())   ? "selected" : "" %>>SMS (SMSC)</option>
                        <option value="data"  <%= isEdit && "data".equals(node.getCdrFormat())  ? "selected" : "" %>>Data (PGW)</option>
                    </select>
                    <div class="form-hint">Required for upstream nodes only</div>
                </div>
            </div>

            <div class="form-grid" style="margin-bottom:16px;">
                <div class="form-group">
                    <label for="ip">IP Address / Hostname *</label>
                    <input type="text" id="ip" name="ip" required
                           placeholder="e.g. msc-node or 192.168.1.10"
                           value="<%= isEdit ? node.getIp() : "" %>">
                </div>
                <div class="form-group">
                    <label for="port">Port *</label>
                    <input type="number" id="port" name="port" required
                           placeholder="2221"
                           value="<%= isEdit ? node.getPort() : "2221" %>">
                </div>
            </div>

            <div class="form-grid" style="margin-bottom:16px;">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username"
                           placeholder="sftp username"
                           value="<%= isEdit && node.getUsername() != null ? node.getUsername() : "" %>">
                </div>
                <div class="form-group">
                    <label for="password">Password <%= isEdit ? "(leave blank to keep current)" : "" %></label>
                    <input type="password" id="password" name="password"
                           placeholder="<%= isEdit ? "leave blank to keep" : "sftp password" %>">
                </div>
            </div>

            <div class="form-group" style="margin-bottom:20px;">
                <label for="remotePath">Remote Path *</label>
                <input type="text" id="remotePath" name="remotePath" required
                       placeholder="/cdr-files"
                       value="<%= isEdit ? node.getRemotePath() : "/cdr-files" %>">
                <div class="form-hint">Directory on the remote node to pull CDRs from (upstream) or push to (downstream)</div>
            </div>

            <div class="form-group" style="margin-bottom:24px;">
                <div class="toggle-wrap">
                    <label class="toggle">
                        <input type="checkbox" name="isActive" value="on" <%= (!isEdit || node.isActive()) ? "checked" : "" %>>
                        <span class="toggle-slider"></span>
                    </label>
                    <span class="toggle-label">Node is active</span>
                </div>
            </div>

            <hr class="divider">
            <div class="flex gap-2">
                <button type="submit" class="btn btn-primary">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                    <%= isEdit ? "Save Changes" : "Create Node" %>
                </button>
                <a href="<%= ctx %>/nodes" class="btn btn-outline">Cancel</a>
            </div>
        </form>
    </div>
</div>

<script>
function toggleFormatField() {
    const type = document.getElementById('nodeType').value;
    const group = document.getElementById('formatGroup');
    group.style.opacity = type === 'DOWNSTREAM' ? '0.5' : '1';
    if (type === 'DOWNSTREAM') {
        document.getElementById('cdrFormat').value = '';
    }
}
// Run on load
toggleFormatField();
</script>

<%@ include file="layout-end.jsp" %>
