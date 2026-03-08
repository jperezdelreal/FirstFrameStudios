// ==========================================================================
// Environmental Hazards — AAA-L3
// ==========================================================================
// Hazards that damage BOTH player and enemies. Strategic play: throw enemies
// into hazards for bonus damage and score.
//
// INTEGRATION (gameplay.js — do NOT add here, Solo owns that file):
//   1. Import: import { Hazard, HAZARD_TYPES } from '../entities/hazard.js';
//   2. On wave/level init, create instances from LEVEL_1.hazards:
//        const hazards = LEVEL_1.hazards.map(h =>
//            new Hazard(h.x, h.y, h.type));
//   3. In update loop:
//        hazards.forEach(h => h.update(dt));
//   4. Damage check (run every frame for player AND each enemy):
//        hazards.forEach(h => {
//            const result = h.checkDamage(entity);
//            if (result) {
//                entity.health -= result.damage;
//                entity.hitstunTime = 0.2;
//                if (result.knockback) {
//                    entity.knockbackVx = result.knockback.vx;
//                    entity.knockbackVy = result.knockback.vy;
//                }
//                if (result.scoreBonus) score += result.scoreBonus;
//            }
//        });
//   5. Throw bonus — when an enemy lands in a hazard after being thrown:
//        hazards.forEach(h => {
//            if (h.isInside(enemy) && enemy.wasThrown) {
//                enemy.health -= h.throwBonusDamage;
//                score += h.throwBonusScore;
//            }
//        });
//   6. In render loop (call BEFORE entities for proper layering):
//        hazards.forEach(h => h.render(ctx, cameraX));
// ==========================================================================

// ---------------------------------------------------------------------------
// Hazard type definitions
// ---------------------------------------------------------------------------

export const HAZARD_TYPES = {
    steamVent: {
        radius: 30,
        damage: 3,
        interval: 2.0,   // seconds between bursts
        activeDuration: 0.8,
        color: '#B0BEC5',
        glowColor: 'rgba(255,255,255,0.4)',
        label: 'Steam Vent',
        throwBonusDamage: 10,
        throwBonusScore: 200
    },
    radioactiveBarrel: {
        radius: 36,
        damage: 2,
        interval: 0,     // 0 = constant damage (ticks every 0.5s)
        activeDuration: 0,
        color: '#76FF03',
        glowColor: 'rgba(118,255,3,0.3)',
        label: 'Radioactive Barrel',
        throwBonusDamage: 15,
        throwBonusScore: 300
    },
    manhole: {
        radius: 28,
        damage: 5,
        interval: 5.0,   // knockback burst every 5s
        activeDuration: 0.3,
        color: '#5D4037',
        glowColor: 'rgba(255,152,0,0.4)',
        label: 'Manhole',
        knockbackForce: 250,
        throwBonusDamage: 12,
        throwBonusScore: 250
    }
};

// ---------------------------------------------------------------------------
// Hazard entity
// ---------------------------------------------------------------------------

export class Hazard {
    constructor(x, y, type) {
        const config = HAZARD_TYPES[type] || HAZARD_TYPES.steamVent;
        this.x = x;
        this.y = y;
        this.radius = config.radius;
        this.type = type;
        this.damage = config.damage;
        this.interval = config.interval;
        this.activeDuration = config.activeDuration;
        this.color = config.color;
        this.glowColor = config.glowColor;
        this.knockbackForce = config.knockbackForce || 0;
        this.throwBonusDamage = config.throwBonusDamage;
        this.throwBonusScore = config.throwBonusScore;

        // State
        this.timer = 0;
        this.active = type === 'radioactiveBarrel'; // constant types start active
        this.pulseTime = 0;

        // Per-entity damage cooldown to prevent per-frame damage stacking
        this._damageCooldowns = new Map();
        this._damageCooldownDuration = type === 'radioactiveBarrel' ? 0.5 : 0;
    }

    update(dt) {
        this.pulseTime += dt;

        // Decrement per-entity cooldowns
        for (const [id, t] of this._damageCooldowns) {
            const newT = t - dt;
            if (newT <= 0) this._damageCooldowns.delete(id);
            else this._damageCooldowns.set(id, newT);
        }

        if (this.type === 'radioactiveBarrel') {
            // Always active — damage is cooldown-gated
            this.active = true;
            return;
        }

        // Periodic hazards
        this.timer += dt;
        if (!this.active && this.timer >= this.interval) {
            this.active = true;
            this.timer = 0;
        }
        if (this.active && this.timer >= this.activeDuration) {
            this.active = false;
            this.timer = 0;
        }
    }

    isInside(entity) {
        const cx = entity.x + (entity.width || 0) / 2;
        const cy = entity.y + (entity.height || 0) / 2;
        const dx = cx - this.x;
        const dy = cy - this.y;
        return (dx * dx + dy * dy) <= (this.radius * this.radius);
    }

    // Returns { damage, knockback?, scoreBonus? } or null
    checkDamage(entity) {
        if (!this.active) return null;
        if (!this.isInside(entity)) return null;

        // Per-entity cooldown check (use object reference as key)
        const id = entity;
        if (this._damageCooldowns.has(id)) return null;
        if (this._damageCooldownDuration > 0) {
            this._damageCooldowns.set(id, this._damageCooldownDuration);
        }

        const result = { damage: this.damage };

        // Manhole knockback burst
        if (this.type === 'manhole' && this.knockbackForce > 0) {
            const cx = entity.x + (entity.width || 0) / 2;
            const cy = entity.y + (entity.height || 0) / 2;
            const dx = cx - this.x;
            const dy = cy - this.y;
            const dist = Math.sqrt(dx * dx + dy * dy) || 1;
            result.knockback = {
                vx: (dx / dist) * this.knockbackForce,
                vy: (dy / dist) * this.knockbackForce
            };
        }

        return result;
    }

    render(ctx, cameraX) {
        const sx = this.x - cameraX;
        const pulseScale = 1 + 0.05 * Math.sin(this.pulseTime * 4);

        ctx.save();

        // Glow ring when active
        if (this.active) {
            const glowRadius = this.radius * pulseScale * 1.3;
            const grad = ctx.createRadialGradient(sx, this.y, 0, sx, this.y, glowRadius);
            grad.addColorStop(0, this.glowColor);
            grad.addColorStop(1, 'rgba(0,0,0,0)');
            ctx.fillStyle = grad;
            ctx.beginPath();
            ctx.arc(sx, this.y, glowRadius, 0, Math.PI * 2);
            ctx.fill();
        }

        // Type-specific rendering
        switch (this.type) {
            case 'steamVent':
                this._renderSteamVent(ctx, sx);
                break;
            case 'radioactiveBarrel':
                this._renderRadioactiveBarrel(ctx, sx);
                break;
            case 'manhole':
                this._renderManhole(ctx, sx);
                break;
        }

        ctx.restore();
    }

    _renderSteamVent(ctx, sx) {
        // Metal grate
        ctx.fillStyle = '#78909C';
        ctx.beginPath();
        ctx.ellipse(sx, this.y, this.radius * 0.8, this.radius * 0.5, 0, 0, Math.PI * 2);
        ctx.fill();
        // Grate lines
        ctx.strokeStyle = '#546E7A';
        ctx.lineWidth = 2;
        for (let i = -2; i <= 2; i++) {
            const offset = i * 8;
            ctx.beginPath();
            ctx.moveTo(sx + offset, this.y - this.radius * 0.4);
            ctx.lineTo(sx + offset, this.y + this.radius * 0.4);
            ctx.stroke();
        }
        // Steam particles when active
        if (this.active) {
            ctx.globalAlpha = 0.5 + 0.3 * Math.sin(this.pulseTime * 10);
            for (let i = 0; i < 5; i++) {
                const px = sx + (Math.random() - 0.5) * this.radius;
                const py = this.y - 10 - Math.random() * 30;
                ctx.fillStyle = 'rgba(255,255,255,0.6)';
                ctx.beginPath();
                ctx.arc(px, py, 3 + Math.random() * 4, 0, Math.PI * 2);
                ctx.fill();
            }
            ctx.globalAlpha = 1;
        }
    }

    _renderRadioactiveBarrel(ctx, sx) {
        // Barrel body
        ctx.fillStyle = '#4E342E';
        ctx.fillRect(sx - 14, this.y - 20, 28, 40);
        // Barrel bands
        ctx.fillStyle = '#3E2723';
        ctx.fillRect(sx - 15, this.y - 20, 30, 3);
        ctx.fillRect(sx - 15, this.y + 17, 30, 3);
        // Radiation symbol (simplified triangle)
        ctx.fillStyle = this.color;
        ctx.beginPath();
        ctx.arc(sx, this.y, 8, 0, Math.PI * 2);
        ctx.fill();
        // Inner dot
        ctx.fillStyle = '#4E342E';
        ctx.beginPath();
        ctx.arc(sx, this.y, 3, 0, Math.PI * 2);
        ctx.fill();
        // Green glow puddle
        const glowAlpha = 0.3 + 0.15 * Math.sin(this.pulseTime * 3);
        ctx.fillStyle = `rgba(118,255,3,${glowAlpha})`;
        ctx.beginPath();
        ctx.ellipse(sx, this.y + 22, this.radius * 0.9, this.radius * 0.4, 0, 0, Math.PI * 2);
        ctx.fill();
    }

    _renderManhole(ctx, sx) {
        // Manhole cover
        ctx.fillStyle = this.color;
        ctx.beginPath();
        ctx.arc(sx, this.y, this.radius, 0, Math.PI * 2);
        ctx.fill();
        // Inner ring
        ctx.strokeStyle = '#3E2723';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.arc(sx, this.y, this.radius * 0.7, 0, Math.PI * 2);
        ctx.stroke();
        // Cross pattern
        ctx.beginPath();
        ctx.moveTo(sx - this.radius * 0.5, this.y);
        ctx.lineTo(sx + this.radius * 0.5, this.y);
        ctx.moveTo(sx, this.y - this.radius * 0.5);
        ctx.lineTo(sx, this.y + this.radius * 0.5);
        ctx.stroke();
        // Burst effect when active
        if (this.active) {
            ctx.strokeStyle = '#FF9800';
            ctx.lineWidth = 3;
            const burstRadius = this.radius * (1 + 0.5 * (this.timer / this.activeDuration));
            ctx.globalAlpha = 1 - (this.timer / this.activeDuration);
            ctx.beginPath();
            ctx.arc(sx, this.y, burstRadius, 0, Math.PI * 2);
            ctx.stroke();
            ctx.globalAlpha = 1;
        }
    }
}
