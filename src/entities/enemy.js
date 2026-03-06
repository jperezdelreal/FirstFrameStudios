export class Enemy {
    constructor(x, y, variant = 'normal') {
        this.x = x;
        this.y = y;
        this.width = 48;
        this.height = 76;
        this.vx = 0;
        this.vy = 0;
        this.speed = 100;
        
        this.variant = variant;
        this.health = variant === 'tough' ? 50 : 30;
        this.maxHealth = this.health;
        
        this.state = 'idle';
        this.facing = -1;
        this.animTime = 0;
        
        this.attackCooldown = 0;
        this.hitstunTime = 0;
        this.flashTime = 0;
        this.deathTime = 0;
        
        this.knockbackVx = 0;
        this.knockbackVy = 0;
        
        this.aiCooldown = 0;

        // Behavior-tree state (used by AI system)
        this.hasAttackSlot = false;
        this.circleDirection = Math.random() < 0.5 ? 1 : -1;
    }

    update(dt) {
        this.animTime += dt;
        
        if (this.attackCooldown > 0) this.attackCooldown -= dt;
        if (this.hitstunTime > 0) this.hitstunTime -= dt;
        if (this.flashTime > 0) this.flashTime -= dt;
        if (this.aiCooldown > 0) this.aiCooldown -= dt;
        
        if (this.state === 'dead') {
            this.deathTime += dt;
            return;
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
        this.health -= damage;
        this.hitstunTime = 0.2;
        this.flashTime = 0.2;
        this.knockbackVx = knockbackX;
        this.knockbackVy = knockbackY;
        
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
        if (this.state === 'attack' && this.attackCooldown > 0.3) {
            return {
                x: this.x + (this.facing > 0 ? this.width : -35),
                y: this.y + 20,
                width: 35,
                height: 35
            };
        }
        return null;
    }

    render(ctx) {
        if (this.state === 'dead') {
            const alpha = Math.max(0, 1 - this.deathTime / 0.5);
            ctx.globalAlpha = alpha;
        }
        
        // Shadow
        ctx.fillStyle = 'rgba(0, 0, 0, 0.3)';
        ctx.beginPath();
        ctx.ellipse(this.x + this.width / 2, this.y + this.height - 5, 20, 8, 0, 0, Math.PI * 2);
        ctx.fill();
        
        // Flash white when hit
        if (this.flashTime > 0) {
            ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
            ctx.fillRect(this.x, this.y, this.width, this.height);
        }
        
        ctx.save();
        if (this.facing < 0) {
            ctx.translate(this.x + this.width, this.y);
            ctx.scale(-1, 1);
        } else {
            ctx.translate(this.x, this.y);
        }
        
        // Body color based on variant
        const bodyColor = this.variant === 'tough' ? '#8B0000' : '#663399';
        
        // Body
        ctx.fillStyle = bodyColor;
        ctx.fillRect(14, 30, 20, 35);
        
        // Head
        ctx.fillStyle = '#FFB6C1';
        ctx.beginPath();
        ctx.arc(24, 18, 12, 0, Math.PI * 2);
        ctx.fill();
        
        // Eyes (angry)
        ctx.fillStyle = '#000000';
        ctx.fillRect(19, 16, 3, 2);
        ctx.fillRect(26, 16, 3, 2);
        
        // Arms
        ctx.fillStyle = '#FFB6C1';
        const armBob = Math.sin(this.animTime * 6) * 2;
        ctx.fillRect(8, 35 + armBob, 6, 18);
        ctx.fillRect(34, 35 - armBob, 6, 18);
        
        // Attack animation
        if (this.state === 'attack') {
            ctx.fillRect(34, 40, 12, 6);
        }
        
        // Legs
        ctx.fillStyle = '#333333';
        ctx.fillRect(16, 65, 7, 11);
        ctx.fillRect(25, 65, 7, 11);
        
        ctx.restore();
        
        if (this.state === 'dead') {
            ctx.globalAlpha = 1;
        }
    }
}
