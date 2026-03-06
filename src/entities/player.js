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

        // Style tracking — unique attack types used in current streak
        this.styleTypes = new Set();
        
        // Lives system
        this.lives = 3;
        
        // Special move cooldown
        this.specialCooldown = 0;

        // Grab/throw state
        this.grabbedEnemy = null;
        this.grabTimer = 0;
        this.pummelCount = 0;
        this.grabPummelCooldown = 0;
        this.pummelRequest = false;
        this.throwRequest = null;
        this.throwTimer = 0;

        // Dodge roll state
        this.dodgeCooldown = 0;
        this.dodgeElapsed = 0;
        this.dodgeRecovery = 0;
        this.dodgeDirection = 0;
        this.leftTapTimer = 0;
        this.rightTapTimer = 0;
        this.doubleTapWindow = 0.2;

        // Back attack state
        this.backAttackFacing = null;

        // Cached enemies for proximity checks
        this.nearbyEnemies = [];
    }

    update(dt, input) {
        this.animTime += dt;
        
        // Update cooldowns
        if (this.attackCooldown > 0) this.attackCooldown -= dt;
        if (this.hitstunTime > 0) this.hitstunTime -= dt;
        if (this.flashTime > 0) this.flashTime -= dt;
        if (this.invulnTime > 0) this.invulnTime -= dt;
        if (this.specialCooldown > 0) this.specialCooldown -= dt;
        if (this.dodgeCooldown > 0) this.dodgeCooldown -= dt;
        if (this.dodgeRecovery > 0) this.dodgeRecovery -= dt;
        if (this.leftTapTimer > 0) this.leftTapTimer -= dt;
        if (this.rightTapTimer > 0) this.rightTapTimer -= dt;
        if (this.grabPummelCooldown > 0) this.grabPummelCooldown -= dt;
        if (this.throwTimer > 0) this.throwTimer -= dt;

        this.pummelRequest = false;
        this.throwRequest = null;
        
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
        
        const dodgeSpeed = 120 / 0.4;
        const enemies = this.nearbyEnemies || [];
        const playerCenterX = this.x + this.width / 2;
        const playerCenterY = this.y + this.height / 2;
        const findClosestEnemy = (range, behindOnly = false, frontOnly = false) => {
            let closest = null;
            let closestDist = Infinity;
            for (const enemy of enemies) {
                if (!enemy || enemy.state === 'dead') continue;
                if (enemy === this.grabbedEnemy) continue;
                const enemyCenterX = enemy.x + enemy.width / 2;
                const enemyCenterY = enemy.y + enemy.height / 2;
                const dx = enemyCenterX - playerCenterX;
                const dy = enemyCenterY - playerCenterY;
                const distance = Math.hypot(dx, dy);
                if (distance > range) continue;
                const behind = dx * this.facing < 0;
                if (behindOnly && !behind) continue;
                if (frontOnly && behind) continue;
                if (distance < closestDist) {
                    closest = enemy;
                    closestDist = distance;
                }
            }
            return closest;
        };

        const startDodge = (direction) => {
            if (this.dodgeCooldown > 0) return false;
            this.state = 'dodging';
            this.dodgeDirection = direction;
            this.dodgeElapsed = 0;
            this.dodgeRecovery = 0;
            this.dodgeCooldown = 0.5;
            if (direction !== 0) {
                this.facing = direction;
            }
            return true;
        };

        const releaseGrab = () => {
            if (this.grabbedEnemy) {
                this.grabbedEnemy.isGrabbed = false;
                this.grabbedEnemy.grabbedBy = null;
                if (this.grabbedEnemy.state !== 'dead') {
                    this.grabbedEnemy.state = 'idle';
                }
            }
            this.grabbedEnemy = null;
            this.grabTimer = 0;
            this.pummelCount = 0;
        };

        const syncGrabbedEnemy = () => {
            if (!this.grabbedEnemy) return;
            const enemy = this.grabbedEnemy;
            const offsetX = this.facing > 0 ? this.width - 12 : -enemy.width + 12;
            enemy.x = this.x + offsetX;
            enemy.y = this.y;
            enemy.state = 'grabbed';
            enemy.isGrabbed = true;
            enemy.grabbedBy = this;
            enemy.vx = 0;
            enemy.vy = 0;
            enemy.knockbackVx = 0;
            enemy.knockbackVy = 0;
        };

        // Handle input when not in hitstun
        if (this.hitstunTime <= 0) {
            // Recover from hit state once hitstun expires
            if (this.state === 'hit') {
                this.state = 'idle';
            }

            if (this.state === 'dodging') {
                this.dodgeElapsed += dt;
                this.vx = this.dodgeDirection * dodgeSpeed;
                this.vy = 0;
                if (this.dodgeElapsed >= 0.4) {
                    this.state = 'dodge_recovery';
                    this.dodgeRecovery = 0.15;
                    this.dodgeElapsed = 0;
                    this.vx = 0;
                }
            } else if (this.state === 'dodge_recovery') {
                this.vx = 0;
                this.vy = 0;
                if (this.dodgeRecovery <= 0) {
                    this.state = 'idle';
                }
            } else if (this.state === 'throwing') {
                this.vx = 0;
                this.vy = 0;
                if (this.throwTimer <= 0) {
                    this.state = 'idle';
                }
            } else if (this.state === 'grabbing') {
                this.vx = 0;
                this.vy = 0;
                if (!this.grabbedEnemy || this.grabbedEnemy.state === 'dead') {
                    releaseGrab();
                    this.state = 'idle';
                } else {
                    this.grabTimer += dt;
                    syncGrabbedEnemy();
                    const forward = (this.facing === 1 && input.isRight()) || (this.facing === -1 && input.isLeft());
                    const back = (this.facing === 1 && input.isLeft()) || (this.facing === -1 && input.isRight());
                    const attackPressed = input.isPunch() || input.isKick();
                    if (attackPressed && this.grabPummelCooldown <= 0) {
                        if (forward || back) {
                            const direction = forward ? this.facing : -this.facing;
                            this.throwRequest = { enemy: this.grabbedEnemy, direction };
                            releaseGrab();
                            this.state = 'throwing';
                            this.throwTimer = 0.3;
                            this.grabTimer = 0;
                            this.grabPummelCooldown = 0.15;
                        } else {
                            this.pummelCount++;
                            this.pummelRequest = true;
                            this.grabTimer = 0;
                            this.grabPummelCooldown = 0.15;
                            if (this.pummelCount >= 3) {
                                this.throwRequest = { enemy: this.grabbedEnemy, direction: this.facing };
                                releaseGrab();
                                this.state = 'throwing';
                                this.throwTimer = 0.3;
                            }
                        }
                    }
                    if (this.grabTimer >= 1.5) {
                        releaseGrab();
                        this.state = 'idle';
                    }
                }
            } else if (this.state === 'back_attack') {
                this.vx = 0;
                this.vy = 0;
            } else if (this.state === 'idle' || this.state === 'walk') {
                const leftTap = input.isPressed('KeyA') || input.isPressed('ArrowLeft');
                const rightTap = input.isPressed('KeyD') || input.isPressed('ArrowRight');
                if (leftTap) {
                    if (this.leftTapTimer > 0) {
                        startDodge(-1);
                    }
                    this.leftTapTimer = this.doubleTapWindow;
                }
                if (rightTap) {
                    if (this.rightTapTimer > 0) {
                        startDodge(1);
                    }
                    this.rightTapTimer = this.doubleTapWindow;
                }
                if (input.isDodge()) {
                    const dir = input.isLeft() ? -1 : (input.isRight() ? 1 : this.facing);
                    startDodge(dir);
                }

                if (this.state !== 'dodging') {
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
                    
                    // Attacks — check buffer alongside live input (AAA-C9)
                    if (this.attackCooldown <= 0) {
                        const buffered = input.consumeBuffer();
                        const wantsPunch = input.isPunch() || buffered === 'punch';
                        const wantsKick = input.isKick() || buffered === 'kick';
                        const backAttackTarget = findClosestEnemy(60, true, false);
                        const grabTarget = findClosestEnemy(40, false, true);
                        const attackPressed = wantsPunch || wantsKick;

                        if (input.isGrab() && grabTarget) {
                            this.state = 'grabbing';
                            this.grabbedEnemy = grabTarget;
                            this.grabTimer = 0;
                            this.pummelCount = 0;
                            this.grabPummelCooldown = 0;
                            syncGrabbedEnemy();
                            return null;
                        }

                        if (backAttackTarget && attackPressed) {
                            this.state = 'back_attack';
                            this.attackCooldown = 0.25;
                            this.attackHitList.clear();
                            this.comboChain.push('back_attack');
                            this.styleTypes.add('back_attack');
                            this.comboTimer = 0;
                            this.backAttackFacing = this.facing;
                            this.facing *= -1;
                            return { type: 'back_attack', combo: this.comboCount };
                        }

                        // Belly bump — forward + punch during combo (3+ hits)
                        if (this.specialCooldown <= 0 && this.comboCount >= 3 && wantsPunch &&
                            ((this.facing === 1 && input.isRight()) || (this.facing === -1 && input.isLeft()))) {
                            this.state = 'belly_bump';
                            this.attackCooldown = 0.4;
                            this.specialCooldown = 1.5;
                            this.attackHitList.clear();
                            this.x += this.facing * 100;
                            this.comboChain.push('punch');
                            this.styleTypes.add('special');
                            this.comboTimer = 0;
                            return { type: 'belly_bump', combo: this.comboCount };
                        }
                        if (grabTarget && attackPressed) {
                            this.state = 'grabbing';
                            this.grabbedEnemy = grabTarget;
                            this.grabTimer = 0;
                            this.pummelCount = 0;
                            this.grabPummelCooldown = 0;
                            syncGrabbedEnemy();
                            return null;
                        }
                        if (wantsPunch) {
                            this.state = 'punch';
                            this.attackCooldown = 0.3;
                            this.attackHitList.clear();
                            this.comboChain.push('punch');
                            this.styleTypes.add('punch');
                            this.comboTimer = 0;
                            return { type: 'punch', combo: this.comboCount };
                        }
                        if (wantsKick) {
                            this.state = 'kick';
                            this.attackCooldown = 0.5;
                            this.attackHitList.clear();
                            this.comboChain.push('kick');
                            this.styleTypes.add('kick');
                            this.comboTimer = 0;
                            return { type: 'kick', combo: this.comboCount };
                        }
                    }
                } else {
                    this.vx = this.dodgeDirection * dodgeSpeed;
                    this.vy = 0;
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
                this.styleTypes.add('special');
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
                    this.styleTypes.add('jump_attack');
                    this.comboTimer = 0;
                    return { type: 'jump_punch', combo: this.comboCount };
                }
                if (input.isKick()) {
                    this.state = 'jump_kick';
                    this.attackCooldown = 0.4;
                    this.attackHitList.clear();
                    this.jumpVelocity = -800;
                    this.comboChain.push('kick');
                    this.styleTypes.add('jump_attack');
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
            if (this.state === 'back_attack' && this.attackCooldown <= 0.05) {
                this.state = 'idle';
                if (this.backAttackFacing !== null) {
                    this.facing = this.backAttackFacing;
                    this.backAttackFacing = null;
                }
            }
        } else {
            this.state = 'hit';
            this.vx = 0;
            this.vy = 0;
            this.dodgeElapsed = 0;
            if (this.grabbedEnemy) {
                this.grabbedEnemy.isGrabbed = false;
                this.grabbedEnemy.grabbedBy = null;
                if (this.grabbedEnemy.state !== 'dead') {
                    this.grabbedEnemy.state = 'idle';
                }
                this.grabbedEnemy = null;
                this.grabTimer = 0;
                this.pummelCount = 0;
            }
            if (this.backAttackFacing !== null) {
                this.facing = this.backAttackFacing;
                this.backAttackFacing = null;
            }
            input.clearBuffer();
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
        if (this.state === 'dodging' && this.dodgeElapsed >= 0.05 && this.dodgeElapsed <= 0.25) return;
        
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
        if (this.state === 'back_attack' && this.attackCooldown > 0.05) {
            return {
                x: this.x + (this.facing > 0 ? this.width : -40),
                y: this.y + 25,
                width: 40,
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
        const isIdle = this.state === 'idle';
        const isWalk = this.state === 'walk';
        const isPunch = this.state === 'punch';
        const isKick = this.state === 'kick';
        const isJump = this.state === 'jump';
        const isJumpPunch = this.state === 'jump_punch';
        const isJumpKick = this.state === 'jump_kick';
        const isBelly = this.state === 'belly_bump';
        const isSlam = this.state === 'ground_slam';
        const isBackAttack = this.state === 'back_attack';
        const isGrab = this.state === 'grabbing';
        const isThrow = this.state === 'throwing';
        const isDodge = this.state === 'dodging';
        const isDodgeRecovery = this.state === 'dodge_recovery';
        const isHit = this.state === 'hit';
        const isRolling = isDodge || isDodgeRecovery;
        const walkFrame = isWalk ? Math.floor(this.animTime / 0.15) % 4 : 0;
        const walkBob = isWalk ? (walkFrame % 2 === 0 ? 1 : -1) : 0;
        const drawY = this.y - this.jumpHeight + walkBob;
        
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

        // Scale drawing to entity dimensions (base: 64x80)
        const sx = this.width / 64;
        const sy = this.height / 80;
        ctx.scale(sx, sy);

        if (isRolling) {
            const rollSquash = 0.85 + Math.sin(this.animTime * 20) * 0.05;
            const rollStretch = 1.15;
            ctx.translate(32, 50);
            ctx.scale(rollStretch, rollSquash);
            ctx.translate(-32, -50);
        }
        
        // Consistent outline style (art-direction: 2px #222222, round caps)
        ctx.strokeStyle = '#222222';
        ctx.lineWidth = 2;
        ctx.lineJoin = 'round';
        ctx.lineCap = 'round';
        
        const skin = '#FED90F';
        const shirt = '#F5F5DC';
        const pants = '#4169E1';
        const shoes = '#8B4513';
        const lips = '#F4A6A6';
        const breath = isIdle ? 1 + Math.sin(this.animTime * 2) * 0.015 : 1;
        const legLift = (isJump || isJumpPunch || isJumpKick || isSlam) ? -6 : (isRolling ? -2 : 0);
        const legBack = isBelly ? -4 : 0;

        const drawShoe = (x, y, width, height) => {
            ctx.beginPath();
            ctx.moveTo(x + 2, y);
            ctx.lineTo(x + width - 2, y);
            ctx.quadraticCurveTo(x + width, y, x + width, y + 2);
            ctx.lineTo(x + width, y + height - 2);
            ctx.quadraticCurveTo(x + width, y + height, x + width - 2, y + height);
            ctx.lineTo(x + 2, y + height);
            ctx.quadraticCurveTo(x, y + height, x, y + height - 2);
            ctx.lineTo(x, y + 2);
            ctx.quadraticCurveTo(x, y, x + 2, y);
            ctx.closePath();
            ctx.fill();
            ctx.stroke();
        };

        const drawFist = (x, y, scale = 1) => {
            const fingerR = 2 * scale;
            const offsets = [-3, -1, 1, 3];
            offsets.forEach((offset) => {
                ctx.beginPath();
                ctx.arc(x + offset * scale, y, fingerR, 0, Math.PI * 2);
                ctx.fill();
                ctx.stroke();
            });
            ctx.beginPath();
            ctx.arc(x, y + 2.5 * scale, 2.5 * scale, 0, Math.PI * 2);
            ctx.fill();
            ctx.stroke();
        };

        const drawArm = (x, y, length, angle, fistScale = 1) => {
            ctx.save();
            ctx.translate(x, y);
            ctx.rotate(angle);
            ctx.beginPath();
            ctx.rect(-3, 0, 6, length);
            ctx.fill();
            ctx.stroke();
            drawFist(0, length + 3, fistScale);
            ctx.restore();
        };

        const drawFace = (state) => {
            const isFaceIdle = state === 'idle';
            const isFaceWalk = state === 'walk';
            const isFacePunch = state === 'punch' || state === 'kick' || state === 'jump_punch' ||
                state === 'jump_kick' || state === 'belly_bump' || state === 'ground_slam' ||
                state === 'back_attack' || state === 'throwing';
            const isFaceHit = state === 'hit';
            const isFaceJump = state === 'jump';
            const isFaceGrabbing = state === 'grabbing';
            const isFaceDead = state === 'dead';

            const leftEyeX = 27;
            const rightEyeX = 37;
            const eyeY = 18;

            const drawXEye = (x, y, size) => {
                ctx.beginPath();
                ctx.moveTo(x - size, y - size);
                ctx.lineTo(x + size, y + size);
                ctx.moveTo(x + size, y - size);
                ctx.lineTo(x - size, y + size);
                ctx.stroke();
            };

            ctx.strokeStyle = '#222222';
            ctx.lineWidth = 2;

            if (isFaceDead) {
                drawXEye(leftEyeX, eyeY, 3);
                drawXEye(rightEyeX, eyeY, 3);
            } else if (isFaceHit) {
                ctx.beginPath();
                ctx.moveTo(leftEyeX - 3, eyeY);
                ctx.lineTo(leftEyeX + 3, eyeY);
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(rightEyeX - 3, eyeY);
                ctx.lineTo(rightEyeX + 3, eyeY);
                ctx.stroke();
            } else {
                const eyeW = isFaceJump ? 5.5 : 5;
                const eyeH = isFaceJump ? 7 : 6;
                ctx.fillStyle = '#FFFFFF';
                ctx.beginPath();
                ctx.ellipse(leftEyeX, eyeY, eyeW, eyeH, 0, 0, Math.PI * 2);
                ctx.fill();
                ctx.stroke();
                ctx.beginPath();
                ctx.ellipse(rightEyeX, eyeY, eyeW, eyeH, 0, 0, Math.PI * 2);
                ctx.fill();
                ctx.stroke();
                ctx.fillStyle = '#000000';
                const pupilOffset = isFacePunch ? 1.5 : 0;
                ctx.beginPath();
                ctx.arc(leftEyeX + pupilOffset, eyeY + 1, 2, 0, Math.PI * 2);
                ctx.fill();
                ctx.beginPath();
                ctx.arc(rightEyeX + pupilOffset, eyeY + 1, 2, 0, Math.PI * 2);
                ctx.fill();
            }

            if (isFacePunch || isFaceGrabbing || isFaceHit) {
                ctx.strokeStyle = '#222222';
                ctx.lineWidth = 2.5;
                if (isFaceHit) {
                    ctx.beginPath();
                    ctx.moveTo(23, 12);
                    ctx.lineTo(30, 9);
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.moveTo(41, 12);
                    ctx.lineTo(34, 9);
                    ctx.stroke();
                } else {
                    const browDrop = isFaceGrabbing ? 15 : 14;
                    ctx.beginPath();
                    ctx.moveTo(23, 12);
                    ctx.lineTo(31, browDrop);
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.moveTo(41, 12);
                    ctx.lineTo(33, browDrop);
                    ctx.stroke();
                }
            }

            ctx.strokeStyle = '#222222';
            ctx.lineWidth = 1.5;
            if (isFaceDead) {
                ctx.fillStyle = lips;
                ctx.beginPath();
                ctx.ellipse(32, 28, 4, 5, 0, 0, Math.PI * 2);
                ctx.fill();
                ctx.stroke();
                ctx.fillStyle = '#E57373';
                ctx.beginPath();
                ctx.ellipse(32, 33, 3, 4, 0, 0, Math.PI * 2);
                ctx.fill();
            } else if (isFaceHit) {
                ctx.fillStyle = lips;
                ctx.beginPath();
                ctx.arc(32, 28, 5, 0, Math.PI * 2);
                ctx.fill();
                ctx.stroke();
            } else if (isFaceJump) {
                ctx.fillStyle = lips;
                ctx.beginPath();
                ctx.arc(32, 28, 2.5, 0, Math.PI * 2);
                ctx.fill();
                ctx.stroke();
            } else if (isFaceGrabbing) {
                ctx.fillStyle = '#FFFFFF';
                ctx.beginPath();
                ctx.rect(24, 26, 16, 6);
                ctx.fill();
                ctx.stroke();
                ctx.lineWidth = 1;
                ctx.beginPath();
                ctx.moveTo(28, 26);
                ctx.lineTo(28, 32);
                ctx.moveTo(32, 26);
                ctx.lineTo(32, 32);
                ctx.moveTo(36, 26);
                ctx.lineTo(36, 32);
                ctx.stroke();
            } else if (isFacePunch) {
                ctx.fillStyle = lips;
                ctx.beginPath();
                ctx.moveTo(22, 28);
                ctx.quadraticCurveTo(32, 34, 42, 28);
                ctx.quadraticCurveTo(32, 31, 22, 28);
                ctx.fill();
                ctx.stroke();
                ctx.beginPath();
                ctx.moveTo(24, 30);
                ctx.lineTo(40, 30);
                ctx.stroke();
            } else if (isFaceWalk) {
                ctx.fillStyle = lips;
                ctx.beginPath();
                ctx.ellipse(32, 29, 4, 3, 0, 0, Math.PI * 2);
                ctx.fill();
                ctx.stroke();
            } else {
                ctx.fillStyle = lips;
                ctx.beginPath();
                ctx.moveTo(26, 28);
                ctx.quadraticCurveTo(32, 32, 38, 28);
                ctx.quadraticCurveTo(32, 30, 26, 28);
                ctx.fill();
                ctx.stroke();
            }

            if (isFaceIdle || isFaceWalk) {
                ctx.lineWidth = 2;
                ctx.fillStyle = skin;
                ctx.beginPath();
                ctx.moveTo(26, 30);
                ctx.quadraticCurveTo(32, 38, 38, 30);
                ctx.quadraticCurveTo(32, 34, 26, 30);
                ctx.fill();
                ctx.stroke();
            }
            ctx.lineWidth = 2;
        };

        let leftLegOffsetX = 0;
        let rightLegOffsetX = 0;
        let leftLegOffsetY = 0;
        let rightLegOffsetY = 0;
        if (isWalk) {
            switch (walkFrame) {
                case 0:
                    leftLegOffsetX = 2;
                    rightLegOffsetX = -2;
                    leftLegOffsetY = -1;
                    rightLegOffsetY = 1;
                    break;
                case 2:
                    leftLegOffsetX = -2;
                    rightLegOffsetX = 2;
                    leftLegOffsetY = 1;
                    rightLegOffsetY = -1;
                    break;
                default:
                    break;
            }
        }

        // Legs
        ctx.fillStyle = pants;
        const leftLegX = 20 + legBack + leftLegOffsetX;
        const rightLegX = 34 + legBack + rightLegOffsetX;
        const leftLegY = 62 + legLift + leftLegOffsetY;
        const rightLegY = 62 + legLift + rightLegOffsetY;
        const drawRightLeg = !(isKick && this.attackCooldown > 0.2) && !isJumpKick;
        ctx.beginPath();
        ctx.rect(leftLegX, leftLegY, 8, 12);
        ctx.fill();
        ctx.stroke();
        if (drawRightLeg) {
            ctx.beginPath();
            ctx.rect(rightLegX, rightLegY, 8, 12);
            ctx.fill();
            ctx.stroke();
        }

        // Shoes
        ctx.fillStyle = shoes;
        drawShoe(leftLegX - 2, leftLegY + 10, 14, 6);
        if (drawRightLeg) {
            drawShoe(rightLegX - 2, rightLegY + 10, 14, 6);
        }

        // Kick animation — leg extends forward at an angle from the hip
        if (isKick && this.attackCooldown > 0.2) {
            ctx.fillStyle = pants;
            ctx.save();
            ctx.translate(40, 66);
            ctx.rotate(Math.PI / 6);
            ctx.beginPath();
            ctx.rect(0, -4, 28, 8);
            ctx.fill();
            ctx.stroke();
            ctx.fillStyle = shoes;
            drawShoe(24, -6, 12, 8);
            ctx.restore();
        }

        // Jump kick (dive kick) — leg extends diagonally downward
        if (isJumpKick) {
            ctx.fillStyle = pants;
            ctx.save();
            ctx.translate(38, 60);
            ctx.rotate(Math.PI / 4);
            ctx.beginPath();
            ctx.rect(0, -4, 30, 8);
            ctx.fill();
            ctx.stroke();
            ctx.fillStyle = shoes;
            drawShoe(26, -6, 12, 8);
            ctx.restore();
        }

        // Pants waistband
        ctx.fillStyle = pants;
        ctx.beginPath();
        ctx.rect(18 + legBack, 58 + legLift * 0.2, 28, 10);
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        ctx.moveTo(18 + legBack, 62 + legLift * 0.2);
        ctx.lineTo(46 + legBack, 62 + legLift * 0.2);
        ctx.stroke();

        // Body (white shirt) — bulging belly path with subtle breathing
        ctx.save();
        ctx.translate(32, 50);
        ctx.scale(1, breath);
        ctx.translate(-32, -50);
        ctx.fillStyle = shirt;
        ctx.beginPath();
        ctx.moveTo(18, 34);
        ctx.lineTo(46, 34);
        ctx.quadraticCurveTo(52, 44, 50, 56);
        ctx.quadraticCurveTo(48, 66, 32, 66);
        ctx.quadraticCurveTo(16, 66, 14, 56);
        ctx.quadraticCurveTo(12, 44, 18, 34);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();
        // Shirt highlight
        ctx.fillStyle = 'rgba(255, 255, 255, 0.18)';
        ctx.beginPath();
        ctx.ellipse(26, 44, 10, 7, -0.2, 0, Math.PI * 2);
        ctx.fill();
        // Collar line
        ctx.strokeStyle = '#222222';
        ctx.beginPath();
        ctx.moveTo(28, 34);
        ctx.lineTo(32, 40);
        ctx.lineTo(36, 34);
        ctx.stroke();
        ctx.restore();

        // Arms (yellow skin)
        ctx.fillStyle = skin;
        const armSwing = isWalk ? Math.sin(this.animTime * 10) * 0.4 : Math.sin(this.animTime * 2) * 0.2;
        let leftArmAngle = 0.5 + armSwing;
        let rightArmAngle = -0.5 - armSwing;
        let leftArmLen = 18;
        let rightArmLen = 18;
        if (isJump || isJumpPunch || isJumpKick || isSlam) {
            leftArmAngle = -1.2;
            rightArmAngle = -1.2;
            leftArmLen = 16;
            rightArmLen = 16;
        }
        if (isRolling) {
            leftArmAngle = 1.6;
            rightArmAngle = -1.6;
            leftArmLen = 12;
            rightArmLen = 12;
        }
        if (isPunch) {
            rightArmAngle = 0;
            rightArmLen = 24;
        }
        if (isJumpPunch) {
            rightArmAngle = -0.2;
            rightArmLen = 22;
            leftArmAngle = -1.1;
        }
        if (isBackAttack) {
            rightArmAngle = 0.4;
            rightArmLen = 20;
            leftArmAngle = -0.8;
            leftArmLen = 16;
        }
        if (isKick) {
            leftArmAngle = 0.2;
            rightArmAngle = -0.8;
        }
        if (isBelly) {
            leftArmAngle = 2.6;
            rightArmAngle = -2.6;
            leftArmLen = 14;
            rightArmLen = 14;
        }
        if (isGrab) {
            leftArmAngle = 1.4;
            rightArmAngle = -1.4;
            leftArmLen = 14;
            rightArmLen = 14;
        }
        if (isThrow) {
            rightArmAngle = 0.2;
            rightArmLen = 22;
            leftArmAngle = 1.6;
            leftArmLen = 14;
        }
        drawArm(18, 40, leftArmLen, leftArmAngle, 0.9);
        drawArm(46, 40, rightArmLen, rightArmAngle, 0.9);

        // Head (yellow)
        ctx.fillStyle = skin;
        ctx.beginPath();
        ctx.arc(32, 18, 17, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();
        // Head highlight
        ctx.fillStyle = 'rgba(255, 255, 255, 0.2)';
        ctx.beginPath();
        ctx.ellipse(26, 10, 8, 5, -0.3, 0, Math.PI * 2);
        ctx.fill();

        // Ears
        ctx.fillStyle = skin;
        ctx.beginPath();
        ctx.arc(14, 20, 4, -0.6, 1.6);
        ctx.fill();
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(50, 20, 4, Math.PI - 1.6, Math.PI + 0.6);
        ctx.fill();
        ctx.stroke();
        ctx.fillStyle = '#E8C000';
        ctx.beginPath();
        ctx.arc(14, 21, 1.5, 0, Math.PI * 2);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(50, 21, 1.5, 0, Math.PI * 2);
        ctx.fill();

        // Hair spikes (M-shaped zigzag)
        ctx.fillStyle = '#8B4513';
        ctx.beginPath();
        ctx.moveTo(20, 8);
        ctx.lineTo(24, 2);
        ctx.lineTo(28, 8);
        ctx.lineTo(32, 2);
        ctx.lineTo(36, 8);
        ctx.lineTo(40, 2);
        ctx.lineTo(44, 8);
        ctx.lineTo(44, 12);
        ctx.lineTo(20, 12);
        ctx.closePath();
        ctx.fill();
        ctx.stroke();

        drawFace(this.state);

        // Stubble
        ctx.fillStyle = '#888888';
        for (let sxPos = 24; sxPos <= 40; sxPos += 3) {
            const yOffset = Math.abs(sxPos - 32) * 0.12;
            ctx.beginPath();
            ctx.arc(sxPos, 33 + yOffset, 0.8, 0, Math.PI * 2);
            ctx.fill();
        }

        // Belly bump — belly extends forward, arms swept back
        if (isBelly && this.attackCooldown > 0.15) {
            ctx.fillStyle = shirt;
            ctx.beginPath();
            ctx.ellipse(52, 52, 14, 11, 0, 0, Math.PI * 2);
            ctx.fill();
            ctx.stroke();
        }

        // Ground slam — arms spread wide, shockwave ring
        if (isSlam && this.attackCooldown > 0.15) {
            ctx.strokeStyle = '#FFD700';
            ctx.lineWidth = 3;
            ctx.beginPath();
            ctx.ellipse(32, 78, 40, 10, 0, 0, Math.PI * 2);
            ctx.stroke();
        }
        
        ctx.restore();
    }
}
