<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<% request.setAttribute("pageTitle", "Dashboard"); %>
<%@ include file="layout.jsp" %>

<%
    /* ── Null-safe reads of all backend attributes ── */
    Object rawUp   = request.getAttribute("upstreamCount");
    Object rawDown = request.getAttribute("downstreamCount");
    Object rawAR   = request.getAttribute("activeRules");
    Object rawBL   = request.getAttribute("blockedCount");
    Object rawADM  = request.getAttribute("adminCount");
    int up   = (rawUp   instanceof Integer) ? (Integer) rawUp   : 0;
    int down = (rawDown instanceof Integer) ? (Integer) rawDown : 0;
    int ar   = (rawAR   instanceof Integer) ? (Integer) rawAR   : 0;
    int bl   = (rawBL   instanceof Integer) ? (Integer) rawBL   : 0;
    int adm  = (rawADM  instanceof Integer) ? (Integer) rawADM  : 0;
    int total = up + down;
    List<Node> recentNodes = (List<Node>) request.getAttribute("recentNodes");
    String ctx = request.getContextPath();
%>

<!-- ─── Page Header ─── -->
<div class="page-header fade-in">
    <div class="page-header-left">
        <div class="page-eyebrow">Overview</div>
        <h1>System Dashboard</h1>
        <p>Real-time mediation infrastructure status &amp; control center</p>
    </div>
    <div class="flex gap-3 items-center">
        <a href="<%= ctx %>/flow"       class="btn btn-outline"><i class="fas fa-stream"></i> Live Flow</a>
        <a href="<%= ctx %>/nodes/new"  class="btn btn-primary"><i class="fas fa-plus"></i>  Add Node</a>
    </div>
</div>

<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-error fade-in">
    <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
</div>
<% } %>

<!-- ─── KPI Cards — values written directly into HTML as integers ─── -->
<div class="stat-grid fade-in-2">
    <div class="stat-card s-blue">
        <div class="stat-icon"><i class="fas fa-arrow-up"></i></div>
        <div class="stat-label">Upstream Nodes</div>
        <div class="stat-value" data-count="<%= up %>"><%= up %></div>
        <div class="stat-sub">MSC · SMSC · PGW</div>
    </div>
    <div class="stat-card s-green">
        <div class="stat-icon"><i class="fas fa-arrow-down"></i></div>
        <div class="stat-label">Downstream Nodes</div>
        <div class="stat-value" data-count="<%= down %>"><%= down %></div>
        <div class="stat-sub">Billing · Fraud · Charging</div>
    </div>
    <div class="stat-card s-violet">
        <div class="stat-icon"><i class="fas fa-route"></i></div>
        <div class="stat-label">Active Rules</div>
        <div class="stat-value" data-count="<%= ar %>"><%= ar %></div>
        <div class="stat-sub">Mediation pipelines</div>
    </div>
    <div class="stat-card s-red">
        <div class="stat-icon"><i class="fas fa-ban"></i></div>
        <div class="stat-label">Blocked Numbers</div>
        <div class="stat-value" data-count="<%= bl %>"><%= bl %></div>
        <div class="stat-sub">Filtered from routing</div>
    </div>
    <div class="stat-card s-amber">
        <div class="stat-icon"><i class="fas fa-user-shield"></i></div>
        <div class="stat-label">Admin Users</div>
        <div class="stat-value" data-count="<%= adm %>"><%= adm %></div>
        <div class="stat-sub">Console operators</div>
    </div>
</div>

<!-- ─── Mid row: Pipeline + Activity Feed ─── -->
<div class="dash-mid-row fade-in-3">

    <!-- CDR Mediation Pipeline (CSS Grid — guaranteed horizontal) -->
    <div class="card">
        <div class="card-header">
            <span class="card-title"><i class="fas fa-project-diagram"></i> CDR Mediation Pipeline</span>
            <a href="<%= ctx %>/flow" class="btn btn-sm btn-outline"><i class="fas fa-expand-alt"></i> Full View</a>
        </div>
        <div class="card-body" style="padding:20px 16px;">
            <div class="pipeline-grid">

                <!-- Col 1: Upstream nodes -->
                <div class="pg-nodes-col">
                    <div class="pg-node pg-up"><div class="pg-icon pg-amber"><i class="fas fa-broadcast-tower"></i></div><div class="pg-label">MSC</div><div class="pg-sub">Voice</div></div>
                    <div class="pg-node pg-up"><div class="pg-icon pg-amber"><i class="fas fa-envelope"></i></div><div class="pg-label">SMSC</div><div class="pg-sub">SMS</div></div>
                    <div class="pg-node pg-up"><div class="pg-icon pg-amber"><i class="fas fa-wifi"></i></div><div class="pg-label">PGW</div><div class="pg-sub">Data</div></div>
                </div>

                <!-- Col 2: Left animated lanes -->
                <div class="pg-lanes-col">
                    <div class="pg-lane pg-lane-amber"></div>
                    <div class="pg-lane pg-lane-amber pg-lane-d2"></div>
                    <div class="pg-lane pg-lane-amber pg-lane-d3"></div>
                </div>

                <!-- Col 3: Engine -->
                <div class="pg-engine-col">
                    <div class="pg-engine">
                        <div class="pg-engine-ring"></div>
                        <i class="fas fa-microchip" style="font-size:20px;color:var(--blue);"></i>
                        <div style="font-family:var(--font-mono);font-size:7.5px;letter-spacing:.12em;text-transform:uppercase;color:var(--blue);margin-top:5px;font-weight:500;">Engine</div>
                        <div id="eng-ctr" style="font-family:var(--font-display);font-size:18px;font-weight:800;color:var(--blue);margin-top:3px;line-height:1;">0</div>
                        <div style="font-family:var(--font-mono);font-size:7px;color:var(--text-faint);">processed</div>
                    </div>
                </div>

                <!-- Col 4: Right animated lanes -->
                <div class="pg-lanes-col">
                    <div class="pg-lane pg-lane-green pg-lane-r1"></div>
                    <div class="pg-lane pg-lane-green pg-lane-r2"></div>
                    <div class="pg-lane pg-lane-green pg-lane-r3"></div>
                </div>

                <!-- Col 5: Downstream nodes -->
                <div class="pg-nodes-col">
                    <div class="pg-node pg-down"><div class="pg-icon pg-green"><i class="fas fa-file-invoice-dollar"></i></div><div class="pg-label">Billing</div><div class="pg-sub">Revenue</div></div>
                    <div class="pg-node pg-fraud"><div class="pg-icon pg-red"><i class="fas fa-shield-alt"></i></div><div class="pg-label">Fraud</div><div class="pg-sub">Detection</div></div>
                    <div class="pg-node pg-down"><div class="pg-icon pg-green"><i class="fas fa-bolt"></i></div><div class="pg-label">Charging</div><div class="pg-sub">OCS</div></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Live Activity Feed -->
    <div class="card activity-card">
        <div class="card-header">
            <span class="card-title"><i class="fas fa-terminal"></i> Live Activity Feed</span>
            <div class="flex gap-2 items-center">
                <div class="live-badge"><span class="live-dot"></span><span>Live</span></div>
                <button class="btn-icon" id="clear-feed-btn" title="Clear"><i class="fas fa-trash-can"></i></button>
            </div>
        </div>
        <div id="activity-feed" class="activity-feed-wrap"></div>
        <div class="feed-footer">
            <span id="feed-count">0 events</span>
            <span id="feed-rate">—</span>
        </div>
    </div>
</div>

<!-- ─── Nodes Table ─── -->
<div class="card fade-in-4" style="margin-top:20px;">
    <div class="card-header">
        <span class="card-title"><i class="fas fa-server"></i> Network Nodes</span>
        <div class="flex gap-2 items-center">
            <span class="badge badge-gray"><%= total %> nodes</span>
            <a href="<%= ctx %>/nodes" class="btn btn-sm btn-outline"><i class="fas fa-arrow-right"></i> Manage</a>
        </div>
    </div>
    <div class="table-wrap">
        <table>
            <thead>
                <tr><th>Node</th><th>Type</th><th>Protocol</th><th>Address</th><th>CDR Format</th><th>Status</th><th></th></tr>
            </thead>
            <tbody>
            <% if (recentNodes != null && !recentNodes.isEmpty()) {
                for (Node node : recentNodes) {
                    boolean isUp = "UPSTREAM".equals(node.getNodeType()); %>
            <tr>
                <td>
                    <div style="display:flex;align-items:center;gap:10px;">
                        <div class="node-type-badge <%= isUp ? "ntb-amber" : "ntb-green" %>">
                            <i class="fas <%= isUp ? "fa-arrow-up" : "fa-arrow-down" %>"></i>
                        </div>
                        <div>
                            <div class="td-name"><%= node.getName() %></div>
                            <div class="td-mono" style="font-size:10px;">#<%= node.getId() %></div>
                        </div>
                    </div>
                </td>
                <td><span class="badge <%= isUp ? "badge-amber" : "badge-green" %>"><%= node.getNodeType() %></span></td>
                <td><span class="badge badge-gray"><%= node.getProtocol() %></span></td>
                <td class="td-mono"><%= node.getIp() %>:<%= node.getPort() %></td>
                <td>
                    <% String fmt = node.getCdrFormat(); %>
                    <% if (fmt != null && !fmt.isEmpty()) { %>
                    <span class="badge badge-violet"><%= fmt %></span>
                    <% } else { %><span style="color:var(--text-placeholder);font-family:var(--font-mono);font-size:11px;">—</span><% } %>
                </td>
                <td><span class="badge <%= node.isActive() ? "badge-green badge-active-pulse" : "badge-red" %>"><%= node.isActive() ? "Active" : "Offline" %></span></td>
                <td><a href="<%= ctx %>/nodes/edit/<%= node.getId() %>" class="btn-icon" title="Edit"><i class="fas fa-pencil"></i></a></td>
            </tr>
            <% } } else { %>
            <tr><td colspan="7">
                <div class="empty-state">
                    <i class="fas fa-server"></i>
                    <div class="empty-title">No Nodes Configured</div>
                    <p>Add upstream or downstream nodes to begin CDR mediation.</p>
                </div>
            </td></tr>
            <% } %>
            </tbody>
        </table>
    </div>
</div>

<!-- ─── Quick Actions ─── -->
<div class="quick-actions-row fade-in-5">
    <a href="<%= ctx %>/nodes/new"  class="qa-card qa-blue">  <i class="fas fa-plus-circle"></i>  <span>New Node</span></a>
    <a href="<%= ctx %>/rules/new"  class="qa-card qa-violet"><i class="fas fa-route"></i>          <span>New Rule</span></a>
    <a href="<%= ctx %>/blocked"    class="qa-card qa-red">   <i class="fas fa-ban"></i>            <span>Blocked Numbers</span></a>
    <a href="<%= ctx %>/admins"     class="qa-card qa-green"> <i class="fas fa-user-shield"></i>    <span>Manage Admins</span></a>
    <a href="<%= ctx %>/flow"       class="qa-card qa-amber"> <i class="fas fa-stream"></i>         <span>CDR Flow</span></a>
</div>

<!-- ─── Styles ─── -->
<style>
/* Mid row */
.dash-mid-row { display:grid; grid-template-columns:1fr 320px; gap:20px; margin-bottom:20px; }
@media(max-width:960px){ .dash-mid-row { grid-template-columns:1fr; } }

/* ── Pipeline: 5-column CSS Grid (cannot collapse) ── */
.pipeline-grid {
    display: grid;
    grid-template-columns: auto 1fr auto 1fr auto;
    align-items: center;
    width: 100%;
    min-height: 180px;
    gap: 0;
}
.pg-nodes-col { display:flex; flex-direction:column; gap:8px; flex-shrink:0; }
.pg-node {
    display:flex; align-items:center; gap:7px; padding:7px 11px;
    border-radius:7px; border:1px solid; background:white;
    box-shadow:0 1px 3px rgba(15,23,42,0.06); transition:box-shadow 0.15s;
    white-space:nowrap; cursor:default;
}
.pg-node:hover { box-shadow:0 3px 8px rgba(15,23,42,0.10); }
.pg-up    { border-color:rgba(217,119,6,0.22);  background:linear-gradient(135deg,white,rgba(254,243,199,0.30)); }
.pg-down  { border-color:rgba(5,150,105,0.22);  background:linear-gradient(135deg,white,rgba(236,253,245,0.30)); }
.pg-fraud { border-color:rgba(225,29,72,0.20);  background:linear-gradient(135deg,white,rgba(255,241,242,0.30)); }
.pg-icon  { width:22px;height:22px;border-radius:4px;display:flex;align-items:center;justify-content:center;font-size:9px;flex-shrink:0; }
.pg-amber { background:rgba(217,119,6,0.08);  color:var(--amber); }
.pg-green { background:var(--green-subtle);    color:var(--green); }
.pg-red   { background:var(--red-subtle);      color:var(--red); }
.pg-label { font-family:var(--font-mono);font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.04em;color:var(--text-primary); }
.pg-sub   { font-family:var(--font-mono);font-size:8px;color:var(--text-faint); }

.pg-lanes-col {
    display:flex; flex-direction:column; justify-content:space-around;
    align-self:stretch; padding:12px 10px; gap:8px; min-width:50px;
}
.pg-lane { height:2px; border-radius:1px; position:relative; overflow:hidden; flex:1; max-height:2px; }
.pg-lane-amber { background:rgba(217,119,6,0.12); }
.pg-lane-green { background:rgba(5,150,105,0.12); }
.pg-lane::after { content:''; position:absolute; top:0; left:-50%; width:50%; height:100%; animation:pg-flow 2.2s linear infinite; }
.pg-lane-amber::after { background:linear-gradient(90deg,transparent,var(--amber),transparent); }
.pg-lane-green::after { background:linear-gradient(90deg,transparent,var(--green),transparent); }
.pg-lane-d2::after { animation-delay:.73s; }
.pg-lane-d3::after { animation-delay:1.46s; }
.pg-lane-r1::after { animation-delay:.3s; }
.pg-lane-r2::after { animation-delay:1.0s; }
.pg-lane-r3::after { animation-delay:1.7s; }
@keyframes pg-flow { from{left:-50%;} to{left:150%;} }

.pg-engine-col { display:flex; align-items:center; justify-content:center; padding:0 4px; }
.pg-engine {
    width:78px; height:78px; background:var(--blue-subtle);
    border:1.5px solid var(--blue-border); border-radius:12px;
    display:flex; flex-direction:column; align-items:center; justify-content:center;
    box-shadow:0 4px 20px rgba(37,99,235,0.10); position:relative; flex-shrink:0;
}
.pg-engine-ring {
    position:absolute; inset:-6px; border:1.5px solid var(--blue-border);
    border-radius:18px; animation:ring-pulse 2.8s ease-in-out infinite; pointer-events:none;
}
@keyframes ring-pulse { 0%,100%{opacity:.45;transform:scale(1);} 50%{opacity:0;transform:scale(1.06);} }

/* Activity feed */
.activity-card { display:flex; flex-direction:column; }
.activity-feed-wrap {
    flex:1; overflow-y:auto; padding:10px 14px;
    max-height:248px; display:flex; flex-direction:column; gap:2px;
}
.activity-feed-wrap::-webkit-scrollbar { width:3px; }
.activity-feed-wrap::-webkit-scrollbar-thumb { background:var(--border-base); border-radius:4px; }
.feed-item {
    display:flex; align-items:baseline; gap:8px;
    font-family:var(--font-mono); font-size:10.5px;
    padding:4px 0; border-bottom:1px solid rgba(15,23,42,0.04);
    animation:feed-in 0.18s ease both;
}
.feed-item:last-child { border-bottom:none; }
@keyframes feed-in { from{opacity:0;transform:translateX(-5px);} to{opacity:1;transform:none;} }
.feed-time  { color:var(--text-faint); flex-shrink:0; font-size:9.5px; }
.feed-badge { flex-shrink:0; font-size:8px; padding:1px 5px; border-radius:3px; font-weight:600; letter-spacing:.06em; text-transform:uppercase; border:1px solid; }
.fb-voice   { background:rgba(217,119,6,0.08);  color:var(--amber);  border-color:rgba(217,119,6,0.22); }
.fb-sms     { background:var(--violet-subtle);   color:var(--violet); border-color:rgba(124,58,237,0.22); }
.fb-data    { background:var(--green-subtle);    color:var(--green);  border-color:var(--green-border); }
.fb-block   { background:var(--red-subtle);      color:var(--red);    border-color:var(--red-border); }
.fb-sys     { background:var(--blue-subtle);     color:var(--blue);   border-color:var(--blue-border); }
.feed-msg   { color:var(--text-muted); flex:1; }
.feed-footer {
    padding:8px 14px; border-top:1px solid var(--border-soft);
    display:flex; justify-content:space-between;
    font-family:var(--font-mono); font-size:9.5px; color:var(--text-faint);
}
.live-badge {
    display:flex; align-items:center; gap:5px; padding:3px 9px;
    background:var(--red-subtle); border:1px solid rgba(225,29,72,0.18); border-radius:12px;
    font-family:var(--font-mono); font-size:9px; color:var(--red); font-weight:500;
    text-transform:uppercase; letter-spacing:.08em;
}
.live-dot { width:5px;height:5px;background:var(--red);border-radius:50%;animation:blink-r 1s infinite; }
@keyframes blink-r { 0%,100%{opacity:1;} 50%{opacity:0.3;} }

/* Node badge */
.node-type-badge { width:28px;height:28px;border-radius:5px;display:flex;align-items:center;justify-content:center;font-size:11px;flex-shrink:0; }
.ntb-amber { background:rgba(217,119,6,0.08); color:var(--amber); border:1px solid rgba(217,119,6,0.22); }
.ntb-green { background:var(--green-subtle);  color:var(--green);  border:1px solid var(--green-border); }

/* Quick actions */
.quick-actions-row { display:flex; gap:12px; margin-top:20px; flex-wrap:wrap; }
.qa-card {
    flex:1; min-width:120px; display:flex; align-items:center; gap:10px;
    padding:14px 16px; background:white; border:1px solid var(--border-soft);
    border-radius:10px; box-shadow:var(--shadow-xs); transition:all 0.15s;
    font-size:13px; font-weight:600; color:var(--text-secondary);
}
.qa-card:hover { box-shadow:var(--shadow-md); transform:translateY(-2px); }
.qa-card i { font-size:15px; }
.qa-blue   i { color:var(--blue); }   .qa-violet i { color:var(--violet); }
.qa-red    i { color:var(--red); }    .qa-green  i { color:var(--green); }
.qa-amber  i { color:var(--amber); }
</style>

<!-- ─── JS ─── -->
<script>
(function() {
    // ── Animated counters — read the integer already in the element text
    document.querySelectorAll('.stat-value[data-count]').forEach(function(el) {
        var target = parseInt(el.dataset.count, 10);
        if (isNaN(target) || target === 0) { el.textContent = '0'; return; }
        var start = 0;
        var step  = Math.max(1, Math.ceil(target / 28));
        var t = setInterval(function() {
            start = Math.min(start + step, target);
            el.textContent = start;
            if (start >= target) clearInterval(t);
        }, 30);
    });

    // ── Live activity feed simulation
    var feed     = document.getElementById('activity-feed');
    var counter  = document.getElementById('feed-count');
    var rateEl   = document.getElementById('feed-rate');
    var engCtr   = document.getElementById('eng-ctr');
    var clearBtn = document.getElementById('clear-feed-btn');
    var MAX      = 60;
    var total    = 0;
    var recent   = 0;
    var engCount = 0;

    var types   = ['voice','sms','data'];
    var sources = ['MSC-01','MSC-02','SMSC-01','PGW-01','PGW-02'];
    var dests   = ['Billing','Fraud','Charging'];

    function nowStr() {
        var d = new Date();
        var p = function(n){ return String(n).padStart(2,'0'); };
        return p(d.getHours())+':'+p(d.getMinutes())+':'+p(d.getSeconds());
    }

    function addEvent(type, badge, msg) {
        var item = document.createElement('div');
        item.className = 'feed-item';
        item.innerHTML = '<span class="feed-time">'+nowStr()+'</span>'
                        +'<span class="feed-badge fb-'+badge+'">'+type+'</span>'
                        +'<span class="feed-msg">'+msg+'</span>';
        feed.insertBefore(item, feed.firstChild);
        while (feed.children.length > MAX) feed.removeChild(feed.lastChild);
        total++; recent++; engCount++;
        if (engCtr)  engCtr.textContent  = engCount > 999 ? (engCount/1000).toFixed(1)+'k' : engCount;
        if (counter) counter.textContent = total + ' events';
    }

    function randomEvent() {
        var rand  = Math.random();
        var src   = sources[Math.floor(Math.random()*sources.length)];
        var dst   = dests[Math.floor(Math.random()*dests.length)];
        var tp    = types[Math.floor(Math.random()*types.length)];
        var msn   = '+2010' + Math.floor(Math.random()*9000000+1000000);
        if (rand < 0.07) {
            addEvent('BLOCK','block', msn+' blocked — dropped before routing');
        } else if (rand < 0.12) {
            addEvent('SYS','sys', 'Rule engine re-evaluated '+src+' routing table');
        } else {
            var upper = tp.toUpperCase();
            addEvent(upper, tp, 'CDR_'+upper+' '+src+' → Engine → '+dst+'  ['+msn+']');
        }
    }

    // Seed with historical events (reversed so newest is at top)
    var seeds = [
        ['SYS',  'sys',   'MediSwitch engine initialised — all pipelines active'],
        ['VOICE','voice', 'CDR_VOICE MSC-01 → Engine → Billing  [+20101234567]'],
        ['SMS',  'sms',   'CDR_SMS SMSC-01 → Engine → Fraud  [+20109876543]'],
        ['DATA', 'data',  'CDR_DATA PGW-01 → Engine → Charging  [+20107654321]'],
        ['BLOCK','block', '+20100000000 blocked — dropped'],
        ['VOICE','voice', 'CDR_VOICE MSC-02 → Engine → Billing  [+20102345678]'],
        ['SYS',  'sys',   'Blocked-number list refreshed'],
        ['DATA', 'data',  'CDR_DATA PGW-02 → Engine → Charging  [+20103456789]']
    ];
    seeds.slice().reverse().forEach(function(s){ addEvent(s[0],s[1],s[2]); });

    // Live tick: 1.4 – 3 seconds
    function scheduleTick() {
        var delay = 1400 + Math.random() * 1600;
        setTimeout(function(){ randomEvent(); scheduleTick(); }, delay);
    }
    scheduleTick();

    // Events/min rate update every 10s
    setInterval(function(){
        if (rateEl) rateEl.textContent = (recent * 6).toFixed(0) + ' evt/min';
        recent = 0;
    }, 10000);

    // Clear button
    if (clearBtn) clearBtn.addEventListener('click', function(){
        feed.innerHTML = '';
        total = 0; recent = 0;
        if (counter) counter.textContent = '0 events';
        addEvent('SYS','sys','Feed cleared by operator');
    });
})();
</script>

<%@ include file="layout-end.jsp" %>
