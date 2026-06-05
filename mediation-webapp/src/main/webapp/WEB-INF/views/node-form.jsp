<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<%
    Node node  = (Node) request.getAttribute("node");
    boolean isEdit = (node != null);
    String  ctx    = request.getContextPath();
    request.setAttribute("pageTitle", isEdit ? "Edit Node" : "Add Node");
    String action  = isEdit ? ctx + "/nodes/edit/" + node.getId() : ctx + "/nodes/new";

    // Safe defaults
    String nName     = isEdit && node.getName()       != null ? node.getName()       : "";
    String nType     = isEdit && node.getNodeType()   != null ? node.getNodeType()   : "";
    String nProto    = isEdit && node.getProtocol()   != null ? node.getProtocol()   : "";
    String nIp       = isEdit && node.getIp()         != null ? node.getIp()         : "";
    String nUser     = isEdit && node.getUsername()   != null ? node.getUsername()   : "";
    String nPath     = isEdit && node.getRemotePath() != null ? node.getRemotePath() : "/cdr-files";
    String nFmt      = isEdit && node.getCdrFormat()  != null ? node.getCdrFormat()  : "";
    int    nPort     = isEdit ? node.getPort() : 2221;
    boolean nActive  = !isEdit || node.isActive();
%>
<%@ include file="layout.jsp" %>

<div class="page-header fade-in">
    <div class="page-header-left">
        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a>
            <span class="sep">›</span>
            <a href="<%= ctx %>/nodes">Nodes</a>
            <span class="sep">›</span>
            <%= isEdit ? "Edit" : "New" %>
        </div>
        <div class="page-eyebrow"><%= isEdit ? "Edit Node" : "Register Node" %></div>
        <h1><%= isEdit ? nName : "Add Network Node" %></h1>
        <p><%= isEdit ? "Update SFTP/FTP connection details and settings" : "Register a new upstream or downstream network node" %></p>
    </div>
    <a href="<%= ctx %>/nodes" class="btn btn-outline">
        <i class="fas fa-arrow-left"></i> Back
    </a>
</div>

<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-error fade-in">
    <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
</div>
<% } %>

<div style="display:grid;grid-template-columns:1fr 280px;gap:20px;align-items:start;">

    <!-- Main form card -->
    <div class="card fade-in-2">
        <div class="card-header">
            <span class="card-title"><i class="fas fa-server"></i> Node Configuration</span>
            <% if (isEdit) { %>
            <span class="badge <%= nActive ? "badge-green badge-active-pulse" : "badge-red" %>">
                <%= nActive ? "Active" : "Offline" %>
            </span>
            <% } %>
        </div>
        <div class="card-body">
            <form method="POST" action="<%= action %>">

                <div class="nf-section-label"><i class="fas fa-id-card"></i> Node Identity</div>
                <div class="form-grid mb-16">
                    <div class="form-group">
                        <label for="name">Node Name *</label>
                        <input type="text" id="name" name="name" required
                               placeholder="e.g. MSC-PRIMARY" value="<%= nName %>"
                               oninput="updatePreview()">
                    </div>
                    <div class="form-group">
                        <label for="nodeType">Node Type *</label>
                        <select id="nodeType" name="nodeType" required onchange="onTypeChange()">
                            <option value="">Select type…</option>
                            <option value="UPSTREAM"   <%= "UPSTREAM".equals(nType)   ? "selected" : "" %>>UPSTREAM (MSC, SMSC, PGW)</option>
                            <option value="DOWNSTREAM" <%= "DOWNSTREAM".equals(nType) ? "selected" : "" %>>DOWNSTREAM (Billing, Fraud, Charging)</option>
                        </select>
                    </div>
                </div>

                <div class="nf-section-label"><i class="fas fa-plug"></i> Connection</div>
                <div class="form-grid mb-16">
                    <div class="form-group">
                        <label for="protocol">Protocol *</label>
                        <select id="protocol" name="protocol" required>
                            <option value="">Select…</option>
                            <option value="SFTP"  <%= "SFTP".equals(nProto)  ? "selected" : "" %>>SFTP</option>
                            <option value="FTP"   <%= "FTP".equals(nProto)   ? "selected" : "" %>>FTP</option>
                            <option value="SCP"   <%= "SCP".equals(nProto)   ? "selected" : "" %>>SCP</option>
                            <option value="HTTP"  <%= "HTTP".equals(nProto)  ? "selected" : "" %>>HTTP</option>
                            <option value="HTTPS" <%= "HTTPS".equals(nProto) ? "selected" : "" %>>HTTPS</option>
                        </select>
                    </div>
                    <div class="form-group" id="fmtGroup">
                        <label for="cdrFormat">CDR Format</label>
                        <select id="cdrFormat" name="cdrFormat">
                            <option value="">None (downstream)</option>
                            <option value="voice" <%= "voice".equals(nFmt) ? "selected" : "" %>>Voice / MSC</option>
                            <option value="sms"   <%= "sms".equals(nFmt)   ? "selected" : "" %>>SMS / SMSC</option>
                            <option value="data"  <%= "data".equals(nFmt)  ? "selected" : "" %>>Data / PGW</option>
                        </select>
                        <div class="form-hint">Required for upstream nodes only</div>
                    </div>
                </div>
                <div class="form-grid mb-16">
                    <div class="form-group">
                        <label for="ip">IP / Hostname *</label>
                        <input type="text" id="ip" name="ip" required
                               placeholder="192.168.1.10" value="<%= nIp %>"
                               oninput="updatePreview()">
                    </div>
                    <div class="form-group">
                        <label for="port">Port *</label>
                        <input type="number" id="port" name="port" required
                               min="1" max="65535" placeholder="2221"
                               value="<%= nPort %>" oninput="updatePreview()">
                    </div>
                </div>

                <div class="nf-section-label"><i class="fas fa-key"></i> Authentication</div>
                <div class="form-grid mb-16">
                    <div class="form-group">
                        <label for="username">Username</label>
                        <input type="text" id="username" name="username"
                               placeholder="sftp_user" value="<%= nUser %>"
                               autocomplete="off">
                    </div>
                    <div class="form-group">
                        <label for="password">Password<%= isEdit ? " (blank = keep)" : "" %></label>
                        <input type="password" id="password" name="password"
                               placeholder="<%= isEdit ? "Leave blank to keep current" : "SFTP password" %>"
                               autocomplete="new-password">
                    </div>
                </div>

                <div class="nf-section-label"><i class="fas fa-folder"></i> File Transfer</div>
                <div class="form-group mb-16">
                    <label for="remotePath">Remote Path *</label>
                    <input type="text" id="remotePath" name="remotePath" required
                           placeholder="/cdr-files" value="<%= nPath %>">
                    <div class="form-hint">Directory to pull CDRs from (upstream) or push to (downstream)</div>
                </div>

                <div class="form-group" style="margin-bottom:24px;">
                    <label>Node Status</label>
                    <div class="toggle-wrap" style="margin-top:6px;">
                        <label class="toggle">
                            <input type="checkbox" name="isActive" value="on" id="isActiveCheck"
                                   <%= nActive ? "checked" : "" %>
                                   onchange="document.getElementById('toggle-text').textContent=this.checked?'Node is Active':'Node is Inactive'">
                            <div class="toggle-track"></div>
                            <div class="toggle-thumb"></div>
                        </label>
                        <span class="toggle-label" id="toggle-text"><%= nActive ? "Node is Active" : "Node is Inactive" %></span>
                    </div>
                </div>

                <hr class="divider">
                <div class="flex gap-3">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-check"></i>
                        <%= isEdit ? "Save Changes" : "Create Node" %>
                    </button>
                    <a href="<%= ctx %>/nodes" class="btn btn-outline">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- Sidebar -->
    <div style="display:flex;flex-direction:column;gap:16px;" class="fade-in-3">

        <!-- Live preview -->
        <div class="card">
            <div class="card-header"><span class="card-title"><i class="fas fa-eye"></i> Preview</span></div>
            <div class="card-body">
                <div style="padding:14px;background:var(--bg-subtle);border-radius:8px;border:1px solid var(--border-soft);">
                    <div style="font-family:var(--font-mono);font-size:8.5px;color:var(--text-faint);text-transform:uppercase;letter-spacing:.10em;margin-bottom:8px;">Node Preview</div>
                    <div id="prev-name" style="font-family:var(--font-display);font-size:18px;font-weight:800;color:var(--text-primary);margin-bottom:8px;letter-spacing:-.01em;min-height:24px;">—</div>
                    <div id="prev-badges" style="display:flex;flex-wrap:wrap;gap:5px;margin-bottom:8px;"></div>
                    <div id="prev-addr" style="font-family:var(--font-mono);font-size:11px;color:var(--text-muted);">—</div>
                </div>
            </div>
        </div>

        <!-- Node type reference -->
        <div class="card">
            <div class="card-header"><span class="card-title"><i class="fas fa-circle-info"></i> Node Types</span></div>
            <div class="card-body" style="display:flex;flex-direction:column;gap:10px;">
                <div style="padding:10px;background:rgba(217,119,6,0.06);border:1px solid rgba(217,119,6,0.18);border-radius:7px;">
                    <div style="font-family:var(--font-mono);font-size:8.5px;color:var(--amber);letter-spacing:.10em;text-transform:uppercase;margin-bottom:4px;font-weight:600;display:flex;align-items:center;gap:5px;">
                        <i class="fas fa-arrow-up"></i> Upstream
                    </div>
                    <div style="font-size:12px;color:var(--text-muted);line-height:1.5;">MSC, SMSC, PGW nodes. Generate CDR files. CDR format is required.</div>
                </div>
                <div style="padding:10px;background:var(--green-subtle);border:1px solid var(--green-border);border-radius:7px;">
                    <div style="font-family:var(--font-mono);font-size:8.5px;color:var(--green);letter-spacing:.10em;text-transform:uppercase;margin-bottom:4px;font-weight:600;display:flex;align-items:center;gap:5px;">
                        <i class="fas fa-arrow-down"></i> Downstream
                    </div>
                    <div style="font-size:12px;color:var(--text-muted);line-height:1.5;">Billing, Fraud, Charging systems. Receive processed CDR records.</div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.nf-section-label {
    font-family:var(--font-mono); font-size:9px; color:var(--blue);
    letter-spacing:.14em; text-transform:uppercase; margin-bottom:12px;
    padding-bottom:8px; border-bottom:1px solid var(--border-soft);
    display:flex; align-items:center; gap:6px; font-weight:500;
}
.mb-16 { margin-bottom:16px; }
</style>

<script>
function onTypeChange() {
    var type = document.getElementById('nodeType').value;
    var fg   = document.getElementById('fmtGroup');
    if (type === 'DOWNSTREAM') {
        fg.style.opacity = '0.4';
        fg.style.pointerEvents = 'none';
        document.getElementById('cdrFormat').value = '';
    } else {
        fg.style.opacity = '1';
        fg.style.pointerEvents = 'auto';
    }
    updatePreview();
}

function updatePreview() {
    var name  = document.getElementById('name').value  || '—';
    var type  = document.getElementById('nodeType').value;
    var proto = document.getElementById('protocol').value;
    var ip    = document.getElementById('ip').value;
    var port  = document.getElementById('port').value;
    var fmt   = document.getElementById('cdrFormat').value;

    document.getElementById('prev-name').textContent = name;
    document.getElementById('prev-addr').textContent = (ip && port) ? ip+':'+port : '—';

    var b = '';
    if (type)  b += '<span class="badge '+(type==='UPSTREAM'?'badge-amber':'badge-green')+'">'+type+'</span>';
    if (proto) b += '<span class="badge badge-gray">'+proto+'</span>';
    if (fmt)   b += '<span class="badge badge-violet">'+fmt+'</span>';
    document.getElementById('prev-badges').innerHTML = b;
}

// Init
onTypeChange();
updatePreview();
</script>

<%@ include file="layout-end.jsp" %>
