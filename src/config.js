/**
 * Central configuration for all tunable gameplay values.
 *
 * Migration guide — files that should import CONFIG:
 *   - src/entities/player.js  → player.speed, player.depthSpeed, player.jumpPower, player.health
 *                                combat.punchCooldown, combat.kickCooldown, combat.hitstun, combat.invulnTime
 *   - src/entities/enemy.js   → enemy.normalHP, enemy.toughHP, enemy.speed, enemy.attackCooldown
 *                                level.groundYMin, level.groundYMax
 *   - src/systems/combat.js   → combat.punchDamage, combat.kickDamage, combat.punchKnockback, combat.kickKnockback
 *   - src/scenes/gameplay.js  → level.width, level.groundYMin, level.groundYMax
 *                                hitlag.playerHit, hitlag.enemyHit
 */
export const CONFIG = {
    player: {
        speed: 200,
        depthSpeed: 120,
        jumpPower: 400,
        health: 100
    },
    combat: {
        punchDamage: 10,
        kickDamage: 15,
        punchCooldown: 0.3,
        kickCooldown: 0.5,
        punchKnockback: 150,
        kickKnockback: 250,
        hitstun: 0.2,
        invulnTime: 0.5
    },
    enemy: {
        normalHP: 30,
        toughHP: 50,
        speed: 100,
        attackCooldown: 1.5
    },
    level: {
        width: 4000,
        groundYMin: 400,
        groundYMax: 600
    },
    hitlag: {
        playerHit: 3,
        enemyHit: 2
    }
};
