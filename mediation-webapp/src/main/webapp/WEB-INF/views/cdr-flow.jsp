<%@ page contentType="text/html;charset=UTF-8" import="java.util.*,com.mediation.web.model.*" %>
<%
    request.setAttribute("pageTitle", "CDR Flow");
    String ctx = request.getContextPath();

    // Build blocked numbers JSON array for JS
    List<BlockedNumber> blockedNumbers = (List<BlockedNumber>) request.getAttribute("blockedNumbers");
    StringBuilder blockedJson = new StringBuilder("[");
    if (blockedNumbers != null) {
        for (int i = 0; i < blockedNumbers.size(); i++) {
            if (i > 0) {
                blockedJson.append(",");
            }
            blockedJson.append("\"").append(blockedNumbers.get(i).getNumber()).append("\"");
        }
    }
    blockedJson.append("]");

    // Build mediation rules JSON for routing logic
    List<MediationRule> rules = (List<MediationRule>) request.getAttribute("rules");
    StringBuilder rulesJson = new StringBuilder("[");
    if (rules != null) {
        for (int i = 0; i < rules.size(); i++) {
            MediationRule r = rules.get(i);
            if (i > 0) {
                rulesJson.append(",");
            }
            rulesJson.append("{")
                    .append("\"id\":").append(r.getId()).append(",")
                    .append("\"source\":\"").append(r.getSourceName()).append("\",")
                    .append("\"destination\":\"").append(r.getDestinationName()).append("\",")
                    .append("\"active\":").append(r.isActive())
                    .append("}");
        }
    }
    rulesJson.append("]");
%>
<%@ include file="layout.jsp" %>

<style>
    .flow-canvas {
        position: relative;
        width: 100%;
        height: 340px;
        margin-bottom: 1.5rem;
        background: var(--bg3);
        border-radius: 8px;
        border: 1px solid var(--border);
        overflow: hidden;
    }
    .flow-svg {
        position: absolute;
        inset: 0;
        width: 100%;
        height: 100%;
        pointer-events: none;
    }
    .node-box {
        position: absolute;
        border-radius: 8px;
        border: 1px solid var(--border);
        background: var(--bg2);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 4px;
        padding: 10px 6px;
        transition: border-color 0.25s, box-shadow 0.25s;
    }
    .node-box.active-amber {
        border-color: var(--amber);
        box-shadow: 0 0 0 3px rgba(245,158,11,0.15);
    }
    .node-box.active-green {
        border-color: var(--green);
        box-shadow: 0 0 0 3px rgba(16,185,129,0.15);
    }
    .node-box.active-cyan  {
        border-color: var(--cyan);
        box-shadow: 0 0 0 3px rgba(6,182,212,0.15);
    }
    .node-icon {
        width: 30px;
        height: 30px;
        border-radius: 6px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
    }
    .node-label  {
        font-size: 11px;
        font-weight: 700;
        color: var(--text);
        text-align: center;
        line-height: 1.3;
        letter-spacing: .03em;
        text-transform: uppercase;
    }
    .node-sub    {
        font-size: 10px;
        color: var(--text-dim);
        font-family: var(--mono);
    }
    .icon-up     {
        background: rgba(245,158,11,0.12);
        color: var(--amber);
    }
    .icon-engine {
        background: rgba(6,182,212,0.12);
        color: var(--cyan);
    }
    .icon-down   {
        background: rgba(16,185,129,0.12);
        color: var(--green);
    }
    .icon-fraud  {
        background: rgba(239,68,68,0.12);
        color: var(--red);
    }

    .node-msc     {
        top: 40px;
        left: 180px;
        width: 90px;
        height: 78px;
    }
    .node-smsc    {
        top: 125px;
        left: 180px;
        width: 90px;
        height: 78px;
    }
    .node-pgw     {
        top: 210px;
        left: 180px;
        width: 90px;
        height: 78px;
    }
    .node-engine  {
        top: 110px;
        left: 675px;
        width: 110px;
        height: 120px;
    }
    .node-billing {
        top: 50px;
        left: 1150px;
        width: 90px;
        height: 78px;
    }
    .node-fraud   {
        top: 190px;
        left: 1150px;
        width: 90px;
        height: 78px;
    }

    .packet {
        position: absolute;
        width: 11px;
        height: 11px;
        border-radius: 50%;
        pointer-events: none;
        display: none;
        z-index: 20;
    }
    .pkt-voice   {
        background: var(--amber);
        box-shadow: 0 0 6px rgba(245,158,11,0.6);
    }
    .pkt-sms     {
        background: var(--cyan);
        box-shadow: 0 0 6px rgba(6,182,212,0.6);
    }
    .pkt-data    {
        background: var(--green);
        box-shadow: 0 0 6px rgba(16,185,129,0.6);
    }
    .pkt-blocked {
        background: var(--red);
        box-shadow: 0 0 6px rgba(239,68,68,0.6);
    }

    .stats-grid  {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 12px;
        margin-bottom: 20px;
    }
    .stat-card   {
        background: var(--bg2);
        border: 1px solid var(--border);
        border-radius: 8px;
        padding: 14px 16px;
        position: relative;
        overflow: hidden;
    }
    .stat-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 2px;
    }
    .stat-card.s-voice::before  {
        background: var(--amber);
    }
    .stat-card.s-sms::before    {
        background: var(--cyan);
    }
    .stat-card.s-data::before   {
        background: var(--green);
    }
    .stat-card.s-blocked::before{
        background: var(--red);
    }
    .stat-num   {
        font-size: 32px;
        font-weight: 800;
        line-height: 1;
        margin-bottom: 4px;
    }
    .stat-card.s-voice   .stat-num {
        color: var(--amber);
    }
    .stat-card.s-sms     .stat-num {
        color: var(--cyan);
    }
    .stat-card.s-data    .stat-num {
        color: var(--green);
    }
    .stat-card.s-blocked .stat-num {
        color: var(--red);
    }
    .stat-lbl {
        font-family: var(--mono);
        font-size: 10px;
        color: var(--text-dim);
        text-transform: uppercase;
        letter-spacing: .1em;
    }

    .detail-panel {
        background: var(--bg2);
        border: 1px solid var(--border);
        border-radius: 8px;
        overflow: hidden;
    }
    .detail-top   {
        padding: 14px 20px;
        border-bottom: 1px solid var(--border);
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .detail-title {
        font-size: 12px;
        font-weight: 700;
        color: var(--text);
        letter-spacing: .05em;
        text-transform: uppercase;
    }
    .detail-body  {
        padding: 16px 20px;
    }

    .status-pill {
        font-family: var(--mono);
        font-size: 10px;
        font-weight: 700;
        padding: 3px 8px;
        border-radius: 4px;
        text-transform: uppercase;
        letter-spacing: .08em;
    }
    .pill-forwarded {
        background: rgba(16,185,129,0.12);
        color: var(--green);
        border: 1px solid rgba(16,185,129,0.25);
    }
    .pill-filtered  {
        background: rgba(239,68,68,0.12);
        color: var(--red);
        border: 1px solid rgba(239,68,68,0.25);
    }
    .pill-idle      {
        background: rgba(100,116,139,0.12);
        color: var(--text-dim);
        border: 1px solid var(--border);
    }

    .cdr-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 8px 24px;
    }
    .cdr-field {
        display: flex;
        flex-direction: column;
        gap: 1px;
    }
    .cdr-key   {
        font-family: var(--mono);
        font-size: 10px;
        color: var(--text-dim);
        letter-spacing: .04em;
    }
    .cdr-val   {
        font-family: var(--mono);
        font-size: 12px;
        font-weight: 700;
        color: var(--text);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .cdr-val.hl-blocked {
        color: var(--red);
    }
    .cdr-val.hl-zero    {
        color: var(--amber);
    }

    .filter-msg {
        margin-top: 12px;
        padding: 8px 12px;
        background: rgba(239,68,68,0.07);
        border: 1px solid rgba(239,68,68,0.2);
        border-radius: 6px;
        font-family: var(--mono);
        font-size: 11px;
        color: var(--red);
    }

    .controls-row {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 16px;
        flex-wrap: wrap;
    }
    .ctrl-btn {
        display: inline-flex;
        align-items: center;
        gap: 5px;
        padding: 6px 14px;
        border-radius: 6px;
        border: 1px solid var(--border);
        background: var(--bg2);
        color: var(--text-dim);
        font-family: var(--sans);
        font-size: 12px;
        font-weight: 700;
        letter-spacing: .04em;
        cursor: pointer;
        transition: all .15s;
    }
    .ctrl-btn:hover {
        background: var(--bg3);
        color: var(--text);
    }
    .ctrl-btn.active {
        background: var(--amber);
        border-color: var(--amber);
        color: #000;
    }
    .ctrl-btn svg {
        width: 13px;
        height: 13px;
    }

    .legend {
        display: flex;
        gap: 16px;
        flex-wrap: wrap;
        margin-bottom: 16px;
    }
    .legend-item {
        display: flex;
        align-items: center;
        gap: 5px;
        font-family: var(--mono);
        font-size: 10px;
        color: var(--text-dim);
        text-transform: uppercase;
        letter-spacing: .06em;
    }
    .legend-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        flex-shrink: 0;
    }

    .empty-cdr {
        text-align: center;
        padding: 24px;
        color: var(--text-dim);
        font-size: 13px;
    }

    @keyframes cdr-fadein {
        from {
            opacity: 0;
            transform: translateY(4px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    .cdr-fadein {
        animation: cdr-fadein 0.3s ease;
    }
</style>

<div class="page-header">
    <div class="page-header-left">
        <div class="breadcrumb"><a href="<%= ctx%>/dashboard">Dashboard</a> <span>/</span> CDR Flow</div>
        <h1>Real-Time CDR Flow</h1>
        <p>Live animation of CDR collection, filtering, and routing through the mediation pipeline</p>
    </div>
</div>

<!-- Stats -->
<div class="stats-grid">
    <div class="stat-card s-voice">
        <div class="stat-num" id="cnt-voice">0</div>
        <div class="stat-lbl">Voice CDRs</div>
    </div>
    <div class="stat-card s-sms">
        <div class="stat-num" id="cnt-sms">0</div>
        <div class="stat-lbl">SMS CDRs</div>
    </div>
    <div class="stat-card s-data">
        <div class="stat-num" id="cnt-data">0</div>
        <div class="stat-lbl">Data CDRs</div>
    </div>
    <div class="stat-card s-blocked">
        <div class="stat-num" id="cnt-blocked">0</div>
        <div class="stat-lbl">Filtered</div>
    </div>
</div>

<!-- Controls -->
<div class="controls-row">
    <button class="ctrl-btn active" id="btn-play" onclick="togglePlay()">
        <svg id="play-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
        <rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/>
        </svg>
        <span id="play-label">Pause</span>
    </button>
    <span style="font-family:var(--mono);font-size:10px;color:var(--text-muted);text-transform:uppercase;letter-spacing:.1em;">Speed</span>
    <button class="ctrl-btn" id="spd-slow" onclick="setSpeed(2500, 'spd-slow')">Slow</button>
    <button class="ctrl-btn active" id="spd-med"  onclick="setSpeed(1500, 'spd-med')">Normal</button>
    <button class="ctrl-btn" id="spd-fast" onclick="setSpeed(700, 'spd-fast')">Fast</button>
</div>

<!-- Legend -->
<div class="legend">
    <div class="legend-item"><span class="legend-dot" style="background:var(--amber)"></span>Voice (MSC)</div>
    <div class="legend-item"><span class="legend-dot" style="background:var(--cyan)"></span>SMS (SMSC)</div>
    <div class="legend-item"><span class="legend-dot" style="background:var(--green)"></span>Data (PGW)</div>
    <div class="legend-item"><span class="legend-dot" style="background:var(--red)"></span>Filtered / Blocked</div>
</div>

<!-- Flow Canvas -->
<div class="flow-canvas" id="canvas">

    <!-- Static arrow paths -->
    <svg class="flow-svg" viewBox="0 0 570 280" preserveAspectRatio="none">
    <defs>
    <marker id="farr" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="5" markerHeight="5" orient="auto-start-reverse">
        <path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
    </defs>
    <!-- Upstream → Engine -->
    <line x1="114" y1="69"  x2="228" y2="128" stroke="#1e2d45" stroke-width="1.2" marker-end="url(#farr)"/>
    <line x1="114" y1="139" x2="228" y2="140" stroke="#1e2d45" stroke-width="1.2" marker-end="url(#farr)"/>
    <line x1="114" y1="209" x2="228" y2="152" stroke="#1e2d45" stroke-width="1.2" marker-end="url(#farr)"/>

    <!-- Engine → Downstream -->
    <line x1="342" y1="118" x2="448" y2="79"  stroke="#1e2d45" stroke-width="1.2" marker-end="url(#farr)"/>
    <line x1="342" y1="162" x2="448" y2="201" stroke="#1e2d45" stroke-width="1.2" marker-end="url(#farr)"/>
    </svg>

    <!-- Upstream nodes -->
    <div class="node-box node-msc"  id="node-msc">
        <div class="node-icon icon-up">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.61 3.44 2 2 0 0 1 3.57 1.25h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.19a16 16 0 0 0 5.9 5.9l.92-.92a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 21.46 16.92Z"/></svg>
        </div>
        <div class="node-label">MSC</div>
        <div class="node-sub">voice</div>
    </div>
    <div class="node-box node-smsc" id="node-smsc">
        <div class="node-icon icon-up">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
        </div>
        <div class="node-label">SMSC</div>
        <div class="node-sub">sms</div>
    </div>
    <div class="node-box node-pgw"  id="node-pgw">
        <div class="node-icon icon-up">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><path d="M5 12.55a11 11 0 0 1 14.08 0"/><path d="M1.42 9a16 16 0 0 1 21.16 0"/><path d="M8.53 16.11a6 6 0 0 1 6.95 0"/><line x1="12" y1="20" x2="12.01" y2="20"/></svg>
        </div>
        <div class="node-label">PGW</div>
        <div class="node-sub">data</div>
    </div>

    <!-- Engine -->
    <div class="node-box node-engine" id="node-engine">
        <div class="node-icon icon-engine" style="width:36px;height:36px;font-size:16px;border-radius:8px;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="18" height="18"><rect x="4" y="4" width="16" height="16" rx="2"/><rect x="9" y="9" width="6" height="6"/><line x1="9" y1="2" x2="9" y2="4"/><line x1="15" y1="2" x2="15" y2="4"/><line x1="9" y1="20" x2="9" y2="22"/><line x1="15" y1="20" x2="15" y2="22"/><line x1="2" y1="9" x2="4" y2="9"/><line x1="2" y1="15" x2="4" y2="15"/><line x1="20" y1="9" x2="22" y2="9"/><line x1="20" y1="15" x2="22" y2="15"/></svg>
        </div>
        <div class="node-label" style="font-size:11px;">Mediation<br>Engine</div>
        <div class="node-sub">filter · route</div>
    </div>

    <!-- Downstream -->
    <div class="node-box node-billing" id="node-billing">
        <div class="node-icon icon-down">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
        </div>
        <div class="node-label">Billing</div>
        <div class="node-sub">downstream</div>
    </div>
    <div class="node-box node-fraud" id="node-fraud">
        <div class="node-icon icon-fraud">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
        </div>
        <div class="node-label">Fraud</div>
        <div class="node-sub">downstream</div>
    </div>

    <!-- Animated packet -->
    <div class="packet" id="packet"></div>
</div>

<!-- CDR Detail Panel -->
<div class="detail-panel">
    <div class="detail-top">
        <span class="detail-title">Live CDR Record</span>
        <span class="status-pill pill-idle" id="status-pill">Idle</span>
    </div>
    <div class="detail-body" id="cdr-body">
        <div class="empty-cdr">Pipeline starting — CDR details will appear here</div>
    </div>
</div>

<script>
    const BLOCKED = <%= blockedJson%>;
    const RULES = <%= rulesJson%>;

    let running = true;
    let speed = 1500;
    let stats = {voice: 0, sms: 0, data: 0, blocked: 0};
    let timer = null;

    function rand(n) {
        return Math.floor(Math.random() * n);
    }
    function randF(n) {
        return (Math.random() * n).toFixed(2);
    }
    function msisdn() {
        return 2010000000 + rand(32767);
    }
    function nowTs() {
        const d = new Date();
        return d.toISOString().replace('T', ' ').substring(0, 19);
    }

    function genVoice() {
        const recv = Math.random() < 0.12 ? BLOCKED[rand(BLOCKED.length)] : String(msisdn());
        const dur = Math.random() < 0.10 ? 0 : rand(300);
        return {type: 'voice', source: 'MSC', nodeId: 'node-msc', fields: {
                file_id: '1', caller_id: String(msisdn()), receiver_id: recv,
                start_time: nowTs(), duration: String(dur),
                service_id: String(rand(3) + 1), hplmn: '60201', vplmn: '60202',
                external_charges: randF(10), rated_flag: 'false'
            }};
    }
    function genSms() {
        const recv = Math.random() < 0.10 ? BLOCKED[rand(BLOCKED.length)] : String(msisdn());
        const len = Math.random() < 0.08 ? 0 : rand(160);
        return {type: 'sms', source: 'SMSC', nodeId: 'node-smsc', fields: {
                file_id: '2', sender_id: String(msisdn()), receiver_id: recv,
                timestamp: nowTs(), message_length: String(len),
                service_type: 'SMS', hplmn: '60201', vplmn: '60202',
                external_charges: '0.10', rated_flag: 'false'
            }};
    }
    function genData() {
        const dur = Math.random() < 0.08 ? 0 : rand(600);
        const usage = Math.random() < 0.08 ? '0.00' : randF(500);
        return {type: 'data', source: 'PGW', nodeId: 'node-pgw', fields: {
                file_id: '3', imsi: '60201' + rand(1000000000),
                session_start: nowTs(), session_duration: String(dur),
                data_usage_mb: usage, apn: 'internet',
                hplmn: '60201', vplmn: '60202',
                external_charges: randF(20), rated_flag: 'false'
            }};
    }
    function generateCdr() {
        const r = rand(3);
        return r === 0 ? genVoice() : r === 1 ? genSms() : genData();
    }

    function applyFilters(cdr) {
        const f = cdr.fields;
        if (cdr.type === 'voice' && f.duration === '0')
            return 'FIELD_EQUALS — duration = 0 (zero-duration call)';
        if (cdr.type === 'sms' && f.message_length === '0')
            return 'FIELD_EQUALS — message_length = 0 (empty message)';
        if (cdr.type === 'data' && parseFloat(f.data_usage_mb) === 0)
            return 'FIELD_EQUALS — data_usage_mb = 0 (no data used)';
        if (cdr.type === 'data' && f.session_duration === '0')
            return 'FIELD_EQUALS — session_duration = 0 (no session)';
        const recv = f.receiver_id || f.sender_id || '';
        if (BLOCKED.includes(recv))
            return 'BLOCKED_NUMBER — ' + recv + ' (emergency/short-code)';
        return null;
    }

    function nodeCenter(id) {
        const canvas = document.getElementById('canvas');
        const node = document.getElementById(id);
        const cr = canvas.getBoundingClientRect();
        const nr = node.getBoundingClientRect();
        return {x: nr.left - cr.left + nr.width / 2, y: nr.top - cr.top + nr.height / 2};
    }

    function flashNode(id, cls) {
        const el = document.getElementById(id);
        el.classList.add(cls);
        setTimeout(() => el.classList.remove(cls), 600);
    }

    function animatePacket(from, to, cls, onMid, onDone) {
        const pkt = document.getElementById('packet');
        pkt.className = 'packet ' + cls;
        pkt.style.display = 'block';
        const p0 = nodeCenter(from);
        const p1 = nodeCenter('node-engine');
        const p2 = to ? nodeCenter(to) : null;
        const leg = speed * 0.42;
        const t0 = performance.now();

        function step1(now) {
            const prog = Math.min((now - t0) / leg, 1);
            const ease = 1 - Math.pow(1 - prog, 2);
            pkt.style.left = (p0.x + (p1.x - p0.x) * ease - 5.5) + 'px';
            pkt.style.top = (p0.y + (p1.y - p0.y) * ease - 5.5) + 'px';
            if (prog < 1) {
                requestAnimationFrame(step1);
                return;
            }
            onMid && onMid();
            if (!p2) {
                setTimeout(() => {
                    pkt.style.display = 'none';
                    onDone && onDone();
                }, 250);
                return;
            }
            const t1 = performance.now();
            function step2(now2) {
                const prog2 = Math.min((now2 - t1) / leg, 1);
                const ease2 = 1 - Math.pow(1 - prog2, 2);
                pkt.style.left = (p1.x + (p2.x - p1.x) * ease2 - 5.5) + 'px';
                pkt.style.top = (p1.y + (p2.y - p1.y) * ease2 - 5.5) + 'px';
                if (prog2 < 1) {
                    requestAnimationFrame(step2);
                    return;
                }
                pkt.style.display = 'none';
                onDone && onDone();
            }
            requestAnimationFrame(step2);
        }
        requestAnimationFrame(step1);
    }

    function renderCdr(cdr, filterReason, destName) {
        const f = cdr.fields;
        const isFiltered = !!filterReason;

        const pill = document.getElementById('status-pill');
        pill.className = 'status-pill ' + (isFiltered ? 'pill-filtered' : 'pill-forwarded');
        pill.textContent = isFiltered ? 'FILTERED' : 'FORWARDED \u2192 ' + destName.toUpperCase();

        const ZERO_FIELDS = ['duration', 'data_usage_mb', 'message_length', 'session_duration'];
        const BLOCKED_FIELDS = ['receiver_id', 'sender_id'];

        const rows = Object.entries(f).map(([k, v]) => {
            let cls = '';
            if (BLOCKED_FIELDS.includes(k) && BLOCKED.includes(v))
                cls = 'hl-blocked';
            else if (ZERO_FIELDS.includes(k) && (v === '0' || v === '0.00'))
                cls = 'hl-zero';
            return '<div class="cdr-field">'
                    + '<span class="cdr-key">' + k + '</span>'
                    + '<span class="cdr-val' + (cls ? ' ' + cls : '') + '">' + v + '</span>'
                    + '</div>';
        }).join('');

        const filterHtml = isFiltered
                ? '<div class="filter-msg">&#9888; Rule matched: ' + filterReason + '</div>'
                : '';

        document.getElementById('cdr-body').innerHTML =
                '<div class="cdr-grid cdr-fadein">' + rows + '</div>' + filterHtml;
    }

    function processCdr() {
        if (!running)
            return;
        const cdr = generateCdr();
        const filterReason = applyFilters(cdr);
        const isFiltered = !!filterReason;

        // Destination: alternate billing / fraud for voice + data
        const toFraud = !isFiltered && (cdr.type === 'voice' || cdr.type === 'data') && Math.random() > 0.5;
        const destId = isFiltered ? null : (toFraud ? 'node-fraud' : 'node-billing');
        const destName = destId === 'node-fraud' ? 'Fraud' : 'Billing';

        flashNode(cdr.nodeId, 'active-amber');
        if (isFiltered)
            stats.blocked++;
        else
            stats[cdr.type]++;

        document.getElementById('cnt-voice').textContent = stats.voice;
        document.getElementById('cnt-sms').textContent = stats.sms;
        document.getElementById('cnt-data').textContent = stats.data;
        document.getElementById('cnt-blocked').textContent = stats.blocked;

        renderCdr(cdr, filterReason, destName);

        const pktCls = isFiltered ? 'pkt-blocked' : 'pkt-' + cdr.type;
        animatePacket(
                cdr.nodeId, destId, pktCls,
                () => {
            flashNode('node-engine', isFiltered ? 'active-amber' : 'active-cyan');
            if (destId)
                flashNode(destId, 'active-green');
        },
                () => {
            if (running)
                timer = setTimeout(processCdr, speed * 0.08);
        }
        );
    }

    function togglePlay() {
        running = !running;
        const btn = document.getElementById('btn-play');
        const lbl = document.getElementById('play-label');
        const icon = document.getElementById('play-icon');
        if (running) {
            btn.classList.add('active');
            lbl.textContent = 'Pause';
            icon.innerHTML = '<rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/>';
            processCdr();
        } else {
            btn.classList.remove('active');
            lbl.textContent = 'Play';
            icon.innerHTML = '<polygon points="5 3 19 12 5 21 5 3"/>';
            clearTimeout(timer);
            document.getElementById('packet').style.display = 'none';
        }
    }

    function setSpeed(s, btnId) {
        speed = s;
        ['spd-slow', 'spd-med', 'spd-fast'].forEach(id => {
            document.getElementById(id).classList.toggle('active', id === btnId);
        });
    }

    setTimeout(processCdr, 600);
</script>

<%@ include file="layout-end.jsp" %>
