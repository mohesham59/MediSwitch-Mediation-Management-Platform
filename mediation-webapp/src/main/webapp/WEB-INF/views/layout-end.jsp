    </div><!-- /content -->
</div><!-- /main -->
</div><!-- /app -->
<script>
// Live clock
(function() {
    function tick() {
        const el = document.getElementById('tbar-clock');
        if (el) {
            const now = new Date();
            const pad = n => String(n).padStart(2, '0');
            el.textContent = pad(now.getHours()) + ':' + pad(now.getMinutes()) + ':' + pad(now.getSeconds());
        }
    }
    tick();
    setInterval(tick, 1000);
})();

// Auto-dismiss alerts
document.querySelectorAll('.alert').forEach(el => {
    setTimeout(() => {
        el.style.transition = 'opacity 0.4s, transform 0.4s';
        el.style.opacity = '0';
        el.style.transform = 'translateY(-4px)';
        setTimeout(() => el.remove(), 400);
    }, 5000);
});

// Confirm deletes
document.querySelectorAll('[data-confirm]').forEach(el => {
    el.addEventListener('click', e => {
        if (!confirm(el.dataset.confirm)) e.preventDefault();
    });
});

// Toggle switch fix
document.querySelectorAll('.toggle-track, .toggle-thumb').forEach(el => {
    el.addEventListener('click', () => {
        const inp = el.closest('.toggle').querySelector('input');
        if (inp) { inp.checked = !inp.checked; inp.dispatchEvent(new Event('change')); }
    });
});
</script>
</body>
</html>
