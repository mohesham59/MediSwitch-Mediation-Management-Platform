<%-- WEB-INF/views/layout.jsp — included by all pages via jsp:include --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String currentPath = request.getServletPath();
    String adminUser   = (String) session.getAttribute("admin");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "Mediation System" %></title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Space+Mono:ital,wght@0,400;0,700;1,400&family=Syne:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
:root {
    --bg:        #080c14;
    --bg2:       #0d1420;
    --bg3:       #111827;
    --border:    #1e2d45;
    --border2:   #243450;
    --amber:     #f59e0b;
    --amber-dim: #92600a;
    --amber-glow:#fbbf24;
    --cyan:      #06b6d4;
    --cyan-dim:  #0e4f5c;
    --green:     #10b981;
    --green-dim: #064e3b;
    --red:       #ef4444;
    --red-dim:   #450a0a;
    --text:      #e2e8f0;
    --text-dim:  #64748b;
    --text-muted:#334155;
    --nav-w:     240px;
    --radius:    6px;
    --mono:      'Space Mono', monospace;
    --sans:      'Syne', sans-serif;
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

html, body {
    height: 100%;
    background: var(--bg);
    color: var(--text);
    font-family: var(--sans);
    font-size: 14px;
    line-height: 1.6;
}

a { color: inherit; text-decoration: none; }

/* ─── Scrollbar ─────────────────────────────────────────── */
::-webkit-scrollbar { width: 6px; height: 6px; }
::-webkit-scrollbar-track { background: var(--bg); }
::-webkit-scrollbar-thumb { background: var(--border2); border-radius: 3px; }

/* ─── Layout ─────────────────────────────────────────────── */
.app { display: flex; min-height: 100vh; }

/* ─── Sidebar ─────────────────────────────────────────────── */
.sidebar {
    width: var(--nav-w);
    background: var(--bg2);
    border-right: 1px solid var(--border);
    display: flex;
    flex-direction: column;
    position: fixed;
    top: 0; left: 0; bottom: 0;
    z-index: 100;
    overflow: hidden;
}

.sidebar-logo {
    padding: 24px 20px 20px;
    border-bottom: 1px solid var(--border);
}
.logo-mark {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 4px;
}
.logo-icon {
    width: 32px; height: 32px;
    background: var(--amber);
    border-radius: 4px;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
}
.logo-icon svg { width: 18px; height: 18px; fill: #000; }
.logo-text {
    font-family: var(--sans);
    font-weight: 800;
    font-size: 15px;
    color: var(--text);
    letter-spacing: 0.04em;
    text-transform: uppercase;
}
.logo-sub {
    font-family: var(--mono);
    font-size: 10px;
    color: var(--text-dim);
    letter-spacing: 0.1em;
    text-transform: uppercase;
    padding-left: 42px;
}

.sidebar-section {
    padding: 16px 12px 8px;
}
.sidebar-label {
    font-family: var(--mono);
    font-size: 10px;
    color: var(--text-muted);
    letter-spacing: 0.15em;
    text-transform: uppercase;
    padding: 0 8px;
    margin-bottom: 6px;
}

.nav-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 9px 12px;
    border-radius: var(--radius);
    color: var(--text-dim);
    font-size: 13px;
    font-weight: 600;
    letter-spacing: 0.02em;
    transition: all 0.15s;
    margin-bottom: 2px;
    cursor: pointer;
    border: 1px solid transparent;
}
.nav-item:hover {
    background: var(--bg3);
    color: var(--text);
    border-color: var(--border);
}
.nav-item.active {
    background: rgba(245,158,11,0.1);
    color: var(--amber);
    border-color: rgba(245,158,11,0.25);
}
.nav-item svg { width: 16px; height: 16px; flex-shrink: 0; }
.nav-item.active svg { stroke: var(--amber); }

.sidebar-bottom {
    margin-top: auto;
    padding: 16px 12px;
    border-top: 1px solid var(--border);
}
.admin-badge {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 8px 10px;
    border-radius: var(--radius);
    background: var(--bg3);
    border: 1px solid var(--border);
    margin-bottom: 10px;
}
.admin-avatar {
    width: 28px; height: 28px;
    background: var(--amber-dim);
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-family: var(--mono);
    font-size: 11px;
    font-weight: 700;
    color: var(--amber);
    flex-shrink: 0;
}
.admin-name {
    font-size: 12px;
    font-weight: 600;
    color: var(--text);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}
.admin-role {
    font-family: var(--mono);
    font-size: 10px;
    color: var(--text-dim);
}
.logout-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    width: 100%;
    padding: 8px;
    border-radius: var(--radius);
    border: 1px solid var(--border);
    background: transparent;
    color: var(--text-dim);
    font-family: var(--sans);
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.04em;
    cursor: pointer;
    transition: all 0.15s;
}
.logout-btn:hover { background: var(--red-dim); border-color: var(--red); color: var(--red); }
.logout-btn svg { width: 14px; height: 14px; }

/* ─── Main content ────────────────────────────────────────── */
.main {
    margin-left: var(--nav-w);
    flex: 1;
    display: flex;
    flex-direction: column;
    min-height: 100vh;
}

.topbar {
    height: 56px;
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 28px;
    background: var(--bg2);
    position: sticky;
    top: 0;
    z-index: 50;
}
.topbar-title {
    font-size: 15px;
    font-weight: 700;
    color: var(--text);
    letter-spacing: 0.03em;
}
.topbar-right {
    display: flex;
    align-items: center;
    gap: 12px;
}
.status-dot {
    display: flex;
    align-items: center;
    gap: 6px;
    font-family: var(--mono);
    font-size: 11px;
    color: var(--green);
}
.status-dot::before {
    content: '';
    width: 6px; height: 6px;
    background: var(--green);
    border-radius: 50%;
    box-shadow: 0 0 8px var(--green);
    animation: pulse 2s infinite;
}
@keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.4; }
}

.content { padding: 28px; flex: 1; }

/* ─── Page header ─────────────────────────────────────────── */
.page-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 28px;
    gap: 16px;
}
.page-header-left h1 {
    font-size: 22px;
    font-weight: 800;
    color: var(--text);
    letter-spacing: -0.02em;
}
.page-header-left p {
    color: var(--text-dim);
    font-size: 13px;
    margin-top: 3px;
}
.breadcrumb {
    display: flex;
    align-items: center;
    gap: 6px;
    font-family: var(--mono);
    font-size: 11px;
    color: var(--text-muted);
    margin-bottom: 6px;
    letter-spacing: 0.05em;
}
.breadcrumb a { color: var(--amber); }
.breadcrumb span { color: var(--text-muted); }

/* ─── Cards ───────────────────────────────────────────────── */
.card {
    background: var(--bg2);
    border: 1px solid var(--border);
    border-radius: 8px;
    overflow: hidden;
}
.card-header {
    padding: 16px 20px;
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.card-title {
    font-size: 13px;
    font-weight: 700;
    color: var(--text);
    letter-spacing: 0.04em;
    text-transform: uppercase;
}
.card-body { padding: 20px; }

/* ─── Stat cards ──────────────────────────────────────────── */
.stat-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 16px;
    margin-bottom: 28px;
}
.stat-card {
    background: var(--bg2);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 20px;
    position: relative;
    overflow: hidden;
    transition: border-color 0.2s;
}
.stat-card:hover { border-color: var(--border2); }
.stat-card::before {
    content: '';
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 2px;
}
.stat-card.amber::before { background: var(--amber); }
.stat-card.cyan::before  { background: var(--cyan); }
.stat-card.green::before { background: var(--green); }
.stat-card.red::before   { background: var(--red); }

.stat-label {
    font-family: var(--mono);
    font-size: 10px;
    color: var(--text-dim);
    text-transform: uppercase;
    letter-spacing: 0.12em;
    margin-bottom: 10px;
}
.stat-value {
    font-size: 36px;
    font-weight: 800;
    line-height: 1;
    color: var(--text);
    margin-bottom: 6px;
}
.stat-card.amber .stat-value { color: var(--amber); }
.stat-card.cyan  .stat-value { color: var(--cyan); }
.stat-card.green .stat-value { color: var(--green); }
.stat-card.red   .stat-value { color: var(--red); }
.stat-sub {
    font-size: 11px;
    color: var(--text-dim);
}

/* ─── Tables ──────────────────────────────────────────────── */
.table-wrap { overflow-x: auto; }
table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
}
thead th {
    font-family: var(--mono);
    font-size: 10px;
    font-weight: 700;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.1em;
    padding: 10px 16px;
    text-align: left;
    border-bottom: 1px solid var(--border);
    white-space: nowrap;
}
tbody tr {
    border-bottom: 1px solid var(--border);
    transition: background 0.1s;
}
tbody tr:last-child { border-bottom: none; }
tbody tr:hover { background: rgba(255,255,255,0.02); }
tbody td {
    padding: 12px 16px;
    color: var(--text);
    vertical-align: middle;
}
.td-mono {
    font-family: var(--mono);
    font-size: 12px;
    color: var(--text-dim);
}

/* ─── Badges ──────────────────────────────────────────────── */
.badge {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 3px 8px;
    border-radius: 4px;
    font-family: var(--mono);
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    white-space: nowrap;
}
.badge-green  { background: rgba(16,185,129,0.12); color: var(--green); border: 1px solid rgba(16,185,129,0.25); }
.badge-red    { background: rgba(239,68,68,0.12);  color: var(--red);   border: 1px solid rgba(239,68,68,0.25); }
.badge-amber  { background: rgba(245,158,11,0.12); color: var(--amber); border: 1px solid rgba(245,158,11,0.25); }
.badge-cyan   { background: rgba(6,182,212,0.12);  color: var(--cyan);  border: 1px solid rgba(6,182,212,0.25); }
.badge-gray   { background: rgba(100,116,139,0.15);color: var(--text-dim); border: 1px solid var(--border); }

/* ─── Buttons ─────────────────────────────────────────────── */
.btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    border-radius: var(--radius);
    font-family: var(--sans);
    font-size: 12px;
    font-weight: 700;
    letter-spacing: 0.05em;
    text-transform: uppercase;
    border: 1px solid transparent;
    cursor: pointer;
    transition: all 0.15s;
    white-space: nowrap;
}
.btn svg { width: 14px; height: 14px; flex-shrink: 0; }

.btn-primary {
    background: var(--amber);
    color: #000;
    border-color: var(--amber);
}
.btn-primary:hover { background: var(--amber-glow); }

.btn-outline {
    background: transparent;
    color: var(--text-dim);
    border-color: var(--border);
}
.btn-outline:hover { border-color: var(--border2); color: var(--text); background: var(--bg3); }

.btn-danger {
    background: transparent;
    color: var(--red);
    border-color: rgba(239,68,68,0.3);
}
.btn-danger:hover { background: var(--red-dim); border-color: var(--red); }

.btn-sm { padding: 5px 10px; font-size: 11px; }

.btn-icon {
    padding: 6px;
    background: transparent;
    border: 1px solid var(--border);
    border-radius: var(--radius);
    color: var(--text-dim);
    cursor: pointer;
    transition: all 0.15s;
    display: inline-flex;
    align-items: center;
    justify-content: center;
}
.btn-icon svg { width: 14px; height: 14px; }
.btn-icon:hover { background: var(--bg3); color: var(--text); border-color: var(--border2); }
.btn-icon.danger:hover { background: var(--red-dim); color: var(--red); border-color: var(--red); }
.btn-icon.success:hover { background: var(--green-dim); color: var(--green); border-color: var(--green); }

/* ─── Forms ───────────────────────────────────────────────── */
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.form-grid.cols-3 { grid-template-columns: 1fr 1fr 1fr; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-group.span-2 { grid-column: span 2; }
.form-group.span-3 { grid-column: span 3; }

label {
    font-family: var(--mono);
    font-size: 10px;
    font-weight: 700;
    color: var(--text-dim);
    text-transform: uppercase;
    letter-spacing: 0.1em;
}

input, select, textarea {
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    color: var(--text);
    font-family: var(--mono);
    font-size: 13px;
    padding: 9px 12px;
    outline: none;
    transition: border-color 0.15s, box-shadow 0.15s;
    width: 100%;
}
input:focus, select:focus, textarea:focus {
    border-color: var(--amber);
    box-shadow: 0 0 0 3px rgba(245,158,11,0.1);
}
select option { background: var(--bg2); }
textarea { resize: vertical; min-height: 80px; }

.form-hint {
    font-family: var(--mono);
    font-size: 10px;
    color: var(--text-muted);
    margin-top: 2px;
}

.toggle-wrap {
    display: flex;
    align-items: center;
    gap: 10px;
}
.toggle {
    position: relative;
    width: 36px; height: 20px;
    flex-shrink: 0;
}
.toggle input { opacity: 0; width: 0; height: 0; }
.toggle-slider {
    position: absolute;
    inset: 0;
    background: var(--border);
    border-radius: 10px;
    cursor: pointer;
    transition: 0.2s;
}
.toggle-slider::before {
    content: '';
    position: absolute;
    left: 3px; top: 3px;
    width: 14px; height: 14px;
    background: var(--text-dim);
    border-radius: 50%;
    transition: 0.2s;
}
.toggle input:checked + .toggle-slider { background: rgba(245,158,11,0.3); }
.toggle input:checked + .toggle-slider::before {
    transform: translateX(16px);
    background: var(--amber);
}
.toggle-label { font-size: 13px; color: var(--text-dim); }

/* ─── Alerts ──────────────────────────────────────────────── */
.alert {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    padding: 12px 16px;
    border-radius: var(--radius);
    font-size: 13px;
    margin-bottom: 20px;
}
.alert svg { width: 16px; height: 16px; flex-shrink: 0; margin-top: 1px; }
.alert-error   { background: var(--red-dim);   border: 1px solid rgba(239,68,68,0.3);  color: var(--red); }
.alert-success { background: var(--green-dim); border: 1px solid rgba(16,185,129,0.3); color: var(--green); }
.alert-info    { background: var(--cyan-dim);  border: 1px solid rgba(6,182,212,0.3);  color: var(--cyan); }

/* ─── Tags ────────────────────────────────────────────────── */
.tag-row { display: flex; flex-wrap: wrap; gap: 6px; }
.tag {
    padding: 3px 8px;
    border-radius: 3px;
    font-family: var(--mono);
    font-size: 11px;
    background: var(--bg3);
    border: 1px solid var(--border);
    color: var(--text-dim);
}

/* ─── Empty state ─────────────────────────────────────────── */
.empty-state {
    text-align: center;
    padding: 48px 20px;
    color: var(--text-dim);
}
.empty-state svg { width: 40px; height: 40px; margin-bottom: 12px; opacity: 0.3; }
.empty-state p { font-size: 13px; }

/* ─── Flow arrow ──────────────────────────────────────────── */
.flow {
    display: inline-flex;
    align-items: center;
    gap: 8px;
}
.flow-arrow {
    font-family: var(--mono);
    font-size: 14px;
    color: var(--amber);
}

/* ─── Divider ─────────────────────────────────────────────── */
.divider {
    border: none;
    border-top: 1px solid var(--border);
    margin: 20px 0;
}

/* ─── Utilities ───────────────────────────────────────────── */
.flex { display: flex; }
.items-center { align-items: center; }
.justify-between { justify-content: space-between; }
.gap-2 { gap: 8px; }
.gap-3 { gap: 12px; }
.mt-4 { margin-top: 16px; }
.mb-4 { margin-bottom: 16px; }
.text-dim { color: var(--text-dim); }
.text-mono { font-family: var(--mono); }
</style>
</head>
<body>
<div class="app">

<!-- SIDEBAR -->
<nav class="sidebar">
    <div class="sidebar-logo">
        <div class="logo-mark">
            <div class="logo-icon">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                </svg>
            </div>
            <span class="logo-text">MediFlow</span>
        </div>
        <div class="logo-sub">Telecom Mediation</div>
    </div>

    <div class="sidebar-section">
        <div class="sidebar-label">Navigation</div>

        <a href="<%= request.getContextPath() %>/dashboard" class="nav-item <%= currentPath.contains("dashboard") || currentPath.equals("/") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/>
                <rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/>
            </svg>
            Dashboard
        </a>

        <a href="<%= request.getContextPath() %>/nodes" class="nav-item <%= currentPath.contains("/nodes") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="3"/><path d="M12 1v4M12 19v4M4.22 4.22l2.83 2.83m9.9 9.9 2.83 2.83M1 12h4m14 0h4M4.22 19.78l2.83-2.83m9.9-9.9 2.83-2.83"/>
            </svg>
            Nodes
        </a>

        <a href="<%= request.getContextPath() %>/rules" class="nav-item <%= currentPath.contains("/rules") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M22 12h-4l-3 9L9 3l-3 9H2"/>
            </svg>
            Mediation Rules
        </a>

        <a href="<%= request.getContextPath() %>/blocked" class="nav-item <%= currentPath.contains("/blocked") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/>
            </svg>
            Blocked Numbers
        </a>

        <a href="<%= request.getContextPath() %>/admins" class="nav-item <%= currentPath.contains("/admins") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
                <path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/>
            </svg>
            Admins
        </a>

        <a href="<%= request.getContextPath() %>/flow" class="nav-item <%= currentPath.contains("/flow") ? "active" : "" %>">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
            </svg>
            CDR Flow
        </a>
    </div>

    <div class="sidebar-bottom">
        <div class="admin-badge">
            <div class="admin-avatar"><%= adminUser != null ? adminUser.substring(0,1).toUpperCase() : "A" %></div>
            <div>
                <div class="admin-name"><%= adminUser != null ? adminUser : "admin" %></div>
                <div class="admin-role">Administrator</div>
            </div>
        </div>
        <a href="<%= request.getContextPath() %>/logout">
            <button class="logout-btn">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                    <polyline points="16 17 21 12 16 7"/>
                    <line x1="21" y1="12" x2="9" y2="12"/>
                </svg>
                Sign Out
            </button>
        </a>
    </div>
</nav>

<!-- MAIN -->
<div class="main">
    <div class="topbar">
        <div class="topbar-title"><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "Dashboard" %></div>
        <div class="topbar-right">
            <div class="status-dot">SYSTEM ONLINE</div>
        </div>
    </div>
    <div class="content">
