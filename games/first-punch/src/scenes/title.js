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
        this.shineOffset = -1; // title text shine sweep position

        // Generate twinkling stars (stable positions)
        this.stars = [];
        for (let i = 0; i < 60; i++) {
            this.stars.push({
                x: Math.random(),
                y: Math.random() * 0.35,
                r: 0.5 + Math.random() * 1.5,
                twinkleSpeed: 1.5 + Math.random() * 3,
                twinklePhase: Math.random() * Math.PI * 2
            });
        }

        // Generate skyline buildings (repeated strip)
        this.buildings = [];
        for (let i = 0; i < 20; i++) {
            this.buildings.push({
                x: i * 80,
                w: 60 + Math.random() * 30,
                h: 60 + Math.random() * 120,
                color: `hsl(220, 15%, ${18 + Math.random() * 12}%)`,
                litWindows: Math.floor(Math.random() * 6) + 2
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

        // Animate shine sweep across title (cycles every 4 seconds)
        this.shineOffset = ((this.blinkTime % 4) / 4) * 3 - 1;

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

        // ── Rich gradient sky with deeper colors ──
        const grad = ctx.createLinearGradient(0, 0, 0, h);
        grad.addColorStop(0, '#050520');
        grad.addColorStop(0.2, '#0d0d2b');
        grad.addColorStop(0.4, '#1a1a40');
        grad.addColorStop(0.6, '#3a2060');
        grad.addColorStop(0.8, '#6B3074');
        grad.addColorStop(1, '#C85A30');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, w, h);

        // ── Twinkling stars ──
        ctx.save();
        for (const star of this.stars) {
            const twinkle = 0.3 + 0.7 * Math.max(0, Math.sin(this.blinkTime * star.twinkleSpeed + star.twinklePhase));
            ctx.globalAlpha = twinkle;
            ctx.fillStyle = '#FFFFFF';
            ctx.beginPath();
            ctx.arc(star.x * w, star.y * h, star.r, 0, Math.PI * 2);
            ctx.fill();
            // Cross glint on brightest stars
            if (star.r > 1.2 && twinkle > 0.8) {
                ctx.strokeStyle = 'rgba(255, 255, 255, 0.4)';
                ctx.lineWidth = 0.5;
                const sx = star.x * w, sy = star.y * h, gl = star.r * 3;
                ctx.beginPath();
                ctx.moveTo(sx - gl, sy); ctx.lineTo(sx + gl, sy);
                ctx.moveTo(sx, sy - gl); ctx.lineTo(sx, sy + gl);
                ctx.stroke();
            }
        }
        ctx.restore();

        // ── Scrolling skyline with lit windows ──
        ctx.save();
        const stripW = this.buildings.length * 80 / 2;
        for (const b of this.buildings) {
            const bx = b.x - this.skylineOffset;
            const drawX = ((bx % stripW) + stripW) % stripW - 80;
            ctx.fillStyle = b.color;
            ctx.fillRect(drawX, h - 120 - b.h, b.w, b.h + 120);
            // Lit windows with warm glow
            let winIdx = 0;
            for (let wy = h - 120 - b.h + 12; wy < h - 120; wy += 18) {
                for (let wx = drawX + 8; wx < drawX + b.w - 8; wx += 14) {
                    const lit = winIdx < b.litWindows;
                    ctx.fillStyle = lit ? 'rgba(255, 220, 80, 0.7)' : 'rgba(255, 220, 80, 0.12)';
                    ctx.fillRect(wx, wy, 6, 8);
                    if (lit) {
                        ctx.fillStyle = 'rgba(255, 200, 50, 0.15)';
                        ctx.fillRect(wx - 2, wy - 2, 10, 12);
                    }
                    winIdx++;
                }
            }
        }
        ctx.restore();

        // Ground strip with road feel
        const groundGrad = ctx.createLinearGradient(0, h - 120, 0, h);
        groundGrad.addColorStop(0, '#3a3a3a');
        groundGrad.addColorStop(0.05, '#2a2a2a');
        groundGrad.addColorStop(1, '#1a1a1a');
        ctx.fillStyle = groundGrad;
        ctx.fillRect(0, h - 120, w, 120);
        ctx.fillStyle = '#555';
        ctx.fillRect(0, h - 122, w, 3);
        // Yellow center line
        ctx.fillStyle = '#FFDD00';
        for (let dx = 0; dx < w; dx += 60) {
            ctx.fillRect(dx, h - 60, 30, 4);
        }

        // ── Player silhouette (fighting stance, more detailed) ──
        ctx.save();
        const hx = w * 0.78;
        const hy = h - 125;
        // Subtle glow behind character
        const charGlow = ctx.createRadialGradient(hx, hy - 50, 10, hx, hy - 50, 80);
        charGlow.addColorStop(0, 'rgba(254, 217, 15, 0.12)');
        charGlow.addColorStop(1, 'rgba(254, 217, 15, 0)');
        ctx.fillStyle = charGlow;
        ctx.fillRect(hx - 80, hy - 130, 160, 140);

        const silAlpha = 0.22 + 0.04 * Math.sin(this.blinkTime * 1.5);
        ctx.fillStyle = `rgba(254, 217, 15, ${silAlpha})`;
        // Head
        ctx.beginPath(); ctx.arc(hx, hy - 115, 32, 0, Math.PI * 2); ctx.fill();
        // Body (wider, more muscular)
        ctx.beginPath(); ctx.ellipse(hx, hy - 55, 28, 44, 0, 0, Math.PI * 2); ctx.fill();
        // Legs
        ctx.fillRect(hx - 20, hy - 18, 14, 22);
        ctx.fillRect(hx + 6, hy - 18, 14, 22);
        // Fighting arm (extended fist)
        ctx.save();
        ctx.translate(hx + 18, hy - 70);
        ctx.rotate(-0.3);
        ctx.fillRect(0, 0, 32, 8);
        ctx.beginPath(); ctx.arc(32, 4, 7, 0, Math.PI * 2); ctx.fill();
        ctx.restore();
        // Back arm (guard position)
        ctx.save();
        ctx.translate(hx - 18, hy - 65);
        ctx.rotate(0.8);
        ctx.fillRect(0, 0, 16, 7);
        ctx.beginPath(); ctx.arc(16, 3.5, 6, 0, Math.PI * 2); ctx.fill();
        ctx.restore();
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

        // ── Title text with glow + shine sweep ──
        const titleY = Math.round(h * 0.17);
        const titleFont = 'bold 76px "Arial Black", Arial, sans-serif';
        const hw = Math.round(w / 2);

        ctx.save();
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.font = titleFont;

        // Title glow behind text
        ctx.shadowColor = '#FED90F';
        ctx.shadowBlur = 30 + 10 * Math.sin(this.blinkTime * 2);

        // Drop shadow
        ctx.fillStyle = 'rgba(0,0,0,0.45)';
        ctx.shadowBlur = 0;
        ctx.fillText('FIRST PUNCH', hw + 4, titleY + 5);

        // Thick dark outline (double-stroke for thickness)
        ctx.shadowColor = '#FED90F';
        ctx.shadowBlur = 25 + 10 * Math.sin(this.blinkTime * 2);
        ctx.lineWidth = 8;
        ctx.strokeStyle = '#1a1a1a';
        ctx.lineJoin = 'round';
        ctx.strokeText('FIRST PUNCH', hw, titleY);

        ctx.lineWidth = 4;
        ctx.strokeStyle = '#4a3000';
        ctx.strokeText('FIRST PUNCH', hw, titleY);

        // Yellow fill with gradient
        const titleGrad = ctx.createLinearGradient(hw - 200, titleY - 30, hw + 200, titleY + 30);
        titleGrad.addColorStop(0, '#FFE040');
        titleGrad.addColorStop(0.3, '#FED90F');
        titleGrad.addColorStop(0.5, '#FFEC6B');
        titleGrad.addColorStop(0.7, '#FED90F');
        titleGrad.addColorStop(1, '#E8B800');
        ctx.fillStyle = titleGrad;
        ctx.fillText('FIRST PUNCH', hw, titleY);

        // Shine sweep across title text
        ctx.save();
        ctx.globalCompositeOperation = 'lighter';
        const shineX = hw - 250 + this.shineOffset * 500;
        const shineGrad = ctx.createLinearGradient(shineX - 40, 0, shineX + 40, 0);
        shineGrad.addColorStop(0, 'rgba(255, 255, 255, 0)');
        shineGrad.addColorStop(0.5, 'rgba(255, 255, 255, 0.35)');
        shineGrad.addColorStop(1, 'rgba(255, 255, 255, 0)');
        ctx.fillStyle = shineGrad;
        ctx.fillText('FIRST PUNCH', hw, titleY);
        ctx.restore();

        ctx.shadowBlur = 0;

        // ── Subtitle with slight bounce ──
        const subY = titleY + 55;
        const subBounce = Math.sin(this.blinkTime * 3) * 2;
        ctx.font = 'bold 30px "Arial Black", Arial, sans-serif';

        ctx.lineWidth = 5;
        ctx.strokeStyle = '#1a1a1a';
        ctx.strokeText('BEAT \'EM UP', hw, subY + subBounce);

        ctx.fillStyle = '#FFFFFF';
        ctx.fillText('BEAT \'EM UP', hw, subY + subBounce);
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

        // ── Vignette overlay for cinematic feel ──
        ctx.save();
        const vignette = ctx.createRadialGradient(hw, h * 0.45, h * 0.25, hw, h * 0.45, h * 0.85);
        vignette.addColorStop(0, 'rgba(0, 0, 0, 0)');
        vignette.addColorStop(0.7, 'rgba(0, 0, 0, 0)');
        vignette.addColorStop(1, 'rgba(0, 0, 0, 0.5)');
        ctx.fillStyle = vignette;
        ctx.fillRect(0, 0, w, h);
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
