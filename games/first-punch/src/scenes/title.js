import { getHighScore } from '../ui/highscore.js';

export class TitleScene {
    constructor(game, renderer, input, audio) {
        this.game = game;
        this.renderer = renderer;
        this.input = input;
        this.audio = audio;
        this.blinkTime = 0;
        this.skylineOffset = 0;
        this.particles = [];
        this.menuIndex = 0;

        // Generate skyline buildings (repeated strip)
        this.buildings = [];
        for (let i = 0; i < 20; i++) {
            this.buildings.push({
                x: i * 80,
                w: 60 + Math.random() * 30,
                h: 60 + Math.random() * 120,
                color: `hsl(220, 15%, ${18 + Math.random() * 12}%)`
            });
        }
    }

    onEnter() {
        this.blinkTime = 0;
        this.skylineOffset = 0;
        this.particles = [];
        this.menuIndex = 0;
    }

    onExit() {
    }

    _spawnParticle() {
        this.particles.push({
            x: Math.random() * this.renderer.width,
            y: this.renderer.height + 5,
            r: 2 + Math.random() * 3,
            speed: 30 + Math.random() * 40,
            drift: (Math.random() - 0.5) * 20,
            alpha: 0.5 + Math.random() * 0.5
        });
    }

    // Rounded rectangle path helper
    _roundRect(ctx, x, y, w, h, r) {
        r = Math.min(r, w / 2, h / 2);
        ctx.beginPath();
        ctx.moveTo(x + r, y);
        ctx.lineTo(x + w - r, y);
        ctx.arcTo(x + w, y, x + w, y + r, r);
        ctx.lineTo(x + w, y + h - r);
        ctx.arcTo(x + w, y + h, x + w - r, y + h, r);
        ctx.lineTo(x + r, y + h);
        ctx.arcTo(x, y + h, x, y + h - r, r);
        ctx.lineTo(x, y + r);
        ctx.arcTo(x, y, x + r, y, r);
        ctx.closePath();
    }

    // Draw a key cap icon (rounded rect with label)
    _drawKey(ctx, cx, cy, label, minWidth = 40) {
        ctx.font = 'bold 13px "Arial Black", Arial, sans-serif';
        const textW = ctx.measureText(label).width;
        const kw = Math.max(minWidth, textW + 18);
        const kh = 28;
        const kx = cx - kw / 2;
        const ky = cy - kh / 2;

        // Key shadow
        this._roundRect(ctx, kx, ky + 3, kw, kh, 6);
        ctx.fillStyle = 'rgba(0,0,0,0.5)';
        ctx.fill();

        // Key face
        this._roundRect(ctx, kx, ky, kw, kh, 6);
        const keyGrad = ctx.createLinearGradient(kx, ky, kx, ky + kh);
        keyGrad.addColorStop(0, '#555');
        keyGrad.addColorStop(1, '#333');
        ctx.fillStyle = keyGrad;
        ctx.fill();
        ctx.strokeStyle = 'rgba(255,255,255,0.2)';
        ctx.lineWidth = 1;
        ctx.stroke();

        // Key label
        ctx.fillStyle = '#EEE';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText(label, cx, cy);
    }

    update(dt) {
        this.blinkTime += dt;
        this.skylineOffset = (this.skylineOffset + dt * 15) % (this.buildings.length * 80 / 2);

        if (Math.random() < dt * 2.5) {
            this._spawnParticle();
        }

        for (const p of this.particles) {
            p.y -= p.speed * dt;
            p.x += p.drift * dt;
            p.alpha -= dt * 0.15;
        }
        this.particles = this.particles.filter(p => p.y > -10 && p.alpha > 0);

        // Menu navigation
        if (this.input.isPressed('ArrowUp') || this.input.isPressed('KeyW')) {
            this.menuIndex = (this.menuIndex - 1 + 2) % 2;
            if (this.audio) this.audio.playMenuSelect();
        }
        if (this.input.isPressed('ArrowDown') || this.input.isPressed('KeyS')) {
            this.menuIndex = (this.menuIndex + 1) % 2;
            if (this.audio) this.audio.playMenuSelect();
        }

        if (this.input.isStart()) {
            if (this.audio) this.audio.playMenuConfirm();
            if (this.menuIndex === 0) {
                this.game.switchScene('gameplay');
            } else {
                this.game._optionsReturn = 'title';
                this.game.switchScene('options');
            }
        }

        this.input.clearFrameState();
    }

    render() {
        const ctx = this.renderer.ctx;
        const w = this.renderer.width;
        const h = this.renderer.height;

        // ── Gradient sky ──
        const grad = ctx.createLinearGradient(0, 0, 0, h);
        grad.addColorStop(0, '#0d0d2b');
        grad.addColorStop(0.4, '#1a1a40');
        grad.addColorStop(0.7, '#3a2060');
        grad.addColorStop(1, '#87CEEB');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, w, h);

        // ── Scrolling skyline ──
        ctx.save();
        const stripW = this.buildings.length * 80 / 2;
        for (const b of this.buildings) {
            const bx = b.x - this.skylineOffset;
            const drawX = ((bx % stripW) + stripW) % stripW - 80;
            ctx.fillStyle = b.color;
            ctx.fillRect(drawX, h - 120 - b.h, b.w, b.h + 120);
            ctx.fillStyle = 'rgba(255, 220, 80, 0.3)';
            for (let wy = h - 120 - b.h + 12; wy < h - 120; wy += 18) {
                for (let wx = drawX + 8; wx < drawX + b.w - 8; wx += 14) {
                    ctx.fillRect(wx, wy, 6, 8);
                }
            }
        }
        ctx.restore();

        // Ground strip
        ctx.fillStyle = '#2a2a2a';
        ctx.fillRect(0, h - 120, w, 120);
        ctx.fillStyle = '#444';
        ctx.fillRect(0, h - 122, w, 3);

        // ── Player silhouette ──
        ctx.save();
        const hx = w * 0.78;
        const hy = h - 125;
        ctx.fillStyle = 'rgba(254, 217, 15, 0.18)';
        ctx.beginPath(); ctx.arc(hx, hy - 115, 32, 0, Math.PI * 2); ctx.fill();
        ctx.beginPath(); ctx.ellipse(hx, hy - 55, 26, 42, 0, 0, Math.PI * 2); ctx.fill();
        ctx.fillRect(hx - 18, hy - 18, 14, 20);
        ctx.fillRect(hx + 4, hy - 18, 14, 20);
        ctx.beginPath(); ctx.arc(hx + 6, hy - 55, 22, -0.5, 1.2); ctx.fill();
        ctx.restore();

        // ── Star particles ──
        ctx.save();
        for (const p of this.particles) {
            ctx.globalAlpha = p.alpha;
            ctx.fillStyle = '#FED90F';
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
            ctx.fill();
        }
        ctx.restore();

        // ── Title text with thick outline + drop shadow ──
        const titleY = Math.round(h * 0.17);
        const titleFont = 'bold 76px "Arial Black", Arial, sans-serif';
        const hw = Math.round(w / 2);

        ctx.save();
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.font = titleFont;

        // Drop shadow
        ctx.fillStyle = 'rgba(0,0,0,0.45)';
        ctx.fillText('FIRST PUNCH', hw + 4, titleY + 5);

        // Thick dark outline (double-stroke for thickness)
        ctx.lineWidth = 8;
        ctx.strokeStyle = '#1a1a1a';
        ctx.lineJoin = 'round';
        ctx.strokeText('FIRST PUNCH', hw, titleY);

        ctx.lineWidth = 4;
        ctx.strokeStyle = '#4a3000';
        ctx.strokeText('FIRST PUNCH', hw, titleY);

        // Yellow fill
        ctx.fillStyle = '#FED90F';
        ctx.fillText('FIRST PUNCH', hw, titleY);

        // ── Subtitle ──
        const subY = titleY + 55;
        ctx.font = 'bold 30px "Arial Black", Arial, sans-serif';

        ctx.lineWidth = 5;
        ctx.strokeStyle = '#1a1a1a';
        ctx.strokeText('BEAT \'EM UP', hw, subY);

        ctx.fillStyle = '#FFFFFF';
        ctx.fillText('BEAT \'EM UP', hw, subY);
        ctx.restore();

        // ── High Score (prominent) ──
        const highScore = getHighScore();
        if (highScore > 0) {
            ctx.save();
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';
            ctx.font = 'bold 22px "Arial Black", Arial, sans-serif';
            const hsY = Math.round(h * 0.38);
            ctx.lineWidth = 4;
            ctx.strokeStyle = '#1a1a1a';
            ctx.lineJoin = 'round';
            ctx.strokeText(`★ HIGH SCORE: ${highScore} ★`, hw, hsY);
            ctx.fillStyle = '#FED90F';
            ctx.fillText(`★ HIGH SCORE: ${highScore} ★`, hw, hsY);
            ctx.restore();
        }

        // ── Menu items with selection cursor ──
        const menuY = Math.round(h * 0.50);
        const menuItems = ['START GAME', 'OPTIONS'];

        ctx.save();
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';

        for (let i = 0; i < menuItems.length; i++) {
            const selected = i === this.menuIndex;
            const itemY = Math.round(menuY + i * 45);

            if (selected) {
                const pulse = 0.7 + 0.3 * Math.sin(this.blinkTime * 4);
                ctx.globalAlpha = pulse;
                ctx.shadowColor = '#FED90F';
                ctx.shadowBlur = 15 + 12 * Math.sin(this.blinkTime * 4);
            } else {
                ctx.globalAlpha = 0.6;
                ctx.shadowBlur = 0;
            }

            ctx.font = selected ? 'bold 30px "Arial Black", Arial, sans-serif' : 'bold 24px "Arial Black", Arial, sans-serif';
            ctx.lineWidth = 4;
            ctx.strokeStyle = '#222';
            ctx.lineJoin = 'round';

            const label = selected ? `▸ ${menuItems[i]} ◂` : menuItems[i];
            ctx.strokeText(label, hw, itemY);
            ctx.fillStyle = selected ? '#FED90F' : '#aaa';
            ctx.fillText(label, hw, itemY);
        }

        ctx.globalAlpha = 1;
        ctx.shadowBlur = 0;
        ctx.restore();

        // ── Controls with key icons ──
        const ctrlY = Math.round(h * 0.68);
        ctx.save();
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';

        // Semi-transparent panel behind controls
        this._roundRect(ctx, Math.round(w / 2 - 250), ctrlY - 45, 500, 100, 12);
        ctx.fillStyle = 'rgba(0, 0, 0, 0.45)';
        ctx.fill();
        ctx.strokeStyle = 'rgba(255,255,255,0.08)';
        ctx.lineWidth = 1;
        ctx.stroke();

        // Row 1: Movement
        const row1Y = ctrlY - 18;
        this._drawKey(ctx, Math.round(w / 2 - 160), row1Y, 'W A S D', 90);
        ctx.font = 'bold 14px Arial';
        ctx.fillStyle = '#999';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('/', Math.round(w / 2 - 100), row1Y);
        this._drawKey(ctx, Math.round(w / 2 - 40), row1Y, '← → ↑ ↓', 90);
        ctx.font = 'bold 14px Arial';
        ctx.fillStyle = '#ccc';
        ctx.fillText('— Move', Math.round(w / 2 + 50), row1Y);

        // Row 2: Actions
        const row2Y = ctrlY + 22;
        this._drawKey(ctx, Math.round(w / 2 - 170), row2Y, 'J / Z', 55);
        ctx.font = 'bold 14px Arial';
        ctx.fillStyle = '#ccc';
        ctx.fillText('Punch', Math.round(w / 2 - 110), row2Y);

        this._drawKey(ctx, Math.round(w / 2 - 30), row2Y, 'K / X', 55);
        ctx.font = 'bold 14px Arial';
        ctx.fillText('Kick', Math.round(w / 2 + 30), row2Y);

        this._drawKey(ctx, Math.round(w / 2 + 100), row2Y, 'SPACE', 65);
        ctx.font = 'bold 14px Arial';
        ctx.fillText('Jump', Math.round(w / 2 + 165), row2Y);

        ctx.restore();

        // ── Credits ──
        ctx.save();
        ctx.fillStyle = 'rgba(255, 255, 255, 0.35)';
        ctx.font = '13px Arial';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'bottom';
        ctx.fillText('A First Punch Production', hw, h - 10);
        ctx.restore();
    }
}
