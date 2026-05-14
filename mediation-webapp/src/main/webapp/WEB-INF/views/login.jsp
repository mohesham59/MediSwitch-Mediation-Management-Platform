<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Sign In — MediFlow</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=Syne:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
:root {
    --bg: #080c14; --bg2: #0d1420; --bg3: #111827;
    --border: #1e2d45; --amber: #f59e0b; --amber-glow: #fbbf24;
    --text: #e2e8f0; --text-dim: #64748b; --text-muted: #334155;
    --red: #ef4444; --red-dim: #450a0a;
    --mono: 'Space Mono', monospace;
    --sans: 'Syne', sans-serif;
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html, body { height: 100%; background: var(--bg); color: var(--text); font-family: var(--sans); }

.login-page {
    min-height: 100vh;
    display: grid;
    grid-template-columns: 1fr 420px;
}

/* Left panel — decorative */
.login-art {
    background: var(--bg2);
    border-right: 1px solid var(--border);
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 60px;
    position: relative;
    overflow: hidden;
}
.login-art::before {
    content: '';
    position: absolute;
    inset: 0;
    background: radial-gradient(ellipse at 30% 50%, rgba(245,158,11,0.06) 0%, transparent 60%),
                radial-gradient(ellipse at 80% 20%, rgba(6,182,212,0.04) 0%, transparent 50%);
}
.art-grid {
    position: absolute;
    inset: 0;
    background-image:
        linear-gradient(rgba(30,45,69,0.4) 1px, transparent 1px),
        linear-gradient(90deg, rgba(30,45,69,0.4) 1px, transparent 1px);
    background-size: 40px 40px;
}
.art-content { position: relative; z-index: 1; }
.art-logo {
    display: flex;
    align-items: center;
    gap: 14px;
    margin-bottom: 48px;
}
.art-logo-icon {
    width: 44px; height: 44px;
    background: var(--amber);
    border-radius: 8px;
    display: flex; align-items: center; justify-content: center;
}
.art-logo-icon svg { width: 24px; height: 24px; fill: #000; }
.art-logo-text { font-size: 20px; font-weight: 800; letter-spacing: 0.04em; text-transform: uppercase; }

.art-headline {
    font-size: 40px;
    font-weight: 800;
    line-height: 1.1;
    letter-spacing: -0.03em;
    margin-bottom: 16px;
}
.art-headline span { color: var(--amber); }
.art-desc { color: var(--text-dim); font-size: 14px; line-height: 1.7; max-width: 380px; margin-bottom: 48px; }

.art-features { display: flex; flex-direction: column; gap: 12px; }
.art-feature {
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 13px;
    color: var(--text-dim);
}
.art-feature-dot {
    width: 6px; height: 6px;
    background: var(--amber);
    border-radius: 50%;
    flex-shrink: 0;
    box-shadow: 0 0 8px var(--amber);
}

/* Right panel — form */
.login-form-panel {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 40px;
    background: var(--bg);
}
.login-box { width: 100%; max-width: 340px; }
.login-box h2 {
    font-size: 22px;
    font-weight: 800;
    margin-bottom: 6px;
    letter-spacing: -0.02em;
}
.login-box p { color: var(--text-dim); font-size: 13px; margin-bottom: 32px; }

.form-group { margin-bottom: 16px; }
label {
    display: block;
    font-family: var(--mono);
    font-size: 10px;
    font-weight: 700;
    color: var(--text-dim);
    text-transform: uppercase;
    letter-spacing: 0.12em;
    margin-bottom: 6px;
}
input {
    width: 100%;
    background: var(--bg2);
    border: 1px solid var(--border);
    border-radius: 6px;
    color: var(--text);
    font-family: var(--mono);
    font-size: 13px;
    padding: 11px 14px;
    outline: none;
    transition: border-color 0.15s, box-shadow 0.15s;
}
input:focus { border-color: var(--amber); box-shadow: 0 0 0 3px rgba(245,158,11,0.1); }

.alert-error {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 14px;
    background: var(--red-dim);
    border: 1px solid rgba(239,68,68,0.3);
    border-radius: 6px;
    color: var(--red);
    font-size: 13px;
    margin-bottom: 20px;
}

.btn-login {
    width: 100%;
    padding: 12px;
    background: var(--amber);
    color: #000;
    border: none;
    border-radius: 6px;
    font-family: var(--sans);
    font-size: 13px;
    font-weight: 800;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    cursor: pointer;
    transition: background 0.15s;
    margin-top: 8px;
}
.btn-login:hover { background: var(--amber-glow); }

.login-footer {
    text-align: center;
    margin-top: 24px;
    font-family: var(--mono);
    font-size: 10px;
    color: var(--text-muted);
    letter-spacing: 0.08em;
}

@media (max-width: 768px) {
    .login-page { grid-template-columns: 1fr; }
    .login-art { display: none; }
}
</style>
</head>
<body>
<div class="login-page">
    <!-- Left art panel -->
    <div class="login-art">
        <div class="art-grid"></div>
        <div class="art-content">
            <div class="art-logo">
                <div class="art-logo-icon">
                    <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
                </div>
                <span class="art-logo-text">MediFlow</span>
            </div>
            <div class="art-headline">
                Telecom<br><span>Mediation</span><br>System
            </div>
            <p class="art-desc">
                Collect, filter, and route Call Detail Records from upstream network nodes to downstream billing and fraud detection systems.
            </p>
            <div class="art-features">
                <div class="art-feature"><span class="art-feature-dot"></span>Real-time CDR collection via SFTP</div>
                <div class="art-feature"><span class="art-feature-dot"></span>Configurable filtration rules engine</div>
                <div class="art-feature"><span class="art-feature-dot"></span>MSC · SMSC · PGW support</div>
                <div class="art-feature"><span class="art-feature-dot"></span>Billing &amp; Fraud system integration</div>
            </div>
        </div>
    </div>

    <!-- Right form panel -->
    <div class="login-form-panel">
        <div class="login-box">
            <h2>Welcome back</h2>
            <p>Sign in to the admin console</p>

            <% if (request.getAttribute("error") != null) { %>
            <div class="alert-error">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" width="16" height="16">
                    <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
                <%= request.getAttribute("error") %>
            </div>
            <% } %>

            <form method="POST" action="<%= request.getContextPath() %>/login">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" placeholder="admin"
                           value="<%= request.getAttribute("username") != null ? request.getAttribute("username") : "" %>"
                           autocomplete="username" required>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" placeholder="••••••••"
                           autocomplete="current-password" required>
                </div>
                <button type="submit" class="btn-login">Sign In</button>
            </form>

            <div class="login-footer">MEDIATION SYSTEM v1.0 · SECURE ACCESS</div>
        </div>
    </div>
</div>
</body>
</html>
