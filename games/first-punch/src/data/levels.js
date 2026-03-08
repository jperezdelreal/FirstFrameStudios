// Level and enemy type definitions.
// Edit this file to author content — no code changes needed.
// WaveManager (upcoming) will consume these exports.

// ---------------------------------------------------------------------------
// Enemy type templates
// ---------------------------------------------------------------------------
// Each key maps to a variant name used by Enemy constructor and AI system.
// Properties here are *design intent* values; the Enemy entity applies them
// via its constructor (variant string match) and the AI reads cooldowns from
// the entity instance.

export const ENEMY_TYPES = {
    normal: {
        hp: 30,
        speed: 100,
        damage: 5,
        color: '#663399',
        attackCooldown: 1.5,
        aiCooldown: 0.5,
        attackRange: 80
    },
    tough: {
        hp: 50,
        speed: 80,
        damage: 8,
        color: '#8B0000',
        attackCooldown: 1.0,
        aiCooldown: 0.3,
        attackRange: 90
    },
    fast: {
        hp: 20,
        speed: 180,
        damage: 5,
        color: '#2196F3',
        width: 40,
        height: 68,
        attackCooldown: 1.0,
        aiCooldown: 0.3,
        attackRange: 60
    },
    heavy: {
        hp: 80,
        speed: 60,
        damage: 12,
        color: '#2E7D32',
        width: 60,
        height: 84,
        attackCooldown: 2.0,
        aiCooldown: 0.6,
        attackRange: 80
    },
    boss: {
        hp: 200,
        speed: 70,
        damage: 15,
        color: '#F57C00',
        width: 80,
        height: 100,
        attackCooldown: 1.2,
        aiCooldown: 0.4,
        attackRange: 110
    }
};

// ---------------------------------------------------------------------------
// Level 1 — Downtown District
// ---------------------------------------------------------------------------
// Wave design follows encounter-pacing.md and wave-rules.md:
//   Wave 1: intro (2 normals — easy)
//   Wave 2: escalation (3 normals + 1 fast — introduce hit-and-run)
//   Wave 3: challenge (3 normals + 2 fast + 1 heavy — full variety)
//
// triggerX  — camera-world X where the wave activates (player.x >= triggerX - 400)
// enemies[] — spawn list; type must be a key in ENEMY_TYPES

export const LEVEL_1 = {
    name: 'Downtown District',
    width: 5000,
    background: 'downtown',
    waves: [
        {
            // Wave 1 — Intro: 2 normals, easy start
            triggerX: 800,
            enemies: [
                { type: 'normal', x: 1000, y: 500 },
                { type: 'normal', x: 1100, y: 470 }
            ]
        },
        {
            // Wave 2 — Fast intro: 3 normals + 1 fast (first fast encounter)
            triggerX: 1600,
            enemies: [
                { type: 'normal', x: 1800, y: 480 },
                { type: 'normal', x: 1850, y: 530 },
                { type: 'normal', x: 1400, y: 500 },
                { type: 'fast',   x: 1900, y: 460 }
            ]
        },
        {
            // Wave 3 — Full variety: 3 normals + 2 fast + 1 heavy
            triggerX: 2800,
            enemies: [
                { type: 'normal', x: 3000, y: 500 },
                { type: 'normal', x: 3050, y: 460 },
                { type: 'normal', x: 2600, y: 480 },
                { type: 'fast',   x: 3100, y: 520 },
                { type: 'fast',   x: 3150, y: 450 },
                { type: 'heavy',  x: 3200, y: 500 }
            ]
        },
        {
            // Wave 4 — Boss: Bruiser
            triggerX: 3500,
            enemies: [
                { type: 'boss', x: 3800, y: 500 }
            ]
        }
    ],

    // -----------------------------------------------------------------------
    // Destructible objects — smashable street props
    // Types: trashCan (10 HP), newspaperStand (15 HP),
    //        parkingMeter (20 HP), donutSign (25 HP)
    // -----------------------------------------------------------------------
    destructibles: [
        // Wave 1 zone — teach smashing early
        { type: 'trashCan',       x: 850,  y: 510 },
        { type: 'trashCan',       x: 920,  y: 475 },
        { type: 'parkingMeter',   x: 1050, y: 460 },
        // Wave 2 zone — cover + drops
        { type: 'newspaperStand', x: 1650, y: 490 },
        { type: 'trashCan',       x: 1750, y: 520 },
        { type: 'parkingMeter',   x: 1870, y: 455 },
        // Wave 3 zone — heavier objects, more reward
        { type: 'newspaperStand', x: 2700, y: 470 },
        { type: 'parkingMeter',   x: 2900, y: 510 },
        { type: 'trashCan',       x: 3020, y: 540 },
        { type: 'donutSign',    x: 3100, y: 460 },
        // Wave 4 / boss zone — one big smashable
        { type: 'donutSign',    x: 3600, y: 480 }
    ],

    // -----------------------------------------------------------------------
    // Environmental hazards — damage player AND enemies
    // Types: steamVent (periodic), radioactiveBarrel (constant),
    //        manhole (knockback burst every 5s)
    // -----------------------------------------------------------------------
    hazards: [
        // Wave 2 zone — introduce steam vent, player learns to avoid/exploit
        { type: 'steamVent',        x: 1700, y: 500 },
        // Wave 3 zone — radioactive barrel near heavy spawn for strategic throws
        { type: 'radioactiveBarrel', x: 2950, y: 490 },
        { type: 'manhole',          x: 3080, y: 510 },
        // Boss zone — manhole for knockback disruption during boss fight
        { type: 'steamVent',        x: 3700, y: 480 },
        { type: 'manhole',          x: 3900, y: 520 }
    ]
};

// ---------------------------------------------------------------------------
// All levels (add future levels here)
// ---------------------------------------------------------------------------

export const LEVELS = [LEVEL_1];
