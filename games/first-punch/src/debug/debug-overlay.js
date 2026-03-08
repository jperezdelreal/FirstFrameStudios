// INTEGRATION: In gameplay.js:
// import { DebugOverlay } from '../debug/debug-overlay.js';
// constructor: this.debug = new DebugOverlay();
// update(): this.debug.update(dt, this.player, this.enemies, this.vfx);
// render() at END: this.debug.render(this.renderer.ctx, this.renderer.cameraX, this.player, this.enemies, this.vfx);

export class DebugOverlay {
    constructor() {
        this.enabled = false;
        this.fps = 0;
        this.frameCount = 0;
        this.fpsTimer = 0;
        this.entityCount = 0;
        this.lastDt = 0;
        this.frameTime = 0;
        this.vfxCount = 0;
        this.collisionChecksPerFrame = 0;

        this._onKeyDown = (e) => {
            if (e.key === '`') {
                this.enabled = !this.enabled;
            }
        };
        window.addEventListener('keydown', this._onKeyDown);
    }

    destroy() {
        window.removeEventListener('keydown', this._onKeyDown);
    }

    update(dt, player, enemies, vfx) {
        if (!this.enabled) return;

        this.frameCount++;
        this.fpsTimer += dt;
        this.lastDt = dt;
        this.frameTime = dt * 1000; // Convert to milliseconds
        
        if (this.fpsTimer >= 1.0) {
            this.fps = this.frameCount;
            this.frameCount = 0;
            this.fpsTimer -= 1.0;
        }

        this.entityCount = 1 + (enemies ? enemies.filter(e => e.state !== 'dead').length : 0);
        this.vfxCount = vfx ? vfx.effects.length : 0;
        
        // Estimate collision checks: player checks all living enemies
        const livingEnemies = enemies ? enemies.filter(e => e.state !== 'dead').length : 0;
        this.collisionChecksPerFrame = Math.max(0, livingEnemies);
    }

    render(ctx, cameraX, player, enemies, vfx) {
        if (!this.enabled) return;

        ctx.save();

        // --- World-space overlays (affected by camera) ---
        this._drawEntityOverlay(ctx, player, 'PLAYER');
        if (enemies) {
            for (const enemy of enemies) {
                if (enemy.state === 'dead') continue;
                const label = enemy.variant === 'normal' ? 'ENEMY' : `ENEMY (${enemy.variant})`;
                this._drawEntityOverlay(ctx, enemy, label);
            }
        }

        // --- Screen-space HUD (draw after restoring camera) ---
        ctx.restore();
        ctx.save();

        // Performance metrics — top-right
        ctx.font = 'bold 14px monospace';
        ctx.textAlign = 'right';
        ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
        
        // Calculate panel height based on content
        const panelHeight = 110;
        const cw = ctx.canvas.logicalWidth || ctx.canvas.width;
        ctx.fillRect(cw - 200, 4, 196, panelHeight);
        
        // FPS counter (color coded)
        ctx.fillStyle = this.fps < 50 ? '#FF4444' : '#44FF44';
        ctx.fillText(`FPS: ${this.fps}`, cw - 12, 20);
        
        // Frame time in ms
        ctx.fillStyle = '#FFFF44';
        ctx.fillText(`Frame: ${this.frameTime.toFixed(1)}ms`, cw - 12, 38);
        
        // Entity count
        ctx.fillStyle = '#FFFFFF';
        ctx.fillText(`Entities: ${this.entityCount}`, cw - 12, 56);
        
        // VFX count
        ctx.fillStyle = '#FF88FF';
        ctx.fillText(`VFX: ${this.vfxCount}`, cw - 12, 74);
        
        // Collision checks estimate
        ctx.fillStyle = '#88CCFF';
        ctx.fillText(`Collisions: ${this.collisionChecksPerFrame}`, cw - 12, 92);

        // Combo count (if exists on player)
        if (player && typeof player.comboCount === 'number') {
            ctx.fillStyle = '#FFD700';
            ctx.fillText(`Combo: ${player.comboCount}`, cw - 12, 110);
        }

        ctx.restore();
    }

    _drawEntityOverlay(ctx, entity, label) {
        if (!entity) return;

        // Hurtbox (green)
        const hurtbox = entity.getHurtbox();
        if (hurtbox) {
            ctx.strokeStyle = 'rgba(0, 255, 0, 0.7)';
            ctx.lineWidth = 2;
            ctx.strokeRect(hurtbox.x, hurtbox.y, hurtbox.width, hurtbox.height);

            // Semi-transparent fill
            ctx.fillStyle = 'rgba(0, 255, 0, 0.1)';
            ctx.fillRect(hurtbox.x, hurtbox.y, hurtbox.width, hurtbox.height);
        }

        // Attack hitbox (red)
        const attackBox = entity.getAttackHitbox();
        if (attackBox) {
            ctx.strokeStyle = 'rgba(255, 0, 0, 0.8)';
            ctx.lineWidth = 2;
            ctx.strokeRect(attackBox.x, attackBox.y, attackBox.width, attackBox.height);

            ctx.fillStyle = 'rgba(255, 0, 0, 0.2)';
            ctx.fillRect(attackBox.x, attackBox.y, attackBox.width, attackBox.height);
        }

        // State label above entity
        const labelX = entity.x + (entity.width / 2);
        const labelY = entity.y - 12 - (entity.jumpHeight || 0);

        ctx.font = 'bold 11px monospace';
        ctx.textAlign = 'center';

        // Background for text readability
        const stateText = `${label}: ${entity.state}`;
        const textWidth = ctx.measureText(stateText).width;
        ctx.fillStyle = 'rgba(0, 0, 0, 0.6)';
        ctx.fillRect(labelX - textWidth / 2 - 3, labelY - 10, textWidth + 6, 14);

        ctx.fillStyle = '#FFFFFF';
        ctx.fillText(stateText, labelX, labelY);
    }
}
