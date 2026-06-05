<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<%
    request.setAttribute("pageTitle", "CDR Flow");
    String ctx = request.getContextPath();

    List<?> rawBlocked = (List<?>) request.getAttribute("blockedNumbers");
    List<?> rawRules   = (List<?>) request.getAttribute("rules");

    StringBuilder blockedJson = new StringBuilder("[");
    if (rawBlocked != null) {
        for (int i = 0; i < rawBlocked.size(); i++) {
            Object b = rawBlocked.get(i);
            if (i > 0) blockedJson.append(",");
            try {
                java.lang.reflect.Method m = b.getClass().getMethod("getNumber");
                blockedJson.append("\"").append(m.invoke(b)).append("\"");
            } catch (Exception e) { blockedJson.append("\"\""); }
        }
    }
    blockedJson.append("]");
    int ruleCount    = rawRules   != null ? rawRules.size()   : 0;
    int blockedCount = rawBlocked != null ? rawBlocked.size() : 0;
%>
<%@ include file="layout.jsp" %>

<!-- ─── Header ─── -->
<div class="page-header fade-in">
    <div class="page-header-left">
        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a>
            <span class="sep">›</span> CDR Flow
        </div>
        <div class="page-eyebrow">Live Monitoring</div>
        <h1>CDR Flow</h1>
        <p>Real-time mediation topology with animated packet visualization</p>
    </div>
    <div class="flex gap-2 items-center">
        <div class="cf-live-pill"><span class="cf-live-dot"></span><span>Live</span></div>
        <button class="btn btn-outline" id="sim-toggle-btn"><i class="fas fa-pause"></i> Pause</button>
        <button class="btn btn-outline" id="sim-clear-btn" title="Clear events"><i class="fas fa-trash-can"></i></button>
    </div>
</div>

<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-error fade-in"><i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %></div>
<% } %>

<!-- ─── Telemetry strip ─── -->
<div class="cf-tele-row fade-in-2">
    <div class="tele-card tc-blue">
        <div class="tc-icon"><i class="fas fa-phone-volume"></i></div>
        <div><div class="tc-label">Voice CDRs</div><div class="tc-value tc-blue-v" id="tc-voice">0</div></div>
    </div>
    <div class="tele-card tc-violet">
        <div class="tc-icon"><i class="fas fa-comment-sms"></i></div>
        <div><div class="tc-label">SMS CDRs</div><div class="tc-value tc-violet-v" id="tc-sms">0</div></div>
    </div>
    <div class="tele-card tc-green">
        <div class="tc-icon"><i class="fas fa-wifi"></i></div>
        <div><div class="tc-label">Data CDRs</div><div class="tc-value tc-green-v" id="tc-data">0</div></div>
    </div>
    <div class="tele-card tc-red">
        <div class="tc-icon"><i class="fas fa-ban"></i></div>
        <div><div class="tc-label">Blocked</div><div class="tc-value tc-red-v" id="tc-blocked">0</div></div>
    </div>
    <div class="tele-card tc-amber">
        <div class="tc-icon"><i class="fas fa-layer-group"></i></div>
        <div><div class="tc-label">Total Processed</div><div class="tc-value tc-amber-v" id="tc-total">0</div></div>
    </div>
</div>

<!-- ─── Flow Topology ─── -->
<!--
    Node layout strategy: Pure CSS % positioning inside the viewport div.
    Nodes are placed by the browser immediately. Canvas draws packets on top.
    No JS measurement needed — completely avoids timing/paint-order bugs.
-->
<div class="card cf-canvas-card fade-in-3">
    <div class="card-header">
        <span class="card-title"><i class="fas fa-project-diagram"></i> Mediation Topology</span>
        <div class="flex gap-2 items-center">
            <span class="badge badge-green badge-active-pulse">Real-time</span>
            <span class="badge badge-gray" id="pkt-count-badge">0 packets</span>
        </div>
    </div>

    <!-- viewport: nodes are CSS-positioned, canvas paints over them -->
    <div class="cf-viewport" id="cf-viewport">
        <canvas id="cf-canvas"></canvas>

        <!-- Upstream — left column, CSS % vertical distribution -->
        <div class="cfn cfn-up cfn-pos-ul" id="cfn-msc"
             data-tip="MSC: Mobile Switching Center — voice CDRs via SFTP">
            <div class="cfn-dot cfn-dot-on"></div>
            <div class="cfn-iw cfni-amber"><i class="fas fa-broadcast-tower"></i></div>
            <div class="cfn-name">MSC</div><div class="cfn-sub">Voice</div>
        </div>
        <div class="cfn cfn-up cfn-pos-um" id="cfn-smsc"
             data-tip="SMSC: Short Message Service Center — SMS CDRs via SFTP">
            <div class="cfn-dot cfn-dot-on"></div>
            <div class="cfn-iw cfni-amber"><i class="fas fa-envelope"></i></div>
            <div class="cfn-name">SMSC</div><div class="cfn-sub">SMS</div>
        </div>
        <div class="cfn cfn-up cfn-pos-lb" id="cfn-pgw"
             data-tip="PGW: Packet Gateway — data CDRs via SFTP">
            <div class="cfn-dot cfn-dot-on"></div>
            <div class="cfn-iw cfni-amber"><i class="fas fa-wifi"></i></div>
            <div class="cfn-name">PGW</div><div class="cfn-sub">Data</div>
        </div>

        <!-- Engine — center -->
        <div class="cfn cfn-engine cfn-pos-center" id="cfn-engine"
             data-tip="Mediation Engine — filters, validates, routes CDR records">
            <div class="cfn-ering"></div>
            <div class="cfn-ering r2"></div>
            <div class="cfn-iw cfni-blue cfni-lg"><i class="fas fa-microchip"></i></div>
            <div class="cfn-name" style="font-size:10px;margin-top:4px;">MEDIATION</div>
            <div class="cfn-sub">ENGINE</div>
            <div id="engine-tps" class="engine-tps">0 rec/s</div>
        </div>

        <!-- Downstream — right column -->
        <div class="cfn cfn-down cfn-pos-ur" id="cfn-billing"
             data-tip="Billing System — processed CDRs for revenue assurance">
            <div class="cfn-dot cfn-dot-on"></div>
            <div class="cfn-iw cfni-green"><i class="fas fa-file-invoice-dollar"></i></div>
            <div class="cfn-name">Billing</div><div class="cfn-sub">Revenue</div>
        </div>
        <div class="cfn cfn-fraud cfn-pos-mr" id="cfn-fraud"
             data-tip="Fraud Detection — blocked and suspicious CDR records">
            <div class="cfn-dot cfn-dot-warn"></div>
            <div class="cfn-iw cfni-red"><i class="fas fa-shield-alt"></i></div>
            <div class="cfn-name">Fraud</div><div class="cfn-sub">Detection</div>
        </div>
        <div class="cfn cfn-down cfn-pos-dr" id="cfn-charging"
             data-tip="Online Charging System — real-time balance deduction">
            <div class="cfn-dot cfn-dot-on"></div>
            <div class="cfn-iw cfni-green"><i class="fas fa-bolt"></i></div>
            <div class="cfn-name">Charging</div><div class="cfn-sub">OCS</div>
        </div>

        <div id="cf-tip" class="cf-tip"></div>
    </div>
</div>

<!-- ─── Bottom row ─── -->
<div class="cf-bottom-row fade-in-4">

    <!-- Rules table -->
    <div class="card">
        <div class="card-header">
            <span class="card-title"><i class="fas fa-route"></i> Active Routing Rules</span>
            <span class="badge badge-blue"><%= ruleCount %> rule<%= ruleCount != 1 ? "s" : "" %></span>
        </div>
        <div class="table-wrap">
            <table>
                <thead><tr><th>#</th><th>Source</th><th>Destination</th><th>Filters</th><th>Status</th></tr></thead>
                <tbody>
                <% if (rawRules != null && !rawRules.isEmpty()) {
                       for (Object rObj : rawRules) {
                           try {
                               Class<?> rc = rObj.getClass();
                               int     id      = (int)     rc.getMethod("getId").invoke(rObj);
                               String  srcName = (String)  rc.getMethod("getSourceName").invoke(rObj);
                               String  dstName = (String)  rc.getMethod("getDestinationName").invoke(rObj);
                               boolean active  = (boolean) rc.getMethod("isActive").invoke(rObj);
                               int filterCount = 0;
                               try { List<?> fl = (List<?>) rc.getMethod("getFiltrationRules").invoke(rObj); if (fl!=null) filterCount=fl.size(); } catch(Exception ignore){}
                %>
                <tr>
                    <td class="td-mono"><%= id %></td>
                    <td><span class="badge badge-amber"><i class="fas fa-arrow-up" style="font-size:8px;"></i> <%= srcName != null ? srcName : "—" %></span></td>
                    <td><span class="badge badge-green"><i class="fas fa-arrow-down" style="font-size:8px;"></i> <%= dstName != null ? dstName : "—" %></span></td>
                    <td><% if(filterCount>0){%><span class="badge badge-violet"><%= filterCount %> filter<%= filterCount!=1?"s":"" %></span><%}else{%><span style="font-family:var(--font-mono);font-size:10.5px;color:var(--text-faint);">No filters</span><%}%></td>
                    <td><span class="badge <%= active ? "badge-green badge-active-pulse" : "badge-gray" %>"><%= active ? "Active" : "Paused" %></span></td>
                </tr>
                <% } catch(Exception ignore){} } } else { %>
                <tr><td colspan="5">
                    <div class="empty-state" style="padding:24px 20px;">
                        <i class="fas fa-route"></i>
                        <div class="empty-title">No Rules Configured</div>
                        <p>Create mediation rules to define CDR routing.</p>
                    </div>
                </td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Event stream -->
    <div class="card cf-events-card">
        <div class="card-header">
            <span class="card-title"><i class="fas fa-terminal"></i> Event Stream</span>
            <button class="btn-icon" id="clear-stream-btn" title="Clear"><i class="fas fa-trash-can"></i></button>
        </div>
        <div id="cf-stream" class="cf-stream-wrap"></div>
        <div style="padding:8px 14px;border-top:1px solid var(--border-soft);display:flex;justify-content:space-between;font-family:var(--font-mono);font-size:9.5px;color:var(--text-faint);">
            <span id="cf-evt-count">0 events</span>
            <span id="cf-evt-rate">—</span>
        </div>
    </div>
</div>

<!-- ─── Styles ─── -->
<style>
.cf-live-pill { display:flex;align-items:center;gap:6px;padding:5px 12px;background:var(--red-subtle);border:1px solid rgba(225,29,72,.18);border-radius:20px;font-family:var(--font-mono);font-size:9.5px;font-weight:500;color:var(--red);text-transform:uppercase;letter-spacing:.08em; }
.cf-live-dot  { width:6px;height:6px;background:var(--red);border-radius:50%;animation:blink-r 1s infinite; }
@keyframes blink-r { 0%,100%{opacity:1;}50%{opacity:.2;} }

/* Telemetry */
.cf-tele-row { display:grid;grid-template-columns:repeat(5,1fr);gap:14px;margin-bottom:20px; }
@media(max-width:900px){ .cf-tele-row{grid-template-columns:repeat(3,1fr);} }
.tele-card { background:white;border:1px solid var(--border-soft);border-radius:12px;padding:16px;box-shadow:var(--shadow-xs);display:flex;align-items:center;gap:12px;position:relative;overflow:hidden; }
.tele-card::before { content:'';position:absolute;top:0;left:0;right:0;height:3px;border-radius:12px 12px 0 0; }
.tc-blue::before   { background:linear-gradient(90deg,var(--blue),var(--violet)); }
.tc-violet::before { background:linear-gradient(90deg,var(--violet),#a855f7); }
.tc-green::before  { background:linear-gradient(90deg,var(--green),var(--green-light)); }
.tc-red::before    { background:linear-gradient(90deg,var(--red),#f43f5e); }
.tc-amber::before  { background:linear-gradient(90deg,var(--amber),#f59e0b); }
.tc-icon { width:32px;height:32px;border-radius:7px;display:flex;align-items:center;justify-content:center;font-size:13px;flex-shrink:0; }
.tc-blue   .tc-icon { background:var(--blue-subtle);   color:var(--blue);   border:1px solid var(--blue-border); }
.tc-violet .tc-icon { background:var(--violet-subtle); color:var(--violet); border:1px solid rgba(124,58,237,.20); }
.tc-green  .tc-icon { background:var(--green-subtle);  color:var(--green);  border:1px solid var(--green-border); }
.tc-red    .tc-icon { background:var(--red-subtle);    color:var(--red);    border:1px solid var(--red-border); }
.tc-amber  .tc-icon { background:var(--amber-subtle);  color:var(--amber);  border:1px solid rgba(217,119,6,.20); }
.tc-label { font-family:var(--font-mono);font-size:8.5px;color:var(--text-faint);text-transform:uppercase;letter-spacing:.10em;font-weight:500; }
.tc-value { font-family:var(--font-display);font-size:26px;font-weight:800;letter-spacing:-.02em;line-height:1.1; }
.tc-blue-v{color:var(--blue);} .tc-violet-v{color:var(--violet);} .tc-green-v{color:var(--green);} .tc-red-v{color:var(--red);} .tc-amber-v{color:var(--amber);}

/* ── Viewport ── */
.cf-canvas-card .card-body { padding:0; }
.cf-viewport {
    position:relative;
    height:380px;
    background:#f8fafc;
    overflow:hidden;
    border-radius:0 0 12px 12px;
}
#cf-canvas { position:absolute;inset:0;width:100%;height:100%;pointer-events:none; }

/* ── Node cards — CSS % positions ── */
.cfn {
    position:absolute;
    display:flex;flex-direction:column;align-items:center;
    padding:10px 8px;border-radius:10px;border:1px solid;
    background:white;box-shadow:var(--shadow-sm);width:82px;
    cursor:default;user-select:none;
    transition:box-shadow .2s,transform .2s;
}
.cfn:hover { box-shadow:var(--shadow-lg);transform:translateY(-2px);z-index:10; }

/* ── Absolute % positions — no JS needed ── */
/* Left column: upstream */
.cfn-pos-ul { left:3%; top:8%;  }
.cfn-pos-um { left:3%; top:42%; }
.cfn-pos-lb { left:3%; top:74%; }
/* Center: engine */
.cfn-pos-center { left:calc(50% - 48px); top:calc(50% - 58px); width:96px; padding:14px 10px; }
/* Right column: downstream */
.cfn-pos-ur { right:3%; top:8%;  }
.cfn-pos-mr { right:3%; top:42%; }
.cfn-pos-dr { right:3%; top:74%; }

/* Node styles */
.cfn-up    { border-color:rgba(217,119,6,.22); background:linear-gradient(160deg,white,rgba(254,252,232,.5)); }
.cfn-down  { border-color:rgba(5,150,105,.22); background:linear-gradient(160deg,white,rgba(240,253,244,.5)); }
.cfn-fraud { border-color:rgba(225,29,72,.20); background:linear-gradient(160deg,white,rgba(255,241,242,.5)); }
.cfn-engine {
    border-color:rgba(37,99,235,.25);
    background:linear-gradient(160deg,white,rgba(239,246,255,.7));
    box-shadow:0 4px 20px rgba(37,99,235,.10);
}

/* Icon wrappers */
.cfn-iw { width:30px;height:30px;border-radius:7px;display:flex;align-items:center;justify-content:center;font-size:12px;margin-bottom:5px;flex-shrink:0; }
.cfni-lg  { width:38px!important;height:38px!important;font-size:16px!important;border-radius:9px!important; }
.cfni-amber { background:rgba(217,119,6,.08); color:var(--amber); border:1px solid rgba(217,119,6,.20); }
.cfni-green { background:var(--green-subtle);  color:var(--green);  border:1px solid var(--green-border); }
.cfni-red   { background:var(--red-subtle);    color:var(--red);    border:1px solid var(--red-border); }
.cfni-blue  { background:var(--blue-subtle);   color:var(--blue);   border:1px solid var(--blue-border); }

.cfn-name { font-family:var(--font-mono);font-size:10.5px;font-weight:600;text-transform:uppercase;letter-spacing:.04em;color:var(--text-primary);text-align:center; }
.cfn-sub  { font-family:var(--font-mono);font-size:8px;color:var(--text-faint);text-align:center;letter-spacing:.06em; }

/* Status dot */
.cfn-dot { position:absolute;top:7px;right:7px;width:6px;height:6px;border-radius:50%; }
.cfn-dot-on   { background:var(--green); box-shadow:0 0 6px rgba(5,150,105,.5); animation:sdot 2.4s infinite; }
.cfn-dot-warn { background:var(--amber); box-shadow:0 0 6px rgba(217,119,6,.5);  animation:sdot 1.2s infinite; }
@keyframes sdot { 0%,100%{opacity:1;}50%{opacity:.3;} }

/* Engine rings */
.cfn-ering { position:absolute;inset:-7px;border:1.5px solid rgba(37,99,235,.20);border-radius:17px;animation:ering 3s ease-in-out infinite;pointer-events:none; }
.cfn-ering.r2 { inset:-13px;border-radius:23px;animation:ering 3s 1s ease-in-out infinite; }
@keyframes ering { 0%,100%{opacity:.4;transform:scale(1);}50%{opacity:0;transform:scale(1.06);} }
.engine-tps { font-family:var(--font-mono);font-size:8px;color:var(--blue);margin-top:4px;background:var(--blue-subtle);padding:2px 6px;border-radius:4px;border:1px solid var(--blue-border); }

/* Tooltip */
.cf-tip { position:absolute;z-index:50;padding:8px 12px;background:var(--text-primary);color:white;border-radius:7px;font-size:12px;max-width:220px;line-height:1.5;pointer-events:none;opacity:0;transition:opacity .15s;box-shadow:var(--shadow-lg); }
.cf-tip.visible { opacity:1; }

/* Bottom row */
.cf-bottom-row { display:grid;grid-template-columns:1fr 340px;gap:20px;margin-top:20px; }
@media(max-width:960px){ .cf-bottom-row{grid-template-columns:1fr;} }

/* Event stream */
.cf-events-card { display:flex;flex-direction:column; }
.cf-stream-wrap { flex:1;overflow-y:auto;padding:10px 14px;max-height:280px;display:flex;flex-direction:column;gap:2px; }
.cf-stream-wrap::-webkit-scrollbar{width:3px;} .cf-stream-wrap::-webkit-scrollbar-thumb{background:var(--border-base);border-radius:4px;}
.cf-evt { display:flex;align-items:baseline;gap:7px;font-family:var(--font-mono);font-size:10.5px;padding:3px 0;border-bottom:1px solid rgba(15,23,42,.04);animation:cfi .18s ease both; }
.cf-evt:last-child{border-bottom:none;}
@keyframes cfi{from{opacity:0;transform:translateX(-5px);}to{opacity:1;transform:none;}}
.cft{color:var(--text-faint);flex-shrink:0;font-size:9.5px;}
.cfb{flex-shrink:0;font-size:8px;padding:1px 5px;border-radius:3px;font-weight:600;letter-spacing:.05em;text-transform:uppercase;border:1px solid;}
.cfb-v{background:rgba(217,119,6,.08);color:var(--amber);border-color:rgba(217,119,6,.22);}
.cfb-s{background:var(--violet-subtle);color:var(--violet);border-color:rgba(124,58,237,.22);}
.cfb-d{background:var(--green-subtle);color:var(--green);border-color:var(--green-border);}
.cfb-b{background:var(--red-subtle);color:var(--red);border-color:var(--red-border);}
.cfb-x{background:var(--blue-subtle);color:var(--blue);border-color:var(--blue-border);}
.cfm{color:var(--text-muted);flex:1;}
</style>

<!-- ─── Canvas packet animation ─── -->
<script>
(function(){
    'use strict';

    var BLOCKED  = <%= blockedJson %>;
    var running  = true;
    var packets  = [];
    var evtTotal = 0, evtRecent = 0, tpsRecent = 0;
    var counts   = { voice:0, sms:0, data:0, blocked:0 };
    var COLORS   = { voice:'#d97706', sms:'#7c3aed', data:'#059669', blocked:'#e11d48' };
    var UP_IDS   = ['cfn-msc','cfn-smsc','cfn-pgw'];
    var DOWN_IDS = ['cfn-billing','cfn-fraud','cfn-charging'];

    var canvas   = document.getElementById('cf-canvas');
    var ctx      = canvas.getContext('2d');
    var viewport = document.getElementById('cf-viewport');

    /* ── Resize canvas to match viewport ── */
    function resize() {
        canvas.width  = viewport.clientWidth;
        canvas.height = viewport.clientHeight;
    }

    /* ── Node center from CSS-positioned element ──
       Uses getBoundingClientRect relative to viewport rect.
       This is safe AFTER layout (which CSS guarantees before first paint).
       We call it per-frame so it's always fresh even on resize. ── */
    function center(id) {
        var el = document.getElementById(id);
        if (!el) return { x: canvas.width/2, y: canvas.height/2 };
        var vr = viewport.getBoundingClientRect();
        var nr = el.getBoundingClientRect();
        return {
            x: nr.left - vr.left + nr.width  / 2,
            y: nr.top  - vr.top  + nr.height / 2
        };
    }

    /* ── Spawn a packet ── */
    function spawnPacket() {
        var isBlocked = BLOCKED.length > 0 && Math.random() < 0.12;
        var type   = isBlocked ? 'blocked' : ['voice','sms','data'][Math.floor(Math.random()*3)];
        var fromId = UP_IDS[Math.floor(Math.random() * UP_IDS.length)];
        var toId   = isBlocked ? 'cfn-fraud' : DOWN_IDS[Math.floor(Math.random() * DOWN_IDS.length)];

        var src = center(fromId);
        var eng = center('cfn-engine');
        var dst = center(toId);

        packets.push({
            type:type, color:COLORS[type],
            phase:0, t:0, speed:0.022 + Math.random()*0.014,
            sx:src.x, sy:src.y,
            ex:eng.x, ey:eng.y,
            dx:dst.x, dy:dst.y,
            x:src.x,  y:src.y,
            r:4 + Math.random()*2.5,
            trail:[]
        });

        counts[type]++;
        var tot = counts.voice + counts.sms + counts.data + counts.blocked;
        var ids = { voice:'tc-voice', sms:'tc-sms', data:'tc-data', blocked:'tc-blocked' };
        var el  = document.getElementById(ids[type]);
        if (el) el.textContent = counts[type];
        var telEl = document.getElementById('tc-total');
        if (telEl) telEl.textContent = tot;
        var badge = document.getElementById('pkt-count-badge');
        if (badge) badge.textContent = tot + ' packets';

        addEvt(type, fromId, toId);
        tpsRecent++;
    }

    /* ── Draw frame ── */
    function draw() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        var eng = center('cfn-engine');

        /* Guide dashes */
        ctx.setLineDash([5,8]);
        ctx.lineWidth = 1.5;
        UP_IDS.forEach(function(id){
            var p = center(id);
            ctx.beginPath();
            ctx.strokeStyle = 'rgba(217,119,6,0.09)';
            ctx.moveTo(p.x + 41, p.y);
            ctx.lineTo(eng.x - 48, eng.y);
            ctx.stroke();
        });
        DOWN_IDS.forEach(function(id){
            var p = center(id);
            ctx.beginPath();
            ctx.strokeStyle = 'rgba(5,150,105,0.09)';
            ctx.moveTo(eng.x + 48, eng.y);
            ctx.lineTo(p.x - 41, p.y);
            ctx.stroke();
        });
        ctx.setLineDash([]);

        /* Packets */
        packets.forEach(function(p){
            /* Trail */
            if (p.trail.length > 1) {
                ctx.beginPath();
                ctx.strokeStyle = p.color + '28';
                ctx.lineWidth   = p.r * 1.5;
                ctx.lineCap     = 'round';
                ctx.moveTo(p.trail[0].x, p.trail[0].y);
                p.trail.forEach(function(pt){ ctx.lineTo(pt.x, pt.y); });
                ctx.stroke();
            }
            /* Glow */
            var grd = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.r * 3.5);
            grd.addColorStop(0, p.color + '55');
            grd.addColorStop(1, p.color + '00');
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.r*3.5, 0, Math.PI*2);
            ctx.fillStyle = grd;
            ctx.fill();
            /* Core */
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.r, 0, Math.PI*2);
            ctx.fillStyle   = p.color;
            ctx.globalAlpha = 0.92;
            ctx.fill();
            ctx.globalAlpha = 1;
        });
    }

    /* ── Update packets ── */
    function update() {
        packets = packets.filter(function(p){
            p.trail.push({ x:p.x, y:p.y });
            if (p.trail.length > 6) p.trail.shift();
            p.t += p.speed;
            var t1 = Math.min(p.t, 1);
            var e  = 1 - Math.pow(1 - t1, 2);
            if (p.phase === 0) {
                p.x = p.sx + (p.ex - p.sx) * e;
                p.y = p.sy + (p.ey - p.sy) * e;
                if (p.t >= 1) { p.phase = 1; p.t = 0; }
            } else {
                p.x = p.ex + (p.dx - p.ex) * e;
                p.y = p.ey + (p.dy - p.ey) * e;
                if (p.t >= 1) return false;
            }
            return true;
        });
    }

    /* ── Event stream ── */
    function addEvt(type, fromId, toId) {
        var stream = document.getElementById('cf-stream');
        if (!stream) return;
        var d = new Date();
        var p = function(n){ return String(n).padStart(2,'0'); };
        var ts = p(d.getHours())+':'+p(d.getMinutes())+':'+p(d.getSeconds());
        var src = fromId.replace('cfn-','').toUpperCase();
        var dst = toId.replace('cfn-','').toUpperCase();
        var tm  = { voice:'VOICE', sms:'SMS', data:'DATA', blocked:'BLOCK' };
        var cm  = { voice:'cfb-v', sms:'cfb-s', data:'cfb-d', blocked:'cfb-b' };
        var msg = {
            voice:   'CDR_VOICE   '+src+' → Engine → '+dst,
            sms:     'CDR_SMS     '+src+' → Engine → '+dst,
            data:    'CDR_DATA    '+src+' → Engine → '+dst,
            blocked: 'BLOCKED     '+src+' → Engine [FILTERED] → '+dst
        };
        var div = document.createElement('div');
        div.className = 'cf-evt';
        div.innerHTML = '<span class="cft">'+ts+'</span>'
                      + '<span class="cfb '+cm[type]+'">'+tm[type]+'</span>'
                      + '<span class="cfm">'+msg[type]+'</span>';
        stream.insertBefore(div, stream.firstChild);
        while (stream.children.length > 80) stream.removeChild(stream.lastChild);
        evtTotal++; evtRecent++;
        var ec = document.getElementById('cf-evt-count');
        if (ec) ec.textContent = evtTotal + ' events';
    }

    /* Seed the stream */
    [['sms','cfn-smsc','cfn-fraud'],
     ['data','cfn-pgw','cfn-charging'],
     ['voice','cfn-msc','cfn-billing'],
     ['blocked','cfn-smsc','cfn-fraud']].forEach(function(row){
        addEvt(row[0], row[1], row[2]);
    });

    /* ── Main loop ── */
    var lastSpawn = 0;
    function loop(ts) {
        if (!running) { requestAnimationFrame(loop); return; }
        /* Resize every frame — cheap, ensures canvas matches viewport after any layout change */
        resize();
        if (ts - lastSpawn > 500 + Math.random()*600) {
            spawnPacket();
            lastSpawn = ts;
        }
        update();
        draw();
        requestAnimationFrame(loop);
    }

    /* ── TPS / rate display ── */
    setInterval(function(){
        var el = document.getElementById('engine-tps');
        if (el) el.textContent = tpsRecent + ' rec/s';
        var re = document.getElementById('cf-evt-rate');
        if (re) re.textContent = (evtRecent*6).toFixed(0) + ' evt/min';
        tpsRecent = 0; evtRecent = 0;
    }, 10000);

    /* ── Tooltip ── */
    var tip = document.getElementById('cf-tip');
    document.querySelectorAll('.cfn[data-tip]').forEach(function(el){
        el.addEventListener('mouseenter', function(){
            if(!tip) return;
            tip.textContent = el.dataset.tip;
            tip.classList.add('visible');
        });
        el.addEventListener('mousemove', function(e){
            if(!tip) return;
            var vr = viewport.getBoundingClientRect();
            var tx = e.clientX - vr.left + 12;
            var ty = e.clientY - vr.top  - tip.offsetHeight - 10;
            if (tx + 220 > viewport.offsetWidth)  tx = e.clientX - vr.left - 232;
            if (ty < 0)                            ty = e.clientY - vr.top  + 16;
            tip.style.left = tx + 'px';
            tip.style.top  = ty + 'px';
        });
        el.addEventListener('mouseleave', function(){
            if(tip) tip.classList.remove('visible');
        });
    });

    /* ── Controls ── */
    var toggleBtn = document.getElementById('sim-toggle-btn');
    if (toggleBtn) toggleBtn.addEventListener('click', function(){
        running = !running;
        toggleBtn.innerHTML = running
            ? '<i class="fas fa-pause"></i> Pause'
            : '<i class="fas fa-play"></i>  Resume';
    });

    function clearStream() {
        var s = document.getElementById('cf-stream');
        if (s) { s.innerHTML=''; addEvt('sms','cfn-smsc','cfn-fraud'); }
    }
    var clearBtn = document.getElementById('sim-clear-btn');
    if (clearBtn) clearBtn.addEventListener('click', clearStream);
    var clearSBtn = document.getElementById('clear-stream-btn');
    if (clearSBtn) clearSBtn.addEventListener('click', clearStream);
    window.clearCfStream = clearStream;

    window.addEventListener('resize', resize);

    /* ── START — CSS-positioned nodes are ready synchronously,
       getBoundingClientRect is valid as soon as the browser has painted.
       We use requestAnimationFrame to guarantee first paint has happened. ── */
    requestAnimationFrame(function(){
        resize();
        requestAnimationFrame(loop);
    });

})();
</script>

<%@ include file="layout-end.jsp" %>
