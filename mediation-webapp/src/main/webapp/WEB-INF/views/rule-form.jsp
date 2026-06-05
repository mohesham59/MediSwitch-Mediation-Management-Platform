<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<%--
  rule-form.jsp — Create (/rules/new) AND Edit (/rules/edit/{id})

  SAFE scriptlet strategy:
  - ALL model method calls wrapped in try/catch
  - layout.jsp included AFTER all variable setup
  - No calls to non-existent methods (getSourceNodeId removed)
  - Pre-selection by name comparison using getSourceName()/getDestinationName()
--%>
<%
    /* 1. Read rule safely */
    MediationRule rule   = null;
    boolean       isEdit = false;
    String  ruleId       = "";
    String  currentSrc   = "";
    String  currentDst   = "";
    boolean ruleActive   = true;

    try {
        rule = (MediationRule) request.getAttribute("rule");
    } catch (Exception e) { rule = null; }

    if (rule != null) {
        isEdit = true;
        try { ruleId = String.valueOf(rule.getId()); }         catch (Exception e) { ruleId = ""; }
        try { currentSrc = rule.getSourceName(); }             catch (Exception e) { currentSrc = ""; }
        try { currentDst = rule.getDestinationName(); }        catch (Exception e) { currentDst = ""; }
        try { ruleActive  = rule.isActive(); }                 catch (Exception e) { ruleActive = true; }
        if (currentSrc == null) currentSrc = "";
        if (currentDst == null) currentDst = "";
    }

    /* 2. Node lists */
    List<Node> upNodes   = null;
    List<Node> downNodes = null;
    try { upNodes   = (List<Node>) request.getAttribute("upstreamNodes");   } catch (Exception e) {}
    try { downNodes = (List<Node>) request.getAttribute("downstreamNodes"); } catch (Exception e) {}

    /* 3. Page meta */
    String ctx        = request.getContextPath();
    String formAction = isEdit ? ctx + "/rules/edit/" + ruleId : ctx + "/rules/new";
    String pageTitle  = isEdit ? "Edit Rule #" + ruleId : "New Mediation Rule";
    request.setAttribute("pageTitle", pageTitle);
%>
<%@ include file="layout.jsp" %>

<div class="page-header fade-in">
    <div class="page-header-left">
        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a>
            <span class="sep">›</span>
            <a href="<%= ctx %>/rules">Rules</a>
            <span class="sep">›</span>
            <%= isEdit ? "Edit #" + ruleId : "New" %>
        </div>
        <div class="page-eyebrow"><%= isEdit ? "Edit Rule" : "Create Rule" %></div>
        <h1><%= isEdit ? "Edit Mediation Rule #" + ruleId : "Add Mediation Rule" %></h1>
        <p><%= isEdit ? "Update the routing configuration for this rule"
                      : "Link an upstream node to a downstream destination with optional CDR filtering" %></p>
    </div>
    <a href="<%= ctx %>/rules" class="btn btn-outline">
        <i class="fas fa-arrow-left"></i> Back to Rules
    </a>
</div>

<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-error fade-in">
    <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
</div>
<% } %>

<div style="display:grid;grid-template-columns:1fr 290px;gap:20px;align-items:start;">

    <!-- ── Main form ── -->
    <div class="card fade-in-2">
        <div class="card-header">
            <span class="card-title">
                <i class="fas fa-route"></i>
                <%= isEdit ? "Route Configuration" : "New Route" %>
            </span>
            <% if (isEdit) { %>
            <span class="badge <%= ruleActive ? "badge-green badge-active-pulse" : "badge-amber" %>">
                <%= ruleActive ? "Active" : "Paused" %>
            </span>
            <% } %>
        </div>
        <div class="card-body">

            <div class="alert alert-info" style="margin-bottom:20px;">
                <i class="fas fa-circle-info"></i>
                CDRs from the upstream source will be filtered and forwarded to the destination.
                <% if (!isEdit) { %> Filtration rules can be added after creation.<% } %>
            </div>

            <form method="POST" action="<%= formAction %>">

                <div class="form-grid" style="margin-bottom:20px;">

                    <!-- Source node -->
                    <div class="form-group">
                        <label for="sourceNodeId">
                            <i class="fas fa-arrow-up" style="color:var(--amber);font-size:9px;"></i>
                            Source Node (Upstream) *
                        </label>
                        <select id="sourceNodeId" name="sourceNodeId" required onchange="updatePreview()">
                            <option value="">Select upstream node…</option>
                            <% if (upNodes != null) {
                                for (Node n : upNodes) {
                                    String nName = "";
                                    String nFmt  = "";
                                    int    nId   = 0;
                                    try { nName = n.getName();      if (nName == null) nName = ""; } catch (Exception e) {}
                                    try { nFmt  = n.getCdrFormat(); if (nFmt  == null) nFmt  = ""; } catch (Exception e) {}
                                    try { nId   = n.getId(); }      catch (Exception e) {}
                                    boolean sel = isEdit && nName.equals(currentSrc);
                                    String  disp = nFmt.isEmpty() ? nName : nName + " (" + nFmt + ")";
                            %>
                            <option value="<%= nId %>"
                                    data-name="<%= nName %>"
                                    <%= sel ? "selected" : "" %>>
                                <%= disp %>
                            </option>
                            <% } } %>
                        </select>
                    </div>

                    <!-- Destination node -->
                    <div class="form-group">
                        <label for="destinationNodeId">
                            <i class="fas fa-arrow-down" style="color:var(--green);font-size:9px;"></i>
                            Destination Node (Downstream) *
                        </label>
                        <select id="destinationNodeId" name="destinationNodeId" required onchange="updatePreview()">
                            <option value="">Select downstream node…</option>
                            <% if (downNodes != null) {
                                for (Node n : downNodes) {
                                    String nName = "";
                                    int    nId   = 0;
                                    try { nName = n.getName(); if (nName == null) nName = ""; } catch (Exception e) {}
                                    try { nId   = n.getId(); }  catch (Exception e) {}
                                    boolean sel = isEdit && nName.equals(currentDst);
                            %>
                            <option value="<%= nId %>"
                                    data-name="<%= nName %>"
                                    <%= sel ? "selected" : "" %>>
                                <%= nName %>
                            </option>
                            <% } } %>
                        </select>
                    </div>
                </div>

                <!-- Live route preview -->
                <div class="route-preview">
                    <div class="rp-node rp-src" id="rp-src">
                        <%= (isEdit && !currentSrc.isEmpty()) ? currentSrc : "SELECT SOURCE" %>
                    </div>
                    <div class="rp-connector">
                        <div class="rp-lane"></div>
                        <i class="fas fa-arrow-right rp-arr"></i>
                        <div class="rp-lane"></div>
                    </div>
                    <div class="rp-engine">
                        <i class="fas fa-microchip"></i>
                        <span>Engine</span>
                    </div>
                    <div class="rp-connector">
                        <div class="rp-lane"></div>
                        <i class="fas fa-arrow-right rp-arr"></i>
                        <div class="rp-lane"></div>
                    </div>
                    <div class="rp-node rp-dst" id="rp-dst">
                        <%= (isEdit && !currentDst.isEmpty()) ? currentDst : "SELECT DEST" %>
                    </div>
                </div>

                <hr class="divider">
                <div class="flex gap-3">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas <%= isEdit ? "fa-check" : "fa-plus-circle" %>"></i>
                        <%= isEdit ? "Save Changes" : "Create Rule" %>
                    </button>
                    <a href="<%= ctx %>/rules" class="btn btn-outline">
                        <i class="fas fa-times"></i> Cancel
                    </a>
                </div>

            </form>
        </div>
    </div>

    <!-- ── Sidebar ── -->
    <div style="display:flex;flex-direction:column;gap:16px;" class="fade-in-3">

        <div class="card">
            <div class="card-header">
                <span class="card-title"><i class="fas fa-circle-info"></i> How Rules Work</span>
            </div>
            <div class="card-body" style="display:flex;flex-direction:column;gap:10px;">
                <div class="info-step">
                    <div class="info-step-num">1</div>
                    <div>
                        <div class="info-step-title">Select Source</div>
                        <div class="info-step-sub">Choose an upstream node (MSC, SMSC, PGW) as the CDR origin.</div>
                    </div>
                </div>
                <div class="info-step">
                    <div class="info-step-num">2</div>
                    <div>
                        <div class="info-step-title">Select Destination</div>
                        <div class="info-step-sub">Choose a downstream node (Billing, Fraud, Charging) to receive CDRs.</div>
                    </div>
                </div>
                <div class="info-step">
                    <div class="info-step-num">3</div>
                    <div>
                        <div class="info-step-title">Add Filters (optional)</div>
                        <div class="info-step-sub">After saving, add filtration rules to control which CDRs pass through.</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <span class="card-title"><i class="fas fa-server"></i> Available Nodes</span>
            </div>
            <div class="card-body">
                <div style="margin-bottom:12px;">
                    <div style="font-family:var(--font-mono);font-size:8.5px;color:var(--amber);text-transform:uppercase;letter-spacing:.10em;font-weight:600;margin-bottom:6px;">
                        <i class="fas fa-arrow-up"></i> Upstream
                    </div>
                    <% if (upNodes != null && !upNodes.isEmpty()) {
                        for (Node n : upNodes) {
                            String nName = ""; String nFmt = "";
                            try { nName = n.getName();      if (nName==null) nName=""; } catch(Exception e){}
                            try { nFmt  = n.getCdrFormat(); if (nFmt ==null) nFmt =""; } catch(Exception e){}
                    %>
                    <div style="display:flex;align-items:center;gap:6px;padding:5px 0;border-bottom:1px solid var(--border-soft);">
                        <span class="badge badge-amber" style="font-size:8.5px;"><%= nName %></span>
                        <% if (!nFmt.isEmpty()) { %>
                        <span class="badge badge-violet" style="font-size:8px;"><%= nFmt %></span>
                        <% } %>
                    </div>
                    <% } } else { %>
                    <div style="font-family:var(--font-mono);font-size:11px;color:var(--text-faint);">No upstream nodes</div>
                    <% } %>
                </div>
                <div>
                    <div style="font-family:var(--font-mono);font-size:8.5px;color:var(--green);text-transform:uppercase;letter-spacing:.10em;font-weight:600;margin-bottom:6px;">
                        <i class="fas fa-arrow-down"></i> Downstream
                    </div>
                    <% if (downNodes != null && !downNodes.isEmpty()) {
                        for (Node n : downNodes) {
                            String nName = "";
                            try { nName = n.getName(); if (nName==null) nName=""; } catch(Exception e){}
                    %>
                    <div style="display:flex;align-items:center;gap:6px;padding:5px 0;border-bottom:1px solid var(--border-soft);">
                        <span class="badge badge-green" style="font-size:8.5px;"><%= nName %></span>
                    </div>
                    <% } } else { %>
                    <div style="font-family:var(--font-mono);font-size:11px;color:var(--text-faint);">No downstream nodes</div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.route-preview {
    display:flex;align-items:center;justify-content:center;gap:8px;
    padding:16px;background:var(--bg-subtle);border:1px solid var(--border-soft);
    border-radius:10px;margin-bottom:20px;flex-wrap:wrap;
}
.rp-node {
    padding:8px 14px;border-radius:7px;border:1px solid;
    font-family:var(--font-mono);font-size:10.5px;font-weight:600;
    text-transform:uppercase;letter-spacing:.04em;white-space:nowrap;transition:all .2s;
}
.rp-src { border-color:rgba(217,119,6,.25);background:rgba(217,119,6,.07);color:var(--amber); }
.rp-dst { border-color:rgba(5,150,105,.25);background:rgba(5,150,105,.07);color:var(--green); }
.rp-connector { display:flex;align-items:center;gap:4px;flex:1;min-width:36px;max-width:70px; }
.rp-lane { flex:1;height:1.5px;background:var(--border-base); }
.rp-arr  { color:var(--text-faint);font-size:10px;flex-shrink:0; }
.rp-engine {
    display:flex;flex-direction:column;align-items:center;gap:3px;
    padding:8px 12px;background:var(--blue-subtle);border:1px solid var(--blue-border);
    border-radius:7px;font-family:var(--font-mono);font-size:8.5px;
    color:var(--blue);font-weight:600;letter-spacing:.06em;text-transform:uppercase;
}
.info-step { display:flex;gap:10px;align-items:flex-start; }
.info-step-num {
    width:22px;height:22px;border-radius:50%;
    background:var(--blue-subtle);border:1px solid var(--blue-border);
    color:var(--blue);font-family:var(--font-mono);font-size:10px;font-weight:700;
    display:flex;align-items:center;justify-content:center;flex-shrink:0;
}
.info-step-title { font-size:12.5px;font-weight:600;color:var(--text-primary);margin-bottom:2px; }
.info-step-sub   { font-size:11.5px;color:var(--text-muted);line-height:1.5; }
</style>

<script>
function updatePreview() {
    var ss  = document.getElementById('sourceNodeId');
    var ds  = document.getElementById('destinationNodeId');
    var src = document.getElementById('rp-src');
    var dst = document.getElementById('rp-dst');
    var so  = ss.options[ss.selectedIndex];
    var doo = ds.options[ds.selectedIndex];
    src.textContent = (so  && so.value)  ? (so.dataset.name  || so.text)  : 'SELECT SOURCE';
    dst.textContent = (doo && doo.value) ? (doo.dataset.name || doo.text) : 'SELECT DEST';
}
updatePreview();
</script>

<%@ include file="layout-end.jsp" %>
