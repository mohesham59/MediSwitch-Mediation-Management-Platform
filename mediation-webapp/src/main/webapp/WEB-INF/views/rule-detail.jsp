<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<%
    MediationRule rule = (MediationRule) request.getAttribute("rule");
    request.setAttribute("pageTitle", "Rule #" + (rule != null ? rule.getId() : "") + " Filters");
    String ctx = request.getContextPath();
%>
<%@ include file="layout.jsp" %>

<% if (rule == null) { %>
<div class="alert alert-error">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    Rule not found.
</div>
<%@ include file="layout-end.jsp" %>
<% return; } %>

<div class="page-header">
    <div class="page-header-left">
        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a> <span>/</span>
            <a href="<%= ctx %>/rules">Rules</a> <span>/</span>
            Rule #<%= rule.getId() %>
        </div>
        <h1>Filtration Rules</h1>
        <p>Manage filter predicates for: <strong><%= rule.getSourceName() %></strong> → <strong><%= rule.getDestinationName() %></strong></p>
    </div>
    <a href="<%= ctx %>/rules" class="btn btn-outline">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg>
        Back to Rules
    </a>
</div>

<% String success = request.getParameter("success"); if (success != null) { %>
<div class="alert alert-success">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
    Filter rule added successfully.
</div>
<% } %>

<!-- Rule summary banner -->
<div style="background:var(--bg2);border:1px solid var(--border);border-radius:8px;padding:16px 20px;margin-bottom:24px;display:flex;align-items:center;gap:20px;flex-wrap:wrap;">
    <div>
        <div style="font-family:var(--mono);font-size:10px;color:var(--text-muted);text-transform:uppercase;letter-spacing:.1em;margin-bottom:4px;">Mediation Rule #<%= rule.getId() %></div>
        <div class="flow">
            <span class="badge badge-amber"><%= rule.getSourceName() %></span>
            <span class="flow-arrow">──→</span>
            <span class="badge badge-cyan"><%= rule.getDestinationName() %></span>
        </div>
    </div>
    <div style="margin-left:auto;display:flex;align-items:center;gap:10px;">
        <span class="badge <%= rule.isActive() ? "badge-green" : "badge-red" %>">
            <%= rule.isActive() ? "ACTIVE" : "INACTIVE" %>
        </span>
        <span style="font-family:var(--mono);font-size:12px;color:var(--text-dim);"><%= rule.getFiltrationRules().size() %> filter(s)</span>
    </div>
</div>

<div style="display:grid;grid-template-columns:1fr 360px;gap:20px;align-items:start;">

    <!-- Existing filtration rules -->
    <div class="card">
        <div class="card-header">
            <span class="card-title">Active Filter Rules</span>
            <span class="badge badge-gray"><%= rule.getFiltrationRules().size() %></span>
        </div>
        <% if (rule.getFiltrationRules().isEmpty()) { %>
        <div class="empty-state" style="padding:32px;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="width:32px;height:32px;margin-bottom:10px;opacity:0.3;"><path d="M22 3H2l8 9.46V19l4 2v-8.54L22 3z"/></svg>
            <p style="font-size:12px;">No filter rules yet. All CDRs pass through.</p>
        </div>
        <% } else { %>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Rule Type</th>
                        <th>Field</th>
                        <th>Value</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                <% for (FiltrationRule fr : rule.getFiltrationRules()) { %>
                <tr style="<%= !fr.isActive() ? "opacity:0.5;" : "" %>">
                    <td class="td-mono"><%= fr.getId() %></td>
                    <td>
                        <span class="badge
                            <%= fr.getRuleType().equals("FIELD_EQUALS")    ? "badge-amber" :
                               fr.getRuleType().equals("FIELD_LESS_THAN")  ? "badge-cyan"  :
                               fr.getRuleType().equals("BLOCKED_NUMBER")   ? "badge-red"   : "badge-gray" %>">
                            <%= fr.getRuleType().replace("_", " ") %>
                        </span>
                    </td>
                    <td class="td-mono"><%= fr.getFieldName() %></td>
                    <td class="td-mono">
                        <% if (fr.getValue() != null && !fr.getValue().isEmpty()) { %>
                        <span style="color:var(--amber)"><%= fr.getValue() %></span>
                        <% } else { %><span style="color:var(--text-muted)">— (uses blocked_numbers)</span><% } %>
                    </td>
                    <td><span class="badge <%= fr.isActive() ? "badge-green" : "badge-red" %>"><%= fr.isActive() ? "ON" : "OFF" %></span></td>
                    <td>
                        <a href="<%= ctx %>/rules/filter/delete/<%= fr.getId() %>"
                           class="btn-icon danger"
                           data-confirm="Delete this filter rule?"
                           title="Delete">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14H6L5 6"/><path d="M10 11v6M14 11v6"/><path d="M9 6V4h6v2"/></svg>
                        </a>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>

    <!-- Add filter form -->
    <div class="card">
        <div class="card-header"><span class="card-title">Add Filter Rule</span></div>
        <div class="card-body">
            <form method="POST" action="<%= ctx %>/rules/filter/add/<%= rule.getId() %>">

                <div class="form-group" style="margin-bottom:14px;">
                    <label for="ruleType">Rule Type *</label>
                    <select id="ruleType" name="ruleType" required onchange="updateValueField()">
                        <option value="">Select type...</option>
                        <option value="FIELD_EQUALS">FIELD_EQUALS — field == value</option>
                        <option value="FIELD_LESS_THAN">FIELD_LESS_THAN — field &lt; value</option>
                        <option value="BLOCKED_NUMBER">BLOCKED_NUMBER — in blocked list</option>
                        <option value="REGEX_MATCH">REGEX_MATCH — field matches regex</option>
                    </select>
                </div>

                <div class="form-group" style="margin-bottom:14px;">
                    <label for="fieldName">CDR Field Name *</label>
                    <select id="fieldName" name="fieldName" required>
                        <option value="">Select field...</option>
                        <optgroup label="Voice (MSC)">
                            <option value="caller_id">caller_id</option>
                            <option value="receiver_id">receiver_id</option>
                            <option value="start_time">start_time</option>
                            <option value="duration">duration</option>
                            <option value="hplmn">hplmn</option>
                            <option value="vplmn">vplmn</option>
                        </optgroup>
                        <optgroup label="SMS (SMSC)">
                            <option value="sender_id">sender_id</option>
                            <option value="receiver_id">receiver_id</option>
                            <option value="timestamp">timestamp</option>
                            <option value="message_length">message_length</option>
                        </optgroup>
                        <optgroup label="Data (PGW)">
                            <option value="imsi">imsi</option>
                            <option value="session_start">session_start</option>
                            <option value="session_duration">session_duration</option>
                            <option value="data_usage_mb">data_usage_mb</option>
                        </optgroup>
                    </select>
                </div>

                <div class="form-group" id="valueGroup" style="margin-bottom:20px;">
                    <label for="value">Value <span id="valueRequired"></span></label>
                    <input type="text" id="value" name="value" placeholder="e.g. 0">
                    <div class="form-hint" id="valueHint">The value to compare against the CDR field</div>
                </div>

                <button type="submit" class="btn btn-primary" style="width:100%;">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    Add Filter
                </button>
            </form>

            <hr class="divider">
            <div style="font-family:var(--mono);font-size:11px;color:var(--text-muted);line-height:1.8;">
                <div style="color:var(--text-dim);font-weight:700;margin-bottom:6px;">Rule Type Reference</div>
                <div><span style="color:var(--amber)">FIELD_EQUALS</span> — drop if field == "0"</div>
                <div><span style="color:var(--cyan)">FIELD_LESS_THAN</span> — drop if field &lt; 1</div>
                <div><span style="color:var(--red)">BLOCKED_NUMBER</span> — drop if in blocked_numbers table</div>
                <div><span style="color:var(--text-dim)">REGEX_MATCH</span> — drop if field matches pattern</div>
            </div>
        </div>
    </div>
</div>

<script>
function updateValueField() {
    const type = document.getElementById('ruleType').value;
    const valueGroup = document.getElementById('valueGroup');
    const valueInput = document.getElementById('value');
    const hint = document.getElementById('valueHint');
    const req = document.getElementById('valueRequired');

    if (type === 'BLOCKED_NUMBER') {
        valueGroup.style.opacity = '0.4';
        valueInput.disabled = true;
        valueInput.value = '';
        valueInput.placeholder = 'not needed — uses blocked_numbers table';
        hint.textContent = 'The field will be checked against all entries in blocked_numbers table';
        req.textContent = '(not required)';
    } else {
        valueGroup.style.opacity = '1';
        valueInput.disabled = false;
        req.textContent = '*';
        if (type === 'FIELD_EQUALS')    { valueInput.placeholder = 'e.g. 0'; hint.textContent = 'Drop CDR if field equals this exact value'; }
        if (type === 'FIELD_LESS_THAN') { valueInput.placeholder = 'e.g. 1'; hint.textContent = 'Drop CDR if field (numeric) is less than this value'; }
        if (type === 'REGEX_MATCH')     { valueInput.placeholder = 'e.g. ^00101\\d{10}$'; hint.textContent = 'Drop CDR if field matches this Java regex pattern'; }
    }
}
</script>

<%@ include file="layout-end.jsp" %>
