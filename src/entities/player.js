export class Player {
    constructor(x, y) {
        this.x = x;
        this.y = y;
        this.width = 64;
        this.height = 80;
        this.vx = 0;
        this.vy = 0;
        this.speed = 200;
        this.depthSpeed = 120;
        
        this.health = 100;
        this.maxHealth = 100;
        
        this.state = 'idle';
        this.facing = 1; // 1 = right, -1 = left
        this.animTime = 0;
        
        this.attackCooldown = 0;
        this.hitstunTime = 0;
        this.flashTime = 0;
        this.attackHitList = new Set();
        this.invulnTime = 0;
        
        // Jump state
        this.jumpVelocity = 0;
        this.jumpHeight = 0;
        this.gravity = 800;
        this.jumpPower = 400;
        
        this.knockbackVx = 0;
        this.knockbackVy = 0;
        
        // Combo state (public — UI can read comboCount for display)
        this.comboCount = 0;
        this.comboTimer = 0;
        this.comboWindow = 0.6;
        this.comboChain = [];
    }

    update(dt, input) {
        this.animTime += dt;
        
        // Update cooldowns
        if (this.attackCooldown > 0) this.attackCooldown -= dt;
        if (this.hitstunTime > 0) this.hitstunTime -= dt;
        if (this.flashTime > 0) this.flashTime -= dt;
        if (this.invulnTime > 0) this.invulnTime -= dt;
        
        // Update combo timer — reset combo if window expires
        this.comboTimer += dt;
        if (this.comboTimer > this.comboWindow) {
            this.comboCount = 0;
            this.comboChain = [];
        }
        
        // Apply knockback
        if (this.knockbackVx !== 0 || this.knockbackVy !== 0) {
            this.x += this.knockbackVx * dt;
            this.y += this.knockbackVy * dt;
            this.knockbackVx *= 0.9;
            this.knockbackVy *= 0.9;
            if (Math.abs(this.knockbackVx) < 10) this.knockbackVx = 0;
            if (Math.abs(this.knockbackVy) < 10) this.knockbackVy = 0;
        }
        
        // Handle jump physics
        if (this.jumpHeight > 0 || this.jumpVelocity !== 0) {
            this.jumpVelocity -= this.gravity * dt;
            this.jumpHeight += this.jumpVelocity * dt;
            
            if (this.jumpHeight <= 0) {
                this.jumpHeight = 0;
                this.jumpVelocity = 0;
                if (this.state === 'jump' || this.state === 'jump_punch' || this.state === 'jump_kick') {
                    this.state = 'idle';
                }
            }
        }
        
        // Handle input when not in hitstun
        if (this.hitstunTime <= 0) {
            if (this.state === 'idle' || this.state === 'walk') {
                // Movement
                this.vx = 0;
                this.vy = 0;
                
                if (input.isLeft()) {
                    this.vx = -this.speed;
                    this.facing = -1;
                }
                if (input.isRight()) {
                    this.vx = this.speed;
                    this.facing = 1;
                }
                if (input.isUp()) {
                    this.vy = -this.depthSpeed;
                }
                if (input.isMovingDown()) {
                    this.vy = this.depthSpeed;
                }
                
                // Update state based on movement
                if (this.vx !== 0 || this.vy !== 0) {
                    this.state = 'walk';
                } else {
                    this.state = 'idle';
                }
                
                // Jump
                if (input.isJump() && this.jumpHeight === 0) {
                    this.jumpVelocity = this.jumpPower;
                    this.state = 'jump';
                }
                
                // Attacks
                if (this.attackCooldown <= 0) {
                    if (input.isPunch()) {
                        this.state = 'punch';
                        this.attackCooldown = 0.3;
                        this.attackHitList.clear();
                        this.comboChain.push('punch');
                        this.comboTimer = 0;
                        return { type: 'punch', combo: this.comboCount };
                    }
                    if (input.isKick()) {
                        this.state = 'kick';
                        this.attackCooldown = 0.5;
                        this.attackHitList.clear();
                        this.comboChain.push('kick');
                        this.comboTimer = 0;
                        return { type: 'kick', combo: this.comboCount };
                    }
                }
            }
            
            // Air attacks while jumping
            if (this.state === 'jump' && this.attackCooldown <= 0) {
                if (input.isPunch()) {
                    this.state = 'jump_punch';
                    this.attackCooldown = 0.2;
                    this.attackHitList.clear();
                    this.comboChain.push('punch');
                    this.comboTimer = 0;
                    return { type: 'jump_punch', combo: this.comboCount };
                }
                if (input.isKick()) {
                    this.state = 'jump_kick';
                    this.attackCooldown = 0.4;
                    this.attackHitList.clear();
                    this.jumpVelocity = -800;
                    this.comboChain.push('kick');
                    this.comboTimer = 0;
                    return { type: 'jump_kick', combo: this.comboCount };
                }
            }
            
            // Return to idle after attack
            if (this.state === 'punch' && this.attackCooldown <= 0.15) {
                this.state = 'idle';
            }
            if (this.state === 'kick' && this.attackCooldown <= 0.2) {
                this.state = 'idle';
            }
            if (this.state === 'jump_punch' && this.attackCooldown <= 0.05) {
                this.state = this.jumpHeight > 0 ? 'jump' : 'idle';
            }
        } else {
            this.state = 'hit';
            this.vx = 0;
            this.vy = 0;
        }
        
        // Apply movement
        this.x += this.vx * dt;
        this.y += this.vy * dt;
        
        // Keep in bounds
        this.y = Math.max(400, Math.min(600, this.y));
        
        return null;
    }

    takeDamage(damage, knockbackX, knockbackY) {
        if (this.invulnTime > 0) return;
        
        this.health -= damage;
        this.hitstunTime = 0.2;
        this.flashTime = 0.2;
        this.invulnTime = 0.5;
        this.knockbackVx = knockbackX;
        this.knockbackVy = knockbackY;
        
        if (this.health <= 0) {
            this.health = 0;
            this.state = 'dead';
        }
    }

    getAttackHitbox() {
        if (this.state === 'punch' && this.attackCooldown > 0.15) {
            return {
                x: this.x + (this.facing > 0 ? this.width : -40),
                y: this.y + 20,
                width: 40,
                height: 40
            };
        }
        if (this.state === 'kick' && this.attackCooldown > 0.25) {
            return {
                x: this.x + (this.facing > 0 ? this.width : -60),
                y: this.y + 30,
                width: 60,
                height: 30
            };
        }
        // Jump punch: wider arc in front
        if (this.state === 'jump_punch' && this.attackCooldown > 0.05) {
            return {
                x: this.x + (this.facing > 0 ? this.width - 10 : -40),
                y: this.y + 10 - this.jumpHeight,
                width: 50,
                height: 40
            };
        }
        // Jump kick (dive kick): extends below and in front of player
        if (this.state === 'jump_kick' && this.attackCooldown > 0.1) {
            return {
                x: this.x + (this.facing > 0 ? this.width - 20 : -50),
                y: this.y + 20 - this.jumpHeight,
                width: 70,
                height: 50
            };
        }
        return null;
    }

    getHurtbox() {
        return {
            x: this.x + 10,
            y: this.y + 10 - this.jumpHeight,
            width: this.width - 20,
            height: this.height - 10
        };
    }

    render(ctx) {
        const drawY = this.y - this.jumpHeight;
        
        // Shadow
        ctx.fillStyle = 'rgba(0, 0, 0, 0.3)';
        ctx.beginPath();
        ctx.ellipse(this.x + this.width / 2, this.y + this.height - 5, 25, 10, 0, 0, Math.PI * 2);
        ctx.fill();
        
        // Blink during invulnerability
        if (this.invulnTime > 0 && Math.floor(this.invulnTime * 10) % 2 === 0) {
            return;
        }
        
        // Flash white when hit
        if (this.flashTime > 0) {
            ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
            ctx.fillRect(this.x, drawY, this.width, this.height);
        }
        
        ctx.save();
        if (this.facing < 0) {
            ctx.translate(this.x + this.width, drawY);
            ctx.scale(-1, 1);
        } else {
            ctx.translate(this.x, drawY);
        }
        
        // Body (white shirt)
        ctx.fillStyle = '#FFFFFF';
        ctx.fillRect(18, 35, 28, 30);
        
        // Pants (blue)
        ctx.fillStyle = '#4682B4';
        ctx.fillRect(18, 65, 28, 15);
        
        // Head (yellow)
        ctx.fillStyle = '#FED90F';
        ctx.beginPath();
        ctx.arc(32, 20, 16, 0, Math.PI * 2);
        ctx.fill();
        
        // Eyes
        ctx.fillStyle = '#FFFFFF';
        ctx.beginPath();
        ctx.ellipse(28, 18, 4, 5, 0, 0, Math.PI * 2);
        ctx.ellipse(36, 18, 4, 5, 0, 0, Math.PI * 2);
        ctx.fill();
        
        ctx.fillStyle = '#000000';
        ctx.beginPath();
        ctx.arc(28, 19, 2, 0, Math.PI * 2);
        ctx.arc(36, 19, 2, 0, Math.PI * 2);
        ctx.fill();
        
        // Arms (yellow)
        ctx.fillStyle = '#FED90F';
        const armBob = Math.sin(this.animTime * 8) * 2;
        ctx.fillRect(10, 40 + armBob, 8, 20);
        ctx.fillRect(46, 40 - armBob, 8, 20);
        
        // Punch animation
        if (this.state === 'punch') {
            ctx.fillRect(46, 45, 15, 8);
        }
        
        // Kick animation — leg extends forward at an angle from the hip
        if (this.state === 'kick' && this.attackCooldown > 0.2) {
            ctx.fillStyle = '#4682B4';
            ctx.save();
            ctx.translate(46, 70);
            ctx.rotate(Math.PI / 6);
            ctx.fillRect(0, -5, 28, 10);
            ctx.fillStyle = '#808080';
            ctx.fillRect(26, -6, 10, 12);
            ctx.restore();
        }
        
        // Jump punch — arm extends forward in air
        if (this.state === 'jump_punch') {
            ctx.fillStyle = '#FED90F';
            ctx.fillRect(46, 40, 18, 8);
        }
        
        // Jump kick (dive kick) — leg extends diagonally downward
        if (this.state === 'jump_kick') {
            ctx.fillStyle = '#4682B4';
            ctx.save();
            ctx.translate(46, 65);
            ctx.rotate(Math.PI / 4);
            ctx.fillRect(0, -5, 30, 10);
            ctx.fillStyle = '#808080';
            ctx.fillRect(28, -6, 10, 12);
            ctx.restore();
        }
        
        ctx.restore();
    }
}
