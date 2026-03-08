export class SplashScene {
    constructor(game, renderer, input, audio) {
        this.game = game;
        this.renderer = renderer;
        this.input = input;
        this.audio = audio;

        this.elapsed = 0;
        this.finished = false;

        // Timing (seconds)
        this.fadeInDuration = 1.0;
        this.holdDuration = 2.0;
        this.fadeOutDuration = 1.0;
        this.totalDuration = this.fadeInDuration + this.holdDuration + this.fadeOutDuration;

        // Particle accents
        this.sparks = [];
    }

    onEnter() {
        this.elapsed = 0;
        this.finished = false;
        this.sparks = [];
    }

    onExit() {}

    _getAlpha() {
        const t = this.elapsed;
        if (t < this.fadeInDuration) {
            // Ease-out quad for smooth fade in
            const p = t / this.fadeInDuration;
            return p * (2 - p);
        }
        if (t < this.fadeInDuration + this.holdDuration) {
            return 1;
        }
        const fadeT = (t - this.fadeInDuration - this.holdDuration) / this.fadeOutDuration;
        // Ease-in quad for smooth fade out
        return Math.max(0, 1 - fadeT * fadeT);
    }

    update(dt) {
        this.elapsed += dt;

        // Spawn subtle gold sparks during the hold phase
        const inHold = this.elapsed > this.fadeInDuration &&
                       this.elapsed < this.fadeInDuration + this.holdDuration;
        if (inHold && Math.random() < dt * 6) {
            const w = this.renderer.width;
            const h = this.renderer.height;
            this.sparks.push({
                x: w * 0.3 + Math.random() * w * 0.4,
                y: h * 0.42 + (Math.random() - 0.5) * 60,
                vx: (Math.random() - 0.5) * 30,
                vy: -15 - Math.random() * 25,
                life: 0.8 + Math.random() * 0.6,
                age: 0,
                r: 1 + Math.random() * 1.5
            });
        }

        for (const s of this.sparks) {
            s.age += dt;
            s.x += s.vx * dt;
            s.y += s.vy * dt;
        }
        this.sparks = this.sparks.filter(s => s.age < s.life);

        // Allow skipping with any key/click after a brief moment
        if (this.elapsed > 0.5) {
            if (this.input.isStart() || this.input.isPressed('Space') || this.input.isPressed('Escape')) {
                this.input.clearFrameState();
                this._transitionOut();
                return;
            }
        }

        this.input.clearFrameState();

        if (this.elapsed >= this.totalDuration && !this.finished) {
            this._transitionOut();
        }
    }

    _transitionOut() {
        if (this.finished) return;
        this.finished = true;
        this.game.switchScene('title');
    }

    render() {
        const ctx = this.renderer.ctx;
        const w = this.renderer.width;
        const h = this.renderer.height;
        const alpha = this._getAlpha();

        // Deep dark background
        ctx.fillStyle = '#08080c';
        ctx.fillRect(0, 0, w, h);

        // Subtle radial vignette glow in center
        const glow = ctx.createRadialGradient(w / 2, h * 0.44, 0, w / 2, h * 0.44, w * 0.4);
        glow.addColorStop(0, `rgba(40, 30, 15, ${0.25 * alpha})`);
        glow.addColorStop(1, 'rgba(0, 0, 0, 0)');
        ctx.fillStyle = glow;
        ctx.fillRect(0, 0, w, h);

        ctx.save();
        ctx.globalAlpha = alpha;
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';

        const cx = Math.round(w / 2);
        const cy = Math.round(h * 0.43);

        // Decorative line above
        const lineW = 260;
        ctx.strokeStyle = `rgba(212, 175, 55, ${0.5 * alpha})`;
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(cx - lineW / 2, cy - 52);
        ctx.lineTo(cx + lineW / 2, cy - 52);
        ctx.stroke();

        // Small diamond accent at center of top line
        const dSize = 4;
        ctx.fillStyle = `rgba(212, 175, 55, ${0.7 * alpha})`;
        ctx.beginPath();
        ctx.moveTo(cx, cy - 52 - dSize);
        ctx.lineTo(cx + dSize, cy - 52);
        ctx.lineTo(cx, cy - 52 + dSize);
        ctx.lineTo(cx - dSize, cy - 52);
        ctx.closePath();
        ctx.fill();

        // Studio name — gold gradient text
        ctx.font = 'bold 52px "Arial Black", Arial, sans-serif';
        ctx.letterSpacing = '6px';

        // Shadow
        ctx.fillStyle = `rgba(0, 0, 0, ${0.6 * alpha})`;
        ctx.fillText('FIRST FRAME STUDIOS', cx + 2, cy + 3);

        // Gold gradient fill
        const grad = ctx.createLinearGradient(cx - 280, cy, cx + 280, cy);
        grad.addColorStop(0, '#b8942e');
        grad.addColorStop(0.3, '#d4af37');
        grad.addColorStop(0.5, '#f5e6a3');
        grad.addColorStop(0.7, '#d4af37');
        grad.addColorStop(1, '#b8942e');
        ctx.fillStyle = grad;
        ctx.fillText('FIRST FRAME STUDIOS', cx, cy);

        // Reset letter spacing
        ctx.letterSpacing = '0px';

        // Tagline
        const tagY = cy + 50;
        ctx.font = 'italic 22px Georgia, "Times New Roman", serif';
        ctx.fillStyle = `rgba(180, 175, 165, ${0.85 * alpha})`;
        ctx.fillText('Forged in Play', cx, tagY);

        // Decorative line below
        ctx.strokeStyle = `rgba(212, 175, 55, ${0.5 * alpha})`;
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(cx - lineW / 2, tagY + 30);
        ctx.lineTo(cx + lineW / 2, tagY + 30);
        ctx.stroke();

        // Small diamond accent at center of bottom line
        ctx.fillStyle = `rgba(212, 175, 55, ${0.7 * alpha})`;
        ctx.beginPath();
        ctx.moveTo(cx, tagY + 30 - dSize);
        ctx.lineTo(cx + dSize, tagY + 30);
        ctx.lineTo(cx, tagY + 30 + dSize);
        ctx.lineTo(cx - dSize, tagY + 30);
        ctx.closePath();
        ctx.fill();

        ctx.restore();

        // Gold sparks
        ctx.save();
        for (const s of this.sparks) {
            const life = 1 - s.age / s.life;
            ctx.globalAlpha = life * alpha * 0.8;
            ctx.fillStyle = '#d4af37';
            ctx.beginPath();
            ctx.arc(s.x, s.y, s.r * life, 0, Math.PI * 2);
            ctx.fill();
        }
        ctx.restore();
    }
}
