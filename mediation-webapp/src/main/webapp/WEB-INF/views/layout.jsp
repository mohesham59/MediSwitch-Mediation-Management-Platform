<%-- WEB-INF/views/layout.jsp — MediSwitch Light Design System v3.0 --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String currentPath = request.getServletPath();
    String adminUser   = (String) session.getAttribute("admin");
    String adminInitial = (adminUser != null && !adminUser.isEmpty())
                         ? String.valueOf(adminUser.charAt(0)).toUpperCase() : "A";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") + " · MediSwitch" : "MediSwitch" %></title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=DM+Mono:wght@300;400;500&family=Syne:wght@600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
/* ════════════════════════════════════════════════════
   MEDISWITCH DESIGN SYSTEM v3.0 — LIGHT PREMIUM THEME
   Inspired by: Stripe · Linear · Vercel · Cloudflare
════════════════════════════════════════════════════ */
:root {
    /* Backgrounds */
    --bg-canvas:   #f5f7fb;
    --bg-white:    #ffffff;
    --bg-subtle:   #f8fafc;
    --bg-muted:    #f1f5f9;

    /* Borders */
    --border-soft:   rgba(15,23,42,0.06);
    --border-base:   rgba(15,23,42,0.10);
    --border-strong: rgba(15,23,42,0.16);
    --border-focus:  #2563eb;

    /* Primary — Electric Blue */
    --blue:         #2563eb;
    --blue-light:   #3b82f6;
    --blue-subtle:  rgba(37,99,235,0.06);
    --blue-muted:   rgba(37,99,235,0.12);
    --blue-border:  rgba(37,99,235,0.25);

    /* Secondary — Violet */
    --violet:        #7c3aed;
    --violet-light:  #8b5cf6;
    --violet-subtle: rgba(124,58,237,0.06);
    --violet-border: rgba(124,58,237,0.20);

    /* Success — Emerald */
    --green:        #059669;
    --green-light:  #10b981;
    --green-subtle: rgba(5,150,105,0.06);
    --green-border: rgba(5,150,105,0.20);

    /* Danger — Rose */
    --red:          #e11d48;
    --red-light:    #f43f5e;
    --red-subtle:   rgba(225,29,72,0.06);
    --red-border:   rgba(225,29,72,0.20);

    /* Warning — Amber */
    --amber:        #d97706;
    --amber-light:  #f59e0b;
    --amber-subtle: rgba(217,119,6,0.06);
    --amber-border: rgba(217,119,6,0.20);

    /* Text */
    --text-primary:   #0f172a;
    --text-secondary: #334155;
    --text-muted:     #64748b;
    --text-faint:     #94a3b8;
    --text-placeholder: #cbd5e1;

    /* Typography */
    --font-body:    'Plus Jakarta Sans', sans-serif;
    --font-display: 'Syne', sans-serif;
    --font-mono:    'DM Mono', monospace;

    /* Layout */
    --sidebar-w:    256px;
    --topbar-h:     56px;
    --radius-xs:    4px;
    --radius-sm:    6px;
    --radius:       8px;
    --radius-lg:    12px;
    --radius-xl:    16px;

    /* Shadows */
    --shadow-xs:  0 1px 2px rgba(15,23,42,0.06);
    --shadow-sm:  0 1px 3px rgba(15,23,42,0.08), 0 1px 2px rgba(15,23,42,0.04);
    --shadow-md:  0 4px 6px rgba(15,23,42,0.06), 0 2px 4px rgba(15,23,42,0.04);
    --shadow-lg:  0 10px 24px rgba(15,23,42,0.08), 0 4px 8px rgba(15,23,42,0.04);
    --shadow-xl:  0 20px 40px rgba(15,23,42,0.10), 0 8px 16px rgba(15,23,42,0.06);
}

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
html, body {
    height: 100%;
    background: var(--bg-canvas);
    color: var(--text-primary);
    font-family: var(--font-body);
    font-size: 14px;
    line-height: 1.6;
    -webkit-font-smoothing: antialiased;
}
a { color: inherit; text-decoration: none; }
button { font-family: inherit; cursor: pointer; }

::-webkit-scrollbar { width: 4px; height: 4px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--border-base); border-radius: 8px; }
::-webkit-scrollbar-thumb:hover { background: var(--border-strong); }

/* ══════════════════════════════════
   LAYOUT SHELL
══════════════════════════════════ */
.app { display: flex; min-height: 100vh; }

/* ══════════════════════════════════
   SIDEBAR
══════════════════════════════════ */
.sidebar {
    width: var(--sidebar-w);
    background: var(--bg-white);
    border-right: 1px solid var(--border-soft);
    display: flex;
    flex-direction: column;
    position: fixed;
    top: 0; left: 0; bottom: 0;
    z-index: 100;
    box-shadow: var(--shadow-sm);
}

.sidebar-logo {
    padding: 20px 18px 16px;
    border-bottom: 1px solid var(--border-soft);
}
.logo-inner {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 12px;
}
.logo-emblem {
    width: 34px; height: 34px;
    background: linear-gradient(135deg, var(--blue) 0%, var(--violet) 100%);
    border-radius: var(--radius-sm);
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    box-shadow: 0 2px 8px rgba(37,99,235,0.30);
}
.logo-emblem svg { width: 18px; height: 18px; fill: white; }
.logo-wordmark { display: flex; flex-direction: column; line-height: 1; }
.logo-name {
    font-family: var(--font-display);
    font-weight: 800;
    font-size: 16px;
    color: var(--text-primary);
    letter-spacing: -0.01em;
}
.logo-tag {
    font-family: var(--font-mono);
    font-size: 9px;
    color: var(--text-faint);
    letter-spacing: 0.08em;
    text-transform: uppercase;
    margin-top: 2px;
}

.sys-status {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 9px;
    background: var(--green-subtle);
    border: 1px solid var(--green-border);
    border-radius: 20px;
}
.sys-dot {
    width: 5px; height: 5px;
    background: var(--green);
    border-radius: 50%;
    flex-shrink: 0;
    animation: pulse-green 2.4s ease-in-out infinite;
}
@keyframes pulse-green {
    0%, 100% { opacity: 1; box-shadow: 0 0 0 0 rgba(5,150,105,0.4); }
    50% { opacity: 0.7; box-shadow: 0 0 0 4px rgba(5,150,105,0); }
}
.sys-status span {
    font-family: var(--font-mono);
    font-size: 9px;
    color: var(--green);
    letter-spacing: 0.06em;
    text-transform: uppercase;
    font-weight: 500;
}

/* Nav */
.nav-section { padding: 10px 10px 4px; }
.nav-section-label {
    font-family: var(--font-mono);
    font-size: 9px;
    color: var(--text-faint);
    letter-spacing: 0.14em;
    text-transform: uppercase;
    padding: 0 8px;
    margin-bottom: 4px;
    font-weight: 500;
}

.nav-link {
    display: flex;
    align-items: center;
    gap: 9px;
    padding: 8px 10px;
    border-radius: var(--radius-sm);
    color: var(--text-muted);
    font-size: 13.5px;
    font-weight: 500;
    transition: all 0.15s;
    margin-bottom: 1px;
    border: 1px solid transparent;
    position: relative;
    letter-spacing: -0.01em;
}
.nav-link:hover {
    background: var(--bg-subtle);
    color: var(--text-secondary);
    border-color: var(--border-soft);
}
.nav-link.active {
    background: var(--blue-subtle);
    color: var(--blue);
    border-color: var(--blue-border);
    font-weight: 600;
}
.nav-link i {
    font-size: 13px;
    width: 16px;
    text-align: center;
    flex-shrink: 0;
}
.nav-badge {
    margin-left: auto;
    font-family: var(--font-mono);
    font-size: 8px;
    font-weight: 500;
    padding: 1px 6px;
    background: var(--green-subtle);
    color: var(--green);
    border: 1px solid var(--green-border);
    border-radius: 10px;
    letter-spacing: 0.04em;
    text-transform: uppercase;
}

.sidebar-footer {
    margin-top: auto;
    padding: 12px 10px;
    border-top: 1px solid var(--border-soft);
}
.admin-card {
    display: flex;
    align-items: center;
    gap: 9px;
    padding: 9px 10px;
    background: var(--bg-subtle);
    border: 1px solid var(--border-soft);
    border-radius: var(--radius-sm);
    margin-bottom: 8px;
    transition: border-color 0.15s;
}
.admin-card:hover { border-color: var(--border-base); }
.admin-avatar {
    width: 30px; height: 30px;
    background: linear-gradient(135deg, var(--violet) 0%, var(--blue) 100%);
    border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-family: var(--font-mono);
    font-size: 11px;
    font-weight: 500;
    color: white;
    flex-shrink: 0;
}
.admin-info { flex: 1; overflow: hidden; }
.admin-name {
    font-size: 12.5px;
    font-weight: 600;
    color: var(--text-primary);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.admin-role {
    font-family: var(--font-mono);
    font-size: 9px;
    color: var(--text-faint);
    letter-spacing: 0.06em;
    text-transform: uppercase;
}
.logout-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 7px;
    width: 100%;
    padding: 8px;
    border-radius: var(--radius-sm);
    border: 1px solid var(--border-base);
    background: transparent;
    color: var(--text-muted);
    font-family: var(--font-body);
    font-size: 12px;
    font-weight: 500;
    transition: all 0.15s;
}
.logout-btn:hover {
    background: var(--red-subtle);
    border-color: var(--red-border);
    color: var(--red);
}

/* ══════════════════════════════════
   MAIN CONTENT
══════════════════════════════════ */
.main {
    margin-left: var(--sidebar-w);
    flex: 1;
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    background: var(--bg-canvas);
}

/* Topbar */
.topbar {
    height: var(--topbar-h);
    border-bottom: 1px solid var(--border-soft);
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 28px;
    background: rgba(255,255,255,0.90);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    position: sticky;
    top: 0;
    z-index: 50;
}
.topbar-breadcrumb {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 13px;
}
.topbar-breadcrumb .crumb-root {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--text-faint);
    letter-spacing: 0.08em;
    text-transform: uppercase;
}
.topbar-breadcrumb .crumb-sep { color: var(--text-placeholder); }
.topbar-page {
    font-weight: 600;
    color: var(--text-primary);
    font-size: 13.5px;
}
.topbar-right { display: flex; align-items: center; gap: 12px; }
.topbar-clock {
    font-family: var(--font-mono);
    font-size: 11px;
    color: var(--text-muted);
    letter-spacing: 0.04em;
    padding: 3px 9px;
    background: var(--bg-subtle);
    border: 1px solid var(--border-soft);
    border-radius: var(--radius-xs);
}
.topbar-status {
    display: flex;
    align-items: center;
    gap: 5px;
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--green);
    letter-spacing: 0.08em;
    text-transform: uppercase;
    padding: 3px 9px;
    background: var(--green-subtle);
    border: 1px solid var(--green-border);
    border-radius: 20px;
    font-weight: 500;
}
.topbar-status::before {
    content: '';
    width: 5px; height: 5px;
    background: var(--green);
    border-radius: 50%;
    animation: pulse-green 2s infinite;
}

/* ══════════════════════════════════
   CONTENT AREA
══════════════════════════════════ */
.content { padding: 28px 32px; flex: 1; }

/* Page header */
.page-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 28px;
    gap: 16px;
}
.page-header-left { flex: 1; }
.page-eyebrow {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--blue);
    letter-spacing: 0.12em;
    text-transform: uppercase;
    margin-bottom: 6px;
    font-weight: 500;
}
.page-header-left h1 {
    font-family: var(--font-display);
    font-size: 24px;
    font-weight: 800;
    color: var(--text-primary);
    letter-spacing: -0.02em;
    line-height: 1.2;
}
.page-header-left p {
    color: var(--text-muted);
    font-size: 13.5px;
    margin-top: 4px;
}

.breadcrumb {
    display: flex;
    align-items: center;
    gap: 5px;
    font-size: 12px;
    color: var(--text-faint);
    margin-bottom: 6px;
}
.breadcrumb a { color: var(--blue); }
.breadcrumb a:hover { color: var(--text-primary); }
.breadcrumb .sep { color: var(--text-placeholder); }

/* ══════════════════════════════════
   CARDS
══════════════════════════════════ */
.card {
    background: var(--bg-white);
    border: 1px solid var(--border-soft);
    border-radius: var(--radius-lg);
    overflow: hidden;
    box-shadow: var(--shadow-xs);
    transition: box-shadow 0.2s, border-color 0.2s;
}
.card:hover { box-shadow: var(--shadow-sm); }

.card-header {
    padding: 14px 20px;
    border-bottom: 1px solid var(--border-soft);
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: var(--bg-subtle);
}
.card-title {
    font-size: 12.5px;
    font-weight: 600;
    color: var(--text-primary);
    display: flex;
    align-items: center;
    gap: 7px;
    letter-spacing: -0.01em;
}
.card-title i { color: var(--blue); font-size: 12px; }
.card-body { padding: 20px; }

/* ══════════════════════════════════
   STAT CARDS
══════════════════════════════════ */
.stat-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 16px;
    margin-bottom: 28px;
}
.stat-card {
    background: var(--bg-white);
    border: 1px solid var(--border-soft);
    border-radius: var(--radius-lg);
    padding: 20px;
    box-shadow: var(--shadow-xs);
    transition: all 0.2s;
    position: relative;
    overflow: hidden;
}
.stat-card:hover { box-shadow: var(--shadow-md); transform: translateY(-1px); }
.stat-card::before {
    content: '';
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 3px;
    border-radius: var(--radius-lg) var(--radius-lg) 0 0;
}
.stat-card.s-blue::before   { background: linear-gradient(90deg, var(--blue), var(--violet)); }
.stat-card.s-green::before  { background: linear-gradient(90deg, var(--green), var(--green-light)); }
.stat-card.s-violet::before { background: linear-gradient(90deg, var(--violet), var(--violet-light)); }
.stat-card.s-red::before    { background: linear-gradient(90deg, var(--red), var(--red-light)); }
.stat-card.s-amber::before  { background: linear-gradient(90deg, var(--amber), var(--amber-light)); }

.stat-icon {
    width: 36px; height: 36px;
    border-radius: var(--radius-sm);
    display: flex; align-items: center; justify-content: center;
    font-size: 15px;
    margin-bottom: 12px;
}
.stat-card.s-blue .stat-icon   { background: var(--blue-subtle); color: var(--blue); border: 1px solid var(--blue-border); }
.stat-card.s-green .stat-icon  { background: var(--green-subtle); color: var(--green); border: 1px solid var(--green-border); }
.stat-card.s-violet .stat-icon { background: var(--violet-subtle); color: var(--violet); border: 1px solid var(--violet-border); }
.stat-card.s-red .stat-icon    { background: var(--red-subtle); color: var(--red); border: 1px solid var(--red-border); }
.stat-card.s-amber .stat-icon  { background: var(--amber-subtle); color: var(--amber); border: 1px solid var(--amber-border); }

.stat-label {
    font-family: var(--font-mono);
    font-size: 9.5px;
    letter-spacing: 0.10em;
    text-transform: uppercase;
    color: var(--text-faint);
    margin-bottom: 4px;
    font-weight: 500;
}
.stat-value {
    font-family: var(--font-display);
    font-size: 34px;
    font-weight: 800;
    line-height: 1;
    margin-bottom: 4px;
    letter-spacing: -0.02em;
}
.stat-card.s-blue .stat-value   { color: var(--blue); }
.stat-card.s-green .stat-value  { color: var(--green); }
.stat-card.s-violet .stat-value { color: var(--violet); }
.stat-card.s-red .stat-value    { color: var(--red); }
.stat-card.s-amber .stat-value  { color: var(--amber); }
.stat-sub {
    font-size: 11.5px;
    color: var(--text-faint);
    font-family: var(--font-mono);
}

/* ══════════════════════════════════
   TABLES
══════════════════════════════════ */
.table-wrap { overflow-x: auto; }
table { width: 100%; border-collapse: collapse; }

thead th {
    font-family: var(--font-mono);
    font-size: 9.5px;
    font-weight: 500;
    color: var(--text-faint);
    text-transform: uppercase;
    letter-spacing: 0.10em;
    padding: 10px 18px;
    text-align: left;
    border-bottom: 1px solid var(--border-soft);
    background: var(--bg-subtle);
    white-space: nowrap;
}

tbody tr {
    border-bottom: 1px solid var(--border-soft);
    transition: background 0.1s;
}
tbody tr:last-child { border-bottom: none; }
tbody tr:hover { background: var(--bg-subtle); }

tbody td {
    padding: 12px 18px;
    color: var(--text-secondary);
    vertical-align: middle;
    font-size: 13.5px;
}
.td-mono {
    font-family: var(--font-mono);
    font-size: 11.5px;
    color: var(--text-muted);
}
.td-name {
    font-weight: 600;
    color: var(--text-primary);
    font-size: 13.5px;
    letter-spacing: -0.01em;
}

/* ══════════════════════════════════
   BADGES
══════════════════════════════════ */
.badge {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 2px 8px;
    border-radius: 4px;
    font-family: var(--font-mono);
    font-size: 9.5px;
    font-weight: 500;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    white-space: nowrap;
    border: 1px solid;
}
.badge-blue   { background: var(--blue-subtle);   color: var(--blue);   border-color: var(--blue-border); }
.badge-green  { background: var(--green-subtle);  color: var(--green);  border-color: var(--green-border); }
.badge-red    { background: var(--red-subtle);    color: var(--red);    border-color: var(--red-border); }
.badge-amber  { background: var(--amber-subtle);  color: var(--amber);  border-color: var(--amber-border); }
.badge-violet { background: var(--violet-subtle); color: var(--violet); border-color: var(--violet-border); }
.badge-gray   { background: var(--bg-muted);      color: var(--text-muted); border-color: var(--border-base); }

.badge-active-pulse::before {
    content: '';
    width: 5px; height: 5px;
    background: currentColor;
    border-radius: 50%;
    animation: pulse-green 2s infinite;
}

/* ══════════════════════════════════
   BUTTONS
══════════════════════════════════ */
.btn {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    border-radius: var(--radius-sm);
    font-family: var(--font-body);
    font-size: 13px;
    font-weight: 600;
    letter-spacing: -0.01em;
    border: 1px solid transparent;
    cursor: pointer;
    transition: all 0.15s;
    white-space: nowrap;
}
.btn i { font-size: 11px; }

.btn-primary {
    background: var(--blue);
    color: white;
    border-color: var(--blue);
    box-shadow: 0 1px 2px rgba(37,99,235,0.20);
}
.btn-primary:hover {
    background: #1d4ed8;
    box-shadow: 0 4px 12px rgba(37,99,235,0.25);
    transform: translateY(-1px);
}

.btn-outline {
    background: var(--bg-white);
    color: var(--text-secondary);
    border-color: var(--border-base);
    box-shadow: var(--shadow-xs);
}
.btn-outline:hover {
    border-color: var(--border-strong);
    color: var(--text-primary);
    background: var(--bg-subtle);
}

.btn-danger {
    background: var(--bg-white);
    color: var(--red);
    border-color: var(--red-border);
}
.btn-danger:hover { background: var(--red-subtle); border-color: var(--red); }

.btn-success {
    background: var(--green-subtle);
    color: var(--green);
    border-color: var(--green-border);
}
.btn-success:hover { background: rgba(5,150,105,0.10); }

.btn-sm { padding: 5px 11px; font-size: 12px; }
.btn-xs { padding: 3px 8px; font-size: 11px; }

.btn-icon {
    width: 30px; height: 30px;
    padding: 0;
    background: var(--bg-white);
    border: 1px solid var(--border-base);
    border-radius: var(--radius-sm);
    color: var(--text-muted);
    cursor: pointer;
    transition: all 0.15s;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    box-shadow: var(--shadow-xs);
}
.btn-icon:hover { background: var(--bg-subtle); color: var(--text-primary); border-color: var(--border-strong); }
.btn-icon.danger:hover { background: var(--red-subtle); color: var(--red); border-color: var(--red-border); }
.btn-icon.success:hover { background: var(--green-subtle); color: var(--green); border-color: var(--green-border); }

/* ══════════════════════════════════
   FORMS
══════════════════════════════════ */
.form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
.form-grid.cols-3 { grid-template-columns: 1fr 1fr 1fr; }
.form-group { display: flex; flex-direction: column; gap: 6px; }
.form-group.span-2 { grid-column: span 2; }
.form-group.span-3 { grid-column: span 3; }

label {
    font-family: var(--font-mono);
    font-size: 9.5px;
    font-weight: 500;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.10em;
    display: flex;
    align-items: center;
    gap: 5px;
}

input, select, textarea {
    background: var(--bg-white);
    border: 1px solid var(--border-base);
    border-radius: var(--radius-sm);
    color: var(--text-primary);
    font-family: var(--font-body);
    font-size: 13.5px;
    padding: 9px 12px;
    outline: none;
    transition: border-color 0.15s, box-shadow 0.15s;
    width: 100%;
    box-shadow: var(--shadow-xs);
}
input::placeholder, textarea::placeholder { color: var(--text-placeholder); }
input:hover, select:hover, textarea:hover { border-color: var(--border-strong); }
input:focus, select:focus, textarea:focus {
    border-color: var(--border-focus);
    box-shadow: 0 0 0 3px rgba(37,99,235,0.08);
}
select option { background: white; color: var(--text-primary); }
textarea { resize: vertical; min-height: 90px; }

.form-hint {
    font-size: 11.5px;
    color: var(--text-faint);
}

/* Toggle */
.toggle-wrap { display: flex; align-items: center; gap: 10px; }
.toggle { position: relative; width: 36px; height: 20px; flex-shrink: 0; }
.toggle input { opacity: 0; width: 0; height: 0; }
.toggle-track {
    position: absolute;
    inset: 0;
    background: var(--bg-muted);
    border: 1px solid var(--border-base);
    border-radius: 10px;
    cursor: pointer;
    transition: 0.2s;
}
.toggle-thumb {
    position: absolute;
    left: 3px; top: 3px;
    width: 12px; height: 12px;
    background: var(--text-faint);
    border-radius: 50%;
    transition: 0.2s;
    cursor: pointer;
}
.toggle input:checked + .toggle-track { background: var(--blue-subtle); border-color: var(--blue-border); }
.toggle input:checked ~ .toggle-thumb { transform: translateX(16px); background: var(--blue); box-shadow: 0 1px 4px rgba(37,99,235,0.4); }
.toggle-label { font-size: 13px; color: var(--text-secondary); font-family: var(--font-body); }

/* ══════════════════════════════════
   ALERTS
══════════════════════════════════ */
.alert {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    padding: 12px 16px;
    border-radius: var(--radius-sm);
    font-size: 13px;
    margin-bottom: 20px;
    border: 1px solid;
    box-shadow: var(--shadow-xs);
}
.alert i { font-size: 13px; flex-shrink: 0; margin-top: 1px; }
.alert-error   { background: var(--red-subtle);    border-color: var(--red-border);    color: var(--red); }
.alert-success { background: var(--green-subtle);  border-color: var(--green-border);  color: var(--green); }
.alert-info    { background: var(--blue-subtle);   border-color: var(--blue-border);   color: var(--blue); }
.alert-warn    { background: var(--amber-subtle);  border-color: var(--amber-border);  color: var(--amber); }

/* Tags */
.tag-row { display: flex; flex-wrap: wrap; gap: 5px; }
.tag {
    padding: 2px 8px;
    border-radius: var(--radius-xs);
    font-family: var(--font-mono);
    font-size: 10.5px;
    background: var(--bg-subtle);
    border: 1px solid var(--border-soft);
    color: var(--text-muted);
}

/* Empty states */
.empty-state {
    text-align: center;
    padding: 48px 20px;
    color: var(--text-faint);
}
.empty-state i { font-size: 32px; margin-bottom: 12px; display: block; color: var(--text-placeholder); }
.empty-state .empty-title {
    font-family: var(--font-display);
    font-size: 15px;
    font-weight: 700;
    color: var(--text-muted);
    margin-bottom: 6px;
    letter-spacing: -0.01em;
}
.empty-state p { font-size: 13px; color: var(--text-faint); }

/* Divider */
.divider { border: none; border-top: 1px solid var(--border-soft); margin: 20px 0; }

/* ══════════════════════════════════
   UTILITIES
══════════════════════════════════ */
.flex { display: flex; }
.flex-col { flex-direction: column; }
.items-center { align-items: center; }
.items-start { align-items: flex-start; }
.justify-between { justify-content: space-between; }
.justify-center { justify-content: center; }
.gap-2 { gap: 8px; }
.gap-3 { gap: 12px; }
.gap-4 { gap: 16px; }
.mt-2 { margin-top: 8px; }
.mt-3 { margin-top: 12px; }
.mt-4 { margin-top: 16px; }
.mb-2 { margin-bottom: 8px; }
.mb-4 { margin-bottom: 16px; }
.mb-6 { margin-bottom: 24px; }
.w-full { width: 100%; }
.text-muted { color: var(--text-muted); }
.text-primary { color: var(--text-primary); }
.text-blue { color: var(--blue); }
.text-green { color: var(--green); }
.text-red { color: var(--red); }
.text-amber { color: var(--amber); }
.font-mono { font-family: var(--font-mono); }

/* Entry animations */
@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(10px); }
    to   { opacity: 1; transform: translateY(0); }
}
.fade-in   { animation: fadeInUp 0.28s ease forwards; }
.fade-in-2 { animation: fadeInUp 0.28s 0.05s ease forwards; opacity: 0; }
.fade-in-3 { animation: fadeInUp 0.28s 0.10s ease forwards; opacity: 0; }
.fade-in-4 { animation: fadeInUp 0.28s 0.15s ease forwards; opacity: 0; }
.fade-in-5 { animation: fadeInUp 0.28s 0.20s ease forwards; opacity: 0; }

/* Responsive */
@media (max-width: 1024px) {
    .sidebar { width: 56px; }
    .logo-wordmark, .nav-link span, .nav-section-label, .admin-info, .sys-status { display: none; }
    .logo-emblem { margin: 0 auto; }
    .nav-link { justify-content: center; padding: 10px; }
    .main { margin-left: 56px; }
    .admin-card { justify-content: center; }
}
@media (max-width: 768px) {
    .content { padding: 16px; }
    .stat-grid { grid-template-columns: repeat(2, 1fr); }
    .form-grid { grid-template-columns: 1fr; }
    .form-group.span-2 { grid-column: span 1; }
}
</style>
</head>
<body>
<div class="app">

<!-- ═══ SIDEBAR ═══ -->
<nav class="sidebar">
    <div class="sidebar-logo">
        <div class="logo-inner">
            <div class="logo-emblem">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                </svg>
            </div>
            <div class="logo-wordmark">
                <span class="logo-name">MediSwitch</span>
                <span class="logo-tag">NOC Platform</span>
            </div>
        </div>
        <div class="sys-status">
            <span class="sys-dot"></span>
            <span>All Systems Online</span>
        </div>
    </div>

    <div class="nav-section">
        <div class="nav-section-label">Monitor</div>
        <a href="<%= request.getContextPath() %>/dashboard"
           class="nav-link <%= currentPath.contains("dashboard") || currentPath.equals("/") ? "active" : "" %>">
            <i class="fas fa-home"></i>
            <span>Dashboard</span>
        </a>
        <a href="<%= request.getContextPath() %>/flow"
           class="nav-link <%= currentPath.contains("/flow") ? "active" : "" %>">
            <i class="fas fa-stream"></i>
            <span>CDR Flow</span>
            <span class="nav-badge">Live</span>
        </a>
    </div>

    <div class="nav-section">
        <div class="nav-section-label">Configure</div>
        <a href="<%= request.getContextPath() %>/nodes"
           class="nav-link <%= currentPath.contains("/nodes") ? "active" : "" %>">
            <i class="fas fa-server"></i>
            <span>Network Nodes</span>
        </a>
        <a href="<%= request.getContextPath() %>/rules"
           class="nav-link <%= currentPath.contains("/rules") ? "active" : "" %>">
            <i class="fas fa-route"></i>
            <span>Mediation Rules</span>
        </a>
        <a href="<%= request.getContextPath() %>/blocked"
           class="nav-link <%= currentPath.contains("/blocked") ? "active" : "" %>">
            <i class="fas fa-ban"></i>
            <span>Blocked Numbers</span>
        </a>
    </div>

    <div class="nav-section">
        <div class="nav-section-label">Admin</div>
        <a href="<%= request.getContextPath() %>/admins"
           class="nav-link <%= currentPath.contains("/admins") ? "active" : "" %>">
            <i class="fas fa-user-shield"></i>
            <span>Admin Users</span>
        </a>
    </div>

    <div class="sidebar-footer">
        <div class="admin-card">
            <div class="admin-avatar"><%= adminInitial %></div>
            <div class="admin-info">
                <div class="admin-name"><%= adminUser != null ? adminUser : "admin" %></div>
                <div class="admin-role">Administrator</div>
            </div>
        </div>
        <a href="<%= request.getContextPath() %>/logout">
            <button class="logout-btn">
                <i class="fas fa-sign-out-alt"></i>
                <span>Sign Out</span>
            </button>
        </a>
    </div>
</nav>

<!-- ═══ MAIN ═══ -->
<div class="main">
    <div class="topbar">
        <div class="topbar-breadcrumb">
            <span class="crumb-root">MediSwitch</span>
            <span class="crumb-sep">›</span>
            <span class="topbar-page"><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "Dashboard" %></span>
        </div>
        <div class="topbar-right">
            <div class="topbar-clock" id="tbar-clock">--:--:--</div>
            <div class="topbar-status">Online</div>
        </div>
    </div>
    <div class="content">
