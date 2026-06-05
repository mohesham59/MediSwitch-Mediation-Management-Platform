<%--
  index.jsp — Root entry point at: mediation-webapp/src/main/webapp/index.jsp
  (NOT inside WEB-INF — this file is at the webapp root)
  
  Redirects authenticated users to dashboard.
  All other visitors see the full landing/marketing page inline.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    /* Already logged in? Go straight to dashboard */
    javax.servlet.http.HttpSession sess = request.getSession(false);
    if (sess != null && sess.getAttribute("admin") != null) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>MediSwitch — Enterprise Telecom Mediation Platform</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=DM+Mono:wght@300;400;500&family=Syne:wght@700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
:root {
    --blue:         #2563eb;
    --blue-dark:    #1d4ed8;
    --blue-subtle:  rgba(37,99,235,0.06);
    --violet:       #7c3aed;
    --green:        #059669;
    --green-light:  #10b981;
    --amber:        #d97706;
    --red:          #e11d48;
    --border-soft:  rgba(15,23,42,0.07);
    --border-base:  rgba(15,23,42,0.11);
    --text-primary:  #0f172a;
    --text-muted:    #64748b;
    --text-faint:    #94a3b8;
    --font-body:    'Plus Jakarta Sans', sans-serif;
    --font-display: 'Syne', sans-serif;
    --font-mono:    'DM Mono', monospace;
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
html, body { background: #f8fafc; color: var(--text-primary); font-family: var(--font-body); -webkit-font-smoothing: antialiased; overflow-x: hidden; }
a { color: inherit; text-decoration: none; }

/* ── NAV ── */
.lp-nav {
    position: fixed; top: 0; left: 0; right: 0; z-index: 100;
    height: 60px; display: flex; align-items: center; justify-content: space-between;
    padding: 0 40px;
    background: rgba(248,250,252,0.88); backdrop-filter: blur(16px);
    border-bottom: 1px solid var(--border-soft);
    transition: box-shadow 0.3s;
}
.lp-nav.scrolled { box-shadow: 0 1px 3px rgba(15,23,42,0.08); }
.nav-logo { display: flex; align-items: center; gap: 10px; }
.nav-emblem {
    width: 32px; height: 32px;
    background: linear-gradient(135deg, var(--blue) 0%, var(--violet) 100%);
    border-radius: 7px; display: flex; align-items: center; justify-content: center;
    box-shadow: 0 2px 8px rgba(37,99,235,0.25);
}
.nav-emblem svg { width: 16px; height: 16px; fill: white; }
.nav-name { font-family: var(--font-display); font-weight: 800; font-size: 17px; color: var(--text-primary); letter-spacing: -0.01em; }
.nav-links { display: flex; align-items: center; gap: 28px; list-style: none; }
.nav-links a { font-size: 13.5px; font-weight: 500; color: var(--text-muted); transition: color 0.15s; }
.nav-links a:hover { color: var(--text-primary); }
.btn-nav-login {
    padding: 7px 18px; border-radius: 7px; background: var(--blue); color: white;
    font-size: 13.5px; font-weight: 600; border: none; cursor: pointer;
    transition: all 0.15s; box-shadow: 0 1px 4px rgba(37,99,235,0.25);
    display: inline-flex; align-items: center; gap: 6px;
}
.btn-nav-login:hover { background: var(--blue-dark); box-shadow: 0 4px 14px rgba(37,99,235,0.30); transform: translateY(-1px); }

/* ── HERO ── */
.lp-hero {
    min-height: 100vh; display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    padding: 120px 40px 80px; text-align: center; position: relative; overflow: hidden;
}
.hero-bg { position: absolute; inset: 0; pointer-events: none; z-index: 0; }
.hero-blob {
    position: absolute; border-radius: 50%; filter: blur(80px);
}
.hb1 { width:700px;height:500px; background:radial-gradient(ellipse,rgba(37,99,235,0.08) 0%,transparent 70%); top:-100px;left:-100px; animation:blob 18s ease-in-out infinite; }
.hb2 { width:600px;height:600px; background:radial-gradient(ellipse,rgba(124,58,237,0.07) 0%,transparent 70%); top:50px;right:-150px; animation:blob 22s ease-in-out infinite reverse; }
.hb3 { width:400px;height:400px; background:radial-gradient(ellipse,rgba(5,150,105,0.05) 0%,transparent 70%); bottom:0;left:30%; animation:blob 15s ease-in-out infinite 3s; }
@keyframes blob { 0%,100%{transform:translate(0,0) scale(1);} 33%{transform:translate(30px,-20px) scale(1.04);} 66%{transform:translate(-20px,30px) scale(0.97);} }
.hero-grid { position:absolute;inset:0; background-image:linear-gradient(rgba(37,99,235,0.022) 1px,transparent 1px),linear-gradient(90deg,rgba(37,99,235,0.022) 1px,transparent 1px); background-size:60px 60px; }
.hero-content { position:relative;z-index:1;max-width:820px; }
.hero-badge {
    display:inline-flex;align-items:center;gap:7px;padding:5px 14px;
    background:rgba(37,99,235,0.06);border:1px solid rgba(37,99,235,0.18);border-radius:20px;
    font-family:var(--font-mono);font-size:10.5px;font-weight:500;color:var(--blue);
    letter-spacing:.06em;text-transform:uppercase;margin-bottom:28px;
    animation:fadeUp .6s ease both;
}
.hero-badge::before { content:'';width:5px;height:5px;background:var(--green);border-radius:50%;box-shadow:0 0 8px var(--green);animation:blink 2s infinite; }
@keyframes blink { 0%,100%{opacity:1;}50%{opacity:.3;} }
.hero h1 {
    font-family:var(--font-display);font-size:clamp(38px,6vw,70px);font-weight:900;
    color:var(--text-primary);line-height:1.08;letter-spacing:-.03em;margin-bottom:24px;
    animation:fadeUp .6s .1s ease both;
}
.hero h1 .accent { background:linear-gradient(135deg,var(--blue) 0%,var(--violet) 60%); -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text; }
.hero-sub { font-size:18px;color:var(--text-muted);max-width:580px;margin:0 auto 40px;line-height:1.7;animation:fadeUp .6s .2s ease both; }
.hero-actions { display:flex;align-items:center;justify-content:center;gap:14px;margin-bottom:56px;animation:fadeUp .6s .3s ease both; }
.btn-hero-primary {
    display:inline-flex;align-items:center;gap:8px;padding:14px 32px;
    background:var(--blue);color:white;border-radius:10px;font-size:15px;font-weight:700;
    border:none;cursor:pointer;transition:all .2s;box-shadow:0 4px 16px rgba(37,99,235,.30);
}
.btn-hero-primary:hover { background:var(--blue-dark);box-shadow:0 8px 24px rgba(37,99,235,.40);transform:translateY(-2px); }
.btn-hero-secondary {
    display:inline-flex;align-items:center;gap:7px;padding:13px 24px;background:white;color:var(--text-muted);
    border-radius:10px;font-size:14.5px;font-weight:600;border:1px solid var(--border-base);
    cursor:pointer;transition:all .15s;box-shadow:0 1px 3px rgba(15,23,42,.08);
}
.btn-hero-secondary:hover { color:var(--text-primary);box-shadow:0 4px 8px rgba(15,23,42,.08);transform:translateY(-1px); }
.hero-trust { display:flex;align-items:center;justify-content:center;gap:24px;flex-wrap:wrap;animation:fadeUp .6s .4s ease both; }
.trust-item { display:flex;align-items:center;gap:7px;font-size:12.5px;color:var(--text-faint);font-weight:500; }
.trust-item i { color:var(--green);font-size:12px; }
@keyframes fadeUp { from{opacity:0;transform:translateY(16px);}to{opacity:1;transform:translateY(0);} }

/* ── PIPELINE SECTION ── */
.lp-section { padding:90px 40px;background:white;border-top:1px solid var(--border-soft);border-bottom:1px solid var(--border-soft); }
.section-eyebrow { font-family:var(--font-mono);font-size:10px;font-weight:500;color:var(--blue);letter-spacing:.16em;text-transform:uppercase;text-align:center;margin-bottom:12px;display:flex;align-items:center;justify-content:center;gap:10px; }
.section-eyebrow::before,.section-eyebrow::after { content:'';width:32px;height:1px;background:var(--blue);opacity:.3; }
.section-title { font-family:var(--font-display);font-size:clamp(26px,4vw,42px);font-weight:800;color:var(--text-primary);text-align:center;letter-spacing:-.02em;line-height:1.15;margin-bottom:12px; }
.section-sub { font-size:16px;color:var(--text-muted);text-align:center;max-width:520px;margin:0 auto 56px;line-height:1.7; }

/* Pipeline flow diagram */
.pipeline-diagram { max-width:960px;margin:0 auto; }
.pd-row { display:flex;align-items:center;justify-content:center; }
.pd-group { display:flex;flex-direction:column;gap:12px;flex-shrink:0; }
.pd-node {
    display:flex;align-items:center;gap:10px;padding:11px 16px;
    background:white;border:1px solid var(--border-soft);border-radius:10px;
    box-shadow:0 1px 3px rgba(15,23,42,.06);transition:all .2s;min-width:128px;
}
.pd-node:hover { box-shadow:0 4px 12px rgba(15,23,42,.09);transform:translateY(-2px); }
.pd-node.up    { border-left:3px solid var(--amber); }
.pd-node.down  { border-left:3px solid var(--green); }
.pd-node.fraud { border-left:3px solid var(--red); }
.pd-node.engine { border:1.5px solid rgba(37,99,235,.25);background:linear-gradient(135deg,white,rgba(239,246,255,.6));box-shadow:0 4px 20px rgba(37,99,235,.10);min-width:156px;padding:18px 20px;flex-direction:column;align-items:center;text-align:center;position:relative; }
.pd-icon { width:30px;height:30px;border-radius:7px;display:flex;align-items:center;justify-content:center;font-size:12px;flex-shrink:0; }
.pd-icon.i-amber { background:rgba(217,119,6,.08);color:var(--amber); }
.pd-icon.i-green { background:rgba(5,150,105,.07);color:var(--green); }
.pd-icon.i-red   { background:rgba(225,29,72,.06);color:var(--red); }
.pd-icon.i-blue  { background:rgba(37,99,235,.06);color:var(--blue);width:40px;height:40px;font-size:18px;border-radius:10px; }
.pd-name { font-family:var(--font-mono);font-size:11.5px;font-weight:500;text-transform:uppercase;letter-spacing:.04em;color:var(--text-primary); }
.pd-sub  { font-size:11px;color:var(--text-faint); }
.pd-connector { flex:1;display:flex;flex-direction:column;justify-content:space-around;padding:0 14px;min-width:60px;height:160px; }
.pd-line { height:1.5px;background:linear-gradient(90deg,rgba(37,99,235,.08),rgba(37,99,235,.35),rgba(37,99,235,.08));position:relative;overflow:hidden;border-radius:1px; }
.pd-line::after { content:'';position:absolute;top:0;left:-45%;width:45%;height:100%;background:linear-gradient(90deg,transparent,var(--blue),transparent);animation:flow 2.4s linear infinite; }
.pd-line:nth-child(3)::after { animation-delay:.8s; }
.pd-line:nth-child(5)::after { animation-delay:1.6s; }
@keyframes flow { from{left:-45%;}to{left:145%;} }
.pd-engine-ring { position:absolute;inset:-8px;border:1.5px solid rgba(37,99,235,.18);border-radius:14px;animation:ering 3s ease-in-out infinite; }
@keyframes ering { 0%,100%{opacity:.4;transform:scale(1);}50%{opacity:0;transform:scale(1.06);} }

/* ── FEATURES ── */
.lp-features { padding:90px 40px;background:#f8fafc; }
.features-grid { max-width:1060px;margin:0 auto;display:grid;grid-template-columns:repeat(3,1fr);gap:18px; }
.feat-card {
    background:white;border:1px solid var(--border-soft);border-radius:14px;padding:26px;
    box-shadow:0 1px 3px rgba(15,23,42,.06);transition:all .2s;position:relative;overflow:hidden;
}
.feat-card::before { content:'';position:absolute;top:0;left:0;right:0;height:3px;border-radius:14px 14px 0 0;opacity:0;transition:opacity .2s; }
.feat-card:hover { box-shadow:0 12px 32px rgba(15,23,42,.08);transform:translateY(-3px); }
.feat-card:hover::before { opacity:1; }
.fc1::before { background:linear-gradient(90deg,var(--blue),var(--violet)); }
.fc2::before { background:linear-gradient(90deg,var(--violet),#a855f7); }
.fc3::before { background:linear-gradient(90deg,var(--red),#f43f5e); }
.fc4::before { background:linear-gradient(90deg,var(--green),var(--green-light)); }
.fc5::before { background:linear-gradient(90deg,var(--amber),#f59e0b); }
.fc6::before { background:linear-gradient(90deg,#0891b2,#06b6d4); }
.feat-icon { width:44px;height:44px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:18px;margin-bottom:14px; }
.fc1 .feat-icon { background:rgba(37,99,235,.06);color:var(--blue);border:1px solid rgba(37,99,235,.15); }
.fc2 .feat-icon { background:rgba(124,58,237,.06);color:var(--violet);border:1px solid rgba(124,58,237,.15); }
.fc3 .feat-icon { background:rgba(225,29,72,.06);color:var(--red);border:1px solid rgba(225,29,72,.15); }
.fc4 .feat-icon { background:rgba(5,150,105,.06);color:var(--green);border:1px solid rgba(5,150,105,.15); }
.fc5 .feat-icon { background:rgba(217,119,6,.06);color:var(--amber);border:1px solid rgba(217,119,6,.15); }
.fc6 .feat-icon { background:rgba(8,145,178,.06);color:#0891b2;border:1px solid rgba(8,145,178,.15); }
.feat-title { font-family:var(--font-display);font-size:16px;font-weight:700;color:var(--text-primary);letter-spacing:-.01em;margin-bottom:7px;line-height:1.3; }
.feat-desc  { font-size:13.5px;color:var(--text-muted);line-height:1.65; }

/* ── STATS ── */
.lp-stats { padding:72px 40px;background:linear-gradient(135deg,#0f172a 0%,#1e1b4b 50%,#0f172a 100%);position:relative;overflow:hidden; }
.stats-grid-bg { position:absolute;inset:0;background-image:linear-gradient(rgba(255,255,255,.02) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,.02) 1px,transparent 1px);background-size:48px 48px; }
.stats-row { max-width:860px;margin:0 auto;display:grid;grid-template-columns:repeat(4,1fr);position:relative;z-index:1; }
.stat-item { text-align:center;padding:30px 16px;border-right:1px solid rgba(255,255,255,.06); }
.stat-item:last-child { border-right:none; }
.stat-num { font-family:var(--font-display);font-size:clamp(34px,5vw,54px);font-weight:900;letter-spacing:-.03em;line-height:1;margin-bottom:8px; }
.stat-num.sn-white { background:linear-gradient(135deg,white,rgba(255,255,255,.7));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text; }
.stat-num.sn-blue  { background:linear-gradient(135deg,#60a5fa,#93c5fd);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text; }
.stat-num.sn-green { background:linear-gradient(135deg,#34d399,#6ee7b7);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text; }
.stat-lbl { font-family:var(--font-mono);font-size:10.5px;color:rgba(255,255,255,.35);text-transform:uppercase;letter-spacing:.12em;font-weight:500; }

/* ── CTA ── */
.lp-cta { padding:92px 40px;background:white;text-align:center; }
.cta-box {
    max-width:620px;margin:0 auto;
    background:linear-gradient(135deg,rgba(37,99,235,.06) 0%,rgba(124,58,237,.06) 100%);
    border:1px solid rgba(37,99,235,.14);border-radius:20px;padding:52px 44px;
    box-shadow:0 24px 56px rgba(15,23,42,.09);position:relative;overflow:hidden;
}
.cta-box::before { content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,var(--blue),var(--violet)); }
.cta-title { font-family:var(--font-display);font-size:clamp(22px,4vw,36px);font-weight:800;color:var(--text-primary);letter-spacing:-.02em;margin-bottom:12px;line-height:1.2; }
.cta-desc { font-size:15px;color:var(--text-muted);margin-bottom:32px;line-height:1.65; }
.btn-cta {
    display:inline-flex;align-items:center;gap:9px;padding:14px 38px;
    background:var(--blue);color:white;border-radius:10px;font-size:16px;font-weight:700;
    border:none;cursor:pointer;transition:all .2s;box-shadow:0 4px 20px rgba(37,99,235,.30);
}
.btn-cta:hover { background:var(--blue-dark);box-shadow:0 8px 28px rgba(37,99,235,.40);transform:translateY(-2px); }

/* ── FOOTER ── */
.lp-footer {
    padding:24px 40px;background:#f8fafc;border-top:1px solid var(--border-soft);
    display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;
}
.footer-logo { display:flex;align-items:center;gap:8px;font-size:13px;color:var(--text-faint); }
.footer-logo-mark { width:22px;height:22px;background:linear-gradient(135deg,var(--blue),var(--violet));border-radius:5px;display:flex;align-items:center;justify-content:center; }
.footer-logo-mark svg { width:11px;height:11px;fill:white; }
.footer-links { display:flex;gap:20px; }
.footer-links a { font-size:12.5px;color:var(--text-faint);transition:color .15s; }
.footer-links a:hover { color:var(--text-muted); }

/* scroll animations */
.aos { opacity:0;transform:translateY(20px);transition:opacity .5s ease,transform .5s ease; }
.aos.visible { opacity:1;transform:translateY(0); }

@media(max-width:900px){ .nav-links{display:none;} .features-grid{grid-template-columns:1fr 1fr;} .stats-row{grid-template-columns:repeat(2,1fr);} }
@media(max-width:600px){ .lp-nav{padding:0 20px;} .lp-hero,.lp-section,.lp-features,.lp-stats,.lp-cta{padding:60px 20px;} .features-grid{grid-template-columns:1fr;} .pd-row{flex-direction:column;gap:10px;} .pd-connector{display:none;} }
</style>
</head>
<body>

<!-- NAV -->
<nav class="lp-nav" id="lp-nav">
    <div class="nav-logo">
        <div class="nav-emblem"><svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg></div>
        <span class="nav-name">MediSwitch</span>
    </div>
    <ul class="nav-links">
        <li><a href="#features">Features</a></li>
        <li><a href="#pipeline">Architecture</a></li>
        <li><a href="#stats">Platform</a></li>
    </ul>
    <a href="<%= ctx %>/login" class="btn-nav-login">
        <i class="fas fa-arrow-right-to-bracket"></i> Login to Platform
    </a>
</nav>

<!-- HERO -->
<section class="lp-hero">
    <div class="hero-bg">
        <div class="hero-grid"></div>
        <div class="hero-blob hb1"></div>
        <div class="hero-blob hb2"></div>
        <div class="hero-blob hb3"></div>
    </div>
    <div class="hero-content">
        <div class="hero-badge"><i class="fas fa-satellite-dish"></i> Enterprise Telecom Mediation Platform</div>
        <h1>CDR Mediation Built<br>for the <span class="accent">Modern NOC</span></h1>
        <p class="hero-sub">Process, filter, and route Call Detail Records from MSC, SMSC, and PGW nodes to billing, fraud detection, and charging systems — in real time.</p>
        <div class="hero-actions">
            <a href="<%= ctx %>/login" class="btn-hero-primary">
                <i class="fas fa-arrow-right-to-bracket"></i> Open Platform
            </a>
            <a href="#pipeline" class="btn-hero-secondary">
                <i class="fas fa-play-circle"></i> See How It Works
            </a>
        </div>
        <div class="hero-trust">
            <span class="trust-item"><i class="fas fa-check-circle"></i> Real-time CDR Processing</span>
            <span class="trust-item"><i class="fas fa-check-circle"></i> Multi-node Routing</span>
            <span class="trust-item"><i class="fas fa-check-circle"></i> Fraud Detection</span>
            <span class="trust-item"><i class="fas fa-check-circle"></i> BCrypt-Secured Access</span>
        </div>
    </div>
</section>

<!-- PIPELINE SECTION -->
<section class="lp-section" id="pipeline">
    <div class="section-eyebrow">Architecture</div>
    <h2 class="section-title">End-to-End Mediation Pipeline</h2>
    <p class="section-sub">From source network elements to downstream processing — automated, real-time CDR routing with intelligent filtering.</p>
    <div class="pipeline-diagram aos">
        <div class="pd-row">
            <div class="pd-group">
                <div class="pd-node up"><div class="pd-icon i-amber"><i class="fas fa-broadcast-tower"></i></div><div><div class="pd-name">MSC</div><div class="pd-sub">Voice CDRs</div></div></div>
                <div class="pd-node up"><div class="pd-icon i-amber"><i class="fas fa-envelope"></i></div><div><div class="pd-name">SMSC</div><div class="pd-sub">SMS CDRs</div></div></div>
                <div class="pd-node up"><div class="pd-icon i-amber"><i class="fas fa-wifi"></i></div><div><div class="pd-name">PGW</div><div class="pd-sub">Data CDRs</div></div></div>
            </div>
            <div class="pd-connector">
                <div class="pd-line"></div>
                <span style="font-family:var(--font-mono);font-size:9px;color:var(--blue);text-align:center;opacity:.6;letter-spacing:.10em;text-transform:uppercase;">SFTP Pull</span>
                <div class="pd-line"></div>
                <span style="font-family:var(--font-mono);font-size:9px;color:var(--blue);text-align:center;opacity:.6;letter-spacing:.10em;text-transform:uppercase;"></span>
                <div class="pd-line"></div>
            </div>
            <div class="pd-group">
                <div class="pd-node engine">
                    <div class="pd-engine-ring"></div>
                    <div class="pd-icon i-blue"><i class="fas fa-microchip"></i></div>
                    <div class="pd-name" style="font-size:12px;margin-top:5px;">MEDIATION</div>
                    <div class="pd-sub" style="font-size:10px;margin-top:2px;">Filter · Route · Transform</div>
                    <div style="margin-top:8px;display:flex;gap:4px;flex-wrap:wrap;justify-content:center;">
                        <span style="font-family:var(--font-mono);font-size:8px;padding:2px 6px;background:rgba(37,99,235,.06);color:var(--blue);border-radius:4px;border:1px solid rgba(37,99,235,.15);font-weight:500;">Rule Engine</span>
                        <span style="font-family:var(--font-mono);font-size:8px;padding:2px 6px;background:rgba(217,119,6,.06);color:var(--amber);border-radius:4px;border:1px solid rgba(217,119,6,.15);font-weight:500;">Validator</span>
                    </div>
                </div>
            </div>
            <div class="pd-connector">
                <div class="pd-line"></div>
                <span style="font-family:var(--font-mono);font-size:9px;color:var(--blue);text-align:center;opacity:.6;letter-spacing:.10em;text-transform:uppercase;">SFTP Push</span>
                <div class="pd-line"></div>
                <span></span>
                <div class="pd-line"></div>
            </div>
            <div class="pd-group">
                <div class="pd-node down"><div class="pd-icon i-green"><i class="fas fa-file-invoice-dollar"></i></div><div><div class="pd-name">Billing</div><div class="pd-sub">Revenue System</div></div></div>
                <div class="pd-node fraud"><div class="pd-icon i-red"><i class="fas fa-shield-alt"></i></div><div><div class="pd-name">Fraud</div><div class="pd-sub">Detection</div></div></div>
                <div class="pd-node down"><div class="pd-icon i-green"><i class="fas fa-bolt"></i></div><div><div class="pd-name">Charging</div><div class="pd-sub">Online Charging</div></div></div>
            </div>
        </div>
    </div>
</section>

<!-- FEATURES -->
<section class="lp-features" id="features">
    <div class="section-eyebrow">Capabilities</div>
    <h2 class="section-title">Everything Your NOC Needs</h2>
    <p class="section-sub">Built from the ground up for modern telecom operations centers.</p>
    <div class="features-grid">
        <div class="feat-card fc1 aos"><div class="feat-icon"><i class="fas fa-satellite-dish"></i></div><div class="feat-title">Real-time CDR Collection</div><p class="feat-desc">Automated SFTP/FTP polling from MSC, SMSC, and PGW nodes. Processes CDR files immediately upon arrival with zero manual intervention.</p></div>
        <div class="feat-card fc2 aos" style="transition-delay:.05s"><div class="feat-icon"><i class="fas fa-route"></i></div><div class="feat-title">Intelligent Rule Engine</div><p class="feat-desc">Define flexible mediation rules with field filters, regex matching, threshold checks, and blocked-number detection with full routing control.</p></div>
        <div class="feat-card fc3 aos" style="transition-delay:.10s"><div class="feat-icon"><i class="fas fa-shield-virus"></i></div><div class="feat-title">Fraud Detection</div><p class="feat-desc">Block suspicious numbers before records reach downstream systems. Dynamic blocked-number lists updated in real time without service interruption.</p></div>
        <div class="feat-card fc4 aos" style="transition-delay:.15s"><div class="feat-icon"><i class="fas fa-project-diagram"></i></div><div class="feat-title">Multi-Node Routing</div><p class="feat-desc">Route processed CDRs simultaneously to Billing, Fraud, and Charging systems. Each downstream node receives exactly the records it needs.</p></div>
        <div class="feat-card fc5 aos" style="transition-delay:.20s"><div class="feat-icon"><i class="fas fa-chart-line"></i></div><div class="feat-title">Live Flow Monitoring</div><p class="feat-desc">Visual NOC-style topology with real-time packet animation. Watch CDRs traverse your mediation pipeline live with per-type telemetry counters.</p></div>
        <div class="feat-card fc6 aos" style="transition-delay:.25s"><div class="feat-icon"><i class="fas fa-user-shield"></i></div><div class="feat-title">Enterprise Access Control</div><p class="feat-desc">BCrypt-hashed credentials, session-scoped access, and multi-operator admin management for enterprise security requirements.</p></div>
    </div>
</section>

<!-- STATS -->
<section class="lp-stats" id="stats">
    <div class="stats-grid-bg"></div>
    <div class="stats-row">
        <div class="stat-item aos"><div class="stat-num sn-blue" data-target="99.9" data-suffix="">0</div><div class="stat-lbl">Uptime SLA %</div></div>
        <div class="stat-item aos" style="transition-delay:.08s"><div class="stat-num sn-green" data-target="100" data-suffix="ms">0</div><div class="stat-lbl">Avg Process Time</div></div>
        <div class="stat-item aos" style="transition-delay:.16s"><div class="stat-num sn-white" data-target="6">0</div><div class="stat-lbl">Node Types</div></div>
        <div class="stat-item aos" style="transition-delay:.24s"><div class="stat-num sn-white" data-target="3">0</div><div class="stat-lbl">CDR Formats</div></div>
    </div>
</section>

<!-- CTA -->
<section class="lp-cta">
    <div class="cta-box aos">
        <h2 class="cta-title">Ready to Access the Platform?</h2>
        <p class="cta-desc">Sign in to your MediSwitch console to manage nodes, configure routing rules, monitor CDR flows, and control your entire mediation infrastructure.</p>
        <a href="<%= ctx %>/login" class="btn-cta">
            <i class="fas fa-arrow-right-to-bracket"></i> Login to Dashboard
        </a>
    </div>
</section>

<!-- FOOTER -->
<footer class="lp-footer">
    <div class="footer-logo">
        <div class="footer-logo-mark"><svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg></div>
        <span>MediSwitch NOC Platform · v3.0 · Enterprise Telecom Mediation</span>
    </div>
    <div class="footer-links">
        <a href="#features">Features</a>
        <a href="#pipeline">Architecture</a>
        <a href="<%= ctx %>/login">Login</a>
    </div>
</footer>

<script>
// Nav scroll
window.addEventListener('scroll', function(){
    document.getElementById('lp-nav').classList.toggle('scrolled', window.scrollY > 20);
});

// Scroll reveal
var obs = new IntersectionObserver(function(entries){
    entries.forEach(function(e){
        if (e.isIntersecting) {
            e.target.classList.add('visible');
            var num = e.target.querySelector('[data-target]');
            if (num && !num.dataset.done) { num.dataset.done='1'; animateNum(num); }
        }
    });
}, { threshold: 0.15 });
document.querySelectorAll('.aos').forEach(function(el){ obs.observe(el); });

function animateNum(el) {
    var target   = parseFloat(el.dataset.target);
    var suffix   = el.dataset.suffix || '';
    var isFloat  = target % 1 !== 0;
    var start    = performance.now();
    var duration = 1200;
    function step(ts) {
        var p   = Math.min((ts - start) / duration, 1);
        var ease= 1 - Math.pow(1 - p, 3);
        el.textContent = (isFloat ? (target*ease).toFixed(1) : Math.floor(target*ease)) + suffix;
        if (p < 1) requestAnimationFrame(step);
        else el.textContent = (isFloat ? target.toFixed(1) : target) + suffix;
    }
    requestAnimationFrame(step);
}
</script>
</body>
</html>
