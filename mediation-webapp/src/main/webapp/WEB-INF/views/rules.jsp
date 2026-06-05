<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<% request.setAttribute("pageTitle", "Mediation Rules"); %>
<%@ include file="layout.jsp" %>

<%
    List<MediationRule> rules = (List<MediationRule>) request.getAttribute("rules");
    String ctx = request.getContextPath();

    int totalRules  = (rules != null) ? rules.size() : 0;
    int activeRules = 0;
    int pausedRules = 0;
    int totalFilters = 0;
    if (rules != null) {
        for (MediationRule r : rules) {
            if (r.isActive()) activeRules++;
            else pausedRules++;
            if (r.getFiltrationRules() != null) totalFilters += r.getFiltrationRules().size();
        }
    }
%>

<div class="page-header fade-in">
    <div class="page-header-left">
        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a>
            <span class="sep">›</span> Rules
        </div>
        <div class="page-eyebrow">Configuration</div>
        <h1>Mediation Rules</h1>
        <p>Define CDR routing, filtering, and transformation pipelines</p>
    </div>
    <a href="<%= ctx %>/rules/new" class="btn btn-primary">
        <i class="fas fa-plus"></i> New Rule
    </a>
</div>

<% String success = request.getParameter("success"); if (success != null) { %>
<div class="alert alert-success fade-in">
    <i class="fas fa-check-circle"></i>
    Rule <%= "created".equals(success) ? "created" : "updated".equals(success) ? "updated" : "deleted" %> successfully.
</div>
<% } %>
<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-error fade-in">
    <i class="fas fa-exclamation-circle"></i>
    <%= request.getAttribute("error") %>
</div>
<% } %>

<!-- Summary strip -->
<div class="rules-summary-row fade-in-2">
    <div class="rsm-card">
        <div class="rsm-icon rsm-icon-blue"><i class="fas fa-list"></i></div>
        <div><div class="rsm-label">Total Rules</div><div class="rsm-value"><%= totalRules %></div></div>
    </div>
    <div class="rsm-card">
        <div class="rsm-icon rsm-icon-green"><i class="fas fa-circle-check"></i></div>
        <div><div class="rsm-label">Active</div><div class="rsm-value" style="color:var(--green);"><%= activeRules %></div></div>
    </div>
    <div class="rsm-card">
        <div class="rsm-icon rsm-icon-amber"><i class="fas fa-circle-pause"></i></div>
        <div><div class="rsm-label">Paused</div><div class="rsm-value" style="color:var(--amber);"><%= pausedRules %></div></div>
    </div>
    <div class="rsm-card">
        <div class="rsm-icon rsm-icon-violet"><i class="fas fa-filter"></i></div>
        <div><div class="rsm-label">Total Filters</div><div class="rsm-value" style="color:var(--violet);"><%= totalFilters %></div></div>
    </div>
</div>

<!-- Toolbar -->
<div class="rules-toolbar fade-in-3">
    <div class="toolbar-search">
        <i class="fas fa-search"></i>
        <input type="text" id="rule-search" placeholder="Search by ID, source, or destination…" oninput="filterRules()">
    </div>
    <div class="toolbar-filters">
        <div class="filter-group">
            <label>Status</label>
            <div class="filter-btns">
                <button class="fbtn active" data-val="all"    onclick="setStatusFilter('all',    this)">All</button>
                <button class="fbtn"        data-val="active" onclick="setStatusFilter('active', this)">Active</button>
                <button class="fbtn"        data-val="paused" onclick="setStatusFilter('paused', this)">Paused</button>
            </div>
        </div>
        <div class="filter-group">
            <label>Sort</label>
            <select id="sort-select" onchange="sortRules()" class="toolbar-select">
                <option value="id-asc">ID ↑</option>
                <option value="id-desc">ID ↓</option>
                <option value="filters-desc">Most Filters</option>
                <option value="filters-asc">Fewest Filters</option>
                <option value="active-first">Active First</option>
            </select>
        </div>
    </div>
    <span class="toolbar-count" id="visible-count"><%= totalRules %> rule<%= totalRules != 1 ? "s" : "" %></span>
</div>

<!-- Rules table -->
<div class="card fade-in-4">
    <div class="table-wrap">
        <table id="rules-table">
            <thead>
                <tr>
                    <th style="width:52px;">#</th>
                    <th>Source Node</th>
                    <th>Destination Node</th>
                    <th>Filtration Rules</th>
                    <th>Status</th>
                    <th style="width:100px;">Actions</th>
                </tr>
            </thead>
            <tbody id="rules-tbody">
            <%
            if (rules != null && !rules.isEmpty()) {
                for (MediationRule rule : rules) {
                    List<FiltrationRule> filterList = rule.getFiltrationRules();
                    int filterCount = (filterList != null) ? filterList.size() : 0;
                    String statusVal = rule.isActive() ? "active" : "paused";
                    String srcName   = rule.getSourceName()      != null ? rule.getSourceName()      : "—";
                    String dstName   = rule.getDestinationName() != null ? rule.getDestinationName() : "—";
                    String searchKey = (rule.getId() + " " + srcName + " " + dstName).toLowerCase();
            %>
            <tr class="rule-row"
                data-status="<%= statusVal %>"
                data-id="<%= rule.getId() %>"
                data-filters="<%= filterCount %>"
                data-active="<%= rule.isActive() ? 1 : 0 %>"
                data-search="<%= searchKey %>">

                <td class="td-mono"><%= rule.getId() %></td>

                <td>
                    <div style="display:flex;align-items:center;gap:9px;">
                        <div class="node-pill np-amber"><i class="fas fa-arrow-up"></i></div>
                        <div>
                            <div class="td-name"><%= srcName %></div>
                            <div class="td-sub">UPSTREAM</div>
                        </div>
                    </div>
                </td>

                <td>
                    <div style="display:flex;align-items:center;gap:9px;">
                        <div class="node-pill np-green"><i class="fas fa-arrow-down"></i></div>
                        <div>
                            <div class="td-name"><%= dstName %></div>
                            <div class="td-sub">DOWNSTREAM</div>
                        </div>
                    </div>
                </td>

                <td>
                    <% if (filterCount == 0) { %>
                        <span class="no-filters-tag"><i class="fas fa-minus"></i> No filters</span>
                    <% } else { %>
                        <div class="filter-chips-wrap">
                        <% int shown = 0;
                           for (FiltrationRule fr : filterList) {
                               if (shown >= 3) break;
                               String ruleType = fr.getRuleType() != null ? fr.getRuleType().replace("_"," ") : "filter";
                               String chipClass = "fchip-default";
                               if ("BLOCKED_NUMBER".equals(fr.getRuleType())) chipClass = "fchip-red";
                               else if ("FIELD_EQUALS".equals(fr.getRuleType())) chipClass = "fchip-amber";
                               else if (fr.getRuleType() != null && fr.getRuleType().startsWith("FIELD")) chipClass = "fchip-blue";
                        %>
                            <span class="filter-chip <%= chipClass %>"><%= ruleType %></span>
                        <% shown++; } %>
                        <% if (filterCount > 3) { %>
                            <span class="filter-chip-more">+<%= filterCount - 3 %></span>
                        <% } %>
                        </div>
                        <div class="filter-count-sub"><%= filterCount %> filter<%= filterCount != 1 ? "s" : "" %></div>
                    <% } %>
                </td>

                <td>
                    <span class="badge <%= rule.isActive() ? "badge-green badge-active-pulse" : "badge-amber" %>">
                        <%= rule.isActive() ? "Active" : "Paused" %>
                    </span>
                </td>

                <td>
                    <div class="flex gap-2">
                        <a href="<%= ctx %>/rules/<%= rule.getId() %>" class="btn-icon" title="View">
                            <i class="fas fa-eye"></i>
                        </a>
                        <a href="<%= ctx %>/rules/edit/<%= rule.getId() %>" class="btn-icon" title="Edit">
                            <i class="fas fa-pencil"></i>
                        </a>
                        <a href="<%= ctx %>/rules/delete/<%= rule.getId() %>"
                           class="btn-icon danger"
                           data-confirm="Delete rule #<%= rule.getId() %> (<%= srcName %> → <%= dstName %>)? All filtration rules will also be deleted."
                           title="Delete">
                            <i class="fas fa-trash"></i>
                        </a>
                    </div>
                </td>
            </tr>
            <% } } %>
            </tbody>
        </table>

        <!-- Empty state -->
        <div id="rules-empty" style="<%= totalRules == 0 ? "" : "display:none;" %>">
            <div class="empty-state">
                <i class="fas fa-route"></i>
                <div class="empty-title" id="empty-title-text">
                    <%= totalRules == 0 ? "No Rules Configured" : "No Matching Rules" %>
                </div>
                <p id="empty-sub-text">
                    <% if (totalRules == 0) { %>
                        Create your first mediation rule to define CDR routing.
                        <a href="<%= ctx %>/rules/new" style="color:var(--blue);margin-left:4px;">Create Rule →</a>
                    <% } else { %>
                        Try adjusting your search or filters.
                    <% } %>
                </p>
            </div>
        </div>
        <% if (totalRules == 0) { %>
        <script>document.getElementById('rules-tbody').style.display='none';</script>
        <% } %>
    </div>
</div>

<style>
.rules-summary-row {
    display: grid; grid-template-columns: repeat(4,1fr);
    gap: 14px; margin-bottom: 16px;
}
.rsm-card {
    display: flex; align-items: center; gap: 12px;
    padding: 14px 16px; background: white;
    border: 1px solid var(--border-soft); border-radius: 10px;
    box-shadow: var(--shadow-xs);
}
.rsm-icon {
    width: 34px; height: 34px; border-radius: 8px; flex-shrink: 0;
    display: flex; align-items: center; justify-content: center; font-size: 14px;
}
.rsm-icon-blue   { background: var(--blue-subtle);   color: var(--blue);   border: 1px solid var(--blue-border); }
.rsm-icon-green  { background: var(--green-subtle);  color: var(--green);  border: 1px solid var(--green-border); }
.rsm-icon-amber  { background: var(--amber-subtle);  color: var(--amber);  border: 1px solid rgba(217,119,6,0.20); }
.rsm-icon-violet { background: var(--violet-subtle); color: var(--violet); border: 1px solid rgba(124,58,237,0.20); }
.rsm-label { font-family: var(--font-mono); font-size: 9px; color: var(--text-faint); text-transform: uppercase; letter-spacing: 0.10em; font-weight: 500; }
.rsm-value { font-family: var(--font-display); font-size: 26px; font-weight: 800; color: var(--text-primary); letter-spacing: -0.02em; line-height: 1.1; }

.rules-toolbar {
    display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
    margin-bottom: 16px; padding: 12px 14px;
    background: white; border: 1px solid var(--border-soft);
    border-radius: 10px; box-shadow: var(--shadow-xs);
}
.toolbar-search {
    flex: 1; min-width: 200px;
    display: flex; align-items: center; gap: 9px;
    padding: 7px 12px; background: #f8fafc;
    border: 1px solid var(--border-base); border-radius: 7px;
    transition: border-color 0.15s, box-shadow 0.15s;
}
.toolbar-search:focus-within { border-color: var(--blue); box-shadow: 0 0 0 3px rgba(37,99,235,0.08); }
.toolbar-search i { color: var(--text-faint); font-size: 12px; flex-shrink: 0; }
.toolbar-search input { flex: 1; border: none; background: none; outline: none; font-family: var(--font-body); font-size: 13px; color: var(--text-primary); }
.toolbar-search input::placeholder { color: var(--text-placeholder); }

.toolbar-filters { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.filter-group { display: flex; align-items: center; gap: 6px; }
.filter-group > label { font-family: var(--font-mono); font-size: 9px; color: var(--text-faint); text-transform: uppercase; letter-spacing: 0.10em; white-space: nowrap; font-weight: 500; }
.filter-btns { display: flex; gap: 3px; }
.fbtn {
    padding: 4px 12px; border-radius: 6px; border: 1px solid var(--border-base);
    background: white; color: var(--text-muted); font-family: var(--font-body);
    font-size: 12px; font-weight: 500; cursor: pointer; transition: all 0.15s;
}
.fbtn:hover { border-color: var(--border-strong); color: var(--text-primary); }
.fbtn.active { background: var(--blue); border-color: var(--blue); color: white; box-shadow: 0 1px 4px rgba(37,99,235,0.20); }
.toolbar-select {
    padding: 5px 10px; border-radius: 6px; border: 1px solid var(--border-base);
    background: white; color: var(--text-secondary); font-family: var(--font-body);
    font-size: 12.5px; outline: none; cursor: pointer; box-shadow: var(--shadow-xs);
}
.toolbar-select:focus { border-color: var(--blue); box-shadow: 0 0 0 3px rgba(37,99,235,0.08); }
.toolbar-count { margin-left: auto; font-family: var(--font-mono); font-size: 10px; color: var(--text-faint); white-space: nowrap; font-weight: 500; letter-spacing: 0.06em; }

.node-pill { width: 24px; height: 24px; border-radius: 5px; display: flex; align-items: center; justify-content: center; font-size: 9px; flex-shrink: 0; }
.np-amber { background: rgba(217,119,6,0.08); color: var(--amber); border: 1px solid rgba(217,119,6,0.20); }
.np-green { background: var(--green-subtle); color: var(--green); border: 1px solid var(--green-border); }
.td-sub   { font-family: var(--font-mono); font-size: 9px; color: var(--text-faint); letter-spacing: 0.06em; text-transform: uppercase; }

.filter-chips-wrap { display: flex; flex-wrap: wrap; gap: 4px; margin-bottom: 3px; }
.filter-chip { padding: 2px 7px; border-radius: 4px; font-family: var(--font-mono); font-size: 9.5px; font-weight: 500; text-transform: uppercase; letter-spacing: 0.04em; border: 1px solid; }
.fchip-default { background: var(--bg-muted); color: var(--text-muted); border-color: var(--border-base); }
.fchip-red     { background: var(--red-subtle); color: var(--red); border-color: var(--red-border); }
.fchip-amber   { background: var(--amber-subtle); color: var(--amber); border-color: rgba(217,119,6,0.22); }
.fchip-blue    { background: var(--blue-subtle); color: var(--blue); border-color: var(--blue-border); }
.filter-chip-more { padding: 2px 7px; border-radius: 4px; background: var(--bg-muted); color: var(--text-muted); border: 1px solid var(--border-base); font-family: var(--font-mono); font-size: 9.5px; }
.filter-count-sub { font-family: var(--font-mono); font-size: 9px; color: var(--text-faint); }
.no-filters-tag { font-family: var(--font-mono); font-size: 10px; color: var(--text-placeholder); display: flex; align-items: center; gap: 4px; }
.rule-row.hidden-row { display: none; }

@media (max-width: 768px) { .rules-summary-row { grid-template-columns: repeat(2,1fr); } }
</style>

<script>
var currentStatus = 'all';

function setStatusFilter(val, btn) {
    currentStatus = val;
    document.querySelectorAll('.fbtn').forEach(function(b) { b.classList.remove('active'); });
    if (btn) btn.classList.add('active');
    filterRules();
}

function filterRules() {
    var search = (document.getElementById('rule-search').value || '').toLowerCase().trim();
    var rows   = document.querySelectorAll('.rule-row');
    var visible = 0;
    rows.forEach(function(row) {
        var matchSearch = !search || row.dataset.search.indexOf(search) !== -1;
        var matchStatus = currentStatus === 'all' || row.dataset.status === currentStatus;
        if (matchSearch && matchStatus) { row.classList.remove('hidden-row'); visible++; }
        else { row.classList.add('hidden-row'); }
    });
    var countEl = document.getElementById('visible-count');
    if (countEl) countEl.textContent = visible + ' rule' + (visible !== 1 ? 's' : '');
    var emptyEl = document.getElementById('rules-empty');
    var tbody   = document.getElementById('rules-tbody');
    if (emptyEl && tbody && rows.length > 0) {
        if (visible === 0) {
            emptyEl.style.display = 'block';
            tbody.style.display   = 'none';
            document.getElementById('empty-title-text').textContent = 'No Matching Rules';
            document.getElementById('empty-sub-text').textContent   = 'Try adjusting your search or filters.';
        } else {
            emptyEl.style.display = 'none';
            tbody.style.display   = '';
        }
    }
}

function sortRules() {
    var tbody = document.getElementById('rules-tbody');
    if (!tbody) return;
    var rows = Array.from(tbody.querySelectorAll('.rule-row'));
    var val  = document.getElementById('sort-select').value;
    rows.sort(function(a, b) {
        switch(val) {
            case 'id-asc':       return parseInt(a.dataset.id)      - parseInt(b.dataset.id);
            case 'id-desc':      return parseInt(b.dataset.id)      - parseInt(a.dataset.id);
            case 'filters-desc': return parseInt(b.dataset.filters) - parseInt(a.dataset.filters);
            case 'filters-asc':  return parseInt(a.dataset.filters) - parseInt(b.dataset.filters);
            case 'active-first': return parseInt(b.dataset.active)  - parseInt(a.dataset.active);
            default: return 0;
        }
    });
    rows.forEach(function(row) { tbody.appendChild(row); });
    filterRules();
}
</script>

<%@ include file="layout-end.jsp" %>
