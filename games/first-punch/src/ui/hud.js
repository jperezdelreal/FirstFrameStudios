function drawCrispText(ctx, text, x, y, options = {}) {
    ctx.save();
    ctx.font = options.font || 'bold 20px Arial';
    ctx.fillStyle = options.color || '#FFFFFF';
    ctx.textAlign = options.align || 'left';
    ctx.textBaseline = options.baseline || 'top';
    const rx = Math.round(x);
    const ry = Math.round(y);
    if (options.outline) {
        ctx.strokeStyle = options.outlineColor || '#000000';
        ctx.lineWidth = options.outlineWidth || 3;
        ctx.lineJoin = 'round';
        ctx.strokeText(text, rx, ry);
    }
    ctx.fillText(text, rx, ry);
    ctx.restore();
}

export class HUD {
    constructor(renderer) {
        this.renderer = renderer;

        // Score lerp state
        this.displayedScore = 0;

        // Combo display state
        this.prevComboCount = 0;
        this.comboDisplayScale = 1.0;
        this.comboScaleTimer = 0;
        this.comboFadeOut = 0;
        this.displayedCombo = 0;
        this.comboGlowTime = 0;

        // Style meter state
        this.styleLevel = 0;
        this.stylePulseTime = 0;
        this.prevHealth = -1;
    }

    update(dt, player) {
        const current = player.comboCount;
        this.comboGlowTime += dt;
        this.stylePulseTime += dt;

        if (current > this.prevComboCount && current > 1) {
            this.comboDisplayScale = 1.5;
            this.comboScaleTimer = 0.2;
            this.comboFadeOut = 1.0;
            this.displayedCombo = current;
        } else if (current <= 1 && this.prevComboCount > 1) {
            this.comboFadeOut = 1.0;
        }

        if (this.comboScaleTimer > 0) {
            this.comboScaleTimer -= dt;
            const t = Math.max(0, this.comboScaleTimer / 0.2);
            this.comboDisplayScale = 1.0 + 0.5 * t;
        } else {
            this.comboDisplayScale = 1.0;
        }

        if (current <= 1 && this.comboFadeOut > 0) {
            this.comboFadeOut -= dt * 4;
            if (this.comboFadeOut < 0) this.comboFadeOut = 0;
        }

        if (current > 1) {
            this.displayedCombo = current;
        }

        this.prevComboCount = current;

        // Style meter — reset on damage
        if (this.prevHealth >= 0 && player.health < this.prevHealth) {
            this.styleLevel = 0;
            if (player.styleTypes) player.styleTypes.clear();
        }
        this.prevHealth = player.health;

        // Calculate style target from unique attack types + combo count
        const uniqueTypes = player.styleTypes ? player.styleTypes.size : 0;
        const targetStyle = Math.min(100, uniqueTypes * 18 + player.comboCount * 2);

        // Smooth transition
        if (targetStyle > this.styleLevel) {
            this.styleLevel += (targetStyle - this.styleLevel) * 0.12;
        } else {
            // Decay when not actively comboing
            this.styleLevel -= dt * 15;
        }
        this.styleLevel = Math.max(0, Math.min(100, this.styleLevel));
    }

    // Draw a rounded rectangle path
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

    // Mini player head icon
    _drawPlayerIcon(ctx, cx, cy, size) {
        // Yellow head circle
        ctx.fillStyle = '#FED90F';
        ctx.beginPath();
        ctx.arc(cx, cy, size, 0, Math.PI * 2);
        ctx.fill();
        ctx.strokeStyle = '#B8960A';
        ctx.lineWidth = 1.5;
        ctx.stroke();

        // Eyes (white with black pupils)
        const eyeR = size * 0.28;
        const eyeY = cy - size * 0.12;
        ctx.fillStyle = '#FFFFFF';
        ctx.beginPath();
        ctx.arc(cx - size * 0.25, eyeY, eyeR, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(cx + size * 0.25, eyeY, eyeR, 0, Math.PI * 2);
        ctx.fill();

        // Pupils
        ctx.fillStyle = '#000';
        const pupilR = eyeR * 0.5;
        ctx.beginPath();
        ctx.arc(cx - size * 0.2, eyeY, pupilR, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(cx + size * 0.3, eyeY, pupilR, 0, Math.PI * 2);
        ctx.fill();

        // Mouth line
        ctx.strokeStyle = '#B8960A';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.arc(cx, cy + size * 0.1, size * 0.35, 0.2, Math.PI - 0.2);
        ctx.stroke();
    }

    _getStyleInfo(level) {
        if (level >= 80) return { label: 'Best. Combo. Ever.', color: '#FFD700', multiplier: 5, glow: true };
        if (level >= 60) return { label: 'Excellent!', color: '#00e040', multiplier: 3, glow: false };
        if (level >= 40) return { label: 'Oh Yeah!', color: '#FF8C00', multiplier: 2, glow: false };
        if (level >= 20) return { label: 'Not Bad', color: '#FED90F', multiplier: 1.5, glow: false };
        return { label: 'Meh', color: '#888', multiplier: 1, glow: false };
    }

    _renderStyleMeter(ctx) {
        const meterX = 12;
        const meterY = 88;
        const meterW = 22;
        const meterH = 100;
        const pct = this.styleLevel / 100;
        const info = this._getStyleInfo(this.styleLevel);

        // Background panel
        ctx.save();
        this._roundRect(ctx, meterX - 3, meterY - 16, meterW + 6, meterH + 50, 8);
        ctx.fillStyle = 'rgba(0, 0, 0, 0.55)';
        ctx.fill();
        ctx.strokeStyle = 'rgba(254, 217, 15, 0.2)';
        ctx.lineWidth = 1;
        ctx.stroke();
        ctx.restore();

        // "STYLE" label
        ctx.save();
        ctx.font = 'bold 9px "Arial Black", Arial, sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillStyle = '#aaa';
        ctx.fillText('STYLE', Math.round(meterX + meterW / 2), Math.round(meterY - 6));
        ctx.restore();

        // Meter background (dark inset)
        ctx.save();
        this._roundRect(ctx, meterX, meterY, meterW, meterH, 4);
        ctx.fillStyle = '#1a1a1a';
        ctx.fill();
        ctx.strokeStyle = '#333';
        ctx.lineWidth = 1;
        ctx.stroke();

        // Filled portion (bottom to top)
        if (pct > 0.01) {
            const fillH = meterH * pct;
            const fillY = meterY + meterH - fillH;

            ctx.save();
            this._roundRect(ctx, meterX + 1, fillY, meterW - 2, fillH, 3);
            ctx.clip();

            // Gradient based on style level
            const grad = ctx.createLinearGradient(meterX, meterY + meterH, meterX, meterY);
            grad.addColorStop(0, '#888');
            grad.addColorStop(0.2, '#FED90F');
            grad.addColorStop(0.4, '#FF8C00');
            grad.addColorStop(0.6, '#00e040');
            grad.addColorStop(0.8, '#FFD700');
            ctx.fillStyle = grad;
            ctx.fillRect(meterX + 1, fillY, meterW - 2, fillH);

            // Glossy highlight
            const shine = ctx.createLinearGradient(meterX, 0, meterX + meterW, 0);
            shine.addColorStop(0, 'rgba(255,255,255,0.25)');
            shine.addColorStop(0.5, 'rgba(255,255,255,0.05)');
            shine.addColorStop(1, 'rgba(0,0,0,0.1)');
            ctx.fillStyle = shine;
            ctx.fillRect(meterX + 1, fillY, meterW - 2, fillH);
            ctx.restore();

            // Pulsing glow for max level
            if (info.glow) {
                ctx.save();
                const glowAlpha = 0.3 + 0.3 * Math.sin(this.stylePulseTime * 6);
                ctx.shadowColor = '#FFD700';
                ctx.shadowBlur = 12 + 8 * Math.sin(this.stylePulseTime * 6);
                this._roundRect(ctx, meterX, fillY, meterW, fillH, 3);
                ctx.strokeStyle = `rgba(255, 215, 0, ${glowAlpha})`;
                ctx.lineWidth = 2;
                ctx.stroke();
                ctx.restore();
            }
        }
        ctx.restore();

        // Style label below meter
        ctx.save();
        ctx.font = 'bold 8px "Arial Black", Arial, sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'top';
        ctx.fillStyle = info.color;
        ctx.fillText(info.label, Math.round(meterX + meterW / 2), Math.round(meterY + meterH + 4), meterW + 20);
        ctx.restore();

        // Multiplier display
        if (info.multiplier > 1) {
            ctx.save();
            ctx.font = 'bold 10px "Arial Black", Arial, sans-serif';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'top';
            ctx.fillStyle = info.color;
            ctx.fillText(`x${info.multiplier}`, Math.round(meterX + meterW / 2), Math.round(meterY + meterH + 16));
            ctx.restore();
        }
    }

    _renderWaveProgress(ctx, W, waveInfo) {
        if (!waveInfo || waveInfo.total <= 0) return;

        const total = waveInfo.total;
        const dotR = 5;
        const spacing = 22;
        const totalW = (total - 1) * spacing;
        const startX = (W - totalW) / 2;
        const dotY = 16;

        // Subtle background
        ctx.save();
        this._roundRect(ctx, startX - 14, dotY - 10, totalW + 28, 20, 10);
        ctx.fillStyle = 'rgba(0, 0, 0, 0.4)';
        ctx.fill();
        ctx.restore();

        for (let i = 0; i < total; i++) {
            const cx = startX + i * spacing;
            const isCompleted = i < waveInfo.completed;
            const isCurrent = i === waveInfo.current;

            ctx.save();
            ctx.beginPath();
            ctx.arc(cx, dotY, dotR, 0, Math.PI * 2);

            if (isCompleted) {
                ctx.fillStyle = '#FED90F';
                ctx.fill();
            } else if (isCurrent) {
                // Pulsing current wave
                const pulse = 0.5 + 0.5 * Math.sin(this.stylePulseTime * 4);
                ctx.fillStyle = `rgba(254, 217, 15, ${0.3 + pulse * 0.4})`;
                ctx.fill();
                ctx.strokeStyle = '#FED90F';
                ctx.lineWidth = 2;
                ctx.stroke();

                // Outer pulse ring
                ctx.beginPath();
                ctx.arc(cx, dotY, dotR + 2 + pulse * 2, 0, Math.PI * 2);
                ctx.strokeStyle = `rgba(254, 217, 15, ${0.3 * (1 - pulse)})`;
                ctx.lineWidth = 1;
                ctx.stroke();
            } else {
                ctx.strokeStyle = 'rgba(255, 255, 255, 0.35)';
                ctx.lineWidth = 1.5;
                ctx.stroke();
            }

            ctx.restore();
        }

        // "WAVE" label
        ctx.save();
        ctx.font = 'bold 8px "Arial Black", Arial, sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'top';
        ctx.fillStyle = 'rgba(255,255,255,0.45)';
        ctx.fillText('WAVE', Math.round(W / 2), Math.round(dotY + 12));
        ctx.restore();
    }

    render(player, score, enemies = [], cameraX = 0, waveInfo = null) {
        const ctx = this.renderer.ctx;
        const W = this.renderer.width;
        ctx.imageSmoothingEnabled = true;

        // Smooth score tick-up
        if (this.displayedScore < score) {
            this.displayedScore += Math.max(1, Math.ceil((score - this.displayedScore) * 0.12));
            if (this.displayedScore > score) this.displayedScore = score;
        }

        // ── Style Meter (left side) ──
        this._renderStyleMeter(ctx);

        // ── Wave Progress (top center) ──
        this._renderWaveProgress(ctx, W, waveInfo);

        // ── HUD Panel (semi-transparent dark backdrop) ──
        ctx.save();
        this._roundRect(ctx, 42, 6, 250, 68, 10);
        ctx.fillStyle = 'rgba(0, 0, 0, 0.55)';
        ctx.fill();
        ctx.strokeStyle = 'rgba(254, 217, 15, 0.25)';
        ctx.lineWidth = 1.5;
        ctx.stroke();
        ctx.restore();

        // ── Player Icon ──
        this._drawPlayerIcon(ctx, 62, 32, 14);

        // ── "BRAWLER" label ──
        drawCrispText(ctx, 'BRAWLER', 82, 15, {
            font: 'bold 14px "Arial Black", Arial, sans-serif',
            color: '#FED90F',
            baseline: 'top',
            outline: true,
            outlineColor: '#222',
            outlineWidth: 3
        });

        // ── Health Bar ──
        const barX = 82;
        const barY = 32;
        const barW = 155;
        const barH = 16;
        const healthPct = Math.max(0, player.health / player.maxHealth);
        const radius = 6;

        // Dark inset background
        ctx.save();
        this._roundRect(ctx, barX - 1, barY - 1, barW + 2, barH + 2, radius + 1);
        ctx.fillStyle = '#1a0000';
        ctx.fill();
        ctx.strokeStyle = '#333';
        ctx.lineWidth = 1.5;
        ctx.stroke();

        // Gradient health fill
        if (healthPct > 0) {
            ctx.save();
            this._roundRect(ctx, barX, barY, barW * healthPct, barH, radius);
            ctx.clip();

            const grad = ctx.createLinearGradient(barX, barY, barX + barW, barY);
            grad.addColorStop(0, '#00e040');
            grad.addColorStop(0.5, '#c8e000');
            grad.addColorStop(1, '#ff2020');
            ctx.fillStyle = grad;
            ctx.fillRect(barX, barY, barW, barH);

            // Glossy highlight
            const shineGrad = ctx.createLinearGradient(barX, barY, barX, barY + barH);
            shineGrad.addColorStop(0, 'rgba(255,255,255,0.35)');
            shineGrad.addColorStop(0.5, 'rgba(255,255,255,0.05)');
            shineGrad.addColorStop(1, 'rgba(0,0,0,0.15)');
            ctx.fillStyle = shineGrad;
            ctx.fillRect(barX, barY, barW, barH);

            ctx.restore();
        }

        // Subtle glow on bar edge
        if (healthPct > 0) {
            ctx.save();
            const edgeX = barX + barW * healthPct;
            ctx.shadowColor = healthPct > 0.5 ? '#00ff40' : healthPct > 0.25 ? '#ffcc00' : '#ff3300';
            ctx.shadowBlur = 8;
            ctx.fillStyle = 'rgba(255,255,255,0.6)';
            ctx.fillRect(edgeX - 2, barY + 2, 2, barH - 4);
            ctx.restore();
        }

        ctx.restore(); // inset bg clip restore

        // Health text overlay
        drawCrispText(ctx, `${Math.ceil(player.health)} / ${player.maxHealth}`, Math.round(barX + barW / 2), Math.round(barY + barH / 2), {
            font: 'bold 12px "Arial Black", Arial, sans-serif',
            color: '#FFF',
            align: 'center',
            baseline: 'middle',
            outline: true,
            outlineColor: '#000',
            outlineWidth: 2.5
        });

        // ── Lives Display ──
        const livesY = 56;
        drawCrispText(ctx, 'LIVES', 82, Math.round(livesY), {
            font: 'bold 11px "Arial Black", Arial, sans-serif',
            color: '#aaa',
            baseline: 'top'
        });
        const lives = player.lives !== undefined ? player.lives : 3;
        for (let i = 0; i < lives; i++) {
            this._drawPlayerIcon(ctx, 132 + i * 24, livesY, 8);
        }

        // ── Score Panel (top-right) ──
        ctx.save();
        this._roundRect(ctx, W - 168, 6, 160, 56, 10);
        ctx.fillStyle = 'rgba(0, 0, 0, 0.55)';
        ctx.fill();
        ctx.strokeStyle = 'rgba(254, 217, 15, 0.25)';
        ctx.lineWidth = 1.5;
        ctx.stroke();
        ctx.restore();

        // Score label
        drawCrispText(ctx, 'SCORE', Math.round(W - 22), 14, {
            font: 'bold 12px "Arial Black", Arial, sans-serif',
            color: '#bbb',
            align: 'right',
            baseline: 'top',
            outline: true,
            outlineColor: '#222',
            outlineWidth: 2
        });

        // Score value
        const scoreStr = String(this.displayedScore).padStart(7, '0');
        drawCrispText(ctx, scoreStr, Math.round(W - 20), 30, {
            font: 'bold 28px "Arial Black", Arial, sans-serif',
            color: '#FED90F',
            align: 'right',
            baseline: 'top',
            outline: true,
            outlineColor: '#222',
            outlineWidth: 4
        });

        // ── Combo Counter ──
        const showCombo = player.comboCount > 1 || this.comboFadeOut > 0;
        if (showCombo && this.displayedCombo > 1) {
            const alpha = player.comboCount > 1 ? 1.0 : this.comboFadeOut;
            const combo = this.displayedCombo;

            let fillColor, strokeColor, glowColor;
            if (combo >= 5) {
                fillColor = `rgba(255, 60, 30, ${alpha})`;
                strokeColor = `rgba(80, 0, 0, ${alpha})`;
                glowColor = '#ff3300';
            } else if (combo >= 3) {
                fillColor = `rgba(255, 165, 0, ${alpha})`;
                strokeColor = `rgba(100, 50, 0, ${alpha})`;
                glowColor = '#ff8800';
            } else {
                fillColor = `rgba(254, 217, 15, ${alpha})`;
                strokeColor = `rgba(80, 60, 0, ${alpha})`;
                glowColor = '#FED90F';
            }

            const comboSizeBoost = Math.min(combo * 2, 16);
            const baseSize = 36 + comboSizeBoost;
            const fontSize = Math.round(baseSize * this.comboDisplayScale);
            const cx = this.renderer.width / 2;
            const cy = this.renderer.height / 2 - 60;

            ctx.save();
            ctx.globalAlpha = alpha;

            // Glow pulse effect
            const glowPulse = 8 + 6 * Math.sin(this.comboGlowTime * 8);
            ctx.shadowColor = glowColor;
            ctx.shadowBlur = glowPulse;

            ctx.font = `bold ${fontSize}px "Arial Black", Arial, sans-serif`;
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';

            const rcx = Math.round(cx);
            const rcy = Math.round(cy);
            ctx.lineWidth = 5;
            ctx.strokeStyle = strokeColor;
            ctx.strokeText(`${combo} HIT COMBO!`, rcx, rcy);
            ctx.fillStyle = fillColor;
            ctx.fillText(`${combo} HIT COMBO!`, rcx, rcy);

            // Style-based multiplier
            ctx.shadowBlur = glowPulse * 0.5;
            const styleInfo = this._getStyleInfo(this.styleLevel);
            const multiplier = styleInfo.multiplier;
            const multSize = Math.round(22 * this.comboDisplayScale);
            ctx.font = `bold ${multSize}px "Arial Black", Arial, sans-serif`;
            ctx.strokeStyle = strokeColor;
            ctx.lineWidth = 3;
            ctx.strokeText(`x${multiplier}`, rcx, Math.round(rcy + fontSize * 0.7));
            ctx.fillStyle = fillColor;
            ctx.fillText(`x${multiplier}`, rcx, Math.round(rcy + fontSize * 0.7));

            ctx.restore();
            ctx.textAlign = 'left';
            ctx.textBaseline = 'alphabetic';
        }

        // ── Boss Health Bar ──
        const boss = enemies.find(enemy => enemy && enemy.variant === 'boss' && enemy.state !== 'dead');
        if (boss) {
            const bossPct = Math.max(0, boss.health / boss.maxHealth);
            const barW = W - 80;
            const barH = 18;
            const barX = 40;
            const barY = this.renderer.height - 34;

            ctx.save();
            this._roundRect(ctx, barX - 2, barY - 2, barW + 4, barH + 4, 8);
            ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
            ctx.fill();
            ctx.strokeStyle = 'rgba(255, 180, 100, 0.35)';
            ctx.lineWidth = 2;
            ctx.stroke();

            if (bossPct > 0) {
                ctx.save();
                this._roundRect(ctx, barX, barY, barW * bossPct, barH, 7);
                ctx.clip();
                const bossGrad = ctx.createLinearGradient(barX, barY, barX + barW, barY);
                bossGrad.addColorStop(0, '#ff8a00');
                bossGrad.addColorStop(0.5, '#ff4b2b');
                bossGrad.addColorStop(1, '#b00020');
                ctx.fillStyle = bossGrad;
                ctx.fillRect(barX, barY, barW, barH);
                ctx.restore();
            }

            drawCrispText(ctx, 'BRUISER', Math.round(barX + 8), Math.round(barY + barH / 2), {
                font: 'bold 12px "Arial Black", Arial, sans-serif',
                color: '#FFF',
                baseline: 'middle',
                outline: true,
                outlineColor: '#000',
                outlineWidth: 3
            });
            drawCrispText(ctx, `${Math.ceil(boss.health)} / ${boss.maxHealth}`, Math.round(barX + barW - 8), Math.round(barY + barH / 2), {
                font: 'bold 12px "Arial Black", Arial, sans-serif',
                color: '#FFF',
                align: 'right',
                baseline: 'middle',
                outline: true,
                outlineColor: '#000',
                outlineWidth: 3
            });
            ctx.restore();
        }

        // ── Enemy Health Bars ──
        for (const enemy of enemies) {
            if (!enemy || enemy.state === 'dead') continue;
            if (enemy.variant === 'boss') continue;
            if (enemy.health >= enemy.maxHealth) continue;

            const ePct = Math.max(0, enemy.health / enemy.maxHealth);
            const barEW = 34;
            const barEH = 5;
            const bx = Math.round(enemy.x + enemy.width / 2 - barEW / 2 - cameraX);
            const by = Math.round(enemy.y - 12);

            // Dark bg with rounded ends
            ctx.save();
            this._roundRect(ctx, bx, by, barEW, barEH, 2);
            ctx.fillStyle = '#1a0000';
            ctx.fill();

            // Health fill
            if (ePct > 0) {
                ctx.save();
                this._roundRect(ctx, bx, by, barEW * ePct, barEH, 2);
                ctx.clip();
                const eGrad = ctx.createLinearGradient(bx, by, bx + barEW, by);
                eGrad.addColorStop(0, '#00e040');
                eGrad.addColorStop(1, '#ff2020');
                ctx.fillStyle = eGrad;
                ctx.fillRect(bx, by, barEW, barEH);
                ctx.restore();
            }

            ctx.strokeStyle = 'rgba(255,255,255,0.3)';
            ctx.lineWidth = 0.8;
            this._roundRect(ctx, bx, by, barEW, barEH, 2);
            ctx.stroke();
            ctx.restore();
        }
    }
}
