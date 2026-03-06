export class Combat {
    static checkCollision(box1, box2) {
        if (!box1 || !box2) return false;
        
        return box1.x < box2.x + box2.width &&
               box1.x + box1.width > box2.x &&
               box1.y < box2.y + box2.height &&
               box1.y + box1.height > box2.y;
    }

    static handlePlayerAttack(player, enemies, audio, renderer) {
        const attackBox = player.getAttackHitbox();
        if (!attackBox) return { score: 0, hits: [] };
        
        let hitCount = 0;
        const hits = [];
        
        // Base damage and knockback by attack type
        const attackStats = {
            'punch':      { damage: 10, knockback: 150, score: 10 },
            'kick':       { damage: 15, knockback: 250, score: 20 },
            'jump_punch': { damage: 10, knockback: 150, score: 10 },
            'jump_kick':  { damage: 20, knockback: 300, score: 25 }
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
            if (enemy.state === 'dead') continue;
            if (player.attackHitList.has(enemy)) continue;
            
            const hurtbox = enemy.getHurtbox();
            if (this.checkCollision(attackBox, hurtbox)) {
                const knockbackX = player.facing * knockbackForce;
                let knockbackY = (enemy.y - player.y) * 2;
                
                // Dive kick pushes enemies downward
                if (player.state === 'jump_kick') {
                    knockbackY = 100;
                }
                
                enemy.takeDamage(damage, knockbackX, knockbackY);
                player.attackHitList.add(enemy);
                player.comboCount++;
                player.comboTimer = 0;
                hitCount++;
                
                if (enemy.health <= 0) {
                    audio.playKO();
                } else {
                    audio.playHit();
                }
                
                renderer.screenShake(isFinisher ? 6 : 3, isFinisher ? 0.15 : 0.1);
                
                const hitX = (player.x + player.width / 2 + enemy.x + enemy.width / 2) / 2;
                const hitY = (player.y + player.height / 2 + enemy.y + enemy.height / 2) / 2;
                const intensity = isFinisher ? 'heavy' :
                    (player.state === 'kick' || player.state === 'jump_kick') ? 'medium' : 'light';
                hits.push({ x: hitX, y: hitY, intensity, damage });
            }
        }
        
        return { score: hitCount > 0 ? hitCount * stats.score : 0, hits };
    }

    static handleEnemyAttacks(enemies, player, audio) {
        for (const enemy of enemies) {
            if (enemy.state !== 'attack') continue;
            
            const attackBox = enemy.getAttackHitbox();
            if (!attackBox) continue;
            
            const playerHurtbox = player.getHurtbox();
            if (this.checkCollision(attackBox, playerHurtbox)) {
                const knockbackX = enemy.facing * 100;
                const knockbackY = (player.y - enemy.y) * 1.5;
                
                player.takeDamage(5, knockbackX, knockbackY);
                audio.playHit();
            }
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
