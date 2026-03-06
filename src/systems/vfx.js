/**
 * VFX System — SimpsonsKong
 * Owner: Boba (VFX/Art Specialist)
 *
 * INTEGRATION INSTRUCTIONS (for whoever owns gameplay.js — currently Chewie):
 * ──────────────────────────────────────────────────────────────────────────
 * 1. Import:
 *      import { vfx, VFX } from '../systems/vfx.js';
 *
 * 2. In the update loop, call:
 *      vfx.update(dt);
 *
 * 3. In the render loop, AFTER entity rendering, call:
 *      vfx.render(ctx);
 *
 * 4. When a hit lands (in combat resolution), call:
 *      import { VFX } from '../systems/vfx.js';
 *      // Punch hit:
 *      vfx.addEffect(VFX.createHitEffect(hitX, hitY, 'light'));
 *      // Kick hit:
 *      vfx.addEffect(VFX.createHitEffect(hitX, hitY, 'medium'));
 *      // Combo finisher:
 *      vfx.addEffect(VFX.createHitEffect(hitX, hitY, 'heavy'));
 *      // KO:
 *      vfx.addEffect(VFX.createKOEffect(hitX, hitY));
 *
 * 5. For ground shadows, call the static method directly in entity render:
 *      VFX.drawShadow(ctx, entity.x, entity.y, entity.width, entity.height, jumpHeight);
 *
 * MIGRATION NOTE:
 *   player.js already draws its own shadow in its render method.
 *   When ready, replace that inline shadow with VFX.drawShadow() for consistency.
 *   Same for enemy.js. Do NOT modify those files this wave (Lando/Tarkin own them).
 * ──────────────────────────────────────────────────────────────────────────
 */

// --- Art direction constants (from .squad/analysis/art-direction.md) ---
const HIT_WHITE  = '#FFFFEE';
const HIT_YELLOW = '#FFD700';
const KO_STARS   = '#FFEC8B';

const INTENSITY_RADIUS = {
    light:  20,   // punch
    medium: 30,   // kick
    heavy:  40,   // combo finisher
};

const HIT_LIFETIME   = 0.1;   // 100ms (~6 frames at 60fps)
const KO_LIFETIME    = 0.25;  // 250ms — larger, more dramatic
const RAY_COUNT      = 6;     // starburst ray count
const KO_STAR_COUNT  = 5;     // orbiting star particles

// ─────────────────────────────────────────────────────────────────────────

export class VFX {
    constructor() {
        /** @type {Array<{lifetime: number, maxLifetime: number, x: number, y: number, render: function}>} */
        this.effects = [];
    }

    // ── Static: Ground Shadow ────────────────────────────────────────────

    /**
     * Draw an oval shadow under an entity for 2.5D depth readability.
     * Call this directly — no VFX instance needed.
     *
     * @param {CanvasRenderingContext2D} ctx
     * @param {number} x        Entity left edge
     * @param {number} y        Entity top edge
     * @param {number} width    Entity width
     * @param {number} height   Entity height
     * @param {number} [jumpHeight=0]  How high above ground (shrinks/fades shadow)
     */
    static drawShadow(ctx, x, y, width, height, jumpHeight = 0) {
        const scale = Math.max(0.3, 1 - (jumpHeight / 300) * 0.5);
        const alpha = 0.3 * scale;

        ctx.save();
        ctx.fillStyle = `rgba(0, 0, 0, ${alpha})`;
        ctx.beginPath();
        ctx.ellipse(
            x + width / 2,
            y + height - 5,
            (width / 2) * scale,
            8 * scale,
            0, 0, Math.PI * 2
        );
        ctx.fill();
        ctx.restore();
    }

    // ── Static: Effect Factories ─────────────────────────────────────────

    /**
     * Create a starburst/flash hit effect.
     *
     * @param {number} x  Center X of impact
     * @param {number} y  Center Y of impact
     * @param {'light'|'medium'|'heavy'} intensity
     * @returns {object}  Effect object to pass to vfx.addEffect()
     */
    static createHitEffect(x, y, intensity = 'light') {
        const radius = INTENSITY_RADIUS[intensity] || INTENSITY_RADIUS.light;
        const maxLifetime = HIT_LIFETIME;

        // Pre-compute random ray angles so they stay stable across frames
        const angles = [];
        for (let i = 0; i < RAY_COUNT; i++) {
            angles.push((Math.PI * 2 * i) / RAY_COUNT + (Math.random() - 0.5) * 0.3);
        }

        return {
            x,
            y,
            lifetime: maxLifetime,
            maxLifetime,
            render(ctx, progress) {
                // progress: 0 → 1 (0 = just spawned, 1 = about to expire)
                const scale = 0.3 + progress * 0.7;       // grow from 30% to 100%
                const alpha = 1 - progress * progress;     // ease-out fade
                const r = radius * scale;

                ctx.save();
                ctx.globalAlpha = alpha;
                ctx.lineCap = 'round';

                // Center flash circle
                ctx.fillStyle = HIT_WHITE;
                ctx.beginPath();
                ctx.arc(x, y, r * 0.25, 0, Math.PI * 2);
                ctx.fill();

                // Radiating rays
                ctx.strokeStyle = HIT_YELLOW;
                ctx.lineWidth = 2;
                for (const angle of angles) {
                    const innerR = r * 0.3;
                    const outerR = r;
                    ctx.beginPath();
                    ctx.moveTo(
                        x + Math.cos(angle) * innerR,
                        y + Math.sin(angle) * innerR
                    );
                    ctx.lineTo(
                        x + Math.cos(angle) * outerR,
                        y + Math.sin(angle) * outerR
                    );
                    ctx.stroke();
                }

                ctx.restore();
            },
        };
    }

    /**
     * Create a KO effect — larger starburst with orbiting star particles.
     *
     * @param {number} x  Center X
     * @param {number} y  Center Y
     * @returns {object}  Effect object to pass to vfx.addEffect()
     */
    static createKOEffect(x, y) {
        const maxLifetime = KO_LIFETIME;
        const radius = 50;

        // Pre-compute ray angles
        const angles = [];
        for (let i = 0; i < RAY_COUNT + 2; i++) {
            angles.push((Math.PI * 2 * i) / (RAY_COUNT + 2));
        }

        // Pre-compute star starting angles and radii
        const stars = [];
        for (let i = 0; i < KO_STAR_COUNT; i++) {
            stars.push({
                angle: (Math.PI * 2 * i) / KO_STAR_COUNT,
                speed: 1.5 + Math.random() * 1.5,   // radians per second
                dist: 0.5 + Math.random() * 0.3,     // fraction of radius
                size: 3 + Math.random() * 2,
            });
        }

        return {
            x,
            y,
            lifetime: maxLifetime,
            maxLifetime,
            render(ctx, progress) {
                const scale = 0.2 + progress * 0.8;
                const alpha = 1 - progress * progress;
                const r = radius * scale;

                ctx.save();
                ctx.globalAlpha = alpha;
                ctx.lineCap = 'round';

                // Center flash — bigger than hit effect
                ctx.fillStyle = HIT_WHITE;
                ctx.beginPath();
                ctx.arc(x, y, r * 0.3, 0, Math.PI * 2);
                ctx.fill();

                // Radiating rays (thicker)
                ctx.strokeStyle = HIT_YELLOW;
                ctx.lineWidth = 3;
                for (const angle of angles) {
                    ctx.beginPath();
                    ctx.moveTo(
                        x + Math.cos(angle) * r * 0.35,
                        y + Math.sin(angle) * r * 0.35
                    );
                    ctx.lineTo(
                        x + Math.cos(angle) * r,
                        y + Math.sin(angle) * r
                    );
                    ctx.stroke();
                }

                // Orbiting star particles
                const elapsed = (1 - progress) * maxLifetime; // time since spawn
                ctx.fillStyle = KO_STARS;
                for (const star of stars) {
                    const a = star.angle + elapsed * star.speed * Math.PI * 2;
                    const d = r * star.dist * (1 + progress * 0.8); // expand outward
                    const sx = x + Math.cos(a) * d;
                    const sy = y + Math.sin(a) * d;

                    // Draw a four-point star shape
                    const s = star.size * alpha;
                    ctx.beginPath();
                    ctx.moveTo(sx, sy - s);
                    ctx.lineTo(sx + s * 0.3, sy - s * 0.3);
                    ctx.lineTo(sx + s, sy);
                    ctx.lineTo(sx + s * 0.3, sy + s * 0.3);
                    ctx.lineTo(sx, sy + s);
                    ctx.lineTo(sx - s * 0.3, sy + s * 0.3);
                    ctx.lineTo(sx - s, sy);
                    ctx.lineTo(sx - s * 0.3, sy - s * 0.3);
                    ctx.closePath();
                    ctx.fill();
                }

                ctx.restore();
            },
        };
    }

    // ── Instance Methods ─────────────────────────────────────────────────

    /**
     * Add an effect to the active effects list.
     * @param {object} effect  Object from createHitEffect / createKOEffect
     */
    addEffect(effect) {
        this.effects.push(effect);
    }

    /**
     * Update all active effects. Call once per frame.
     * @param {number} dt  Delta time in seconds
     */
    update(dt) {
        for (let i = this.effects.length - 1; i >= 0; i--) {
            this.effects[i].lifetime -= dt;
            if (this.effects[i].lifetime <= 0) {
                this.effects.splice(i, 1);
            }
        }
    }

    /**
     * Render all active effects. Call AFTER entity rendering so effects draw on top.
     * @param {CanvasRenderingContext2D} ctx
     */
    render(ctx) {
        for (const effect of this.effects) {
            const progress = 1 - (effect.lifetime / effect.maxLifetime);
            effect.render(ctx, progress);
        }
    }
}

// Singleton instance for game-wide use
export const vfx = new VFX();
