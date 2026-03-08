import { ENEMY_TYPES } from '../data/levels.js';

export class Enemy {
    constructor(x, y, variant = 'normal') {
        const config = ENEMY_TYPES[variant] || ENEMY_TYPES.normal;

        this.x = x;
        this.y = y;
        this.width = config.width || 48;
        this.height = config.height || 76;
        this.vx = 0;
        this.vy = 0;
        this.speed = config.speed;
        this.baseSpeed = this.speed;
        
        this.variant = variant;
        this.health = config.hp;
        this.maxHealth = this.health;
        this.damage = config.damage;
        this.attackDamage = this.damage;
        this.attackRange = config.attackRange;
        this.configAttackCooldown = config.attackCooldown;
        this.configAiCooldown = config.aiCooldown;
        this.jumpHeight = 0;
        
        this.state = 'idle';
        this.facing = -1;
        this.animTime = 0;
        
        this.attackCooldown = 0;
        this.hitstunTime = 0;
        this.flashTime = 0;
        this.deathTime = 0;
        this.deathVx = 0;
        this.deathVy = 0;
        
        this.knockbackVx = 0;
        this.knockbackVy = 0;
        
        this.aiCooldown = 0;
        this.attackAnimTime = 0;
        this.attackAnimDuration = 0;
        this.invulnTime = 0;
        this.phaseFlashTime = 0;

        // Behavior-tree state (used by AI system)
        this.hasAttackSlot = false;
        this.circleDirection = Math.random() < 0.5 ? 1 : -1;

        // Heavy: super armor + wind-up telegraph
        if (variant === 'heavy') {
            this.armorHits = 0;
            this.armorBroken = false;
            this.armorTimer = 0;
            this.windupTime = 0;
        }

        // Fast: hit-and-run retreat flag
        if (variant === 'fast') {
            this.retreating = false;
        }

        // Boss: phase-based behavior and special attacks
        if (variant === 'boss') {
            this.phase = 1;
            this.phaseAddsSpawned = { 1: false, 2: false };
            this.pendingAdds = 0;
            this.chargeWindup = 0;
            this.chargeTime = 0;
            this.chargeAngle = 0;
            this.chargeVx = 0;
            this.chargeVy = 0;
            this.chargeCooldown = 0;
            this.slamWindup = 0;
            this.slamTime = 0;
            this.slamCooldown = 0;
            this.slamRadius = 120;
            this.slamImpactActive = false;
            this.slamImpactTriggered = false;
            this.bossAttackToggle = 'punch';
        }
    }

    update(dt) {
        this.animTime += dt;
        
        if (this.attackCooldown > 0) this.attackCooldown -= dt;
        if (this.hitstunTime > 0) this.hitstunTime -= dt;
        if (this.flashTime > 0) this.flashTime -= dt;
        if (this.aiCooldown > 0) this.aiCooldown -= dt;
        if (this.invulnTime > 0) this.invulnTime -= dt;
        if (this.phaseFlashTime > 0) this.phaseFlashTime -= dt;
        if (this.variant === 'boss') {
            if (this.chargeCooldown > 0) this.chargeCooldown -= dt;
            if (this.slamCooldown > 0) this.slamCooldown -= dt;
            this.slamImpactActive = false;
        }
        
        if (this.state === 'dead') {
            if (this.deathTime === 0) {
                this.deathVx = -this.facing * 200;
                this.deathVy = -150;
            }
            this.deathTime += dt;
            this.deathVy += 500 * dt;
            if (this.deathTime >= 0.2) {
                this.x += this.deathVx * dt;
                this.y += this.deathVy * dt;
            }
            return;
        }

        if (this.variant === 'boss') {
            const prevPhase = this.phase;
            if (this.health <= 75) this.phase = 3;
            else if (this.health <= 150) this.phase = 2;
            else this.phase = 1;

            if (this.phase !== prevPhase) {
                this.invulnTime = 0.5;
                this.phaseFlashTime = 0.5;
                this.speed = this.baseSpeed * (this.phase === 2 ? 1.5 : this.phase === 3 ? 2 : 1);
                this.state = 'idle';
                this.aiCooldown = Math.max(this.aiCooldown, 0.3);
            }

            if (this.phase === 1 && !this.phaseAddsSpawned[1]) {
                this.pendingAdds = 2;
                this.phaseAddsSpawned[1] = true;
            }
            if (this.phase === 2 && !this.phaseAddsSpawned[2]) {
                this.pendingAdds = 2;
                this.phaseAddsSpawned[2] = true;
            }
        }

        // Attack animation countdown — transition back to idle when done
        if (this.attackAnimTime > 0) {
            this.attackAnimTime -= dt;
            if (this.attackAnimTime <= 0 && this.state === 'attack') {
                this.state = 'idle';
                this.attackAnimTime = 0;
                this.attackDamage = this.damage;
            }
        }

        // Heavy wind-up: transition to attack when timer expires
        if (this.variant === 'heavy' && this.windupTime > 0) {
            this.windupTime -= dt;
            if (this.windupTime <= 0) {
                this.state = 'attack';
                this.windupTime = 0;
                // C3: set attack anim timer for the attack phase
                this.attackAnimTime = this.attackAnimDuration || 0.5;
            }
        }

        if (this.variant === 'boss' && this.hitstunTime <= 0) {
            if (this.chargeWindup > 0) {
                this.chargeWindup -= dt;
                if (this.chargeWindup <= 0) {
                    this.chargeWindup = 0;
                    this.state = 'charging';
                    this.chargeTime = 0.5;
                    const speed = 400;
                    this.chargeVx = Math.cos(this.chargeAngle) * speed;
                    this.chargeVy = Math.sin(this.chargeAngle) * speed;
                    this.attackDamage = 20;
                }
            }

            if (this.state === 'charging' && this.chargeTime > 0) {
                this.chargeTime -= dt;
                this.x += this.chargeVx * dt;
                this.y += this.chargeVy * dt;
                if (this.chargeTime <= 0) {
                    this.state = 'idle';
                    this.chargeTime = 0;
                    this.chargeVx = 0;
                    this.chargeVy = 0;
                    this.attackDamage = this.damage;
                }
            }

            if (this.slamWindup > 0) {
                this.slamWindup -= dt;
                if (this.slamWindup <= 0) {
                    this.slamWindup = 0;
                    this.state = 'slamming';
                    this.slamTime = 0.4;
                    this.slamImpactTriggered = false;
                    this.attackDamage = 15;
                }
            }

            if (this.state === 'slamming' && this.slamTime > 0) {
                this.slamTime -= dt;
                const progress = 1 - this.slamTime / 0.4;
                this.jumpHeight = Math.sin(progress * Math.PI) * 28;
                if (!this.slamImpactTriggered && this.slamTime <= 0.1) {
                    this.slamImpactTriggered = true;
                    this.slamImpactActive = true;
                }
                if (this.slamTime <= 0) {
                    this.state = 'idle';
                    this.slamTime = 0;
                    this.jumpHeight = 0;
                    this.attackDamage = this.damage;
                }
            } else if (this.state !== 'slamming') {
                this.jumpHeight = 0;
            }
        }

        // Heavy armor reset: if not hit for 2 seconds, armor resets
        if (this.variant === 'heavy' && this.armorHits > 0) {
            this.armorTimer -= dt;
            if (this.armorTimer <= 0) {
                this.armorHits = 0;
                this.armorBroken = false;
            }
        }
        
        // Apply knockback
        if (this.knockbackVx !== 0 || this.knockbackVy !== 0) {
            this.x += this.knockbackVx * dt;
            this.y += this.knockbackVy * dt;
            this.knockbackVx *= 0.85;
            this.knockbackVy *= 0.85;
            if (Math.abs(this.knockbackVx) < 10) this.knockbackVx = 0;
            if (Math.abs(this.knockbackVy) < 10) this.knockbackVy = 0;
        }
        
        if (this.hitstunTime > 0) {
            this.state = 'hit';
            this.vx = 0;
            this.vy = 0;
        } else if (this.state === 'hit') {
            this.state = 'idle';
        }
        
        // Keep in bounds
        this.y = Math.max(400, Math.min(600, this.y));
    }

    takeDamage(damage, knockbackX, knockbackY) {
        if (this.variant === 'boss' && this.invulnTime > 0) return;

        this.health -= damage;
        this.flashTime = 0.2;

        // Heavy super armor: absorb hits without hitstun until armor breaks
        if (this.variant === 'heavy' && !this.armorBroken) {
            this.armorHits++;
            this.armorTimer = 2.0;
            if (this.armorHits >= 3) {
                this.armorBroken = true;
                this.hitstunTime = 0.3;
                this.knockbackVx = knockbackX * 1.2;
                this.knockbackVy = knockbackY * 1.2;
            } else {
                // Absorb — reduced knockback, no hitstun
                this.knockbackVx = knockbackX * 0.3;
                this.knockbackVy = knockbackY * 0.3;
            }
        } else {
            this.hitstunTime = 0.2;
            this.knockbackVx = knockbackX;
            this.knockbackVy = knockbackY;
        }
        
        if (this.health <= 0) {
            this.health = 0;
            this.state = 'dead';
        }
    }

    getHurtbox() {
        if (this.state === 'dead') return null;
        
        return {
            x: this.x + 8,
            y: this.y + 8,
            width: this.width - 16,
            height: this.height - 8
        };
    }

    getAttackHitbox() {
        if (this.variant === 'boss' && this.state === 'charging') {
            const hitW = 70;
            const hitH = 60;
            return {
                x: this.x + (this.facing > 0 ? this.width - 10 : -hitW + 10),
                y: this.y + 25,
                width: hitW,
                height: hitH
            };
        }

        if (this.state !== 'attack') return null;
        if (this.attackAnimDuration <= 0) return null;

        // C2 fix: hitbox active during middle 30%-70% of attack animation
        const elapsed = this.attackAnimDuration - this.attackAnimTime;
        const fraction = elapsed / this.attackAnimDuration;
        if (fraction < 0.3 || fraction > 0.7) return null;

        const hitW = this.variant === 'heavy' ? 45 :
            (this.variant === 'fast' ? 28 : (this.variant === 'boss' ? 55 : 35));
        const hitH = this.variant === 'heavy' ? 45 :
            (this.variant === 'fast' ? 28 : (this.variant === 'boss' ? 55 : 35));

        return {
            x: this.x + (this.facing > 0 ? this.width : -hitW),
            y: this.y + 20,
            width: hitW,
            height: hitH
        };
    }

    render(ctx) {
        let deathRotation = 0;
        let deathAlpha = 1;
        if (this.state === 'dead') {
            if (this.deathTime < 0.2) {
                deathRotation = (this.deathTime / 0.2) * Math.PI * 2;
            } else if (this.deathTime >= 0.5) {
                const fadeProgress = Math.min(1, (this.deathTime - 0.5) / 0.3);
                deathRotation = fadeProgress * Math.PI * 3;
                deathAlpha = Math.max(0, 1 - fadeProgress);
            }
            ctx.globalAlpha = deathAlpha;
        }

        const drawY = this.y - (this.jumpHeight || 0);
        
        // Shadow
        ctx.fillStyle = 'rgba(0, 0, 0, 0.3)';
        ctx.beginPath();
        ctx.ellipse(this.x + this.width / 2, this.y + this.height - 5,
                     this.width * 0.42, 8, 0, 0, Math.PI * 2);
        ctx.fill();
        
        // Flash white when hit
        if (this.flashTime > 0) {
            ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
            ctx.fillRect(this.x, drawY, this.width, this.height);
        }

        if (this.variant === 'boss' && this.phaseFlashTime > 0 && Math.floor(this.phaseFlashTime * 20) % 2 === 0) {
            ctx.fillStyle = 'rgba(255, 255, 255, 0.6)';
            ctx.fillRect(this.x, drawY, this.width, this.height);
        }
        
        ctx.save();
        if (this.facing < 0) {
            ctx.translate(this.x + this.width, drawY);
            ctx.scale(-1, 1);
        } else {
            ctx.translate(this.x, drawY);
        }

        // Scale drawing to entity dimensions (base: 48x76)
        const sx = this.width / 48;
        const sy = this.height / 76;
        ctx.scale(sx, sy);
        if (this.state === 'dead' && deathRotation !== 0) {
            ctx.translate(24, 38);
            ctx.rotate(deathRotation);
            ctx.translate(-24, -38);
        }
        
        // Consistent outline style (art-direction: 2px #222222, round caps)
        ctx.strokeStyle = '#222222';
        ctx.lineWidth = 2;
        ctx.lineJoin = 'round';
        ctx.lineCap = 'round';

        const variant = this.variant;
        const isBoss = variant === 'boss';
        const isHeavy = variant === 'heavy' || isBoss;
        const isFast = variant === 'fast';
        const skin = '#FFB6C1';
        const bodyColors = {
            normal: '#663399',
            tough: '#8B0000',
            fast: '#2196F3',
            heavy: '#2E7D32',
            boss: '#F57C00'
        };
        const outfit = bodyColors[variant] || bodyColors.normal;
        const pants = isBoss ? '#1E88E5' : (variant === 'heavy' ? '#1E1E1E' : (isFast ? '#1B2735' : '#333333'));
        const accent = isBoss ? '#BF360C' : (isFast ? '#1565C0' : (variant === 'heavy' ? '#1B5E20' : '#4B2A6F'));
        const shoe = isBoss ? '#F5F5F5' : (isFast ? '#F5F5F5' : '#2B2B2B');
        const lean = isFast ? -0.12 : (this.state === 'hit' ? 0.1 : 0);

        ctx.save();
        ctx.translate(24, 44);
        ctx.rotate(lean);
        ctx.translate(-24, -44);

        // Legs
        const legW = isHeavy ? 10 : (isFast ? 6 : 8);
        const legH = isHeavy ? 14 : 12;
        const legGap = isHeavy ? 6 : 4;
        const walkBob = this.state === 'walk' ? Math.sin(this.animTime * 8) * 2 : 0;
        const leftLegX = 24 - legGap - legW;
        const rightLegX = 24 + legGap;
        ctx.fillStyle = pants;
        ctx.beginPath();
        ctx.rect(leftLegX, 60 + walkBob, legW, legH);
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        ctx.rect(rightLegX, 60 - walkBob, legW, legH);
        ctx.fill();
        ctx.stroke();

        // Shoes / sneakers
        ctx.fillStyle = shoe;
        ctx.beginPath();
        ctx.rect(leftLegX - 1, 72 + walkBob, legW + 3, 4);
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        ctx.rect(rightLegX - 1, 72 - walkBob, legW + 3, 4);
        ctx.fill();
        ctx.stroke();
        // Shoe soles — darker line at bottom
        const soleFill = isBoss ? '#AAAAAA' : '#111111';
        ctx.fillStyle = soleFill;
        ctx.beginPath();
        ctx.rect(leftLegX - 1, 74 + walkBob, legW + 3, 2);
        ctx.fill();
        ctx.beginPath();
        ctx.rect(rightLegX - 1, 74 - walkBob, legW + 3, 2);
        ctx.fill();
        if (isFast) {
            ctx.strokeStyle = accent;
            ctx.lineWidth = 1.5;
            ctx.beginPath();
            ctx.moveTo(leftLegX, 74 + walkBob);
            ctx.lineTo(leftLegX + legW, 74 + walkBob);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(rightLegX, 74 - walkBob);
            ctx.lineTo(rightLegX + legW, 74 - walkBob);
            ctx.stroke();
            // Sneaker lace detail
            ctx.fillStyle = '#FFFFFF';
            ctx.beginPath();
            ctx.arc(leftLegX + legW / 2, 73 + walkBob, 1, 0, Math.PI * 2);
            ctx.fill();
            ctx.beginPath();
            ctx.arc(leftLegX + legW / 2 - 2, 73 + walkBob, 0.8, 0, Math.PI * 2);
            ctx.fill();
            ctx.beginPath();
            ctx.arc(rightLegX + legW / 2, 73 - walkBob, 1, 0, Math.PI * 2);
            ctx.fill();
            ctx.beginPath();
            ctx.arc(rightLegX + legW / 2 - 2, 73 - walkBob, 0.8, 0, Math.PI * 2);
            ctx.fill();
            ctx.strokeStyle = '#222222';
            ctx.lineWidth = 2;
        }

        // Torso
        const torsoW = isHeavy ? 30 : (isFast ? 16 : 20);
        const torsoH = isHeavy ? 34 : (isFast ? 30 : 32);
        const torsoX = 24 - torsoW / 2;
        const torsoY = 26;
        ctx.fillStyle = outfit;
        ctx.beginPath();
        if (isHeavy) {
            ctx.moveTo(torsoX, torsoY);
            ctx.lineTo(torsoX + torsoW, torsoY);
            ctx.lineTo(torsoX + torsoW - 2, torsoY + torsoH);
            ctx.lineTo(torsoX + 2, torsoY + torsoH);
            ctx.closePath();
        } else {
            ctx.rect(torsoX, torsoY, torsoW, torsoH);
        }
        ctx.fill();
        ctx.stroke();
        ctx.fillStyle = 'rgba(255, 255, 255, 0.12)';
        ctx.fillRect(torsoX + 2, torsoY + 2, torsoW * 0.4, torsoH * 0.35);
        // Boss vest — open jacket with darker edge lapels and white undershirt
        if (isBoss) {
            ctx.strokeStyle = '#BF360C';
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.moveTo(torsoX + 4, torsoY);
            ctx.lineTo(torsoX + 8, torsoY + 12);
            ctx.lineTo(torsoX + 4, torsoY + torsoH);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(torsoX + torsoW - 4, torsoY);
            ctx.lineTo(torsoX + torsoW - 8, torsoY + 12);
            ctx.lineTo(torsoX + torsoW - 4, torsoY + torsoH);
            ctx.stroke();
            ctx.fillStyle = '#FFFFFF';
            ctx.beginPath();
            ctx.moveTo(torsoX + 8, torsoY);
            ctx.lineTo(24, torsoY + 10);
            ctx.lineTo(torsoX + torsoW - 8, torsoY);
            ctx.closePath();
            ctx.fill();
            ctx.strokeStyle = '#222222';
            ctx.lineWidth = 2;
        }

        // Heavy tank top straps
        if (variant === 'heavy') {
            ctx.strokeStyle = '#1B5E20';
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.moveTo(torsoX + 4, torsoY);
            ctx.lineTo(torsoX + 6, torsoY + 6);
            ctx.moveTo(torsoX + torsoW - 4, torsoY);
            ctx.lineTo(torsoX + torsoW - 6, torsoY + 6);
            ctx.stroke();
            ctx.strokeStyle = '#222222';
            ctx.lineWidth = 2;
        }

        // Arms (fighting stance)
        ctx.fillStyle = skin;
        const armW = isHeavy ? 9 : (isFast ? 5 : 7);
        const armLen = isHeavy ? 20 : (isFast ? 14 : 16);
        const armY = isHeavy ? 32 : 30;
        ctx.beginPath();
        ctx.rect(torsoX - armW + 1, armY, armW, armLen);
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        ctx.rect(torsoX + torsoW - 1, armY, armW, armLen);
        ctx.fill();
        ctx.stroke();
        const fistR = isHeavy ? 5 : (isFast ? 3 : 4);
        ctx.beginPath();
        ctx.arc(torsoX - armW / 2 + 1, armY + armLen + 2, fistR, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(torsoX + torsoW + armW / 2 - 1, armY + armLen + 2, fistR, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();

        // Attack animation
        if (this.state === 'attack') {
            ctx.fillStyle = skin;
            const punchLen = isHeavy ? 18 : 14;
            ctx.beginPath();
            ctx.rect(torsoX + torsoW, armY + 6, punchLen, armW);
            ctx.fill();
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(torsoX + torsoW + punchLen + fistR, armY + 6 + armW / 2,
                    fistR + 1, 0, Math.PI * 2);
            ctx.fill();
            ctx.stroke();
        }

        // Wind-up telegraph (heavy only)
        if (this.state === 'windup') {
            const pulse = 0.5 + Math.sin(this.animTime * 15) * 0.5;
            ctx.fillStyle = `rgba(255, 50, 50, ${0.2 + pulse * 0.3})`;
            ctx.beginPath();
            ctx.arc(34, 34, 10 + pulse * 4, 0, Math.PI * 2);
            ctx.fill();
        }

        if (this.variant === 'boss' && (this.state === 'charge_windup' || this.state === 'slam_windup')) {
            const pulse = 0.5 + Math.sin(this.animTime * 12) * 0.5;
            ctx.fillStyle = `rgba(255, 80, 20, ${0.2 + pulse * 0.35})`;
            ctx.beginPath();
            ctx.arc(24, 38, 12 + pulse * 5, 0, Math.PI * 2);
            ctx.fill();
        }

        // Hoodie for fast variant (draw behind head)
        if (isFast) {
            ctx.fillStyle = accent;
            ctx.beginPath();
            ctx.arc(24, 17, 13, Math.PI * 0.9, Math.PI * 2.1);
            ctx.fill();
            ctx.stroke();
        }

        // Neck (heavy/boss variants — thick visible neck)
        if (isHeavy) {
            ctx.fillStyle = skin;
            const neckW = isBoss ? 14 : 12;
            ctx.beginPath();
            ctx.rect(24 - neckW / 2, 22, neckW, 8);
            ctx.fill();
            ctx.stroke();
        }

        // Head
        const headR = isHeavy ? 11 : (isFast ? 9 : 10);
        ctx.fillStyle = skin;
        ctx.beginPath();
        ctx.arc(24, 17, headR, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();
        ctx.fillStyle = 'rgba(255, 255, 255, 0.15)';
        ctx.beginPath();
        ctx.arc(21, 14, 5, 0, Math.PI * 2);
        ctx.fill();

        // Head accessories
        if (isBoss) {
            ctx.fillStyle = '#2B2B2B';
            ctx.beginPath();
            ctx.moveTo(12, 10);
            ctx.lineTo(18, 3);
            ctx.lineTo(22, 10);
            ctx.closePath();
            ctx.fill();
            ctx.beginPath();
            ctx.moveTo(26, 10);
            ctx.lineTo(30, 2);
            ctx.lineTo(36, 10);
            ctx.closePath();
            ctx.fill();
        }
        if (variant === 'heavy') {
            // Red bandana
            ctx.fillStyle = '#B71C1C';
            ctx.beginPath();
            ctx.rect(12, 12, 24, 5);
            ctx.fill();
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(36, 12);
            ctx.lineTo(42, 9);
            ctx.lineTo(40, 16);
            ctx.closePath();
            ctx.fill();
            ctx.stroke();
        }
        // Normal variant: purple baseball cap
        if (variant === 'normal') {
            ctx.fillStyle = '#4A2D7A';
            ctx.beginPath();
            ctx.arc(24, 11, 11, Math.PI, 0);
            ctx.fill();
            ctx.stroke();
            ctx.fillStyle = '#3A1D6A';
            ctx.beginPath();
            ctx.moveTo(13, 12);
            ctx.lineTo(38, 12);
            ctx.quadraticCurveTo(40, 12, 40, 14);
            ctx.lineTo(13, 14);
            ctx.closePath();
            ctx.fill();
            ctx.stroke();
        }
        // Tough variant: goatee
        if (variant === 'tough') {
            ctx.fillStyle = '#333333';
            ctx.beginPath();
            ctx.ellipse(24, 30, 3, 2.5, 0, 0, Math.PI * 2);
            ctx.fill();
        }

        // Eyes
        const drawXEye = (x, y, size) => {
            ctx.beginPath();
            ctx.moveTo(x - size, y - size);
            ctx.lineTo(x + size, y + size);
            ctx.moveTo(x + size, y - size);
            ctx.lineTo(x - size, y + size);
            ctx.stroke();
        };
        if (this.state === 'dead') {
            ctx.strokeStyle = '#222222';
            ctx.lineWidth = 2;
            const eyeSize = variant === 'fast' ? 4 : 3;
            drawXEye(20, 17, eyeSize);
            drawXEye(28, 17, eyeSize);
        } else if (variant === 'fast') {
            ctx.fillStyle = '#FFFFFF';
            ctx.beginPath();
            ctx.ellipse(20, 17, 4, 4.5, 0, 0, Math.PI * 2);
            ctx.fill();
            ctx.stroke();
            ctx.beginPath();
            ctx.ellipse(28, 17, 4, 4.5, 0, 0, Math.PI * 2);
            ctx.fill();
            ctx.stroke();
            ctx.fillStyle = '#000000';
            ctx.beginPath();
            ctx.arc(20, 18, 2, 0, Math.PI * 2);
            ctx.fill();
            ctx.beginPath();
            ctx.arc(28, 18, 2, 0, Math.PI * 2);
            ctx.fill();
        } else {
            ctx.fillStyle = '#FFFFFF';
            ctx.beginPath();
            ctx.ellipse(20, 17, 3, 3.5, 0, 0, Math.PI * 2);
            ctx.fill();
            ctx.stroke();
            ctx.beginPath();
            ctx.ellipse(28, 17, 3, 3.5, 0, 0, Math.PI * 2);
            ctx.fill();
            ctx.stroke();
            ctx.fillStyle = '#000000';
            ctx.beginPath();
            ctx.arc(20, 18, 1.5, 0, Math.PI * 2);
            ctx.fill();
            ctx.beginPath();
            ctx.arc(28, 18, 1.5, 0, Math.PI * 2);
            ctx.fill();
        }

        // Eyebrows
        ctx.strokeStyle = '#222222';
        ctx.lineWidth = 2.5;
        if (this.state !== 'dead') {
            if (isBoss) {
                ctx.beginPath();
                ctx.moveTo(14, 11);
                ctx.lineTo(22, 13);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(34, 11);
                ctx.lineTo(26, 13);
                ctx.stroke();
            } else if (variant === 'heavy') {
                ctx.beginPath();
                ctx.moveTo(16, 12);
                ctx.lineTo(22, 13);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(32, 12);
                ctx.lineTo(26, 13);
                ctx.stroke();
            } else if (variant === 'fast') {
                ctx.beginPath();
                ctx.moveTo(16, 11);
                ctx.lineTo(22, 10);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(32, 11);
                ctx.lineTo(26, 10);
                ctx.stroke();
            } else {
                ctx.beginPath();
                ctx.moveTo(15, 12);
                ctx.lineTo(22, 14);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(33, 12);
                ctx.lineTo(26, 14);
                ctx.stroke();
            }
        }

        // Mouth
        ctx.strokeStyle = '#222222';
        ctx.lineWidth = 2;
        ctx.beginPath();
        if (variant === 'fast') {
            ctx.arc(24, 24, 4, 0, Math.PI);
        } else {
            ctx.arc(24, 25, 5, 0.1, Math.PI - 0.1);
        }
        ctx.stroke();

        // Tough scar
        if (variant === 'tough') {
            ctx.strokeStyle = '#C96D6D';
            ctx.lineWidth = 1.5;
            ctx.beginPath();
            ctx.moveTo(18, 20);
            ctx.lineTo(30, 24);
            ctx.stroke();
            ctx.strokeStyle = '#222222';
            ctx.lineWidth = 2;
        }

        if (isBoss && this.phase >= 2) {
            const flash = this.phase === 3 ? Math.floor(this.animTime * 8) % 2 === 0 : true;
            if (flash) {
                const alpha = this.phase === 2 ? 0.18 : 0.35;
                ctx.fillStyle = `rgba(255, 60, 60, ${alpha})`;
                ctx.fillRect(0, 0, 48, 76);
            }
        }

        ctx.restore();
        
        ctx.restore();
        
        if (this.state === 'dead') {
            ctx.globalAlpha = 1;
        }
    }
}
