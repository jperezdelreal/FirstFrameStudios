export class Combat {
    static checkCollision(box1, box2) {
        if (!box1 || !box2) return false;
        
        return box1.x < box2.x + box2.width &&
               box1.x + box1.width > box2.x &&
               box1.y < box2.y + box2.height &&
               box1.y + box1.height > box2.y;
    }

    static handlePlayerAttack(player, enemies, audio, renderer) {
        player.nearbyEnemies = enemies;
        const hits = [];
        let totalScore = 0;

        if (player.pummelRequest && player.grabbedEnemy && player.grabbedEnemy.state !== 'dead') {
            const enemy = player.grabbedEnemy;
            enemy.takeDamage(8, 0, 0);
            player.comboCount++;
            player.comboTimer = 0;
            totalScore += 8;

            if (enemy.health <= 0) {
                audio.playKO();
            } else {
                audio.playHit(player.comboCount);
            }

            const hitX = (player.x + player.width / 2 + enemy.x + enemy.width / 2) / 2;
            const hitY = (player.y + player.height / 2 + enemy.y + enemy.height / 2) / 2;
            hits.push({ x: hitX, y: hitY, intensity: 'light', damage: 8 });
            renderer.screenShake(2, 0.05);
        }
        player.pummelRequest = false;

        if (player.throwRequest) {
            const { enemy, direction } = player.throwRequest;
            if (enemy && enemy.state !== 'dead') {
                enemy.takeDamage(20, direction * 200, 0);
                enemy.knockbackVx = direction * 1800;
                enemy.knockbackVy = 0;
                enemy.hitstunTime = Math.max(enemy.hitstunTime || 0, 0.4);
                enemy.throwing = true;
                enemy.throwDirection = direction;
                enemy.throwStartX = enemy.x;
                enemy.throwHitList = new Set();
                enemy.isGrabbed = false;
                enemy.grabbedBy = null;
                enemy.state = 'hit';

                player.comboCount++;
                player.comboTimer = 0;
                totalScore += 20;

                if (enemy.health <= 0) {
                    audio.playKO();
                } else {
                    audio.playHit(player.comboCount);
                }

                const hitX = (player.x + player.width / 2 + enemy.x + enemy.width / 2) / 2;
                const hitY = (player.y + player.height / 2 + enemy.y + enemy.height / 2) / 2;
                hits.push({ x: hitX, y: hitY, intensity: 'heavy', damage: 20 });
                renderer.screenShake(4, 0.1);
            }
        }
        player.throwRequest = null;

        for (const enemy of enemies) {
            if (!enemy || enemy.state === 'dead' || !enemy.throwing) continue;
            const projectileBox = enemy.getHurtbox();
            if (!projectileBox) continue;

            const travel = enemy.throwStartX !== undefined ? Math.abs(enemy.x - enemy.throwStartX) : 0;
            if (travel >= 200 || Math.abs(enemy.knockbackVx) < 20) {
                enemy.throwing = false;
                continue;
            }

            for (const other of enemies) {
                if (!other || other === enemy || other.state === 'dead') continue;
                if (enemy.throwHitList && enemy.throwHitList.has(other)) continue;
                const hurtbox = other.getHurtbox();
                if (this.checkCollision(projectileBox, hurtbox)) {
                    const knockbackX = (enemy.throwDirection || 1) * 200;
                    const knockbackY = (other.y - enemy.y) * 1.5;
                    other.takeDamage(15, knockbackX, knockbackY);
                    if (!enemy.throwHitList) enemy.throwHitList = new Set();
                    enemy.throwHitList.add(other);
                    totalScore += 15;

                    if (other.health <= 0) {
                        audio.playKO();
                    } else {
                        audio.playHit(player.comboCount);
                    }

                    const hitX = (enemy.x + enemy.width / 2 + other.x + other.width / 2) / 2;
                    const hitY = (enemy.y + enemy.height / 2 + other.y + other.height / 2) / 2;
                    hits.push({ x: hitX, y: hitY, intensity: 'medium', damage: 15 });
                    renderer.screenShake(3, 0.08);
                }
            }
        }

        const attackBox = player.getAttackHitbox();
        if (!attackBox) return { score: totalScore, hits };

        let hitCount = 0;

        // Base damage and knockback by attack type
        const attackStats = {
            'punch':       { damage: 10, knockback: 150, score: 10 },
            'kick':        { damage: 15, knockback: 250, score: 20 },
            'jump_punch':  { damage: 10, knockback: 150, score: 10 },
            'jump_kick':   { damage: 20, knockback: 300, score: 25 },
            'belly_bump':  { damage: 25, knockback: 300, score: 30 },
            'ground_slam': { damage: 20, knockback: 200, score: 25 },
            'back_attack': { damage: 12, knockback: 180, score: 12 }
        };
        const stats = attackStats[player.state] || attackStats['punch'];

        // Combo damage scaling: +10% per combo hit, capped at 2x
        const comboMultiplier = Math.min(2, 1 + (player.comboCount * 0.1));
        let damage = Math.round(stats.damage * comboMultiplier);
        let knockbackForce = stats.knockback;

        // Combo finisher: punch-punch-kick gets 1.5x knockback
        const chain = player.comboChain;
        const isFinisher = chain.length >= 3 &&
            chain[chain.length - 3] === 'punch' &&
            chain[chain.length - 2] === 'punch' &&
            chain[chain.length - 1] === 'kick';
        if (isFinisher) {
            knockbackForce = Math.round(knockbackForce * 1.5);
        }

        for (const enemy of enemies) {
            if (enemy.state === 'dead' || enemy.state === 'grabbed') continue;
            if (player.attackHitList.has(enemy)) continue;

            const hurtbox = enemy.getHurtbox();
            if (this.checkCollision(attackBox, hurtbox)) {
                let knockbackX = player.facing * knockbackForce;
                let knockbackY = (enemy.y - player.y) * 2;

                // Dive kick pushes enemies downward
                if (player.state === 'jump_kick') {
                    knockbackY = 100;
                }

                // Ground slam pushes enemies away from player center
                if (player.state === 'ground_slam') {
                    knockbackX = (enemy.x > player.x) ? knockbackForce : -knockbackForce;
                }

                enemy.takeDamage(damage, knockbackX, knockbackY);
                player.attackHitList.add(enemy);
                player.comboCount++;
                player.comboTimer = 0;
                hitCount++;

                if (enemy.health <= 0) {
                    audio.playKO();
                } else {
                    audio.playHit(player.comboCount);
                }

                const isSpecialMove = player.state === 'belly_bump' || player.state === 'ground_slam';
                renderer.screenShake((isFinisher || isSpecialMove) ? 6 : 3, (isFinisher || isSpecialMove) ? 0.15 : 0.1);

                const hitX = (player.x + player.width / 2 + enemy.x + enemy.width / 2) / 2;
                const hitY = (player.y + player.height / 2 + enemy.y + enemy.height / 2) / 2;
                const intensity = (isFinisher || isSpecialMove) ? 'heavy' :
                    (player.state === 'kick' || player.state === 'jump_kick' || player.state === 'back_attack') ? 'medium' : 'light';
                hits.push({ x: hitX, y: hitY, intensity, damage });
            }
        }

        totalScore += hitCount > 0 ? hitCount * stats.score : 0;
        return { score: totalScore, hits };
    }

    static handleEnemyAttacks(enemies, player, audio) {
        for (const enemy of enemies) {
            if (enemy.state === 'grabbed' || enemy.isGrabbed) {
                enemy.vx = 0;
                enemy.vy = 0;
                enemy.knockbackVx = 0;
                enemy.knockbackVy = 0;
                continue;
            }
            if (enemy.throwing) continue;

            if (enemy.variant === 'boss' && enemy.state === 'slamming' && enemy.slamImpactActive) {
                const dx = (player.x + player.width / 2) - (enemy.x + enemy.width / 2);
                const dy = (player.y + player.height / 2) - (enemy.y + enemy.height / 2);
                const distance = Math.sqrt(dx * dx + dy * dy);
                if (distance <= enemy.slamRadius) {
                    const force = 180;
                    const dirX = distance > 0 ? dx / distance : 0;
                    const dirY = distance > 0 ? dy / distance : 0;
                    const knockbackX = dirX * force;
                    const knockbackY = dirY * force;
                    player.takeDamage(enemy.attackDamage || enemy.damage || 5, knockbackX, knockbackY);
                    audio.playHit();
                }
                enemy.slamImpactActive = false;
            }

            if (enemy.state !== 'attack' && enemy.state !== 'charging') continue;
            
            const attackBox = enemy.getAttackHitbox();
            if (!attackBox) continue;
            
            const playerHurtbox = player.getHurtbox();
            if (this.checkCollision(attackBox, playerHurtbox)) {
                const knockbackForce = enemy.state === 'charging' ? 200 : 100;
                const knockbackX = enemy.facing * knockbackForce;
                const knockbackY = (player.y - enemy.y) * 1.5;
                
                player.takeDamage(enemy.attackDamage || enemy.damage || 5, knockbackX, knockbackY);
                audio.playHit();
            }
        }

        if (player.grabbedEnemy && player.grabbedEnemy.state !== 'dead') {
            const grabbed = player.grabbedEnemy;
            const offsetX = player.facing > 0 ? player.width - 12 : -grabbed.width + 12;
            grabbed.x = player.x + offsetX;
            grabbed.y = player.y;
            grabbed.state = 'grabbed';
            grabbed.isGrabbed = true;
            grabbed.grabbedBy = player;
            grabbed.vx = 0;
            grabbed.vy = 0;
            grabbed.knockbackVx = 0;
            grabbed.knockbackVy = 0;
        }
    }

    static cleanupDeadEnemies(enemies) {
        return enemies.filter(enemy => {
            if (enemy.state === 'dead' && enemy.deathTime > 0.5) {
                return false;
            }
            return true;
        });
    }
}
