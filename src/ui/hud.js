export class HUD {
    constructor(renderer) {
        this.renderer = renderer;

        // Combo display state
        this.prevComboCount = 0;
        this.comboDisplayScale = 1.0;
        this.comboScaleTimer = 0;
        this.comboFadeOut = 0;       // 1.0 → 0.0 fade when combo drops
        this.displayedCombo = 0;     // what we're currently showing (for fade-out)
    }

    update(dt, player) {
        const current = player.comboCount;

        if (current > this.prevComboCount && current > 1) {
            // Combo grew — pop effect
            this.comboDisplayScale = 1.5;
            this.comboScaleTimer = 0.2;
            this.comboFadeOut = 1.0;
            this.displayedCombo = current;
        } else if (current <= 1 && this.prevComboCount > 1) {
            // Combo just reset — start fade-out
            this.comboFadeOut = 1.0;
        }

        // Lerp scale back to 1.0
        if (this.comboScaleTimer > 0) {
            this.comboScaleTimer -= dt;
            const t = Math.max(0, this.comboScaleTimer / 0.2);
            this.comboDisplayScale = 1.0 + 0.5 * t;
        } else {
            this.comboDisplayScale = 1.0;
        }

        // Fade out when combo is inactive
        if (current <= 1 && this.comboFadeOut > 0) {
            this.comboFadeOut -= dt * 4; // fade over ~0.25s
            if (this.comboFadeOut < 0) this.comboFadeOut = 0;
        }

        if (current > 1) {
            this.displayedCombo = current;
        }

        this.prevComboCount = current;
    }

    render(player, score, enemies = [], cameraX = 0) {
        const ctx = this.renderer.ctx;
        
        // Player health bar (top-left)
        const barWidth = 200;
        const barHeight = 30;
        const barX = 20;
        const barY = 20;
        
        // Label
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 18px Arial';
        ctx.fillText('HOMER', barX, barY - 5);
        
        // Background (red)
        ctx.fillStyle = '#8B0000';
        ctx.fillRect(barX, barY, barWidth, barHeight);
        
        // Health (green)
        const healthPercent = player.health / player.maxHealth;
        ctx.fillStyle = healthPercent > 0.3 ? '#00FF00' : '#FFA500';
        ctx.fillRect(barX, barY, barWidth * healthPercent, barHeight);
        
        // Border
        ctx.strokeStyle = '#FFFFFF';
        ctx.lineWidth = 3;
        ctx.strokeRect(barX, barY, barWidth, barHeight);
        
        // Health text
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 16px Arial';
        ctx.textAlign = 'center';
        ctx.fillText(`${Math.ceil(player.health)} / ${player.maxHealth}`, barX + barWidth / 2, barY + 20);
        ctx.textAlign = 'left';
        
        // Score (top-right)
        ctx.fillStyle = '#FFFFFF';
        ctx.font = 'bold 28px Arial';
        ctx.textAlign = 'right';
        ctx.fillText(`SCORE: ${score}`, this.renderer.width - 20, 35);
        ctx.textAlign = 'left';

        // Combo counter (center screen, above middle)
        const showCombo = player.comboCount > 1 || this.comboFadeOut > 0;
        if (showCombo && this.displayedCombo > 1) {
            const alpha = player.comboCount > 1 ? 1.0 : this.comboFadeOut;
            const combo = this.displayedCombo;

            // Color shifts: yellow (2) → orange (3-4) → red (5+)
            let fillColor, strokeColor;
            if (combo >= 5) {
                fillColor = `rgba(255, 60, 30, ${alpha})`;
                strokeColor = `rgba(80, 0, 0, ${alpha})`;
            } else if (combo >= 3) {
                fillColor = `rgba(255, 165, 0, ${alpha})`;
                strokeColor = `rgba(100, 50, 0, ${alpha})`;
            } else {
                fillColor = `rgba(254, 217, 15, ${alpha})`;
                strokeColor = `rgba(80, 60, 0, ${alpha})`;
            }

            // Scale grows with combo count — bigger combos = bigger text
            const comboSizeBoost = Math.min(combo * 2, 16);
            const baseSize = 36 + comboSizeBoost;
            const fontSize = Math.round(baseSize * this.comboDisplayScale);
            const cx = this.renderer.width / 2;
            const cy = this.renderer.height / 2 - 60;

            ctx.save();
            ctx.globalAlpha = alpha;
            ctx.font = `bold ${fontSize}px Arial`;
            ctx.textAlign = 'center';
            ctx.textBaseline = 'middle';

            // Dark outline
            ctx.lineWidth = 5;
            ctx.strokeStyle = strokeColor;
            ctx.strokeText(`${combo} HIT COMBO!`, cx, cy);

            // Fill
            ctx.fillStyle = fillColor;
            ctx.fillText(`${combo} HIT COMBO!`, cx, cy);

            // Damage multiplier below
            const multiplier = Math.min(2, 1 + (combo * 0.1));
            const multSize = Math.round(22 * this.comboDisplayScale);
            ctx.font = `bold ${multSize}px Arial`;
            ctx.strokeStyle = strokeColor;
            ctx.lineWidth = 3;
            ctx.strokeText(`x${multiplier.toFixed(1)}`, cx, cy + fontSize * 0.7);
            ctx.fillStyle = fillColor;
            ctx.fillText(`x${multiplier.toFixed(1)}`, cx, cy + fontSize * 0.7);

            ctx.restore();
            // Reset alignment for other draw calls
            ctx.textAlign = 'left';
            ctx.textBaseline = 'alphabetic';
        }

        // Enemy health bars (only for damaged enemies)
        for (const enemy of enemies) {
            if (!enemy || enemy.state === 'dead') continue;
            if (enemy.health >= enemy.maxHealth) continue;

            const healthPct = Math.max(0, enemy.health / enemy.maxHealth);
            const barW = 30;
            const barH = 4;
            const bx = enemy.x + enemy.width / 2 - barW / 2 - cameraX;
            const by = enemy.y - 10;

            // Red background
            ctx.fillStyle = '#8B0000';
            ctx.fillRect(bx, by, barW, barH);

            // Green fill
            ctx.fillStyle = '#00FF00';
            ctx.fillRect(bx, by, barW * healthPct, barH);

            // Thin border
            ctx.strokeStyle = '#000000';
            ctx.lineWidth = 1;
            ctx.strokeRect(bx, by, barW, barH);
        }
    }
}
