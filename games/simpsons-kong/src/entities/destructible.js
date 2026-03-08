// ==========================================================================
// Destructible Objects — AAA-L1
// ==========================================================================
// Springfield street props that can be smashed for items and points.
//
// INTEGRATION (gameplay.js — do NOT add here, Solo owns that file):
//   1. Import: import { Destructible, DESTRUCTIBLE_TYPES } from '../entities/destructible.js';
//   2. On wave/level init, create instances from LEVEL_1.destructibles:
//        const destructibles = LEVEL_1.destructibles.map(d =>
//            new Destructible(d.x, d.y, d.type));
//   3. In update loop:
//        destructibles.forEach(d => d.update(dt));
//   4. Player attack hit detection — after computing player hitbox:
//        destructibles.forEach(d => {
//            if (!d.broken && rectsOverlap(attackBox, d.getHurtbox())) {
//                const drop = d.takeDamage(attackDamage);
//                if (drop) { /* spawn pickup at d.x, d.y based on drop.type */ }
//            }
//        });
//   5. Movement collision — block player/enemy when intact:
//        destructibles.forEach(d => {
//            if (!d.broken && rectsOverlap(entity, d.getHurtbox())) {
//                // push entity out of destructible bounds
//            }
//        });
//   6. In render loop (call BEFORE entity rendering for depth sorting):
//        destructibles.forEach(d => d.render(ctx, cameraX));
// ==========================================================================

// ---------------------------------------------------------------------------
// Type definitions
// ---------------------------------------------------------------------------

export const DESTRUCTIBLE_TYPES = {
    trashCan: {
        hp: 10,
        width: 32,
        height: 40,
        color: '#6B6B6B',
        accentColor: '#4A4A4A',
        label: 'Trash Can',
        dropChance: 0.4
    },
    newspaperStand: {
        hp: 15,
        width: 44,
        height: 50,
        color: '#1565C0',
        accentColor: '#0D47A1',
        label: 'Newspaper Stand',
        dropChance: 0.5
    },
    parkingMeter: {
        hp: 20,
        width: 16,
        height: 56,
        color: '#9E9E9E',
        accentColor: '#616161',
        label: 'Parking Meter',
        dropChance: 0.5
    },
    lardLadSign: {
        hp: 25,
        width: 52,
        height: 64,
        color: '#E65100',
        accentColor: '#BF360C',
        label: 'Lard Lad Donut Sign',
        dropChance: 0.6
    }
};

// ---------------------------------------------------------------------------
// Drop table
// ---------------------------------------------------------------------------
const DROP_TABLE = [
    { type: 'health', weight: 3 },
    { type: 'score',  weight: 4 },
    { type: 'none',   weight: 3 }
];
const TOTAL_WEIGHT = DROP_TABLE.reduce((s, d) => s + d.weight, 0);

function rollDrop() {
    let roll = Math.random() * TOTAL_WEIGHT;
    for (const entry of DROP_TABLE) {
        roll -= entry.weight;
        if (roll <= 0) return entry.type === 'none' ? null : { type: entry.type };
    }
    return null;
}

// ---------------------------------------------------------------------------
// Destructible entity
// ---------------------------------------------------------------------------

export class Destructible {
    constructor(x, y, type) {
        const config = DESTRUCTIBLE_TYPES[type] || DESTRUCTIBLE_TYPES.trashCan;
        this.x = x;
        this.y = y;
        this.width = config.width;
        this.height = config.height;
        this.hp = config.hp;
        this.maxHp = config.hp;
        this.type = type;
        this.color = config.color;
        this.accentColor = config.accentColor;
        this.dropChance = config.dropChance;
        this.broken = false;

        // Visual feedback
        this.shakeTime = 0;
        this.shakeIntensity = 0;

        // Break animation: scattered debris pieces
        this.debris = [];
        this.breakAnimTime = 0;
    }

    // Returns a drop descriptor or null
    takeDamage(amount) {
        if (this.broken) return null;
        this.hp -= amount;
        this.shakeTime = 0.15;
        this.shakeIntensity = 3;

        if (this.hp <= 0) {
            this.hp = 0;
            this.broken = true;
            this._spawnDebris();
            this.breakAnimTime = 0.6;
            if (Math.random() < this.dropChance) return rollDrop();
        }
        return null;
    }

    getHurtbox() {
        return { x: this.x, y: this.y, width: this.width, height: this.height };
    }

    update(dt) {
        if (this.shakeTime > 0) this.shakeTime -= dt;

        // Animate debris
        if (this.breakAnimTime > 0) {
            this.breakAnimTime -= dt;
            for (const p of this.debris) {
                p.x += p.vx * dt;
                p.y += p.vy * dt;
                p.vy += 400 * dt; // gravity
                p.alpha = Math.max(0, this.breakAnimTime / 0.6);
            }
        }
    }

    render(ctx, cameraX) {
        const screenX = this.x - cameraX;

        // Draw debris after destruction
        if (this.broken) {
            if (this.breakAnimTime > 0) {
                for (const p of this.debris) {
                    ctx.globalAlpha = p.alpha;
                    ctx.fillStyle = p.color;
                    ctx.fillRect(p.x - cameraX, p.y, p.size, p.size);
                }
                ctx.globalAlpha = 1;
            }
            return;
        }

        ctx.save();

        // Shake offset
        let shakeX = 0;
        if (this.shakeTime > 0) {
            shakeX = (Math.random() - 0.5) * 2 * this.shakeIntensity;
        }

        const sx = screenX + shakeX;
        const sy = this.y;

        // Damage tint — darken as HP drops
        const hpRatio = this.hp / this.maxHp;

        // Type-specific rendering
        switch (this.type) {
            case 'trashCan':
                this._renderTrashCan(ctx, sx, sy, hpRatio);
                break;
            case 'newspaperStand':
                this._renderNewspaperStand(ctx, sx, sy, hpRatio);
                break;
            case 'parkingMeter':
                this._renderParkingMeter(ctx, sx, sy, hpRatio);
                break;
            case 'lardLadSign':
                this._renderLardLadSign(ctx, sx, sy, hpRatio);
                break;
            default:
                this._renderGeneric(ctx, sx, sy, hpRatio);
        }

        // Damage cracks overlay when below 50% HP
        if (hpRatio < 0.5) {
            ctx.strokeStyle = 'rgba(0,0,0,0.4)';
            ctx.lineWidth = 1;
            ctx.beginPath();
            ctx.moveTo(sx + this.width * 0.3, sy);
            ctx.lineTo(sx + this.width * 0.5, sy + this.height * 0.4);
            ctx.lineTo(sx + this.width * 0.4, sy + this.height);
            ctx.stroke();
        }

        ctx.restore();
    }

    // --- Type-specific renders ---

    _renderTrashCan(ctx, x, y, hpRatio) {
        // Body — tapered cylinder
        ctx.fillStyle = this._tintColor(this.color, hpRatio);
        ctx.fillRect(x + 2, y + 6, this.width - 4, this.height - 6);
        // Lid
        ctx.fillStyle = this._tintColor(this.accentColor, hpRatio);
        ctx.fillRect(x, y, this.width, 8);
        // Handle on lid
        ctx.fillStyle = '#888';
        ctx.fillRect(x + this.width / 2 - 4, y - 2, 8, 4);
        // Horizontal bands
        ctx.fillStyle = this.accentColor;
        ctx.fillRect(x + 2, y + 16, this.width - 4, 2);
        ctx.fillRect(x + 2, y + this.height - 10, this.width - 4, 2);
    }

    _renderNewspaperStand(ctx, x, y, hpRatio) {
        // Box body
        ctx.fillStyle = this._tintColor(this.color, hpRatio);
        ctx.fillRect(x, y + 8, this.width, this.height - 8);
        // Sloped top panel
        ctx.fillStyle = this._tintColor(this.accentColor, hpRatio);
        ctx.fillRect(x, y, this.width, 10);
        // Window
        ctx.fillStyle = 'rgba(200, 230, 255, 0.7)';
        ctx.fillRect(x + 4, y + 14, this.width - 8, 20);
        // "NEWS" text placeholder
        ctx.fillStyle = '#FFF';
        ctx.font = '8px monospace';
        ctx.fillText('NEWS', x + 8, y + 28);
        // Coin slot
        ctx.fillStyle = '#333';
        ctx.fillRect(x + this.width - 10, y + 38, 6, 3);
    }

    _renderParkingMeter(ctx, x, y, hpRatio) {
        // Pole
        ctx.fillStyle = this._tintColor(this.accentColor, hpRatio);
        ctx.fillRect(x + 5, y + 18, 6, this.height - 18);
        // Meter head
        ctx.fillStyle = this._tintColor(this.color, hpRatio);
        ctx.beginPath();
        ctx.arc(x + 8, y + 12, 8, 0, Math.PI * 2);
        ctx.fill();
        // Indicator
        ctx.fillStyle = hpRatio > 0.5 ? '#4CAF50' : '#F44336';
        ctx.beginPath();
        ctx.arc(x + 8, y + 12, 4, 0, Math.PI * 2);
        ctx.fill();
        // Base
        ctx.fillStyle = this.accentColor;
        ctx.fillRect(x + 2, y + this.height - 4, 12, 4);
    }

    _renderLardLadSign(ctx, x, y, hpRatio) {
        // Sign board
        ctx.fillStyle = this._tintColor(this.color, hpRatio);
        ctx.fillRect(x, y, this.width, this.height * 0.7);
        // Border
        ctx.strokeStyle = this._tintColor('#FFD600', hpRatio);
        ctx.lineWidth = 2;
        ctx.strokeRect(x + 2, y + 2, this.width - 4, this.height * 0.7 - 4);
        // Donut circle
        ctx.fillStyle = '#FFD600';
        ctx.beginPath();
        ctx.arc(x + this.width / 2, y + this.height * 0.3, 10, 0, Math.PI * 2);
        ctx.fill();
        // Donut hole
        ctx.fillStyle = this._tintColor(this.color, hpRatio);
        ctx.beginPath();
        ctx.arc(x + this.width / 2, y + this.height * 0.3, 4, 0, Math.PI * 2);
        ctx.fill();
        // Post
        ctx.fillStyle = this._tintColor(this.accentColor, hpRatio);
        ctx.fillRect(x + this.width / 2 - 4, y + this.height * 0.7, 8, this.height * 0.3);
    }

    _renderGeneric(ctx, x, y, hpRatio) {
        ctx.fillStyle = this._tintColor(this.color, hpRatio);
        ctx.fillRect(x, y, this.width, this.height);
    }

    // Darken color based on remaining HP
    _tintColor(hex, ratio) {
        const r = parseInt(hex.slice(1, 3), 16);
        const g = parseInt(hex.slice(3, 5), 16);
        const b = parseInt(hex.slice(5, 7), 16);
        const f = 0.4 + 0.6 * ratio; // 40% brightness at 0 HP, 100% at full
        return `rgb(${Math.floor(r * f)},${Math.floor(g * f)},${Math.floor(b * f)})`;
    }

    _spawnDebris() {
        const count = 6 + Math.floor(Math.random() * 4);
        for (let i = 0; i < count; i++) {
            this.debris.push({
                x: this.x + Math.random() * this.width,
                y: this.y + Math.random() * this.height * 0.5,
                vx: (Math.random() - 0.5) * 200,
                vy: -100 - Math.random() * 150,
                size: 3 + Math.random() * 5,
                color: Math.random() > 0.5 ? this.color : this.accentColor,
                alpha: 1
            });
        }
    }
}
