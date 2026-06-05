<%@ page contentType="text/html;charset=UTF-8" %>
<%--
  login.jsp — WEB-INF/views/login.jsp
  
  This is the ONLY unauthenticated URL (/login) so it serves DUAL purpose:
    1. Full landing/marketing page (default view)
    2. Sign-in form (shown via #signin hash or when error/redirect occurs)
  
  The page shows the landing by default. The login card slides in when the
  user clicks "Login to Platform" or when there's an auth error/username redirect.
--%>
<%
    String ctx         = request.getContextPath();
    Object errorAttr   = request.getAttribute("error");
    Object usernameAttr= request.getAttribute("username");
    /* If there's an error or a pre-filled username, open the login panel immediately */
    boolean openLogin  = (errorAttr != null || usernameAttr != null);
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
/* ══════════════════════════════════════════════
   MEDISWITCH — LANDING + LOGIN  (light theme)
══════════════════════════════════════════════ */
:root {
    --blue:        #2563eb;
    --blue-dark:   #1d4ed8;
    --blue-subtle: rgba(37,99,235,0.06);
    --blue-border: rgba(37,99,235,0.20);
    --violet:      #7c3aed;
    --green:       #059669;
    --green-light: #10b981;
    --amber:       #d97706;
    --red:         #e11d48;
    --red-subtle:  rgba(225,29,72,0.06);
    --red-border:  rgba(225,29,72,0.20);
    --border-soft: rgba(15,23,42,0.07);
    --border-base: rgba(15,23,42,0.11);
    --text-primary:  #0f172a;
    --text-muted:    #64748b;
    --text-faint:    #94a3b8;
    --font-body:    'Plus Jakarta Sans', sans-serif;
    --font-display: 'Syne', sans-serif;
    --font-mono:    'DM Mono', monospace;
}
*, *::before, *::after { box-sizing:border-box; margin:0; padding:0; }
html { scroll-behavior:smooth; }
html, body {
    background:#f8fafc; color:var(--text-primary);
    font-family:var(--font-body); -webkit-font-smoothing:antialiased; overflow-x:hidden;
}
a { color:inherit; text-decoration:none; }

/* ── NAV ── */
.lp-nav {
    position:fixed; top:0; left:0; right:0; z-index:200;
    height:60px; display:flex; align-items:center; justify-content:space-between;
    padding:0 40px;
    background:rgba(248,250,252,0.90); backdrop-filter:blur(16px);
    border-bottom:1px solid var(--border-soft);
}
.lp-nav.scrolled { box-shadow:0 1px 4px rgba(15,23,42,.08); }
.nav-logo { display:flex; align-items:center; gap:10px; }
.nav-emblem {
    width:32px; height:32px;
    background:linear-gradient(135deg,var(--blue) 0%,var(--violet) 100%);
    border-radius:7px; display:flex; align-items:center; justify-content:center;
    box-shadow:0 2px 8px rgba(37,99,235,0.25); flex-shrink:0;
}
.nav-emblem svg { width:16px; height:16px; fill:white; }
.nav-name { font-family:var(--font-display); font-weight:800; font-size:17px; color:var(--text-primary); letter-spacing:-.01em; }
.nav-links { display:flex; align-items:center; gap:26px; list-style:none; }
.nav-links a { font-size:13.5px; font-weight:500; color:var(--text-muted); transition:color .15s; }
.nav-links a:hover { color:var(--text-primary); }
.btn-nav-login {
    padding:7px 18px; border-radius:7px; background:var(--blue); color:white;
    font-size:13.5px; font-weight:600; border:none; cursor:pointer;
    transition:all .15s; box-shadow:0 1px 4px rgba(37,99,235,.25);
    display:inline-flex; align-items:center; gap:6px;
}
.btn-nav-login:hover { background:var(--blue-dark); box-shadow:0 4px 14px rgba(37,99,235,.30); transform:translateY(-1px); }

/* ── LOGIN OVERLAY ── */
.login-overlay {
    position:fixed; inset:0; z-index:300;
    background:rgba(15,23,42,0.55); backdrop-filter:blur(6px);
    display:flex; align-items:center; justify-content:center;
    padding:20px;
    opacity:0; pointer-events:none;
    transition:opacity .25s ease;
}
.login-overlay.open { opacity:1; pointer-events:all; }

.login-card {
    width:100%; max-width:420px;
    background:white; border:1px solid var(--border-soft);
    border-radius:16px;
    box-shadow:0 24px 64px rgba(15,23,42,.18);
    overflow:hidden;
    transform:translateY(16px) scale(0.97);
    transition:transform .28s cubic-bezier(.16,1,.3,1);
}
.login-overlay.open .login-card { transform:translateY(0) scale(1); }

.card-accent { height:3px; background:linear-gradient(90deg,var(--blue) 0%,var(--violet) 100%); }

.card-body { padding:32px 32px 28px; }
.card-footer {
    padding:12px 32px 18px;
    border-top:1px solid var(--border-soft);
    background:#fafafa;
    display:flex; align-items:center; justify-content:space-between;
}

/* Card top: logo + close */
.card-topbar { display:flex; align-items:center; justify-content:space-between; margin-bottom:24px; }
.card-logo   { display:flex; align-items:center; gap:9px; }
.logo-mark {
    width:34px; height:34px;
    background:linear-gradient(135deg,var(--blue) 0%,var(--violet) 100%);
    border-radius:7px; display:flex; align-items:center; justify-content:center;
    box-shadow:0 2px 8px rgba(37,99,235,.28); flex-shrink:0;
}
.logo-mark svg { width:17px; height:17px; fill:white; }
.logo-name { font-family:var(--font-display); font-size:15px; font-weight:800; color:var(--text-primary); letter-spacing:-.01em; }
.logo-sub  { font-family:var(--font-mono); font-size:8.5px; color:var(--text-faint); letter-spacing:.10em; text-transform:uppercase; }
.close-btn {
    width:28px; height:28px; border-radius:6px; border:1px solid var(--border-base);
    background:white; color:var(--text-muted); cursor:pointer;
    display:flex; align-items:center; justify-content:center; font-size:12px;
    transition:all .15s;
}
.close-btn:hover { background:var(--red-subtle); border-color:var(--red-border); color:var(--red); }

/* Heading */
.card-heading h2 {
    font-family:var(--font-display); font-size:21px; font-weight:800;
    color:var(--text-primary); letter-spacing:-.02em; line-height:1.2; margin-bottom:4px;
}
.card-heading p { font-size:13.5px; color:var(--text-muted); margin-bottom:20px; }

/* Error */
.login-error {
    display:flex; align-items:flex-start; gap:8px;
    padding:10px 13px; background:var(--red-subtle);
    border:1px solid var(--red-border); border-radius:7px;
    color:var(--red); font-size:13px; margin-bottom:16px;
}
.login-error i { flex-shrink:0; margin-top:1px; }
.login-error .close-err { margin-left:auto; cursor:pointer; opacity:.6; font-size:10px; }
.login-error .close-err:hover { opacity:1; }

/* Form fields */
.field-group { display:flex; flex-direction:column; gap:5px; margin-bottom:14px; }
.field-label { font-family:var(--font-mono); font-size:9.5px; font-weight:500; color:var(--text-muted); text-transform:uppercase; letter-spacing:.12em; }
.field-wrap  { position:relative; }
.field-icon  { position:absolute; left:12px; top:50%; transform:translateY(-50%); font-size:12px; color:var(--text-faint); pointer-events:none; transition:color .15s; }
.field-input {
    width:100%; background:#f8fafc; border:1px solid var(--border-base);
    border-radius:7px; color:var(--text-primary);
    font-family:var(--font-body); font-size:14px;
    padding:11px 14px 11px 36px; outline:none; transition:all .15s;
    box-shadow:0 1px 2px rgba(15,23,42,.04);
}
.field-input::placeholder { color:rgba(148,163,184,.7); }
.field-input:hover  { border-color:var(--border-base); background:white; }
.field-input:focus  { border-color:var(--blue); background:white; box-shadow:0 0 0 3px rgba(37,99,235,.08); }
.field-wrap:focus-within .field-icon { color:var(--blue); }
.pwd-toggle {
    position:absolute; right:11px; top:50%; transform:translateY(-50%);
    background:none; border:none; cursor:pointer; color:var(--text-faint);
    font-size:12px; padding:3px; transition:color .15s;
}
.pwd-toggle:hover { color:var(--text-muted); }

/* Submit */
.btn-submit {
    width:100%; padding:11px 20px; background:var(--blue); color:white;
    border:none; border-radius:7px; font-family:var(--font-display);
    font-size:14px; font-weight:700; cursor:pointer; transition:all .15s;
    box-shadow:0 2px 8px rgba(37,99,235,.22);
    display:flex; align-items:center; justify-content:center; gap:7px;
    margin-top:4px;
}
.btn-submit:hover { background:var(--blue-dark); box-shadow:0 4px 16px rgba(37,99,235,.30); transform:translateY(-1px); }
.btn-submit .spinner { display:none; align-items:center; gap:6px; }
.btn-submit.loading .btn-txt { display:none; }
.btn-submit.loading .spinner { display:flex; }

/* Security strip */
.security-strip {
    display:flex; align-items:center; justify-content:center; gap:6px;
    padding:8px 12px; background:rgba(5,150,105,.06);
    border:1px solid rgba(5,150,105,.18); border-radius:6px; margin-top:12px;
}
.security-strip i { color:var(--green); font-size:11px; }
.security-strip span { font-family:var(--font-mono); font-size:9px; color:var(--green); letter-spacing:.05em; }
.security-strip .sep { color:rgba(5,150,105,.35); }

.status-dot { width:5px; height:5px; background:var(--green); border-radius:50%; animation:sdot 2.4s ease-in-out infinite; box-shadow:0 0 5px rgba(5,150,105,.5); }
.footer-status { display:flex; align-items:center; gap:5px; }
.footer-status span, .footer-ver span { font-family:var(--font-mono); font-size:9px; color:var(--text-faint); letter-spacing:.06em; text-transform:uppercase; }
.footer-status span { color:var(--green); font-weight:500; }
@keyframes sdot { 0%,100%{opacity:1;}50%{opacity:.3;} }

/* ── HERO ── */
.lp-hero {
    min-height:100vh; display:flex; flex-direction:column;
    align-items:center; justify-content:center;
    padding:120px 40px 80px; text-align:center;
    position:relative; overflow:hidden;
}
.hero-bg { position:absolute; inset:0; pointer-events:none; z-index:0; }
.hblob {
    position:absolute; border-radius:50%; filter:blur(80px);
}
.hb1{width:700px;height:500px;background:radial-gradient(ellipse,rgba(37,99,235,.08) 0%,transparent 70%);top:-100px;left:-100px;animation:blob 18s ease-in-out infinite;}
.hb2{width:600px;height:600px;background:radial-gradient(ellipse,rgba(124,58,237,.07) 0%,transparent 70%);top:50px;right:-150px;animation:blob 22s ease-in-out infinite reverse;}
.hb3{width:400px;height:400px;background:radial-gradient(ellipse,rgba(5,150,105,.05) 0%,transparent 70%);bottom:0;left:30%;animation:blob 15s ease-in-out infinite 3s;}
@keyframes blob{0%,100%{transform:translate(0,0) scale(1);}33%{transform:translate(30px,-20px) scale(1.04);}66%{transform:translate(-20px,30px) scale(.97);}}
.hero-grid{position:absolute;inset:0;background-image:linear-gradient(rgba(37,99,235,.022) 1px,transparent 1px),linear-gradient(90deg,rgba(37,99,235,.022) 1px,transparent 1px);background-size:60px 60px;}

.hero-content { position:relative; z-index:1; max-width:820px; }
.hero-badge {
    display:inline-flex; align-items:center; gap:7px; padding:5px 14px;
    background:rgba(37,99,235,.06); border:1px solid rgba(37,99,235,.18); border-radius:20px;
    font-family:var(--font-mono); font-size:10.5px; font-weight:500; color:var(--blue);
    letter-spacing:.06em; text-transform:uppercase; margin-bottom:28px;
    animation:fadeUp .6s ease both;
}
.hero-badge::before{content:'';width:5px;height:5px;background:var(--green);border-radius:50%;box-shadow:0 0 8px var(--green);animation:blink 2s infinite;}
@keyframes blink{0%,100%{opacity:1;}50%{opacity:.3;}}
.hero h1 {
    font-family:var(--font-display);font-size:clamp(36px,6vw,68px);font-weight:900;
    color:var(--text-primary);line-height:1.08;letter-spacing:-.03em;margin-bottom:24px;
    animation:fadeUp .6s .1s ease both;
}
.hero h1 .accent{background:linear-gradient(135deg,var(--blue) 0%,var(--violet) 60%);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}
.hero-sub{font-size:17px;color:var(--text-muted);max-width:560px;margin:0 auto 38px;line-height:1.7;animation:fadeUp .6s .2s ease both;}
.hero-actions{display:flex;align-items:center;justify-content:center;gap:14px;margin-bottom:48px;animation:fadeUp .6s .3s ease both;}
.btn-hp{display:inline-flex;align-items:center;gap:8px;padding:13px 30px;background:var(--blue);color:white;border-radius:10px;font-size:15px;font-weight:700;border:none;cursor:pointer;transition:all .2s;box-shadow:0 4px 16px rgba(37,99,235,.30);}
.btn-hp:hover{background:var(--blue-dark);box-shadow:0 8px 24px rgba(37,99,235,.40);transform:translateY(-2px);}
.btn-hs{display:inline-flex;align-items:center;gap:7px;padding:12px 22px;background:white;color:var(--text-muted);border-radius:10px;font-size:14px;font-weight:600;border:1px solid var(--border-base);cursor:pointer;transition:all .15s;box-shadow:0 1px 3px rgba(15,23,42,.07);}
.btn-hs:hover{color:var(--text-primary);box-shadow:0 4px 8px rgba(15,23,42,.08);transform:translateY(-1px);}
.hero-trust{display:flex;align-items:center;justify-content:center;gap:22px;flex-wrap:wrap;animation:fadeUp .6s .4s ease both;}
.trust-item{display:flex;align-items:center;gap:6px;font-size:12.5px;color:var(--text-faint);font-weight:500;}
.trust-item i{color:var(--green);font-size:12px;}
@keyframes fadeUp{from{opacity:0;transform:translateY(16px);}to{opacity:1;transform:translateY(0);}}

/* ── PIPELINE ── */
.lp-section{padding:80px 40px;background:white;border-top:1px solid var(--border-soft);border-bottom:1px solid var(--border-soft);}
.sec-eye{font-family:var(--font-mono);font-size:10px;font-weight:500;color:var(--blue);letter-spacing:.16em;text-transform:uppercase;text-align:center;margin-bottom:10px;display:flex;align-items:center;justify-content:center;gap:10px;}
.sec-eye::before,.sec-eye::after{content:'';width:28px;height:1px;background:var(--blue);opacity:.3;}
.sec-title{font-family:var(--font-display);font-size:clamp(24px,4vw,40px);font-weight:800;color:var(--text-primary);text-align:center;letter-spacing:-.02em;line-height:1.15;margin-bottom:10px;}
.sec-sub{font-size:15.5px;color:var(--text-muted);text-align:center;max-width:500px;margin:0 auto 50px;line-height:1.7;}
.pd-row{display:flex;align-items:center;justify-content:center;max-width:940px;margin:0 auto;}
.pd-col{display:flex;flex-direction:column;gap:11px;flex-shrink:0;}
.pd-node{display:flex;align-items:center;gap:10px;padding:10px 15px;background:white;border:1px solid var(--border-soft);border-radius:10px;box-shadow:0 1px 3px rgba(15,23,42,.06);transition:all .2s;min-width:125px;cursor:default;}
.pd-node:hover{box-shadow:0 4px 12px rgba(15,23,42,.09);transform:translateY(-2px);}
.pd-node.up   {border-left:3px solid var(--amber);}
.pd-node.dn   {border-left:3px solid var(--green);}
.pd-node.fraud{border-left:3px solid var(--red);}
.pd-node.eng  {border:1.5px solid rgba(37,99,235,.25);background:linear-gradient(135deg,white,rgba(239,246,255,.6));box-shadow:0 4px 20px rgba(37,99,235,.10);min-width:152px;padding:16px 18px;flex-direction:column;align-items:center;text-align:center;position:relative;}
.pd-ico{width:29px;height:29px;border-radius:6px;display:flex;align-items:center;justify-content:center;font-size:12px;flex-shrink:0;}
.ico-a{background:rgba(217,119,6,.08);color:var(--amber);}
.ico-g{background:rgba(5,150,105,.07);color:var(--green);}
.ico-r{background:rgba(225,29,72,.07);color:var(--red);}
.ico-b{background:rgba(37,99,235,.07);color:var(--blue);width:38px;height:38px;font-size:17px;border-radius:9px;}
.pd-name{font-family:var(--font-mono);font-size:11px;font-weight:500;text-transform:uppercase;letter-spacing:.04em;color:var(--text-primary);}
.pd-sub{font-size:11px;color:var(--text-faint);}
.pd-conn{flex:1;display:flex;flex-direction:column;justify-content:space-around;padding:0 12px;min-width:55px;height:155px;}
.pd-line{height:1.5px;background:linear-gradient(90deg,rgba(37,99,235,.08),rgba(37,99,235,.35),rgba(37,99,235,.08));position:relative;overflow:hidden;border-radius:1px;}
.pd-line::after{content:'';position:absolute;top:0;left:-45%;width:45%;height:100%;background:linear-gradient(90deg,transparent,var(--blue),transparent);animation:flow 2.4s linear infinite;}
.pd-line:nth-child(3)::after{animation-delay:.8s;}
.pd-line:nth-child(5)::after{animation-delay:1.6s;}
@keyframes flow{from{left:-45%;}to{left:145%;}}
.pd-ering{position:absolute;inset:-8px;border:1.5px solid rgba(37,99,235,.18);border-radius:14px;animation:ering 3s ease-in-out infinite;}
@keyframes ering{0%,100%{opacity:.4;transform:scale(1);}50%{opacity:0;transform:scale(1.06);}}

/* ── FEATURES ── */
.lp-feat{padding:80px 40px;background:#f8fafc;}
.feat-grid{max-width:1040px;margin:0 auto;display:grid;grid-template-columns:repeat(3,1fr);gap:16px;}
.fc{background:white;border:1px solid var(--border-soft);border-radius:13px;padding:24px;box-shadow:0 1px 3px rgba(15,23,42,.06);transition:all .2s;position:relative;overflow:hidden;}
.fc::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;border-radius:13px 13px 0 0;opacity:0;transition:opacity .2s;}
.fc:hover{box-shadow:0 12px 28px rgba(15,23,42,.08);transform:translateY(-3px);}
.fc:hover::before{opacity:1;}
.fc1::before{background:linear-gradient(90deg,var(--blue),var(--violet));}
.fc2::before{background:linear-gradient(90deg,var(--violet),#a855f7);}
.fc3::before{background:linear-gradient(90deg,var(--red),#f43f5e);}
.fc4::before{background:linear-gradient(90deg,var(--green),var(--green-light));}
.fc5::before{background:linear-gradient(90deg,var(--amber),#f59e0b);}
.fc6::before{background:linear-gradient(90deg,#0891b2,#06b6d4);}
.fc-icon{width:42px;height:42px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:17px;margin-bottom:13px;}
.fc1 .fc-icon{background:rgba(37,99,235,.06);color:var(--blue);border:1px solid rgba(37,99,235,.14);}
.fc2 .fc-icon{background:rgba(124,58,237,.06);color:var(--violet);border:1px solid rgba(124,58,237,.14);}
.fc3 .fc-icon{background:rgba(225,29,72,.06);color:var(--red);border:1px solid rgba(225,29,72,.14);}
.fc4 .fc-icon{background:rgba(5,150,105,.06);color:var(--green);border:1px solid rgba(5,150,105,.14);}
.fc5 .fc-icon{background:rgba(217,119,6,.06);color:var(--amber);border:1px solid rgba(217,119,6,.14);}
.fc6 .fc-icon{background:rgba(8,145,178,.06);color:#0891b2;border:1px solid rgba(8,145,178,.14);}
.fc-title{font-family:var(--font-display);font-size:15.5px;font-weight:700;color:var(--text-primary);letter-spacing:-.01em;margin-bottom:7px;line-height:1.3;}
.fc-desc{font-size:13px;color:var(--text-muted);line-height:1.65;}

/* ── STATS ── */
.lp-stats{padding:64px 40px;background:linear-gradient(135deg,#0f172a 0%,#1e1b4b 50%,#0f172a 100%);position:relative;overflow:hidden;}
.stats-bg{position:absolute;inset:0;background-image:linear-gradient(rgba(255,255,255,.02) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,.02) 1px,transparent 1px);background-size:48px 48px;}
.stats-row{max-width:840px;margin:0 auto;display:grid;grid-template-columns:repeat(4,1fr);position:relative;z-index:1;}
.stat-item{text-align:center;padding:28px 14px;border-right:1px solid rgba(255,255,255,.06);}
.stat-item:last-child{border-right:none;}
.stat-num{font-family:var(--font-display);font-size:clamp(32px,5vw,52px);font-weight:900;letter-spacing:-.03em;line-height:1;margin-bottom:7px;}
.sn-w{background:linear-gradient(135deg,white,rgba(255,255,255,.7));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}
.sn-b{background:linear-gradient(135deg,#60a5fa,#93c5fd);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}
.sn-g{background:linear-gradient(135deg,#34d399,#6ee7b7);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;}
.stat-lbl{font-family:var(--font-mono);font-size:10px;color:rgba(255,255,255,.35);text-transform:uppercase;letter-spacing:.12em;font-weight:500;}

/* ── CTA ── */
.lp-cta{padding:80px 40px;background:white;text-align:center;}
.cta-box{max-width:600px;margin:0 auto;background:linear-gradient(135deg,rgba(37,99,235,.06) 0%,rgba(124,58,237,.06) 100%);border:1px solid rgba(37,99,235,.14);border-radius:18px;padding:48px 40px;box-shadow:0 20px 50px rgba(15,23,42,.09);position:relative;overflow:hidden;}
.cta-box::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,var(--blue),var(--violet));}
.cta-title{font-family:var(--font-display);font-size:clamp(22px,4vw,34px);font-weight:800;color:var(--text-primary);letter-spacing:-.02em;margin-bottom:12px;line-height:1.2;}
.cta-desc{font-size:15px;color:var(--text-muted);margin-bottom:28px;line-height:1.65;}
.btn-cta{display:inline-flex;align-items:center;gap:8px;padding:13px 36px;background:var(--blue);color:white;border-radius:9px;font-size:15px;font-weight:700;border:none;cursor:pointer;transition:all .2s;box-shadow:0 4px 18px rgba(37,99,235,.28);}
.btn-cta:hover{background:var(--blue-dark);box-shadow:0 8px 26px rgba(37,99,235,.38);transform:translateY(-2px);}

/* ── FOOTER ── */
.lp-footer{padding:22px 40px;background:#f8fafc;border-top:1px solid var(--border-soft);display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;}
.footer-logo{display:flex;align-items:center;gap:8px;font-size:12.5px;color:var(--text-faint);}
.footer-logo-m{width:21px;height:21px;background:linear-gradient(135deg,var(--blue),var(--violet));border-radius:4px;display:flex;align-items:center;justify-content:center;}
.footer-logo-m svg{width:10px;height:10px;fill:white;}
.footer-links{display:flex;gap:18px;}
.footer-links a{font-size:12.5px;color:var(--text-faint);transition:color .15s;}
.footer-links a:hover{color:var(--text-muted);}

/* AOS scroll animations */
.aos{opacity:0;transform:translateY(18px);transition:opacity .5s ease,transform .5s ease;}
.aos.visible{opacity:1;transform:translateY(0);}

@media(max-width:900px){ .nav-links{display:none;} .feat-grid{grid-template-columns:1fr 1fr;} .stats-row{grid-template-columns:repeat(2,1fr);} .stat-item:nth-child(2){border-right:none;} }
@media(max-width:600px){ .lp-nav{padding:0 16px;} .lp-hero,.lp-section,.lp-feat,.lp-stats,.lp-cta{padding:56px 16px;} .feat-grid{grid-template-columns:1fr;} .pd-row{flex-direction:column;gap:8px;} .pd-conn{display:none;} .hero-actions{flex-direction:column;align-items:stretch;} .card-body{padding:24px 20px 20px;} .card-footer{padding:10px 20px 14px;} }
</style>
</head>
<body>

<!-- ══ NAV ══ -->
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
    <button class="btn-nav-login" onclick="openLogin()">
        <i class="fas fa-arrow-right-to-bracket"></i> Login to Platform
    </button>
</nav>

<!-- ══ LOGIN OVERLAY ══ -->
<div class="login-overlay" id="login-overlay" onclick="overlayClick(event)">
    <div class="login-card">
        <div class="card-accent"></div>
        <div class="card-body">

            <!-- Top bar -->
            <div class="card-topbar">
                <div class="card-logo">
                    <div class="logo-mark"><svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg></div>
                    <div>
                        <div class="logo-name">MediSwitch</div>
                        <div class="logo-sub">NOC Platform</div>
                    </div>
                </div>
                <button class="close-btn" onclick="closeLogin()" title="Close"><i class="fas fa-times"></i></button>
            </div>

            <div class="card-heading">
                <h2>Welcome back</h2>
                <p>Sign in to access your mediation console</p>
            </div>

            <!-- Error (from JSP attribute) -->
            <% if (errorAttr != null) { %>
            <div class="login-error" id="login-err">
                <i class="fas fa-circle-exclamation"></i>
                <span style="flex:1"><%= errorAttr %></span>
                <i class="fas fa-times close-err" onclick="this.closest('.login-error').remove()"></i>
            </div>
            <% } %>

            <form method="POST" action="<%= request.getContextPath() %>/login" id="login-form" autocomplete="on">

                <div class="field-group">
                    <label class="field-label" for="username">Username</label>
                    <div class="field-wrap">
                        <input type="text" id="username" name="username" class="field-input"
                               placeholder="Enter username"
                               value="<%= usernameAttr != null ? usernameAttr : "" %>"
                               autocomplete="username" required>
                        <i class="fas fa-user field-icon"></i>
                    </div>
                </div>

                <div class="field-group">
                    <label class="field-label" for="password">Password</label>
                    <div class="field-wrap">
                        <input type="password" id="password" name="password" class="field-input"
                               placeholder="••••••••••" autocomplete="current-password" required
                               style="padding-right:38px;">
                        <i class="fas fa-lock field-icon"></i>
                        <button type="button" class="pwd-toggle" id="pwd-toggle" tabindex="-1">
                            <i class="fas fa-eye" id="pwd-icon"></i>
                        </button>
                    </div>
                </div>

                <button type="submit" class="btn-submit" id="submit-btn">
                    <span class="btn-txt"><i class="fas fa-arrow-right-to-bracket"></i> Sign In</span>
                    <span class="spinner"><i class="fas fa-circle-notch fa-spin"></i> Authenticating…</span>
                </button>
            </form>

            <div class="security-strip">
                <i class="fas fa-shield-halved"></i>
                <span>BCrypt-hashed</span><span class="sep">·</span>
                <span>Session-scoped</span><span class="sep">·</span>
                <span>Restricted access</span>
            </div>
        </div>

        <div class="card-footer">
            <div class="footer-status">
                <div class="status-dot"></div>
                <span>Online</span>
            </div>
            <div class="footer-ver"><span>MediSwitch v3.0</span></div>
        </div>
    </div>
</div>

<!-- ══ HERO ══ -->
<section class="lp-hero">
    <div class="hero-bg">
        <div class="hero-grid"></div>
        <div class="hblob hb1"></div>
        <div class="hblob hb2"></div>
        <div class="hblob hb3"></div>
    </div>
    <div class="hero-content">
        <div class="hero-badge"><i class="fas fa-satellite-dish"></i> Enterprise Telecom Mediation</div>
        <h1>CDR Mediation Built<br>for the <span class="accent">Modern NOC</span></h1>
        <p class="hero-sub">Process, filter, and route Call Detail Records from MSC, SMSC, and PGW nodes to billing, fraud detection, and charging systems — in real time.</p>
        <div class="hero-actions">
            <button class="btn-hp" onclick="openLogin()">
                <i class="fas fa-arrow-right-to-bracket"></i> Open Platform
            </button>
            <a href="#pipeline" class="btn-hs">
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

<!-- ══ PIPELINE ══ -->
<section class="lp-section" id="pipeline">
    <div class="sec-eye">Architecture</div>
    <h2 class="sec-title">End-to-End Mediation Pipeline</h2>
    <p class="sec-sub">From source network elements to downstream processing — automated, real-time CDR routing with intelligent filtering.</p>
    <div class="pd-row aos">
        <div class="pd-col">
            <div class="pd-node up"><div class="pd-ico ico-a"><i class="fas fa-broadcast-tower"></i></div><div><div class="pd-name">MSC</div><div class="pd-sub">Voice CDRs</div></div></div>
            <div class="pd-node up"><div class="pd-ico ico-a"><i class="fas fa-envelope"></i></div><div><div class="pd-name">SMSC</div><div class="pd-sub">SMS CDRs</div></div></div>
            <div class="pd-node up"><div class="pd-ico ico-a"><i class="fas fa-wifi"></i></div><div><div class="pd-name">PGW</div><div class="pd-sub">Data CDRs</div></div></div>
        </div>
        <div class="pd-conn">
            <div class="pd-line"></div>
            <span style="font-family:var(--font-mono);font-size:8.5px;color:var(--blue);text-align:center;opacity:.6;letter-spacing:.10em;text-transform:uppercase;">SFTP Pull</span>
            <div class="pd-line"></div><span></span><div class="pd-line"></div>
        </div>
        <div class="pd-col">
            <div class="pd-node eng">
                <div class="pd-ering"></div>
                <div class="pd-ico ico-b"><i class="fas fa-microchip"></i></div>
                <div class="pd-name" style="font-size:11px;margin-top:5px;">MEDIATION</div>
                <div class="pd-sub" style="font-size:10px;">Filter · Route · Transform</div>
                <div style="margin-top:7px;display:flex;gap:4px;flex-wrap:wrap;justify-content:center;">
                    <span style="font-family:var(--font-mono);font-size:7.5px;padding:2px 5px;background:rgba(37,99,235,.06);color:var(--blue);border-radius:3px;border:1px solid rgba(37,99,235,.14);font-weight:500;">Rule Engine</span>
                    <span style="font-family:var(--font-mono);font-size:7.5px;padding:2px 5px;background:rgba(217,119,6,.06);color:var(--amber);border-radius:3px;border:1px solid rgba(217,119,6,.14);font-weight:500;">Validator</span>
                </div>
            </div>
        </div>
        <div class="pd-conn">
            <div class="pd-line"></div>
            <span style="font-family:var(--font-mono);font-size:8.5px;color:var(--blue);text-align:center;opacity:.6;letter-spacing:.10em;text-transform:uppercase;">SFTP Push</span>
            <div class="pd-line"></div><span></span><div class="pd-line"></div>
        </div>
        <div class="pd-col">
            <div class="pd-node dn"><div class="pd-ico ico-g"><i class="fas fa-file-invoice-dollar"></i></div><div><div class="pd-name">Billing</div><div class="pd-sub">Revenue</div></div></div>
            <div class="pd-node fraud"><div class="pd-ico ico-r"><i class="fas fa-shield-alt"></i></div><div><div class="pd-name">Fraud</div><div class="pd-sub">Detection</div></div></div>
            <div class="pd-node dn"><div class="pd-ico ico-g"><i class="fas fa-bolt"></i></div><div><div class="pd-name">Charging</div><div class="pd-sub">OCS</div></div></div>
        </div>
    </div>
</section>

<!-- ══ FEATURES ══ -->
<section class="lp-feat" id="features">
    <div class="sec-eye">Capabilities</div>
    <h2 class="sec-title">Everything Your NOC Needs</h2>
    <p class="sec-sub">Built from the ground up for modern telecom operations centers.</p>
    <div class="feat-grid">
        <div class="fc fc1 aos"><div class="fc-icon"><i class="fas fa-satellite-dish"></i></div><div class="fc-title">Real-time CDR Collection</div><p class="fc-desc">Automated SFTP/FTP polling from MSC, SMSC, and PGW nodes. Processes CDR files immediately upon arrival.</p></div>
        <div class="fc fc2 aos" style="transition-delay:.05s"><div class="fc-icon"><i class="fas fa-route"></i></div><div class="fc-title">Intelligent Rule Engine</div><p class="fc-desc">Flexible mediation rules with field filters, regex matching, threshold checks, and blocked-number detection.</p></div>
        <div class="fc fc3 aos" style="transition-delay:.10s"><div class="fc-icon"><i class="fas fa-shield-virus"></i></div><div class="fc-title">Fraud Detection</div><p class="fc-desc">Block suspicious numbers before records reach downstream. Dynamic lists updated in real time.</p></div>
        <div class="fc fc4 aos" style="transition-delay:.15s"><div class="fc-icon"><i class="fas fa-project-diagram"></i></div><div class="fc-title">Multi-Node Routing</div><p class="fc-desc">Route processed CDRs simultaneously to Billing, Fraud, and Charging. Each node gets exactly what it needs.</p></div>
        <div class="fc fc5 aos" style="transition-delay:.20s"><div class="fc-icon"><i class="fas fa-chart-line"></i></div><div class="fc-title">Live Flow Monitoring</div><p class="fc-desc">Visual NOC-style topology with real-time packet animation and per-type telemetry counters.</p></div>
        <div class="fc fc6 aos" style="transition-delay:.25s"><div class="fc-icon"><i class="fas fa-user-shield"></i></div><div class="fc-title">Enterprise Access Control</div><p class="fc-desc">BCrypt credentials, session-scoped access, multi-operator admin management for enterprise security.</p></div>
    </div>
</section>

<!-- ══ STATS ══ -->
<section class="lp-stats" id="stats">
    <div class="stats-bg"></div>
    <div class="stats-row">
        <div class="stat-item aos"><div class="stat-num sn-b" data-target="99.9" data-suffix="">0</div><div class="stat-lbl">Uptime SLA %</div></div>
        <div class="stat-item aos" style="transition-delay:.08s"><div class="stat-num sn-g" data-target="100" data-suffix="ms">0</div><div class="stat-lbl">Avg Process Time</div></div>
        <div class="stat-item aos" style="transition-delay:.16s"><div class="stat-num sn-w" data-target="6">0</div><div class="stat-lbl">Node Types</div></div>
        <div class="stat-item aos" style="transition-delay:.24s"><div class="stat-num sn-w" data-target="3">0</div><div class="stat-lbl">CDR Formats</div></div>
    </div>
</section>

<!-- ══ CTA ══ -->
<section class="lp-cta">
    <div class="cta-box aos">
        <h2 class="cta-title">Ready to Access the Platform?</h2>
        <p class="cta-desc">Sign in to your MediSwitch console to manage nodes, configure routing rules, monitor CDR flows, and control your entire mediation infrastructure.</p>
        <button class="btn-cta" onclick="openLogin()">
            <i class="fas fa-arrow-right-to-bracket"></i> Login to Dashboard
        </button>
    </div>
</section>

<!-- ══ FOOTER ══ -->
<footer class="lp-footer">
    <div class="footer-logo">
        <div class="footer-logo-m"><svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg></div>
        <span>MediSwitch NOC Platform · v3.0 · Enterprise Telecom Mediation</span>
    </div>
    <div class="footer-links">
        <a href="#features">Features</a>
        <a href="#pipeline">Architecture</a>
        <a href="#" onclick="openLogin();return false;">Login</a>
    </div>
</footer>

<script>
/* ── Login overlay ── */
function openLogin() {
    document.getElementById('login-overlay').classList.add('open');
    document.body.style.overflow = 'hidden';
    setTimeout(function(){
        var u = document.getElementById('username');
        if (u && !u.value) u.focus();
    }, 300);
}
function closeLogin() {
    document.getElementById('login-overlay').classList.remove('open');
    document.body.style.overflow = '';
}
function overlayClick(e) {
    if (e.target === document.getElementById('login-overlay')) closeLogin();
}
document.addEventListener('keydown', function(e){ if(e.key==='Escape') closeLogin(); });

/* ── Password toggle ── */
(function(){
    var toggle = document.getElementById('pwd-toggle');
    var input  = document.getElementById('password');
    var icon   = document.getElementById('pwd-icon');
    if (toggle) toggle.addEventListener('click', function(){
        var shown = input.type === 'text';
        input.type = shown ? 'password' : 'text';
        icon.className = shown ? 'fas fa-eye' : 'fas fa-eye-slash';
    });
})();

/* ── Submit loading state ── */
(function(){
    var form = document.getElementById('login-form');
    var btn  = document.getElementById('submit-btn');
    if (form && btn) form.addEventListener('submit', function(){
        setTimeout(function(){ if(form.checkValidity()) btn.classList.add('loading'); }, 0);
    });
})();

/* ── Auto-open login if there's an error or pre-fill ── */
<% if (openLogin) { %>
window.addEventListener('load', function(){ openLogin(); });
<% } %>

/* ── Nav shadow on scroll ── */
window.addEventListener('scroll', function(){
    document.getElementById('lp-nav').classList.toggle('scrolled', window.scrollY > 20);
});

/* ── Scroll-reveal (AOS) ── */
var aosObs = new IntersectionObserver(function(entries){
    entries.forEach(function(e){
        if (e.isIntersecting) {
            e.target.classList.add('visible');
            var num = e.target.querySelector('[data-target]');
            if (num && !num.dataset.done) { num.dataset.done='1'; animateNum(num); }
        }
    });
}, { threshold:0.15 });
document.querySelectorAll('.aos').forEach(function(el){ aosObs.observe(el); });

function animateNum(el) {
    var target   = parseFloat(el.dataset.target);
    var suffix   = el.dataset.suffix || '';
    var isFloat  = target % 1 !== 0;
    var start    = performance.now();
    var duration = 1200;
    function step(ts) {
        var p    = Math.min((ts - start) / duration, 1);
        var ease = 1 - Math.pow(1 - p, 3);
        el.textContent = (isFloat ? (target*ease).toFixed(1) : Math.floor(target*ease)) + suffix;
        if (p < 1) requestAnimationFrame(step);
        else el.textContent = (isFloat ? target.toFixed(1) : target) + suffix;
    }
    requestAnimationFrame(step);
}
</script>
</body>
</html>
