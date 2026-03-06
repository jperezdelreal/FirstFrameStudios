// Lightweight behavior tree AI with attack throttling.
// Max 2 enemies attack simultaneously; others circle and wait.

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
        const range = enemy.variant === 'tough' ? 90 : 80;
        return distance < range && Math.abs(dy) < 30;
    }

    static _tooClose(distance) {
        return distance < 60;
    }

    static _farAway(distance) {
        return distance > 150;
    }

    static _hasAttackSlot(enemy) {
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
        enemy.state = 'attack';
        const cooldown = enemy.variant === 'tough' ? 1.0 : 1.5;
        enemy.attackCooldown = cooldown;
        enemy.aiCooldown = enemy.variant === 'tough' ? 0.3 : 0.5;
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
    // Main update — called per-enemy from gameplay.js for-loop
    // ----------------------------------------------------------------

    static updateEnemy(enemy, player, dt) {
        AI._resetFrameIfNeeded();

        if (enemy.state === 'dead' || enemy.hitstunTime > 0) {
            AI._releaseSlot(enemy);
            return;
        }

        if (enemy.aiCooldown > 0) {
            enemy.state = 'idle';
            AI._releaseSlot(enemy);
            return;
        }

        const dx = player.x - enemy.x;
        const dy = player.y - enemy.y;
        const distance = Math.sqrt(dx * dx + dy * dy);

        // Face the player
        if (dx < 0) enemy.facing = -1;
        else if (dx > 0) enemy.facing = 1;

        // --- Behavior tree selector (first success wins) ---

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

        // 3. sequence(farAway, approach)
        if (AI._farAway(distance)) {
            AI._approachPlayer(enemy, dx, dy, dt);
            return;
        }

        // 4. fallback — circle player
        AI._circlePlayer(enemy, player, dx, dy, distance, dt);
    }
}
