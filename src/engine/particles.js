/**
 * Particle System — SimpsonsKong
 * Owner: Chewie (Engine Dev)
 *
 * Generic particle emitter for dust clouds, hit sparks, death debris, etc.
 * Each particle: { x, y, vx, vy, life, maxLife, size, color, alpha }
 */

// ── Pre-built emitter configs ────────────────────────────────────────────

/** Brown/tan dust on landing — short life, spread outward */
export const DUST_CLOUD = {
    count: 8,
    speed: 60,
    spread: Math.PI,          // full semicircle upward
    lifetime: 0.3,
    size: 4,
    color: ['#C4A46C', '#B8956A', '#D2B48C', '#A0845C'],
    gravity: -40,             // slight upward float
    fadeOut: true,
    shrink: true,
};

/** Yellow/white sparks on hit — fast, narrow cone, very short */
export const HIT_SPARKS = {
    count: 6,
    speed: 200,
    spread: Math.PI * 0.25,   // narrow 45° cone
    lifetime: 0.2,
    size: 3,
    color: ['#FFD700', '#FFFFEE', '#FFA500', '#FFFFFF'],
    gravity: 0,
    fadeOut: true,
    shrink: false,
};

/** Mixed debris on enemy death — wide spread, gravity pulls down */
export const DEATH_DEBRIS = {
    count: 12,
    speed: 120,
    spread: Math.PI * 2,      // full 360°
    lifetime: 0.5,
    size: 5,
    color: ['#FF6347', '#FFD700', '#FFFFFF', '#87CEEB', '#FF4500'],
    gravity: 300,
    fadeOut: true,
    shrink: true,
};

// ── ParticleSystem ───────────────────────────────────────────────────────

export class ParticleSystem {
    constructor() {
        /** @type {Array<{x:number,y:number,vx:number,vy:number,life:number,maxLife:number,size:number,color:string,alpha:number}>} */
        this.particles = [];
    }

    /**
     * Spawn particles at (x, y) using a config object.
     * @param {number} x  Emitter center X
     * @param {number} y  Emitter center Y
     * @param {object} config  Emitter configuration
     */
    emit(x, y, config) {
        const {
            count = 8,
            speed = 100,
            spread = Math.PI * 2,
            lifetime = 0.4,
            size = 4,
            color = ['#FFFFFF'],
            gravity = 0,
            fadeOut = true,
            shrink = false,
        } = config;

        const colors = Array.isArray(color) ? color : [color];

        for (let i = 0; i < count; i++) {
            const angle = -Math.PI / 2 + (Math.random() - 0.5) * spread;
            const spd = speed * (0.5 + Math.random() * 0.5);

            this.particles.push({
                x,
                y,
                vx: Math.cos(angle) * spd,
                vy: Math.sin(angle) * spd,
                life: lifetime * (0.7 + Math.random() * 0.3),
                maxLife: lifetime,
                size: size * (0.6 + Math.random() * 0.4),
                color: colors[Math.floor(Math.random() * colors.length)],
                alpha: 1,
                gravity,
                fadeOut,
                shrink,
            });
        }
    }

    /**
     * Advance all particles: move, age, remove dead.
     * @param {number} dt  Delta time in seconds
     */
    update(dt) {
        for (let i = this.particles.length - 1; i >= 0; i--) {
            const p = this.particles[i];
            p.life -= dt;
            if (p.life <= 0) {
                this.particles.splice(i, 1);
                continue;
            }

            p.vy += p.gravity * dt;
            p.x += p.vx * dt;
            p.y += p.vy * dt;

            const progress = 1 - p.life / p.maxLife;
            if (p.fadeOut) p.alpha = 1 - progress;
            if (p.shrink) p.size = p.size * (1 - progress * 0.02);
        }
    }

    /**
     * Draw all alive particles.
     * @param {CanvasRenderingContext2D} ctx
     */
    render(ctx) {
        if (this.particles.length === 0) return;

        ctx.save();
        for (const p of this.particles) {
            ctx.globalAlpha = p.alpha;
            ctx.fillStyle = p.color;
            ctx.fillRect(
                p.x - p.size / 2,
                p.y - p.size / 2,
                p.size,
                p.size
            );
        }
        ctx.restore();
    }
}
