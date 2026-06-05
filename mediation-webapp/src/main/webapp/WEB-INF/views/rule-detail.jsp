<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<%--
  rule-detail.jsp — View rule + manage filtration rules
  
  SAFE strategy: All model calls in try/catch BEFORE layout include.
  Matches original API exactly: getSourceName(), getDestinationName(),
  getFiltrationRules(), fr.getRuleType(), fr.getFieldName(), fr.getValue(), fr.isActive()
--%>
<%
    /* 1. Read rule safely — any exception here must not crash the page */
    MediationRule rule = null;
    try { rule = (MediationRule) request.getAttribute("rule"); } catch (Exception e) {}

    String ctx = request.getContextPath();

    /* 2. Extract rule fields safely */
    String  ruleId      = "";
    String  srcName     = "—";
    String  dstName     = "—";
    boolean ruleActive  = false;
    int     filterCount = 0;
    List<FiltrationRule> filterList = new ArrayList<>();

    if (rule != null) {
        try { ruleId = String.valueOf(rule.getId()); }       catch (Exception e) {}
        try { srcName = rule.getSourceName();
              if (srcName == null) srcName = "—"; }          catch (Exception e) {}
        try { dstName = rule.getDestinationName();
              if (dstName == null) dstName = "—"; }          catch (Exception e) {}
        try { ruleActive = rule.isActive(); }                catch (Exception e) {}
        try {
            List<FiltrationRule> tmp = rule.getFiltrationRules();
            if (tmp != null) { filterList = tmp; filterCount = tmp.size(); }
        } catch (Exception e) {}
    }

    request.setAttribute("pageTitle", "Rule #" + ruleId + " Filters");
%>
<%@ include file="layout.jsp" %>

<%-- ── Rule not found ── --%>
<% if (rule == null) { %>
<div class="alert alert-error fade-in">
    <i class="fas fa-exclamation-circle"></i> Rule not found.
</div>
<%@ include file="layout-end.jsp" %>
<% return; } %>

<%-- ── Page header ── --%>
<div class="page-header fade-in">
    <div class="page-header-left">
        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a>
            <span class="sep">›</span>
            <a href="<%= ctx %>/rules">Rules</a>
            <span class="sep">›</span>
            Rule #<%= ruleId %>
        </div>
        <div class="page-eyebrow">Filtration Rules</div>
        <h1>Rule #<%= ruleId %> — Filters</h1>
        <p>
            <span class="badge badge-amber">
                <i class="fas fa-arrow-up" style="font-size:8px;"></i> <%= srcName %>
            </span>
            &nbsp;→&nbsp;
            <span class="badge badge-green">
                <i class="fas fa-arrow-down" style="font-size:8px;"></i> <%= dstName %>
            </span>
        </p>
    </div>
    <div class="flex gap-2">
        <a href="<%= ctx %>/rules/edit/<%= ruleId %>" class="btn btn-outline">
            <i class="fas fa-pencil"></i> Edit Rule
        </a>
        <a href="<%= ctx %>/rules" class="btn btn-outline">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>
</div>

<%-- ── Success / error alerts ── --%>
<% String success = request.getParameter("success"); if (success != null) { %>
<div class="alert alert-success fade-in">
    <i class="fas fa-check-circle"></i> Filter rule added successfully.
</div>
<% } %>
<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-error fade-in">
    <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
</div>
<% } %>

<%-- ── Rule summary banner ── --%>
<div class="rule-banner fade-in-2">
    <div style="display:flex;align-items:center;gap:16px;flex-wrap:wrap;">
        <div>
            <div style="font-family:var(--font-mono);font-size:8.5px;color:var(--text-faint);text-transform:uppercase;letter-spacing:.10em;margin-bottom:6px;">
                Mediation Rule #<%= ruleId %>
            </div>
            <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap;">
                <span class="badge badge-amber">
                    <i class="fas fa-arrow-up" style="font-size:8px;"></i> <%= srcName %>
                </span>
                <i class="fas fa-arrow-right" style="color:var(--text-faint);font-size:11px;"></i>
                <span style="padding:3px 9px;background:var(--blue-subtle);border:1px solid var(--blue-border);border-radius:5px;font-family:var(--font-mono);font-size:9.5px;color:var(--blue);font-weight:500;">
                    <i class="fas fa-microchip" style="font-size:9px;"></i> Engine
                </span>
                <i class="fas fa-arrow-right" style="color:var(--text-faint);font-size:11px;"></i>
                <span class="badge badge-green">
                    <i class="fas fa-arrow-down" style="font-size:8px;"></i> <%= dstName %>
                </span>
            </div>
        </div>
        <div style="margin-left:auto;display:flex;align-items:center;gap:10px;">
            <span class="badge <%= ruleActive ? "badge-green badge-active-pulse" : "badge-red" %>">
                <%= ruleActive ? "Active" : "Inactive" %>
            </span>
            <span class="badge badge-violet"><%= filterCount %> filter<%= filterCount != 1 ? "s" : "" %></span>
        </div>
    </div>
</div>

<%-- ── Two-column layout ── --%>
<div style="display:grid;grid-template-columns:1fr 340px;gap:20px;" class="fade-in-3">

    <%-- ── Left: existing filters table ── --%>
    <div class="card">
        <div class="card-header">
            <span class="card-title"><i class="fas fa-filter"></i> Active Filter Rules</span>
            <span class="badge badge-gray"><%= filterCount %></span>
        </div>

        <% if (filterList.isEmpty()) { %>
        <div class="empty-state" style="padding:36px 20px;">
            <i class="fas fa-filter"></i>
            <div class="empty-title">No Filter Rules</div>
            <p>All CDRs pass through. Add filters to control which records are forwarded.</p>
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
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                <% for (FiltrationRule fr : filterList) {
                    /* Safe reads per filter */
                    int     frId     = 0;
                    String  frType   = "";
                    String  frField  = "";
                    String  frValue  = "";
                    boolean frActive = false;
                    try { frId     = fr.getId(); }        catch (Exception e) {}
                    try { frType   = fr.getRuleType();
                          if (frType == null) frType = ""; }  catch (Exception e) {}
                    try { frField  = fr.getFieldName();
                          if (frField == null) frField = ""; } catch (Exception e) {}
                    try { frValue  = fr.getValue();
                          if (frValue == null) frValue = ""; } catch (Exception e) {}
                    try { frActive = fr.isActive(); }     catch (Exception e) {}

                    /* Badge class by type */
                    String frBadge = "badge-gray";
                    if ("FIELD_EQUALS".equals(frType))    frBadge = "badge-amber";
                    else if ("FIELD_LESS_THAN".equals(frType)) frBadge = "badge-blue";
                    else if ("BLOCKED_NUMBER".equals(frType))  frBadge = "badge-red";
                    else if ("REGEX_MATCH".equals(frType))     frBadge = "badge-violet";

                    String frTypeDisp = frType.replace("_", " ");
                %>
                <tr style="<%= !frActive ? "opacity:0.55;" : "" %>">
                    <td class="td-mono"><%= frId %></td>
                    <td>
                        <span class="badge <%= frBadge %>"><%= frTypeDisp %></span>
                    </td>
                    <td class="td-mono"><%= frField.isEmpty() ? "—" : frField %></td>
                    <td>
                        <% if (!frValue.isEmpty()) { %>
                        <code style="font-family:var(--font-mono);font-size:11px;background:var(--bg-muted);padding:2px 6px;border-radius:4px;border:1px solid var(--border-soft);color:var(--text-secondary);"><%= frValue %></code>
                        <% } else { %>
                        <span style="font-family:var(--font-mono);font-size:10px;color:var(--text-faint);">— blocked_numbers</span>
                        <% } %>
                    </td>
                    <td>
                        <span class="badge <%= frActive ? "badge-green badge-active-pulse" : "badge-red" %>">
                            <%= frActive ? "ON" : "OFF" %>
                        </span>
                    </td>
                    <td>
                        <a href="<%= ctx %>/rules/filter/delete/<%= frId %>"
                           class="btn-icon danger"
                           data-confirm="Delete this filter rule? This cannot be undone."
                           title="Delete filter">
                            <i class="fas fa-trash"></i>
                        </a>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </div>

    <%-- ── Right: add filter form ── --%>
    <div class="card">
        <div class="card-header">
            <span class="card-title"><i class="fas fa-plus-circle"></i> Add Filter Rule</span>
        </div>
        <div class="card-body">
            <form method="POST" action="<%= ctx %>/rules/filter/add/<%= ruleId %>">

                <div class="form-group" style="margin-bottom:14px;">
                    <label for="ruleType">Rule Type *</label>
                    <select id="ruleType" name="ruleType" required onchange="onTypeChange()">
                        <option value="">Select type…</option>
                        <option value="FIELD_EQUALS">FIELD_EQUALS — field == value</option>
                        <option value="FIELD_LESS_THAN">FIELD_LESS_THAN — field &lt; value</option>
                        <option value="BLOCKED_NUMBER">BLOCKED_NUMBER — in blocked list</option>
                        <option value="REGEX_MATCH">REGEX_MATCH — field matches regex</option>
                    </select>
                </div>

                <div class="form-group" style="margin-bottom:14px;">
                    <label for="fieldName">CDR Field Name *</label>
                    <select id="fieldName" name="fieldName" required>
                        <option value="">Select field…</option>
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
                    <label for="value">
                        Value <span id="valueReq" style="color:var(--red);">*</span>
                    </label>
                    <input type="text" id="value" name="value" placeholder="e.g. 0">
                    <div class="form-hint" id="valueHint">Compare against the CDR field value</div>
                </div>

                <button type="submit" class="btn btn-primary w-full">
                    <i class="fas fa-plus"></i> Add Filter
                </button>
            </form>

            <div class="divider"></div>

            <%-- Type reference ── --%>
            <div style="display:flex;flex-direction:column;gap:7px;">
                <div style="font-family:var(--font-mono);font-size:8.5px;color:var(--text-faint);text-transform:uppercase;letter-spacing:.10em;font-weight:500;margin-bottom:2px;">Rule Type Reference</div>
                <div style="display:flex;align-items:flex-start;gap:7px;font-size:12px;">
                    <span class="badge badge-amber" style="flex-shrink:0;white-space:nowrap;">FIELD_EQUALS</span>
                    <span style="color:var(--text-muted);">Drop CDR if field == exact value</span>
                </div>
                <div style="display:flex;align-items:flex-start;gap:7px;font-size:12px;">
                    <span class="badge badge-blue" style="flex-shrink:0;white-space:nowrap;">FIELD_LESS_THAN</span>
                    <span style="color:var(--text-muted);">Drop CDR if numeric field &lt; value</span>
                </div>
                <div style="display:flex;align-items:flex-start;gap:7px;font-size:12px;">
                    <span class="badge badge-red" style="flex-shrink:0;white-space:nowrap;">BLOCKED_NUMBER</span>
                    <span style="color:var(--text-muted);">Drop if caller/sender in blocked list</span>
                </div>
                <div style="display:flex;align-items:flex-start;gap:7px;font-size:12px;">
                    <span class="badge badge-violet" style="flex-shrink:0;white-space:nowrap;">REGEX_MATCH</span>
                    <span style="color:var(--text-muted);">Drop CDR if field matches Java regex</span>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.rule-banner {
    padding:16px 20px; background:white;
    border:1px solid var(--border-soft); border-radius:10px;
    box-shadow:var(--shadow-xs); margin-bottom:20px;
}
</style>

<script>
function onTypeChange() {
    var type  = document.getElementById('ruleType').value;
    var vg    = document.getElementById('valueGroup');
    var vi    = document.getElementById('value');
    var hint  = document.getElementById('valueHint');
    var req   = document.getElementById('valueReq');

    if (type === 'BLOCKED_NUMBER') {
        vg.style.opacity = '0.4';
        vg.style.pointerEvents = 'none';
        vi.disabled   = true;
        vi.value      = '';
        vi.placeholder= 'not needed — uses blocked_numbers table';
        hint.textContent = 'Field is checked against all entries in the blocked_numbers table';
        req.style.display = 'none';
    } else {
        vg.style.opacity = '1';
        vg.style.pointerEvents = 'auto';
        vi.disabled   = false;
        req.style.display = '';
        if (type === 'FIELD_EQUALS')    { vi.placeholder='e.g. 0';            hint.textContent='Drop CDR if field equals this exact value'; }
        if (type === 'FIELD_LESS_THAN') { vi.placeholder='e.g. 1';            hint.textContent='Drop CDR if field (numeric) is less than this value'; }
        if (type === 'REGEX_MATCH')     { vi.placeholder='^00101\\d{10}$';    hint.textContent='Drop CDR if field matches this Java regex pattern'; }
        if (type === '')                { vi.placeholder='e.g. 0';            hint.textContent='Compare against the CDR field value'; }
    }
}
</script>

<%@ include file="layout-end.jsp" %>
