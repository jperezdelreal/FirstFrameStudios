// Lightweight behavior tree AI with attack throttling.
// Max 2 enemies attack simultaneously; others circle and wait.
// Variant-specific behaviors: fast (hit-and-run), heavy (relentless approach + wind-up).

const MAX_ATTACKERS = 2;

export class AI {
    // --- Frame-level attacker tracking ---
    static activeAttackers = 0;
    static _frameId = -1;

    static _resetFrameIfNeeded() {
        const now = performance.now();
        if (AI._frameId !== now) {
            AI._frameId = now;
            AI.activeAttackers = 0;
        }
    }

    // ----------------------------------------------------------------
    // Behavior-tree condition helpers (return true/false)
    // ----------------------------------------------------------------

    static _inAttackRange(enemy, dx, dy, distance) {
        return distance < enemy.attackRange && Math.abs(dy) < 30;
    }

    static _tooClose(distance) {
        return distance < 60;
    }

    static _farAway(distance) {
        return distance > 150;
    }

    static _hasAttackSlot(enemy) {
        if (enemy.variant === 'boss') {
            enemy.hasAttackSlot = true;
            return true;
        }
        if (enemy.hasAttackSlot) return true;
        if (AI.activeAttackers < MAX_ATTACKERS) {
            AI.activeAttackers++;
            enemy.hasAttackSlot = true;
            return true;
        }
        return false;
    }

    static _releaseSlot(enemy) {
        if (enemy.hasAttackSlot) {
            enemy.hasAttackSlot = false;
            // activeAttackers is reset per-frame, no decrement needed
        }
    }

    // ----------------------------------------------------------------
    // Behavior-tree action leaves
    // ----------------------------------------------------------------

    static _attackPlayer(enemy, dt) {
        if (enemy.attackCooldown > 0) return false;

        // Heavy: telegraph wind-up before attack
        if (enemy.variant === 'heavy') {
            const attackDur = 0.5;
            enemy.windupTime = 0.5;
            enemy.state = 'windup';
            enemy.attackCooldown = enemy.configAttackCooldown;
            enemy.attackAnimDuration = attackDur;
            // C1+C3: aiCooldown covers windup + attack + post-attack pause
            enemy.aiCooldown = 0.5 + attackDur + enemy.configAiCooldown;
            return true;
        }

        if (enemy.variant === 'boss') {
            const attackDur = 0.5;
            enemy.state = 'attack';
            enemy.attackAnimTime = attackDur;
            enemy.attackAnimDuration = attackDur;
            enemy.attackCooldown = enemy.configAttackCooldown;
            enemy.aiCooldown = attackDur + enemy.configAiCooldown;
            enemy.attackDamage = enemy.damage;
            return true;
        }

        const attackDur = enemy.variant === 'fast' ? 0.25 : 0.4;
        enemy.state = 'attack';
        enemy.attackAnimTime = attackDur;
        enemy.attackAnimDuration = attackDur;
        enemy.attackCooldown = enemy.configAttackCooldown;
        // C1 fix: aiCooldown includes attack duration so state isn't reset mid-punch
        enemy.aiCooldown = attackDur + enemy.configAiCooldown;
        return true;
    }

    static _startBossCharge(enemy, dx, dy) {
        if (enemy.attackCooldown > 0 || enemy.chargeCooldown > 0) return false;

        enemy.state = 'charge_windup';
        enemy.chargeWindup = 0.5;
        enemy.chargeAngle = Math.atan2(dy * 0.6, dx);
        enemy.vx = 0;
        enemy.vy = 0;
        enemy.attackCooldown = enemy.configAttackCooldown + 0.4;
        enemy.aiCooldown = 0.5 + 0.5 + enemy.configAiCooldown;
        enemy.chargeCooldown = 2.5;
        enemy.attackDamage = 20;
        return true;
    }

    static _startBossSlam(enemy) {
        if (enemy.attackCooldown > 0 || enemy.slamCooldown > 0) return false;

        enemy.state = 'slam_windup';
        enemy.slamWindup = 0.3;
        enemy.vx = 0;
        enemy.vy = 0;
        enemy.attackCooldown = enemy.configAttackCooldown + 0.6;
        enemy.aiCooldown = 0.3 + 0.4 + enemy.configAiCooldown;
        enemy.slamCooldown = 3.2;
        enemy.attackDamage = 15;
        return true;
    }

    static _retreatFromPlayer(enemy, dx, dy, dt) {
        enemy.vx = dx < 0 ? enemy.speed : -enemy.speed;
        enemy.vy = dy < 0 ? enemy.speed * 0.6 : -enemy.speed * 0.6;
        enemy.state = 'walk';
        enemy.x += enemy.vx * dt;
        enemy.y += enemy.vy * dt;
        AI._releaseSlot(enemy);
        return true;
    }

    static _approachPlayer(enemy, dx, dy, dt) {
        const angle = Math.atan2(dy, dx);
        enemy.vx = Math.cos(angle) * enemy.speed;
        enemy.vy = Math.sin(angle) * enemy.speed * 0.6;
        enemy.state = 'walk';
        enemy.x += enemy.vx * dt;
        enemy.y += enemy.vy * dt;
        return true;
    }

    static _circlePlayer(enemy, player, dx, dy, distance, dt) {
        // Maintain a consistent circle direction per enemy
        if (!enemy.circleDirection) {
            enemy.circleDirection = Math.random() < 0.5 ? 1 : -1;
        }
        // Drift occasionally
        if (Math.random() < 0.005) {
            enemy.circleDirection *= -1;
        }

        const targetDist = 125;
        const perpAngle = Math.atan2(dy, dx) + (Math.PI / 2) * enemy.circleDirection;
        const radialAngle = Math.atan2(dy, dx);

        // Blend: mostly tangential, slight radial correction toward target distance
        const radialStrength = (distance - targetDist) / targetDist;
        const speed = enemy.speed * 0.45;
        enemy.vx = Math.cos(perpAngle) * speed + Math.cos(radialAngle) * speed * radialStrength;
        enemy.vy = Math.sin(perpAngle) * speed * 0.5 + Math.sin(radialAngle) * speed * 0.5 * radialStrength;
        enemy.state = 'walk';
        enemy.x += enemy.vx * dt;
        enemy.y += enemy.vy * dt;
        return true;
    }

    static _waitForSlot(enemy, player, dx, dy, distance, dt) {
        // No slot available — circle at medium range to create visual tension
        return AI._circlePlayer(enemy, player, dx, dy, distance, dt);
    }

    // ----------------------------------------------------------------
    // Variant-specific behavior trees
    // ----------------------------------------------------------------

    static _behaveDefault(enemy, player, dx, dy, distance, dt) {
        // 1. sequence(inRange, hasSlot, attack)
        if (AI._inAttackRange(enemy, dx, dy, distance)) {
            if (AI._hasAttackSlot(enemy)) {
                if (AI._attackPlayer(enemy, dt)) return;
            }
            // In range but no slot — wait nearby
            AI._waitForSlot(enemy, player, dx, dy, distance, dt);
            return;
        }

        // Not in attack range — release any held slot
        AI._releaseSlot(enemy);

        // 2. sequence(tooClose, retreat)
        if (AI._tooClose(distance)) {
            AI._retreatFromPlayer(enemy, dx, dy, dt);
            return;
        }

        // 3. Approach player to enter attack range
        AI._approachPlayer(enemy, dx, dy, dt);
    }

    static _behaveFast(enemy, player, dx, dy, distance, dt) {
        // Hit-and-run: after attacking, retreat to 200px before re-engaging
        if (enemy.retreating) {
            if (distance > 200) {
                enemy.retreating = false;
                enemy.aiCooldown = 0.3;
                enemy.state = 'idle';
                AI._releaseSlot(enemy);
            } else {
                AI._retreatFromPlayer(enemy, dx, dy, dt);
            }
            return;
        }

        if (AI._inAttackRange(enemy, dx, dy, distance)) {
            if (AI._hasAttackSlot(enemy)) {
                if (AI._attackPlayer(enemy, dt)) {
                    enemy.retreating = true;
                    return;
                }
            }
            AI._waitForSlot(enemy, player, dx, dy, distance, dt);
            return;
        }

        AI._releaseSlot(enemy);

        // Fast enemies dash straight in — no circling, no retreat
        AI._approachPlayer(enemy, dx, dy, dt);
    }

    static _behaveHeavy(enemy, player, dx, dy, distance, dt) {
        // Heavy: relentless approach, no retreat, no circling
        if (AI._inAttackRange(enemy, dx, dy, distance)) {
            if (AI._hasAttackSlot(enemy)) {
                if (AI._attackPlayer(enemy, dt)) return;
            }
            // Heavy stands ground when waiting for slot
            enemy.state = 'idle';
            return;
        }

        AI._releaseSlot(enemy);

        // Always approach — heavy never retreats or circles
        AI._approachPlayer(enemy, dx, dy, dt);
    }

    static _behaveBoss(enemy, player, dx, dy, distance, dt) {
        const inRange = AI._inAttackRange(enemy, dx, dy, distance);
        const midRange = distance < 220 && Math.abs(dy) < 40;

        if (enemy.phase === 3) {
            if (enemy.bossAttackToggle === 'charge' && midRange) {
                if (AI._startBossCharge(enemy, dx, dy)) {
                    enemy.bossAttackToggle = 'punch';
                    return;
                }
            }
            if (inRange && AI._hasAttackSlot(enemy)) {
                if (AI._attackPlayer(enemy, dt)) {
                    enemy.bossAttackToggle = 'charge';
                    return;
                }
            }
            if (enemy.bossAttackToggle === 'charge' && midRange) {
                if (AI._startBossCharge(enemy, dx, dy)) {
                    enemy.bossAttackToggle = 'punch';
                    return;
                }
            }
        } else if (enemy.phase === 2) {
            if (distance < 140 && Math.abs(dy) < 35) {
                if (AI._startBossSlam(enemy)) return;
            }
            if (inRange && AI._hasAttackSlot(enemy)) {
                if (AI._attackPlayer(enemy, dt)) return;
            }
            if (midRange && Math.random() < 0.7 * dt) {
                if (AI._startBossCharge(enemy, dx, dy)) return;
            }
        } else {
            if (inRange && AI._hasAttackSlot(enemy)) {
                if (AI._attackPlayer(enemy, dt)) return;
            }
            if (midRange && Math.random() < 0.6 * dt) {
                if (AI._startBossCharge(enemy, dx, dy)) return;
            }
        }

        AI._approachPlayer(enemy, dx, dy, dt);
    }

    // ----------------------------------------------------------------
    // Main update — called per-enemy from gameplay.js for-loop
    // ----------------------------------------------------------------

    static updateEnemy(enemy, player, dt) {
        AI._resetFrameIfNeeded();

        if (enemy.state === 'dead' || enemy.hitstunTime > 0) {
            AI._releaseSlot(enemy);
            return;
        }

        if (enemy.aiCooldown > 0) {
            // C1+C3: preserve windup/attack state for ALL enemies during AI cooldown
            if (enemy.state === 'windup' || enemy.state === 'attack' ||
                enemy.state === 'charge_windup' || enemy.state === 'charging' ||
                enemy.state === 'slam_windup' || enemy.state === 'slamming') {
                // Don't override — let attack/windup animate to completion
            } else {
                enemy.state = 'idle';
            }
            AI._releaseSlot(enemy);
            return;
        }

        const dx = player.x - enemy.x;
        const dy = player.y - enemy.y;
        const distance = Math.sqrt(dx * dx + dy * dy);

        // Face the player
        if (dx < 0) enemy.facing = -1;
        else if (dx > 0) enemy.facing = 1;

        // --- Variant-specific behavior dispatch ---
        switch (enemy.variant) {
            case 'fast':
                AI._behaveFast(enemy, player, dx, dy, distance, dt);
                break;
            case 'heavy':
                AI._behaveHeavy(enemy, player, dx, dy, distance, dt);
                break;
            case 'boss':
                AI._behaveBoss(enemy, player, dx, dy, distance, dt);
                break;
            default:
                AI._behaveDefault(enemy, player, dx, dy, distance, dt);
                break;
        }
    }
}
