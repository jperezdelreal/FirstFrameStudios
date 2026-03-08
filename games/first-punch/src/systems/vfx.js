/**
 * VFX System — First Punch
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
 *      VFX.createKOText(vfx, hitX, hitY - 30);
 *
 * 5. For ground shadows, call the static method directly in entity render:
 *      VFX.drawShadow(ctx, entity.x, entity.y, entity.width, entity.height, jumpHeight);
 *
 * 6. For floating damage numbers (call alongside hit effects when hits land):
 *      // Normal hit:
 *      VFX.createDamageNumber(vfx, hitX, hitY, damageAmount, false);
 *      // Combo hit (3+ chain):
 *      VFX.createDamageNumber(vfx, hitX, hitY, damageAmount, true);
 *
 *    NOTE: gameplay.js should call VFX.createDamageNumber() when hits land.
 *    Do NOT modify gameplay.js from vfx.js — Wedge owns it this wave.
 *
 * 7. For attack motion trails (call when player attack animation starts):
 *      // Punch trail (white/yellow arc behind fist):
 *      VFX.createMotionTrail(vfx, fistX, fistY, 40, 20, Math.PI * 0.3, '#FFFFCC');
 *      // Kick trail (wider arc behind foot):
 *      VFX.createMotionTrail(vfx, footX, footY, 55, 25, -Math.PI * 0.2, '#FFFFCC');
 *
 * 8. For enemy spawn effects (call when creating/spawning a new enemy):
 *      VFX.createSpawnEffect(vfx, enemy.x + enemy.width / 2, enemy.y + enemy.height);
 *      // Also apply scale-up to the enemy entity itself:
 *      //   enemy.spawnTimer = 0.2;  // 0.2s scale-up duration
 *      //   enemy.spawnScale = 0.5;  // start at 50%
 *      // In enemy update: if (enemy.spawnTimer > 0) {
 *      //     enemy.spawnTimer -= dt;
 *      //     enemy.spawnScale = 1.0 - (enemy.spawnTimer / 0.2) * 0.5;
 *      // }
 *      // In enemy render: ctx.scale(enemy.spawnScale, enemy.spawnScale);
 *      // A warning shadow should appear 0.3s before enemy drops in:
 *      //   Schedule enemy spawn 0.3s after VFX.createSpawnEffect() call,
 *      //   or call createSpawnEffect() 0.3s before adding the enemy to the entity list.
 *
 * 9. For enemy attack telegraph (call 300ms BEFORE enemy attack executes):
 *      VFX.createTelegraph(vfx, enemy.x + enemy.width / 2, enemy.y, 0.3);
 *      // Schedule the actual attack 300ms later.
 *      // This gives the player a fair reaction window.
 *
 * 10. For motion trails with attack-type coloring:
 *      // Punch trail (yellow arc):
 *      VFX.createMotionTrail(vfx, fistX, fistY, 40, 20, Math.PI*0.3, '#FFFFCC', 'punch');
 *      // Kick trail (blue arc):
 *      VFX.createMotionTrail(vfx, footX, footY, 55, 25, -Math.PI*0.2, '#FFFFCC', 'kick');
 *      // Special/heavy trail (red, wider arc + sparkles):
 *      VFX.createMotionTrail(vfx, fistX, fistY, 55, 30, Math.PI*0.3, '#FFFFCC', 'special');
 *
 * 11. For boss intro cinematic (call when boss entity spawns):
 *      VFX.createBossIntro(vfx, 'BRUISER', 'Get ready!', 3.0);
 *      // IMPORTANT: gameplay.js should PAUSE game updates during boss intro.
 *      //   if (vfx.effects.some(e => e.type === 'boss_intro')) {
 *      //       // skip enemy AI / player input / physics this frame
 *      //       vfx.update(dt);
 *      //       vfx.render(ctx);
 *      //       return; // skip rest of update loop
 *      //   }
 *
 * 12. For screen flash (call on big hits or player damage):
 *      // White flash for big combo hits:
 *      VFX.createScreenFlash(vfx, '#FFFFFF', 0.15);
 *      // Red flash for player taking damage:
 *      VFX.createScreenFlash(vfx, '#FF0000', 0.2);
 *
 * 13. For speed lines (call during dashes or charge attacks):
 *      // Direction is angle in radians (0 = right, Math.PI = left):
 *      VFX.createSpeedLines(vfx, 0, 0.3);
 *      // Omit direction for radial burst (omnidirectional):
 *      VFX.createSpeedLines(vfx, null, 0.25);
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
    light:  28,   // punch — bigger for more impact
    medium: 38,   // kick
    heavy:  52,   // combo finisher
};

const HIT_LIFETIME   = 0.15;   // 150ms (~9 frames at 60fps) — slightly longer for readability
const KO_LIFETIME    = 0.25;  // 250ms — larger, more dramatic
const RAY_COUNT      = 6;     // starburst ray count
const KO_STAR_COUNT  = 5;     // orbiting star particles

// KO text constants
const KO_TEXT_LIFETIME = 0.6;   // 0.1s pop-in + 0.5s fade
const KO_TEXT_POP_TIME = 0.1;   // seconds for scale 0 → 1.5
const KO_TEXT_PHRASES  = ['POW!', 'WHAM!', 'BAM!', 'BONK!', 'UGH!'];
const KO_TEXT_COLOR    = '#FED90F';
const KO_TEXT_SIZE     = 40;
const KO_TEXT_DRIFT    = 60;    // px/s upward drift

// Damage number constants
const DMG_LIFETIME     = 0.8;   // 800ms float duration
const DMG_DRIFT_SPEED  = 80;    // px/s upward drift
const DMG_COLOR_NORMAL = '#FFFFFF';
const DMG_COLOR_COMBO  = '#FED90F';
const DMG_COLOR_CRIT   = '#FF3333';
const DMG_FONT_NORMAL  = 20;
const DMG_FONT_COMBO   = 28;
const DMG_FONT_FINISHER = 36;
const DMG_FINISHER_THRESHOLD = 25;  // combo damage >= this = finisher tier

// Motion trail constants
const TRAIL_FRAME_COUNT  = 4;      // 3-4 afterimage frames
const TRAIL_LIFETIME     = 0.15;   // 150ms total trail duration (~4 frames at 60fps)
const TRAIL_START_ALPHA  = 0.4;    // first frame alpha
const TRAIL_COLOR_DEFAULT = '#FFFFCC'; // warm white-yellow

// Spawn effect constants
const SPAWN_LIFETIME      = 0.5;   // total spawn effect duration
const SPAWN_PARTICLE_COUNT = 12;   // dust particles in ring
const SPAWN_RING_RADIUS    = 40;   // max expansion radius
const SPAWN_SHADOW_DURATION = 0.3; // warning shadow shows first 0.3s

// Telegraph constants (B-10)
const TELEGRAPH_EXCLAIM_SIZE = 28;     // "!" font size
const TELEGRAPH_EXCLAIM_COLOR = '#FF3333';
const TELEGRAPH_FLASH_COLOR  = 'rgba(255, 0, 0, 0.35)';
const TELEGRAPH_RING_MAX_R   = 35;     // expanding ring max radius

// Attack-type trail colors (B-11)
const TRAIL_COLOR_PUNCH   = '#FFD700';  // yellow
const TRAIL_COLOR_KICK    = '#4488FF';  // blue
const TRAIL_COLOR_SPECIAL = '#FF3333';  // red
const TRAIL_ARC_SCALE = { punch: 1.0, kick: 1.0, special: 1.5 }; // heavy = wider
const TRAIL_SPARKLE_COUNT = 6;

// Boss intro constants (AAA-V3)
const BOSS_INTRO_DIM_ALPHA   = 0.5;
const BOSS_NAME_SIZE         = 64;
const BOSS_TITLE_SIZE        = 28;
const BOSS_TEXT_HOLD_TIME    = 1.5;    // seconds text stays fully visible
const BOSS_TEXT_COLOR        = '#FED90F';
const BOSS_TITLE_COLOR       = '#FFFFFF';

// Screen flash constants
const SCREEN_FLASH_DEFAULT_DURATION = 0.15;

// Speed line constants
const SPEED_LINE_COUNT       = 18;
const SPEED_LINE_MIN_LEN     = 40;
const SPEED_LINE_MAX_LEN     = 120;

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

        // Pre-compute scatter particles
        const scatterCount = intensity === 'heavy' ? 10 : (intensity === 'medium' ? 7 : 5);
        const scatters = [];
        for (let i = 0; i < scatterCount; i++) {
            scatters.push({
                angle: Math.random() * Math.PI * 2,
                speed: 0.5 + Math.random() * 1.0,
                size: 1.5 + Math.random() * 2.5,
            });
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

                // Center flash circle (bigger, brighter)
                ctx.fillStyle = '#FFFFFF';
                ctx.beginPath();
                ctx.arc(x, y, r * 0.35, 0, Math.PI * 2);
                ctx.fill();

                // Secondary warm glow
                ctx.fillStyle = HIT_WHITE;
                ctx.beginPath();
                ctx.arc(x, y, r * 0.2, 0, Math.PI * 2);
                ctx.fill();

                // Radiating rays (thicker for impact)
                ctx.strokeStyle = HIT_YELLOW;
                ctx.lineWidth = intensity === 'heavy' ? 3.5 : (intensity === 'medium' ? 2.5 : 2);
                for (const angle of angles) {
                    const innerR = r * 0.25;
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

                // Ring shockwave expanding outward
                const ringR = r * (0.5 + progress * 0.8);
                const ringAlpha = alpha * 0.6;
                ctx.globalAlpha = ringAlpha;
                ctx.strokeStyle = HIT_WHITE;
                ctx.lineWidth = 2 * (1 - progress);
                ctx.beginPath();
                ctx.arc(x, y, ringR, 0, Math.PI * 2);
                ctx.stroke();

                // Scatter particles flying outward
                ctx.globalAlpha = alpha * 0.8;
                ctx.fillStyle = HIT_YELLOW;
                for (const sp of scatters) {
                    const dist = r * progress * sp.speed * 1.5;
                    const px = x + Math.cos(sp.angle) * dist;
                    const py = y + Math.sin(sp.angle) * dist;
                    const pSize = sp.size * (1 - progress * 0.7);
                    ctx.beginPath();
                    ctx.arc(px, py, pSize, 0, Math.PI * 2);
                    ctx.fill();
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
        const radius = 60;

        // Pre-compute ray angles
        const angles = [];
        for (let i = 0; i < RAY_COUNT + 4; i++) {
            angles.push((Math.PI * 2 * i) / (RAY_COUNT + 4));
        }

        // Pre-compute star starting angles and radii
        const stars = [];
        for (let i = 0; i < KO_STAR_COUNT + 2; i++) {
            stars.push({
                angle: (Math.PI * 2 * i) / (KO_STAR_COUNT + 2),
                speed: 1.5 + Math.random() * 1.5,
                dist: 0.5 + Math.random() * 0.3,
                size: 3 + Math.random() * 3,
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

    // ── Static: Damage Number ────────────────────────────────────────────

    /**
     * Spawn a floating damage number at the hit point.
     * Drifts upward, scales down, and fades out over 0.8s.
     *
     * @param {VFX} vfxInstance  The VFX singleton to add the effect to
     * @param {number} x        Hit point X
     * @param {number} y        Hit point Y
     * @param {number} damage   Damage value to display
     * @param {boolean} [isCombo=false]  True for combo hits (3+ chain)
     */
    static createDamageNumber(vfxInstance, x, y, damage, isCombo = false) {
        const isFinisher = isCombo && damage >= DMG_FINISHER_THRESHOLD;

        let color, fontSize;
        if (isFinisher) {
            color = DMG_COLOR_CRIT;
            fontSize = DMG_FONT_FINISHER;
        } else if (isCombo) {
            color = DMG_COLOR_COMBO;
            fontSize = DMG_FONT_COMBO;
        } else {
            color = DMG_COLOR_NORMAL;
            fontSize = DMG_FONT_NORMAL;
        }

        const text = (isCombo && damage >= DMG_FINISHER_THRESHOLD) ? `${damage}!` : `${damage}`;
        const startY = y;
        const maxLifetime = DMG_LIFETIME;

        const effect = {
            type: 'damage_number',
            value: damage,
            x,
            y: startY,
            lifetime: maxLifetime,
            maxLifetime,
            scale: 1.5,
            color,
            render(ctx, progress) {
                // progress: 0 → 1 (0 = just spawned, 1 = about to expire)
                const alpha = 1 - progress;
                const currentScale = 1.5 - 0.5 * progress;   // 1.5x → 1.0x
                const yOffset = progress * maxLifetime * DMG_DRIFT_SPEED;
                const drawY = startY - yOffset;

                // Update stored y for external reads
                effect.y = drawY;

                ctx.save();
                ctx.globalAlpha = alpha;

                const scaledSize = Math.round(fontSize * currentScale);
                ctx.font = `bold ${scaledSize}px sans-serif`;
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';

                // Dark outline for readability against any background
                ctx.strokeStyle = '#222222';
                ctx.lineWidth = 3;
                ctx.lineJoin = 'round';
                ctx.strokeText(text, x, drawY);

                ctx.fillStyle = color;
                ctx.fillText(text, x, drawY);

                ctx.restore();
            },
        };

        vfxInstance.addEffect(effect);
    }

    // ── Static: KO Text ─────────────────────────────────────────────────

    /**
     * Spawn a comic-style KO pop-up text (POW!, WHAM!, etc.) at the given point.
     * Scales up from 0 → 1.5× over 0.1s, shrinks to 1.0×, fades out over 0.5s,
     * drifts upward. Slight random rotation for comic-book energy.
     *
     * @param {VFX} vfxInstance  The VFX singleton to add the effect to
     * @param {number} x        Center X
     * @param {number} y        Center Y
     */
    static createKOText(vfxInstance, x, y) {
        const text = KO_TEXT_PHRASES[Math.floor(Math.random() * KO_TEXT_PHRASES.length)];
        const rotation = (Math.random() - 0.5) * (Math.PI / 6); // ±15°
        const startY = y;
        const maxLifetime = KO_TEXT_LIFETIME;

        const effect = {
            type: 'ko_text',
            x,
            y: startY,
            lifetime: maxLifetime,
            maxLifetime,
            render(ctx, progress) {
                // progress: 0 → 1
                const elapsed = progress * maxLifetime;

                // Scale: 0→1.5 in first 0.1s, then 1.5→1.0 over remaining 0.5s
                let scale;
                if (elapsed < KO_TEXT_POP_TIME) {
                    scale = (elapsed / KO_TEXT_POP_TIME) * 1.5;
                } else {
                    const shrinkProgress = (elapsed - KO_TEXT_POP_TIME) / (maxLifetime - KO_TEXT_POP_TIME);
                    scale = 1.5 - 0.5 * shrinkProgress;
                }

                // Fade: full opacity during pop-in, then 1→0 over the 0.5s fade phase
                let alpha;
                if (elapsed < KO_TEXT_POP_TIME) {
                    alpha = 1;
                } else {
                    alpha = 1 - (elapsed - KO_TEXT_POP_TIME) / (maxLifetime - KO_TEXT_POP_TIME);
                }

                const yOffset = progress * maxLifetime * KO_TEXT_DRIFT;
                const drawY = startY - yOffset;

                ctx.save();
                ctx.globalAlpha = Math.max(0, alpha);
                ctx.translate(x, drawY);
                ctx.rotate(rotation);

                const scaledSize = Math.round(KO_TEXT_SIZE * scale);
                ctx.font = `bold ${scaledSize}px sans-serif`;
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';

                // Thick dark outline
                ctx.strokeStyle = '#222222';
                ctx.lineWidth = 4;
                ctx.lineJoin = 'round';
                ctx.strokeText(text, 0, 0);

                // Bright yellow fill
                ctx.fillStyle = KO_TEXT_COLOR;
                ctx.fillText(text, 0, 0);

                ctx.restore();
            },
        };

        vfxInstance.addEffect(effect);
    }

    // ── Static: Motion Trail ────────────────────────────────────────────

    /**
     * Create a swoosh/arc motion trail behind an attack.
     * Produces 3-4 afterimage frames that fade from 0.4 → 0 alpha, each
     * slightly larger and more transparent than the last. Uses bezier
     * curves for an organic arc shape.
     *
     * B-11 Polish: attack-type coloring (yellow/blue/red), wider arcs for
     * heavy/special attacks, curved path following attack arc, and sparkle
     * particles along the trail edge.
     *
     * @param {VFX} vfxInstance  The VFX singleton
     * @param {number} x        Center X of the arc origin (fist/foot position)
     * @param {number} y        Center Y of the arc origin
     * @param {number} width    Arc width (horizontal extent)
     * @param {number} height   Arc height (vertical extent)
     * @param {number} angle    Rotation angle in radians (direction of attack)
     * @param {string} [color='#FFFFCC']  Trail color (fallback if no attackType)
     * @param {'punch'|'kick'|'special'} [attackType]  Attack type for auto-color/arc scaling
     */
    static createMotionTrail(vfxInstance, x, y, width, height, angle, color = TRAIL_COLOR_DEFAULT, attackType) {
        // B-11: Override color and arc scale based on attack type
        let trailColor = color;
        let arcScale = 1.0;
        if (attackType) {
            if (attackType === 'punch') trailColor = TRAIL_COLOR_PUNCH;
            else if (attackType === 'kick') trailColor = TRAIL_COLOR_KICK;
            else if (attackType === 'special') trailColor = TRAIL_COLOR_SPECIAL;
            arcScale = TRAIL_ARC_SCALE[attackType] || 1.0;
        }

        const scaledWidth = width * arcScale;
        const scaledHeight = height * arcScale;

        // Pre-compute sparkle positions along the outer arc edge
        const sparkles = [];
        for (let s = 0; s < TRAIL_SPARKLE_COUNT; s++) {
            const t = s / (TRAIL_SPARKLE_COUNT - 1); // 0 → 1 along arc
            sparkles.push({
                t,
                offset: (Math.random() - 0.5) * 6,
                size: 1.5 + Math.random() * 2,
                twinkleSpeed: 3 + Math.random() * 4,
            });
        }

        for (let i = 0; i < TRAIL_FRAME_COUNT; i++) {
            const frameDelay = i * (TRAIL_LIFETIME / TRAIL_FRAME_COUNT);
            const frameScale = 1.0 + i * 0.15;
            const frameAlpha = TRAIL_START_ALPHA * (1 - i / TRAIL_FRAME_COUNT);
            const frameLifetime = TRAIL_LIFETIME - frameDelay;

            const effect = {
                type: 'motion_trail',
                x,
                y,
                lifetime: frameLifetime,
                maxLifetime: frameLifetime,
                render(ctx, progress) {
                    const alpha = frameAlpha * (1 - progress * progress);
                    if (alpha <= 0) return;

                    const w = scaledWidth * frameScale;
                    const h = scaledHeight * frameScale;

                    ctx.save();
                    ctx.globalAlpha = alpha;
                    ctx.translate(x, y);
                    ctx.rotate(angle);

                    // Curved swoosh arc using bezier curves
                    ctx.beginPath();
                    ctx.moveTo(-w * 0.5, 0);
                    ctx.bezierCurveTo(
                        -w * 0.3, -h * 0.8,
                        w * 0.3, -h * 1.0,
                        w * 0.5, -h * 0.3
                    );
                    // Return path (thinner inner arc)
                    ctx.bezierCurveTo(
                        w * 0.2, -h * 0.6,
                        -w * 0.15, -h * 0.4,
                        -w * 0.5, 0
                    );
                    ctx.closePath();

                    ctx.fillStyle = trailColor;
                    ctx.fill();

                    // Bright edge highlight on outer arc
                    ctx.beginPath();
                    ctx.moveTo(-w * 0.5, 0);
                    ctx.bezierCurveTo(
                        -w * 0.3, -h * 0.8,
                        w * 0.3, -h * 1.0,
                        w * 0.5, -h * 0.3
                    );
                    ctx.strokeStyle = '#FFFFFF';
                    ctx.lineWidth = 1.5;
                    ctx.stroke();

                    // B-11: Sparkle particles along outer arc edge
                    if (i === 0) {
                        const elapsed = progress * frameLifetime;
                        for (const sp of sparkles) {
                            const twinkle = Math.sin(elapsed * sp.twinkleSpeed * Math.PI * 2);
                            if (twinkle < 0.2) continue; // only visible part of the time
                            // Approximate point on outer bezier at parameter t
                            const bt = sp.t;
                            const bt2 = bt * bt;
                            const bt3 = bt2 * bt;
                            const mt = 1 - bt;
                            const mt2 = mt * mt;
                            const mt3 = mt2 * mt;
                            const p0x = -w * 0.5, p0y = 0;
                            const p1x = -w * 0.3, p1y = -h * 0.8;
                            const p2x = w * 0.3,  p2y = -h * 1.0;
                            const p3x = w * 0.5,  p3y = -h * 0.3;
                            const sx = mt3 * p0x + 3 * mt2 * bt * p1x + 3 * mt * bt2 * p2x + bt3 * p3x;
                            const sy = mt3 * p0y + 3 * mt2 * bt * p1y + 3 * mt * bt2 * p2y + bt3 * p3y + sp.offset;

                            ctx.globalAlpha = alpha * twinkle * 0.8;
                            ctx.fillStyle = '#FFFFFF';
                            ctx.beginPath();
                            ctx.arc(sx, sy, sp.size, 0, Math.PI * 2);
                            ctx.fill();
                        }
                    }

                    ctx.restore();
                },
            };

            vfxInstance.addEffect(effect);
        }
    }

    // ── Static: Spawn Effect ─────────────────────────────────────────────

    /**
     * Create an enemy spawn-in effect: warning shadow on ground → dust cloud
     * ring expanding outward. Call this when spawning enemies so they don't
     * just pop in.
     *
     * The dust ring is a circle of small particles that expand outward.
     * A dark oval shadow pulses on the ground as a 0.3s warning before the
     * enemy appears. The effect lasts 0.5s total.
     *
     * For the scale-up animation (enemy starts at 0.5× → 1.0× over 0.2s),
     * see integration instructions in the file header — that logic belongs
     * in gameplay.js / enemy.js, not in the VFX system.
     *
     * @param {VFX} vfxInstance  The VFX singleton
     * @param {number} x        Center X of spawn point (enemy center)
     * @param {number} y        Ground Y of spawn point (enemy feet)
     */
    static createSpawnEffect(vfxInstance, x, y) {
        // Pre-compute dust particle positions and velocities
        const particles = [];
        for (let i = 0; i < SPAWN_PARTICLE_COUNT; i++) {
            const a = (Math.PI * 2 * i) / SPAWN_PARTICLE_COUNT + (Math.random() - 0.5) * 0.4;
            particles.push({
                angle: a,
                speed: 0.6 + Math.random() * 0.4,   // fraction of max radius
                size: 3 + Math.random() * 4,
                yOffset: (Math.random() - 0.5) * 6,  // slight vertical scatter
            });
        }

        const maxLifetime = SPAWN_LIFETIME;

        const effect = {
            type: 'spawn_effect',
            x,
            y,
            lifetime: maxLifetime,
            maxLifetime,
            render(ctx, progress) {
                const elapsed = progress * maxLifetime;

                ctx.save();

                // Phase 1 (0–0.3s): Warning shadow pulses on ground
                if (elapsed < SPAWN_SHADOW_DURATION) {
                    const shadowProgress = elapsed / SPAWN_SHADOW_DURATION;
                    const shadowAlpha = 0.15 + 0.2 * Math.sin(shadowProgress * Math.PI * 3); // pulse
                    const shadowScale = 0.4 + shadowProgress * 0.6;

                    ctx.fillStyle = `rgba(0, 0, 0, ${shadowAlpha})`;
                    ctx.beginPath();
                    ctx.ellipse(x, y, 30 * shadowScale, 8 * shadowScale, 0, 0, Math.PI * 2);
                    ctx.fill();
                }

                // Phase 2 (0.3s onward): Dust cloud ring expanding outward
                if (elapsed >= SPAWN_SHADOW_DURATION * 0.5) {
                    const dustProgress = Math.min(1, (elapsed - SPAWN_SHADOW_DURATION * 0.5) / (maxLifetime - SPAWN_SHADOW_DURATION * 0.5));
                    const dustAlpha = 0.6 * (1 - dustProgress * dustProgress); // ease-out fade

                    for (const p of particles) {
                        const dist = SPAWN_RING_RADIUS * dustProgress * p.speed;
                        const px = x + Math.cos(p.angle) * dist;
                        const py = y + Math.sin(p.angle) * dist * 0.4 + p.yOffset; // flatten ring vertically
                        const pSize = p.size * (1 - dustProgress * 0.5); // shrink as they expand

                        ctx.globalAlpha = dustAlpha * (0.5 + Math.random() * 0.1); // slight flicker
                        ctx.fillStyle = '#C8B89A'; // dusty tan
                        ctx.beginPath();
                        ctx.arc(px, py, pSize, 0, Math.PI * 2);
                        ctx.fill();

                        // Second smaller puff for volume
                        ctx.fillStyle = '#D4C4A8';
                        ctx.beginPath();
                        ctx.arc(px + pSize * 0.5, py - pSize * 0.3, pSize * 0.6, 0, Math.PI * 2);
                        ctx.fill();
                    }
                }

                ctx.restore();
            },
        };

        vfxInstance.addEffect(effect);
    }

    // ── Static: Enemy Attack Telegraph (B-10) ────────────────────────────

    /**
     * Show a visual warning before an enemy attacks.
     * Exclamation mark "!" above head, red body flash overlay, and an
     * expanding circular indicator — gives the player a 300ms reaction window.
     *
     * @param {VFX} vfxInstance  The VFX singleton
     * @param {number} x        Center X above enemy head
     * @param {number} y        Top Y of enemy (exclamation appears above)
     * @param {number} [duration=0.3]  Telegraph duration in seconds (default 300ms)
     */
    static createTelegraph(vfxInstance, x, y, duration = 0.3) {
        const maxLifetime = duration;

        const effect = {
            type: 'telegraph',
            x,
            y,
            lifetime: maxLifetime,
            maxLifetime,
            render(ctx, progress) {
                ctx.save();

                // --- 1. Exclamation mark "!" above enemy head ---
                const exclaimY = y - 30;
                // Pop-in scale: 0→1.3 in first 30%, settle to 1.0
                let exclaimScale;
                if (progress < 0.3) {
                    exclaimScale = (progress / 0.3) * 1.3;
                } else {
                    exclaimScale = 1.3 - 0.3 * ((progress - 0.3) / 0.7);
                }
                // Pulse alpha to draw attention
                const pulseAlpha = 0.7 + 0.3 * Math.sin(progress * Math.PI * 6);

                ctx.globalAlpha = pulseAlpha * (1 - progress * 0.3);
                const scaledSize = Math.round(TELEGRAPH_EXCLAIM_SIZE * exclaimScale);
                ctx.font = `bold ${scaledSize}px sans-serif`;
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';

                // Dark outline
                ctx.strokeStyle = '#222222';
                ctx.lineWidth = 3;
                ctx.lineJoin = 'round';
                ctx.strokeText('!', x, exclaimY);

                ctx.fillStyle = TELEGRAPH_EXCLAIM_COLOR;
                ctx.fillText('!', x, exclaimY);

                // --- 2. Red flash overlay on enemy body ---
                const flashAlpha = 0.35 * (1 - progress) * (0.5 + 0.5 * Math.sin(progress * Math.PI * 4));
                ctx.globalAlpha = flashAlpha;
                ctx.fillStyle = '#FF0000';
                // Approximate enemy body area (centered on x, below y)
                ctx.fillRect(x - 20, y, 40, 50);

                // --- 3. Expanding circular indicator ---
                const ringProgress = progress;
                const ringR = TELEGRAPH_RING_MAX_R * ringProgress;
                const ringAlpha = 0.6 * (1 - ringProgress);
                ctx.globalAlpha = ringAlpha;
                ctx.strokeStyle = TELEGRAPH_EXCLAIM_COLOR;
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.arc(x, y + 25, ringR, 0, Math.PI * 2);
                ctx.stroke();

                // Inner solid ring for readability
                ctx.globalAlpha = ringAlpha * 0.3;
                ctx.fillStyle = TELEGRAPH_EXCLAIM_COLOR;
                ctx.beginPath();
                ctx.arc(x, y + 25, ringR, 0, Math.PI * 2);
                ctx.fill();

                ctx.restore();
            },
        };

        vfxInstance.addEffect(effect);
    }

    // ── Static: Boss Intro Cinematic (AAA-V3) ────────────────────────────

    /**
     * Dramatic boss intro: dims screen, slides in boss name + subtitle,
     * holds, then fades out. Gameplay should pause while this effect is active.
     *
     * Integration: gameplay.js should check for active boss_intro effects
     * and skip game updates while one is playing. See header instructions #11.
     *
     * @param {VFX} vfxInstance  The VFX singleton
     * @param {string} bossName   Boss display name (e.g. 'BRUISER')
     * @param {string} bossTitle  Subtitle (e.g. 'Get ready!')
     * @param {number} [duration=3.0]  Total cinematic duration in seconds
     */
    static createBossIntro(vfxInstance, bossName, bossTitle, duration = 3.0) {
        const maxLifetime = duration;
        // Timing phases: slide-in (0.5s) → hold (1.5s) → fade-out (remaining)
        const slideInTime = 0.5;
        const holdEnd = slideInTime + BOSS_TEXT_HOLD_TIME;

        const effect = {
            type: 'boss_intro',
            x: 0,
            y: 0,
            lifetime: maxLifetime,
            maxLifetime,
            render(ctx, progress) {
                const elapsed = progress * maxLifetime;
                const canvasW = ctx.canvas.logicalWidth || ctx.canvas.width;
                const canvasH = ctx.canvas.logicalHeight || ctx.canvas.height;

                ctx.save();

                // --- 1. Screen dim overlay ---
                let dimAlpha;
                if (elapsed < slideInTime) {
                    dimAlpha = BOSS_INTRO_DIM_ALPHA * (elapsed / slideInTime);
                } else if (elapsed < holdEnd) {
                    dimAlpha = BOSS_INTRO_DIM_ALPHA;
                } else {
                    dimAlpha = BOSS_INTRO_DIM_ALPHA * (1 - (elapsed - holdEnd) / (maxLifetime - holdEnd));
                }
                ctx.globalAlpha = Math.max(0, dimAlpha);
                ctx.fillStyle = '#000000';
                ctx.fillRect(0, 0, canvasW, canvasH);

                // --- 2. Text slide-in from right, hold, fade ---
                let textX, textAlpha;
                if (elapsed < slideInTime) {
                    // Slide in from right edge to center
                    const slideProgress = elapsed / slideInTime;
                    const eased = 1 - Math.pow(1 - slideProgress, 3); // ease-out cubic
                    textX = canvasW + 100 - (canvasW / 2 + 100) * eased;
                    textAlpha = slideProgress;
                } else if (elapsed < holdEnd) {
                    textX = canvasW / 2;
                    textAlpha = 1;
                } else {
                    textX = canvasW / 2;
                    textAlpha = 1 - (elapsed - holdEnd) / (maxLifetime - holdEnd);
                }

                ctx.globalAlpha = Math.max(0, textAlpha);
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';

                // Boss name — large bold
                ctx.font = `bold ${BOSS_NAME_SIZE}px sans-serif`;
                ctx.strokeStyle = '#222222';
                ctx.lineWidth = 5;
                ctx.lineJoin = 'round';
                ctx.strokeText(bossName, textX, canvasH / 2 - 20);
                ctx.fillStyle = BOSS_TEXT_COLOR;
                ctx.fillText(bossName, textX, canvasH / 2 - 20);

                // Boss title — smaller, slightly below
                ctx.font = `italic ${BOSS_TITLE_SIZE}px sans-serif`;
                ctx.strokeStyle = '#222222';
                ctx.lineWidth = 3;
                ctx.strokeText(bossTitle, textX, canvasH / 2 + 30);
                ctx.fillStyle = BOSS_TITLE_COLOR;
                ctx.fillText(bossTitle, textX, canvasH / 2 + 30);

                ctx.restore();
            },
        };

        vfxInstance.addEffect(effect);
    }

    // ── Static: Screen Flash ─────────────────────────────────────────────

    /**
     * Full-screen color flash. White for big hits, red for player damage.
     *
     * @param {VFX} vfxInstance  The VFX singleton
     * @param {string} color    Flash color (e.g. '#FFFFFF', '#FF0000')
     * @param {number} [duration=0.15]  Flash duration in seconds
     */
    static createScreenFlash(vfxInstance, color, duration = SCREEN_FLASH_DEFAULT_DURATION) {
        const maxLifetime = duration;

        const effect = {
            type: 'screen_flash',
            x: 0,
            y: 0,
            lifetime: maxLifetime,
            maxLifetime,
            render(ctx, progress) {
                // Sharp attack, fast decay — peak at 10% progress
                let alpha;
                if (progress < 0.1) {
                    alpha = progress / 0.1; // 0→1 ramp up
                } else {
                    alpha = 1 - (progress - 0.1) / 0.9; // 1→0 decay
                }
                alpha *= 0.6; // cap max brightness so it doesn't blind

                ctx.save();
                ctx.globalAlpha = Math.max(0, alpha);
                ctx.fillStyle = color;
                ctx.fillRect(0, 0, ctx.canvas.logicalWidth || ctx.canvas.width, ctx.canvas.logicalHeight || ctx.canvas.height);
                ctx.restore();
            },
        };

        vfxInstance.addEffect(effect);
    }

    // ── Static: Speed Lines ──────────────────────────────────────────────

    /**
     * Radial speed lines from center during dashes/charges.
     * If direction is null/undefined, lines radiate in all directions.
     * If a direction is given, lines concentrate in a cone around that angle.
     *
     * @param {VFX} vfxInstance  The VFX singleton
     * @param {number|null} direction  Angle in radians (0=right), or null for omnidirectional
     * @param {number} [duration=0.3]  Duration in seconds
     */
    static createSpeedLines(vfxInstance, direction, duration = 0.3) {
        const maxLifetime = duration;

        // Pre-compute line angles and lengths
        const lines = [];
        for (let i = 0; i < SPEED_LINE_COUNT; i++) {
            let angle;
            if (direction != null) {
                // Concentrate in ±45° cone around direction
                angle = direction + (Math.random() - 0.5) * (Math.PI / 2);
            } else {
                angle = Math.random() * Math.PI * 2;
            }
            lines.push({
                angle,
                startDist: 30 + Math.random() * 60,   // distance from center to start
                length: SPEED_LINE_MIN_LEN + Math.random() * (SPEED_LINE_MAX_LEN - SPEED_LINE_MIN_LEN),
                width: 1 + Math.random() * 2,
                alpha: 0.3 + Math.random() * 0.4,
            });
        }

        const effect = {
            type: 'speed_lines',
            x: 0,
            y: 0,
            lifetime: maxLifetime,
            maxLifetime,
            render(ctx, progress) {
                const canvasW = ctx.canvas.logicalWidth || ctx.canvas.width;
                const canvasH = ctx.canvas.logicalHeight || ctx.canvas.height;
                const cx = canvasW / 2;
                const cy = canvasH / 2;

                // Lines shoot outward then fade
                const expansion = 1 + progress * 2;
                const fadeAlpha = 1 - progress * progress;

                ctx.save();
                ctx.lineCap = 'round';

                for (const line of lines) {
                    const sd = line.startDist * expansion;
                    const ed = (line.startDist + line.length) * expansion;
                    const sx = cx + Math.cos(line.angle) * sd;
                    const sy = cy + Math.sin(line.angle) * sd;
                    const ex = cx + Math.cos(line.angle) * ed;
                    const ey = cy + Math.sin(line.angle) * ed;

                    ctx.globalAlpha = line.alpha * fadeAlpha;
                    ctx.strokeStyle = '#FFFFFF';
                    ctx.lineWidth = line.width;
                    ctx.beginPath();
                    ctx.moveTo(sx, sy);
                    ctx.lineTo(ex, ey);
                    ctx.stroke();
                }

                ctx.restore();
            },
        };

        vfxInstance.addEffect(effect);
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
