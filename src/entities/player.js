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
        
        // Lives system
        this.lives = 3;
        
        // Special move cooldown
        this.specialCooldown = 0;
    }

    update(dt, input) {
        this.animTime += dt;
        
        // Update cooldowns
        if (this.attackCooldown > 0) this.attackCooldown -= dt;
        if (this.hitstunTime > 0) this.hitstunTime -= dt;
        if (this.flashTime > 0) this.flashTime -= dt;
        if (this.invulnTime > 0) this.invulnTime -= dt;
        if (this.specialCooldown > 0) this.specialCooldown -= dt;
        
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
                if (this.state === 'jump' || this.state === 'jump_punch' || this.state === 'jump_kick' || this.state === 'ground_slam') {
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
                    // Belly bump — forward + punch during combo (3+ hits)
                    if (this.specialCooldown <= 0 && this.comboCount >= 3 && input.isPunch() &&
                        ((this.facing === 1 && input.isRight()) || (this.facing === -1 && input.isLeft()))) {
                        this.state = 'belly_bump';
                        this.attackCooldown = 0.4;
                        this.specialCooldown = 1.5;
                        this.attackHitList.clear();
                        this.x += this.facing * 100;
                        this.comboChain.push('punch');
                        this.comboTimer = 0;
                        return { type: 'belly_bump', combo: this.comboCount };
                    }
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
            
            // Ground slam — down + punch while airborne
            if (this.state === 'jump' && this.jumpHeight > 0 && this.attackCooldown <= 0 &&
                input.isMovingDown() && input.isPunch()) {
                this.state = 'ground_slam';
                this.attackCooldown = 0.4;
                this.attackHitList.clear();
                this.jumpHeight = 0;
                this.jumpVelocity = 0;
                this.comboTimer = 0;
                return { type: 'ground_slam', combo: this.comboCount };
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
            if (this.state === 'belly_bump' && this.attackCooldown <= 0.15) {
                this.state = 'idle';
            }
            if (this.state === 'ground_slam' && this.attackCooldown <= 0.15) {
                this.state = 'idle';
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
            if (this.lives > 0) {
                this.lives--;
                this.health = 100;
                this.invulnTime = 2.0;
                this.state = 'idle';
                this.hitstunTime = 0;
                this.knockbackVx = 0;
                this.knockbackVy = 0;
            } else {
                this.state = 'dead';
            }
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
        // Belly bump: wide frontal hitbox
        if (this.state === 'belly_bump' && this.attackCooldown > 0.15) {
            return {
                x: this.x + (this.facing > 0 ? this.width - 10 : -70),
                y: this.y + 15,
                width: 80,
                height: 50
            };
        }
        // Ground slam: large shockwave centered on player
        if (this.state === 'ground_slam' && this.attackCooldown > 0.15) {
            return {
                x: this.x + this.width / 2 - 100,
                y: this.y - 10,
                width: 200,
                height: 80
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
        
        // Consistent outline style (art-direction: 2px #222222, round caps)
        ctx.strokeStyle = '#222222';
        ctx.lineWidth = 2;
        ctx.lineJoin = 'round';
        ctx.lineCap = 'round';
        
        // Body (white shirt) — bulging belly path
        ctx.fillStyle = '#F5F5F5';
        ctx.beginPath();
        ctx.moveTo(18, 35);
        ctx.lineTo(46, 35);
        ctx.lineTo(48, 48);
        ctx.quadraticCurveTo(52, 58, 46, 65);
        ctx.lineTo(18, 65);
        ctx.quadraticCurveTo(12, 58, 16, 48);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();
        // Subtle highlight on upper-left of shirt
        ctx.fillStyle = 'rgba(255, 255, 255, 0.15)';
        ctx.beginPath();
        ctx.arc(26, 44, 10, Math.PI, 0);
        ctx.fill();
        
        // Pants (blue)
        ctx.fillStyle = '#4169E1';
        ctx.beginPath();
        ctx.rect(18, 65, 28, 13);
        ctx.fill();
        ctx.stroke();
        
        // Shoes (brown)
        ctx.fillStyle = '#8B4513';
        ctx.beginPath();
        ctx.rect(16, 78, 14, 5);
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        ctx.rect(34, 78, 14, 5);
        ctx.fill();
        ctx.stroke();
        
        // Head (yellow)
        ctx.fillStyle = '#FED90F';
        ctx.beginPath();
        ctx.arc(32, 20, 16, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();
        // Head highlight
        ctx.fillStyle = 'rgba(255, 255, 255, 0.15)';
        ctx.beginPath();
        ctx.arc(28, 14, 7, 0, Math.PI * 2);
        ctx.fill();
        
        // Hair spikes (M-shape — 3 brown triangles on crown)
        ctx.fillStyle = '#8B4513';
        ctx.beginPath();
        ctx.moveTo(23, 7);
        ctx.lineTo(26, 0);
        ctx.lineTo(29, 7);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        ctx.moveTo(29, 6);
        ctx.lineTo(32, -1);
        ctx.lineTo(35, 6);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        ctx.moveTo(35, 7);
        ctx.lineTo(38, 0);
        ctx.lineTo(41, 7);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();
        
        // Eyes
        ctx.fillStyle = '#FFFFFF';
        ctx.beginPath();
        ctx.ellipse(28, 18, 4, 5, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        ctx.ellipse(36, 18, 4, 5, 0, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();
        
        ctx.fillStyle = '#000000';
        ctx.beginPath();
        ctx.arc(29, 19, 2, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(37, 19, 2, 0, Math.PI * 2);
        ctx.fill();
        
        // Mouth
        ctx.strokeStyle = '#222222';
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        ctx.arc(32, 27, 5, 0.15, Math.PI - 0.15);
        ctx.stroke();
        // Overbite bump
        ctx.fillStyle = '#FED90F';
        ctx.beginPath();
        ctx.arc(32, 30, 3, 0, Math.PI);
        ctx.fill();
        ctx.lineWidth = 1.5;
        ctx.stroke();
        
        // Reset outline for limbs
        ctx.strokeStyle = '#222222';
        ctx.lineWidth = 2;
        
        // Arms (yellow)
        ctx.fillStyle = '#FED90F';
        const armBob = Math.sin(this.animTime * 8) * 2;
        ctx.beginPath();
        ctx.rect(10, 40 + armBob, 8, 20);
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        ctx.rect(46, 40 - armBob, 8, 20);
        ctx.fill();
        ctx.stroke();
        
        // Punch animation
        if (this.state === 'punch') {
            ctx.beginPath();
            ctx.rect(46, 45, 15, 8);
            ctx.fill();
            ctx.stroke();
        }
        
        // Kick animation — leg extends forward at an angle from the hip
        if (this.state === 'kick' && this.attackCooldown > 0.2) {
            ctx.fillStyle = '#4169E1';
            ctx.save();
            ctx.translate(46, 70);
            ctx.rotate(Math.PI / 6);
            ctx.beginPath();
            ctx.rect(0, -5, 28, 10);
            ctx.fill();
            ctx.stroke();
            ctx.fillStyle = '#8B4513';
            ctx.beginPath();
            ctx.rect(26, -6, 10, 12);
            ctx.fill();
            ctx.stroke();
            ctx.restore();
        }
        
        // Jump punch — arm extends forward in air
        if (this.state === 'jump_punch') {
            ctx.fillStyle = '#FED90F';
            ctx.beginPath();
            ctx.rect(46, 40, 18, 8);
            ctx.fill();
            ctx.stroke();
        }
        
        // Jump kick (dive kick) — leg extends diagonally downward
        if (this.state === 'jump_kick') {
            ctx.fillStyle = '#4169E1';
            ctx.save();
            ctx.translate(46, 65);
            ctx.rotate(Math.PI / 4);
            ctx.beginPath();
            ctx.rect(0, -5, 30, 10);
            ctx.fill();
            ctx.stroke();
            ctx.fillStyle = '#8B4513';
            ctx.beginPath();
            ctx.rect(28, -6, 10, 12);
            ctx.fill();
            ctx.stroke();
            ctx.restore();
        }
        
        // Belly bump — belly extends forward, arms swept back
        if (this.state === 'belly_bump' && this.attackCooldown > 0.15) {
            ctx.fillStyle = '#F5F5F5';
            ctx.beginPath();
            ctx.ellipse(54, 52, 16, 12, 0, 0, Math.PI * 2);
            ctx.fill();
            ctx.stroke();
            ctx.fillStyle = '#FED90F';
            ctx.beginPath();
            ctx.rect(2, 44, 10, 8);
            ctx.fill();
            ctx.stroke();
        }
        
        // Ground slam — arms spread wide, shockwave ring
        if (this.state === 'ground_slam' && this.attackCooldown > 0.15) {
            ctx.fillStyle = '#FED90F';
            ctx.beginPath();
            ctx.rect(-4, 40, 16, 8);
            ctx.fill();
            ctx.stroke();
            ctx.beginPath();
            ctx.rect(52, 40, 16, 8);
            ctx.fill();
            ctx.stroke();
            ctx.strokeStyle = '#FFD700';
            ctx.lineWidth = 3;
            ctx.beginPath();
            ctx.ellipse(32, 78, 40, 10, 0, 0, Math.PI * 2);
            ctx.stroke();
        }
        
        ctx.restore();
    }
}
